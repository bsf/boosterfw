unit EntityTreeListPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  cxClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter,
  EntityCatalogIntf, EntityCatalogConst, db, controls, UIStr;

const
  COMMAND_SELECTOR = '{0D2B32E3-7CE0-4775-A2D3-3A91ED2AFEFB}';//'commands.view.selector';
  INFOTEXT_FIELD_NAME = 'INFO';



  ENT_VIEW_NEW_DEFAULT = 'New';
  ENT_VIEW_ITEM_DEFAULT = 'Item';


type
  IEntityTreeListView = interface(IContentView)
  ['{B1E6FCB6-EAC1-4B63-880F-C662B09579B4}']
    function Selection: ISelection;
    procedure SetListDataSet(ADataSet: TDataSet);
    procedure SetInfoText(const AText: string);
  end;

  TEntityTreeListPresenter = class(TEntityContentPresenter)
  const
    ENT_VIEW_LIST = 'List';
  private
    FIsReady: boolean;
    FSelectorInitialized: boolean;
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
    function View: IEntityTreeListView;
  protected
    function EntityViewName: string; override;
    function OnGetWorkItemState(const AName: string): Variant; override;
    //
    function GetEVList: IEntityView;

    procedure OnViewReady; override;
    //
    function GetSelectedIDList: Variant;
  end;

implementation

{ TEntityListPresenter }

procedure TEntityTreeListPresenter.CmdReload(Sender: TObject);
begin
  GetEVList.Reload;
end;


procedure TEntityTreeListPresenter.CmdDelete(Sender: TObject);
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

function TEntityTreeListPresenter.GetSelectedIDList: Variant;
var
  I: integer;
begin
  if (GetView as IEntityTreeListView).Selection.Count > 0 then
  begin
    Result := VarArrayCreate([0, (GetView as IEntityTreeListView).Selection.Count - 1], varVariant);
    for I := 0 to (GetView as IEntityTreeListView).Selection.Count - 1 do
      Result[I] := (GetView as IEntityTreeListView).Selection.Items[I];
  end
  else
    Result := Unassigned;
end;

function TEntityTreeListPresenter.OnGetWorkItemState(const AName: string): Variant;
var
  ds: TDataSet;
begin
  if SameText(AName, 'ITEM_ID') or SameText(AName, 'ID') then
    Result := View.Selection.First
  else if SameText(AName, 'LIST_ID_STR') then
    Result := View.Selection.AsString
  else if SameText(AName, 'LIST_ID_STR2') then
    Result := View.Selection.AsString(',')
  else if SameText(AName, 'LIST_ID_ARRAY') then
    Result := View.Selection.AsArray
  else if FIsReady then
  begin
    ds := App.Entities[EntityName].GetView(EntityViewName, WorkItem).DataSet;
    if ds.FindField(AName) <> nil then
      Result := ds[AName];
  end
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


procedure TEntityTreeListPresenter.OnViewReady;
begin
  FreeOnViewClose := true;
  ViewTitle := ViewInfo.Title;

  if ViewInfo.OptionExists('Title') then
     ViewTitle :=
       VarToStr(GetEView(EntityName, ViewInfo.OptionValue('Title')).DataSet.Fields[0].Value);

