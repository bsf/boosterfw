unit EntityCatalogController;

interface
uses classes, CoreClasses,  ShellIntf, Variants, db, Contnrs,
  EntityCatalogIntf, EntityServiceIntf, UIClasses, sysutils,
  StrUtils, SecurityIntf, controls,
  EntityJournalPresenter, EntityJournalView,
  EntityListPresenter, EntityListView,
  EntityTreeListPresenter, EntityTreeListView,
  EntityNewPresenter, EntityNewView,
  EntityItemPresenter, EntityItemView,
  EntityComplexPresenter, EntityComplexView,
  EntityCollectPresenter, EntityCollectView,
  EntityOrgChartPresenter, EntityOrgChartView,
  EntityPickListPresenter, EntityPickListView,
  EntitySelectorPresenter, EntitySelectorView,
  EntityDeskPresenter, EntityDeskView;


type


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
      TEntityPickListActivityHandler = class(TViewActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
  end;

implementation

{ TEntityCatalogController }
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
    RegisterHandler('IEntityListView', TViewActivityHandler.Create(TEntityListPresenter, TfrEntityListView));
    RegisterHandler('IEntityNewView', TViewActivityHandler.Create(TEntityNewPresenter, TfrEntityNewView));
    RegisterHandler('IEntityItemView', TViewActivityHandler.Create(TEntityItemPresenter, TfrEntityItemView));
    RegisterHandler('IEntityComplexView', TViewActivityHandler.Create(TEntityComplexPresenter, TfrEntityComplexView));
    RegisterHandler('IEntityCollectView', TViewActivityHandler.Create(TEntityCollectPresenter, TfrEntityCollectView));
    RegisterHandler('IEntityListView', TViewActivityHandler.Create(TEntityListPresenter, TfrEntityListView));
    RegisterHandler('IEntityTreeListView', TViewActivityHandler.Create(TEntityTreeListPresenter, TfrEntityTreeListView));
    RegisterHandler('IEntityPickListView', TEntityPickListActivityHandler.Create(TEntityPickListPresenter, TfrEntityPickListView));
    RegisterHandler('IEntityJournalView', TViewActivityHandler.Create(TEntityJournalPresenter, TfrEntityJournalView));
    RegisterHandler('IEntitySelectorView', TViewActivityHandler.Create(TEntitySelectorPresenter, TfrEntitySelectorView));
    RegisterHandler('IEntityDeskView', TViewActivityHandler.Create(TEntityDeskPresenter, TfrEntityDeskView));
    RegisterHandler('IEntityOrgChartView', TViewActivityHandler.Create(TEntityOrgChartPresenter, TfrEntityOrgChartView));
  end;

end;



{ TEntityCatalogController.TEntityItemActionHandler }

procedure TEntityCatalogController.TEntityItemActionHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
const
  FMT_VIEW_ITEM = 'views.%s.Item';
var
  viewURI: string;
  dsItemURI: TDataSet;
  entityName: string;
  bindingRule: string;
  I: integer;
  field: TField;
begin

  entityName := Activity.Params[TEntityItemActionParams.EntityName];

  bindingRule := Activity.Params[TEntityItemActionParams.BindingParams];
  if bindingRule = '' then
    bindingRule := TEntityItemActionParams.BindingParamsDef;

  viewURI := Activity.Params[TEntityItemActionParams.ViewUri];

  dsItemURI := nil;

  if (viewURI = '') and App.Entities.EntityViewExists(entityName, 'ItemURI') then
  begin
    dsItemURI := App.Entities[entityName].GetView('ItemURI', Sender).Load(true, bindingRule);
    viewURI := VarToStr(dsItemURI['URI']);
  end
  else
    viewURI := format(TEntityItemActionParams.ViewUriDef, [entityName]);

  if viewURI = '' then Exit;

  with Sender.Activities[viewURI] do
  begin
    Params.Assign(Sender, bindingRule);

    if dsItemURI <> nil then
      for I := 0 to Params.Count - 1 do
      begin
        field := dsItemURI.FindField(Params.ValueName(I));
        if field <> nil then
          Params.Value[Params.ValueName(I)] := field.Value;
      end;

    Execute(Sender);
  end;


end;

{ TEntityCatalogController.TEntityNewActionHandler }

procedure TEntityCatalogController.TEntityNewActionHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
const
  FMT_VIEW_NEW_URI = 'views.%s.NewURI';
  FMT_VIEW_NEW = 'views.%s.New';

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
  FMT_VIEW_NEW_URI = 'views.%s.DetailNewURI';
  FMT_VIEW_NEW = 'views.%s.DetailNew';

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
  FMT_VIEW_ITEM = 'views.%s.Detail';
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

{ TEntityCatalogController.TEntityPickListActivityHandler }

procedure TEntityCatalogController.TEntityPickListActivityHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
begin
  Activity.Outs[TPickListActivityOuts.ID] := Unassigned;
  Activity.Outs[TPickListActivityOuts.NAME] := Unassigned;
  inherited Execute(Sender, Activity);
end;


end.
