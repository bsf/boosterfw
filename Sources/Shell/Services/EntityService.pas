unit EntityService;

interface

uses
  SysUtils, Classes, ConfigServiceIntf, EntityServiceIntf, Contnrs, ComObj,
  DBClient, CoreClasses, db, Variants, DAL, generics.collections,DBXJSON;

const
  ENT_METADATA_ENTITIES = 'Entities';
  ENT_METADATA_FIELDS = 'Fields';
  ENT_METADATA_ENTITY = 'Entity';
  ENT_METADATA_OPER = 'Oper';
  ENT_METADATA_VIEW = 'View';
  ENT_METADATA_VIEW_LINKS = 'ViewLinks';
  ENT_METADATA_VIEW_LINKEDFIELDS = 'ViewLinkedFields';

  ET_ENTITY_VIEW_RELOAD_LINKS_PK = 'entity://view_reload_links_pk_%s_%s';
  ET_ENTITY_VIEW_RELOAD_LINKS_LF = 'entity://view_reload_links_lf_%s_%s_%s';

  ERROR_MSG_FIELD_REQUIRE = 'Поле ''''%s'''' обязательно для заполнения';

type
  {добавляет поведение master -> detail в clientdataset}
  TEntityDataSetMasterLink = class(DB.TDetailDataLink)
  private
    FDataSet: TDataSet;
    procedure ReOpen;
  protected
    procedure ActiveChanged; override;
    procedure RecordChanged(Field: TField); override;
    function GetDetailDataSet: TDataSet; override;
    procedure CheckBrowseMode; override;
  public
    constructor Create(ADataSet: TDataSet);
  end;

  TEntityDataSet = class(TClientDataSet, IDataSetProxy)
  private
    FMasterLink: TDataLink;
    FUpdateErrorText: string;
    FImmediateApplyUpdates: boolean;
    FOnAfterImmediateApplyUpdates: TNotifyEvent;
    procedure SetImmediateApplyUpdates(const Value: boolean);
    procedure ReconcileErrorHandler(DataSet: TCustomClientDataSet;
      E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
    procedure SetParamsFromMaster;
  protected
    procedure DoBeforeOpen; override;
    procedure DoAfterDelete; override;
    procedure DoAfterInsert; override;
    //IDataSetProxy
    function DSProxy_GetDataSet: TDataSet;
    function DSProxy_GetParams: TParams;
    function DSProxy_GetCommandText: string;
    procedure DSProxy_SetCommandText(const AValue: string);
    procedure DSProxy_SetMaster(ADataSource: TDataSource);
    function DSProxy_GetMaster: TDataSource;

    function IDataSetProxy.GetDataSet = DSProxy_GetDataSet;
    function IDataSetProxy.GetParams = DSProxy_GetParams;
    function IDataSetProxy.GetCommandText = DSProxy_GetCommandText;
    procedure IDataSetProxy.SetCommandText = DSProxy_SetCommandText;
    procedure IDataSetProxy.SetMaster = DSProxy_SetMaster;
    function IDataSetProxy.GetMaster = DSProxy_GetMaster;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Post; override;
    property ImmediateApplyUpdates: boolean read FImmediateApplyUpdates
      write SetImmediateApplyUpdates;
    property OnAfterImmediateApplyUpdates: TNotifyEvent read FOnAfterImmediateApplyUpdates
      write FOnAfterImmediateApplyUpdates;
    property LastUpdateErrorMessage: string read FUpdateErrorText;
  end;


  TEntity = class;


  TEntityAttr = class(TComponent)
  private
    FParamsFetched: boolean;
    FWorkItem: TWorkItem;
    FEntityName: string;
    FAttrName: string;
    FDataSet: TEntityDataSet;
    FImmediateSave: boolean;
    FUpdateErrorText: string;
    procedure ReconcileErrorHandler(DataSet: TCustomClientDataSet; E: EReconcileError;
       UpdateKind: TUpdateKind; var Action: TReconcileAction);
  protected
    function GetWorkItem: TWorkItem;
    function GetEntityName: string;
    function GetAttrName: string;
    function GetDataSet: TClientDataSet;
    procedure SetImmediateSave(Value: boolean);
    function GetImmediateSave: boolean;
    function Params: TParams;
    procedure ParamsBind(const ABindingRule: string = '');
    function GetLastUpdateErrorMessage: string;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure AfterImmediateApplyUpdates(Sender: TObject); virtual;
  public
    class function ProviderKind: TProviderNameBuilder.TProviderKind; virtual;
    constructor Create(AConnection: TCustomRemoteServer;
      const AEntityName, AttrName: string; AWorkItem: TWorkItem); reintroduce; virtual;
    destructor Destroy; override;
    procedure SetProvider(ARemoteServer: TCustomRemoteServer;
      const AProviderName: string);
    property ImmediateSave: boolean read FImmediateSave write SetImmediateSave;
  end;


  TEntityView = class(TEntityAttr, IEntityView)
  private
    FDataSetInitialized: boolean;
    FPrimaryKeys: TStringList;
    FLinkedFields: TStringList;
    FReloadAfterUpdate: boolean;
    procedure ApplyPKInfo;
    procedure ApplyFieldInfo;
    procedure ApplyLinksInfo;
    procedure InitDataSetAttributes;

    procedure DoSynchronizeOnEntityChange(EventData: Variant);

    function EntityInfo: IEntityInfo;
    function SchemeInfo: IEntitySchemeInfo;
    function SchemeInfoDef: IEntitySchemeInfo;
    procedure CheckRequiredFields;
  protected
     procedure AfterImmediateApplyUpdates(Sender: TObject); override;
    //IEntityView
    function IEntityView.EntityName = GetEntityName;
    function ViewName: string;
    function Title: string;
    function DataSet: TDataSet;
    function IsModified: boolean;
    function IsLoaded: boolean;
    function Info: IEntityViewInfo;
    function Load(AParams: array of variant): TDataSet; overload;
    function Load(AReload: boolean = true; AParamBindingRule: string = ''): TDataSet; overload;
    procedure ReloadRecord(APrimaryKeyValues: Variant; SyncRecord: boolean = false);
    procedure ReloadLinksData;
    procedure Save;
    procedure UndoLastChange;
    procedure CancelUpdates;
    procedure DoModify;
    procedure SynchronizeOnEntityChange(const AEntityName, AViewName: string;
      const AFieldName: string = '');

    //JSON
    function EscapeString(const AValue: string): string;
    function JSONLoad: string;
    procedure JSONInsert(const Data: string);
    procedure JSONUpdate(const Data: string);
    procedure JSONDelete(const Data: string);

  public
    class function ProviderKind: TProviderNameBuilder.TProviderKind; override;
    constructor Create(AConnection: TCustomRemoteServer;
      const AEntityName, AttrName: string; AWorkItem: TWorkItem); override;
    destructor Destroy; override;
  end;

  TEntityOper = class(TEntityAttr, IEntityOper)
  protected
    //IEntityOper
    function IEntityOper.EntityName = GetEntityName;
    function OperName: string;
    function ResultData: TDataSet;
    function Execute(AParams: array of variant): TDataSet; overload;
    function Execute: TDataSet; overload;
    function Info: IEntityViewInfo;
  public
    class function ProviderKind: TProviderNameBuilder.TProviderKind;override;
  end;


  TEntityViewInfo = class(TComponent, IEntityViewInfo)
  private
    FMetaDS: TEntityDataSet;
    FEntityName: string;
    FViewName: string;
    FReadOnly: boolean;
    FPrimaryKey: string;
    FFields: TFields;
    FIsExec: boolean;
    FTitle: string;
    FViewExists: boolean;
    FOptions: TStringList;
    FLinkInfoDictionary: TObjectList<TEntityViewLinkInfo>;
    FLinkedFields: TStringList;
   protected
    function Fields: TFields;
    //function Params: TParams;
    function PrimaryKey: string;
    function ReadOnly: boolean;
    function IsExec: boolean;
    function Title: string;
    function LinksCount: integer;
    function GetLinksInfo(AIndex: integer): TEntityViewLinkInfo;
    function LinkedFields: TStringList;
    function GetOptions(const AName: string): string;
    function OptionExists(const AName: string): boolean;
  public
    constructor Create(AOwner: TComponent; AConnection: TCustomRemoteServer); reintroduce;
    destructor Destroy; override;
    procedure LoadInfo;
    function ViewExists: boolean;
  end;

  TEntityInfo = class(TComponent, IEntityInfo)
  private
    FMetaDS: TEntityDataSet;
    FFields: TFields;
    FEntityName: string;
    FSchemeName: string;
    FOptions: TStringList;
    FViewInfoDictionary: TDictionary<string, TEntityViewInfo>;
  protected
    //IEntityInfo
    function SchemeName: string;
    function Fields: TFields;
    function GetViewInfo(const AViewName: string): TEntityViewInfo;
    function GetViewInfoIntf(const AViewName: string): IEntityViewInfo;
    function IEntityInfo.GetViewInfo = GetViewInfoIntf;
    function ViewExists(const AViewName: string): boolean;

    function GetOptions(const AName: string): string;
    procedure SetOptions(const AName, AValue: string);
  public
    constructor Create(const AEntityName: string; AConnection: TCustomRemoteServer); reintroduce;
    destructor Destroy; override;
    procedure LoadInfo;
  end;

  TEntitySchemeInfo = class(TComponent, IEntitySchemeInfo)
  private
    FSchemeName: string;
    FFields: TFields;
    FConnection: TCustomRemoteServer;
  protected
    //IEntitySchemeInfo
    function Fields: TFields;
  public
    constructor Create(AOwner: TComponent; AConnection: TCustomRemoteServer); reintroduce;
    destructor Destroy; override;
    procedure LoadInfo;
  end;

  TEntity = class(TComponent, IEntity)
  private
    FConnection: TCustomRemoteServer;
    FEntityName: string;
    FEntityInfo: TEntityInfo;
  protected
    //IEntity
    function EntityName: string;
    function GetView(const AViewName: string; AWorkItem: TWorkItem;
      AInstanceID: string = ''): IEntityView;
    function GetOper(const AOperName: string; AWorkItem: TWorkItem;
      AInstanceID: string = ''): IEntityOper;
    function Info: IEntityInfo;
  public
    constructor Create(const AEntityName: string;
      AConnection: TCustomRemoteServer); reintroduce;
    destructor Destroy; override;
  end;



  TEntityService = class(TComponent, IEntityService)
  private
    FWorkItem: TWorkItem;
    FDAL: TCustomDAL;
    FConnection: TConnectionBroker;
    FEntities: TComponentList;
    FSchemeInfoDictionary: TDictionary<string, TEntitySchemeInfo>;
    FEntityList: TStringList;
    FMetadataDS: TEntityDataSet;
    function GetEntityList: TStringList;
  protected
    //IEntityManagerService
    function GetDataSetProxy(AOwner: TComponent): IDataSetProxy;
    function EntityExists(const AEntityName: string): boolean;
    function EntityViewExists(const AEntityName, AEntityViewName: string): boolean;
    function GetEntity(const AEntityName: string): IEntity;
    function GetSchemeInfo(const ASchemeName: string): IEntitySchemeInfo;

    procedure Connect(const AConnectionEngine, AConnectionParams: string);
    procedure Disconnect;
    procedure ClearMetadataCache;

  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

procedure LoadFieldsInfo(AFields: TFields; AConnection: TCustomRemoteServer;
  const AEntityName, AViewName: string);

var
  NoCacheMetadata: boolean;



implementation

procedure LoadFieldsInfo(AFields: TFields; AConnection: TCustomRemoteServer;
  const AEntityName, AViewName: string);

  procedure FieldAttributeBuilder(AField: TField; AData: TDataSet);
  var
    attributeText: string;
    I: integer;
    editorOptionsList: TStringList;
    editorOptions: string;
  begin
    AField.FieldName := VarToStr(AData['fieldname']);
    AField.DisplayLabel := VarToStr(AData['title']);
    AField.DisplayWidth := 50;
    AField.Visible := AData['visible'] = 1;
    AField.ReadOnly := AData['readonly'] = 1;
    AField.Required := AData['req'] = 1;

    attributeText := '';
    attributeText := attributeText + FIELD_ATTR_BAND + '=' + VarToStr(AData['band']) + ';';

    if AData['visible'] = -1 then
      attributeText := attributeText + FIELD_ATTR_HIDDEN + '=1;';

    if VarToStr(AData['options']) <> '' then
      attributeText := attributeText + VarToStr(AData['options']) + ';';

    if VarToStr(AData['editor']) <> '' then
    begin
      attributeText := attributeText + FIELD_ATTR_EDITOR + '=' + VarToStr(AData['editor']) + ';';
      editorOptions := VarToStr(AData['editor_options']);
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

var
  field: TField;
  ds: TClientDataSet;
begin
  AFields.Clear;

  ds := TClientDataSet.Create(nil);
  try
    ds.ProviderName := METADATA_PROVIDER;
    ds.RemoteServer := AConnection;
    ds.CommandText := ENT_METADATA_FIELDS;

    with ds.Params.AddParameter do
    begin
      Name := 'EntityName';
      Value := AEntityName;
    end;

    with ds.Params.AddParameter do
    begin
      Name := 'ViewName';
      Value := AViewName;
    end;
    ds.Open;
    while not ds.Eof do
    begin
      field := TField.Create(nil);
      AFields.Add(field);
      FieldAttributeBuilder(field, ds);
      ds.Next;
    end;
  finally
    ds.Free;
  end;
end;

var
  APP_VER: integer;

procedure InitAppVer;
var
  exeDate: TDateTime;
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
  sMonth, sDay, sHour: string;
  sResult: string;
begin
  exeDate := FileDateToDateTime(FileAge(ParamStr(0)));
  DecodeDate(exeDate, Year, Month, Day);
  DecodeTime(exeDate, Hour, Min, Sec, MSec);

  if Month < 10 then
    sMonth := '0' + IntToStr(Month)
  else
    sMonth := IntToStr(Month);

  if Day < 10 then
    sDay := '0' + IntToStr(Day)
  else
    sDay := IntToStr(Day);

  if Hour < 10 then
    sHour := '0' + IntToStr(Hour)
  else
    sHour := IntToStr(Hour);

  sResult := format('%d%s%s%s', [Year, sMonth, sDay, sHour]);
  APP_VER := StrToIntDef(sResult, 0);
end;

{ TEntityManagerService }

procedure TEntityService.ClearMetadataCache;
var
  I: integer;
begin

  FDAL.Reconnect;
  FDAL.ClearCacheMetadata;

  FEntityList.Clear;
  FSchemeInfoDictionary.Clear;

  for I := 0 to FEntities.Count - 1 do
  begin
    TEntity(FEntities[I]).FEntityInfo.FViewInfoDictionary.Clear;
    TEntity(FEntities[I]).FEntityInfo.LoadInfo;
  end;

end;

procedure TEntityService.Connect(const AConnectionEngine,
  AConnectionParams: string);
begin
  Disconnect;

  FDAL := GetDALEngine(AConnectionEngine).Create(Self);
  try
    FDAL.Connect(AConnectionParams);
    FDAL.NoCacheMetadata := NoCacheMetadata;
    FConnection.Connection := FDAL.RemoteServer;
  except
    FDAL.Free;
    FDAL := nil;
    raise;
  end;
end;

constructor TEntityService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FEntities := TComponentList.Create(True);
  FSchemeInfoDictionary := TDictionary<string, TEntitySchemeInfo>.Create;
  FConnection := TConnectionBroker.Create(Self);

  FMetadataDS := TEntityDataSet.Create(Self);
  FMetadataDS.ProviderName := METADATA_PROVIDER;
  FMetadataDS.RemoteServer := FConnection;

  FEntityList := TStringList.Create;
end;

destructor TEntityService.Destroy;
begin
  FEntities.Free;
  FEntityList.Free;
  FSchemeInfoDictionary.Free;

  inherited;
end;

procedure TEntityService.Disconnect;
var
  I: integer;
begin
  for I := FEntities.Count -1 downto 0 do FEntities.Delete(I);

  if FDAL <> nil then
  begin
    FDAL.Disconnect;
    FDAL.Free;
    FDAL := nil;
  end;
end;

function TEntityService.EntityExists(
  const AEntityName: string): boolean;
begin
  Result := true;
end;

function TEntityService.EntityViewExists(
  const AEntityName, AEntityViewName: string): boolean;
begin
  Result := GetEntity(AEntityName).Info.ViewExists(AEntityViewName);
end;

function TEntityService.GetDataSetProxy(AOwner: TComponent): IDataSetProxy;
var
  ds: TEntityDataSet;
begin
  ds := TEntityDataSet.Create(AOwner);
  ds.RemoteServer := FConnection;
  ds.ProviderName := DATASETPROXY_PROVIDER;
  Result := ds as IDataSetProxy;
end;

function TEntityService.GetEntityList: TStringList;
begin
  if (FEntityList.Count = 0) or NoCacheMetadata then
  begin
    FEntityList.Clear;
    FMetadataDS.Close;
    FMetadataDS.CommandText := ENT_METADATA_ENTITIES;
    FMetadataDS.Open;
    while not FMetadataDS.Eof do
    begin
      FEntityList.Add(FMetadataDS['ENTITYNAME']);
      FMetadataDS.Next;
    end;
  end;

  Result := FEntityList;
end;

function TEntityService.GetEntity(const AEntityName: string): IEntity;
var
  I: integer;
  Ent: TEntity;
begin
  Result := nil;
  for I := 0 to FEntities.Count -1 do
    if TEntity(FEntities[I]).EntityName = AEntityName then
    begin
      FEntities[I].GetInterface(IEntity, Result);
      Exit;
    end;

  if GetEntityList.IndexOf(AEntityName) = - 1 then
    raise Exception.CreateFmt('Entity %s not found', [AEntityName]);

  Ent := TEntity.Create(AEntityName, FConnection);
  FEntities.Add(Ent);
  Ent.GetInterface(IEntity, Result);
end;

function TEntityService.GetSchemeInfo(
  const ASchemeName: string): IEntitySchemeInfo;
var
  schemeName: string;
  item: TEntitySchemeInfo;
  doLoadInfo: boolean;
begin
  schemeName := ASchemeName;
  if schemeName = '' then schemeName := '-';

  doLoadInfo := NoCacheMetadata;
  if not FSchemeInfoDictionary.TryGetValue(schemeName, item) then
  begin
     item := TEntitySchemeInfo.Create(Self, FConnection);
     item.FSchemeName := schemeName;
     FSchemeInfoDictionary.Add(schemeName, item);
     doLoadInfo := true;
  end;

  if doLoadInfo then item.LoadInfo;

  Result := item as IEntitySchemeInfo;
end;

{ TEntity }

constructor TEntity.Create(const AEntityName: string; AConnection: TCustomRemoteServer);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FConnection := AConnection;
  FEntityInfo := TEntityInfo.Create(AEntityName, FConnection);
  FEntityInfo.LoadInfo;
end;

function TEntity.EntityName: string;
begin
  Result := FEntityName;
end;

function TEntity.GetView(const AViewName: string; AWorkItem: TWorkItem;
   AInstanceID: string): IEntityView;
var
  viewID: string;
  viewObj: TObject;
  view: TEntityView;
  viewProviderName: string;
begin
  viewID := 'entityViews.' + FEntityName + '.' + AViewName + '.' + AInstanceID;
  viewObj := AWorkItem.Items[viewID, TEntityView];
  if Assigned(viewObj) then
  begin
    viewObj.GetInterface(IEntityView, Result);
    Exit;
  end;

  view := TEntityView.Create(FConnection, FEntityName, AViewName, AWorkItem);

  viewProviderName := DAL.TProviderNameBuilder.Encode(pkEntityView,
    FEntityName, AViewName);

  view.SetProvider(FConnection, viewProviderName);


  AWorkItem.Items.Add(viewID, view);

  view.GetInterface(IEntityView, Result);

end;


function TEntity.GetOper(const AOperName: string;
  AWorkItem: TWorkItem; AInstanceID: string): IEntityOper;
const
  ENTITY_OPER_SUFFIX = '{D0B194AE-20F5-4BCA-8008-82E243769027}';
var
  operID: string;
  operObj: TObject;
  oper: TEntityOper;
  operProviderName: string;
begin
  operID := 'entityOpers.' + FEntityName + '.' + AOperName + '.' + AInstanceID;
  operObj := AWorkItem.Items[operID, TEntityOper];
  if Assigned(operObj) then
  begin
    operObj.GetInterface(IEntityOper, Result);
    Exit;
  end;

  oper := TEntityOper.Create(FConnection, FEntityName, AOperName, AWorkItem);

  operProviderName := DAL.TProviderNameBuilder.Encode(pkEntityOper,
    FEntityName, AOperName);

  oper.SetProvider(FConnection, operProviderName);

  AWorkItem.Items.Add(operID, oper);

  oper.GetInterface(IEntityOper, Result);
end;

destructor TEntity.Destroy;
begin
  FEntityInfo.Free;
  inherited;
end;

function TEntity.Info: IEntityInfo;
begin
  if NoCacheMetadata then  FEntityInfo.LoadInfo;

  Result := FEntityInfo as IEntityInfo;
end;

{ TEntityView }

procedure TEntityView.AfterImmediateApplyUpdates(Sender: TObject);
var
  I: integer;
  pkValues: Variant;
begin
  if FReloadAfterUpdate and (FPrimaryKeys.Count <> 0) and (not FDataSet.IsEmpty) then
  begin
    pkValues := VarArrayCreate([0, FPrimaryKeys.Count], varVariant);
    for I := 0 to FPrimaryKeys.Count - 1 do
      pkValues[I] := FDataSet[FPrimaryKeys[I]];
    ReloadRecord(pkValues, false);
  end;
end;

procedure TEntityView.ApplyFieldInfo;

  procedure SetFieldProp(AFieldInfo, AField: TField);
  begin
    if not Assigned(AFieldInfo) then Exit;
    if AFieldInfo.DisplayLabel <> AFieldInfo.FieldName then
      AField.DisplayLabel := AFieldInfo.DisplayLabel;
    AField.DisplayWidth := AFieldInfo.DisplayWidth;
    AField.Visible := AFieldInfo.Visible;
    AField.ReadOnly := AFieldInfo.ReadOnly;
    AField.Required := AFieldInfo.Required;
     // CopyFieldAttribute(FAttr, F);
  end;


var
  I: integer;
  F: TField;
  vInfo: IEntityViewInfo;
  eInfo: IEntityInfo;
  smInfo: IEntitySchemeInfo;
  smInfoDef: IEntitySchemeInfo;
  vFieldInfo: TField;
  eFieldInfo: TField;
  smFieldInfo: TField;
  smFieldInfoDef: TField;
  uiField: TField;
  dsReadOnly: boolean;
  rowReadOnly: boolean;
  applyUIFieldProp: boolean;
begin
  eInfo := EntityInfo;
  vInfo := Info;
  smInfo := SchemeInfo;
  smInfoDef := SchemeInfoDef;

  dsReadOnly := GetDataSetAttribute(GetDataSet, DATASET_ATTR_READONLY) = 'Yes';
  applyUIFieldProp := not GetDataSet.IsEmpty;

  rowReadOnly := false;
  if applyUIFieldProp then
  begin
    uiField := GetDataSet.FindField(FIELD_UI_ROW_READONLY);
    if uiField <> nil then
      rowReadOnly := uiField.AsInteger = 1;
  end;

  for I := 0 to GetDataSet.FieldCount - 1 do
  begin
    F := GetDataSet.Fields[I];

    //Hide system fields
    if Pos('UI_', UpperCase(F.FieldName)) = 1 then
    begin
      F.Visible := false;
      SetFieldAttribute(F, FIELD_ATTR_HIDDEN, '1');
    end;

    vFieldInfo := vInfo.Fields.FindField(F.FieldName);
    eFieldInfo := eInfo.Fields.FindField(F.FieldName);
    smFieldInfo := smInfo.Fields.FindField(F.FieldName);
    smFieldInfoDef := smInfoDef.Fields.FindField(F.FieldName);

    SetFieldProp(smFieldInfoDef, F);
    SetFieldProp(smFieldInfo, F);
    SetFieldProp(eFieldInfo, F);
    SetFieldProp(vFieldInfo, F);


    //ViewInfo
    if Assigned(vFieldInfo) then
      CopyFieldAttribute(vFieldInfo, F);

    //EntityInfo
    if Assigned(eFieldInfo) then
      CopyFieldAttribute(eFieldInfo, F);

    //SchemeInfo
    if Assigned(smFieldInfo) then
      CopyFieldAttribute(smFieldInfo, F);

    //Scheme default
    if Assigned(smFieldInfoDef) then
      CopyFieldAttribute(smFieldInfoDef, F);

    if (not F.ReadOnly) and vInfo.ReadOnly then
      F.ReadOnly := true;

    if dsReadOnly then
      F.ReadOnly := true;

    if applyUIFieldProp then
    begin
      uiField := GetDataSet.FindField(format(FIELD_UI_READONLY_FMT, [F.FieldName]));
      if uiField <> nil then
        F.ReadOnly := uiField.AsInteger = 1;

      if rowReadOnly then
        F.ReadOnly := true;

      uiField := GetDataSet.FindField(format(FIELD_UI_VISIBLE_FMT, [F.FieldName]));
      if uiField <> nil then
        F.Visible := uiField.AsInteger = 1;
    end;

    if (not F.ReadOnly) and F.Required then
    begin
      SetFieldAttribute(F, FIELD_ATTR_REQUIRED, '1');
      F.Required := false; //отключаю стандартную обработку
    end;

    if F is TFloatField then
    begin
      TFloatField(F).DisplayFormat := ',##0.00';
      //currency := true;
    end;

  end;

end;

procedure TEntityView.ApplyLinksInfo;
var
  I: integer;
  linkInfo: TEntityViewLinkInfo;
begin
  for I := 0 to Info.LinksCount -1 do
  begin
    linkInfo := Info.GetLinksInfo(I);
    SynchronizeOnEntityChange(linkInfo.EntityName, linkInfo.ViewName, linkInfo.FieldName);
  end;
  FLinkedFields.Clear;
  FLinkedFields.AddStrings(Info.LinkedFields);
end;

procedure TEntityView.ApplyPKInfo;
begin
  FPrimaryKeys.Clear;
  ExtractStrings([';',','], [], PChar(Info.PrimaryKey), FPrimaryKeys);
end;

procedure TEntityView.CancelUpdates;
begin
  GetDataSet.CancelUpdates;
end;

constructor TEntityView.Create(AConnection: TCustomRemoteServer;
  const AEntityName, AttrName: string; AWorkItem: TWorkItem);
begin
  inherited;
  FPrimaryKeys := TStringList.Create;
  FLinkedFields := TStringList.Create;
end;


function TEntityView.DataSet: TDataSet;
begin
  Result := GetDataSet;
  if not FDataSetInitialized then
  begin
    InitDataSetAttributes;
    FDataSetInitialized := true;
  end
end;


destructor TEntityView.Destroy;
begin
  FPrimaryKeys.Free;
  FLinkedFields.Free;  
  inherited;
end;

procedure TEntityView.DoModify;
var
  fieldAux: TField;
  _immediateSave: boolean;
begin
  _immediateSave := GetImmediateSave;
  try

    SetImmediateSave(false);

    if GetDataSet.IsEmpty then
    begin
      GetDataSet.Insert;
     // GetDataSet.Post; // ReqFields!!!
    end
    else
    begin
      fieldAux := GetDataSet.FindField('UI_MODIFIED');
      if fieldAux = nil then
        fieldAux := GetDataSet.FindField('MODIFIED'); //obsolete
      if Assigned(fieldAux) then
      begin
        GetDataSet.Edit;
        fieldAux.Value := 1;
        GetDataSet.Post;
      end;
    end;

  finally
    SetImmediateSave(_immediateSave);
  end;
end;

procedure TEntityView.DoSynchronizeOnEntityChange(EventData: Variant);
begin
  ReloadRecord(EventData);
end;

function TEntityView.EntityInfo: IEntityInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).
     Entity[GetEntityName].Info;
