unit frReportFactory;

interface
uses windows, classes, CoreClasses, ReportServiceIntf, EntityServiceIntf,
  SysUtils, db, ibdatabase, CustomUIController, ComObj, controls,
  frxClass, frxExportXML, frxExportXLS, frxExportCSV, frxIBXComponents, frxDesgn,
  frxChBox, frxCross, frxBarCode, frxDCtrl, variants, frReportPreviewPresenter;

const
  VIEW_FASTREPORT_PREVIEW = 'views.reports.fastreport.preview';

type

  TFastReportLauncher = class(TComponent, IReportLauncher)
  private
    FWorkItem: TWorkItem;
    FIBXComponents: TfrxIBXComponents;
    FReport: TfrxReport;
    FXLSExportFilter: TfrxXLSExport;
    FCSVExportFilter: TfrxCSVExport;
    FCallerWI: TWorkItem;
    FGetParamValueCallback: TReportGetParamValueCallback;
    FProgressCallback: TReportProgressCallback;
    FTemplate: string;
    function GetReportFileName: string;
    procedure OnAfterPrintReport(Sender: TObject);
    procedure OnReportGetValue(const VarName: String; var Value: Variant);
    procedure OnBeforePrintReport(Sender: TfrxReportComponent);
    procedure EndHandler(Sender: TObject);
    procedure DoReportProgressStart(Sender: TfrxReport;
      ProgressType: TfrxProgressType; Progress: Integer);
    procedure DoReportProgress(Sender: TfrxReport;
      ProgressType: TfrxProgressType; Progress: Integer);
    procedure DoReportProgressStop(Sender: TfrxReport;
      ProgressType: TfrxProgressType; Progress: Integer);
    function IsControlKeyDown: boolean;
    procedure Preview(const ATitle: string);
  protected
    //IReportLauncher
    procedure Execute(Caller: TWorkItem; ExecuteAction: TReportExecuteAction;
      GetParamValueCallback: TReportGetParamValueCallback;
      ProgressCallback: TReportProgressCallback; const ATitle: string);
    procedure Design(Caller: TWorkItem);
  public
    constructor Create(AOwner: TComponent;
      AConnection: IEntityStorageConnection; AWorkItem: TWorkItem); reintroduce;
    property Template: string read FTemplate write FTemplate;
  end;

  TFastReportFactory = class(TCustomUIController, IReportLauncherFactory)
  private
    FWorkItem: TWorkItem;
    FLauncher: TFastReportLauncher;
  protected
    //IReportFactory
    function GetLauncher(AConnection: IEntityStorageConnection; const ATemplate: string): IReportLauncher;
  public
    constructor Create(AOwner: TWorkItem); override;
  end;


implementation

{ TFastReportFactory }

constructor TFastReportFactory.Create(AOwner: TWorkItem);
begin
  inherited;
  FWorkItem := AOwner;
  (WorkItem.Services[IReportService] as IReportService).RegisterLauncherFactory(Self);
end;

function TFastReportFactory.GetLauncher(AConnection: IEntityStorageConnection;
  const ATemplate: string): IReportLauncher;
begin
  Result := nil;
  if ExtractFileExt(ATemplate) = '.fr3' then
  begin
    if not Assigned(FLauncher) then
      FLauncher := TFastReportLauncher.Create(Self, AConnection, FWorkItem);

    FLauncher.Template := ATemplate;
    Result := FLauncher;
  end;
end;

{ TFastReportLauncher }

