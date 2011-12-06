unit StorageConnIBX;

interface
uses classes, EntityServiceIntf, IBDataBase, db, IBSql,
  IBCustomDataSet, provider, sysutils, Contnrs, IBQuery, IBUpdateSQL,
  DBClient, Variants, TConnect, StrUtils, IB, DAL, DAL_IBX;

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

  TIBQueryResultCallback = procedure(AResultData: TIBXSQLDA) of object;

  TExecuteDBQueryProc = procedure(const ASQL: string; AParams: array of variant;
    ResultCallback: TIBQueryResultCallback) of object;

  TIBEntityAttrInfo = class(TComponent)
  private
    FEntityName: string;
    FAttrName: string;

    //
    FParams: TParams;
    FFields: TFields;
    FOptions: TStringList;
    FLinks: TObjectList;
    FLinkedFields: TStringList;
    FDatabase: TIBDatabase;
    procedure GetFieldsInfoCallback( AResultData: TIBXSQLDA);
  protected
    procedure SetOptionsText(const AText: string);
    function GetEntityName: string;
    function GetAttrName: string;
    //IEntityViewInfo
    function Fields: TFields;
    function Params: TParams;
    function GetOptions(const AName: string): string;
  public
    constructor Create(const AEntityName, AttrName: string;
      ADatabase: TIBDatabase); reintroduce; virtual;
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
    procedure GetViewExistsCallback(AResultData: TIBXSQLDA);
    procedure GetViewInfoCallback(AResultData: TIBXSQLDA);
    procedure GetViewLinksInfoCallback(AResultData: TIBXSQLDA);
    procedure GetViewLinkedFieldsInfoCallback(AResultData: TIBXSQLDA);
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
    procedure GetOperInfoCallback(AResultData: TIBXSQLDA);
  protected
    function IsSelect: boolean;
  public
    procedure Initialize; override;
    property SQL: string read FSQL;
  end;

  TIBEntityInfo = class(TComponent, IEntityInfo)
  private
    FNoCache: boolean;
    FEntityName: string;
    FSchemeName: string;
    FDescription: string;
    FFields: TFields;
    FOptions: TStringList;
    FViewInfoList: TComponentList;
    FOperInfoList: TComponentList;
    FDatabase: TIBDatabase;
    procedure GetFieldsInfoCallback(AResultData: TIBXSQLDA);

    procedure GetInfoDataCallback(AResultData: TIBXSQLDA);
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
      ADatabase: TIBDatabase; ANoCache: boolean); reintroduce;
    destructor Destroy; override;
    procedure Initialize;
  end;


  TIBEntitySchemeInfo = class(TComponent, IEntitySchemeInfo)
  private
    FSchemeName: string;
    FFields: TFields;
    FDataBase: TIBDataBase;
    procedure GetFieldsInfoCallback(AResultData: TIBXSQLDA);

  protected
    function Fields: TFields;
  public
    constructor Create(const ASchemeName: string; ADataBase: TIBDataBase); reintroduce;
    destructor Destroy; override;
    procedure Initialize;
  end;

  TIBStorageInfo = class(TComponent, IEntityStorageInfo)
  end;

  TEmbededServer = class(TLocalConnection)
  private
    FDAL: TCustomDAL;
  protected
    function GetProvider(const ProviderName: string): TCustomProvider; override;
  public
    property DAL: TCustomDAL read FDAL write FDAL;
  end;

  TIBStorageConnection = class(TComponent, IEntityStorageConnection)
  private
    FNoCache: boolean;
    FDAL: TCustomDAL;
    FRemoteServer: TEmbededServer;
    FConnectionBroker:  TConnectionBroker;
    FDatabase: TIBDatabase;
    FEntityInfoList: TComponentList;
    FEntityAttrProviders: TComponentList;
    FEntitySchemeInfoList: TComponentList;
    FConnectionString: string;

    function FindOrCreateEntityInfo(const AName: string): TIBEntityInfo;
    function FindOrCreateEntitySchemeInfo(const AName: string): TIBEntitySchemeInfo;

  protected
    //IConnection
    procedure Connect;
    procedure Disconnect;
    function IsConnected: boolean;

    function ConnectionComponent: TCustomRemoteServer;


    function GetEntityInfo(const AName: string): IEntityInfo;

    function GetSchemeInfo(const AName: string): IEntitySchemeInfo;

    function GetStubConnectionComponent: TCustomConnection;

  public
    constructor Create(AParams: TStrings); reintroduce;
    destructor Destroy; override;
  end;

  TIBStorageConnectionFactory = class(TComponent, IEntityStorageConnectionFactory)
  protected
    function Engine: string;
    function CreateConnection(AParams: TStrings): TComponent;
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

