unit xlReportFactory;

interface
uses classes,  ReportCatalogConst, EntityServiceIntf, CoreClasses,
  xlReportClasses, db, sysutils, Variants, Generics.Collections;

type
  TXLReportLauncher = class(TComponent, IReportLauncher)
  private
    FTemplate: string;
    FReport: TpfwXLReport;
    FCallerWI: TWorkItem;
    FParams: TDictionary<string, variant>;
    FProgressCallback: TReportProgressCallback;
    procedure DoReportGetValue(const VarName: String; var Value: Variant);
    procedure DoReportProgress;
    function GetReportFileName: string;
  protected
    //IReport
    function Params: TDictionary<string, variant>;
    procedure Execute(Caller: TWorkItem; ALaunchMode: TReportLaunchMode;
      const ATitle: string; ProgressCallback: TReportProgressCallback);

    procedure Design(Caller: TWorkItem);
  public
    constructor Create(AOwner: TComponent; AConnection: IEntityStorageConnection); reintroduce;
    destructor Destroy; override;
    property Template: string read FTemplate write FTemplate;
  end;

  TXLReportFactory = class(TComponent, IReportLauncherFactory)
  private
    FLauncher: TXLReportLauncher;
  protected
    //IReportFactory
    function GetLauncher(AWorkItem: TWorkItem; const ATemplate: string): IReportLauncher;

  end;

implementation

{ TXLReportFactory }

function TXLReportFactory.GetLauncher(AWorkItem: TWorkItem;
  const ATemplate: string): IReportLauncher;
begin
  Result := nil;
  if ExtractFileExt(ATemplate) = '.xrt' then
  begin
    if not Assigned(FLauncher) then
    begin
      FLauncher := TXLReportLauncher.Create(Self,
        (AWorkItem.Services[IEntityService] as IEntityService).Connections.GetDefault);
    end;

    FLauncher.Template := ATemplate;
    FLauncher.GetInterface(IReportLauncher, Result);
  end;
end;

{ TXLReportLauncher }

constructor TXLReportLauncher.Create(AOwner: TComponent;
  AConnection: IEntityStorageConnection);
begin
  inherited Create(AOwner);
  FReport := TpfwXLReport.Create(Self);
  FReport.OnGetValue := DoReportGetValue;
  FReport.OnProgress := DoReportProgress;
  FReport.Connection := AConnection;
  FParams := TDictionary<string, variant>.Create;
end;

procedure TXLReportLauncher.Design(Caller: TWorkItem);
begin

end;

destructor TXLReportLauncher.Destroy;
begin
  FParams.Free;
  inherited;
end;

procedure TXLReportLauncher.Execute(Caller: TWorkItem; ALaunchMode: TReportLaunchMode;
  const ATitle: string; ProgressCallback: TReportProgressCallback);
begin
  FCallerWI := Caller;
  FProgressCallback := ProgressCallback;
  if Assigned(FProgressCallback) then
    FProgressCallback(rpsStart);
  try
    FReport.Execute(GetReportFileName);
  finally
    if Assigned(FProgressCallback) then
      FProgressCallback(rpsFinish);
  end;
end;

function TXLReportLauncher.GetReportFileName: string;
begin
  Result := FTemplate;
end;

function TXLReportLauncher.Params: TDictionary<string, variant>;
begin
  Result := FParams;
end;

procedure TXLReportLauncher.DoReportGetValue(const VarName: String;
  var Value: Variant);
var
  val: variant;
begin
  if VarIsEmpty(Value) and FParams.TryGetValue(UpperCase(VarName), val) then
    Value := val;
end;

procedure TXLReportLauncher.DoReportProgress;
begin
  if Assigned(FProgressCallback) then
    FProgressCallback(rpsProcess);
end;

end.
