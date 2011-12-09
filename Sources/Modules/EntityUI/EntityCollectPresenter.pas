unit EntityCollectPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr;

const
  COMMAND_LIST_SELECTED = '{EE438AAA-D7D9-4849-9958-DD6FDED59783}';
  COMMAND_ITEMS_SELECTED = '{DF4F1801-D1F9-4270-A862-E200D3028FA3}';
  COMMAND_ADD_BULK = '{0D98A6A2-A720-4FB9-8CB4-E9515F89F573}';
  COMMAND_ADD_ITEM = 'command.add';

  ENT_VIEW_NEW_DEFAULT = 'DetailNew';
  ENT_VIEW_ITEM_DEFAULT = 'Detail';

  ENT_VIEW_INFO = 'CollectInfo';
  ENT_VIEW_LIST = 'CollectList';
  ENT_VIEW_ITEMS = 'CollectItems';
  ENT_OPER_ADD = 'CollectAdd';

type
  IEntityCollectView = interface(IContentView)
  ['{E6CD76D9-2A5C-4BA2-93C5-BBF13CA41A07}']
    procedure SetCommandAddDef(const AName: string);
    function SelectionList: ISelection;
    function SelectionItems: ISelection;
    procedure SetData(AInfo, AList, AItems: TDataSet);
  end;

  TEntityCollectPresenter = class(TEntityContentPresenter)
  private
    function View: IEntityCollectView;
    procedure CmdClose(Sender: TObject);
    procedure CmdReload(Sender: TObject);
    procedure CmdAddBulk(Sender: TObject);
    procedure CmdAddItem(Sender: TObject);
    procedure CmdOpen(Sender: TObject);
    procedure CmdDelete(Sender: TObject);
    procedure CmdListSelected(Sender: TObject);
    procedure CmdItemsSelected(Sender: TObject);

    function GetEVList: IEntityView;
    function GetEVInfo: IEntityView;
    function GetEVItems: IEntityView;

    procedure ReloadCallerWorkItem;
  protected
    function OnGetWorkItemState(const AName: string): Variant; override;
    procedure OnUpdateCommandStatus; override;
    procedure OnViewReady; override;
  end;

implementation

{ TEntityCollectPresenter }

procedure TEntityCollectPresenter.CmdClose(Sender: TObject);
begin
  CloseView;
end;

procedure TEntityCollectPresenter.CmdReload(Sender: TObject);
begin
  GetEVList.Reload;
  GetEVInfo.Reload;
  GetEVItems.Reload;
end;

function TEntityCollectPresenter.GetEVList: IEntityView;
begin
  Result := GetEView(EntityName, ENT_VIEW_LIST);
end;

function TEntityCollectPresenter.GetEVInfo: IEntityView;
begin
  Result := GetEView(EntityName, ENT_VIEW_INFO);
end;

function TEntityCollectPresenter.OnGetWorkItemState(
  const AName: string): Variant;
begin
  if SameText(AName, 'ITEM_ID') then
    Result := View.SelectionItems.First
  else if SameText(AName, 'LIST_ID') then
    Result := View.SelectionList.First
  else if SameText(AName, 'HID') then
    Result := WorkItem.State['ID']
  else if (not SameText(AName, 'ID')) and GetEVList.IsLoaded and (GetEVList.DataSet.FindField(AName) <> nil) then
    Result := GetEVList.DataSet[AName];

end;


procedure TEntityCollectPresenter.OnViewReady;
begin
  ViewTitle := ViewInfo.Title;

  View.CommandBar.
    AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD,
      GetLocaleString(@COMMAND_RELOAD_CAPTION), COMMAND_RELOAD_SHORTCUT, CmdReload);

  if ViewInfo.OptionExists('BulkModeOnly') then
  begin
    View.CommandBar.AddCommand(COMMAND_ADD_BULK, 'Добавить', 'Enter', CmdAddBulk);
    View.SetCommandAddDef(COMMAND_ADD_BULK);
  end
  else if ViewInfo.OptionExists('BulkMode') then
  begin
    View.CommandBar.AddCommand(COMMAND_ADD_BULK, 'Добавить', 'Enter', CmdAddBulk, 'Добавить');
    View.CommandBar.AddCommand(COMMAND_ADD_ITEM, 'Добавить запись', 'Ins', CmdAddItem, 'Добавить');
    View.SetCommandAddDef(COMMAND_ADD_BULK);
  end
  else
  begin
    View.CommandBar.AddCommand(COMMAND_ADD_ITEM, 'Добавить', 'Enter', CmdAddItem);
    View.SetCommandAddDef(COMMAND_ADD_ITEM);
  end;

  View.SelectionList.CanMultiSelect := ViewInfo.OptionExists('BulkMode') or ViewInfo.OptionExists('BulkModeOnly');

