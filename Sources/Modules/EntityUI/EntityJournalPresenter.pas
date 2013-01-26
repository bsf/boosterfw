unit EntityJournalPresenter;

interface
uses classes, CoreClasses, CustomPresenter, UIClasses, SysUtils, Variants,
  ShellIntf, Controls, db, StrUtils, UIStr,
  EntityServiceIntf;


const
  COMMAND_SELECTOR = 'commands.journal.selector';

  ENT_VIEW_JOURNAL = 'Journal';
  ENT_VIEW_STATES = 'States';
  ENT_OPER_STATE_CHANGE_DEFAULT = 'StateChange';

  ENT_VIEW_NEW_DEFAULT = 'New';
  ENT_VIEW_ITEM_DEFAULT = 'Item';
  ENT_VIEW_HEAD_EDIT_DEFAULT = 'HeadEdit';


type
  IEntityJournalView = interface(IContentView)
  ['{254B9732-7666-4733-BC3C-6D9D078FC5A7}']
    function Selection: ISelection;
    function Tabs: ITabs;
    procedure SetInfoText(const AText: string);
    procedure SetJournalDataSet(ADataSet: TDataSet);
  end;

  TEntityJournalPresenter = class(TCustomPresenter)
  private
    FIsReady: boolean;
    FSelectorInitialized: boolean;
    procedure InitializeSelector;
    procedure UpdateInfoText;
    function GetSelectorEntityName: string;
    procedure TabChangedHandler;
    procedure SelectionChangedHandler;
    procedure CmdStateChange(Sender: TObject);
    procedure CmdDelete(Sender: TObject);
    function GetEVStates: IEntityView;
    procedure CmdReload(Sender: TObject);
    procedure CmdSelector(Sender: TObject);
  protected
    function View: IEntityJournalView;
    procedure OnUpdateCommandStatus; override;
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;

    function GetEVJrn: IEntityView; virtual;




  end;


implementation

{ TEntityJournalPresenter }

procedure TEntityJournalPresenter.CmdDelete(Sender: TObject);
var
  cResult: boolean;
begin
  cResult := App.UI.MessageBox.ConfirmYesNo('Удалить выделенную запись?');
  if cResult then
  begin
    try
      if GetEVJrn.DataSet.Locate(GetEVJrn.Info.PrimaryKey, WorkItem.State['ITEM_ID'], []) then
      begin
        GetEVJrn.DataSet.Delete;
        GetEVJrn.Save;
      end
    except
      GetEVJrn.CancelUpdates;
      raise;
    end;
  end;

end;

procedure TEntityJournalPresenter.CmdReload(Sender: TObject);
begin
  GetEVJrn.Load;
end;

procedure TEntityJournalPresenter.CmdSelector(Sender: TObject);
const
  FMT_VIEW_SELECTOR = 'Views.%s.Selector';
var
  actionName: string;
begin
  actionName := format(FMT_VIEW_SELECTOR, [GetSelectorEntityName]);

  with WorkItem.Activities[actionName] do
  begin
    Params.Assign(WorkItem);
    Execute(WorkItem);
    if Outs[TViewActivityOuts.ModalResult] = mrOk then
    begin
      Outs.AssignTo(WorkItem);
      UpdateInfoText;
      WorkItem.Commands[COMMAND_RELOAD].Execute;
    end;
  end
end;

procedure TEntityJournalPresenter.CmdStateChange(Sender: TObject);
var
  cmd: ICommand;
  I: integer;
  direction: integer;
  IDList: Variant;
begin

  Sender.GetInterface(ICommand, cmd);
  if cmd.Name = COMMAND_STATE_CHANGE_NEXT then
    direction := 1
  else
    direction := -1;

  if not App.UI.MessageBox.ConfirmYesNo('Сменить текущее состояние ?') then Exit;

  try
    IDList := VarArrayCreate([0, View.Selection.Count - 1], varVariant);
    for I := 0 to View.Selection.Count - 1 do
    begin
      App.Entities[GetEVJrn.EntityName].
        GetOper(ENT_OPER_STATE_CHANGE_DEFAULT, WorkItem).
          Execute([View.Selection[I], direction]);
    end;
  finally

    WorkItem.Commands[COMMAND_RELOAD].Execute;
  end;

