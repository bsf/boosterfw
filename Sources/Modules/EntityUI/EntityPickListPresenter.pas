unit EntityPickListPresenter;

interface
uses CustomDialogPresenter, UIClasses, CoreClasses, EntityServiceIntf,
  CustomPresenter, sysutils, db, controls, UIStr;

const
 // COMMAND_OK = 'commands://picklist.ok';
  COMMAND_FILTER_CHANGED = 'commands://picklist.filter.changed';
  COMMAND_DATA_RELOAD =  'command://picklist.data.reload';
  COMMAND_SHOW_CLOSED = '{B821AEAE-5C78-42F4-819F-E898DB24B4C7}';
  ENT_VIEW_PICKLIST = 'PickList';

  SHOW_CLOSED_PARAM = 'SHOW_CLOSED';

type
  TPickListViewMode = (pvmList, pvmTreeList);


  IEntityPickListView = interface
  ['{87CC1751-FFA3-4F9E-9336-5C4E9D765593}']
    function Selection: ISelection;
    procedure SetFilterText(const AText: string);
    function GetFilterText: string;
    procedure SetListDataSet(ADataSet: TDataSet);
    procedure SetViewMode(AViewMode: TPickListViewMode);
    procedure SetCanParentSelect(AValue: boolean);
  end;

  TEntityPickListPresenter = class(TCustomDialogPresenter)
  private
    FViewMode: TPickListViewMode;
    procedure SetFilter(const AText: string);
  protected
    function View: IEntityPickListView;
    procedure OnViewReady; override;
    procedure OnViewShow; override;
    procedure CmdShowClosed(Sender: TObject);
    procedure CmdCancel(Sender: TObject); virtual;
    procedure CmdOK(Sender: TObject); virtual;
    procedure CmdFilterChanged(Sender: TObject); virtual;
    procedure CmdDataReload(Sender: TObject); virtual;
    procedure SelectionChangedHandler; virtual;
    function GetEVList: IEntityView; virtual;
  end;


implementation


{ TEntityPickListPresenter }

procedure TEntityPickListPresenter.CmdCancel(Sender: TObject);
begin
  WorkItem.State['ModalResult'] := mrCancel;
  CloseView;
end;

procedure TEntityPickListPresenter.CmdDataReload(Sender: TObject);
begin
  GetEVList.Load;
end;

procedure TEntityPickListPresenter.CmdFilterChanged(Sender: TObject);
begin
  SetFilter(View.GetFilterText);
end;

procedure TEntityPickListPresenter.CmdOK(Sender: TObject);
var
  I: integer;
begin
  if View.Selection.Count = 0 then Exit;
  GetEVList.DataSet.Locate(
    GetEVList.Info.PrimaryKey,
    View.Selection.First, []);

  for I := 0 to GetEVList.DataSet.FieldCount - 1 do
    WorkItem.State[GetEVList.DataSet.Fields[I].FieldName] :=
      GetEVList.DataSet.Fields[I].Value;

  WorkItem.State['ModalResult'] := mrOk;
  CloseView;
end;


procedure TEntityPickListPresenter.CmdShowClosed(Sender: TObject);
begin
  WorkItem.State[SHOW_CLOSED_PARAM] := 1;
  GetEVList.Load;
end;

procedure TEntityPickListPresenter.OnViewReady;
begin
  ViewTitle := ViewInfo.Title;
  WorkItem.State['ModalResult'] := mrCancel;
  WorkItem.State[SHOW_CLOSED_PARAM] := 0;


  if ViewInfo.OptionValue('ViewMode') = 'Tree' then
    FViewMode := pvmTreeList
  else
    FViewMode := pvmList;

  View.SetViewMode(FViewMode);
  View.SetCanParentSelect(ViewInfo.OptionExists('CanParentSelect'));

  WorkItem.Commands[COMMAND_OK].SetHandler(CmdOK);
  GetView.CommandBar.AddCommand(COMMAND_OK,
    GetLocaleString(@COMMAND_OK_CAPTION), 'Enter', '', false);

  WorkItem.Commands[COMMAND_CANCEL].SetHandler(CmdCancel);
  GetView.CommandBar.AddCommand(COMMAND_CANCEL,
    GetLocaleString(@COMMAND_CANCEL_CAPTION), 'Esc', '', false);

  WorkItem.Commands[COMMAND_DATA_RELOAD].SetHandler(CmdDataReload);
  WorkItem.Commands[COMMAND_FILTER_CHANGED].SetHandler(CmdFilterChanged);

  View.Selection.SetSelectionChangedHandler(SelectionChangedHandler);
  View.SetListDataSet(GetEVList.DataSet);
  if GetEVList.DataSet.FieldByName('Name') <> nil then
    GetView.FocusDataSetControl(GetEVList.DataSet, 'Name');
  inherited;

end;

function TEntityPickListPresenter.GetEVList: IEntityView;
var
  evName: string;
begin
  evName := EntityViewName;
  if evName = '' then evName := ENT_VIEW_PICKLIST;
  Result := GetEView(EntityName, evName);
end;

procedure TEntityPickListPresenter.OnViewShow;
begin
  SetFilter(WorkItem.State['Filter']);
end;

procedure TEntityPickListPresenter.SelectionChangedHandler;
begin
  if View.Selection.Count > 0 then
    WorkItem.Commands[COMMAND_OK].Status := csEnabled
  else
    WorkItem.Commands[COMMAND_OK].Status := csDisabled;
end;

procedure TEntityPickListPresenter.SetFilter(const AText: string);
const
  FilterByName = '(Substring(upper(name), 1, %d) = upper(''%s''))';
  FilterByID = '(ID = %d)';

var
  filterStr: string;
  searchText: string;
  searchID: integer;
begin
  searchText := Trim(AText);

  if FViewMode = pvmList then
  begin
    if TryStrToInt(searchText, searchID) then
    begin
      filterStr := format(FilterByID, [searchID]);
      filterStr := filterStr + ' or ' +
      format(FilterByName, [length(searchText), searchText]);
    end
    else
      filterStr := format(FilterByName, [length(searchText), searchText]);

    GetEVList.DataSet.Filter := filterStr;
    GetEVList.DataSet.Filtered := filterStr <> '';

    View.SetFilterText(searchText);
  end
  else
  begin
    if GetEVList.DataSet.Locate('NAME', searchText, [loCaseInsensitive, loPartialKey]) then
      View.SetFilterText(searchText);
  end;
end;

function TEntityPickListPresenter.View: IEntityPickListView;
begin
  Result := GetView as IEntityPickListView;
end;

end.
