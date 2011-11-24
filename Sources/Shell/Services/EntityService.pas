unit EntityService;

interface

uses
  SysUtils, Classes, ConfigServiceIntf, EntityServiceIntf, Contnrs, ComObj,
  DBClient, CoreClasses, db, Variants;

const
  ENT_SETTING = 'INF_SETTING';
  ENT_SETTING_VIEW_META = 'META';
  ENT_SETTING_VIEW_GET = 'GET';
  ENT_SETTING_OPER_SET = 'SET';
  ENT_SETTING_VIEW_CHECK = 'CHECK';

  ET_ENTITY_VIEW_RELOAD_LINKS_PK = 'entity://view_reload_links_pk_%s_%s';
  ET_ENTITY_VIEW_RELOAD_LINKS_LF = 'entity://view_reload_links_lf_%s_%s_%s';

  ERROR_MSG_FIELD_REQUIRE = 'ѕоле ''''%s'''' об€зательно дл€ заполнени€';

type
  TEntityDataSet = class(TClientDataSet)
  private
    FUpdateErrorText: string;
    FImmediateApplyUpdates: boolean;
    procedure SetImmediateApplyUpdates(const Value: boolean);
    procedure ReconcileErrorHandler(DataSet: TCustomClientDataSet;
      E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
  protected
    procedure DoAfterDelete; override;
    procedure DoAfterInsert; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Post; override;
    property ImmediateApplyUpdates: boolean read FImmediateApplyUpdates
      write SetImmediateApplyUpdates;
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
    procedure ParamsBind(Source: TWorkItem = nil);
    function GetLastUpdateErrorMessage: string;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(const AEntityName, AttrName: string;
      AWorkItem: TWorkItem); reintroduce; virtual;
    destructor Destroy; override;
    procedure SetProvider(ARemoteServer: TCustomRemoteServer;
      const AProviderName: string);
    property ImmediateSave: boolean read FImmediateSave write SetImmediateSave;
  end;


  TEntityView = class(TEntityAttr, IEntityView)
  private
    FDataSetInitialized: boolean;

    FPrimaryKeys: TStringList;
    FPrimaryKeysParsed: boolean;
    FLinkedFields: TStringList;
    function GetPrimaryKeys: TStrings;
    procedure ApplyFieldInfo;
    procedure ApplyLinksInfo;
    procedure InitDataSetAttributes;
    procedure CheckLoaded;

    procedure DoSynchronizeOnEntityChange(EventData: Variant);

    function EntityInfo: IEntityInfo;
    function SchemeInfo: IEntitySchemeInfo;
    function SchemeInfoDef: IEntitySchemeInfo;
    procedure CheckRequiredFields;
  protected
    //IEntityView
    function IEntityView.EntityName = GetEntityName;
    function ViewName: string;
    function DataSet: TDataSet;
    function IsModified: boolean;
    function IsLoaded: boolean;
    function ViewInfo: IEntityViewInfo;
    function Load(AWorkItem: TWorkItem; AReload: boolean = true): TDataSet; overload;
    function Load(AParams: array of variant): TDataSet; overload;
    function Load: TDataSet; overload;
    procedure Reload;
    procedure ReloadRecord(APrimaryKeyValues: Variant; SyncRecord: boolean = false);
    procedure ReloadLinksData;
    procedure Save;
    procedure UndoLastChange;
    procedure CancelUpdates;
    function GetValue(const AName: string): Variant;
    procedure SetValue(const AName: string; AValue: Variant);

    procedure SynchronizeOnEntityChange(const AEntityName, AViewName: string;
      ALinkKind: TEntityViewLinkKind = lkPK; const AFieldName: string = '');

  public
    constructor Create(const AEntityName, AttrName: string;
      AWorkItem: TWorkItem); override;
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
    function OperInfo: IEntityOperInfo;
  end;

  TEntity = class(TComponent, IEntity)
  private
    FConnection: IEntityStorageConnection;
    FEntityName: string;
  protected
    //IEntity
    function EntityName: string;
    function GetView(const AViewName: string; AWorkItem: TWorkItem;
      AInstanceID: string = ''): IEntityView;
    function GetOper(const AOperName: string; AWorkItem: TWorkItem;
      AInstanceID: string = ''): IEntityOper;
    function EntityInfo: IEntityInfo;
  public
    constructor Create(const AEntityName: string;
      AConnection: IEntityStorageConnection); reintroduce;
  end;


  TEntityStorageSettings = class(TComponent, IEntityStorageSettings)
  private
    FWorkItem: TWorkItem;
    function GetUserID: string;
    procedure SettingsDataChangedHandler(AField: TField);
    procedure LoadSettingValue(AField: TField; APreferences: boolean);
    procedure SaveSettingValue(AField: TField; APreferences: boolean);
    procedure CheckSettingValue(AField: TField; APreferences: boolean);
    function GetSettingsData(AWorkItem: TWorkItem; APreferences: boolean): TDataSet;
  protected
    function GetUserPreferences(AWorkItem: TWorkItem): TDataSet;
    function GetCommonSettings(AWorkitem: TWorkItem): TDataSet;

    function GetValue(const AName: string): Variant;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;

  end;

  TEntityService = class(TComponent, IEntityService)
  private
    FWorkItem: TWorkItem;
    FConnection: TComponent;
    FEntities: TComponentList;
    FSettings: TEntityStorageSettings;
    FFactories: TComponentList;
  protected
    //IEntityManagerService
    procedure ClearConnectionCache;
    function EntityExists(const AEntityName: string): boolean;
    function EntityViewExists(const AEntityName, AEntityViewName: string): boolean;
    function GetEntity(const AEntityName: string): IEntity;
    function GetSettings: IEntityStorageSettings;

    function Connection: IEntityStorageConnection;
    procedure Connect(const AConnectionEngine, AConnectionParams: string);
    procedure Disconnect;

    procedure RegisterConnectionFactory(Factory: TComponent);

  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;


implementation

{ TEntityManagerService }

procedure TEntityService.ClearConnectionCache;
var
  I: integer;
begin
  for I := FEntities.Count -1 downto 0 do  FEntities.Delete(I);
end;

procedure TEntityService.Connect(const AConnectionEngine,
  AConnectionParams: string);
var
  paramList: TStringList;
  Intf: IEntityStorageConnection;
  I: integer;
  Factory: IEntityStorageConnectionFactory;
  ConnectionID: string;
begin
  Disconnect;

  paramList := TStringList.Create;
  try
    ExtractStrings([';'], [], PChar(AConnectionParams), paramList);

    for I := 0 to FFactories.Count - 1 do
    begin
      FFactories[I].GetInterface(IEntityStorageConnectionFactory, Factory);
      if SameText(Factory.Engine, AConnectionEngine) then
      begin
        FConnection := Factory.CreateConnection(ConnectionID, paramList);
        if FConnection <> nil then Break;
      end;
    end;
  finally
    paramList.Free;
  end;

  if FConnection = nil then
    raise Exception.CreateFmt('Connection factory for engine %s not found.', [AConnectionEngine]);

  if not FConnection.GetInterface(IEntityStorageConnection, Intf) then
  begin
    FConnection := nil;
    raise Exception.Create('Bad connection class');
  end;

  (FConnection as IEntityStorageConnection).Connect;

end;

function TEntityService.Connection: IEntityStorageConnection;
begin
  Result := FConnection as IEntityStorageConnection;
end;

constructor TEntityService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FFactories := TComponentList.Create(false);
  FEntities := TComponentList.Create(True);
  FSettings := TEntityStorageSettings.Create(Self, FWorkItem);
end;

destructor TEntityService.Destroy;
begin
  FEntities.Free;
  FFactories.Free;
  inherited;
end;

procedure TEntityService.Disconnect;
begin
  ClearConnectionCache;

  if FConnection <> nil then
    (FConnection as IEntityStorageConnection).Disconnect;

  FConnection := nil;
end;

function TEntityService.EntityExists(
  const AEntityName: string): boolean;
begin
  Result := true;
end;

function TEntityService.EntityViewExists(
  const AEntityName, AEntityViewName: string): boolean;
begin
  Result := GetEntity(AEntityName).EntityInfo.ViewExists(AEntityViewName);
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


  if (FConnection as IEntityStorageConnection).GetEntityList.IndexOf(AEntityName) = - 1 then
    raise Exception.CreateFmt('Entity %s not found', [AEntityName]);

  Ent := TEntity.Create(AEntityName, FConnection as IEntityStorageConnection);
  FEntities.Add(Ent);
  Ent.GetInterface(IEntity, Result);
end;



function TEntityService.GetSettings: IEntityStorageSettings;
begin
  Result := FSettings as IEntityStorageSettings;
end;

procedure TEntityService.RegisterConnectionFactory(Factory: TComponent);
var
  Intf: IEntityStorageConnectionFactory;
begin
  if not Factory.GetInterface(IEntityStorageConnectionFactory, Intf) then
    raise Exception.Create('Bad connection factory');

  FFactories.Add(Factory);

end;


{ TEntity }

constructor TEntity.Create(const AEntityName: string; AConnection: IEntityStorageConnection);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FConnection := AConnection;
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

  view := TEntityView.Create(FEntityName, AViewName, AWorkItem);

  viewProviderName :=
    FConnection.GetEntityViewProviderName(FEntityName, AViewName);

  if viewProviderName = '' then
  begin
    view.Free;
    raise Exception.CreateFmt('Entity View %s for entity %s not found',
        [AViewName, FEntityName]);
  end;

  view.SetProvider(TCustomRemoteServer(FConnection.ConnectionComponent),
      viewProviderName);


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

  oper := TEntityOper.Create(FEntityName, AOperName, AWorkItem);

  operProviderName :=
    FConnection.GetEntityOperProviderName(FEntityName, AOperName);
  if operProviderName = '' then
  begin
    oper.Free;
    raise Exception.CreateFmt('Entity operation %s for entity %s not found',
      [AOperName, FEntityName]);
  end;
  oper.SetProvider(TCustomRemoteServer(FConnection.ConnectionComponent),
    operProviderName);

  AWorkItem.Items.Add(operID, oper);

  oper.GetInterface(IEntityOper, Result);
end;

function TEntity.EntityInfo: IEntityInfo;
begin
  Result := FConnection.GetEntityInfo(FEntityName);
end;

{ TEntityView }

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
  dsReadOnly: boolean;
begin
  eInfo := EntityInfo;
  vInfo := ViewInfo;
  smInfo := SchemeInfo;
  smInfoDef := SchemeInfoDef;

  dsReadOnly := GetDataSetAttribute(GetDataSet, DATASET_ATTR_READONLY) = 'Yes';

  for I := 0 to GetDataSet.FieldCount - 1 do
  begin
    F := GetDataSet.Fields[I];

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

    if (not F.ReadOnly) and F.Required then
    begin
      SetFieldAttribute(F, FIELD_ATTR_REQUIRED, '1');
      F.Required := false; //отключаю стандартную обработку
    end;

    if F is TFloatField then
    begin
      TFloatField(F).DisplayFormat := ',##0.00';
      //currency := true;
    end
  end;

end;

procedure TEntityView.ApplyLinksInfo;
var
  I: integer;
  linkInfo: TEntityViewLinkInfo;
begin
  for I := 0 to ViewInfo.LinksCount -1 do
  begin
    linkInfo := ViewInfo.GetLinksInfo(I);
    SynchronizeOnEntityChange(linkInfo.EntityName, linkInfo.ViewName,
      linkInfo.LinkKind, linkInfo.FieldName);
  end;
  FLinkedFields.Clear;
  FLinkedFields.AddStrings(ViewInfo.LinkedFields);
end;

procedure TEntityView.CancelUpdates;
begin
  GetDataSet.CancelUpdates;
end;

procedure TEntityView.CheckLoaded;
begin
  if not IsLoaded then
    raise Exception.CreateFmt('Entity view %s not loaded', [ViewName]);
end;

constructor TEntityView.Create(const AEntityName, AttrName: string;
  AWorkItem: TWorkItem);
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

procedure TEntityView.DoSynchronizeOnEntityChange(EventData: Variant);
begin
  ReloadRecord(EventData);
end;

function TEntityView.EntityInfo: IEntityInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).
     Entity[GetEntityName].EntityInfo;