end;

procedure TEntityJournalPresenter.OnViewReady;
var
  dsStates: TDataSet;
begin
  ViewTitle := ViewInfo.Title;
//  FreeOnViewClose := false;

  dsStates := GetEVStates.DataSet;
  while not dsStates.Eof do
  begin
    View.Tabs.Add(dsStates['NAME']);
    dsStates.Next;
  end;

  View.CommandBar.
    AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

  WorkItem.Commands[COMMAND_RELOAD].SetHandler(CmdReload);
  View.CommandBar.
    AddCommand(COMMAND_RELOAD,
      GetLocaleString(@COMMAND_RELOAD_CAPTION), COMMAND_RELOAD_SHORTCUT);

  View.CommandBar.AddCommand(COMMAND_SELECTOR,
    GetLocaleString(@COMMAND_SELECTOR_CAPTION));
  WorkItem.Commands[COMMAND_SELECTOR].SetHandler(CmdSelector);

  View.CommandBar.
    AddCommand(COMMAND_NEW,
      GetLocaleString(@COMMAND_NEW_CAPTION), COMMAND_NEW_SHORTCUT, '', false);

  View.CommandBar.
    AddCommand(COMMAND_OPEN,
      GetLocaleString(@COMMAND_OPEN_CAPTION), COMMAND_OPEN_SHORTCUT, '', false);

  View.CommandBar.
    AddCommand(COMMAND_DELETE,
      GetLocaleString(@COMMAND_DELETE_CAPTION), COMMAND_DELETE_SHORTCUT);
  WorkItem.Commands[COMMAND_DELETE].SetHandler(CmdDelete);

  WorkItem.Commands[COMMAND_STATE_CHANGE_NEXT].SetHandler(CmdStateChange);
  View.CommandBar.AddCommand(COMMAND_STATE_CHANGE_NEXT,
    GetLocaleString(@COMMAND_STATE_CHANGE_NEXT_CAPTION), '',
    GetLocaleString(@COMMAND_STATE_CHANGE_CAPTION), true);

  WorkItem.Commands[COMMAND_STATE_CHANGE_PREV].SetHandler(CmdStateChange);
  View.CommandBar.AddCommand(COMMAND_STATE_CHANGE_PREV,
    GetLocaleString(@COMMAND_STATE_CHANGE_PREV_CAPTION), '', GetLocaleString(@COMMAND_STATE_CHANGE_CAPTION));

  GetEVJrn.SynchronizeOnEntityChange(GetEVJrn.EntityName, ENT_VIEW_NEW_DEFAULT);
  GetEVJrn.SynchronizeOnEntityChange(GetEVJrn.EntityName, ENT_VIEW_ITEM_DEFAULT);
  GetEVJrn.SynchronizeOnEntityChange(GetEVJrn.EntityName, ENT_VIEW_HEAD_EDIT_DEFAULT);

  View.SetJournalDataSet(GetEVJrn.DataSet);

  View.Tabs.Active := 0;
  View.Tabs.SetTabChangedHandler(TabChangedHandler);
  View.Selection.SetSelectionChangedHandler(SelectionChangedHandler);

  TabChangedHandler;

  FIsReady := true;
end;

function TEntityJournalPresenter.GetEVJrn: IEntityView;
var
  evName: string;
begin
  if not FSelectorInitialized then
  begin
    InitializeSelector;
    FSelectorInitialized := true;
  end;

  evName := EntityViewName;
  if evName = '' then evName := ENT_VIEW_JOURNAL;
  Result := GetEView(EntityName, evName);
end;

function TEntityJournalPresenter.GetEVStates: IEntityView;
begin
  Result := GetEView(EntityName, ENT_VIEW_STATES, []);
end;

procedure TEntityJournalPresenter.InitializeSelector;
var
  ds: TDataSet;
  I: integer;
begin
  ds := App.Entities[GetSelectorEntityName].GetView('Selector', WorkItem).Load;
  for I := 0 to ds.FieldCount - 1 do
    WorkItem.State[ds.Fields[I].FieldName] := ds.Fields[I].Value;
  UpdateInfoText;