end;


procedure TEntityView.InitDataSetAttributes;
begin
  SetDataSetAttribute(GetDataSet, DATASET_ATTR_ENTITY, GetEntityName);
  SetDataSetAttribute(GetDataSet, DATASET_ATTR_ENTITY_VIEW, ViewName);

  SetDataSetAttribute(GetDataSet, DATASET_ATTR_PRIMARYKEY, Info.PrimaryKey);
  if Info.ReadOnly then
    SetDataSetAttribute(GetDataSet, DATASET_ATTR_READONLY, 'Yes')
  else
    SetDataSetAttribute(GetDataSet, DATASET_ATTR_READONLY, 'No');

  FReloadAfterUpdate := Info.OptionExists(DATASET_ATTR_RELOADAFTERUPDATE);
  if FReloadAfterUpdate then
    SetDataSetAttribute(GetDataSet, DATASET_ATTR_RELOADAFTERUPDATE, 'Yes')
  else
    SetDataSetAttribute(GetDataSet, DATASET_ATTR_RELOADAFTERUPDATE, 'No');

end;

function TEntityView.IsLoaded: boolean;
begin
  Result := FDataSet.Active;
end;

function TEntityView.IsModified: boolean;
begin
  Result := GetDataSet.ChangeCount > 0;
end;

