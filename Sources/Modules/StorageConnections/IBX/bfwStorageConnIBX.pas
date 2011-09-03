unit bfwStorageConnIBX;

interface
uses classes, EntityServiceIntf, IBDataBase, db, IBSql,
  IBCustomDataSet, provider, sysutils, Contnrs, IBQuery, IBUpdateSQL,
  DBClient, Variants, TConnect, StrUtils, IB;

resourcestring
  cnstGetEntityListSQL = 'select entityname from ent_entities';

  cnstGetEntityInfoSQL =
    'select * from ent_entities where entityname = :entityname';

  cnstEntityViewExistsSQL =
    ' select count(*) '+
    ' from ent_views ' +
    ' where entityname = :entityname and viewname = :viewname';

  cnstGetEntityViewInfoSQL =
    ' select * '+
    ' from ent_views ' +
    ' where entityname = :entityname and viewname = :viewname';

  cnstGetEntityViewLinksInfoSQL =
    ' select * '+
    ' from ent_view_links ' +
    ' where entityname = :entityname and viewname = :viewname';

  cnstGetEntityViewLinkedFieldsInfoSQL =
    ' select * '+
    ' from ent_view_links ' +
    ' where linked_entityname = :entityname and linked_viewname = :viewname ' +
    '       and coalesce(linked_field, '''') <> '''' ';

  cnstGetEntityOperInfoSQL =
    ' select * '+
    ' from ent_opers ' +
    ' where entityname = :entityname and opername = :opername';

  cnstGetEntityFieldsInfoSQL =
    ' select * '+
    ' from ent_fields ' +
    ' where entityname = :entityname and viewname = :viewname';

  cnstGetEntityFieldsDefInfoSQL =
    ' select * '+
    ' from ent_fields ' +
    ' where entityname = :entityname and viewname = ''-'' ';

  cnstGetSchemeFieldsInfoSQL =
    ' select * '+
    ' from ent_fields ' +
    ' where entityname = :schemename and viewname = ''-'' ';

type

  TIBQueryResultCallback = procedure(ASourceData: TObject;
    AResultData: TIBXSQLDA) of object;

  TExecuteDBQueryProc = procedure(const ASQL: string; AParams: array of variant;
    ResultCallback: TIBQueryResultCallback; ASourceData: TObject) of object;

  TIBEntityAttrInfo = class(TComponent)
  private
    FEntityName: string;
    FAttrName: string;
    FDBQueryProc: TExecuteDBQueryProc;
    //
    FParams: TParams;
    FFields: TFields;
    FOptions: TStringList;
    FLinks: TObjectList;
    FLinkedFields: TStringList;
    procedure GetFieldsInfoCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
  protected
    procedure SetOptionsText(const AText: string);
    function GetEntityName: string;
    function GetAttrName: string;
    procedure ExecuteDBQuery(const ASQL: string; AParams: array of variant;
      ResultCallback: TIBQueryResultCallback; ASourceData: TObject);
    //IEntityViewInfo
    function Fields: TFields;
    function Params: TParams;
    function GetOptions(const AName: string): string;
  public
    constructor Create(const AEntityName, AttrName: string;
      ADBQueryProc: TExecuteDBQueryProc); reintroduce; virtual;
    destructor Destroy; override;
    procedure Initialize; virtual;
  end;

  TIBEntityAttrInfoClass = class of TIBEntityAttrInfo;


  TIBEntityViewInfo = class(TIBEntityAttrInfo, IEntityViewInfo)
  private
    FSelectSQL: string;
    FInsertSQL: string;
    FUpdateSQL: string;
    FDeleteSQL: string;
    FRefreshSQL: string;
    FPrimaryKey: string;
    FReadOnly: boolean;
    FIsExec: boolean;
    FExists: boolean;
    FInsertDefSQL: string;
    procedure GetViewExistsCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
    procedure GetViewInfoCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
    procedure GetViewLinksInfoCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
    procedure GetViewLinkedFieldsInfoCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
  protected
    //IEntityViewInfo
    function PrimaryKey: string;
    function ReadOnly: boolean;
    function IsExec: boolean;

    function LinksCount: integer;
    function GetLinksInfo(AIndex: integer): TEntityViewLinkInfo;
    function LinkedFields: TStringList;
  public
    procedure Initialize; override;
    property Exists: boolean read FExists;
    property SelectSQL: string read FSelectSQL;
    property InsertSQL: string read FInsertSQL;
    property UpdateSQL: string read FUpdateSQL;
    property DeleteSQL: string read FDeleteSQL;
    property RefreshSQL: string read FRefreshSQL;
    property InsertDefSQL: string read FInsertDefSQL;
  end;

  TIBEntityOperInfo = class(TIBEntityAttrInfo, IEntityOperInfo)
  private
    FSQL: string;
    FIsSelect: boolean;
    procedure GetOperInfoCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
  protected
    function IsSelect: boolean;
  public
    procedure Initialize; override;
    property SQL: string read FSQL;
  end;

  TIBEntityInfo = class(TComponent, IEntityInfo)
  private
    FEntityName: string;
    FSchemeName: string;
    FDescription: string;
    FFields: TFields;
    FOptions: TStringList;
    FViewInfoList: TComponentList;
    FOperInfoList: TComponentList;
    FDBQueryProc: TExecuteDBQueryProc;
    procedure GetFieldsInfoCallback(ASourceData: TObject; AResultData: TIBXSQLDA);

    procedure GetInfoDataCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
    function FindOrCreateAttrInfo(const AttrName: string;
      AttrClass: TIBEntityAttrInfoClass; AList: TComponentList): TIBEntityAttrInfo;

    function FindOrCreateViewInfo(const AViewName: string): TIBEntityViewInfo;
    function FindOrCreateOperInfo(const AOperName: string): TIBEntityOperInfo;
  protected
    function SchemeName: string;
    function Fields: TFields;
    function GetViewInfo(const AViewName: string): IEntityViewInfo;
    function GetOperInfo(const AOperName: string): IEntityOperInfo;
    function ViewExists(const AViewName: string): boolean;
    function GetOptions(const AName: string): string;
    procedure SetOptions(const AName, AValue: string);
  public
    constructor Create(const AEntityName: string;
      ADBQueryProc: TExecuteDBQueryProc); reintroduce;
    destructor Destroy; override;
    procedure Initialize;
  end;


  TIBEntitySchemeInfo = class(TComponent, IEntitySchemeInfo)
  private
    FSchemeName: string;
    FFields: TFields;
    FDBQueryProc: TExecuteDBQueryProc;
    procedure GetFieldsInfoCallback(ASourceData: TObject; AResultData: TIBXSQLDA);