end;

function TEntityJournalPresenter.OnGetWorkItemState(
  const AName: string; var Done: boolean): Variant;
const
  const_EV_FIELD_PREFIX = 'EV.';
var
  ds: TDataSet;
  fieldName: string;

begin
  Done := true;
  if SameText(AName, 'ITEM_ID') then
    Result := View.Selection.First
  else if SameText('STATE_ID', AName) then
  begin
    if (GetView <> nil) and (View.Tabs.Count > 0) then
    begin
      GetEVStates.DataSet.Locate('NAME', View.Tabs.TabCaption[View.Tabs.Active], []);
      result := GetEVStates.DataSet['ID'];
    end;
  end
  else if SameText('USE_DRANGE', AName) then
  begin
    if (GetView <> nil) and (View.Tabs.Count > 0) then
    begin
      GetEVStates.DataSet.Locate('NAME', View.Tabs.TabCaption[View.Tabs.Active], []);
      Result :=  GetEVStates.DataSet['DRANGE'];
    end
  end
  else if FIsReady and AnsiStartsText(const_EV_FIELD_PREFIX, AName) then
  begin
    Done := false;
    fieldName := StringReplace(AName, const_EV_FIELD_PREFIX, '', [rfIgnoreCase]);
    ds := App.Entities[EntityName].GetView(EntityViewName, WorkItem).DataSet;
    if ds.FindField(fieldName) <> nil then
    begin
      Done := true;
      Result := ds[fieldName];
    end;
  end
  else
  begin
    Done := false;
    Result := inherited OnGetWorkItemState(AName, Done);
  end;
end;

procedure TEntityJournalPresenter.OnUpdateCommandStatus;
begin
  WorkItem.Commands[COMMAND_NEW].Status := csDisabled;
  WorkItem.Commands[COMMAND_OPEN].Status := csDisabled;
  WorkItem.Commands[COMMAND_DELETE].Status := csDisabled;
  WorkItem.Commands[COMMAND_STATE_CHANGE_NEXT].Status := csDisabled;
  WorkItem.Commands[COMMAND_STATE_CHANGE_PREV].Status := csDisabled;

  if View.Tabs.Active = 0 then
    WorkItem.Commands[COMMAND_NEW].Status := csEnabled;

  if (View.Tabs.Active = 0) and (View.Selection.Count > 0) then
    WorkItem.Commands[COMMAND_DELETE].Status := csEnabled;

  if View.Selection.Count > 0 then
    WorkItem.Commands[COMMAND_OPEN].Status := csEnabled;

  if (View.Selection.Count > 0) and (View.Tabs.Active < (View.Tabs.Count - 1)) then
    WorkItem.Commands[COMMAND_STATE_CHANGE_NEXT].Status := csEnabled;

  if (View.Selection.Count > 0) and(View.Tabs.Active > 0) then
    WorkItem.Commands[COMMAND_STATE_CHANGE_PREV].Status := csEnabled;
end;

procedure TEntityJournalPresenter.SelectionChangedHandler;
begin
  UpdateCommandStatus;
end;

procedure TEntityJournalPresenter.UpdateInfoText;
var
  txt: string;
begin
  txt := VarToStr(App.Entities[GetSelectorEntityName].
     GetView('SelectorInfo', WorkItem).Load['Info']);

  if GetView <> nil then
    (GetView as IEntityJournalView).SetInfoText(txt);

end;

procedure TEntityJournalPresenter.TabChangedHandler;
begin
  WorkItem.Commands[COMMAND_RELOAD].Execute;
  UpdateCommandStatus;
  UpdateInfoText;
end;

function TEntityJournalPresenter.View: IEntityJournalView;
begin
  Result := GetView as IEntityJournalView;
end;

function TEntityJournalPresenter.GetSelectorEntityName: string;
begin
  Result := ViewInfo.OptionValue('UseSelector');
  if (Result = '') and App.Entities.EntityViewExists(EntityName, 'Selector') then
    Result := EntityName
  else
    Result := 'UTL_JRN';
end;

end.