procedure TEntityView.JSONDelete(const Data: string);
begin

end;

procedure TEntityView.JSONInsert(const Data: string);
begin

end;

function TEntityView.JSONLoad: string;
var
  data: TJSONArray;
  jRecord: TJSONObject;
  jVal: TJSONValue;
  ds: TDataSet;
  I: integer;
begin
  data := TJSONArray.Create;
  try
    ds := Load(true);
    ds.First;
    while not ds.Eof do
    begin
      jRecord := TJSONObject.Create;
      for I := 0 to ds.FieldCount - 1 do
      begin
        if ds.Fields[i] is TFloatField then
          jVal := TJSONNumber.Create(ds.Fields[i].AsFloat)
        else
          jVal := TJSONString.Create(EscapeString(ds.fields[I].AsString));
        jRecord.AddPair(ds.Fields[I].FieldName, jVal);
      end;
      data.AddElement(jRecord);
      ds.Next;
    end;
    Result := data.ToString;
  finally
    data.Free;
  end;
end;

procedure TEntityView.JSONUpdate(const Data: string);
var
  row: TJSONObject;
  jPair: TJSONPair;
  pkValues: Variant;
  I: integer;
  field: TField;
begin
  Load(false);

  row := TJSONObject.ParseJSONValue(Data) as TJSONObject;
  if not Assigned(row) then
    raise Exception.Create('Wrong JSON object!');


  pkValues := VarArrayCreate([0, FPrimaryKeys.Count], varVariant);
  for I := 0 to FPrimaryKeys.Count - 1 do
  begin
    jPair := row.Get(FPrimaryKeys[I]);
    if jPair = nil then
      raise Exception.CreateFmt('Primary key field %s not found in JSON', [FPrimaryKeys[I]]);
    pkValues[I] := jPair.JsonValue.Value;
  end;

  if GetDataSet.Locate(Info.PrimaryKey, pkValues, []) then
  begin
    GetDataSet.Edit;
    for I := 0 to row.Size - 1 do
    begin
      field := GetDataSet.FindField(row.Get(i).JsonString.Value);
      if assigned(field) and (not field.ReadOnly) then
        field.Value := row.Get(i).JsonValue.Value;
    end;

    GetDataSet.Post;
   // Save;
  end;
