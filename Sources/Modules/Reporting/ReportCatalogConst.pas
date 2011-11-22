unit ReportCatalogConst;

interface
uses CoreClasses, ReportCatalogClasses, ShellIntf, EntityServiceIntf, classes;

const


// Actions
  ACTION_RPT_CATALOG = 'actions.reports.catalog';

//Entities
  ENT_RPT_SETUP = 'RPT_Setup';

// VIEWS
  VIEW_RPT_CATALOG = 'view.reports.catalog';
  VIEW_RPT_CATALOG_CAPTION = 'Диспетчер отчетов';

  VIEW_REPORT_LAUNCHER = 'views.reports.launcher';
  VIEW_RPT_ITEM_SETUP = 'views.reports.item.setup';

  ACT_REPORT_PREVIEW = 'reports.preview';

type
  TReportProgressState = (rpsStart, rpsProcess, rpsFinish);
  TReportProgressCallback = procedure(AProgressState: TReportProgressState) of object;

  TReportGetParamValueCallback = procedure(const AName: string; var AValue: Variant) of object;

  TReportExecuteAction = (reaPrepareFirst, reaPrepareNext, reaExecutePrepared, reaExecute);

  IReportLauncher = interface
  ['{E71B53B6-B7C4-41A1-8DF1-82F90CBBD770}']
    procedure Execute(Caller: TWorkItem; ExecuteAction: TReportExecuteAction;
      GetParamValueCallback: TReportGetParamValueCallback;
      ProgressCallback: TReportProgressCallback; const ATitle: string);

    procedure Design(Caller: TWorkItem);
  end;
  IReportLauncherFactory = interface
  ['{941C6B81-D49B-487B-9C81-DF7B00B83A2E}']
    function GetLauncher(AConnection: IEntityStorageConnection;
      const ATemplate: string): IReportLauncher;
  end;

  IReportCatalogService = interface
  ['{884839BB-855A-4622-9110-6B7E9EC725FA}']
    function GetItem(const URI: string): TReportCatalogItem;
    procedure RegisterLauncherFactory(Factory: TComponent);

    procedure Execute(Caller: TWorkItem; Activity: IActivity);
  end;

  TReportLaunchParams = record
    const
      ImmediateRun = 'ImmediateRun';
      ReportURI = 'ReportURI';
  end;

  TReportPreviewParams = record
    const
      ReportURI = 'ReportURI';
      ExecuteAction = 'ExecuteAction';
  end;

implementation

end.