//    procedure GetInfoDataCallback(ASourceData: TObject; AResultData: TIBXSQLDA);
  protected
    function Fields: TFields;
  public
    constructor Create(const ASchemeName: string;
      ADBQueryProc: TExecuteDBQueryProc); reintroduce;
    destructor Destroy; override;
    procedure Initialize;
  end;

  TIBStorageInfo = class(TComponent, IEntityStorageInfo)
  private
    FDBQueryProc: TExecuteDBQueryProc;
  protected
    //IEntityStorageInfo
  public
    constructor Create(ADBQueryProc: TExecuteDBQueryProc); reintroduce;
    destructor Destroy; override;
    procedure Initialize;
  end;

  TIBQueryFix = class(TIBQuery)
  protected
    //Fix - не предусмотрена обработка нового типа ftShortint
    procedure PSSetParams(AParams: TParams); override;
    //Fix - при отрицательном коде ошибки ClientDataSet не нормально обрабатывает exception
    function PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError; override;
  end;

  TIBEntityAttrProvider = class(TDataSetProvider)
  end;

  TIBEntityAttrProviderClass = class of TIBEntityAttrProvider;

  TIBEntityViewProvider = class(TIBEntityAttrProvider)
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

  TIBEntityOperProvider = class(TIBEntityAttrProvider)
  private
    FQuery: TIBQueryFix;
    FTransaction: TIBTransaction;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetSQL(const Value: string);
  end;

  TDetachedDataSet = class(TComponent, IDetachedDataSet)
  private
    FDataSet: TIBQuery;
    FTransaction: TIBTransaction;
  protected
    function GetDataSet: TDataSet;
    function GetParams: TParams;
    procedure Open;
    procedure Close;
  public
    constructor Create(AOwner: TComponent;
      ADataBase: TIBDatabase; const ASQL: string); reintroduce;
  end;

  TIBStorageConnection = class(TComponent, IEntityStorageConnection)
  private
    FID: string;
    FRemoteServer: TLocalConnection;
    FConnectionBroker:  TConnectionBroker;
    FDatabase: TIBDatabase;
    FEntityList: TStringList;
    FEntityListLoaded: boolean;
    FEntityInfoList: TComponentList;
    FEntityAttrProviders: TComponentList;
    FEntitySchemeInfoList: TComponentList;
    FStorageInfo: TIBStorageInfo;
    FStorageInfoInitialized: boolean;

    procedure ExecuteDBQuery(const ASQL: string; AParams: array of variant;
      ResultCallback: TIBQueryResultCallback; ASourceData: TObject);

    procedure LoadEntityList;
    procedure LoadEntityListCallback(ASourceData: TObject; AResultData: TIBXSQLDA);

    function GetEntityAttrProviderName(const AEntityName, AViewName: string): string;
    function FindOrCreateEntityInfo(const AName: string): TIBEntityInfo;
    function FindOrCreateEntityAttrProvider(const AEntityName,
      AViewName: string; AClass: TIBEntityAttrProviderClass): TIBEntityAttrProvider;
    function FindOrCreateEntitySchemeInfo(const AName: string): TIBEntitySchemeInfo;
    function GetEntityViewProvider(const AEntityName, AViewName: string;
      AOwner: TComponent): TComponent;
    function GetEntityOperProvider(const AEntityName, AOperName: string;
      AOwner: TComponent): TComponent;
  protected
    //IConnection
    function ID: string;
    procedure Connect;
    procedure Disconnect;
    function IsConnected: boolean;

    function ConnectionComponent: TCustomRemoteServer;
    function GetEntityViewProviderName(const AEntityName, AViewName: string): string;
    function GetEntityOperProviderName(const AEntityName, AOperName: string): string;

    function GetEntityList: TStringList;
    function GetEntityInfo(const AName: string): IEntityInfo;
    function GetStorageInfo: IEntityStorageInfo;
    function GetSchemeInfo(const AName: string): IEntitySchemeInfo;

    function GetDetachedDataSet(AOwner: TComponent; const ACommandText: string): IDetachedDataSet;
    function GetStubConnectionComponent: TCustomConnection;

  public
    constructor Create(const AID: string; AParams: TStrings); reintroduce;
    destructor Destroy; override;
  end;

  TIBStorageConnectionFactory = class(TComponent, IEntityStorageConnectionFactory)
  protected
    function Engine: string;
    function CreateConnection(const ID: string; AParams: TStrings): TComponent;
  end;


