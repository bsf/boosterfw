unit EntityDeskPresenter;

interface

uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst;

const
  ENT_OPER_STATE_CHANGE_DEFAULT = 'StateChange';
  ENT_VIEW_NEW_DEFAULT = 'New';
  ENT_VIEW_ITEM_DEFAULT = 'Item';

type
  IEntityDeskView = interface(IContentView)
  ['{5D92D298-2E39-4565-B03A-460DDF9EE79E}']
    function Selection: ISelection;
    function Tabs: ITabs;
    procedure SetData(AParams, AList: TDataSet);
  end;


  TEntityDeskPresenter = class(TEntityContentPresenter)
  private
    function View: IEntityDeskView;
    procedure CmdClose(Sender: TObject);
    procedure CmdReload(Sender: TObject);
    procedure CmdNew(Sender: TObject);
    procedure CmdOpen(Sender: TObject);
    procedure CmdDelete(Sender: TObject);
    procedure CmdStateChange(Sender: TObject);
    function GetEVList: IEntityView;
    function GetEVParams: IEntityView;
    function GetEVStates: IEntityView;
    procedure TabChangedHandler;
    procedure SelectionChangedHandler;
  protected
    function OnGetWorkItemState(const AName: string): Variant; override;
    procedure OnUpdateCommandStatus; override;
    procedure OnViewReady; override;
  end;

implementation

{ TEntityDeskPresenter }

procedure TEntityDeskPresenter.CmdClose(Sender: TObject);
begin
  CloseView;
end;

procedure TEntityDeskPresenter.CmdReload(Sender: TObject);
begin
  GetEVList.Reload;
end;

function TEntityDeskPresenter.GetEVList: IEntityView;
begin
  Result := GetEView(EntityName, 'List');
end;

function TEntityDeskPresenter.GetEVParams: IEntityView;
begin
  Result := App.Entities[EntityName].GetView('Params', WorkItem);
end;

function TEntityDeskPresenter.OnGetWorkItemState(
  const AName: string): Variant;
begin
  if GetEVParams.IsLoaded and (GetEVParams.DataSet.FindField(AName) <> nil) then
  begin
    if GetEVParams.DataSet.State = dsEdit then GetEVParams.DataSet.Post;
    Result := GetEVParams.DataSet[AName];
  end
  else if SameText(AName, 'ITEM_ID') then
    Result := View.Selection.First
  else if SameText('STATE_ID', AName) then
  begin
    if (GetView <> nil) and (View.Tabs.Count > 0) then
    begin
      GetEVStates.DataSet.Locate('NAME', View.Tabs.TabCaption[View.Tabs.Active], []);
      result := GetEVStates.DataSet['ID'];
    end;
  end
end;

procedure TEntityDeskPresenter.OnViewReady;
var
  dsStates: TDataSet;
