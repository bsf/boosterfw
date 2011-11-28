unit ReportCatalogConst;

interface
uses CoreClasses, ReportCatalogClasses, ShellIntf, EntityServiceIntf, classes,
  generics.collections;

const
// VIEWS
  VIEW_RPT_CATALOG = 'view.reports.catalog';
  VIEW_RPT_CATALOG_CAPTION = 'Диспетчер отчетов';

  VIEW_REPORT_ITEM_SETUP = 'views.reports.item.setup';

type
  TReportProgressState = (rpsStart, rpsProcess, rpsFinish);
  TReportProgressCallback = procedure(AProgressState: TReportProgressState) of object;

  TReportLaunchMode = (lmParamView, lmPreview, lmPrint, lmHold);

  IReportLauncher = interface
  ['{E71B53B6-B7C4-41A1-8DF1-82F90CBBD770}']

    function Params: TDictionary<string, variant>;

    procedure Execute(Caller: TWorkItem; ALaunchMode: TReportLaunchMode;
      const ATitle: string;
      ProgressCallback: TReportProgressCallback);

    procedure Design(Caller: TWorkItem);
  end;

  IReportLauncherFactory = interface
  ['{941C6B81-D49B-487B-9C81-DF7B00B83A2E}']
    function GetLauncher(AWorkItem: TWorkItem; const ATemplate: string): IReportLauncher;
  end;

  IReportCatalogService = interface
  ['{884839BB-855A-4622-9110-6B7E9EC725FA}']
    function GetItem(const URI: string): TReportCatalogItem;
    procedure RegisterLauncherFactory(Factory: TComponent);

    procedure LaunchReport(Caller: TWorkItem;
      const AURI, ALayout: string; ALaunchMode: TReportLaunchMode);

  end;


  TReportActivityParams = record
  const
    LaunchMode = 'LaunchMode'; {0 - show param view; 1 - immediate preview; 2 - immediate print; 3 - hold}
  end;

  TReportLaunchParams = record
  const
    InitLayout = 'InitLayout';
    LaunchMode = 'LaunchMode';
    ReportURI = 'ReportURI';
  end;


implementation

end.
