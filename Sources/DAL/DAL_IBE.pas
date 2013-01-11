unit DAL_IBE;

interface
uses classes,  IBDataBase, db, IBSql,
  IBCustomDataSet, provider, sysutils, Contnrs, IBQuery, IBUpdateSQL,
  DBClient, Variants, TConnect, StrUtils, IB, DAL, generics.collections;

type

  TIBQueryFix = class(TIBQuery)
  protected
    //Fix - не предусмотрена обработка нового типа ftShortint
    procedure PSSetParams(AParams: TParams); override;
    //Fix - при отрицательном коде ошибки ClientDataSet не нормально обрабатывает exception
    function PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError; override;
    //Binding Self params for insert/update/delete by UpdateObject
    function PSExecuteStatement(const ASQL: WideString; AParams: TParams;
      ResultSet: Pointer = nil): Integer; override;
  end;

  TDataSetProviderClass = class of TDataSetProvider;

  TIBMetadataProvider = class(TDataSetProvider)
  const
    GET_METADATA_SQL =
      ' select sql_select '+
      ' from bfw_ent_views ' +
      ' where entityname = ''BFW_META'' and viewname = :metadata';

  private
    FDatabase: TIBDatabase;
    FQuery: TIBQueryFix;
    FTransaction: TIBTransaction;
    FMetadataDictionary: TDictionary<string, string>;
    function Command2Sql(const ACommandText: string): string;
  protected
    procedure SetCommandText(const CommandText: WideString); override;
  public
    constructor Create(AOwner: TComponent; ADatabase: TIBDatabase); reintroduce;
    destructor Destroy; override;
  end;

  TIBPlainSQLProvider = class(TDataSetProvider)
  private
    FDatabase: TIBDatabase;
    FQuery: TIBQueryFix;
    FTransaction: TIBTransaction;
  public
    constructor Create(AOwner: TComponent; ADatabase: TIBDatabase); reintroduce;
  end;


  TIBEntityOperProvider = class(TDataSetProvider)
  const
    METADATA_SQL =
      ' select * '+
      ' from bfw_ent_views ' +
      ' where entityname = :entityname and viewname = :opername';
  private
    FEntityName: string;
    FOperName: string;
    FDatabase: TIBDatabase;
    FQuery: TIBQueryFix;
    FTransaction: TIBTransaction;
    procedure LoadMetadataCallback(AResultData: TIBXSQLDA);
  public
    constructor Create(AOwner: TComponent; ADataBase: TIBDatabase;
      const AEntityName, AOperName: string); reintroduce;
    procedure ReloadMetadata;
  end;

  TIBEntityViewProvider = class(TDataSetProvider)
  const
    METADATA_SQL =
      ' select * '+
      ' from bfw_ent_views ' +
      ' where entityname = :entityname and viewname = :viewname';
  private
    FEntityName: string;
    FViewName: string;
    FDatabase: TIBDatabase;
    FQuery: TIBQueryFix;
    FQueryDataRequest: TIBQueryFix;
    FRequestReloadRecordSQL: string;
    FRequestInsertDefSQL: string;
    FRequestTitleSQL: string;
    FUpdateSql: TIBUpdateSql;
    FTransaction: TIBTransaction;
    FPrimaryKey: TStringList;
    procedure LoadMetadataCallback(AResultData: TIBXSQLDA);
    procedure AfterOpen(DataSet: TDataSet);
  protected
    function DataRequestHandler(Sender: TObject; Input : OleVariant) : OleVariant;
  public
    constructor Create(AOwner: TComponent; ADataBase: TIBDatabase;
      const AEntityName, AViewName: string); reintroduce;
    destructor Destroy; override;
    procedure ReloadMetadata;
  end;

  TDAL_IBE_RemoteServer = class(TLocalConnection)
  protected
    function GetProvider(const ProviderName: string): TCustomProvider; override;
  end;

  TDAL_IBE = class(TCustomDAL)
  private
    FDatabase: TIBDataBase;
    FProviders: TDictionary<string, TDataSetProvider>;
    FRemoteServer: TCustomRemoteServer;
  public
    class function EngineName: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect(const AConnectionString: string); override;
    procedure Disconnect; override;
    procedure Reconnect; override;
    function RemoteServer: TCustomRemoteServer; override;
    function GetProvider(const AProviderName: string): TDataSetProvider; override;
    procedure ClearCacheMetadata; override;
  end;

implementation