begin
  ViewTitle := ViewInfo.Title;

  dsStates := GetEVStates.DataSet;
  while not dsStates.Eof do
  begin
    View.Tabs.Add(dsStates['NAME']);
    dsStates.Next;
  end;

  View.CommandBar.
    AddCommand(COMMAND_CLOSE, GetLocaleString(@COMMAND_CLOSE_CAPTION),
      COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, GetLocaleString(@COMMAND_RELOAD_CAPTION),
      COMMAND_RELOAD_SHORTCUT, CmdReload);

  if ViewInfo.OptionExists('CanAdd') or ViewInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_NEW, GetLocaleString(@COMMAND_NEW_CAPTION),
      COMMAND_NEW_SHORTCUT, CmdNew);

  if ViewInfo.OptionExists('CanOpen') or ViewInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_OPEN, GetLocaleString(@COMMAND_OPEN_CAPTION),
      COMMAND_OPEN_SHORTCUT, CmdOpen);

  if ViewInfo.OptionExists('CanDelete') or ViewInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_DELETE, GetLocaleString(@COMMAND_DELETE_CAPTION),
      COMMAND_DELETE_SHORTCUT, CmdDelete);


  View.CommandBar.AddCommand(COMMAND_STATE_CHANGE_NEXT,
     GetLocaleString(@COMMAND_STATE_CHANGE_NEXT_CAPTION), '', CmdStateChange,
      GetLocaleString(@COMMAND_STATE_CHANGE_CAPTION), true);

  View.CommandBar.AddCommand(COMMAND_STATE_CHANGE_PREV,
     GetLocaleString(@COMMAND_STATE_CHANGE_PREV_CAPTION), '', CmdStateChange,
     GetLocaleString(@COMMAND_STATE_CHANGE_CAPTION));

  GetEVParams.Load(WorkItem);

  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_NEW_DEFAULT);
  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_ITEM_DEFAULT);

  View.SetData(GetEVParams.DataSet, GetEVList.DataSet);

  View.Tabs.Active := 0;
  View.Tabs.SetTabChangedHandler(TabChangedHandler);
  View.Selection.SetSelectionChangedHandler(SelectionChangedHandler);
  TabChangedHandler;
end;

function TEntityDeskPresenter.View: IEntityDeskView;
begin
  Result := GetView as IEntityDeskView;
end;

procedure TEntityDeskPresenter.CmdDelete(Sender: TObject);
var
  cResult: boolean;
begin
  cResult := App.UI.MessageBox.ConfirmYesNo('Удалить выделенную запись?');
  if cResult then
  begin
    try
      if GetEVList.DataSet.Locate(GetEVList.ViewInfo.PrimaryKey, WorkItem.State['ITEM_ID'], []) then
      begin
        GetEVList.DataSet.Delete;
        GetEVList.Save;
      end
    except
      GetEVList.CancelUpdates;
      raise;
    end;
  end;


end;

procedure TEntityDeskPresenter.CmdNew(Sender: TObject);
begin
  with WorkItem.Activities[ACTION_ENTITY_NEW] do
  begin
    Params[TEntityNewActionParams.EntityName] := EntityName;
    Execute(WorkItem);
  end;
end;

procedure TEntityDeskPresenter.CmdOpen(Sender: TObject);
begin
  if VarIsEmpty(WorkItem.State['ITEM_ID']) then Exit;

  with WorkItem.Activities[ACTION_ENTITY_ITEM] do
  begin
    Params[TEntityItemActionParams.ID] := WorkItem.State['ITEM_ID'];
    Params[TEntityItemActionParams.EntityName] := EntityName;
    Execute(WorkItem);
  end;

end;

procedure TEntityDeskPresenter.SelectionChangedHandler;
begin
  UpdateCommandStatus;
end;

procedure TEntityDeskPresenter.TabChangedHandler;
begin
  WorkItem.Commands[COMMAND_RELOAD].Execute;
  UpdateCommandStatus;
end;


procedure TEntityDeskPresenter.OnUpdateCommandStatus;
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

function TEntityDeskPresenter.GetEVStates: IEntityView;
begin
  Result := GetEView(EntityName, 'States');
end;

procedure TEntityDeskPresenter.CmdStateChange(Sender: TObject);
var
  cmd: ICommand;
  I: integer;
  direction: integer;
begin

  Sender.GetInterface(ICommand, cmd);
  if cmd.Name = COMMAND_STATE_CHANGE_NEXT then
    direction := 1
  else
    direction := -1;

  if not App.UI.MessageBox.ConfirmYesNo('Сменить текущее состояние ?') then Exit;

  try

    for I := 0 to View.Selection.Count - 1 do
    begin
      App.Entities[EntityName].
        GetOper(ENT_OPER_STATE_CHANGE_DEFAULT, WorkItem).
          Execute([View.Selection[I], direction]);
    end;
  finally

    WorkItem.Commands[COMMAND_RELOAD].Execute;
  end;

end;

end.
