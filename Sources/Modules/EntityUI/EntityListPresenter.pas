unit EntityListPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  cxClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter,
  EntityCatalogIntf, EntityCatalogConst, db, controls, UIStr, StrUtils;

const
  COMMAND_SELECTOR = '{0D2B32E3-7CE0-4775-A2D3-3A91ED2AFEFB}';//'commands.view.selector';
  INFOTEXT_FIELD_NAME = 'INFO';



  ENT_VIEW_NEW_DEFAULT = 'New';
  ENT_VIEW_ITEM_DEFAULT = 'Item';


type
  IEntityListView = interface(IContentView)
  ['{B1E6FCB6-EAC1-4B63-880F-C662B09579B4}']
    function Selection: ISelection;
    procedure SetListDataSet(ADataSet: TDataSet);
    procedure SetInfoText(const AText: string);
  end;

  TEntityListPresenter = class(TEntityContentPresenter)
  const
    ENT_VIEW_LIST = 'List';
  private
    FCanEdit: boolean;
    FCanOpen: boolean;
    FCanAdd: boolean;
    FCanDelete: boolean;

    FIsReady: boolean;
    FSelectorInitialized: boolean;
    function UseSelector: boolean;
    function GetSelectorEntityName: string;
    procedure InitializeSelector;
    procedure UpdateInfoText;
    procedure CmdReload(Sender: TObject);

    procedure CmdDelete(Sender: TObject);
    procedure CmdSelector(Sender: TObject);

    procedure EViewListChangedHandler(ADataSet: TDataSet);
    procedure SelectionChangedHandler;
    function View: IEntityListView;
  protected
    procedure OnUpdateCommandStatus; override;
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    //
    function GetEVList: IEntityView;

    procedure OnViewReady; override;
    //
    function GetSelectedIDList: Variant;
  end;

implementation

{ TEntityListPresenter }

procedure TEntityListPresenter.CmdReload(Sender: TObject);
begin
  GetEVList.Load;
end;


procedure TEntityListPresenter.CmdDelete(Sender: TObject);
var
  cResult: boolean;
begin
  cResult := App.UI.MessageBox.ConfirmYesNo('Удалить выделенные записи?');
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

function TEntityListPresenter.OnGetWorkItemState(const AName: string;
  var Done: boolean): Variant;
const
  const_EV_FIELD_PREFIX = 'EV.';

var
  ds: TDataSet;
  fieldName: string;
begin
  Done := true;
  if SameText(AName, 'ITEM_ID') {or SameText(AName, 'ID')} then
    Result := View.Selection.First
  else if SameText(AName, 'LIST_ID_STR') then
    Result := View.Selection.AsString
  else if SameText(AName, 'LIST_ID_STR2') then
    Result := View.Selection.AsString(',')
  else if SameText(AName, 'LIST_ID_ARRAY') then
    Result := View.Selection.AsArray
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


procedure TEntityListPresenter.OnUpdateCommandStatus;
begin
  WorkItem.Commands[COMMAND_NEW].Status := csDisabled;
  WorkItem.Commands[COMMAND_OPEN].Status := csDisabled;
  WorkItem.Commands[COMMAND_DELETE].Status := csDisabled;

  if (FCanAdd or FCanEdit) then
    WorkItem.Commands[COMMAND_NEW].Status := csEnabled;

  if (View.Selection.Count > 0) and (FCanOpen or FCanEdit) then
    WorkItem.Commands[COMMAND_OPEN].Status := csEnabled;

  if (View.Selection.Count > 0) and (FCanDelete or FCanEdit) then
    WorkItem.Commands[COMMAND_DELETE].Status := csEnabled;
end;

procedure TEntityListPresenter.OnViewReady;
begin
  FreeOnViewClose := true;
  ViewTitle := ViewInfo.Title;

  if ViewInfo.OptionExists('Title') then
     ViewTitle :=
       VarToStr(GetEView(EntityName, ViewInfo.OptionValue('Title')).DataSet.Fields[0].Value);