implementation

procedure FieldAttributeBuilder(AField: TField; AData: TIBXSQLDA);
var
  attributeText: string;
  I: integer;
  editorOptionsList: TStringList;
  editorOptions: string;
begin
  AField.FieldName := AData.ByName('fieldname').AsString;
  AField.DisplayLabel := AData.ByName('title').AsString;
  AField.DisplayWidth := 50;
  AField.Visible := AData.ByName('visible').AsInteger = 1;
  AField.ReadOnly := AData.ByName('readonly').AsInteger = 1;
  AField.Required := AData.ByName('req').AsInteger = 1;

  attributeText := '';
  attributeText := attributeText + FIELD_ATTR_BAND + '=' + AData.ByName('band').AsString + ';';

  if AData.ByName('visible').AsInteger = -1 then
    attributeText := attributeText + FIELD_ATTR_HIDDEN + '=1;';

  if AData.ByName('options').AsString <> '' then
    attributeText := attributeText + AData.ByName('options').AsString + ';';

  if AData.ByName('editor').AsString <> '' then
  begin
    attributeText := attributeText + FIELD_ATTR_EDITOR + '=' + AData.ByName('editor').AsString + ';';
    editorOptions := AData.ByName('editor_options').AsString;
    if editorOptions <> '' then
    begin
      editorOptionsList := TStringList.Create;
      try
        ExtractStrings([';'], [], PChar(editorOptions), editorOptionsList);
        editorOptions := '';
        for I := 0 to editorOptionsList.Count - 1 do
          editorOptions := editorOptions + FIELD_ATTR_EDITOR + '.' + editorOptionsList[I] + ';';
      finally
        editorOptionsList.Free;
      end;
      attributeText := attributeText + editorOptions;
    end;
  end;

  SetFieldAttributeText(AField, attributeText);
end;

{ TIBStorageConnectionFactory }

function TIBStorageConnectionFactory.CreateConnection(const ID: string;
  AParams: TStrings): TComponent;
begin
  Result := TIBStorageConnection.Create(ID, AParams);
end;

function TIBStorageConnectionFactory.Engine: string;
begin
  Result := 'IBE';
end;

{ TIBStorageConnection }

