unit ReportCatalogConst;

interface
uses CoreClasses, ReportCatalogClasses, ShellIntf;

const
  ACT_CTG_REPORTS = 'Îעקועû';

// Actions
  ACTION_RPT_CATALOG = 'actions.reports.catalog';

//Entities
  ENT_RPT_SETUP = 'RPT_Setup';

// VIEWS
  VIEW_RPT_CATALOG = 'view.reports.catalog';
  VIEW_RPT_CATALOG_CAPTION = 'Äטסןועקונ מעקועמג';

  VIEW_REPORT_LAUNCHER = 'views.reports.launcher';
  VIEW_RPT_ITEM_SETUP = 'views.reports.item.setup';

type
  IReportCatalogService = interface
  ['{2762CB82-3152-4657-8D9A-30C9A75E6B6B}']
    function GetItem(const URI: string): TReportCatalogItem;
  end;

  TReportLaunchData = class(TActionData)
  private
    FImmediateRun: variant;
    FReportURI: string;
  public
    constructor Create(const ActionURI: string); override;
  published
    property ImmediateRun: variant read FImmediateRun write FImmediateRun;
    property ReportURI: string read FReportURI;
  end;

implementation

{ TReportLaunchData }

constructor TReportLaunchData.Create(const ActionURI: string);
var
  rItem: TReportCatalogItem;
  I: integer;
begin
  inherited;
  FReportURI := ActionURI;
  rItem := (App.WorkItem.Services[IReportCatalogService] as IReportCatalogService).
    GetItem(FReportURI);
  for I := 0 to rItem.Manifest.ParamNodes.Count - 1 do
    Add(rItem.Manifest.ParamNodes[I].Name);
end;

end.