end;


function TEntityView.GetPrimaryKeys: TStrings;
begin
  if not FPrimaryKeysParsed then
  begin
    ExtractStrings([';'], [], PChar(ViewInfo.PrimaryKey), FPrimaryKeys);
    FPrimaryKeysParsed := true;
  end;
  Result := FPrimaryKeys;
end;

function TEntityView.GetValue(const AName: string): Variant;
begin
  CheckLoaded;
  Result := FDataSet.FieldValues[AName];
end;


procedure TEntityView.InitDataSetAttributes;
begin
  SetDataSetAttribute(GetDataSet, DATASET_ATTR_ENTITY, GetEntityName);
  SetDataSetAttribute(GetDataSet, DATASET_ATTR_ENTITY_VIEW, ViewName);

  SetDataSetAttribute(GetDataSet, DATASET_ATTR_PRIMARYKEY, ViewInfo.PrimaryKey);
  if ViewInfo.ReadOnly then
    SetDataSetAttribute(GetDataSet, DATASET_ATTR_READONLY, 'Yes')
  else
    SetDataSetAttribute(GetDataSet, DATASET_ATTR_READONLY, 'No');
end;

function TEntityView.IsLoaded: boolean;
begin
  Result := FDataSet.Active;
end;

function TEntityView.IsModified: boolean;
begin
  Result := GetDataSet.ChangeCount > 0;
