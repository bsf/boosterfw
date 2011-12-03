unit xlReportClasses;

interface
uses classes, xlReport, sysutils, db, xlReportMetadata, 
  Contnrs, xlcClasses, Variants, xlProOPack, Excel8G2, EntityServiceIntf,
  ShellIntf;

type
  TGetValueEvent = procedure(const VarName: String; var Value: Variant) of object;
  TpfwXLReportProgressEvent = procedure of object;

  TpfwXLDataSourceNode = class(TComponent)
  private
    FxlDataSource: TxlDataSource;
    FOnGetValue: TGetValueEvent;
    FData: IDataSetProxy;
    FCrossData: IDataSetProxy;
    FCrossColumns: IDataSetProxy;
    FIsCross: boolean;
    FShowCrossEmptyRow: boolean;
    FCrossDataCommand: string;
    FCrossColumnsCommand: string;
    FCrossColumnsDataFieldName: string;
    FCrossDataRowKeyField: string;
    FCrossDataColKeyField: string;
    FCrossColumnsKeyField: string;
    FKeyField: string;
    FCommand: string;
    function CreateDataSet(const ACommandText: string): IDataSetProxy;
    procedure BeforeDataTransfer(DataSource: TxlDataSource);
    procedure GetDataSourceInfo(DataSource: TxlDataSource; var FieldCount: Integer);
    procedure GetFieldInfo(DataSource: TxlDataSource; const FieldIndex: Integer;
      var FieldName: String; var FieldType: TxlDataType);
    procedure GetRecord(DataSource: TxlDataSource; const RecNo: Integer;
      var Values: OleVariant; var Eof: Boolean);

    procedure CheckPropertyValid;
    function DBTypeToXLDataType(ADBType: TFieldType): TxlDataType;
    function GetCrossDataFieldType(const ACrossDataFieldName: string): TxlDataType;
  public
    constructor Create(AxlDataSource: TxlDataSource;
      AMetadata: TpfwXLReportDataSourceMetadata); reintroduce;
    destructor Destroy; override;
    procedure Open;
    procedure Close;

    property OnGetValue: TGetValueEvent read FOnGetValue write FOnGetValue;
  end;

  TpfwXLReport = class(TComponent)
  private
    FMetadata: TpfwXLReportMetadata;
    FReport: TxlReport;
    FReportProPack: TxlProPackage;
    FDataSourceNodes: TComponentList;
    FOnGetValue: TGetValueEvent;
    FOnProgress: TpfwXLReportProgressEvent;
    FConnection: IEntityStorageConnection;
    procedure LoadMetadata(const AFileName: string);
    procedure InitReportParams;
    procedure DoGetValue(const VarName: string; var Value: Variant);
    procedure DoReportProgress(Report: TxlReport; const Position, Max: Integer);
    procedure AddSysParams;
    procedure OpenData;
    procedure CloseData;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Execute(const AFileName: string);
    property Connection: IEntityStorageConnection read FConnection write FConnection;
    property OnGetValue: TGetValueEvent read FOnGetValue write FOnGetValue;
    property OnProgress: TpfwXLReportProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

{ TpfwXLReport }

procedure TpfwXLReport.LoadMetadata(const AFileName: string);
var
  I: integer;
  ds: TxlDataSource;
  prm: TxlReportParam;
  dsNode: TpfwXLDataSourceNode;
begin
  FMetadata.LoadFromFile(AFileName);

  {Clear}
  FDataSourceNodes.Clear;
  FReport.DataSources.Clear;
  FReport.Params.Clear;

  {Common params}
  FReport.ActiveSheet := FMetadata.ActiveSheet;
  FReport.MacroBefore := FMetadata.MacroBefore;
  FReport.MacroAfter := FMetadata.MacroAfter;

  FReport.XLSTemplate := FMetadata.XLSTemplate;
  if ExtractFilePath(FReport.XLSTemplate) = '' then
    FReport.XLSTemplate := ExtractFilePath(AFileName) + FReport.XLSTemplate;

  {DataSources}
  for I := 0 to FMetadata.DataSources.Count - 1 do
  begin
    ds := FReport.DataSources.Add;
    ds.Alias := FMetadata.DataSources[I].DataSourceName;
    ds.Options := [xrgoPreserveRowHeight];
    ds.Range := FMetadata.DataSources[I].Range;
    ds.MacroBefore := FMetadata.DataSources[I].MacroBefore;
    ds.MacroAfter := FMetadata.DataSources[I].MacroAfter;
    ds.MasterSourceName := FMetadata.DataSources[I].MasterSource;
    dsNode := TpfwXLDataSourceNode.Create(ds, FMetadata.DataSources[I]);
    FDataSourceNodes.Add(dsNode);
    dsNode.OnGetValue := DoGetValue;
  end;

  {Params}
  for I := 0 to FMetadata.Params.Count - 1 do
  begin
    prm := FReport.Params.Add;
    prm.Name := FMetadata.Params.Items[I].ParamName;
  end;