{  if Assigned(GetEVList.DataSet.FindField('VIEW_TITLE')) then
    ViewTitle := VarToStr(GetEVList.DataSet.FindField('VIEW_TITLE').Value);}

  View.CommandBar.
    AddCommand(COMMAND_CLOSE, GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, GetLocaleString(@COMMAND_RELOAD_CAPTION), COMMAND_RELOAD_SHORTCUT, CmdReload);

  if UseSelector then
    View.CommandBar.AddCommand(COMMAND_SELECTOR, GetLocaleString(@COMMAND_SELECTOR_CAPTION), '', CmdSelector);

  if ViewInfo.OptionExists('CanAdd') or ViewInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_NEW, GetLocaleString(@COMMAND_NEW_CAPTION), COMMAND_NEW_SHORTCUT, CmdNew);

  if ViewInfo.OptionExists('CanOpen') or ViewInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_OPEN, GetLocaleString(@COMMAND_OPEN_CAPTION), COMMAND_OPEN_SHORTCUT, CmdOpen);

  if ViewInfo.OptionExists('CanDelete') or ViewInfo.OptionExists('CanEdit') then
    View.CommandBar.AddCommand(COMMAND_DELETE, GetLocaleString(@COMMAND_DELETE_CAPTION), COMMAND_DELETE_SHORTCUT, CmdDelete);

  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_NEW_DEFAULT);
  GetEVList.SynchronizeOnEntityChange(GetEVList.EntityName, ENT_VIEW_ITEM_DEFAULT);

  GetEVList.DataSet.AfterPost := EViewListChangedHandler;

  (GetView as IEntityTreeListView).SetListDataSet(GetEVList.DataSet);


  FIsReady := true;


end;


function TEntityTreeListPresenter.GetEVList: IEntityView;
begin
  if not FSelectorInitialized then
  begin
    if UseSelector then InitializeSelector;
    FSelectorInitialized := true;
  end;

  Result := GetEView(EntityName, EntityViewName);
end;

function TEntityTreeListPresenter.EntityViewName: string;
begin
  Result := inherited EntityViewName;
  if Result = '' then
    Result := ENT_VIEW_LIST;
end;

procedure TEntityTreeListPresenter.EViewListChangedHandler(
  ADataSet: TDataSet);
begin
  try
    GetEVList.Save;
  except
    GetEVList.UndoLastChange;
    raise;
  end;
end;

procedure TEntityTreeListPresenter.CmdNew(Sender: TObject);
begin
  with WorkItem.Activities[ACTION_ENTITY_NEW] do
  begin
    Params[TEntityNewActionParams.EntityName] := EntityName;
    Execute(WorkItem);
  end;
end;

procedure TEntityTreeListPresenter.CmdOpen(Sender: TObject);
begin
  if VarIsEmpty(WorkItem.State['ITEM_ID']) then Exit;

  with WorkItem.Activities[ACTION_ENTITY_ITEM] do
  begin
    Params[TEntityItemActionParams.ID] := WorkItem.State['ITEM_ID'];
    Params[TEntityItemActionParams.EntityName] := EntityName;
    Execute(WorkItem);
  end;
end;



procedure TEntityTreeListPresenter.CmdSelector(Sender: TObject);
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


function TEntityTreeListPresenter.View: IEntityTreeListView;
begin
  Result := GetView as IEntityTreeListView;
end;

procedure TEntityTreeListPresenter.InitializeSelector;
var
  ds: TDataSet;
  I: integer;
begin
  ds := App.Entities[GetSelectorEntityName].GetView('Selector', WorkItem).Load(WorkItem);
  for I := 0 to ds.FieldCount - 1 do
    WorkItem.State[ds.Fields[I].FieldName] := ds.Fields[I].Value;
  UpdateInfoText;
end;

procedure TEntityTreeListPresenter.UpdateInfoText;
var
  txt: string;
begin
  txt := VarToStr(App.Entities[GetSelectorEntityName].
    GetView('SelectorInfo', WorkItem).Load(WorkItem)[INFOTEXT_FIELD_NAME]);
  //txt := VarToStr(WorkItem.State[INFOTEXT_FIELD_NAME]);

  if GetView <> nil then
    (GetView as IEntityTreeListView).SetInfoText(txt);
end;

function TEntityTreeListPresenter.UseSelector: boolean;
begin
  Result := ViewInfo.OptionExists('UseSelector');
end;

function TEntityTreeListPresenter.GetSelectorEntityName: string;
begin
  Result := ViewInfo.OptionValue('UseSelector');
  if Result = '' then
    Result := EntityName;
end;

end.