end;

function TEntityView.Load(AParams: array of variant): TDataSet;
var
  I: integer;
begin

  for I := 0 to High(AParams) do
    if Params.Count > I then
        Params[I].Value := AParams[I];

  Result := Load;

end;

function TEntityView.Load: TDataSet;
begin
  Result := FDataSet;
  FDataSet.DisableControls;
  try
    if FDataSet.Active then
      FDataSet.Close;

    GetWorkItem.Root.EventTopics[ET_ENTITY_VIEW_OPEN_START].Fire;
    try
      FDataSet.Open;
      ApplyFieldInfo;
      ApplyLinksInfo;
    finally
      GetWorkItem.Root.EventTopics[ET_ENTITY_VIEW_OPEN_FINISH].Fire;
    end;
  finally
    FDataSet.EnableControls;
  end;


end;

procedure TEntityView.Reload;
begin
  GetDataSet.DisableControls;
  try
    if GetDataSet.Active then
      GetDataSet.Close;

    GetWorkItem.Root.EventTopics[ET_ENTITY_VIEW_OPEN_START].Fire;
    try
      GetDataSet.Open;
      ApplyFieldInfo;
    finally
      GetWorkItem.Root.EventTopics[ET_ENTITY_VIEW_OPEN_FINISH].Fire;
    end;
  finally
    GetDataSet.EnableControls;
  end;
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

  if GetPrimaryKeys.Count = 0 then
    raise Exception.CreateFmt('Primary key for view %s not setting', [GetAttrName]);

  if GetPrimaryKeys.Count <> GetPrimayKevValueCount then
    raise Exception.CreateFmt('Bad count primary key values for view %s ', [GetAttrName]);

  cloneDS := TClientDataSet.Create(nil);
  try
    cloneDS.RemoteServer := GetDataSet.RemoteServer;
    cloneDS.ProviderName := GetDataSet.ProviderName;
    if GetDataSet.HasAppServer then
      cloneDS.AppServer := GetDataSet.AppServer;

    cloneDS.CloneCursor(GetDataSet, false);

    cloneDS.Params.Assign(GetDataSet.Params);
    cloneDS.Params.AssignValues(GetDataSet.Params);

    for I := 0 to GetPrimaryKeys.Count -1 do
    begin
      if VarIsArray(APrimaryKeyValues) then
        PValue := APrimaryKeyValues[I]
      else
        PValue := APrimaryKeyValues;

      PName := GetPrimaryKeys[I];
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
        if cloneDS.Locate(ViewInfo.PrimaryKey, APrimaryKeyValues, []) then
          cloneDS.Delete;
      end
      else
      begin

        if not cloneDS.Locate(ViewInfo.PrimaryKey, APrimaryKeyValues, []) then
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
          GetDataSet.Locate(ViewInfo.PrimaryKey, APrimaryKeyValues, []);
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
    FWorkItem.Services[IEntityService]).Connection.GetSchemeInfo(EntityInfo.SchemeName);
