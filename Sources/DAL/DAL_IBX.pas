unit DAL_IBX;

interface
uses classes, EntityServiceIntf, IBDataBase, db, IBSql,
  IBCustomDataSet, provider, sysutils, Contnrs, IBQuery, IBUpdateSQL,
  DBClient, Variants, TConnect, StrUtils, IB;

type

  TIBQueryFix = class(TIBQuery)
  protected
    //Fix - не предусмотрена обработка нового типа ftShortint
    procedure PSSetParams(AParams: TParams); override;
    //Fix - при отрицательном коде ошибки ClientDataSet не нормально обрабатывает exception
    function PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError; override;
  end;

  TIBPlainSQLProvider = class(TDataSetProvider)
  private
    FQuery: TIBQueryFix;
    FTransaction: TIBTransaction;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetDatabase(Value: TIBDatabase);
  end;

  TDataSetProviderClass = class of TDataSetProvider;

  TIBEntityOperProvider = class(TDataSetProvider)
  private
    FQuery: TIBQueryFix;
    FTransaction: TIBTransaction;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetSQL(const Value: string);
  end;

  TIBEntityViewProvider = class(TDataSetProvider)
  private
    FQuery: TIBQueryFix;
    FQueryRefresh: TIBQueryFix;
    FQueryInsertDef: TIBQueryFix;
    FUpdateSql: TIBUpdateSql;
    FTransaction: TIBTransaction;
    FPrimaryKey: TStringList;
    function RequestReloadRecord(DSParams: OleVariant): OleVariant;
    function RequestInsertDef(DSParams: OleVariant): OleVariant;
  protected
    function DataRequestHandler(Sender: TObject; Input : OleVariant) : OleVariant;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetSelectSQL(const Value: string);
    procedure SetInsertSQL(const Value: string);
    procedure SetUpdateSQL(const Value: string);
    procedure SetDeleteSQL(const Value: string);
    procedure SetRefreshSQL(const Value: string);
    procedure SetInsertDefSQL(const Value: string);
    procedure SetPrimaryKey(const Value: string);
  end;

type
  TIBExecuteSQLCallback = procedure(AResultData: TIBXSQLDA) of object;

procedure IBExecuteSQL(ADataBase: TIBDatabase; const ASQL: string;
  AParams: array of variant; ResultCallback: TIBExecuteSQLCallback);

implementation


{type
  TExecuteSQLCallback = procedure(AResultData: TIBXSQLDA) of object;}

procedure IBExecuteSQL(ADataBase: TIBDatabase; const ASQL: string;
  AParams: array of variant; ResultCallback: TIBExecuteSQLCallback);
var
  qry: TIBSQL;
  I: integer;
begin
  qry:= TIBSQL.Create(nil);
  try
    qry.Database:= ADatabase;
    qry.Transaction:= TIBTransaction.Create(qry);
    qry.Transaction.DefaultDatabase := ADataBase;
    qry.GoToFirstRecordOnExecute := true;
    qry.Transaction.StartTransaction;
    try
      qry.SQL.Text:= ASQL;
      qry.Prepare;

      for I := 0 to High(AParams) do
        if qry.Params.Count > I then
          qry.Params[I].Value := AParams[I];

      qry.ExecQuery;
      while not qry.Eof do
      begin
        if @ResultCallback <> nil then
          ResultCallback(qry.Current);
        qry.Next;
      end;
      qry.Transaction.Commit;
    except
      qry.Transaction.Rollback;
    end;
  finally
    qry.Free;
  end;
end;

{ TIBQueryFix }

function TIBQueryFix.PSGetUpdateException(E: Exception;
  Prev: EUpdateError): EUpdateError;
var
  PrevErr: Integer;
begin
  if Prev <> nil then
    PrevErr := Prev.ErrorCode else
    PrevErr := 0;
  if E is EIBError then
    with EIBError(E) do
      Result := EUpdateError.Create(E.Message, '', {SQLCode}1, PrevErr, E) else
      Result := inherited PSGetUpdateException(E, Prev);

end;

procedure TIBQueryFix.PSSetParams(AParams: TParams);
var
  I: integer;
begin
  inherited PSSetParams(AParams);

//BEGIN
{FIX DELPHI XE BUG
IBQuery.pas
procedure TIBQuery.SetParams;
begin
..
  case Params[i].DataType of
    не определена ветка для ftShortint !!!

end;
}

   for I := 0 to Params.Count - 1 do
     if Params[I].DataType = ftShortInt then
          Params[I].DataType := ftSmallInt;
end;

{ TPlainSQLProvider }

