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
  EntityDeskPresenter, EntityDeskView,
  EntityDeskMenuPresenter, EntityDeskMenuView;


type


  TEntityCatalogController = class(TWorkItemController)
  protected
    //
    procedure Initialize; override;

    type
      TEntityItemDefaultHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

      TEntityNewDefaultHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

      TEntityOperExecHandler = class(TActivityHandler)
      const
        CLS_ENTITY_OPER_EXEC = 'IEntityOperExec';
      public
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

      TEntityActivityHandler = class(TActivityHandler)
      const
        CLS_ENTITY_ACTIVITY = 'IEntityActivity';
      public
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

  end;

implementation

procedure ParamsBinding(Source: IActivity; Target: TParams); overload;
var
  I: integer;
  prm: TParam;
  prmName: string;
begin
  for i := 0 to Source.Params.Count - 1 do
  begin
    prmName := Source.Params.ValueName(I);
    prm := Target.FindParam(prmName);
    if prm <> nil then
      prm.Value := Source.Params[prmName];
  end;
end;

procedure ParamsBinding(Source: TDataSet; Target: IActivity); overload;
var
  I: integer;
  field: TField;
  prmName: string;
begin
  for i := 0 to Target.Params.Count - 1 do
  begin
    prmName := Target.Params.ValueName(I);
    field := Source.FindField(prmName);
    if field <> nil then
      Target.Params[prmName] := field.Value;
  end;
end;


procedure ParamsBinding(Source: IActivity; Target: IActivity); overload;
var
  I: integer;
  prmName: string;
begin
  for i := 0 to Source.Params.Count - 1 do
  begin
    prmName := Source.Params.ValueName(I);
    if Target.Params.IndexOf(prmName) <> -1 then
      Target.Params[prmName] := Source.Params[prmName];
  end;
end;

procedure TEntityCatalogController.Initialize;
begin

  with WorkItem.Activities do
  begin
    RegisterHandler(TEntityOperExecHandler.CLS_ENTITY_OPER_EXEC, TEntityOperExecHandler.Create);
    //
    RegisterHandler(TEntityActivityHandler.CLS_ENTITY_ACTIVITY, TEntityActivityHandler.Create);
    //
    RegisterHandler('IEntityNewDef', TEntityNewDefaultHandler.Create);
    RegisterHandler('IEntityItemDef', TEntityItemDefaultHandler.Create);
    //
    RegisterHandler('IEntityListView', TViewActivityHandler.Create(TEntityListPresenter, TfrEntityListView));
    RegisterHandler('IEntityNewView', TViewActivityHandler.Create(TEntityNewPresenter, TfrEntityNewView));
    RegisterHandler('IEntityItemView', TViewActivityHandler.Create(TEntityItemPresenter, TfrEntityItemView));
    RegisterHandler('IEntityComplexView', TViewActivityHandler.Create(TEntityComplexPresenter, TfrEntityComplexView));
    RegisterHandler('IEntityCollectView', TViewActivityHandler.Create(TEntityCollectPresenter, TfrEntityCollectView));
    RegisterHandler('IEntityListView', TViewActivityHandler.Create(TEntityListPresenter, TfrEntityListView));
    RegisterHandler('IEntityTreeListView', TViewActivityHandler.Create(TEntityTreeListPresenter, TfrEntityTreeListView));
    RegisterHandler('IEntityPickListView', TViewActivityHandler.Create(TEntityPickListPresenter, TfrEntityPickListView));
    RegisterHandler('IEntityJournalView', TViewActivityHandler.Create(TEntityJournalPresenter, TfrEntityJournalView));
    RegisterHandler('IEntitySelectorView', TViewActivityHandler.Create(TEntitySelectorPresenter, TfrEntitySelectorView));
    RegisterHandler('IEntityDeskView', TViewActivityHandler.Create(TEntityDeskPresenter, TfrEntityDeskView));
    RegisterHandler('IEntityDeskMenuView', TViewActivityHandler.Create(TEntityDeskMenuPresenter, TfrEntityDeskMenuView));
    RegisterHandler('IEntityOrgChartView', TViewActivityHandler.Create(TEntityOrgChartPresenter, TfrEntityOrgChartView));
  end;

end;





{ TEntityCatalogController.TEntityItemDefaultHandler }

procedure TEntityCatalogController.TEntityItemDefaultHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);

const
 // URI_FIELD = 'URI';

  OPTION_DEFAULT_URI = 'DefaultURI';
  OPTION_EVIEW_URI = 'EViewURI';
  OPTION_EVIEW_URI_FIELD = 'EViewURIField';

var
  viewURI: string;
  dsItemURI: TDataSet;
  entityName: string;
  evItemURI: IEntityView;
  targetActivity: IActivity;
  evUriName: string;
  ViewUriDef: string;
  evUriFieldName: string;

