unit EntityCatalogController;

interface
uses classes, CoreClasses,  ShellIntf, Variants, db, Contnrs,
  EntityServiceIntf, UIClasses, sysutils,
  StrUtils, SecurityIntf, controls,
  CustomPresenter,
  EntityJournalPresenter, EntityJournalView,
  EntityListPresenter, EntityListView,
  EntityTreeListPresenter, EntityTreeListView,
  EntityNewPresenter, EntityNewView,
  EntityItemPresenter, EntityItemView,
  EntityItemExtPresenter, EntityItemExtView,
  EntityComplexPresenter, EntityComplexView,
  EntityCollectPresenter, EntityCollectView,
  EntityOrgChartPresenter, EntityOrgChartView,
  EntityPickListPresenter, EntityPickListView,
  EntitySelectorPresenter, EntitySelectorView,
  EntityDeskPresenter, EntityDeskView,
  EntityDeskMenuPresenter, EntityDeskMenuView,
  EntityWebPresenter, EntityWebView;


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

procedure ActivityDataBinding(Source: IActivityData; Target: IActivityData);
var
  I: integer;
  prmName: string;
begin
  for i := 0 to Source.Count - 1 do
  begin
    prmName := Source.ValueName(I);
    if Target.IndexOf(prmName) <> -1 then
      Target[prmName] := Source[prmName];
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
    RegisterHandler('IEntityItemExtView', TViewActivityHandler.Create(TEntityItemExtPresenter, TfrEntityItemExtView));
    RegisterHandler('IEntityComplexView', TViewActivityHandler.Create(TEntityComplexPresenter, TfrEntityComplexView));
    RegisterHandler('IEntityCollectView', TViewActivityHandler.Create(TEntityCollectPresenter, TfrEntityCollectView));
    RegisterHandler('IEntityTreeListView', TViewActivityHandler.Create(TEntityTreeListPresenter, TfrEntityTreeListView));
    RegisterHandler('IEntityPickListView', TViewActivityHandler.Create(TEntityPickListPresenter, TfrEntityPickListView));
    RegisterHandler('IEntityJournalView', TViewActivityHandler.Create(TEntityJournalPresenter, TfrEntityJournalView));
    RegisterHandler('IEntitySelectorView', TViewActivityHandler.Create(TEntitySelectorPresenter, TfrEntitySelectorView));
    RegisterHandler('IEntityDeskView', TViewActivityHandler.Create(TEntityDeskPresenter, TfrEntityDeskView));
    RegisterHandler('IEntityDeskMenuView', TViewActivityHandler.Create(TEntityDeskMenuPresenter, TfrEntityDeskMenuView));
    RegisterHandler('IEntityOrgChartView', TViewActivityHandler.Create(TEntityOrgChartPresenter, TfrEntityOrgChartView));
    RegisterHandler('IEntityWebView', TViewActivityHandler.Create(TEntityWebPresenter, TfrEntityWebView));
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
    if Sender.Controller is TCustomPresenter then
      entityName := (Sender.Controller as TCustomPresenter).EntityName
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
    if Sender.Controller is TCustomPresenter then
      entityName := (Sender.Controller as TCustomPresenter).EntityName
    else
      entityName := '';
  end;

  if entityName = '' then Exit;

  viewURI := '';

  actionURI := nil;
  if App.Entities.EntityViewExists(entityName, 'NewURI') then
  begin
    actionURI := Sender.Activities[format(FMT_VIEW_NEW_URI, [entityName])];
    ParamsBinding(Activity, actionURI);
    actionURI.Execute(Sender);
    if actionURI.Outs[TViewActivityOuts.ModalResult] = mrOk then
    begin
      viewURI := actionURI.Outs['URI']
    end
    else
      viewURI := '';
  end
  else
    viewURI := format(ViewUriDef, [entityName]);

  if (viewURI = '') or SameText(viewURI, Activity.URI) then Exit;

  targetActivity := Sender.Activities[viewURI];
  ParamsBinding(Activity, targetActivity);
  if actionURI <> nil then
    ActivityDataBinding(actionURI.Outs, targetActivity.Params);

  targetActivity.Execute(Sender);


end;

{ TEntityCatalogController.TEntityActivityHandler }

procedure TEntityCatalogController.TEntityActivityHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);

  function GetDialogActivity: IActivity;
  const
    CLS_DIALOG = 'IEntityPickListView';
  var
    I: integer;
    dialogURI: string;
  begin
    dialogURI := Activity.OptionValue('Dialog');
    if dialogURI = '' then
    begin
      Result := Sender.Activities[Activity.URI + '.Dialog'];
      with Result do
      begin
        ActivityClass := CLS_DIALOG;
        Title := Activity.Title;
        Options.Clear;
        Options.AddStrings(Activity.Options);

        for I := 0 to Activity.Params.Count - 1 do
          Params[Activity.Params.ValueName(I)] := Unassigned;

        for I := 0 to Activity.Outs.Count - 1 do
          Params[Activity.Outs.ValueName(I)] := Unassigned;
      end;
    end
    else
      Result := Sender.Activities[dialogURI];
  end;

//const
 // URI_FIELD = 'URI';


var
  viewURI: string;
  dsURI: TDataSet;
  entityName: string;
  eviewName: string;
  evURI: IEntityView;
  targetActivity: IActivity;
  dialogActivity: IActivity;
  I: integer;
  prmName: string;
  field: TField;
begin


  entityName := Activity.OptionValue(TViewActivityOptions.EntityName);
  if entityName = '' then Exit;
  eviewName := Activity.OptionValue(TViewActivityOptions.EntityViewName);
  if eviewName = '' then Exit;

  viewURI := '';

  if Activity.OptionExists('Dialog') then
  begin
    dialogActivity := GetDialogActivity;
    ActivityDataBinding(Activity.Params, dialogActivity.Params);
    dialogActivity.Execute(Sender);
    if dialogActivity.Outs[TViewActivityOuts.ModalResult] = mrOk then
    begin
      viewURI := dialogActivity.Outs['URI'];
      ActivityDataBinding(dialogActivity.Outs, Activity.Outs);
    end
    else
      viewURI := '';
  end
  else
  begin
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
  end;

  if (viewURI = '') or SameText(viewURI, Activity.URI) then Exit;

  targetActivity := Sender.Activities[viewURI];

  //Params -> Params bind
  ActivityDataBinding(Activity.Params, targetActivity.Params);
  //Outs -> Params bind
  ActivityDataBinding(Activity.Outs, targetActivity.Params);
  targetActivity.CallMode := Activity.CallMode;

  targetActivity.Execute(Sender);

end;

end.
