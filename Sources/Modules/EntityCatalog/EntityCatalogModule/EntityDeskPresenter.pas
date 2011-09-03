unit EntityDeskPresenter;

interface

uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, CommonViewIntf,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db, ViewServiceIntf,
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


  TEntityDeskPresenter = class(TCustomContentPresenter)
  private
    function UIInfo: IEntityUIInfo;
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

  public
    class function ExecuteDataClass: TActionDataClass; override;
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

class function TEntityDeskPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TEntityPresenterData;
end;

function TEntityDeskPresenter.GetEVList: IEntityView;
begin
  Result := GetEView(UIInfo.EntityName, 'List');
end;

function TEntityDeskPresenter.GetEVParams: IEntityView;
begin
  Result := App.Entities[UIInfo.EntityName].GetView('Params', WorkItem);
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
  ViewTitle := UIInfo.Title;

  dsStates := GetEVStates.DataSet;
  while not dsStates.Eof do
  begin
    View.Tabs.Add(dsStates['NAME']);
    dsStates.Next;
  end;
  
  View.CommandBar.
    AddCommand(COMMAND_CLOSE, COMMAND_CLOSE_CAPTION, COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, COMMAND_RELOAD_CAPTION, COMMAND_RELOAD_SHORTCUT, CmdReload);

  if UIInfo.OptionExists('CanAdd') or UIInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_NEW, COMMAND_NEW_CAPTION, COMMAND_NEW_SHORTCUT, CmdNew);

  if UIInfo.OptionExists('CanOpen') or UIInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_OPEN, COMMAND_OPEN_CAPTION, COMMAND_OPEN_SHORTCUT, CmdOpen);

  if UIInfo.OptionExists('CanDelete') or UIInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_DELETE, COMMAND_DELETE_CAPTION, COMMAND_DELETE_SHORTCUT, CmdDelete);


  View.CommandBar.AddCommand(COMMAND_STATE_CHANGE_NEXT,
    COMMAND_STATE_CHANGE_NEXT_CAPTION, '', CmdStateChange, 'Сменить состояние', true);

  View.CommandBar.AddCommand(COMMAND_STATE_CHANGE_PREV,
    COMMAND_STATE_CHANGE_PREV_CAPTION, '', CmdStateChange, 'Сменить состояние');

  GetEVParams.Load(WorkItem);

  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_NEW_DEFAULT);
  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_ITEM_DEFAULT);

  View.SetData(GetEVParams.DataSet, GetEVList.DataSet);

  View.Tabs.Active := 0;
  View.Tabs.SetTabChangedHandler(TabChangedHandler);
  View.Selection.SetSelectionChangedHandler(SelectionChangedHandler);
  TabChangedHandler;
end;

function TEntityDeskPresenter.UIInfo: IEntityUIInfo;
begin
  Result := (WorkItem.Services[IEntityUIManagerService] as IEntityUIManagerService).UIInfo(GetViewURI);
end;

function TEntityDeskPresenter.View: IEntityDeskView;
begin
  Result := GetView as IEntityDeskView;
end;

procedure TEntityDeskPresenter.CmdDelete(Sender: TObject);
var
  cResult: boolean;
begin
  cResult := App.Views.MessageBox.ConfirmYesNo('Удалить выделенную запись?');
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
var
  action: IAction;
begin
  action := WorkItem.Actions[ACTION_ENTITY_NEW];
  action.Data.Value['ENTITYNAME'] := UIInfo.EntityName;
  action.Execute(WorkItem);
end;

procedure TEntityDeskPresenter.CmdOpen(Sender: TObject);
var
  action: IAction;
begin
  if VarIsEmpty(WorkItem.State['ITEM_ID']) then Exit;

  action := WorkItem.Actions[ACTION_ENTITY_ITEM];
  action.Data.Value['ID'] := WorkItem.State['ITEM_ID'];
  action.Data.Value['ENTITYNAME'] := UIInfo.EntityName;
  action.Execute(WorkItem);

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
  Result := GetEView(UIInfo.EntityName, 'States');
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

  if not App.Views.MessageBox.ConfirmYesNo('Сменить текущее состояние ?') then Exit;

  try

    for I := 0 to View.Selection.Count - 1 do
    begin
      App.Entities[UIInfo.EntityName].
        GetOper(ENT_OPER_STATE_CHANGE_DEFAULT, WorkItem).
          Execute([View.Selection[I], direction]);
    end;
  finally

    WorkItem.Commands[COMMAND_RELOAD].Execute;
  end;

end;

end.