function TIBStorageConnection.ConnectionComponent: TCustomRemoteServer;
begin
//  Result := FDataBase;
  Result := FConnectionBroker;
end;

constructor TIBStorageConnection.Create(const AID: string; AParams: TStrings);
var
  I: integer;
begin
  inherited Create(nil);
  FID := AID;
  FEntityList := TStringList.Create;
  FEntityListLoaded := false;
  FEntityInfoList := TComponentList.Create(true);
  FEntityAttrProviders := TComponentList.Create(true);
  FEntitySchemeInfoList := TComponentList.Create(true);
  FStorageInfo := TIBStorageInfo.Create(ExecuteDBQuery);
  FRemoteServer := TLocalConnection.Create(Self);
  FConnectionBroker :=  TConnectionBroker.Create(Self);
  FConnectionBroker.Connection := FRemoteServer;

  FDataBase := TIBDataBase.Create(Self);
  FDataBase.DefaultTransaction := TIBTransaction.Create(FDataBase);
  FDataBase.DefaultTransaction.DefaultDatabase := FDataBase;
  FDataBase.DatabaseName := AParams.Values['DataBase'];

  for I := 0 to AParams.Count - 1 do
    if not SameText(AParams.Names[I], 'DataBase') then
      FDataBase.Params.Values[AParams.Names[I]] := AParams.ValueFromIndex[I];

  {FDataBase.Params.Values['user_name'] := FParams.Values['user_name'];
  FDataBase.Params.Values['password'] := FParams.Values['Password'];
  FDataBase.Params.Values['sql_role_name'] := FParams.Values['sql_role_name'];}
  FDataBase.LoginPrompt := false;

end;


destructor TIBStorageConnection.Destroy;
begin
  FEntityList.Free;
  FEntityInfoList.Free;
  FEntityAttrProviders.Free;
  FEntitySchemeInfoList.Free;
  FStorageInfo.Free;
  inherited;
end;



function TIBStorageConnection.GetEntityInfo(
  const AName: string): IEntityInfo;
begin
  Result := FindOrCreateEntityInfo(AName);
end;

function TIBStorageConnection.GetEntityList: TStringList;
begin
  Result := FEntityList;
  if not FEntityListLoaded then
    LoadEntityList;
end;

function TIBStorageConnection.ID: string;
begin
  Result := FID;
end;

procedure TIBStorageConnection.LoadEntityList;
begin
  FEntityList.Clear;
  ExecuteDBQuery(cnstGetEntityListSQL, [], LoadEntityListCallback, nil);
  FEntityListLoaded := true;
end;

procedure TIBStorageConnection.LoadEntityListCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
begin
  FEntityList.Add(AResultData[0].AsString);
end;

procedure TIBStorageConnection.ExecuteDBQuery(const ASQL: string;
  AParams: array of variant; ResultCallback: TIBQueryResultCallback;
  ASourceData: TObject);
var
  qry: TIBSQL;
  I: integer;
begin
  qry:= TIBSQL.Create(nil);
  try
    qry.Database:= FDatabase;
    qry.Transaction:= TIBTransaction.Create(qry);
    qry.Transaction.DefaultDatabase := FDataBase;
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
          ResultCallback(ASourceData, qry.Current);
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


function TIBStorageConnection.FindOrCreateEntityInfo(
  const AName: string): TIBEntityInfo;
var
  I: integer;
begin
  for I := 0 to FEntityInfoList.Count - 1 do
  begin
    Result := TIBEntityInfo(FEntityInfoList[I]);
    if Result.FEntityName = AName then Exit;
  end;

  Result := TIBEntityInfo.Create(AName, ExecuteDBQuery);
  FEntityInfoList.Add(Result);
  try
    Result.Initialize;
  except
    Result.Free;
    raise;
  end;
end;

function TIBStorageConnection.GetEntityViewProvider(const AEntityName,
  AViewName: string; AOwner: TComponent): TComponent;
var
  viewInfo: TIBEntityViewInfo;
begin
  viewInfo := FindOrCreateEntityInfo(AEntityName).
    FindOrCreateViewInfo(AViewName);

