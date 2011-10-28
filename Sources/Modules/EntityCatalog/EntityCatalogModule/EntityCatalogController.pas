unit EntityCatalogController;

interface
uses classes, CoreClasses, CustomUIController,  ShellIntf, Variants, db, Contnrs,
  ActivityServiceIntf,
  EntityCatalogIntf, EntityServiceIntf, CommonViewIntf, sysutils,
  StrUtils, EntitySecResProvider, SecurityIntf, controls,
  EntityJournalPresenter, EntityJournalView,
  EntityListPresenter, EntityListView,
  EntityNewPresenter, EntityNewView,
  EntityItemPresenter, EntityItemView,
  EntityComplexPresenter, EntityComplexView,
  EntityCollectPresenter, EntityCollectView,
  EntityOrgChartPresenter, EntityOrgChartView,
  EntityPickListPresenter, EntityPickListView,
  EntitySelectorPresenter, EntitySelectorView,
  EntityDeskPresenter, EntityDeskView;

const
  ENTC_UI = 'ENTC_UI';
  ENTC_UI_VIEW_LIST = 'List';
  ENTC_UI_VIEW_CMD = 'Commands';

type
  TEntityUIClass = class(TObject)
  private
    FName: string;
  public
    constructor Create(const AName: string); virtual;
    property Name: string read FName;
  end;

  TEntityUIClassPresenter = class(TEntityUIClass)
  private
    FPresenterClass: TPresenterClass;
    FViewClass: TViewClass;
  public
    constructor Create(const AName: string; APresenterClass: TPresenterClass;
      AViewClass: TViewClass); reintroduce;
    property PresenterClass: TPresenterClass read FPresenterClass;
    property ViewClass: TViewClass read FViewClass;
  end;

  TEntityUIClassSecurityResProvider = class(TEntityUIClass)
  end;

  TEntityUIClassActivity = class(TEntityUIClass)
  end;

  TEntityViewExtension = class(TViewExtension, IExtensionCommand)
  private
    function GetDataValue(const AValue: string): Variant;
    procedure CmdHandlerCommand(Sender: TObject);
    procedure CmdHandlerAction(Sender: TObject);
    procedure CmdEntityOperExec(Sender: TObject);
  protected
    procedure CommandExtend;
    procedure CommandUpdate;
  end;


  TEntityUIInfo = class(TComponent, IEntityUIInfo)
  private
    FURI: string;
    FUIClassName: string;
    FEntityName: string;
    FEntityViewName: string;
    FTitle: string;
    FCategory: string;
    FGroup: string;
    FOptions: TStringList;
    FParams: TStringList;
    FOuts: TStringList;
  protected
    //IEntityUIInfo
    function URI: string;
    function UIClassName: string;
    function EntityName: string;
    function EntityViewName: string;
    function Params: TStrings;
    function Outs: TStrings;
    function Title: string;
    function Category: string;
    function Group: string;
    function OptionValue(const AName: string): string;
    function OptionExists(const AName: string): boolean;
  public
    constructor Create(AOwner: TComponent; const AURI, AUIClassName, AEntityName: string); reintroduce;
    destructor Destroy; override;
  end;

  TEntityActivityBuilder = class(TActivityBuilder)
  private
    FWorkItem: TWorkItem;
  public
    constructor Create(AWorkItem: TWorkItem);
    function ActivityClass: string; override;
    procedure Build(ActivityInfo: IActivityInfo); override;
  end;

  TEntityViewActivityBuilder = class(TViewActivityBuilder)
  public
    procedure Build(ActivityInfo: IActivityInfo); override;
  end;

  TSecurityResActivityBuilder = class(TActivityBuilder)
  private
    FProvider: TEntitySecurityResProvider;
    FWorkItem: TWorkItem;
  public
    constructor Create(WorkItem: TWorkItem);
    destructor Destroy; override;
    function ActivityClass: string; override;
    procedure Build(ActivityInfo: IActivityInfo); override;
  end;

  TEntityCatalogController = class(TCustomUIController)
  private

    procedure RegisterUIClasses;
    //
    procedure ActionEntityItem(Sender: IAction);
    procedure ActionEntityNew(Sender: IAction);
    procedure ActionEntityDetailNew(Sender: IAction);
    procedure ActionEntityDetail(Sender: IAction);
  protected
    //
    procedure OnInitialize; override;
    procedure Terminate; override;
  public
    destructor Destroy; override;
  end;