end;

function TEntityView.SchemeInfoDef: IEntitySchemeInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).Connection.GetSchemeInfo('');
end;

procedure TEntityView.SetValue(const AName: string; AValue: Variant);
begin
  CheckLoaded;
  FDataSet.Edit;
  FDataSet.FieldValues[AName] := AValue;
  FDataSet.Post;
end;

procedure TEntityView.SynchronizeOnEntityChange(const AEntityName, AViewName: string;
  ALinkKind: TEntityViewLinkKind; const AFieldName: string);
var
  eventTopic: string;
begin
  case ALinkKind of
    lkPK:
      eventTopic := format(ET_ENTITY_VIEW_RELOAD_LINKS_PK, [AEntityName, AViewName]);
    lkLF:
      eventTopic := format(ET_ENTITY_VIEW_RELOAD_LINKS_LF, [AEntityName, AViewName, AFieldName]);
    else
      eventTopic := '';
  end;

  if eventTopic <> '' then
    GetWorkItem.Root.EventTopics[eventTopic].
      AddSubscription(Self, DoSynchronizeOnEntityChange);
end;

procedure TEntityView.UndoLastChange;
begin
  GetDataSet.UndoLastChange(true);
end;

function TEntityView.ViewInfo: IEntityViewInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).
      Entity[GetEntityName].EntityInfo.GetViewInfo(ViewName);