end;

function TEntityView.Load(AParams: array of variant): TDataSet;
var
  I: integer;
begin

  for I := 0 to High(AParams) do
    if Params.Count > I then
        Params[I].Value := AParams[I];

  Result := Load(true, '-');

end;

function TEntityView.Load(AReload: boolean; AParamBindingRule: string): TDataSet;
var
  IsReloading: boolean;
begin
  Result := FDataSet;

  if (not IsLoaded) or AReload then
  begin
    FDataSet.DisableControls;
    try
      IsReloading := IsLoaded;

      ParamsBind(AParamBindingRule);

      if FDataSet.Active then
        FDataSet.Close;

      GetWorkItem.Root.EventTopics[ET_ENTITY_VIEW_OPEN_START].Fire;
      try
        FDataSet.Open;
        if not IsReloading then
        begin
          ApplyPKInfo;
          ApplyLinksInfo;
        end;
        ApplyFieldInfo;
      finally
        GetWorkItem.Root.EventTopics[ET_ENTITY_VIEW_OPEN_FINISH].Fire;
      end;
    finally
      FDataSet.EnableControls;
    end;
  end;
end;

class function TEntityView.ProviderKind: TProviderNameBuilder.TProviderKind;
begin
  Result := pkEntityView;
end;

procedure TEntityView.ReloadRecord(APrimaryKeyValues: Variant; SyncRecord: boolean);
var
  cloneDS: TClientDataSet;
  RequestDS: TClientDataSet;
  RequestDSParams: OleVariant;
  P: TParam;
  PName: string;
  PValue: Variant;
  Field: TField;
  I: integer;

  function GetPrimayKevValueCount: integer;
  begin
    if VarIsArray(APrimaryKeyValues) then
      Result := VarArrayHighBound(APrimaryKeyValues, 1)
    else if not VarIsEmpty(APrimaryKeyValues) then
      Result := 1
    else
      Result := 0;
  end;