{  function GetEntityAttrProviderName(const AEntityName, AViewName: string): string;
  const
    Alpha = ['A'..'Z', 'a'..'z', '_'];
    AlphaNumeric = Alpha + ['0'..'9'];
  var
    I: Integer;
  begin
    Result := UpperCase(AEntityName + AViewName);
    for I := 1 to Length(Result) do
      if not CharInSet(Result[I], AlphaNumeric) then
        Result[I] := '_';
  end;
  }
{type
  TExecuteSQLCallback = procedure(AResultData: TIBXSQLDA) of object;}

type
  TIBExecuteSQLCallback = procedure(AResultData: TIBXSQLDA) of object;

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

function TIBQueryFix.PSExecuteStatement(const ASQL: WideString;
  AParams: TParams; ResultSet: Pointer): Integer;
var
  I: integer;
  prm: TParam;
begin
  for I := 0 to AParams.Count - 1 do
  begin
    if not AParams[I].IsNull then Continue;
    prm := Params.FindParam(AParams[I].Name);
    if prm <> nil then
      AParams[I].Value := prm.Value;
  end;

  Result := inherited PSExecuteStatement(ASQL, AParams, ResultSet);
end;

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
    не определена ветка дл€ ftShortint !!!

end;
}

   for I := 0 to Params.Count - 1 do
     if Params[I].DataType = ftShortInt then
          Params[I].DataType := ftSmallInt;
end;


{ TPlainSQLProvider }

constructor TIBPlainSQLProvider.Create(AOwner: TComponent; ADatabase: TIBDatabase);
begin
  inherited Create(AOwner);
  FDatabase := ADatabase;
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;
  FQuery := TIBQueryFix.Create(Self);
  FQuery.Transaction := FTransaction;
  FQuery.Database := FDatabase;
  FQuery.Transaction.DefaultDatabase := FDatabase;

  Self.DataSet := FQuery;
  Self.Options := Self.Options + [poAllowCommandText];

end;

{ TIBEntityOperProvider }

constructor TIBEntityOperProvider.Create(AOwner: TComponent; ADataBase: TIBDatabase;
  const AEntityName, AOperName: string);
begin
  inherited Create(AOwner);
  FEntityName := AEntityName;
  FOperName := AOperName;

  FDatabase := ADatabase;
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;
  FQuery := TIBQueryFix.Create(Self);
  FQuery.Transaction := FTransaction;
  FQuery.Database := FDatabase;
  FQuery.Transaction.DefaultDatabase := FDatabase;

  Self.DataSet := FQuery;

  IBExecuteSQL(FDatabase, METADATA_SQL, [FEntityName, FOperName],
    LoadMetadataCallback);

end;

procedure TIBEntityOperProvider.LoadMetadataCallback(AResultData: TIBXSQLDA);
begin
  FQuery.SQL.Text := AResultData.ByName('sql_select').AsString;

  if Trim(FQuery.SQL.Text) = '' then
    raise Exception.CreateFmt('SQL is empty for %s.%s', [FEntityName, FOperName]);


end;

procedure TIBEntityOperProvider.ReloadMetadata;
begin
  IBExecuteSQL(FDatabase, METADATA_SQL, [FEntityName, FOperName],
    LoadMetadataCallback);
end;


{ TIBEntityViewProvider }

procedure TIBEntityViewProvider.AfterOpen(DataSet: TDataSet);
var
  I: integer;
begin
  for I := 0 to DataSet.FieldCount - 1 do
    DataSet.Fields[I].Required := false; //Disable constraint for IEntityView.DoModify method !!!
end;

constructor TIBEntityViewProvider.Create(AOwner: TComponent; ADataBase: TIBDatabase;
  const AEntityName, AViewName: string);
begin
  inherited Create(AOwner);
  FEntityName := AEntityName;
  FViewName := AViewName;

  FDatabase := ADatabase;

  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;

  FQuery := TIBQueryFix.Create(Self);
  FQuery.Transaction := FTransaction;
  FQuery.Database := FDatabase;
  FQuery.Transaction.DefaultDatabase := FDatabase;
  FQuery.AfterOpen := AfterOpen;
  Self.DataSet := FQuery;

  FUpdateSql := TIBUpdateSQL.Create(Self);
  FQuery.UpdateObject := FUpdateSql;

  FQueryDataRequest := TIBQueryFix.Create(Self);
  FQueryDataRequest.Transaction := FTransaction;

  OnDataRequest := DataRequestHandler;

  FPrimaryKey := TStringList.Create;

  IBExecuteSQL(FDatabase, METADATA_SQL, [FEntityName, FViewName],
    LoadMetadataCallback);