end;

constructor TpfwXLReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReport := TxlReport.Create(Self);
  FReport.OnProgress := DoReportProgress;
  FReportProPack := TxlProPackage.Create(Self);
  FMetadata := TpfwXLReportMetadata.Create(Self);
  FDataSourceNodes := TComponentList.Create(True);

  //
  FReport.Options := FReport.Options + [xroNewInstance];
end;

destructor TpfwXLReport.Destroy;
begin
  FDataSourceNodes.Free;
  inherited;
end;

procedure TpfwXLReport.Execute(const AFileName: string);
begin
  LoadMetadata(AFileName);
  AddSysParams;
  InitReportParams;
  try
    OpenData;
    FReport.Report;
  finally
    CloseData;
  end;
end;

procedure TpfwXLReport.InitReportParams;
var
  I: integer;
  Val: Variant;
begin
  for I := 0 to FReport.Params.Count - 1 do
  begin
    Val := FReport.Params[I].Value;
    DoGetValue(FReport.Params[I].Name, Val);
    FReport.Params[I].Value := Val;
  end;
end;


procedure TpfwXLReport.DoGetValue(const VarName: string;
  var Value: Variant);
begin
  if Assigned(FOnGetValue) then
    FOnGetValue(VarName, Value);
end;

procedure TpfwXLReport.AddSysParams;
begin

end;


procedure TpfwXLReport.CloseData;
var
  I: integer;
begin
  for I := 0 to FDataSourceNodes.Count - 1 do
    TpfwXLDataSourceNode(FDataSourceNodes[I]).Close;
end;

procedure TpfwXLReport.OpenData;
var
  I: integer;
begin
  for I := 0 to FDataSourceNodes.Count - 1 do
    TpfwXLDataSourceNode(FDataSourceNodes[I]).Open;
end;

procedure TpfwXLReport.DoReportProgress(Report: TxlReport; const Position,
  Max: Integer);
begin
  if Assigned(FOnProgress) then
    FOnProgress;
end;

{ TpfwXLDataSourceNode }

procedure TpfwXLDataSourceNode.BeforeDataTransfer(
  DataSource: TxlDataSource);
begin
  //
//  DataSource.i  Insert(xlShiftToRight);
end;

procedure TpfwXLDataSourceNode.CheckPropertyValid;
begin
  if FCommand = '' then
    raise Exception.Create('Command is empty in DataSource:' +
      FxlDataSource.Alias);

  if FIsCross then
  begin
    if FKeyField = '' then
      raise Exception.Create('KeyField not specified in DataSource:' +
        FxlDataSource.Alias);

    if FCrossColumnsKeyField = '' then
      raise Exception.Create('ColumnKeyField not specified in DataSource:' +
        FxlDataSource.Alias);

    if FCrossColumnsDataFieldName = '' then
      raise Exception.Create('ColumnDataFieldName not specified in DataSource:' +
        FxlDataSource.Alias);

    if FCrossDataRowKeyField = '' then
      raise Exception.Create('RowKeyField not specified in DataSource:' +
        FxlDataSource.Alias);

    if FCrossDataColKeyField = '' then
      raise Exception.Create('ColKeyField not specified in DataSource:' +
        FxlDataSource.Alias);

    if FCrossDataCommand = '' then
      raise Exception.Create('CrossData command is empty in DataSource:' +
        FxlDataSource.Alias);

    if FCrossColumnsCommand = '' then
      raise Exception.Create('CrossColumns command is empty in DataSource:' +
        FxlDataSource.Alias);
  end;
end;

procedure TpfwXLDataSourceNode.Close;
begin
  if Assigned(FData) then FData.DataSet.Close;

  if Assigned(FCrossColumns) then FCrossData.DataSet.Close;

  if Assigned(FCrossData) then FCrossData.DataSet.Close;
end;

constructor TpfwXLDataSourceNode.Create(AxlDataSource: TxlDataSource;
  AMetadata: TpfwXLReportDataSourceMetadata);