function TIBStorageConnectionFactory.CreateConnection(
  AParams: TStrings): TComponent;
begin
  Result := TIBStorageConnection.Create(AParams);
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

constructor TIBStorageConnection.Create(AParams: TStrings);
begin
  inherited Create(nil);
  FEntityInfoList := TComponentList.Create(true);
  FEntityAttrProviders := TComponentList.Create(true);
  FEntitySchemeInfoList := TComponentList.Create(true);

  FRemoteServer := TEmbededServer.Create(Self);
  FConnectionBroker :=  TConnectionBroker.Create(Self);
  FConnectionBroker.Connection := FRemoteServer;

  FConnectionString := AParams.Text;
  FDAL := TDAL_IBX.Create(Self);
  FDatabase := TDAL_IBX(FDAL).StubDatabase;
  FRemoteServer.DAL := FDAL;

  FNoCache := FindCmdLineSwitch('NoCacheMetadata');
end;


destructor TIBStorageConnection.Destroy;
begin
  FEntityInfoList.Free;
  FEntityAttrProviders.Free;
  FEntitySchemeInfoList.Free;

  inherited;
end;



function TIBStorageConnection.GetEntityInfo(
  const AName: string): IEntityInfo;
begin
  Result := FindOrCreateEntityInfo(AName);
end;


function TIBStorageConnection.FindOrCreateEntityInfo(
  const AName: string): TIBEntityInfo;
var
  I: integer;
begin
  for I := 0 to FEntityInfoList.Count - 1 do
  begin
    Result := TIBEntityInfo(FEntityInfoList[I]);
    if Result.FEntityName = AName then
    begin
      if FNoCache then Result.Initialize;
      Exit;
    end;
  end;

  Result := TIBEntityInfo.Create(AName, FDatabase, FNoCache);
  FEntityInfoList.Add(Result);
  try
    Result.Initialize;
  except
    Result.Free;
    raise;
  end;
end;


procedure TIBStorageConnection.Connect;
begin
  FDAL.Connect(FConnectionString);
end;

procedure TIBStorageConnection.Disconnect;
begin
  FDAL.Disconnect;
end;

function TIBStorageConnection.IsConnected: boolean;
begin
  Result :=  FDatabase.Connected;
end;


function TIBStorageConnection.GetStubConnectionComponent: TCustomConnection;
begin
  Result := FDataBase;
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
    if SameText(Result.FSchemeName, AName) then
    begin
      if FNoCache then Result.Initialize;
      Exit;
    end;
  end;

  Result := TIBEntitySchemeInfo.Create(AName, FDatabase);
  FEntitySchemeInfoList.Add(Result);
  try
    Result.Initialize;
  except
    Result.Free;
    raise;
  end;

end;


{ TIBEntityInfo }

constructor TIBEntityInfo.Create(const AEntityName: string;
  ADatabase: TIBDatabase; ANoCache: boolean);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FNoCache := ANoCache;
  FDatabase := ADatabase;
  FViewInfoList := TComponentList.Create(true);
  FOperInfoList := TComponentList.Create(true);
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
    if Result.GetAttrName = AttrName then
    begin
      if FNoCache then Result.Initialize;
      Exit;
    end;
  end;

  Result := AttrClass.Create(FEntityName, AttrName, FDatabase);
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

procedure TIBEntityInfo.GetFieldsInfoCallback(AResultData: TIBXSQLDA);
var
  FieldItem: TField;

begin
  FieldItem := TField.Create(Self);
  FFields.Add(FieldItem);
  FieldAttributeBuilder(FieldItem, AResultData);
end;

procedure TIBEntityInfo.GetInfoDataCallback(AResultData: TIBXSQLDA);
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
  IBExecuteSQL(FDatabase, cnstGetEntityInfoSQL, [FEntityName], GetInfoDataCallback);

  FFields.Clear;
  IBExecuteSQL(FDatabase, cnstGetEntityFieldsDefInfoSQL, [FEntityName], GetFieldsInfoCallback);

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



