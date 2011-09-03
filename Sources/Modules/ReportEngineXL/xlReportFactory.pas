unit xlReportFactory;

interface
uses classes,  ReportServiceIntf, EntityServiceIntf, CoreClasses,
  xlReportClasses, db, sysutils, Variants;

type
  TXLReportLauncher = class(TComponent, IReportLauncher)
  private
    FTemplate: string;
    FReport: TpfwXLReport;
    FCallerWI: TWorkItem;
    FGetParamValueCallback: TReportGetParamValueCallback;
    FProgressCallback: TReportProgressCallback;
    procedure DoReportGetValue(const VarName: String; var Value: Variant);
    procedure DoReportProgress;
    function GetReportFileName: string;
  protected
    //IReport
    procedure Execute(Caller: TWorkItem; ExecuteAction: TReportExecuteAction;
      GetParamValueCallback: TReportGetParamValueCallback;
      ProgressCallback: TReportProgressCallback; const ATitle: string);

    procedure Design(Caller: TWorkItem);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetConnection(AConnection: IEntityStorageConnection);
    property Template: string read FTemplate write FTemplate;
  end;

  TXLReportFactory = class(TComponent, IReportLauncherFactory)
  private
    FLauncher: TXLReportLauncher;
  protected
    //IReportFactory
    function GetLauncher(AConnection: IEntityStorageConnection; const ATemplate: string): IReportLauncher;

  end;

implementation

{ TXLReportFactory }

function TXLReportFactory.GetLauncher(AConnection: IEntityStorageConnection;
  const ATemplate: string): IReportLauncher;
begin
  Result := nil;
  if ExtractFileExt(ATemplate) = '.xrt' then
  begin
  //  Result := TXLReportLauncher.Create(Self);
    if not Assigned(FLauncher) then
      FLauncher := TXLReportLauncher.Create(Self);

    FLauncher.Template := ATemplate;
    FLauncher.SetConnection(AConnection);
    FLauncher.GetInterface(IReportLauncher, Result);
  end;
end;

{ TXLReportLauncher }

constructor TXLReportLauncher.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReport := TpfwXLReport.Create(Self);
  FReport.OnGetValue := DoReportGetValue;
  FReport.OnProgress := DoReportProgress;
end;

procedure TXLReportLauncher.Design(Caller: TWorkItem);
begin

end;

procedure TXLReportLauncher.Execute(Caller: TWorkItem;
  ExecuteAction: TReportExecuteAction; GetParamValueCallback: TReportGetParamValueCallback;
  ProgressCallback: TReportProgressCallback;
   const ATitle: string);
begin
  FCallerWI := Caller;
  FGetParamValueCallback := GetParamValueCallback;
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

procedure TXLReportLauncher.DoReportGetValue(const VarName: String;
  var Value: Variant);
begin
  if Assigned(FGetParamValueCallback) then
    FGetParamValueCallback(VarName, Value);

  if VarIsEmpty(Value) and Assigned(FCallerWI) then
    Value := FCallerWI.State[VarName];
end;

procedure TXLReportLauncher.SetConnection(AConnection: IEntityStorageConnection);
begin
  FReport.Connection := AConnection;
end;

procedure TXLReportLauncher.DoReportProgress;
begin
  if Assigned(FProgressCallback) then
    FProgressCallback(rpsProcess);
end;

end.
