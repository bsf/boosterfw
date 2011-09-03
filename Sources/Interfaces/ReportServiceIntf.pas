unit ReportServiceIntf;

interface
uses classes, EntityServiceIntf, CoreClasses;

const
  //Event Topics
  ET_REPORT_PROGRESS_START = '{CD281EB7-B0A8-42BF-8515-3F688CE3098B}';
  ET_REPORT_PROGRESS_FINISH = '{31A52925-AA3A-4E9C-9506-2FCFF9A38C61}';
  ET_REPORT_PROGRESS_PROCESS = '{49FB1109-C1B3-45B3-9040-276032FFBC01}';


const
  //SecurityClass
  SECURITY_PROVIDER_REPORTS = 'Security.Policiy.App.Reports';

  SECURITY_PERMISSION_REPORT_ENGINE_ACCESS = 'app.report.engine.access';
  SECURITY_PERMISSION_REPORT_EXECUTE = 'app.report.execute';
  SECURITY_PERMISSION_REPORT_SETUP = 'app.report.setup';

type


  TReportProgressState = (rpsStart, rpsProcess, rpsFinish);
  TReportProgressCallback = procedure(AProgressState: TReportProgressState) of object;

  TReportGetParamValueCallback = procedure(const AName: string; var AValue: Variant) of object;

  TReportExecuteAction = (reaPrepareFirst, reaPrepareNext, reaExecutePrepared, reaExecute);

  IReportLauncher = interface
  ['{2A4B2180-B151-49FF-BE8F-F3C47431AA1B}']
    procedure Execute(Caller: TWorkItem; ExecuteAction: TReportExecuteAction;
      GetParamValueCallback: TReportGetParamValueCallback;
      ProgressCallback: TReportProgressCallback; const ATitle: string);

    procedure Design(Caller: TWorkItem);
  end;

  IReport = interface
  ['{CE44AF96-5254-4E0C-8465-91E4FBC60C40}']
    function ReportName: string;

    function GetGroup: string;
    procedure SetGroup(const AValue: string);
    function GetCaption: string;
    procedure SetCaption(const AValue: string);
    function GetTemplate: string;
    procedure SetTemplate(const AValue: string);

    property Group: string read GetGroup write SetGroup;
    property Caption: string read GetCaption write SetCaption;
    property Template: string read GetTemplate write SetTemplate;

    procedure Execute(Caller: TWorkItem;
      ExecuteAction: TReportExecuteAction = reaExecute);
    procedure Design(Caller: TWorkItem);

    function GetParam(const AName: string): Variant;
    procedure SetParam(const AName: string; AValue: Variant);
    property Params[const AName: string]: Variant read GetParam write SetParam;

  end;

  IReportLauncherFactory = interface
  ['{B9A263D1-F6AA-4604-B98A-3FBA440614FE}']
    function GetLauncher(AConnection: IEntityStorageConnection;
      const ATemplate: string): IReportLauncher;
  end;

  IReportService = interface
  ['{85BB8667-3097-45AA-BB03-FCCC9A4889DC}']
    function Count: integer;
    function Add(const AName: string): IReport;
    procedure Remove(const AName: string);
    procedure Delete(AIndex: integer);
    procedure Clear;
    function Get(AIndex: integer): IReport;
    function GetReport(const AName: string): IReport;
    property Report[const AName: string]: IReport read GetReport; default;
    procedure RegisterLauncherFactory(Factory: TComponent);
    procedure UnRegisterLauncherFactory(Factory: TComponent);
  end;

implementation

end.
