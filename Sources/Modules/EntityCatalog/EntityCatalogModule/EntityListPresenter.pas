unit EntityListPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, CommonViewIntf,
  SysUtils, Variants, ShellIntf, CustomContentPresenter,
  EntityCatalogIntf, EntityCatalogConst, db, controls;

const
  COMMAND_SELECTOR = '{0D2B32E3-7CE0-4775-A2D3-3A91ED2AFEFB}';//'commands.view.selector';
  INFOTEXT_FIELD_NAME = 'INFO';

  ENT_VIEW_LIST = 'List';

  ENT_VIEW_NEW_DEFAULT = 'New';
  ENT_VIEW_ITEM_DEFAULT = 'Item';


type
  TEntityListPresenter = class(TCustomContentPresenter)
  private
    FSelectorInitialized: boolean;
    function UIInfo: IEntityUIInfo;
    function UseSelector: boolean;
    function GetSelectorEntityName: string;
    procedure InitializeSelector;
    procedure UpdateInfoText;
    procedure CmdReload(Sender: TObject);

    procedure CmdNew(Sender: TObject);
    procedure CmdOpen(Sender: TObject);
    procedure CmdDelete(Sender: TObject);
    procedure CmdSelector(Sender: TObject);

    procedure EViewListChangedHandler(ADataSet: TDataSet);
    function View: IEntityListView;
  protected
    function OnGetWorkItemState(const AName: string): Variant; override;
    //
    function GetEVList: IEntityView;

    procedure OnViewReady; override;
    //
    function GetSelectedIDList: Variant;
  public
    class function ExecuteDataClass: TActionDataClass; override;
  end;

implementation

{ TEntityListPresenter }

procedure TEntityListPresenter.CmdReload(Sender: TObject);
begin
  GetEVList.Reload;
end;


procedure TEntityListPresenter.CmdDelete(Sender: TObject);
var
  cResult: boolean;
begin
  cResult := App.Views.MessageBox.ConfirmYesNo('Удалить выделенные записи?');
  if cResult then
  begin
    try
      GetEVList.DataSet.Delete;
      GetEVList.Save;
    except
      GetEVList.CancelUpdates;
      raise;
    end;
  end;

end;

function TEntityListPresenter.GetSelectedIDList: Variant;
var
  I: integer;
begin
  if (GetView as IEntityListView).Selection.Count > 0 then
  begin
    Result := VarArrayCreate([0, (GetView as IEntityListView).Selection.Count - 1], varVariant);
    for I := 0 to (GetView as IEntityListView).Selection.Count - 1 do
      Result[I] := (GetView as IEntityListView).Selection.Items[I];
  end
  else
    Result := Unassigned;
end;

function TEntityListPresenter.OnGetWorkItemState(const AName: string): Variant;
begin
  if SameText(AName, 'ITEM_ID') or SameText(AName, 'ID') then
    Result := View.Selection.First
  else if SameText(AName, 'LIST_ID_STR') then
    Result := View.Selection.AsString
  else if SameText(AName, 'LIST_ID_STR2') then
    Result := View.Selection.AsString(',')
  else if SameText(AName, 'LIST_ID_ARRAY') then
    Result := View.Selection.AsArray
  else
    Result := inherited OnGetWorkItemState(AName);

{  else if SameText(AName, 'IDList') then
  begin
    Result := '';
    for I := 0 to View.Selection.Count - 1 do
      if Result = '' then
        Result := VarToStr(View.Selection[I])
      else
        Result := Result + ';' + VarToStr(View.Selection[I]);
  end
  else if SameText(Result, 'IDList2') then
  begin
    Result := '';
    for I := 0 to View.Selection.Count - 1 do
      if Result = '' then
        Result := VarToStr(View.Selection[I])
      else
        Result := Result + ',' + VarToStr(View.Selection[I]);
  end
  else

    Result := inherited OnGetWorkItemState(AName);
 }
end;


procedure TEntityListPresenter.OnViewReady;
begin
  FreeOnViewClose := true;
  ViewTitle := UIInfo.Title;