begin
  if (not GetDataSet.Active) or VarIsEmpty(APrimaryKeyValues) then Exit;

  if FPrimaryKeys.Count = 0 then
    raise Exception.CreateFmt('Primary key for %s.%s not setting', [GetEntityName, GetAttrName]);

  if FPrimaryKeys.Count <> GetPrimayKevValueCount then
    raise Exception.CreateFmt('Bad count primary key values for %s.%s ', [GetEntityName, GetAttrName]);

  cloneDS := TClientDataSet.Create(nil);
  try
    cloneDS.RemoteServer := GetDataSet.RemoteServer;
    cloneDS.ProviderName := GetDataSet.ProviderName;
    if GetDataSet.HasAppServer then
      cloneDS.AppServer := GetDataSet.AppServer;

    cloneDS.CloneCursor(GetDataSet, false);

    cloneDS.Params.Assign(GetDataSet.Params);
    cloneDS.Params.AssignValues(GetDataSet.Params);

    for I := 0 to FPrimaryKeys.Count -1 do
    begin
      if VarIsArray(APrimaryKeyValues) then
        PValue := APrimaryKeyValues[I]
      else
        PValue := APrimaryKeyValues;

      PName := FPrimaryKeys[I];
      P := cloneDS.Params.FindParam(PName);
      if P = nil then
        cloneDS.Params.CreateParam(ftUnknown, PName, ptInput).Value := PValue
      else
        P.Value := PValue;
    end;

    RequestDS := TClientDataSet.Create(nil);
    try
     // cloneDS.LogChanges := false; заменил на MergeChangeLog, c LogChanges=false были проблемы (operation not applicable etc.)

      RequestDSParams := VarArrayCreate([0, 1], varVariant);
      RequestDSParams[0] := Ord(erkReloadRecord);
      RequestDSParams[1] := PackageParams(cloneDS.Params);

      RequestDS.Data := cloneDS.DataRequest(RequestDSParams);

      if RequestDS.IsEmpty then
      begin
        if cloneDS.Locate(Info.PrimaryKey, APrimaryKeyValues, []) then
          cloneDS.Delete;
      end
      else
      begin

        if not cloneDS.Locate(Info.PrimaryKey, APrimaryKeyValues, []) then
        begin
          if cloneDS.IsEmpty then
            cloneDS.Append
          else
            cloneDS.Insert;

          SyncRecord := true;
        end
        else
          cloneDS.Edit;


        for I := 0 to RequestDS.FieldCount - 1 do
        begin
          Field := cloneDS.FindField(RequestDS.Fields[I].fieldName);
          if Assigned(Field) then
            Field.Value := RequestDS.Fields[I].Value;
        end;
        cloneDS.Post;


        if SyncRecord then
          GetDataSet.Locate(Info.PrimaryKey, APrimaryKeyValues, []);
      end;

    finally

      //if cloneDS.Active then cloneDS.LogChanges := true; //!!! for Source DS
      cloneDS.MergeChangeLog;
      
      RequestDS.Free;
    end;
  finally
    cloneDS.Free;
  end;


end;


procedure TEntityView.Save;
begin
  if GetDataSet.State in [dsEdit, dsInsert] then
    GetDataSet.Post;

  if not ImmediateSave then
  begin
    if GetDataSet.ChangeCount = 0 then Exit;

    CheckRequiredFields;
    if GetDataSet.ApplyUpdates(0) <> 0 then
      raise Exception.Create(GetLastUpdateErrorMessage);

    //DataChangedEventFire;
    ReloadLinksData;
  end;
end;


function TEntityView.SchemeInfo: IEntitySchemeInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).GetSchemeInfo(EntityInfo.SchemeName);
end;

function TEntityView.SchemeInfoDef: IEntitySchemeInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).GetSchemeInfo('');
end;

function TEntityView.EscapeString(const AValue: string): string;

  procedure AddChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 2, 1);
    Inc(AIndex, 2);
  end;

  procedure AddUnicodeChars(const AChars: string; var Dest: string; var AIndex: Integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 6, 1);
    Inc(AIndex, 6);
  end;

var
  i, ix: Integer;
  AChar: Char;
