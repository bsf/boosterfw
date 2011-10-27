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
    procedure LoadCatalogItems;
    procedure LoadCatalogItem(AItem: TReportCatalogItem);
    procedure UnLoadCatalogItem(AItem: TReportCatalogItem);

    procedure ActionReportLaunch(Sender: IAction);
    procedure RegisterSettings;
    procedure LoadActivityImage;
    procedure OnActivityLoadingHandler(EventData: Variant);
  protected
   function GetItem(const URI: string): TReportCatalogItem;
    procedure OnInitialize; override;
    procedure Terminate; override;
  end;

implementation

{ TReportCatalogController }

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
  layout: TReportLayout;
  activitySvc: IActivityService;
begin
  activitySvc := WorkItem.Services[IActivityService] as IActivityService;

  //Layouts
  for layout in AItem.Manifest.Layouts do
  begin
    with FReportService.Add(layout.ID) do
    begin
      Template := AItem.Path + layout.Template;
      Group := AItem.Group.Caption;
      Caption := AItem.Caption;
      if layout.ID <> AItem.ID then
        Caption := Caption + ' [' + layout.Caption + ']';
    end;

    with activitySvc.RegisterActivityInfo(layout.ID) do
    begin
      if layout.ID <> AItem.ID then
      begin
        Title := AItem.Caption + ' [' + layout.Caption + ']';
        MenuIndex := -1;
      end
      else
      begin
        Title := AItem.Caption;
        if not AItem.IsTop then
          MenuIndex := -1;
      end;
      Group := AItem.Group.Caption;
      Image := FActivityImage;
      UsePermission := true;
    end;
  end;
  WorkItem.Root.Actions[AItem.ID].SetHandler(ActionReportLaunch);
  WorkItem.Root.Actions[AItem.ID].SetDataClass(TReportLaunchData);


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

procedure TReportCatalogController.OnActivityLoadingHandler(EventData: Variant);
begin
  LoadCatalogItems;
end;

procedure TReportCatalogController.OnInitialize;
var
  activitySvc: IActivityService;
begin
  WorkItem.Root.Services.Add(Self as IReportCatalogService);

  FActivityImage := TBitmap.Create;
  LoadActivityImage;

  RegisterSettings;
  FReportService := IReportService(WorkItem.Services[IReportService]);

  FReportCatalog := TReportCatalog.Create(Self);

  FCatalogPath := App.Settings[SETTING_REPORTS_LOCATION];

  ActivitySvc := WorkItem.Services[IActivityService] as IActivityService;

  with ActivitySvc.RegisterActivityInfo(VIEW_RPT_CATALOG) do
  begin
    Title := VIEW_RPT_CATALOG_CAPTION;
    Group := MAIN_MENU_SERVICE_GROUP;
  end;

  ActivitySvc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_RPT_CATALOG, TReportCatalogPresenter, TfrReportCatalogView));

  ActivitySvc.RegisterActivityInfo(VIEW_REPORT_LAUNCHER);
  ActivitySvc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_REPORT_LAUNCHER, TReportLauncherPresenter, TfrReportLauncherView));

  ActivitySvc.RegisterActivityInfo(VIEW_RPT_ITEM_SETUP);
  ActivitySvc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_RPT_ITEM_SETUP, TReportSetupPresenter, TfrReportSetupView));


  WorkItem.Root.EventTopics[EVT_ACTIVITY_LOADING].AddSubscription(Self, OnActivityLoadingHandler);
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
end;



end.
