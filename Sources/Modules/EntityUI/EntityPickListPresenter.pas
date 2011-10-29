unit EntityPickListPresenter;

interface
uses CustomDialogPresenter, UIClasses, CoreClasses, EntityServiceIntf,
  CustomPresenter, sysutils, db, EntityCatalogIntf, EntityCatalogConst, controls;

const
 // COMMAND_OK = 'commands://picklist.ok';
  COMMAND_FILTER_CHANGED = 'commands://picklist.filter.changed';
  COMMAND_DATA_RELOAD =  'command://picklist.data.reload';

  ENT_VIEW_PICKLIST = 'PickList';
  
type

  TEntityPickListPresenter = class(TCustomDialogPresenter)
  private
    procedure SetFilter(const AText: string);
  protected
    function View: IEntityPickListView;
    procedure OnViewReady; override;
    procedure OnViewShow; override;
    procedure CmdCancel(Sender: TObject); virtual;
    procedure CmdOK(Sender: TObject); virtual;
    procedure CmdFilterChanged(Sender: TObject); virtual;
    procedure CmdDataReload(Sender: TObject); virtual;
    procedure SelectionChangedHandler; virtual;
    function GetEVList: IEntityView; virtual;
  public
    class function ExecuteDataClass: TActionDataClass; override;
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
  GetEVList.Reload;
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
    GetEVList.ViewInfo.PrimaryKey,
    View.Selection.First, []);

  for I := 0 to GetEVList.DataSet.FieldCount - 1 do
    WorkItem.State[GetEVList.DataSet.Fields[I].FieldName] :=
      GetEVList.DataSet.Fields[I].Value;

  WorkItem.State['ModalResult'] := mrOk;
  CloseView;
end;


procedure TEntityPickListPresenter.OnViewReady;
begin
  ViewTitle := ViewInfo.Title;
  WorkItem.State['ModalResult'] := mrCancel;

  WorkItem.Commands[COMMAND_CANCEL].SetHandler(CmdCancel);
  WorkItem.Commands[COMMAND_CANCEL].Caption := COMMAND_CANCEL_CAPTION;
  WorkItem.Commands[COMMAND_CANCEL].ShortCut := 'Esc';
  View.CommandBar.AddCommand(COMMAND_CANCEL);
  
  WorkItem.Commands[COMMAND_OK].SetHandler(CmdOK);
  WorkItem.Commands[COMMAND_OK].Caption := COMMAND_OK_CAPTION;
  WorkItem.Commands[COMMAND_OK].ShortCut := 'Enter';
  (GetView as IEntityPickListView).CommandBar.AddCommand(COMMAND_OK);

  WorkItem.Commands[COMMAND_DATA_RELOAD].SetHandler(CmdDataReload);
  WorkItem.Commands[COMMAND_FILTER_CHANGED].SetHandler(CmdFilterChanged);

  View.Selection.SetSelectionChangedHandler(SelectionChangedHandler);
  View.SetListDataSet(GetEVList.DataSet);
  if GetEVList.DataSet.FieldByName('Name') <> nil then
    View.FocusDataSetControl(GetEVList.DataSet, 'Name');
  inherited;

end;

class function TEntityPickListPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TEntityPickListPresenterData;
end;

function TEntityPickListPresenter.GetEVList: IEntityView;
var
  evName: string;
begin
  evName := ViewInfo.EntityViewName;
  if evName = '' then evName := ENT_VIEW_PICKLIST;
  Result := GetEView(ViewInfo.EntityName, evName);
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
  FilterByName = 'Substring(upper(name), 1, %d) = upper(''%s'')';
  FilterByID = 'ID = %d';

var
  filterStr: string;
  searchText: string;
  searchID: integer;
begin
  searchText := Trim(AText);
  if not TryStrToInt(searchText, searchID) then
    filterStr := format(FilterByName, [length(searchText), searchText])
  else
    filterStr := format(FilterByID, [searchID]);

  GetEVList.DataSet.Filter := filterStr;
  GetEVList.DataSet.Filtered := filterStr <> '';

  View.SetFilterText(searchText);

end;

function TEntityPickListPresenter.View: IEntityPickListView;
begin
  Result := GetView as IEntityPickListView;
end;

end.