end;

function TEntityView.ViewName: string;
begin
  Result := GetAttrName;
end;

function TEntityView.Load(AWorkItem: TWorkItem;
  AReload: boolean): TDataSet;
var
  I: integer;
begin
  for I := 0 to Params.Count - 1 do
    Params[I].Value := AWorkItem.State[Params[I].Name];

  if (not IsLoaded) or AReload then Load;

  Result := DataSet;
end;


procedure TEntityView.ReloadLinksData;
var
  I: integer;
  eventData: Variant;
begin

  if (GetPrimaryKeys.Count <> 0) and (not FDataSet.IsEmpty) then
  begin
    eventData := VarArrayCreate([0, GetPrimaryKeys.Count], varVariant);
    for I := 0 to GetPrimaryKeys.Count - 1 do
      eventData[I] := GetValue(GetPrimaryKeys[I]);

    GetWorkItem.Root.EventTopics[format(ET_ENTITY_VIEW_RELOAD_LINKS_PK,
        [FEntityName, ViewName])].Fire(eventData);
  end;

  eventData := Unassigned;//VarArrayCreate([0, FLinkedFields.Count], varVariant);
  for I := 0 to FLinkedFields.Count - 1 do
  begin
    if FDataSet.IsEmpty and Assigned(Params.FindParam(FLinkedFields[I])) then
      eventData := Params.ParamValues[FLinkedFields[I]]
    else if (not FDataSet.IsEmpty) and Assigned(FDataSet.FindField(FLinkedFields[I])) then
      eventData := GetValue(FLinkedFields[I])
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
    if (GetFieldAttribute(field, FIELD_ATTR_REQUIRED) = '1') and (not field.ReadOnly) and field.IsNull then
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
begin
  Result := FDataSet;

  if FDataSet.Active then FDataSet.Close;

  if OperInfo.IsSelect then
    FDataSet.Open
  else
    FDataSet.Execute;
end;

function TEntityOper.OperInfo: IEntityOperInfo;
begin
  Result := IEntityService(
    FWorkItem.Services[IEntityService]).
      Entity[FEntityName].EntityInfo.GetOperInfo(OperName);
end;

function TEntityOper.OperName: string;
begin
  Result := GetAttrName;