begin
  inherited Create(nil);
  FxlDataSource := AxlDataSource;

  FCommand := AMetadata.CommandText.Text;
  FIsCross := AMetadata.IsCross;
  FKeyField := AMetadata.KeyField;
  FShowCrossEmptyRow := AMetadata.ShowCrossEmptyRow;

  FCrossDataRowKeyField := AMetadata.CrossDataRowKeyField;
  FCrossDataColKeyField := AMetadata.CrossDataColKeyField;
  FCrossDataCommand := AMetadata.CrossDataCommandText.Text;

  FCrossColumnsKeyField := AMetadata.CrossColumnsKeyField;
  FCrossColumnsDataFieldName := AMetadata.CrossColumnsDataFieldName;
  FCrossColumnsCommand := AMetadata.CrossColumnsCommandText.Text;

end;

function TpfwXLDataSourceNode.CreateDataSet(
  const ACommandText: string): IDataSetProxy;
begin
  Result := App.Entities.GetDataSetProxy(Self);
  Result.CommandText := ACommandText;
//  Result := FCreateDataSetFunc(Self, ACommandText);
end;

function TpfwXLDataSourceNode.DBTypeToXLDataType(
  ADBType: TFieldType): TxlDataType;
begin
  case ADBType of
    ftGuid, ftFixedChar, ftWideString, ftString: Result := xdString;
    ftLargeint, ftAutoInc, ftSmallint, ftInteger, ftWord: Result := xdInteger;
    ftBoolean: Result := xdBoolean;
    ftFloat, ftCurrency: Result := xdFloat;
    ftDate, ftTime, ftDateTime, ftTimeStamp: Result := xdDateTime;
    else Result := xdNotSupported;
  end;
end;

destructor TpfwXLDataSourceNode.Destroy;
begin
  FData := nil;
  FCrossData := nil;
  FCrossColumns := nil;
  inherited;
end;

function TpfwXLDataSourceNode.GetCrossDataFieldType(
  const ACrossDataFieldName: string): TxlDataType;
var
  CrossDataFieldName: string;
  CrossDataField: TField;
begin
  CrossDataField := FCrossData.DataSet.FindField(ACrossDataFieldName);
  if not Assigned(CrossDataField) then
    raise Exception.Create('CrossDataField: ' + CrossDataFieldName + ' not found');

  Result := DBTypeToXLDataType(CrossDataField.DataType);
end;

procedure TpfwXLDataSourceNode.GetDataSourceInfo(DataSource: TxlDataSource;
  var FieldCount: Integer);