begin
  Result := AValue;
  ix := 1;
  for i := 1 to System.Length(AValue) do
  begin
    AChar :=  AValue[i];
    case AChar of
      '/', '\', '"':
      begin
        System.Insert('\', Result, ix);
        Inc(ix, 2);
      end;
      #8:  //backspace \b
      begin
        AddChars('\b', Result, ix);
      end;
      #9:
      begin
        AddChars('\t', Result, ix);
      end;
      #10:
      begin
        AddChars('\n', Result, ix);
      end;
      #12:
      begin
        AddChars('\f', Result, ix);
      end;
      #13:
      begin
        AddChars('\r', Result, ix);
      end;
      #0 .. #7, #11, #14 .. #31:
      begin
        AddUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
      end
      else
      begin
        if Word(AChar) > 127 then
        begin
          AddUnicodeChars('\u' + IntToHex(Word(AChar), 4), Result, ix);
        end
        else
        begin
          Inc(ix);
        end;
      end;
    end;
  end;

end;

procedure TEntityView.SynchronizeOnEntityChange(const AEntityName, AViewName,
   AFieldName: string);
var
  eventTopic: string;
begin
  if AFieldName = '' then
   eventTopic := format(ET_ENTITY_VIEW_RELOAD_LINKS_PK, [AEntityName, AViewName])
  else
   eventTopic := format(ET_ENTITY_VIEW_RELOAD_LINKS_LF, [AEntityName, AViewName, AFieldName]);

  if eventTopic <> '' then
    GetWorkItem.Root.EventTopics[eventTopic].
      AddSubscription(Self, DoSynchronizeOnEntityChange);
end;

function TEntityView.Title: string;
var
  RequestDS: TClientDataSet;
  RequestDSParams: OleVariant;
  RequestData: OleVariant;
begin
  Result := '';

  RequestDSParams := VarArrayCreate([0, 1], varVariant);
  RequestDSParams[0] := Ord(erkTitle);
  RequestDSParams[1] := PackageParams(GetDataSet.Params);

  RequestData := GetDataSet.DataRequest(RequestDSParams);

  if not VarIsEmpty(RequestData) then
  begin
    RequestDS := TClientDataSet.Create(nil);
    try
      RequestDS.Data := RequestData;
      if not RequestDS.IsEmpty then
        Result := RequestDS.Fields[0].AsString;
    finally
      RequestDS.Free;
    end;
  end;

end;

procedure TEntityView.UndoLastChange;
begin
  GetDataSet.UndoLastChange(true);
end;

function TEntityView.Info: IEntityViewInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).
      Entity[GetEntityName].Info.GetViewInfo(ViewName);
end;

function TEntityView.ViewName: string;
begin
  Result := GetAttrName;
end;

procedure TEntityView.ReloadLinksData;
var
  I: integer;
  eventData: Variant;
begin

  if (FPrimaryKeys.Count <> 0) and (not FDataSet.IsEmpty) then
  begin
    eventData := VarArrayCreate([0, FPrimaryKeys.Count], varVariant);
    for I := 0 to FPrimaryKeys.Count - 1 do
      eventData[I] := FDataSet[FPrimaryKeys[I]];

    GetWorkItem.Root.EventTopics[format(ET_ENTITY_VIEW_RELOAD_LINKS_PK,
        [FEntityName, ViewName])].Fire(eventData);
  end;

  eventData := Unassigned;//VarArrayCreate([0, FLinkedFields.Count], varVariant);
  for I := 0 to FLinkedFields.Count - 1 do
  begin
    if FDataSet.IsEmpty and Assigned(Params.FindParam(FLinkedFields[I])) then
      eventData := Params.ParamValues[FLinkedFields[I]]
    else if (not FDataSet.IsEmpty) and Assigned(FDataSet.FindField(FLinkedFields[I])) then
      eventData := FDataSet[FLinkedFields[I]]
    else
      eventData := Unassigned;

    if not VarIsEmpty(eventData) then
      GetWorkItem.Root.EventTopics[format(ET_ENTITY_VIEW_RELOAD_LINKS_LF,
        [FEntityName, ViewName, FLinkedFields[I]])].Fire(eventData);
  end;
end;

procedure TEntityView.CheckRequiredFields;
var
  I: integer;
  field: TField;
begin
  for I := 0 to FDataSet.FieldCount - 1 do
  begin
    field := FDataSet.Fields[I];
    if (GetFieldAttribute(field, FIELD_ATTR_REQUIRED) = '1') and
       (not field.ReadOnly) and field.Visible and field.IsNull then
    begin
      field.FocusControl;
      raise Exception.CreateFmt(ERROR_MSG_FIELD_REQUIRE, [field.DisplayLabel]);
    end;
  end;
end;

{ TEntityOper }

function TEntityOper.Execute(AParams: array of variant): TDataSet;
var
  I: integer;
begin
  {Result := GetDataSet;
  if OperInfo.IsSelect then
    Open(AParams)
  else
    Exec(AParams);}

  for I := 0 to High(AParams) do
    if Params.Count > I then
        Params[I].Value := AParams[I];

  Result := Execute;
end;

function TEntityOper.Execute: TDataSet;

  function FormatExceptMessage(AMessage: string): string;
  var
    strList: TStringList;
  begin
    strList := TStringList.Create;
    try
      strList.Text := AMessage;
      if strList.Count > 0 then
        strList.Delete(0);
      Result := strList.Text;
    finally
      strList.Free;
    end;
  end;

const
  EXCEPTION_TEXT = 'exception';
begin
  Result := FDataSet;

  if FDataSet.Active then FDataSet.Close;

  try
    if Info.IsExec then
      FDataSet.Execute
    else
      FDataSet.Open;
  except
    on E: Exception do
    begin
      if Pos(EXCEPTION_TEXT, E.Message) = 1 then
        raise Exception.Create(FormatExceptMessage(E.Message))
      else
        raise;
    end;
  end;
end;

function TEntityOper.Info: IEntityViewInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).
      Entity[FEntityName].Info.GetViewInfo(OperName);
end;

function TEntityOper.OperName: string;
begin
  Result := GetAttrName;
end;

class function TEntityOper.ProviderKind: TProviderNameBuilder.TProviderKind;
begin
  Result := pkEntityOper;
end;

function TEntityOper.ResultData: TDataSet;
begin
  Result := GetDataSet;  
end;

{ TEntityAttr }

procedure TEntityAttr.AfterImmediateApplyUpdates(Sender: TObject);
begin

end;

constructor TEntityAttr.Create(AConnection: TCustomRemoteServer;
  const AEntityName, AttrName: string; AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FAttrName := AttrName;
  FWorkItem := AWorkItem;
  FDataSet := TEntityDataSet.Create(Self);//TClientDataSet.Create(Self);
  FDataSet.RemoteServer := AConnection;
  FDataSet.ProviderName := DAL.TProviderNameBuilder.Encode(ProviderKind,
    FEntityName, AttrName);
  FDataSet.OnAfterImmediateApplyUpdates := AfterImmediateApplyUpdates;
  FParamsFetched := false;
  SetImmediateSave(false);
end;

destructor TEntityAttr.Destroy;
begin
  inherited;
end;

function TEntityAttr.GetAttrName: string;
begin
  Result := FAttrName;
end;

function TEntityAttr.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

function TEntityAttr.GetEntityName: string;
begin
  Result := FEntityName;
end;

function TEntityAttr.GetImmediateSave: boolean;
begin
  Result := FImmediateSave;
end;

function TEntityAttr.GetLastUpdateErrorMessage: string;
begin
  Result := FUpdateErrorText; 
end;

function TEntityAttr.GetWorkItem: TWorkItem;
begin
  Result := FWorkItem;
end;

procedure TEntityAttr.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
{  if (Operation = opRemove) and (AComponent = FView) then
  begin
    //if Assigned(FForm) and (not FClosing) then FForm.Close;

  //  FView.Parent := nil;

    FView := nil;
    //Free;
  end;
 }
end;

function TEntityAttr.Params: TParams;
begin
  if not FParamsFetched then
  begin
    FDataSet.FetchParams;
    FParamsFetched := true;
  end;

  Result := FDataSet.Params;
end;

procedure TEntityAttr.ParamsBind(const ABindingRule: string);
var
  I: integer;
  bindingList: TStringList;
  sName: string;
begin

  bindingList := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(ABindingRule), bindingList);

    for I := 0 to Params.Count - 1 do
    begin

      if Params[I].Name = 'APP_VER' then
      begin
        Params[I].Value := APP_VER;
        Continue;
      end;

      if bindingList.Count = 0 then
        sName := Params[I].Name
      else
        sName := bindingList.Values[Params[I].Name];

      if sName = '' then Continue;

      Params[I].Value := FWorkItem.State[sName];
    end;

  finally
    bindingList.Free;
  end;