implementation

{ TEntityCatalogController }

procedure TEntityCatalogController.ActionEntityDetail(Sender: IAction);
const
  FMT_VIEW_ITEM = 'Views.%s.Detail';
var
  actionName: string;
  action: IAction;
  dsItemURI: TDataSet;
  itemID: variant;
  entityName: string;
begin

  itemID := (Sender.Data as TEntityItemActionData).ID;
  entityName := (Sender.Data as TEntityItemActionData).EntityName;

  if App.Entities.EntityViewExists(entityName, 'DetailURI') then
  begin
    dsItemURI := App.Entities[entityName].GetView('DetailURI', WorkItem).Load([itemID]);
    actionName := dsItemURI['URI'];
    if dsItemURI.FindField('ITEM_ID') <> nil then
      itemID := dsItemURI['ITEM_ID'];
  end
  else
    actionName := format(FMT_VIEW_ITEM, [entityName]);

  if actionName <> '' then
  begin
    action := WorkItem.Actions[actionName];
    action.Data.Assign(Sender.Caller);
    action.Data.Value['ID'] := itemID;
    action.Execute(Sender.Caller);
  end;

end;

procedure TEntityCatalogController.ActionEntityDetailNew(Sender: IAction);
const
  FMT_VIEW_NEW_URI = 'Views.%s.DetailNewURI';
  FMT_VIEW_NEW = 'Views.%s.DetailNew';

var
  actionURI: IAction;
  actionName: string;
  entityName: string;
begin
  entityName := (Sender.Data as TEntityNewActionData).EntityName;

  if App.Entities.EntityViewExists(entityName, 'DetailNewURI') then
  begin
    actionURI := WorkItem.Actions[format(FMT_VIEW_NEW_URI, [entityName])];
    actionURI.Execute(WorkItem);
    if (actionURI.Data as TEntityPickListPresenterData).ModalResult = mrOk then
      actionName := actionURI.Data.Value['URI']
    else
      actionName := '';
  end
  else
    actionName := format(FMT_VIEW_NEW, [entityName]);

  if actionName <> '' then
  begin
    WorkItem.Actions[actionName].Data.Assign(Sender.Caller);
    //WorkItem.Actions[actionName].Data.HID := (Sender.Data as TEntityNewActionData).HID;    
    WorkItem.Actions[actionName].Execute(Sender.Caller);
  end;

end;

procedure TEntityCatalogController.ActionEntityItem(Sender: IAction);
const
  FMT_VIEW_ITEM = 'Views.%s.Item';
var
  actionName: string;
  action: IAction;
  dsItemURI: TDataSet;
  itemID: variant;
  entityName: string;
begin

  itemID := (Sender.Data as TEntityItemActionData).ID;
  entityName := (Sender.Data as TEntityItemActionData).EntityName;

  if App.Entities.EntityViewExists(entityName, 'ItemURI') then
  begin
    dsItemURI := App.Entities[entityName].GetView('ItemURI', WorkItem).Load([itemID]);
    actionName := dsItemURI['URI'];
    if dsItemURI.FindField('ITEM_ID') <> nil then
      itemID := dsItemURI['ITEM_ID'];
  end
  else
    actionName := format(FMT_VIEW_ITEM, [entityName]);

  if actionName <> '' then
  begin
    action := WorkItem.Actions[actionName];
    action.Data.Assign(Sender.Caller);
    action.Data.Value['ID'] := itemID;
    action.Execute(Sender.Caller);
  end;

end;

procedure TEntityCatalogController.ActionEntityNew(Sender: IAction);
const
  FMT_VIEW_NEW_URI = 'Views.%s.NewURI';
  FMT_VIEW_NEW = 'Views.%s.New';

var
  actionURI: IAction;
  actionName: string;
  entityName: string;
begin
  entityName := (Sender.Data as TEntityNewActionData).EntityName;

  if App.Entities.EntityViewExists(entityName, 'NewURI') then
  begin
    actionURI := WorkItem.Actions[format(FMT_VIEW_NEW_URI, [entityName])];
    actionURI.Execute(WorkItem);
    if (actionURI.Data as TEntityPickListPresenterData).ModalResult = mrOk then
      actionName := actionURI.Data.Value['URI']
    else
      actionName := '';
  end
  else
    actionName := format(FMT_VIEW_NEW, [entityName]);

  if actionName <> '' then
  begin
    WorkItem.Actions[actionName].Data.Assign(Sender.Caller);
    WorkItem.Actions[actionName].Execute(Sender.Caller);
  end;