end;

function TIBEntityViewProvider.DataRequestHandler(Sender: TObject;
  Input: OleVariant): OleVariant;

  function GetData(const ASQL: string; AParams: OleVariant): OleVariant;
  var
    prmDS: TParams;
  begin
    Result := Unassigned;

    FQueryDataRequest.SQL.Text := ASQL;

    prmDS := TParams.Create;
    try
      UnpackParams(AParams, prmDS);
      FQueryDataRequest.Params.AssignValues(prmDS);
      try
        DataSet := FQueryDataRequest;
        FQueryDataRequest.Close;
        FQueryDataRequest.Open;
        Result := Data;
      finally
        DataSet := FQuery;
        FQueryDataRequest.Close;
      end;
    finally
      prmDS.Free;
    end;
  end;

var
  requestKind: TEntityDataRequestKind;
begin
  Result := Unassigned;

  requestKind := Input[0];

  case requestKind of
    erkReloadRecord:
      if FRequestReloadRecordSQL <> '' then
        Result := GetData(FRequestReloadRecordSQL, Input[1]);

    erkInsertDefaults:
      if FRequestInsertDefSQL <> '' then
        Result := GetData(FRequestInsertDefSQL, Input[1]);

    erkTitle:
      if FRequestTitleSQL <> '' then
        Result := GetData(FRequestTitleSQL, Input[1]);

    else
      Result := Unassigned;
  end;

end;

destructor TIBEntityViewProvider.Destroy;
begin
  FPrimaryKey.Free;
  inherited;
end;


procedure TIBEntityViewProvider.LoadMetadataCallback(AResultData: TIBXSQLDA);
begin
  if Trim(AResultData.ByName('SQL_Select').AsString) = '' then
    raise Exception.CreateFmt('SQL is empty for %s.%s', [FEntityName, FViewName]);

  FQuery.SQL.Text := AResultData.ByName('SQL_Select').AsString;
  FUpdateSql.InsertSQL.Text := AResultData.ByName('SQL_Insert').AsString;
  FUpdateSql.ModifySQL.Text := AResultData.ByName('SQL_Update').AsString;
  FUpdateSql.DeleteSQL.Text := AResultData.ByName('SQL_Delete').AsString;

  if FUpdateSql.InsertSQL.Text = '' then
    FUpdateSql.InsertSQL.Text := FUpdateSql.ModifySQL.Text;

  FRequestReloadRecordSQL := AResultData.ByName('SQL_Refresh').AsString;
  FRequestInsertDefSQL := AResultData.ByName('SQL_InsertDef').AsString;
  FRequestTitleSQL := AResultData.ByName('SQL_TITLE').AsString;


end;

procedure TIBEntityViewProvider.ReloadMetadata;
begin
  IBExecuteSQL(FDatabase, METADATA_SQL, [FEntityName, FViewName],
    LoadMetadataCallback);
end;

{ TDAL_IBX }

procedure TDAL_IBE.ClearCacheMetadata;
var
  prov: TDataSetProvider;
begin
  for prov in FProviders.Values do
  begin
    if prov is TIBEntityViewProvider then
      (prov as TIBEntityViewProvider).ReloadMetadata
    else if prov is TIBEntityOperProvider then
      (prov as TIBEntityOperProvider).ReloadMetadata;
  end;
end;

procedure TDAL_IBE.Connect(const AConnectionString: string);
const
  ESQLCode_Login = -901;
  ELoginMessage = 'Ќеверный пароль или им€ пользовател€. ѕовторите ввод.';

var
  prm: TStringList;
  I: integer;
begin
  prm := TStringList.Create;
  try
    ExtractStrings([';'], [], PChar(AConnectionString), prm);

    FDataBase.DatabaseName := prm.Values['DataBase'];
    for I := 0 to prm.Count - 1 do
    if not SameText(prm.Names[I], 'DataBase') then
      FDataBase.Params.Values[prm.Names[I]] := prm.ValueFromIndex[I];

    {FDataBase.Params.Values['user_name'] := FParams.Values['user_name'];
    FDataBase.Params.Values['password'] := FParams.Values['Password'];
    FDataBase.Params.Values['sql_role_name'] := FParams.Values['sql_role_name'];}

  finally
    prm.Free;
  end;

  try
    FDatabase.Connected := true;
  except
    on E: EIBError do
    begin
      if E.SQLCode = ESQLCode_Login then
        raise Exception.Create(ELoginMessage)
      else
        raise;
    end;
  end;