end;

function TEntityOper.ResultData: TDataSet;
begin
  Result := GetDataSet;  
end;

{ TEntityAttr }

constructor TEntityAttr.Create(const AEntityName, AttrName: string;
  AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FEntityName := AEntityName;
  FAttrName := AttrName;
  FWorkItem := AWorkItem;
  FDataSet := TEntityDataSet.Create(Self);//TClientDataSet.Create(Self);
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

procedure TEntityAttr.ParamsBind(Source: TWorkItem);
var
  sourceWI: TWorkItem;
  I: integer;
begin
  sourceWI := Source;
  if not Assigned(sourceWI) then
    sourceWI := FWorkItem;

  for I := 0 to Params.Count - 1 do
    Params[I].Value := sourceWI.State[Params[I].Name];

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
  inherited;
  Self.OnReconcileError := ReconcileErrorHandler;
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

procedure TEntityDataSet.Post;
begin
  inherited;
  if FImmediateApplyUpdates and (ApplyUpdates(0) <> 0) then
  begin
    UndoLastChange(true);
    raise Exception.Create(FUpdateErrorText);
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

{ TEntityStorageSettings }

procedure TEntityStorageSettings.CheckSettingValue(AField: TField;
  APreferences: boolean);
var
  dsCheck: TDataSet;
  userID: string;
  checkVal: integer;

begin
  if APreferences then
    userID := GetUserID
  else
    userID := '';

  dsCheck := (FWorkItem.Services[IEntityService] as IEntityService).
    Entity[ENT_SETTING].GetView(ENT_SETTING_VIEW_CHECK, FWorkItem).
      Load([AField.Origin, userID]);

  if APreferences then
    checkVal := dsCheck['USER_EXISTS']
  else
    checkVal := dsCheck['COMMON_EXISTS'];

  AField.Tag := checkVal;
end;

constructor TEntityStorageSettings.Create(AOwner: TComponent;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
end;

function TEntityStorageSettings.GetCommonSettings(
  AWorkitem: TWorkItem): TDataSet;
begin
  Result := GetSettingsData(AWorkItem, false);
end;

function TEntityStorageSettings.GetSettingsData(AWorkItem: TWorkItem;
  APreferences: boolean): TDataSet;

const
  const_CommonSettings = '{11E1AF84-2F78-4D35-8B4C-2B5DA3C889F9}';
  const_PreferenceSettings = '{39AF0081-983A-43D2-BA1E-7C560CCB0F71}';


type
  TDBSettingType = (stNone, stInteger, stString, stNumber, stDate);

  function NormalizeComponentName(const AName: string): string;
  const
    Alpha = ['A'..'Z', 'a'..'z', '_'];
    AlphaNumeric = Alpha + ['0'..'9'];
  var
    I: Integer;
  begin
    Result := AName;
    for I := 1 to Length(Result) do
      if not CharInSet(Result[I], AlphaNumeric) then
        Result[I] := '_';
  end;

var
  svc: IEntityService;
  evMeta: IEntityView;
  dsMeta: TDataSet;
  instanceID: string;
  field: TField;
  I: integer;
  editorOptions: string;
  editorOptionsList: TStringList;
begin
  if APreferences then
    instanceID := const_CommonSettings
  else
    instanceID := const_PreferenceSettings;


  Result := AWorkItem.Items[instanceID, TClientDataSet] as TClientDataSet;
  if Assigned(Result) then Exit;

  Result := TClientDataSet.Create(AWorkItem);
  if APreferences then Result.Tag := 1;

  svc := FWorkItem.Services[IEntityService] as IEntityService;
  evMeta := svc.Entity[ENT_SETTING].GetView(ENT_SETTING_VIEW_META, FWorkItem);
  evMeta.Reload;
  dsMeta := evMeta.DataSet;
  dsMeta.First;
  while not dsMeta.Eof do
  begin
    if APreferences and (dsMeta['IS_PREFERENCE'] = 0) then
    begin
      dsMeta.Next;
      Continue;
    end;

    case TDBSettingType(dsMeta['TYP']) of
      stInteger: field := TIntegerField.Create(Result);
      stString: field := TStringField.Create(Result);
      stNumber: field := TFloatField.Create(Result);
      stDate: field := TDateTimeField.Create(Result);
    else
      field := TStringField.Create(Self);
    end;

    if field is TStringField then
    begin
      TStringField(field).DisplayWidth := 255;
      TStringField(field).Size := 255;
    end;

    field.DisplayLabel := dsMeta['TITLE'];
    field.Origin := dsMeta['NAME'];
    field.FieldName := NormalizeComponentName(dsMeta['NAME']);
    field.DataSet := Result;
    field.Alignment := taLeftJustify;

    if VarToStr(dsMeta['EDITOR']) <> '' then
    begin
      SetFieldAttribute(field, FIELD_ATTR_EDITOR, VarToStr(dsMeta['EDITOR']));

      editorOptions := VarToStr(dsMeta['EDITOR_OPTIONS']);
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
        SetFieldAttributeText(field, editorOptions);
      end;
    end;

    SetFieldAttribute(field, FIELD_ATTR_BAND, VarToStr(dsMeta['BAND']));
    dsMeta.Next;
  end;


  if Result.FieldCount > 0 then
  begin
    (Result as TClientDataSet).CreateDataSet;
    Result.Insert;
    Result.Post;
    Result.Edit;
    for I := 0 to Result.FieldCount - 1 do
    begin
      LoadSettingValue(Result.Fields[I], APreferences);
      CheckSettingValue(Result.Fields[I], APreferences);
      Result.Fields[I].OnChange := SettingsDataChangedHandler;
    end;
    Result.Post;
  end;

end;

function TEntityStorageSettings.GetUserID: string;
begin
  Result :=
    (FWorkItem.Services[IConfigurationService] as IConfigurationService).Settings.UserID;
end;

function TEntityStorageSettings.GetUserPreferences(
  AWorkItem: TWorkItem): TDataSet;
begin
  Result := GetSettingsData(AWorkItem, true);
end;

function TEntityStorageSettings.GetValue(const AName: string): Variant;
begin


end;

procedure TEntityStorageSettings.LoadSettingValue(AField: TField;
  APreferences: boolean);
var
  dsGet: TDataSet;
  userID: string;
begin
  if APreferences then
    userID := GetUserID
  else
    userID := '';

  dsGet := (FWorkItem.Services[IEntityService] as IEntityService).
    Entity[ENT_SETTING].GetView(ENT_SETTING_VIEW_GET, FWorkItem).
      Load([AField.Origin, userID]);

  if AField is TIntegerField then
    AField.Value := dsGet['VALI']
  else if AField is TStringField then
    AField.Value := dsGet['VALS']
  else if AField is TFloatField then
    AField.Value := dsGet['VALN']
  else if AField is TDateTimeField then
    AField.Value := dsGet['VALD'];
end;

procedure TEntityStorageSettings.SaveSettingValue(AField: TField;
  APreferences: boolean);
var
  userID: string;
  valI: Variant;
  valS: variant;
  valN: variant;
  valD: variant;
begin
  if APreferences then
    userID := GetUserID
  else
    userID := '';

  if AField is TIntegerField then
    valI := AField.Value
  else if AField is TStringField then
    valS := AField.Value
  else if AField is TFloatField then
    valN := AField.Value
  else if AField is TDateTimeField then
    valD := AField.Value;

  (FWorkItem.Services[IEntityService] as IEntityService).
    Entity[ENT_SETTING].GetOper(ENT_SETTING_OPER_SET, FWorkItem).
      Execute([AField.Origin, userID, valI, valS, valN, valD]);

end;

procedure TEntityStorageSettings.SettingsDataChangedHandler(
  AField: TField);
var
  preferences: boolean;
begin
  preferences := (AField.DataSet.Tag = 1);
  SaveSettingValue(AField, preferences);
  AField.OnChange := nil;
  LoadSettingValue(AField, preferences);
  CheckSettingValue(AField, preferences);
  AField.OnChange := SettingsDataChangedHandler;
end;

end.