{ TIBEntityViewInfo }

function TIBEntityViewInfo.GetLinksInfo(
  AIndex: integer): TEntityViewLinkInfo;
begin
  Result := TEntityViewLinkInfo(FLinks[AIndex]);
end;

procedure TIBEntityViewInfo.GetViewExistsCallback(AResultData: TIBXSQLDA);
begin
  FExists := AResultData.Vars[0].AsInteger <> 0;
end;

procedure TIBEntityViewInfo.GetViewInfoCallback(AResultData: TIBXSQLDA);
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

procedure TIBEntityViewInfo.GetViewLinkedFieldsInfoCallback(AResultData: TIBXSQLDA);
begin
  FLinkedFields.Add(AResultData.ByName('linked_field').AsString);
end;

procedure TIBEntityViewInfo.GetViewLinksInfoCallback(AResultData: TIBXSQLDA);
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

  IBExecuteSQL(FDatabase, cnstEntityViewExistsSQL, [GetEntityName, GetAttrName],
    GetViewExistsCallback);

  IBExecuteSQL(FDatabase, cnstGetEntityViewInfoSQL, [GetEntityName, GetAttrName],
    GetViewInfoCallback);

  FLinks.Clear;
  IBExecuteSQL(FDatabase, cnstGetEntityViewLinksInfoSQL, [GetEntityName, GetAttrName],
    GetViewLinksInfoCallback);

  FLinkedFields.Clear;
  IBExecuteSQL(FDatabase, cnstGetEntityViewLinkedFieldsInfoSQL, [GetEntityName, GetAttrName],
    GetViewLinkedFieldsInfoCallback);

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

procedure TIBEntityOperInfo.GetOperInfoCallback(AResultData: TIBXSQLDA);
begin
  FSQL := AResultData.ByName('sql_text').AsString;
  FIsSelect := AResultData.ByName('is_select').AsInteger = 1;
  SetOptionsText(AResultData.ByName('Options').AsString);
end;

procedure TIBEntityOperInfo.Initialize;
begin
  IBExecuteSQL(FDatabase, cnstGetEntityOperInfoSQL, [GetEntityName, GetAttrName],
    GetOperInfoCallback);
  inherited;    
end;

function TIBEntityOperInfo.IsSelect: boolean;
begin
  Result := FIsSelect;
end;


{ TIBEntityAttrInfo }

constructor TIBEntityAttrInfo.Create(const AEntityName, AttrName: string;
  ADatabase: TIBDatabase);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FAttrName := AttrName;
  FDatabase := ADatabase;
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

procedure TIBEntityAttrInfo.GetFieldsInfoCallback(AResultData: TIBXSQLDA);
var
  FieldItem: TField;
begin
  FieldItem := TField.Create(Self);
  FFields.Add(FieldItem);
  FieldAttributeBuilder(FieldItem, AResultData);
end;

procedure TIBEntityAttrInfo.Initialize;
begin
  FFields.Clear;
  IBExecuteSQL(FDatabase, cnstGetEntityFieldsInfoSQL, [GetEntityName, GetAttrName],
    GetFieldsInfoCallback);
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
  FOptions.Clear;
  ExtractStrings([';'], [], PWideChar(AText), FOptions);
end;

{ TIBEntitySchemeInfo }

constructor TIBEntitySchemeInfo.Create(const ASchemeName: string;
  ADataBase: TIBDataBase);
begin
  inherited Create(nil);
  FSchemeName := ASchemeName;
  FDataBase := ADataBase;
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

procedure TIBEntitySchemeInfo.GetFieldsInfoCallback(AResultData: TIBXSQLDA);
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

  FFields.Clear;
  IBExecuteSQL(FDatabase, cnstGetSchemeFieldsInfoSQL, [_schemeName],
    GetFieldsInfoCallback);

end;

{ TEmbededServer }

function TEmbededServer.GetProvider(
  const ProviderName: string): TCustomProvider;
begin
  Result := nil;
  if FDAL <> nil then
    Result := FDAL.GetProvider(ProviderName);
  if Result = nil then
    raise Exception.CreateFmt('Provider %s not found', [ProviderName]);
end;

end.