end;

constructor TDAL_IBE.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FProviders := TDictionary<string, TDataSetProvider>.Create;

  FDataBase := TIBDataBase.Create(Self);
  FDataBase.DefaultTransaction := TIBTransaction.Create(FDataBase);
  FDataBase.DefaultTransaction.DefaultDatabase := FDataBase;
  FDataBase.LoginPrompt := false;

  FRemoteServer := TDAL_IBE_RemoteServer.Create(Self);
end;

destructor TDAL_IBE.Destroy;
begin
  FProviders.Free;
  inherited;
end;

procedure TDAL_IBE.Disconnect;
begin
  FDatabase.Connected := false;
end;

class function TDAL_IBE.EngineName: string;
begin
  Result := 'IBE';
end;

function TDAL_IBE.GetProvider(const AProviderName: string): TDataSetProvider;
var
  providerName: string;
  provKind: TProviderNameBuilder.TProviderKind;
  entityName: string;
  viewName: string;
begin
  providerName := AProviderName; // UpperCase(AProviderName);

  if not FProviders.TryGetValue(providerName, Result) then
  begin
    if providerName = METADATA_PROVIDER then
      Result := TIBMetadataProvider.Create(Self, FDatabase)
    else if providerName = DATASETPROXY_PROVIDER then
      Result := TIBPlainSQLProvider.Create(Self, FDatabase)
    else begin
      TProviderNameBuilder.Decode(providerName, provKind, entityName, viewName);
      if provKind = pkEntityView then
        Result := TIBEntityViewProvider.Create(Self, FDatabase, entityName, viewName)
      else if provKind = pkEntityOper then
        Result := TIBEntityOperProvider.Create(Self, FDatabase, entityName, viewName)
      else
        raise Exception.Create('Bad provider name');
    end;
    FProviders.Add(providerName, Result);
  end;

  if NoCacheMetadata then
  begin
    if Result is TIBEntityViewProvider then
      (Result as TIBEntityViewProvider).ReloadMetadata
    else if Result is TIBEntityOperProvider then
      (Result as TIBEntityOperProvider).ReloadMetadata;
  end;
end;

procedure TDAL_IBE.Reconnect;
begin
  if FDatabase.Connected then
  begin
    FDatabase.Connected := false;
    FDatabase.Connected := true;
  end;
end;

function TDAL_IBE.RemoteServer: TCustomRemoteServer;
begin
  Result := FRemoteServer;
end;

{ TIBMetadataProvider }

function TIBMetadataProvider.Command2Sql(const ACommandText: string): string;
begin
  if not FMetadataDictionary.TryGetValue(ACommandText, Result) then
  begin
    FQuery.SQL.Text := GET_METADATA_SQL;
    FQuery.Params.ParamValues['METADATA'] := ACommandText;
    FQuery.Open;
    if FQuery.IsEmpty then
      raise Exception.CreateFmt('Metadata for %s not found', [ACommandText]);

    Result := FQuery['SQL_SELECT'];
    FMetadataDictionary.Add(ACommandText, Result);
  end;
end;

constructor TIBMetadataProvider.Create(AOwner: TComponent;
  ADatabase: TIBDatabase);
begin
  inherited Create(AOwner);
  FMetadataDictionary := TDictionary<string, string>.Create;
  FDatabase := ADatabase;
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;
  FQuery := TIBQueryFix.Create(Self);
  FQuery.Transaction := FTransaction;
  FQuery.Database := FDatabase;
  FQuery.Transaction.DefaultDatabase := FDatabase;

  Self.DataSet := FQuery;
  Self.Options := Self.Options + [poAllowCommandText];
end;

destructor TIBMetadataProvider.Destroy;
begin
  FMetadataDictionary.Free;
  inherited;
end;

procedure TIBMetadataProvider.SetCommandText(const CommandText: WideString);
var
  sqlText: string;
begin
  sqlText := Command2Sql(CommandText);
  inherited SetCommandText(sqlText);
end;

{ TDAL_IBE_RemoteServer }

function TDAL_IBE_RemoteServer.GetProvider(
  const ProviderName: string): TCustomProvider;
begin
  Result := TDAL_IBE(Owner).GetProvider(ProviderName);
  if Result = nil then
    raise Exception.CreateFmt('Provider %s not found', [ProviderName]);
end;

initialization
  DAL.RegisterDALEngine(TDAL_IBE);
end.