end;

destructor TEntityCatalogController.Destroy;
begin
  inherited;
end;


procedure TEntityCatalogController.OnInitialize;
begin

  RegisterUIClasses;

  with WorkItem.Root.Actions[ACTION_ENTITY_ITEM] do
  begin
    SetHandler(ActionEntityItem);
    SetDataClass(TEntityItemActionData);
  end;

  with WorkItem.Root.Actions[ACTION_ENTITY_NEW] do
  begin
    SetHandler(ActionEntityNew);
    SetDataClass(TEntityNewActionData);
  end;

  with WorkItem.Root.Actions[ACTION_ENTITY_DETAIL] do
  begin
    SetHandler(ActionEntityDetail);
    SetDataClass(TEntityItemActionData);
  end;

  with WorkItem.Root.Actions[ACTION_ENTITY_DETAIL_NEW] do
  begin
    SetHandler(ActionEntityDetailNew);
    SetDataClass(TEntityNewActionData);
  end;

 { RegisterAction(ACTION_ENTITY_ITEM, ActionEntityItem, TEntityItemActionData);
  RegisterAction(ACTION_ENTITY_NEW, ActionEntityNew, TEntityNewActionData);
  RegisterAction(ACTION_ENTITY_DETAIL, ActionEntityDetail, TEntityItemActionData);
  RegisterAction(ACTION_ENTITY_DETAIL_NEW, ActionEntityDetailNew, TEntityNewActionData);
  }

end;


procedure TEntityCatalogController.RegisterUIClasses;
var
  svc: IActivityService;
begin
  svc := WorkItem.Services[IActivityService] as IActivityService;

  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityListView', TEntityListPresenter, TfrEntityListView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityNewView', TEntityNewPresenter, TfrEntityNewView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityItemView', TEntityItemPresenter, TfrEntityItemView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityComplexView', TEntityComplexPresenter, TfrEntityComplexView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityCollectView', TEntityCollectPresenter, TfrEntityCollectView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityListView', TEntityListPresenter, TfrEntityListView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityPickListView', TEntityPickListPresenter, TfrEntityPickListView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityJournalView', TEntityJournalPresenter, TfrEntityJournalView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntitySelectorView', TEntitySelectorPresenter, TfrEntitySelectorView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityDeskView', TEntityDeskPresenter, TfrEntityDeskView));
  svc.RegisterActivityClass(TEntityViewActivityBuilder.Create(WorkItem,
    'IEntityOrgChartView', TEntityOrgChartPresenter, TfrEntityOrgChartView));

  svc.RegisterActivityClass(TEntityActivityBuilder.Create(WorkItem));
  svc.RegisterActivityClass(TSecurityResActivityBuilder.Create(WorkItem));

//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityNewView', TEntityNewPresenter, TfrEntityNewView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityItemView', TEntityItemPresenter, TfrEntityItemView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityComplexView', TEntityComplexPresenter, TfrEntityComplexView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityCollectView', TEntityCollectPresenter, TfrEntityCollectView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityListView', TEntityListPresenter, TfrEntityListView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityPickListView', TEntityPickListPresenter, TfrEntityPickListView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityJournalView', TEntityJournalPresenter, TfrEntityJournalView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntitySelectorView', TEntitySelectorPresenter, TfrEntitySelectorView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityDeskView', TEntityDeskPresenter, TfrEntityDeskView));
//  RegisterUIClass(TEntityUIClassPresenter.Create('IEntityOrgChartView', TEntityOrgChartPresenter, TfrEntityOrgChartView));
//  RegisterUIClass(TEntityUIClassActivity.Create('IEntityActivity'));
//  RegisterUIClass(TEntityUIClassSecurityResProvider.Create('ISecurityResProvider'));
end;


procedure TEntityCatalogController.Terminate;
begin

end;

{ TEntityViewExtension }

