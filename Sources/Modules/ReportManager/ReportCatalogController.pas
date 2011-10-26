unit ReportCatalogController;

interface
uses classes, CoreClasses, CustomUIController, sysutils,
  ShellIntf, ReportServiceIntf, ViewServiceIntf, ActivityServiceIntf,
  CommonUtils, ConfigServiceIntf, graphics, CommonViewIntf,
  ReportCatalogConst, ReportCatalogClasses,
  ReportCatalogPresenter, ReportCatalogView,
  ReportLauncherPresenter, ReportLauncherView,
  ReportSetupPresenter, ReportSetupView, IOUtils;

const
  COMMAND_REPORT_CATALOG_RELOAD = '{04496C3E-9A87-40A5-84BD-CD6E409F4C13}';
  COMMAND_REPORT_CATALOG_DESIGN = '{C7D77C62-FDC2-4C68-BBE2-783FE93C447F}';
  COMMAND_DATA_REPORTID = 'ReportID';

  SETTING_REPORTS_LOCATION = 'Reports.Location';

  REPORT_NAVBAR_IMAGE_RES_NAME = 'REPORT_NAVBAR_IMAGE';

type
  TReportCatalogController = class(TCustomUIController, IReportCatalogService)
  private
    FActivityImage: TBitmap;
    FCatalogPath: string;
    FReportCatalog: TReportCatalog;
    FReportService: IReportService;
    FActivitySvc: IActivityManagerService;
    procedure LoadCatalogItems;
    procedure LoadCatalogItem(AItem: TReportCatalogItem);
    procedure UnLoadCatalogItem(AItem: TReportCatalogItem);

    procedure ActionReportCatalogReload(Sender: IAction);
    procedure ActionReportLaunch(Sender: IAction);
    procedure CmdReportLaunch(Sender: TObject);
    procedure CmdReportInfo(Sender: TObject);
    procedure CmdReportSetup(Sender: TObject);
    procedure RegisterSettings;
    procedure LoadActivityImage;
  protected
   function GetItem(const URI: string): TReportCatalogItem;
    procedure OnInitialize; override;
    procedure Terminate; override;
  end;

implementation

{ TReportCatalogController }

procedure TReportCatalogController.ActionReportCatalogReload(
  Sender: IAction);
begin
  LoadCatalogItems;
end;

procedure TReportCatalogController.ActionReportLaunch(Sender: IAction);
var
  action: IAction;
  launcherData: TReportLauncherPresenterData;
  launchData: TReportLaunchData;
begin
  launchData := Sender.Data as TReportLaunchData;
  App.Security.DemandPermission(SECURITY_PERMISSION_REPORT_EXECUTE, launchData.ReportURI);

  action := WorkItem.Actions[VIEW_REPORT_LAUNCHER];
  action.ResetData;
  launcherData := action.Data as TReportLauncherPresenterData;
  launcherData.PresenterID := launchData.ReportURI + Sender.Caller.ID;
  launcherData.ReportURI := launchData.ReportURI;
  launcherData.ImmediateRun := launchData.ImmediateRun;
  launcherData.AssignLaunchData(launchData);
  action.Execute(Sender.Caller);
end;

procedure TReportCatalogController.CmdReportInfo(Sender: TObject);
var
  Intf: ICommand;
  ItemID: string;
  rcItem: TReportCatalogItem;
