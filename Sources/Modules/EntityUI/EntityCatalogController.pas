unit EntityCatalogController;

interface
uses classes, CoreClasses,  ShellIntf, Variants, db, Contnrs,
  EntityCatalogIntf, EntityServiceIntf, UIClasses, sysutils,
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


type

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


{
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
}

  TEntityCatalogController = class(TWorkItemController)
  protected
    //
    procedure Initialize; override;
    type
      TEntityItemActionHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
      TEntityNewActionHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
      TEntityDetailNewActionHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
      TEntityDetailActionHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
      TEntityViewActivityHandler = class(TViewActivityHandler)
      private
        FInitialized: boolean;
      public
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
  end;

implementation

{ TEntityCatalogController }
(*
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
 *)
procedure TEntityCatalogController.Initialize;
begin


  WorkItem.Activities[ACTION_ENTITY_ITEM].
    RegisterHandler(TEntityItemActionHandler.Create);

  WorkItem.Activities[ACTION_ENTITY_NEW].
    RegisterHandler(TEntityNewActionHandler.Create);

  WorkItem.Activities[ACTION_ENTITY_DETAIL].
    RegisterHandler(TEntityDetailActionHandler.Create);

  WorkItem.Activities[ACTION_ENTITY_DETAIL_NEW].
    RegisterHandler(TEntityDetailNewActionHandler.Create);

  with WorkItem.Activities do
  begin
    RegisterHandler('IEntityListView', TEntityViewActivityHandler.Create(TEntityListPresenter, TfrEntityListView));
    RegisterHandler('IEntityNewView', TEntityViewActivityHandler.Create(TEntityNewPresenter, TfrEntityNewView));
    RegisterHandler('IEntityItemView', TEntityViewActivityHandler.Create(TEntityItemPresenter, TfrEntityItemView));
    RegisterHandler('IEntityComplexView', TEntityViewActivityHandler.Create(TEntityComplexPresenter, TfrEntityComplexView));
    RegisterHandler('IEntityCollectView', TEntityViewActivityHandler.Create(TEntityCollectPresenter, TfrEntityCollectView));
    RegisterHandler('IEntityListView', TEntityViewActivityHandler.Create(TEntityListPresenter, TfrEntityListView));
    RegisterHandler('IEntityPickListView', TEntityViewActivityHandler.Create(TEntityPickListPresenter, TfrEntityPickListView));
    RegisterHandler('IEntityJournalView', TEntityViewActivityHandler.Create(TEntityJournalPresenter, TfrEntityJournalView));
    RegisterHandler('IEntitySelectorView', TEntityViewActivityHandler.Create(TEntitySelectorPresenter, TfrEntitySelectorView));
    RegisterHandler('IEntityDeskView', TEntityViewActivityHandler.Create(TEntityDeskPresenter, TfrEntityDeskView));
    RegisterHandler('IEntityOrgChartView', TEntityViewActivityHandler.Create(TEntityOrgChartPresenter, TfrEntityOrgChartView));
  end;
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
  action: IActivity;
  cmdData: string;
  dataList: TStringList;
  I: integer;
begin
  Sender.GetInterface(ICommand, intf);
  cmdData := intf.Data['CMD_DATA'];
  actionName := intf.Data['HANDLER'];
  intf := nil;

  action := WorkItem.Activities[actionName];

  dataList := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(cmdData), dataList);
    for I := 0 to dataList.Count - 1 do
      action.Params[dataList.Names[I]] :=  GetDataValue(dataList.ValueFromIndex[I]);
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
  ENTC_UI = 'ENTC_UI';
  ENTC_UI_VIEW_CMD = 'Commands';

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


{ TSecurityResActivityBuilder }
{
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
 }
{ TEntityCatalogController.TEntityItemActionHandler }

procedure TEntityCatalogController.TEntityItemActionHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
const
  FMT_VIEW_ITEM = 'Views.%s.Item';
var
  actionName: string;
  dsItemURI: TDataSet;
  itemID: variant;
  entityName: string;