//  Result := TIBEntityViewProvider.Create(AOwner);
//  Result.Name := 'ViewProvider_' + IntToStr(FRemoteServer.ProviderCount);

  Result := FindOrCreateEntityAttrProvider(AEntityName, AViewName,
    TIBEntityViewProvider);

  with TIBEntityViewProvider(Result) do
  begin
     SetDatabase(FDatabase);
     SetSelectSQL(viewInfo.SelectSQL);
     if viewInfo.SelectSQL = '' then
       raise Exception.CreateFmt('SQL is empty for %s.%s', [AEntityName, AViewName]);

     SetInsertSQL(viewInfo.InsertSQL);
     SetUpdateSQL(viewInfo.UpdateSQL);
     SetDeleteSQL(viewInfo.DeleteSQL);
     SetRefreshSQL(viewInfo.RefreshSQL);
     SetInsertDefSQL(viewInfo.InsertDefSQL);
     SetPrimaryKey(viewInfo.PrimaryKey);
  end;
end;

function TIBStorageConnection.GetEntityViewProviderName(const AEntityName,
  AViewName: string): string;
begin
  Result := GetEntityViewProvider(AEntityName, AViewName, Self).Name;
end;

function TIBStorageConnection.GetEntityOperProvider(const AEntityName,
  AOperName: string; AOwner: TComponent): TComponent;
var
  operInfo: TIBEntityOperInfo;
begin
  operInfo := FindOrCreateEntityInfo(AEntityName).
    FindOrCreateOperInfo(AOperName);

  Result := FindOrCreateEntityAttrProvider(AEntityName, AOperName,
    TIBEntityOperProvider);
//  Result := TIBEntityOperProvider.Create(AOwner);
//  Result.Name := 'OperProvider_' + IntToStr(FRemoteServer.ProviderCount);
  with TIBEntityOperProvider(Result) do
  begin
     SetDatabase(FDatabase);
     SetSQL(operInfo.SQL);
     if operInfo.SQL = '' then
       raise Exception.CreateFmt('SQL is empty for %s.%s', [AEntityName, AOperName]);
  end;

end;

function TIBStorageConnection.GetEntityOperProviderName(const AEntityName,
  AOperName: string): string;
begin
  Result := GetEntityOperProvider(AEntityName, AOperName, Self).Name;
end;

procedure TIBStorageConnection.Connect;
const
  ESQLCode_Login = -901;
  ELoginMessage = 'Ќеверный пароль или им€ пользовател€. ѕовторите ввод.';

begin
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

procedure TIBStorageConnection.Disconnect;
begin
  FDatabase.Connected := false;
end;

function TIBStorageConnection.IsConnected: boolean;
begin
  Result :=  FDatabase.Connected;
end;


function TIBStorageConnection.FindOrCreateEntityAttrProvider(const AEntityName,
  AViewName: string; AClass: TIBEntityAttrProviderClass): TIBEntityAttrProvider;
var
  I: integer;
  _ProviderName: string;
begin
  _ProviderName := GetEntityAttrProviderName(AEntityName, AViewName);
  for I := 0 to FEntityAttrProviders.Count - 1 do
  begin
    Result := TIBEntityAttrProvider(FEntityAttrProviders[I]);
    if Result.Name = _ProviderName then Exit;
  end;

  Result := AClass.Create(Self);
  Result.Name := _ProviderName;
  FEntityAttrProviders.Add(Result);
end;

function TIBStorageConnection.GetEntityAttrProviderName(const AEntityName,
  AViewName: string): string;
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

function TIBStorageConnection.GetStubConnectionComponent: TCustomConnection;
begin
  Result := FDataBase;
end;

function TIBStorageConnection.GetStorageInfo: IEntityStorageInfo;
begin
  if not FStorageInfoInitialized then
    FStorageInfo.Initialize;
  Result := FStorageInfo as IEntityStorageInfo;
end;

function TIBStorageConnection.GetSchemeInfo(
  const AName: string): IEntitySchemeInfo;
begin
  Result := FindOrCreateEntitySchemeInfo(AName);
end;

function TIBStorageConnection.FindOrCreateEntitySchemeInfo(
  const AName: string): TIBEntitySchemeInfo;
var
  I: integer;
begin
  for I := 0 to FEntitySchemeInfoList.Count - 1 do
  begin
    Result := TIBEntitySchemeInfo(FEntitySchemeInfoList[I]);
    if SameText(Result.FSchemeName, AName) then Exit;
  end;

  Result := TIBEntitySchemeInfo.Create(AName, ExecuteDBQuery);
  FEntitySchemeInfoList.Add(Result);
  try
    Result.Initialize;
  except
    Result.Free;
    raise;
  end;

end;

function TIBStorageConnection.GetDetachedDataSet(AOwner: TComponent;
  const ACommandText: string): IDetachedDataSet;
var
  obj: TDetachedDataSet;
  cmdText: TStringList;
  cmdSQL: string;