begin
  Sender.GetInterface(ICommand, Intf);
  ItemID := Intf.Data[COMMAND_DATA_REPORTID];
  rcItem := FReportCatalog.GetItem(ItemID);

  if rcItem.LoadErrorCode = 0 then
    App.Views.MessageBox.InfoMessage(rcItem.ID + #10#13 + rcItem.Manifest.Description)
  else
    App.Views.MessageBox.ErrorMessage(rcItem.ID + #10#13 + rcItem.LoadErrorInfo);

end;

procedure TReportCatalogController.CmdReportLaunch(Sender: TObject);
var
  Intf: ICommand;
  _ReportID: string;
begin
  Sender.GetInterface(ICommand, Intf);
  _ReportID := Intf.Name;
  Intf := nil;
  WorkItem.Actions[_ReportID].Execute(WorkItem);
end;

procedure TReportCatalogController.CmdReportSetup(Sender: TObject);
var
  Intf: ICommand;
  _ReportID: string;
  action: IAction;
begin
  Sender.GetInterface(ICommand, Intf);
  _ReportID := Intf.Data[COMMAND_DATA_REPORTID];
  Intf := nil;

  App.Security.DemandPermission(SECURITY_PERMISSION_REPORT_SETUP, _ReportID);

  action := WorkItem.Actions[VIEW_RPT_ITEM_SETUP];
  (action.Data as TReportSetupPresenterData).ReportID := _ReportID;
  action.Execute(WorkItem);

end;

function TReportCatalogController.GetItem(
  const URI: string): TReportCatalogItem;
begin
  Result := FReportCatalog.GetItem(URI);
end;

procedure TReportCatalogController.LoadActivityImage;
var
  ImgRes: TResourceStream;
begin
  ImgRes := TResourceStream.Create(HInstance, 'REPORT_NAVBAR_IMAGE', 'file');
  try
    FActivityImage.LoadFromStream(ImgRes);
  finally
    ImgRes.Free;
  end;
end;

procedure TReportCatalogController.LoadCatalogItem(
  AItem: TReportCatalogItem);
var

  I: integer;

  activityItem: IActivity;
  activityItemChild: IActivity;
  layout: TReportLayout;
  svc: IActivityService;
  activityInfo: IActivityInfo;
begin

  //Layouts
  for layout in AItem.Manifest.Layouts do
    with FReportService.Add(layout.ID) do
    begin
      Template := AItem.Path + layout.Template;
      Group := AItem.Group.Caption;
      Caption := AItem.Caption;
      if layout.ID <> AItem.ID then
        Caption := Caption + ' [' + layout.Caption + ']';
    end;
  WorkItem.Root.Actions[AItem.ID].SetHandler(ActionReportLaunch);
  WorkItem.Root.Actions[AItem.ID].SetDataClass(TReportLaunchData);


  if not AItem.IsTop then Exit;

  svc := WorkItem.Services[IActivityService] as IActivityService;
  activityInfo := svc.RegisterActivityInfo(AItem.ID);
  with activityInfo do
  begin
    //activityItem.Data[COMMAND_DATA_REPORTID] := AItem.ID;
    Title := AItem.Caption;
    Group := AItem.Group.Caption; // + ' - отчеты';
    Image := FActivityImage;
  end;

  {
  activityItem := FActivitySvc.Items.Add(AItem.ID, false);
  activityItem.Data[COMMAND_DATA_REPORTID] := AItem.ID;
  activityItem.Caption := AItem.Caption;
  activityItem.Category := ShellIntf.MAIN_MENU_CATEGORY; // ACT_CTG_REPORTS;
  activityItem.Group := AItem.Group.Caption; // + ' - отчеты';

  activityItem.Image := FActivityImage;

  activityItem.SetCustomPermissionOptions(
    AItem.ID, SECURITY_PERMISSION_REPORT_EXECUTE);
  activityItem.SetHandler(CmdReportLaunch);
   }

  {Subitems}
 {
  for I := 0 to AItem.Manifest.ExtendCommands.Count - 1 do
  begin
    activityItemChild := activityItem.Items.
      Add(AItem.Manifest.ExtendCommands.ValueFromIndex[I]);
    activityItemChild.Caption := AItem.Manifest.ExtendCommands.Names[I];
    activityItemChild.Data[COMMAND_DATA_REPORTID] := AItem.ID;
  end;

  activityItemChild := activityItem.Items.Add('ReportInfo_' + AItem.ID, false);
  activityItemChild.Data[COMMAND_DATA_REPORTID] := AItem.ID;
  activityItemChild.Caption := 'Описание отчета';
  activityItemChild.Section := 99;
  activityItemChild.SetHandler(CmdReportInfo);

  activityItemChild := activityItem.Items.Add('ReportSetup_' + AItem.ID, false);
  activityItemChild.Data[COMMAND_DATA_REPORTID] := AItem.ID;
  activityItemChild.Caption := 'Настройка отчета';
  activityItemChild.Section := 99;
  activityItemChild.SetCustomPermissionOptions(
    AItem.ID, SECURITY_PERMISSION_REPORT_SETUP);
  activityItemChild.SetHandler(CmdReportSetup);
  }
end;

procedure TReportCatalogController.LoadCatalogItems;
var
  I, Y: integer;
begin

  {Clear Report&NavBar Items}
{  for I := WorkItem.WorkItems.Count - 1 downto 0 do
    if Assigned(WorkItem.WorkItems[I].Controller) and
       (WorkItem.WorkItems[I].Controller is TReportLauncherPresenter) then
       TReportLauncherPresenter(WorkItem.WorkItems[I].Controller).CloseView;}

  for I := WorkItem.WorkItems.Count - 1 downto 0 do
    if Assigned(WorkItem.WorkItems[I].Controller) and
       (WorkItem.WorkItems[I].Controller is TReportLauncherPresenter) then
       WorkItem.WorkItems[I].Free;

  for I := 0 to FReportCatalog.Groups.Count - 1 do
    for Y := 0 to FReportCatalog.Groups[I].Items.Count - 1 do
      UnLoadCatalogItem(FReportCatalog.Groups[I].Items[Y]);

  FReportCatalog.Open(FCatalogPath);

  {Add Report&NavBar Items}
  for I := 0 to FReportCatalog.Groups.Count - 1 do
    for Y := 0 to FReportCatalog.Groups[I].Items.Count - 1 do
      LoadCatalogItem(FReportCatalog.Groups[I].Items[Y]);
end;

procedure TReportCatalogController.OnInitialize;
var
  activitySvc: IActivityService;
  activityInfo: IActivityInfo;
begin
  WorkItem.Root.Services.Add(Self as IReportCatalogService);

  FActivityImage := TBitmap.Create;
  LoadActivityImage;

  RegisterSettings;
  FReportService := IReportService(WorkItem.Services[IReportService]);
  FActivitySvc := IActivityManagerService(WorkItem.Services[IActivityManagerService]);
  FReportCatalog := TReportCatalog.Create(Self);

  FCatalogPath := App.Settings[SETTING_REPORTS_LOCATION];

  RegisterActivity(VIEW_RPT_CATALOG, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_RPT_CATALOG_CAPTION, TReportCatalogPresenter, TfrReportCatalogView);

  RegisterActivity(COMMAND_REPORT_CATALOG_RELOAD, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    'Обновить список отчетов', ActionReportCatalogReload, false);

  ActivitySvc := WorkItem.Services[IActivityService] as IActivityService;

  ActivitySvc.RegisterActivityInfo(VIEW_REPORT_LAUNCHER);
  ActivitySvc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_REPORT_LAUNCHER, TReportLauncherPresenter, TfrReportLauncherView));

//  RegisterView(VIEW_REPORT_LAUNCHER, TReportLauncherPresenter, TfrReportLauncherView);

  RegisterView(VIEW_RPT_ITEM_SETUP, TReportSetupPresenter, TfrReportSetupView);

  LoadCatalogItems;

end;

procedure TReportCatalogController.RegisterSettings;
begin
  with App.Settings.Add(SETTING_REPORTS_LOCATION) do
  begin
    Category := 'Отчеты';
    Caption := 'Путь';
    DefaultValue := '%ROOTDIR%\Reports\';
    //StorageLevels := StorageLevels - [slUserProfile, slHostProfile];
  end;
end;

procedure TReportCatalogController.Terminate;
begin
  WorkItem.Root.Services.Remove(Self as IReportCatalogService);
end;

procedure TReportCatalogController.UnLoadCatalogItem(
  AItem: TReportCatalogItem);
begin
  FReportService.Remove(AItem.ID);
  FActivitySvc.Items.Remove(AItem.ID);
end;



end.
