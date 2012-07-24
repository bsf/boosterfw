unit EntityPickListView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomDialogView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  EntityCatalogConst, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxLabel, cxTextEdit, EntityCatalogIntf, EntityPickListPresenter, UIClasses,
  cxPC, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxTLData, cxDBTL,
  cxPCdxBarPopupMenu;

type
  TfrEntityPickListView = class(TfrCustomDialogView, IEntityPickListView)
    ListDataSource: TDataSource;
    pnFilter: TcxGroupBox;
    edFilter: TcxTextEdit;
    lbFilter: TcxLabel;
    pcListContainer: TcxPageControl;
    tsGridList: TcxTabSheet;
    tsTreeList: TcxTabSheet;
    grList: TcxGrid;
    grListView: TcxGridDBTableView;
    grListLevel1: TcxGridLevel;
    grTreeList: TcxDBTreeList;
    procedure edFilterPropertiesChange(Sender: TObject);
    procedure grListViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure grTreeListDblClick(Sender: TObject);
  private
    FViewMode: TPickListViewMode;
    FCanParentSelect: boolean;

    function CmdOKCondition(const CommandName: string;
      Sender: TObject): boolean;

  protected
    //IPickListView
    function Selection: ISelection;
    procedure SetFilterText(const AText: string);
    function GetFilterText: string;
    procedure SetListDataSet(ADataSet: TDataSet);
    procedure SetViewMode(AViewMode: TPickListViewMode);
    procedure SetCanParentSelect(AValue: boolean);
    procedure OnInitialize; override;
  end;


implementation

{$R *.dfm}

type
  TcxDBTreeListHack = class(TcxDBTreeList)

  end;
{ TfrCustomEntityPickListView }



function TfrEntityPickListView.GetFilterText: string;
begin
  Result := edFilter.Text;
end;

function TfrEntityPickListView.Selection: ISelection;
begin
  if FViewMode = pvmTreeList then
    Result := GetChildInterface(grTreeList.Name) as ISelection
  else
    Result := GetChildInterface(grListView.Name) as ISelection;
end;

procedure TfrEntityPickListView.SetCanParentSelect(AValue: boolean);
begin
  FCanParentSelect := AValue;
end;

procedure TfrEntityPickListView.SetFilterText(const AText: string);
var
  col: TcxDBTreeListColumn;
begin
  edFilter.Properties.OnChange := nil;
  edFilter.Text := AText;
  edFilter.Properties.OnChange := edFilterPropertiesChange;

  if FViewMode = pvmTreeList then
  begin
    col := grTreeList.GetColumnByFieldName('Name');
    if col <> nil then
    begin
      col.MakeVisible;
      col.Focused := true;
      TcxDBTreeListHack(grTreeList).Controller.IncSearchText := AText;
    end;
  end;
end;

procedure TfrEntityPickListView.SetListDataSet(ADataSet: TDataSet);
var
  col: TcxDBTreeListColumn;
begin
  LinkDataSet(ListDataSource, ADataSet);

  if FViewMode = pvmTreeList then
  begin
    grTreeList.Root.Collapse(true);
    col := grTreeList.GetColumnByFieldName('Name');
    if col <> nil then
    begin
      col.MakeVisible;
      col.Focused := true;
    end;

    //if grTreeList.VisibleColumnCount > 0 then
      //grTreeList.VisibleColumns[0].Focused := true;
  end;
end;

procedure TfrEntityPickListView.SetViewMode(AViewMode: TPickListViewMode);
begin
  FViewMode := AViewMode;
  case FViewMode of
    pvmList: begin
      grTreeList.DataController.DataSource := nil;
      grListView.DataController.DataSource := ListDataSource;
      pcListContainer.ActivePage := tsGridList;
      pnFilter.Visible := true;
    end;

    pvmTreeList: begin
      grListView.DataController.DataSource := nil;
      grTreeList.DataController.DataSource := ListDataSource;
      pcListContainer.ActivePage := tsTreeList;
      pnFilter.Visible := false;
    end;
  end;

end;

function TfrEntityPickListView.CmdOKCondition(const CommandName: string;
  Sender: TObject): boolean;
begin
  Result := true;
  if FViewMode = pvmTreeList then
    Result :=
      (grTreeList.SelectionCount > 0) and
      ((not grTreeList.Selections[0].HasChildren)
        or
       (grTreeList.Selections[0].HasChildren and FCanParentSelect));

end;

procedure TfrEntityPickListView.edFilterPropertiesChange(
  Sender: TObject);
begin
  WorkItem.Commands[COMMAND_FILTER_CHANGED].Execute;
end;

procedure TfrEntityPickListView.grListViewCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[COMMAND_OK].Execute;
end;

procedure TfrEntityPickListView.grTreeListDblClick(Sender: TObject);
begin
  if  grTreeList.HitTest.HitAtColumn and
      (grTreeList.SelectionCount > 0) and
      (not grTreeList.Selections[0].HasChildren)  then
    WorkItem.Commands[COMMAND_OK].Execute;
end;

procedure TfrEntityPickListView.OnInitialize;
begin
  WorkItem.Commands[COMMAND_OK].RegisterCondition(CmdOKCondition);
end;

end.