constructor TIBPlainSQLProvider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;
  FQuery := TIBQueryFix.Create(Self);
  FQuery.Transaction := FTransaction;
  Self.DataSet := FQuery;
end;

procedure TIBPlainSQLProvider.SetDatabase(Value: TIBDatabase);
begin
  FQuery.Database := Value;
  FQuery.Transaction.DefaultDatabase := Value;
end;

{ TIBEntityOperProvider }

constructor TIBEntityOperProvider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;
  FQuery := TIBQueryFix.Create(Self);
  FQuery.Transaction := FTransaction;
  Self.DataSet := FQuery;
end;

procedure TIBEntityOperProvider.SetDatabase(Value: TIBDatabase);
begin
  FQuery.Database := Value;
  FQuery.Transaction.DefaultDatabase := Value;
end;

procedure TIBEntityOperProvider.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;

{ TIBEntityViewProvider }

constructor TIBEntityViewProvider.Create(AOwner: TComponent);
begin
  inherited;
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;
  FQuery := TIBQueryFix.Create(Self);
  FQuery.Transaction := FTransaction;
  FUpdateSql := TIBUpdateSql.Create(Self);
  FQuery.UpdateObject := FUpdateSql;
  Self.DataSet := FQuery;

  FQueryRefresh := TIBQueryFix.Create(Self);
  FQueryRefresh.Transaction := FTransaction;

  FQueryInsertDef := TIBQueryFix.Create(Self);
  FQueryInsertDef.Transaction := FTransaction;

  OnDataRequest := DataRequestHandler;

  FPrimaryKey := TStringList.Create;

end;

function TIBEntityViewProvider.DataRequestHandler(Sender: TObject;
  Input: OleVariant): OleVariant;
var
  requestKind: TEntityDataRequestKind;
begin
  requestKind := Input[0];
  case requestKind of
    erkReloadRecord:
      Result := RequestReloadRecord(Input[1]);
    erkInsertDefaults:
      Result := RequestInsertDef(Input[1]);
  else
    Result := Unassigned;
  end;

end;

destructor TIBEntityViewProvider.Destroy;
begin
  FPrimaryKey.Free;
  inherited;
end;

function TIBEntityViewProvider.RequestInsertDef(
  DSParams: OleVariant): OleVariant;
var
  prmDS: TParams;
begin
  Result := Unassigned;

  if FQueryInsertDef.SQL.Text = '' then Exit;

  prmDS := TParams.Create;
  try
    UnpackParams(DSParams, prmDS);

    FQueryInsertDef.Params.AssignValues(prmDS);
    try
      DataSet := FQueryInsertDef;
      FQueryInsertDef.Close;
      FQueryInsertDef.Open;
      Result := Data;
    finally
      DataSet := FQuery;
      FQueryInsertDef.Close;
    end;
  finally
    prmDS.Free;
  end;

end;

function TIBEntityViewProvider.RequestReloadRecord(
  DSParams: OleVariant): OleVariant;
var
  prmDS: TParams;
begin
  Result := Unassigned;

  prmDS := TParams.Create;
  try
    UnpackParams(DSParams, prmDS);

    FQueryRefresh.Params.AssignValues(prmDS);
    try
      DataSet := FQueryRefresh;
      FQueryRefresh.Close;
      FQueryRefresh.Open;
      Result := Data;
    finally
      DataSet := FQuery;
      FQueryRefresh.Close;
    end;
  finally
    prmDS.Free;
  end;

end;

procedure TIBEntityViewProvider.SetDatabase(Value: TIBDatabase);
begin
  FQuery.Database := Value;
  FQuery.Transaction.DefaultDatabase := Value;
end;

procedure TIBEntityViewProvider.SetDeleteSQL(const Value: string);
begin
  FUpdateSql.DeleteSQL.Text := Value;
end;

procedure TIBEntityViewProvider.SetInsertDefSQL(const Value: string);
begin
  FQueryInsertDef.SQL.Text := Value;
end;

procedure TIBEntityViewProvider.SetInsertSQL(const Value: string);
begin
  FUpdateSql.InsertSQL.Text := Value;
end;

procedure TIBEntityViewProvider.SetPrimaryKey(const Value: string);
begin
  ExtractStrings([';'], [], PChar(Value), FPrimaryKey);
end;

procedure TIBEntityViewProvider.SetRefreshSQL(const Value: string);
begin
  FQueryRefresh.SQL.Text := Value;
end;

procedure TIBEntityViewProvider.SetSelectSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;

procedure TIBEntityViewProvider.SetUpdateSQL(const Value: string);
begin
  FUpdateSql.ModifySQL.Text := Value;
end;

end.
