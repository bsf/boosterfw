unit ReportingController;

interface
uses classes, CoreClasses,  sysutils, variants,
  ShellIntf, ReportServiceIntf,
  CommonUtils, ConfigServiceIntf, graphics, UIClasses,
  ReportCatalogConst, ReportCatalogClasses,
  ReportCatalogPresenter, ReportCatalogView,
  ReportLauncherPresenter, ReportLauncherView,
  ReportSetupPresenter, ReportSetupView, IOUtils;

const
  COMMAND_REPORT_CATALOG_RELOAD = '{04496C3E-9A87-40A5-84BD-CD6E409F4C13}';
  COMMAND_REPORT_CATALOG_DESIGN = '{C7D77C62-FDC2-4C68-BBE2-783FE93C447F}';
  COMMAND_DATA_REPORTID = 'ReportID';

  SETTING_REPORTS_LOCATION = 'Reports.Location';

type
  TReportingController = class(TWorkItemController, IReportCatalogService)
  private
    FActivityImage: TBitmap;
    FCatalogPath: string;
    FReportCatalog: TReportCatalog;
    FReportService: IReportService;
    procedure LoadCatalogItems;
    procedure LoadCatalogItem(AItem: TReportCatalogItem);
    procedure UnLoadCatalogItem(AItem: TReportCatalogItem);

    procedure RegisterSettings;
    procedure LoadActivityImage;
  protected
   function GetItem(const URI: string): TReportCatalogItem;
    procedure Initialize; override;
    procedure Terminate; override;
  type
    TReportActivityHandler = class(TActivityHandler)
      procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
    end;
  end;

implementation

{ TReportCatalogController }


function TReportingController.GetItem(
  const URI: string): TReportCatalogItem;
begin
  Result := FReportCatalog.GetItem(URI);
end;

procedure TReportingController.LoadActivityImage;
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

procedure TReportingController.LoadCatalogItem(
  AItem: TReportCatalogItem);
var
  layout: TReportLayout;
  I: integer;
begin
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

    with WorkItem.Activities[layout.ID] do
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
        RegisterHandler(TReportActivityHandler.Create);
      end;
      Group := AItem.Group.Caption;
      Image := FActivityImage;
      UsePermission := true;

      for I := 0 to  AItem.Manifest.ParamNodes.Count - 1 do
        Params.Value[AItem.Manifest.ParamNodes[I].Name] := Unassigned;
    end;
  end;
//  WorkItem.Root.Actions[AItem.ID].SetHandler(ActionReportLaunch);
//  WorkItem.Root.Actions[AItem.ID].SetDataClass(TReportLaunchData);


end;

procedure TReportingController.LoadCatalogItems;
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

procedure TReportingController.Initialize;
begin
  WorkItem.Root.Services.Add(Self as IReportCatalogService);

  FActivityImage := TBitmap.Create;
  LoadActivityImage;

  RegisterSettings;
  FReportService := IReportService(WorkItem.Services[IReportService]);

  FReportCatalog := TReportCatalog.Create(Self);

  FCatalogPath := App.Settings[SETTING_REPORTS_LOCATION];

  with  WorkItem.Activities[VIEW_RPT_CATALOG] do
  begin
    Title := VIEW_RPT_CATALOG_CAPTION;
    Group := MAIN_MENU_SERVICE_GROUP;
    RegisterHandler(TViewActivityHandler.Create(TReportCatalogPresenter, TfrReportCatalogView));
  end;

  WorkItem.Activities[VIEW_REPORT_LAUNCHER].
    RegisterHandler(TViewActivityHandler.Create(TReportLauncherPresenter, TfrReportLauncherView));

{  ActivitySvc.RegisterActivityInfo(VIEW_RPT_ITEM_SETUP);
  ActivitySvc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_RPT_ITEM_SETUP, TReportSetupPresenter, TfrReportSetupView));
 }

   LoadCatalogItems;
//  WorkItem.Root.EventTopics[EVT_ACTIVITY_LOADING].AddSubscription(Self, OnActivityLoadingHandler);
end;

procedure TReportingController.RegisterSettings;
begin
  with App.Settings.Add(SETTING_REPORTS_LOCATION) do
  begin
    Category := 'Отчеты';
    Caption := 'Путь';
    DefaultValue := '%ROOTDIR%\Reports\';
    //StorageLevels := StorageLevels - [slUserProfile, slHostProfile];
  end;
end;

procedure TReportingController.Terminate;
begin
  WorkItem.Root.Services.Remove(Self as IReportCatalogService);
end;

procedure TReportingController.UnLoadCatalogItem(
  AItem: TReportCatalogItem);
begin
  FReportService.Remove(AItem.ID);
end;


{ TReportingController.TReportActivityHandler }

procedure TReportingController.TReportActivityHandler.Execute(Sender: TWorkItem;
  Activity: IActivity);
var
  I: integer;
begin
//  App.Security.DemandPermission(SECURITY_PERMISSION_REPORT_EXECUTE, launchData.ReportURI);

  with Sender.Activities[VIEW_REPORT_LAUNCHER] do
  begin
    Params[TViewActivityParams.PresenterID] := Activity.URI + Sender.ID;
    Params[TReportActivityParams.ReportURI] := Activity.URI;
    Params[TReportActivityParams.ImmediateRun] :=
      Activity.Params[TReportActivityParams.ImmediateRun];

    for I := 0 to  Activity.Params.Count - 1 do
      Params['Init.' + Activity.Params.ValueName(I)] :=
        Activity.Params[Activity.Params.ValueName(I)];

    {action.ResetData;
    launcherData := action.Data as TReportLauncherActivityData;
    launcherData.PresenterID := launchData.ReportURI + Sender.Caller.ID;
    launcherData.ReportURI := launchData.ReportURI;
    launcherData.ImmediateRun := launchData.ImmediateRun;
    launcherData.AssignLaunchData(launchData);
     }
    Execute(Sender);
  end;
end;

end.