end;

class function TEntityAttr.ProviderKind: TProviderNameBuilder.TProviderKind;
begin
  Result := pkNone;
end;

procedure TEntityAttr.ReconcileErrorHandler(DataSet: TCustomClientDataSet;
  E: EReconcileError; UpdateKind: TUpdateKind;
  var Action: TReconcileAction);
begin
  Action := raAbort;
  FUpdateErrorText := E.Message;
end;

procedure TEntityAttr.SetImmediateSave(Value: boolean);
begin
  FImmediateSave := Value;
  FDataSet.SetImmediateApplyUpdates(FImmediateSave);
  if not FImmediateSave then
    FDataSet.OnReconcileError := ReconcileErrorHandler;
end;

procedure TEntityAttr.SetProvider(ARemoteServer: TCustomRemoteServer;
  const AProviderName: string);
begin
  FDataSet.ProviderName := AProviderName;
  FDataSet.RemoteServer := ARemoteServer;
end;

{ TEntityDataSet }

constructor TEntityDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.OnReconcileError := ReconcileErrorHandler;
  FMasterLink := TEntityDataSetMasterLink.Create(Self);
end;

destructor TEntityDataSet.Destroy;
begin
  FMasterLink.Free;
  inherited;
end;

procedure TEntityDataSet.DoAfterDelete;
begin
  inherited;
  if FImmediateApplyUpdates and (ApplyUpdates(0) <> 0) then
  begin
    UndoLastChange(true);
    raise Exception.Create(FUpdateErrorText);
  end;
end;

procedure TEntityDataSet.DoAfterInsert;
var
  RequestDS: TClientDataSet;
  RequestDSParams: OleVariant;
  Field: TField;
  I: integer;
  RequestData: OleVariant;
  fieldReadOnlyState: boolean;
begin
  inherited;
  RequestDSParams := VarArrayCreate([0, 1], varVariant);
  RequestDSParams[0] := Ord(erkInsertDefaults);
  RequestDSParams[1] := PackageParams(Self.Params);

  RequestData := Self.DataRequest(RequestDSParams);

  if not VarIsEmpty(RequestData) then
  begin
     RequestDS := TClientDataSet.Create(nil);
    try
      RequestDS.Data := RequestData;
      if not RequestDS.IsEmpty then
        for I := 0 to RequestDS.FieldCount - 1 do
        begin
          Field := Self.FindField(RequestDS.Fields[I].fieldName);
          if Assigned(Field) then
          begin
            fieldReadOnlyState := Field.ReadOnly;
            Field.ReadOnly := false;
            Field.Value := RequestDS.Fields[I].Value;
            Field.ReadOnly := fieldReadOnlyState;
          end;
        end;
    finally
      RequestDS.Free;
    end;
  end;
end;

procedure TEntityDataSet.DoBeforeOpen;
begin
  inherited;
  SetParamsFromMaster;
end;

function TEntityDataSet.DSProxy_GetCommandText: string;
begin
  Result := Self.CommandText;
end;

function TEntityDataSet.DSProxy_GetDataSet: TDataSet;
begin
  Result := Self;
end;

function TEntityDataSet.DSProxy_GetMaster: TDataSource;
begin
  Result := FMasterLink.DataSource;
end;

function TEntityDataSet.DSProxy_GetParams: TParams;
begin
  Result := Self.Params;
end;

procedure TEntityDataSet.DSProxy_SetCommandText(const AValue: string);
begin
  Self.CommandText := AValue;
end;

procedure TEntityDataSet.DSProxy_SetMaster(ADataSource: TDataSource);
begin
  FMasterLink.DataSource := ADataSource;
end;

procedure TEntityDataSet.Post;
begin
  inherited;
  if FImmediateApplyUpdates then
  begin
    if ApplyUpdates(0) <> 0 then
    begin
      UndoLastChange(true);
      raise Exception.Create(FUpdateErrorText);
    end;

    if Assigned(FOnAfterImmediateApplyUpdates) then
      FOnAfterImmediateApplyUpdates(Self);
  end;
end;

procedure TEntityDataSet.ReconcileErrorHandler(DataSet: TCustomClientDataSet;
  E: EReconcileError; UpdateKind: TUpdateKind;
  var Action: TReconcileAction);
begin
  Action := raAbort;
  FUpdateErrorText := E.Message;
end;

procedure TEntityDataSet.SetImmediateApplyUpdates(const Value: boolean);
begin
  FImmediateApplyUpdates := Value;
  if FImmediateApplyUpdates then
    Self.OnReconcileError := ReconcileErrorHandler;
end;

procedure TEntityDataSet.SetParamsFromMaster;
var
  I: Integer;
  DataSet: TDataSet;
begin
  if FMasterLink.DataSource <> nil then
  begin
    DataSet := FMasterLink.DataSource.DataSet;
    if DataSet <> nil then
    begin
      DataSet.FieldDefs.Update;
      for I := 0 to Params.Count - 1 do
        with Params[I] do
          if not Bound then
          begin
            AssignField(DataSet.FieldByName(Name));
            Bound := False;
          end;
    end;
  end;

end;


{ TEntityMasterLink }

procedure TEntityDataSetMasterLink.ActiveChanged;
begin
  if FDataSet.Active then ReOpen;
end;

procedure TEntityDataSetMasterLink.CheckBrowseMode;
begin
  if FDataSet.Active then FDataSet.CheckBrowseMode;
end;

constructor TEntityDataSetMasterLink.Create(ADataSet: TDataSet);
begin
  FDataSet := ADataSet;
end;

function TEntityDataSetMasterLink.GetDetailDataSet: TDataSet;
begin
  Result := FDataSet;
end;

procedure TEntityDataSetMasterLink.RecordChanged(Field: TField);
begin
  if (Field = nil) and FDataSet.Active then ReOpen;
end;

procedure TEntityDataSetMasterLink.ReOpen;
var
  DataSet: TDataSet;
begin
  FDataSet.DisableControls;
  try
    if Self.DataSource <> nil then
    begin
      DataSet := Self.DataSource.DataSet;
      if DataSet <> nil then
        if DataSet.Active and (DataSet.State <> dsSetKey) then
        begin
          FDataSet.Close;
          FDataSet.Open;
        end;
    end;
  finally
    FDataSet.EnableControls;
  end;



end;

{ TEntitySchemeInfo }

constructor TEntitySchemeInfo.Create(AOwner: TComponent; AConnection: TCustomRemoteServer);
begin
  inherited Create(AOwner);
  FConnection := AConnection;
  FFields := TFields.Create(nil);
end;

destructor TEntitySchemeInfo.Destroy;
begin
  FFields.Free;
  inherited;
end;

function TEntitySchemeInfo.Fields: TFields;
begin
  Result := FFields;
end;

procedure TEntitySchemeInfo.LoadInfo;
begin
  LoadFieldsInfo(FFields, FConnection, FSchemeName, '-');
end;

{ TEntityInfo }