procedure TEntityViewExtension.CmdEntityOperExec(Sender: TObject);
var
  intf: ICommand;
  entityName: string;
  operName: string;
  oper: IEntityOper;
  I: integer;
  confirmText: string;
  confirm: boolean;
begin
  Sender.GetInterface(ICommand, intf);


  entityName := intf.Data['ENTITY'];
  operName := intf.Data['OPER'];
  confirmText := intf.Data['CONFIRM'];
  if (confirmText <> '') then
    confirm := App.UI.MessageBox.ConfirmYesNo(confirmText)
  else
    confirm := true;

  if confirm then
  begin
    oper := App.Entities[entityName].GetOper(operName, WorkItem);
    for I := 0 to oper.Params.Count - 1 do
      oper.Params[I].Value := GetDataValue(intf.Data[oper.Params[I].Name]);

    App.UI.WaitBox.StartWait;
    try
      oper.Execute;
    finally
      App.UI.WaitBox.StopWait;
      WorkItem.Commands[COMMAND_RELOAD].Execute;
    end;  
  end;
end;

procedure TEntityViewExtension.CmdHandlerAction(Sender: TObject);
var
  intf: ICommand;
  actionName: string;
  action: IAction;
  cmdData: string;
  dataList: TStringList;
  I: integer;
begin
  Sender.GetInterface(ICommand, intf);
  cmdData := intf.Data['CMD_DATA'];
  actionName := intf.Data['HANDLER'];
  intf := nil;

  action := WorkItem.Actions[actionName];

  dataList := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(cmdData), dataList);
    for I := 0 to dataList.Count - 1 do
      action.Data.SetValue(dataList.Names[I], GetDataValue(dataList.ValueFromIndex[I]));
  finally
    dataList.Free;
  end;

  action.Execute(WorkItem);
end;

procedure TEntityViewExtension.CmdHandlerCommand(Sender: TObject);
var
  intf: ICommand;
  cmdName: string;
  cmdData: string;
  dataList: TStringList;
  I: integer;
begin
  Sender.GetInterface(ICommand, intf);
  cmdName := intf.Data['HANDLER'];
  cmdData := intf.Data['CMD_DATA'];

  intf := WorkItem.Commands[cmdName];
  dataList := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(cmdData), dataList);
    for I := 0 to dataList.Count - 1 do
      intf.Data[dataList.Names[I]] := GetDataValue(dataList.ValueFromIndex[I]);
  finally
    dataList.Free;
  end;

  intf.Execute;

end;

procedure TEntityViewExtension.CommandExtend;
const
  COMMAND_ENTITY_OPER_EXEC = 'view.commands.EntityOperExec';

var
  list: TDataSet;
  cmd: ICommand;
begin
  if not Supports(GetView, ICustomView) then Exit;

  list := App.Entities[ENTC_UI].GetView(ENTC_UI_VIEW_CMD, WorkItem).Load([GetView.ViewURI]);
  while not list.Eof do
  begin
    cmd := WorkItem.Commands[list['CMD']];
    cmd.Caption := list['CAPTION'];
    cmd.Data['HANDLER'] := VarToStr(list['HANDLER']);
    cmd.Data['CMD_DATA'] := VarToStr(list['CMD_DATA']);

    if list['HANDLER_KIND'] = 1 then
      cmd.SetHandler(CmdHandlerCommand)
    else if list['HANDLER_KIND'] = 2 then
      cmd.SetHandler(CmdHandlerAction);

    (GetView as ICustomView).CommandBar.
      AddCommand(cmd.Name, VarToStr(list['GRP']), list['DEF'] = 1);

    list.Next;
  end;

  //embedded commands
  WorkItem.Commands[COMMAND_ENTITY_OPER_EXEC].SetHandler(CmdEntityOperExec);
end;

procedure TEntityViewExtension.CommandUpdate;
begin

end;

function TEntityViewExtension.GetDataValue(const AValue: string): Variant;
const
  const_WI_STATE = 'WI.';
  const_EV_VALUE = 'EV.';

var
  valueName, entityName, eviewName: string;