begin

  ViewUriDef := Activity.OptionValue(OPTION_DEFAULT_URI);
  evUriName := Activity.OptionValue(OPTION_EVIEW_URI);
  evUriFieldName :=  Activity.OptionValue(OPTION_EVIEW_URI_FIELD);

  entityName := Activity.OptionValue(TViewActivityOptions.EntityName);
  if entityName = '-' then
  begin
    if Sender.Controller is TEntityContentPresenter then
      entityName := (Sender.Controller as TEntityContentPresenter).EntityName
    else if Sender.Controller is TEntityDialogPresenter then
      entityName := (Sender.Controller as TEntityDialogPresenter).EntityName
    else
      entityName := '';
  end;

  if entityName = '' then Exit;

  dsItemURI := nil;
  viewURI := '';

  if App.Entities.EntityViewExists(entityName, evUriName) then
  begin
    evItemURI := App.Entities[entityName].GetView(evUriName, Sender);
    ParamsBinding(Activity, evItemURI.Params);

    dsItemURI := App.Entities[entityName].GetView(evUriName, Sender).Load(true, '-');
    viewURI := VarToStr(dsItemURI[evUriFieldName]);
  end
  else
    viewURI := format(ViewUriDef, [entityName]);

  if (viewURI = '') or SameText(viewURI, Activity.URI) then Exit;

  targetActivity := Sender.Activities[viewURI];
  ParamsBinding(Activity, targetActivity);
  if dsItemURI <> nil then
    ParamsBinding(dsItemURI, targetActivity);
  targetActivity.Execute(Sender);

end;

{ TEntityCatalogController.TEntityOperExecHandler }

procedure TEntityCatalogController.TEntityOperExecHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
var
  entityName: string;
  operName: string;
  oper: IEntityOper;
  confirmText: string;
  confirm: boolean;
begin

  entityName := Activity.OptionValue(TViewActivityOptions.EntityName);
  operName := Activity.OptionValue(TViewActivityOptions.EntityViewName);
  confirmText := Activity.OptionValue('CONFIRM');

  if (confirmText <> '') then
    confirm := App.UI.MessageBox.ConfirmYesNo(confirmText)
  else
    confirm := true;

  if confirm then
  begin
    oper := App.Entities[entityName].GetOper(operName, Sender);

    ParamsBinding(Activity, oper.Params);

    App.UI.WaitBox.StartWait;
    try
      oper.Execute;
    finally
      App.UI.WaitBox.StopWait;
      Sender.Commands[COMMAND_RELOAD].Execute;
    end;
  end;

end;


{ TEntityCatalogController.TEntityNewDefaultHandler }

procedure TEntityCatalogController.TEntityNewDefaultHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
const
  URI_FIELD = 'URI';
  FMT_VIEW_NEW_URI = 'views.%s.NewURI';

  OPTION_DEFAULT_URI = 'DefaultURI';


var
  viewURI: string;
  entityName: string;
  targetActivity: IActivity;
  actionURI: IActivity;
  ViewUriDef: string;

begin

  ViewUriDef := Activity.OptionValue(OPTION_DEFAULT_URI);

  entityName := Activity.OptionValue(TViewActivityOptions.EntityName);
  if entityName = '-' then
  begin
    if Sender.Controller is TEntityContentPresenter then
      entityName := (Sender.Controller as TEntityContentPresenter).EntityName
    else if Sender.Controller is TEntityDialogPresenter then
      entityName := (Sender.Controller as TEntityDialogPresenter).EntityName
    else
      entityName := '';
  end;

  if entityName = '' then Exit;

  viewURI := '';

  if App.Entities.EntityViewExists(entityName, 'NewURI') then
  begin
    actionURI := Sender.Activities[format(FMT_VIEW_NEW_URI, [entityName])];
    actionURI.Execute(Sender);
    if actionURI.Outs[TViewActivityOuts.ModalResult] = mrOk then
      viewURI := actionURI.Outs['URI']
    else
      viewURI := '';
  end
  else
    viewURI := format(ViewUriDef, [entityName]);

  if (viewURI = '') or SameText(viewURI, Activity.URI) then Exit;

  targetActivity := Sender.Activities[viewURI];
  ParamsBinding(Activity, targetActivity);
  targetActivity.Execute(Sender);


end;

{ TEntityCatalogController.TEntityActivityHandler }

procedure TEntityCatalogController.TEntityActivityHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
//const
 // URI_FIELD = 'URI';


var
  viewURI: string;
  dsURI: TDataSet;
  entityName: string;
  eviewName: string;
  evURI: IEntityView;
  targetActivity: IActivity;

  I: integer;
  prmName: string;
  field: TField;
begin


  entityName := Activity.OptionValue(TViewActivityOptions.EntityName);
  if entityName = '' then Exit;
  eviewName := Activity.OptionValue(TViewActivityOptions.EntityViewName);
  if eviewName = '' then Exit;

  viewURI := '';

  evURI := App.Entities[entityName].GetView(eviewName, Sender);
  ParamsBinding(Activity, evURI.Params);


  dsURI := evURI.Load(true, '-');
  viewURI := VarToStr(dsURI['URI']);

  //FieldValue -> Outs bind
  for i := 0 to Activity.Outs.Count - 1 do
  begin
    prmName := Activity.Outs.ValueName(I);
    field := dsURI.FindField(prmName);
    if field <> nil then
      Activity.Outs[prmName] := field.Value;
  end;

  if (viewURI = '') or SameText(viewURI, Activity.URI) then Exit;

  targetActivity := Sender.Activities[viewURI];

  //Params -> Params bind
  for i := 0 to Activity.Params.Count - 1 do
  begin
    prmName := Activity.Params.ValueName(I);
    if targetActivity.Params.IndexOf(prmName) <> -1 then
      targetActivity.Params[prmName] := Activity.Params[prmName];
  end;


  //Outs -> Params bind
  for i := 0 to Activity.Outs.Count - 1 do
  begin
    prmName := Activity.Outs.ValueName(I);
    if targetActivity.Params.IndexOf(prmName) <> -1 then
      targetActivity.Params[prmName] := Activity.Outs[prmName];
  end;

  targetActivity.Execute(Sender);

end;

end.