constructor TFastReportLauncher.Create(AOwner: TComponent;
  AConnection: IEntityStorageConnection; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FReport := TfrxReport.Create(Self);
  FReport.OnGetValue := OnReportGetValue;
  FReport.OnProgress := DoReportProgress;
  FReport.OnProgressStart := DoReportProgressStart;
  FReport.OnProgressStop := DoReportProgressStop;
  FReport.OnEndDoc := EndHandler;
  FReport.OnBeforePrint := OnBeforePrintReport;
//  FReport.OldStyleProgress := true;
  FReport.OnAfterPrintReport := OnAfterPrintReport;
  FIBXComponents := TfrxIBXComponents.Create(Self);
  FIBXComponents.DefaultDatabase := TIBDataBase(AConnection.GetStubConnectionComponent);
  FXLSExportFilter := TfrxXLSExport.Create(Self);
  FCSVExportFilter := TfrxCSVExport.Create(Self);
end;

procedure TFastReportLauncher.Design(Caller: TWorkItem);
begin
  FCallerWI := Caller;
  FReport.LoadFromFile(GetReportFileName);
  FReport.DesignReport();
end;

procedure TFastReportLauncher.DoReportProgress(Sender: TfrxReport;
  ProgressType: TfrxProgressType; Progress: Integer);
begin
  if Assigned(FProgressCallback) then
    FProgressCallback(rpsProcess);
end;

procedure TFastReportLauncher.DoReportProgressStart(Sender: TfrxReport;
  ProgressType: TfrxProgressType; Progress: Integer);
begin
  if Assigned(FProgressCallback) then
    FProgressCallback(rpsStart);
end;

procedure TFastReportLauncher.DoReportProgressStop(Sender: TfrxReport;
  ProgressType: TfrxProgressType; Progress: Integer);
begin
  if Assigned(FProgressCallback) then
    FProgressCallback(rpsFinish);
end;

procedure TFastReportLauncher.EndHandler(Sender: TObject);
begin
  if FIBXComponents.DefaultDatabase.DefaultTransaction.InTransaction then
    FIBXComponents.DefaultDatabase.DefaultTransaction.Commit;
end;

procedure TFastReportLauncher.Execute(Caller: TWorkItem;
  ExecuteAction: TReportExecuteAction; GetParamValueCallback: TReportGetParamValueCallback;
  ProgressCallback: TReportProgressCallback;
   const ATitle: string);
begin
  FCallerWI := Caller;
  FGetParamValueCallback := GetParamValueCallback;
  if IsControlKeyDown then
  begin
    Design(FCallerWI);
    Exit;
  end;

  FProgressCallback := ProgressCallback;
  try
    FReport.LoadFromFile(GetReportFileName);

    if FIBXComponents.DefaultDatabase.DefaultTransaction.InTransaction then
      FIBXComponents.DefaultDatabase.DefaultTransaction.Commit;

    try
      case ExecuteAction of
        reaPrepareFirst: FReport.PrepareReport(true);
        reaPrepareNext: FReport.PrepareReport(false);
        reaExecutePrepared: FReport.PrepareReport(false);
        else
          FReport.PrepareReport(true);
      end;
    finally
      if FIBXComponents.DefaultDatabase.DefaultTransaction.InTransaction then
        FIBXComponents.DefaultDatabase.DefaultTransaction.Commit;
    end;

    if ExecuteAction in [reaExecutePrepared,reaExecute] then
    begin
     // FReport.ShowPreparedReport;
      Preview(ATitle);
    end
  finally
    FProgressCallback := nil;
  end;
end;

function TFastReportLauncher.GetReportFileName: string;
begin
  Result := FTemplate;
end;

function TFastReportLauncher.IsControlKeyDown: boolean;
begin
  result:=(Word(GetKeyState(VK_CONTROL)) and $8000)<>0;
end;

procedure TFastReportLauncher.OnAfterPrintReport(Sender: TObject);
begin
  if Assigned(FReport.PreviewForm) then
    FReport.PreviewForm.Caption := 'Œ“◊≈“ Õ¿œ≈◊¿“¿Õ';
end;

procedure TFastReportLauncher.OnBeforePrintReport(Sender: TfrxReportComponent);
begin
  if (Sender is TfrxView) then
  begin
    if ((Sender as TfrxView).TagStr <> '') then
      (Sender as TfrxView).Cursor := crHandPoint
    else
      (Sender as TfrxView).Cursor := crDefault;
  end;
end;

procedure TFastReportLauncher.OnReportGetValue(const VarName: String;
  var Value: Variant);
begin
  if Assigned(FGetParamValueCallback) then
    FGetParamValueCallback(VarName, Value);

  if VarIsEmpty(Value) and Assigned(FCallerWI) then
    Value := FCallerWI.State[VarName];

end;


procedure TFastReportLauncher.Preview(const ATitle: string);
var
  actionData: TfrReportPreviewData;
  action: IAction;
begin
  action := FCallerWI.Actions[VIEW_FR_PREVIEW];
  actionData := action.Data as TfrReportPreviewData;
  actionData.PresenterID := CreateClassID;
  actionData.ViewTitle := ATitle;
  actionData.ClearReportStream;
  FReport.PreviewPages.SaveToStream(actionData.ReportStream);
  action.Execute(FCallerWI);
end;

end.