begin
  if AnsiStartsText(const_WI_STATE, AValue) then
    Result := WorkItem.State[StringReplace(AValue, const_WI_STATE, '', [rfIgnoreCase])]
  else if AnsiStartsText(const_EV_VALUE, AValue) then
  begin
    valueName := StringReplace(AValue, const_EV_VALUE, '', [rfIgnoreCase]);
    entityName := AnsiLeftStr(valueName, Pos('.', valueName) - 1);
    Delete(valueName, 1, Pos('.', valueName));
    eviewName := AnsiLeftStr(valueName, Pos('.', valueName) - 1);
    Delete(valueName, 1, Pos('.', valueName));
    Result := App.Entities[entityName].GetView(eviewName, WorkItem).Values[valueName];
  end
  else
    Result := AValue;
end;

{ TEntityUIInfo }

function TEntityUIInfo.Category: string;
begin
  Result := FCategory;
end;

constructor TEntityUIInfo.Create(AOwner: TComponent;
  const AURI, AUIClassName, AEntityName: string);
begin
  inherited Create(AOwner);
  FURI := AURI;
  FUIClassName := AUIClassName;
  FEntityName := AEntityName;
  FOptions := TStringList.Create;
  FParams := TStringList.Create;
  FOuts := TStringList.Create;
end;

destructor TEntityUIInfo.Destroy;
begin
  FOuts.Free;
  FParams.Free;
  FOptions.Free;
  inherited;
end;

function TEntityUIInfo.EntityName: string;
begin
  Result := FEntityName;
end;

function TEntityUIInfo.EntityViewName: string;
begin
  Result := FEntityViewName;
end;

function TEntityUIInfo.Params: TStrings;
begin
  Result := FParams;
end;

function TEntityUIInfo.OptionValue(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

function TEntityUIInfo.Group: string;
begin
  Result := FGroup;
end;

function TEntityUIInfo.Title: string;
begin
  Result := FTitle;
end;

function TEntityUIInfo.UIClassName: string;
begin
  Result := FUIClassName; //(Owner as TEntityCatalogController).GetUIClass(FUIClassName, true);
end;


function TEntityUIInfo.URI: string;
begin
  Result := FURI;
end;

function TEntityUIInfo.Outs: TStrings;
begin
  Result := FOuts;
end;

function TEntityUIInfo.OptionExists(const AName: string): boolean;
begin
  Result := (FOptions.IndexOfName(AName) <> -1) or (FOptions.IndexOf(AName) <> -1);
end;

{ TEntityUIClassPresenter }

constructor TEntityUIClassPresenter.Create(const AName: string;
  APresenterClass: TPresenterClass; AViewClass: TViewClass);
begin
  inherited Create(AName);
  FPresenterClass := APresenterClass;
  FViewClass := AViewClass;
end;

{ TEntityUIClass }

constructor TEntityUIClass.Create(const AName: string);
begin
  FName := AName;
end;

{ TEntityActivityBuilder }

function TEntityActivityBuilder.ActivityClass: string;
begin
  Result := 'IEntityActivity';
end;

procedure TEntityActivityBuilder.Build(ActivityInfo: IActivityInfo);
begin
//  (FWorkItem.Services[IViewManagerService] as IViewManagerService).
    RegisterViewExtension(ActivityInfo.URI, TEntityViewExtension);
end;

constructor TEntityActivityBuilder.Create(AWorkItem: TWorkItem);
begin
  FWorkItem := AWorkItem;
end;

{ TEntityViewActivityBuilder }

procedure TEntityViewActivityBuilder.Build(ActivityInfo: IActivityInfo);
begin
  inherited;
 // (WorkItem.Services[IViewManagerService] as IViewManagerService).
  RegisterViewExtension(ActivityInfo.URI, TEntityViewExtension);
end;

{ TSecurityResActivityBuilder }

function TSecurityResActivityBuilder.ActivityClass: string;
begin
  Result := 'ISecurityResProvider';
end;

procedure TSecurityResActivityBuilder.Build(ActivityInfo: IActivityInfo);
begin
  FProvider := TEntitySecurityResProvider.Create(nil, ActivityInfo.URI, FWorkItem);
  (FWorkItem.Services[ISecurityService] as ISecurityService).
    RegisterResProvider(FProvider);
end;

constructor TSecurityResActivityBuilder.Create(WorkItem: TWorkItem);
begin
  FWorkItem := WorkItem;
end;

destructor TSecurityResActivityBuilder.Destroy;
begin
  if Assigned(FProvider) then
    FProvider.Free;
  inherited;
end;

end.