//  if ViewInfo.OptionExists('CanOpenItem')  then
    View.CommandBar.AddCommand(COMMAND_OPEN, GetLocaleString(@COMMAND_OPEN_CAPTION),
      COMMAND_OPEN_SHORTCUT, CmdOpen);

  //if ViewInfo.OptionExists('CanDelete') or ViewInfo.OptionExists('CanEdit') then
  View.CommandBar.AddCommand(COMMAND_DELETE, GetLocaleString(@COMMAND_DELETE_CAPTION),
    COMMAND_DELETE_SHORTCUT, CmdDelete);

  GetEVItems.SynchronizeOnEntityChange(GetEVItems.EntityName, ENT_VIEW_NEW_DEFAULT);
  GetEVItems.SynchronizeOnEntityChange(GetEVItems.EntityName, ENT_VIEW_ITEM_DEFAULT);

  WorkItem.Commands[COMMAND_LIST_SELECTED].SetHandler(CmdListSelected);
  WorkItem.Commands[COMMAND_ITEMS_SELECTED].SetHandler(CmdItemsSelected);
  View.SelectionList.SetChangedCommand(COMMAND_LIST_SELECTED);
  View.SelectionItems.SetChangedCommand(COMMAND_ITEMS_SELECTED);

  View.SetData(GetEVInfo.DataSet, GetEVList.DataSet, GetEVItems.DataSet);

end;


function TEntityCollectPresenter.View: IEntityCollectView;
begin
  Result := GetView as IEntityCollectView;
end;

procedure TEntityCollectPresenter.CmdDelete(Sender: TObject);
var
  I: integer;
begin

  if not App.UI.MessageBox.ConfirmYesNo('Удалить выделенные записи?') then Exit;

  try
    if View.SelectionItems.Count = 1 then
    begin
      if GetEVItems.DataSet.Locate(GetEVItems.Info.PrimaryKey, View.SelectionItems.First, []) then
        try
          GetEVItems.DataSet.Delete;
          GetEVItems.Save;
        except
          GetEVItems.CancelUpdates;
          raise;
        end;
    end
    else
    begin
      for I := View.SelectionItems.Count - 1 downto 0 do
        if GetEVItems.DataSet.Locate(GetEVItems.Info.PrimaryKey, View.SelectionItems[I], []) then
          GetEVItems.DataSet.Delete;
      try
        GetEVItems.Save;
      except
        GetEVItems.Reload;
        raise;
      end;
    end;
  finally
    GetEVInfo.Reload;
    if ViewInfo.OptionExists('ReloadList') then
      GetEVList.Reload;
    ReloadCallerWorkItem;  
  end;
end;

procedure TEntityCollectPresenter.CmdAddItem(Sender: TObject);
begin
  with WorkItem.Activities[ACTION_ENTITY_DETAIL_NEW] do
  begin
    Params['HID'] := WorkItem.State['HID'];
    Params['ENTITYNAME'] := EntityName;
    Execute(WorkItem);
  end;
end;

procedure TEntityCollectPresenter.CmdOpen(Sender: TObject);
begin
  if VarIsEmpty(WorkItem.State['ITEM_ID']) then Exit;

  with WorkItem.Activities[ACTION_ENTITY_DETAIL] do
  begin
    Params['ID'] := WorkItem.State['ITEM_ID'];
    Params['ENTITYNAME'] := EntityName;
    Execute(WorkItem);
  end;
end;


procedure TEntityCollectPresenter.OnUpdateCommandStatus;
begin
  WorkItem.Commands[COMMAND_ADD_ITEM].Status := csDisabled;
  WorkItem.Commands[COMMAND_ADD_BULK].Status := csDisabled;
  WorkItem.Commands[COMMAND_OPEN].Status := csDisabled;
  WorkItem.Commands[COMMAND_DELETE].Status := csDisabled;

  if (View.SelectionList.Count > 0) then
  begin
    WorkItem.Commands[COMMAND_ADD_ITEM].Status := csEnabled;
    WorkItem.Commands[COMMAND_ADD_BULK].Status := csEnabled;
  end;

  if (View.SelectionItems.Count > 0) then
    WorkItem.Commands[COMMAND_DELETE].Status := csEnabled;

  if View.SelectionItems.Count > 0 then
    WorkItem.Commands[COMMAND_OPEN].Status := csEnabled;
end;

function TEntityCollectPresenter.GetEVItems: IEntityView;
begin
  Result := GetEView(EntityName, ENT_VIEW_ITEMS);
end;

procedure TEntityCollectPresenter.CmdItemsSelected(Sender: TObject);
begin
  UpdateCommandStatus;
end;

procedure TEntityCollectPresenter.CmdListSelected(Sender: TObject);
begin
  UpdateCommandStatus;
end;


procedure TEntityCollectPresenter.CmdAddBulk(Sender: TObject);
var
  I: integer;
  oper: IEntityOper;
begin
  try
    oper := App.Entities[EntityName].GetOper(ENT_OPER_ADD, WorkItem);
    for I := 0 to View.SelectionList.Count - 1 do
    begin
      oper.ParamsBind;
      oper.Params.ParamByName('HID').Value := WorkItem.State['HID'];
      oper.Params.ParamByName('LIST_ID').Value :=View.SelectionList[I];
      oper.Execute;
    end;
  finally
    GetEVInfo.Reload;
    GetEVItems.Reload;
    if ViewInfo.OptionExists('ReloadList') then
      GetEVList.Reload;
    ReloadCallerWorkItem;
    GetEVItems.ReloadLinksData;
  end;


end;

procedure TEntityCollectPresenter.ReloadCallerWorkItem;
var
  CallerWI: TWorkItem;
begin
  CallerWI := WorkItem.Root.WorkItems.Find(CallerURI);
  if CallerWI <> nil then
    CallerWI.Commands[COMMAND_RELOAD].Execute;
end;

end.