constructor TEntityInfo.Create(const AEntityName: string; AConnection: TCustomRemoteServer);
begin
  inherited Create(nil);

  FEntityName := AEntityName;

  FFields := TFields.Create(nil);
  FOptions := TStringList.Create;

  FMetaDS := TEntityDataSet.Create(Self);
  FMetaDS.CommandText := ENT_METADATA_ENTITY;
  FMetaDS.ProviderName := METADATA_PROVIDER;
  FMetaDS.RemoteServer := AConnection;
  FMetaDS.Params.AddParameter.Name := 'EntityName';

  FViewInfoDictionary := TDictionary<string, TEntityViewInfo>.Create;
end;

destructor TEntityInfo.Destroy;
begin
  FFields.Free;
  FOptions.Free;
  FViewInfoDictionary.Free;

  inherited;
end;

function TEntityInfo.Fields: TFields;
begin
  Result := FFields;
end;

function TEntityInfo.GetOptions(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

function TEntityInfo.GetViewInfo(const AViewName: string): TEntityViewInfo;
var
  item: TEntityViewInfo;
  doLoadInfo: boolean;
begin

  doLoadInfo := NoCacheMetadata;

  if not FViewInfoDictionary.TryGetValue(AViewName, item) then
  begin
    item := TEntityViewInfo.Create(Self, FMetaDS.RemoteServer);
    item.FEntityName := FEntityName;
    item.FViewName := AViewName;
    FViewInfoDictionary.Add(AViewName, item);
    doLoadInfo := true;
  end;

  if doLoadInfo then item.LoadInfo;

  Result := item;
end;

function TEntityInfo.GetViewInfoIntf(const AViewName: string): IEntityViewInfo;
begin
  Result := GetViewInfo(AViewName) as IEntityViewInfo;
end;

procedure TEntityInfo.LoadInfo;
begin
  FMetaDS.Close;
  FMetaDS.Params.ParamValues['EntityName'] := FEntityName;
  FMetaDS.Open;
  if not FMetaDS.IsEmpty then
  begin
    FSchemeName := VarToStr(FMetaDS['SCHEMENAME']);
  end;

  LoadFieldsInfo(FFields, FMetaDS.RemoteServer, FEntityName, '-');
end;

function TEntityInfo.SchemeName: string;
begin
  Result := FSchemeName;
end;

procedure TEntityInfo.SetOptions(const AName, AValue: string);
begin
  FOptions.Values[AName] := AValue;
end;

function TEntityInfo.ViewExists(const AViewName: string): boolean;
begin
  Result := GetViewInfo(AViewName).ViewExists;
end;


{ TEntityViewInfo }

constructor TEntityViewInfo.Create(AOwner: TComponent;
  AConnection: TCustomRemoteServer);
begin
  inherited Create(AOwner);

  FOptions := TStringList.Create;

  FMetaDS := TEntityDataSet.Create(Self);
  FMetaDS.CommandText := ENT_METADATA_VIEW;
  FMetaDS.ProviderName := METADATA_PROVIDER;
  FMetaDS.RemoteServer := AConnection;
  FMetaDS.Params.AddParameter.Name := 'EntityName';
  FMetaDS.Params.AddParameter.Name := 'ViewName';

  FFields := TFields.Create(nil);

  FLinkInfoDictionary := TObjectList<TEntityViewLinkInfo>.Create(true);
  FLinkedFields := TStringList.Create;
end;

destructor TEntityViewInfo.Destroy;
begin
  FOptions.Free;
  FFields.Free;
  FLinkInfoDictionary.Free;
  FLinkedFields.Free;
  inherited;
end;

function TEntityViewInfo.Fields: TFields;
begin
  Result := FFields;
end;

function TEntityViewInfo.GetLinksInfo(AIndex: integer): TEntityViewLinkInfo;
begin
  Result := FLinkInfoDictionary.Items[AIndex];
end;

function TEntityViewInfo.GetOptions(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

function TEntityViewInfo.IsExec: boolean;
begin
  Result := FIsExec;
end;

function TEntityViewInfo.LinkedFields: TStringList;
begin
  Result := FLinkedFields;
end;

function TEntityViewInfo.LinksCount: integer;
begin
  Result := FLinkInfoDictionary.Count;
end;

procedure TEntityViewInfo.LoadInfo;
var
  I: integer;
  linkInfo: TEntityViewLinkInfo;
begin
  FMetaDS.Close;
  FMetaDS.CommandText := ENT_METADATA_VIEW;
  FMetaDS.Params.Clear;
  FMetaDS.Params.AddParameter.Name := 'EntityName';
  FMetaDS.Params.AddParameter.Name := 'ViewName';
  FMetaDS.Params.ParamValues['EntityName'] := FEntityName;
  FMetaDS.Params.ParamValues['ViewName'] := FViewName;
  FMetaDS.Open;

  FOptions.Clear;
  if not FMetaDS.IsEmpty then
  begin
    FViewExists := true;
    FReadOnly := FMetaDS['ReadOnly'] = 1;
    FPrimaryKey := VarToStr(FMetaDS['PKEY']);
    FTitle := VarToStr(FMetaDS['TITLE']);
    if FPrimaryKey = '' then
      FPrimaryKey := CONST_PRIMARYKEY_NAME_DEFAULT;
    FIsExec := FMetaDS['IS_EXEC'] = 1;
    ExtractStrings([';'], [], PWideChar(VarToStr(FMetaDS['OPTIONS'])), FOptions);
  end
  else
    FViewExists := false;

  LoadFieldsInfo(FFields, FMetaDS.RemoteServer, FEntityName, FViewName);

  if ReadOnly then
    for I := 0 to Fields.Count - 1 do
      Fields[I].ReadOnly := true;


  FLinkInfoDictionary.Clear;
  FMetaDS.Close;
  FMetaDS.CommandText := ENT_METADATA_VIEW_LINKS;
  FMetaDS.Params.Clear;
  FMetaDS.Params.AddParameter.Name := 'EntityName';
  FMetaDS.Params.AddParameter.Name := 'ViewName';
  FMetaDS.Params.ParamValues['EntityName'] := FEntityName;
  FMetaDS.Params.ParamValues['ViewName'] := FViewName;
  FMetaDS.Open;
  while not FMetaDS.Eof do
  begin
    linkInfo := TEntityViewLinkInfo.Create;
    linkInfo.EntityName := VarToStr(FMetaDS['linked_entityname']);
    linkInfo.ViewName := VarToStr(FMetaDS['linked_viewname']);
    linkInfo.FieldName := VarToStr(FMetaDS['linked_field']);
    FLinkInfoDictionary.Add(linkInfo);
    FMetaDS.Next;
  end;

  FLinkedFields.Clear;
  FMetaDS.Close;
  FMetaDS.CommandText := ENT_METADATA_VIEW_LINKEDFIELDS;
  FMetaDS.Params.Clear;
  FMetaDS.Params.AddParameter.Name := 'EntityName';
  FMetaDS.Params.AddParameter.Name := 'ViewName';
  FMetaDS.Params.ParamValues['EntityName'] := FEntityName;
  FMetaDS.Params.ParamValues['ViewName'] := FViewName;
  FMetaDS.Open;
  while not FMetaDS.Eof do
  begin
    FLinkedFields.Add(VarToStr(FMetaDS['linked_field']));
    FMetaDS.Next;
  end;

end;

function TEntityViewInfo.OptionExists(const AName: string): boolean;
begin
  Result := (FOptions.IndexOfName(AName) <> -1) or (FOptions.IndexOf(AName) <> -1);
end;

function TEntityViewInfo.PrimaryKey: string;
begin
  Result := FPrimaryKey;
end;

function TEntityViewInfo.ReadOnly: boolean;
begin
  Result := FReadOnly;
end;

function TEntityViewInfo.Title: string;
begin
  Result := FTitle;
end;

function TEntityViewInfo.ViewExists: boolean;
begin
  Result := FViewExists;
end;

initialization
  NoCacheMetadata := FindCmdLineSwitch('NoCacheMetadata');
  InitAppVer;

end.