{  if Assigned(GetEVList.DataSet.FindField('VIEW_TITLE')) then
    ViewTitle := VarToStr(GetEVList.DataSet.FindField('VIEW_TITLE').Value);}

  View.CommandBar.
    AddCommand(COMMAND_CLOSE, GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, GetLocaleString(@COMMAND_RELOAD_CAPTION), COMMAND_RELOAD_SHORTCUT);
  WorkItem.Commands[COMMAND_RELOAD].SetHandler(CmdReload);

  if UseSelector then
  begin
    View.CommandBar.AddCommand(COMMAND_SELECTOR, GetLocaleString(@COMMAND_SELECTOR_CAPTION));
    WorkItem.Commands[COMMAND_SELECTOR].SetHandler(CmdSelector);
  end;

  FCanEdit := ViewInfo.OptionExists('CanEdit');
  FCanAdd := ViewInfo.OptionExists('CanAdd');
  FCanOpen := ViewInfo.OptionExists('CanOpen');
  FCanDelete := ViewInfo.OptionExists('CanDelete');

  if FCanAdd or FCanEdit then
    View.CommandBar.AddCommand(COMMAND_NEW, GetLocaleString(@COMMAND_NEW_CAPTION), COMMAND_NEW_SHORTCUT);

  if FCanOpen or FCanEdit then
    View.CommandBar.AddCommand(COMMAND_OPEN, GetLocaleString(@COMMAND_OPEN_CAPTION), COMMAND_OPEN_SHORTCUT);

  if FCanDelete or FCanEdit then
  begin
    View.CommandBar.AddCommand(COMMAND_DELETE, GetLocaleString(@COMMAND_DELETE_CAPTION), COMMAND_DELETE_SHORTCUT);
    WorkItem.Commands[COMMAND_DELETE].SetHandler(CmdDelete);
  end;

  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_NEW_DEFAULT);
  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_ITEM_DEFAULT);

  GetEVList.DataSet.AfterPost := EViewListChangedHandler;

  (GetView as IEntityListView).SetListDataSet(GetEVList.DataSet);


  FIsReady := true;

  View.Selection.SetSelectionChangedHandler(SelectionChangedHandler);

  SelectionChangedHandler;
end;


procedure TEntityListPresenter.SelectionChangedHandler;
begin
  UpdateCommandStatus;
end;

function TEntityListPresenter.GetEVList: IEntityView;
begin
  if not FSelectorInitialized then
  begin
    if UseSelector then InitializeSelector;
    FSelectorInitialized := true;
  end;

  Result := GetEView(EntityName, EntityViewName);
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


procedure TEntityListPresenter.CmdSelector(Sender: TObject);
const
  FMT_VIEW_SELECTOR = 'Views.%s.Selector';
begin
  with WorkItem.Activities[format(FMT_VIEW_SELECTOR, [GetSelectorEntityName])] do
  begin
    Params.Assign(WorkItem);
    Execute(WorkItem);
    if Outs[TViewActivityOuts.ModalResult] = mrOk then
    begin
      Outs.AssignTo(WorkItem);
      UpdateInfoText;
      WorkItem.Commands[COMMAND_RELOAD].Execute;
    end;
  end;
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
  ds := App.Entities[GetSelectorEntityName].GetView('Selector', WorkItem).Load;
  for I := 0 to ds.FieldCount - 1 do
    WorkItem.State[ds.Fields[I].FieldName] := ds.Fields[I].Value;
  UpdateInfoText;
end;

procedure TEntityListPresenter.UpdateInfoText;
var
  txt: string;
begin
  txt := VarToStr(App.Entities[GetSelectorEntityName].
    GetView('SelectorInfo', WorkItem).Load[INFOTEXT_FIELD_NAME]);
  //txt := VarToStr(WorkItem.State[INFOTEXT_FIELD_NAME]);

  if GetView <> nil then
    (GetView as IEntityListView).SetInfoText(txt);
end;

function TEntityListPresenter.UseSelector: boolean;
begin
  Result := ViewInfo.OptionExists('UseSelector');
end;

function TEntityListPresenter.GetSelectorEntityName: string;
begin
  Result := ViewInfo.OptionValue('UseSelector');
  if Result = '' then
    Result := EntityName;
end;

end.