begin
  cmdText := TStringList.Create;
  try
    cmdText.Text := ACommandText;
    if (cmdText.Values['EntityName'] <> '')  then
      cmdSQL := FindOrCreateEntityInfo(cmdText.Values['EntityName']).
        FindOrCreateViewInfo(cmdText.Values['EntityViewName']).SelectSQL
    else
      cmdSQL := ACommandText;
  finally
    cmdText.Free;
  end;

  obj := TDetachedDataSet.Create(AOwner, FDataBase, cmdSQL);
  obj.GetInterface(IDetachedDataSet, Result);

end;

{ TIBEntityInfo }

constructor TIBEntityInfo.Create(const AEntityName: string;
  ADBQueryProc: TExecuteDBQueryProc);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FViewInfoList := TComponentList.Create(true);
  FOperInfoList := TComponentList.Create(true);
  FDBQueryProc := ADBQueryProc;
  FFields := TFields.Create(nil);
  FOptions := TStringList.Create;
end;

destructor TIBEntityInfo.Destroy;
begin
  FViewInfoList.Free;
  FOperInfoList.Free;
  FFields.Free;
  FOptions.Free;
  inherited;
end;

function TIBEntityInfo.Fields: TFields;
begin
  Result := FFields;
end;

function TIBEntityInfo.FindOrCreateAttrInfo(const AttrName: string;
  AttrClass: TIBEntityAttrInfoClass; AList: TComponentList): TIBEntityAttrInfo;
var
  I: integer;
begin
  for I := 0 to AList.Count - 1 do
  begin
    Result := TIBEntityAttrInfo(AList[I]);
    if Result.GetAttrName = AttrName then Exit;
  end;

  Result := AttrClass.Create(FEntityName, AttrName, FDBQueryProc);
  AList.Add(Result);
  try
    Result.Initialize;
  except
    Result.Free;
    raise;
  end;
end;

function TIBEntityInfo.FindOrCreateOperInfo(
  const AOperName: string): TIBEntityOperInfo;
begin
  Result := TIBEntityOperInfo(
    FindOrCreateAttrInfo(AOperName, TIBEntityOperInfo, FOperInfoList));
end;

function TIBEntityInfo.FindOrCreateViewInfo(
  const AViewName: string): TIBEntityViewInfo;
begin
  Result := TIBEntityViewInfo(
    FindOrCreateAttrInfo(AViewName, TIBEntityViewInfo, FViewInfoList));
end;

procedure TIBEntityInfo.GetFieldsInfoCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
var
  FieldItem: TField;

begin
  FieldItem := TField.Create(Self);
  FFields.Add(FieldItem);
  FieldAttributeBuilder(FieldItem, AResultData);
end;

procedure TIBEntityInfo.GetInfoDataCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
begin
  FDescription := AResultData.ByName('Description').AsString;
  FSchemeName := AResultData.ByName('SchemeName').AsString;
end;

function TIBEntityInfo.GetOperInfo(
  const AOperName: string): IEntityOperInfo;
begin
  Result := FindOrCreateOperInfo(AOperName);
end;