{  if Assigned(GetEVList.DataSet.FindField('VIEW_TITLE')) then
    ViewTitle := VarToStr(GetEVList.DataSet.FindField('VIEW_TITLE').Value);}

  View.CommandBar.
    AddCommand(COMMAND_CLOSE, COMMAND_CLOSE_CAPTION, COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, COMMAND_RELOAD_CAPTION, COMMAND_RELOAD_SHORTCUT, CmdReload);

  if UseSelector then
    View.CommandBar.AddCommand(COMMAND_SELECTOR, 'Отбор', '', CmdSelector);

  if UIInfo.OptionExists('CanAdd') or UIInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_NEW, COMMAND_NEW_CAPTION, COMMAND_NEW_SHORTCUT, CmdNew);

  if UIInfo.OptionExists('CanOpen') or UIInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_OPEN, COMMAND_OPEN_CAPTION, COMMAND_OPEN_SHORTCUT, CmdOpen);

  if UIInfo.OptionExists('CanDelete') or UIInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_DELETE, COMMAND_DELETE_CAPTION, COMMAND_DELETE_SHORTCUT, CmdDelete);

  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_NEW_DEFAULT);
  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_ITEM_DEFAULT);

  GetEVList.DataSet.AfterPost := EViewListChangedHandler;

  (GetView as IEntityListView).SetListDataSet(GetEVList.DataSet);


  inherited;

end;


function TEntityListPresenter.GetEVList: IEntityView;
var
  evName: string;
begin
  if not FSelectorInitialized then
  begin
    if UseSelector then InitializeSelector;
    FSelectorInitialized := true;
  end;

  evName := UIInfo.EntityViewName;
  if evName = '' then evName := ENT_VIEW_LIST;
  Result := GetEView(UIInfo.EntityName, evName);
end;

procedure TEntityListPresenter.EViewListChangedHandler(
  ADataSet: TDataSet);
begin
  try
    GetEVList.Save;
  except
    GetEVList.UndoLastChange;
    raise;
  end;
end;

procedure TEntityListPresenter.CmdNew(Sender: TObject);
var
  action: IAction;
begin
  action := WorkItem.Actions[ACTION_ENTITY_NEW];
  action.Data.Value['ENTITYNAME'] := UIInfo.EntityName;
  action.Execute(WorkItem);
end;

procedure TEntityListPresenter.CmdOpen(Sender: TObject);
var
  action: IAction;
begin
  if VarIsEmpty(WorkItem.State['ITEM_ID']) then Exit;

  action := WorkItem.Actions[ACTION_ENTITY_ITEM];
  action.Data.Value['ID'] := WorkItem.State['ITEM_ID'];
  action.Data.Value['ENTITYNAME'] := UIInfo.EntityName;
  action.Execute(WorkItem);
end;


function TEntityListPresenter.UIInfo: IEntityUIInfo;
begin
  Result := (WorkItem.Services[IEntityUIManagerService] as IEntityUIManagerService).UIInfo(GetViewURI);
end;

procedure TEntityListPresenter.CmdSelector(Sender: TObject);
const
  FMT_VIEW_SELECTOR = 'Views.%s.Selector';

var
  action: IAction;
begin
  action := WorkItem.Actions[format(FMT_VIEW_SELECTOR, [UIInfo.EntityName])];
  action.Data.Assign(WorkItem);
  action.Execute(WorkItem);
  if (action.Data as TEntitySelectorPresenterData).ModalResult = mrOk then
  begin
    action.Data.AssignTo(WorkItem);
    UpdateInfoText;
    WorkItem.Commands[COMMAND_RELOAD].Execute;
  end;
end;

class function TEntityListPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TEntityListPresenterData;
end;

function TEntityListPresenter.View: IEntityListView;
begin
  Result := GetView as IEntityListView;
end;

procedure TEntityListPresenter.InitializeSelector;
var
  ds: TDataSet;
  I: integer;
begin
  ds := App.Entities[GetSelectorEntityName].GetView('Selector', WorkItem).Load(WorkItem);
  for I := 0 to ds.FieldCount - 1 do
    WorkItem.State[ds.Fields[I].FieldName] := ds.Fields[I].Value;
  UpdateInfoText;
end;

procedure TEntityListPresenter.UpdateInfoText;
var
  txt: string;
begin
  txt := VarToStr(App.Entities[GetSelectorEntityName].
    GetView('SelectorInfo', WorkItem).Load(WorkItem)[INFOTEXT_FIELD_NAME]);
  //txt := VarToStr(WorkItem.State[INFOTEXT_FIELD_NAME]);

  if GetView <> nil then
    (GetView as IEntityListView).SetInfoText(txt);
end;

function TEntityListPresenter.UseSelector: boolean;
begin
  Result := UIInfo.OptionExists('UseSelector');
end;

function TEntityListPresenter.GetSelectorEntityName: string;
begin
  Result := UIInfo.OptionValue('UseSelector');
  if Result = '' then
    Result := UIInfo.EntityName;
end;

end.