begin

  itemID := Activity.Params[TEntityItemActionParams.ID];
  entityName := Activity.Params[TEntityItemActionParams.EntityName];

  if App.Entities.EntityViewExists(entityName, 'ItemURI') then
  begin
    dsItemURI := App.Entities[entityName].GetView('ItemURI', Sender).Load([itemID]);
    actionName := dsItemURI['URI'];
    if dsItemURI.FindField('ITEM_ID') <> nil then
      itemID := dsItemURI['ITEM_ID'];
  end
  else
    actionName := format(FMT_VIEW_ITEM, [entityName]);

  if actionName <> '' then
    with Sender.Activities[actionName] do
    begin
      Params.Assign(Sender);
      Params[TEntityItemActivityParams.ID] := itemID;
      Params[TViewActivityParams.PresenterID] := VarToStr(itemID);
      Execute(Sender);
    end;

end;

{ TEntityCatalogController.TEntityNewActionHandler }

procedure TEntityCatalogController.TEntityNewActionHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
const
  FMT_VIEW_NEW_URI = 'Views.%s.NewURI';
  FMT_VIEW_NEW = 'Views.%s.New';

var
  actionURI: IActivity;
  actionName: string;
  entityName: string;
begin
  entityName := Activity.Params[TEntityNewActionParams.EntityName];

  if App.Entities.EntityViewExists(entityName, 'NewURI') then
  begin
    actionURI := Sender.Activities[format(FMT_VIEW_NEW_URI, [entityName])];
    actionURI.Execute(Sender);
    if actionURI.Outs[TViewActivityOuts.ModalResult] = mrOk then
      actionName := actionURI.Outs['URI']
    else
      actionName := '';
  end
  else
    actionName := format(FMT_VIEW_NEW, [entityName]);

  if actionName <> '' then
    with Sender.Activities[actionName] do
    begin
      Params.Assign(Sender);
      Execute(Sender);
    end;

end;

{ TEntityCatalogController.TEntityDetailNewActionHandler }

procedure TEntityCatalogController.TEntityDetailNewActionHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
const
  FMT_VIEW_NEW_URI = 'Views.%s.DetailNewURI';
  FMT_VIEW_NEW = 'Views.%s.DetailNew';

var
  actionURI: IActivity;
  actionName: string;
  entityName: string;
begin
  entityName := Activity.Params['EntityName'];

  if App.Entities.EntityViewExists(entityName, 'DetailNewURI') then
  begin
    actionURI := Sender.Activities[format(FMT_VIEW_NEW_URI, [entityName])];
    actionURI.Execute(Sender);
    if actionURI.Outs[TViewActivityOuts.ModalResult] = mrOk then
      actionName := actionURI.Outs['URI']
    else
      actionName := '';
  end
  else
    actionName := format(FMT_VIEW_NEW, [entityName]);

  if actionName <> '' then
    with Sender.Activities[actionName] do
    begin
      Params.Assign(Sender);
      Execute(Sender);
    end;

end;

{ TEntityCatalogController.TEntityDetailActionHandler }

procedure TEntityCatalogController.TEntityDetailActionHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
const
  FMT_VIEW_ITEM = 'Views.%s.Detail';
var
  actionName: string;
  dsItemURI: TDataSet;
  itemID: variant;
  entityName: string;
begin

  itemID := Activity.Params['ID'];
  entityName := Activity.Params[TEntityItemActionParams.EntityName];

  if App.Entities.EntityViewExists(entityName, 'DetailURI') then
  begin
    dsItemURI := App.Entities[entityName].GetView('DetailURI', Sender).Load([itemID]);
    actionName := dsItemURI['URI'];
    if dsItemURI.FindField('ITEM_ID') <> nil then
      itemID := dsItemURI['ITEM_ID'];
  end
  else
    actionName := format(FMT_VIEW_ITEM, [entityName]);

  if actionName <> '' then
    with Sender.Activities[actionName] do
    begin
      Params.Assign(Sender);
      Params[TEntityItemActionParams.ID] := itemID;
      Execute(Sender);
    end;

end;

{ TEntityCatalogController.TEntitiyViewActivityHandler }

procedure TEntityCatalogController.TEntityViewActivityHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
begin
  if not FInitialized then
  begin
    RegisterViewExtension(Activity.URI, TEntityViewExtension);
    FInitialized := true;
  end;
  inherited;
end;

end.