function TIBEntityInfo.GetOptions(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

function TIBEntityInfo.GetViewInfo(
  const AViewName: string): IEntityViewInfo;
begin
  Result := FindOrCreateViewInfo(AViewName);
end;

procedure TIBEntityInfo.Initialize;
begin
  FDBQueryProc(cnstGetEntityInfoSQL, [FEntityName],
    GetInfoDataCallback, nil);

  FDBQueryProc(cnstGetEntityFieldsDefInfoSQL, [FEntityName],
    GetFieldsInfoCallback, nil);

end;

function TIBEntityInfo.SchemeName: string;
begin
  Result := FSchemeName;
end;

procedure TIBEntityInfo.SetOptions(const AName, AValue: string);
begin
  FOptions.Values[AName] := AValue;
end;

function TIBEntityInfo.ViewExists(const AViewName: string): boolean;
begin
  Result := FindOrCreateViewInfo(AViewName).Exists;
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

function TIBEntityViewProvider.RequestReloadRecord(DSParams: OleVariant): OleVariant;
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

{ TIBEntityViewInfo }

function TIBEntityViewInfo.GetLinksInfo(
  AIndex: integer): TEntityViewLinkInfo;
begin
  Result := TEntityViewLinkInfo(FLinks[AIndex]);
end;

procedure TIBEntityViewInfo.GetViewExistsCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
begin
  FExists := AResultData.Vars[0].AsInteger <> 0;
end;

procedure TIBEntityViewInfo.GetViewInfoCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
begin
  FSelectSQL := AResultData.ByName('SQL_Select').AsString;
  FInsertSQL := AResultData.ByName('SQL_Insert').AsString;
  FUpdateSQL := AResultData.ByName('SQL_Update').AsString;
  FDeleteSQL := AResultData.ByName('SQL_Delete').AsString;
  FRefreshSQL := AResultData.ByName('SQL_Refresh').AsString;
  FInsertDefSQL := AResultData.ByName('SQL_InsertDef').AsString;
  FPrimaryKey := AResultData.ByName('PKEY').AsString;
  if FPrimaryKey = '' then
    FPrimaryKey := CONST_PRIMARYKEY_NAME_DEFAULT;
  FReadOnly := AResultData.ByName('ReadOnly').AsInteger = 1;
  FIsExec := AResultData.ByName('IS_EXEC').AsInteger = 1;
  SetOptionsText(AResultData.ByName('Options').AsString);
end;

procedure TIBEntityViewInfo.GetViewLinkedFieldsInfoCallback(
  ASourceData: TObject; AResultData: TIBXSQLDA);
begin
  FLinkedFields.Add(AResultData.ByName('linked_field').AsString);
end;

procedure TIBEntityViewInfo.GetViewLinksInfoCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
var
  linkInfo: TEntityViewLinkInfo;
begin
  linkInfo := TEntityViewLinkInfo.Create;

  linkInfo.EntityName := AResultData.ByName('linked_entityname').AsString;
  linkInfo.ViewName := AResultData.ByName('linked_viewname').AsString;
  linkInfo.FieldName := AResultData.ByName('linked_field').AsString;
  linkInfo.LinkKind := TEntityViewLinkKind(AResultData.ByName('link_kind').AsInteger);

  FLinks.Add(linkInfo);

end;


procedure TIBEntityViewInfo.Initialize;
var
  I: integer;
begin

  ExecuteDBQuery(cnstEntityViewExistsSQL, [GetEntityName, GetAttrName],
    GetViewExistsCallback, nil);

  ExecuteDBQuery(cnstGetEntityViewInfoSQL, [GetEntityName, GetAttrName],
    GetViewInfoCallback, nil);

  ExecuteDBQuery(cnstGetEntityViewLinksInfoSQL, [GetEntityName, GetAttrName],
    GetViewLinksInfoCallback, nil);

  ExecuteDBQuery(cnstGetEntityViewLinkedFieldsInfoSQL, [GetEntityName, GetAttrName],
    GetViewLinkedFieldsInfoCallback, nil);

  inherited;

  if ReadOnly then
    for I := 0 to Fields.Count - 1 do
      Fields[I].ReadOnly := true;

//  if Params.Count = 0 then
 //   Params.ParseSQL(SelectSQL, true);
end;

function TIBEntityViewInfo.IsExec: boolean;
begin
  Result := FIsExec;
end;

function TIBEntityViewInfo.LinkedFields: TStringList;
begin
  Result := FLinkedFields;
end;

function TIBEntityViewInfo.LinksCount: integer;
begin
  Result := FLinks.Count;
end;

function TIBEntityViewInfo.PrimaryKey: string;
begin
  Result := FPrimaryKey;
end;

function TIBEntityViewInfo.ReadOnly: boolean;
begin
  Result := FReadOnly;
end;

{ TIBEntityOperInfo }

procedure TIBEntityOperInfo.GetOperInfoCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
begin
  FSQL := AResultData.ByName('sql_text').AsString;
  FIsSelect := AResultData.ByName('is_select').AsInteger = 1;
  SetOptionsText(AResultData.ByName('Options').AsString);
end;

procedure TIBEntityOperInfo.Initialize;
begin
  ExecuteDBQuery(cnstGetEntityOperInfoSQL, [GetEntityName, GetAttrName],
    GetOperInfoCallback, nil);
  inherited;    
end;

function TIBEntityOperInfo.IsSelect: boolean;
begin
  Result := FIsSelect;
end;


{ TIBEntityAttrInfo }

constructor TIBEntityAttrInfo.Create(const AEntityName, AttrName: string;
  ADBQueryProc: TExecuteDBQueryProc);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FAttrName := AttrName;
  FDBQueryProc := ADBQueryProc;
  FParams := TParams.Create(Self);
  FFields := TFields.Create(nil);
  FOptions := TStringList.Create;
  FLinks := TObjectList.Create(true);
  FLinkedFields := TStringList.Create;
end;

destructor TIBEntityAttrInfo.Destroy;
begin
  FFields.Free;
  FOptions.Free;
  FLinks.Free;
  FLinkedFields.Free;
  inherited;
end;

procedure TIBEntityAttrInfo.ExecuteDBQuery(const ASQL: string;
  AParams: array of variant; ResultCallback: TIBQueryResultCallback;
  ASourceData: TObject);
begin
  FDBQueryProc(ASQL, AParams, ResultCallback, ASourceData);
end;

function TIBEntityAttrInfo.GetAttrName: string;
begin
  Result := FAttrName;
end;

function TIBEntityAttrInfo.GetEntityName: string;
begin
  Result := FEntityName;
end;

function TIBEntityAttrInfo.Fields: TFields;
begin
  Result := FFields;
end;

procedure TIBEntityAttrInfo.GetFieldsInfoCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
var
  FieldItem: TField;
begin
  FieldItem := TField.Create(Self);
  FFields.Add(FieldItem);
  FieldAttributeBuilder(FieldItem, AResultData);
end;

procedure TIBEntityAttrInfo.Initialize;
begin
  ExecuteDBQuery(cnstGetEntityFieldsInfoSQL, [GetEntityName, GetAttrName],
    GetFieldsInfoCallback, nil);
end;

function TIBEntityAttrInfo.Params: TParams;
begin
  Result := FParams;
end;

function TIBEntityAttrInfo.GetOptions(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

procedure TIBEntityAttrInfo.SetOptionsText(const AText: string);
begin
  ExtractStrings([';'], [], PWideChar(FOptions.Text + ';' + AText), FOptions);
end;


{ TIBStorageInfo }

constructor TIBStorageInfo.Create(ADBQueryProc: TExecuteDBQueryProc);
begin
  inherited Create(nil);
  FDBQueryProc := ADBQueryProc;
end;

destructor TIBStorageInfo.Destroy;
begin
  inherited;
end;

procedure TIBStorageInfo.Initialize;
begin
end;

{ TIBEntitySchemeInfo }

constructor TIBEntitySchemeInfo.Create(const ASchemeName: string;
  ADBQueryProc: TExecuteDBQueryProc);
begin
  inherited Create(nil);
  FSchemeName := ASchemeName;
  FDBQueryProc := ADBQueryProc;
  FFields := TFields.Create(nil);
end;

destructor TIBEntitySchemeInfo.Destroy;
begin
  FFields.Free;
  inherited;
end;

function TIBEntitySchemeInfo.Fields: TFields;
begin
  Result := FFields;
end;

procedure TIBEntitySchemeInfo.GetFieldsInfoCallback(ASourceData: TObject;
  AResultData: TIBXSQLDA);
var
  FieldItem: TField;
begin
  FieldItem := TField.Create(Self);
  FFields.Add(FieldItem);
  FieldAttributeBuilder(FieldItem, AResultData);
end;

procedure TIBEntitySchemeInfo.Initialize;
var
  _schemeName: string;
begin
  _schemeName := FSchemeName;
  if _schemeName = '' then
   _schemeName := '-';

  FDBQueryProc(cnstGetSchemeFieldsInfoSQL, [_schemeName],
    GetFieldsInfoCallback, nil);

end;

{ TDetachedDataSet }

procedure TDetachedDataSet.Close;
begin
  FDataSet.Close;
end;

constructor TDetachedDataSet.Create(AOwner: TComponent;
   ADataBase: TIBDatabase; const ASQL: string);
begin
  inherited Create(AOwner);
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.AutoStopAction := saCommit;
  FDataSet := TIBQuery.Create(Self);
  FDataSet.Transaction := FTransaction;
  FDataSet.Database := ADatabase;
  FDataSet.Transaction.DefaultDatabase := ADatabase;
  FDataSet.SQL.Text := ASQL;
end;

function TDetachedDataSet.GetDataSet: TDataSet;
begin
  Result := FDataSet;
end;

function TDetachedDataSet.GetParams: TParams;
begin
  Result := FDataSet.Params;
end;

procedure TDetachedDataSet.Open;
begin
  FDataSet.Open;
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
    не определена ветка дл€ ftShortint !!!

end;
}

   for I := 0 to Params.Count - 1 do
     if Params[I].DataType = ftShortInt then
          Params[I].DataType := ftSmallInt;
end;

end.
