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

  TReportActivityParams = record
    const
      ImmediateRun = 'ImmediateRun';
      ReportURI = 'ReportURI';
  end;


implementation

end.
