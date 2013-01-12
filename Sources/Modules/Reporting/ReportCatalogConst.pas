unit ReportCatalogConst;

interface
uses CoreClasses, ReportCatalogClasses, ShellIntf, EntityServiceIntf, classes,
  generics.collections;

resourcestring

  COMMAND_PRINT_DEF_CAPTION = 'Quick Print';
  COMMAND_PRINT_CAPTION = 'Print...';
  COMMAND_ZOOM_CAPTION = 'Zoom';

  COMMAND_EXPORT_DEF_CAPTION = 'Export';
  COMMAND_EXPORT_EXCEL_CAPTION = 'Document Excel';
  COMMAND_EXPORT_PDF_CAPTION = 'Document Pdf';
  COMMAND_EXPORT_HTML_CAPTION = 'Document HTML';
  COMMAND_EXPORT_RTF_CAPTION = 'Document RTF';
  COMMAND_EXPORT_CSV_CAPTION = 'CSV File';

  strZoomPageWidth = 'Page Width';
  strZoomWholePage = 'Whole Page';

  strPagesLabelFmt = '%s from %s';


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


procedure Localization(const ALocale: string);

implementation

procedure Localization_ru;
begin
  SetLocaleString(@COMMAND_PRINT_DEF_CAPTION, 'Быстрая печать');
  SetLocaleString(@COMMAND_PRINT_CAPTION, 'Печать...');
  SetLocaleString(@COMMAND_ZOOM_CAPTION, 'Маштаб');

  SetLocaleString(@COMMAND_EXPORT_DEF_CAPTION, 'Экспорт');
  SetLocaleString(@COMMAND_EXPORT_EXCEL_CAPTION, 'Документ Excel');
  SetLocaleString(@COMMAND_EXPORT_RTF_CAPTION, 'Документ RTF');
  SetLocaleString(@COMMAND_EXPORT_PDF_CAPTION, 'Документ Pdf');
  SetLocaleString(@COMMAND_EXPORT_HTML_CAPTION, 'Документ HTML');
  SetLocaleString(@COMMAND_EXPORT_CSV_CAPTION, 'CSV файл');

  SetLocaleString(@strZoomPageWidth, 'По ширине');
  SetLocaleString(@strZoomWholePage, 'Страница целиком');
  SetLocaleString(@strPagesLabelFmt, '%s из %s');
end;

procedure Localization(const ALocale: string);
begin
  if ALocale = 'ru-RU' then
    Localization_ru;

end;

end.