begin
  FieldCount := FData.DataSet.FieldCount;

 {Need for fetch all records because RecordCount don't work correctly}
  FCrossColumns.DataSet.First;
  while not FCrossColumns.DataSet.Eof do
  begin
    Inc(FieldCount);
    FCrossColumns.DataSet.Next;
  end;

end;

procedure TpfwXLDataSourceNode.GetFieldInfo(DataSource: TxlDataSource;
  const FieldIndex: Integer; var FieldName: String; var FieldType: TxlDataType);
var
  CrossColumnIndex: integer;
  Idx: integer;
begin
  //MasterData
  if FieldIndex <= (FData.DataSet.FieldCount - 1) then
  begin
    FieldName := FData.DataSet.Fields[FieldIndex].FieldName;
    FieldType := DBTypeToXLDataType(FData.DataSet.Fields[FieldIndex].DataType);
  end
  //CrossData
  else
  begin
    CrossColumnIndex := FieldIndex - FData.DataSet.FieldCount + 1;
   // FieldName := 'Col' + IntToStr(CrossColumnIndex);

    FCrossColumns.DataSet.First;
    Idx := 1;
    while Idx < CrossColumnIndex do
    begin
      Inc(Idx);
      FCrossColumns.DataSet.Next;
    end;

    FieldName := 'Col' + VarToStr(FCrossColumns.DataSet[FCrossColumnsKeyField]);

    FieldType := GetCrossDataFieldType(
      FCrossColumns.DataSet[FCrossColumnsDataFieldName]);

  end

end;

procedure TpfwXLDataSourceNode.GetRecord(DataSource: TxlDataSource;
  const RecNo: Integer; var Values: OleVariant; var Eof: Boolean);

  procedure GetRowData;
  var
    I: integer;
  begin
    for I := 0 to FData.DataSet.FieldCount - 1 do
    begin
      case DBTypeToXLDataType(FData.DataSet.Fields[I].DataType) of
        xdInteger: Values[I] := FData.DataSet.Fields[I].AsInteger;
        xdBoolean: Values[I] := FData.DataSet.Fields[I].AsBoolean;
        xdFloat: Values[I] := FData.DataSet.Fields[I].AsFloat;
        xdDateTime: Values[I] := FData.DataSet.Fields[I].AsDateTime;
        xdString: Values[I] := FData.DataSet.Fields[I].AsString;
        else Values[I] := Unassigned;
      end
    end;
  end;

  procedure GetCrossData;
  var
    I: integer;
    CrossDataFieldType: TxlDataType;
    CrossDataFieldName: string;
    RowEof: boolean;
  begin
    FCrossColumns.DataSet.First;
    I := FData.DataSet.FieldCount;
    RowEof := false;
    while (not FCrossColumns.DataSet.Eof) and (not RowEof) do
    begin
      if FCrossData.DataSet[FCrossDataColKeyField] =
         FCrossColumns.DataSet[FCrossColumnsKeyField] then
      begin
        CrossDataFieldName := FCrossColumns.DataSet[FCrossColumnsDataFieldName];
        CrossDataFieldType := GetCrossDataFieldType(CrossDataFieldName);

      {if FCrossData.DataSet.Locate(FCrossDataRowKeyField + ';' + FCrossDataColKeyField,
          VarArrayOf([FData.DataSet.FieldValues[FKeyField],
                      FCrossColumns.DataSet.FieldValues[FCrossColumnsKeyField]]), []) then}
        case CrossDataFieldType of
          xdInteger: Values[I] := FCrossData.DataSet.FieldByName(CrossDataFieldName).AsInteger;
          xdBoolean: Values[I] := FCrossData.DataSet.FieldByName(CrossDataFieldName).AsBoolean;
          xdFloat: Values[I] := FCrossData.DataSet.FieldByName(CrossDataFieldName).AsFloat;
          xdDateTime: Values[I] := FCrossData.DataSet.FieldByName(CrossDataFieldName).AsDateTime;
          xdString: Values[I] := FCrossData.DataSet.FieldByName(CrossDataFieldName).AsString;
        end;
        FCrossData.DataSet.Next;
      end;
      Inc(I);
      FCrossColumns.DataSet.Next;
      RowEof := (FCrossData.DataSet[FCrossDataRowKeyField] <> FData.DataSet[FKeyField])
                  or FCrossData.DataSet.Eof;
    end;
  end;

  procedure GetRow;
  begin
    GetRowData;
    GetCrossData;
  end;

var
  IsCrossDataPresent: boolean;
  IsRowPresent: boolean;
begin
  Eof := FData.DataSet.Eof;
  if Eof then Exit;

  repeat
    IsCrossDataPresent := FCrossData.DataSet.Locate(FCrossDataRowKeyField,
      FData.DataSet.FieldValues[FKeyField], []);

    IsRowPresent := FShowCrossEmptyRow or IsCrossDataPresent;

    GetRowData;
    if IsCrossDataPresent then
        GetCrossData;

    FData.DataSet.Next;

  until IsRowPresent or FData.DataSet.Eof;

end;

procedure TpfwXLDataSourceNode.Open;

  procedure InitDataSetParams(AParams: TParams);
  var
    I: integer;
    prmName: string;
    prmVal: Variant;
  begin
    for I := 0 to AParams.Count - 1 do
    begin
      prmName := AParams[I].Name;
      prmVal := AParams.ParamValues[prmName];
      FOnGetValue(prmName, prmVal);
      AParams.ParamValues[prmName] := prmVal;
    end;

  end;

begin
  CheckPropertyValid;

  {Create}
  FData := CreateDataSet(FCommand);

  if FIsCross then
  begin

    FCrossData := CreateDataSet(FCrossDataCommand);
    FCrossColumns := CreateDataSet(FCrossColumnsCommand);

    FxlDataSource.OnGetDataSourceInfo := GetDataSourceInfo;
    FxlDataSource.OnGetFieldInfo := GetFieldInfo;
    FxlDataSource.OnGetRecord := GetRecord;
    FxlDataSource.OnBeforeDataTransfer := BeforeDataTransfer;

    FxlDataSource.Options := FxlDataSource.Options + [xrgoAutoOpen, xrgoAutoClose]; //!!!должно быть
  end
  else
    FxlDataSource.DataSet := FData.DataSet;

  {Open}
  InitDataSetParams(FData.Params);
  FData.DataSet.Open;

  if FIsCross then
  begin
    InitDataSetParams(FCrossColumns.Params);
    FCrossColumns.DataSet.Open;

    InitDataSetParams(FCrossData.Params);
    FCrossData.DataSet.Open;
  end;

end;

initialization


end.
