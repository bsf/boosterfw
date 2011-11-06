unit EntityPickListView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomDialogView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  EntityCatalogConst, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxLabel, cxTextEdit, EntityCatalogIntf, EntityPickListPresenter, UIClasses;

type
  TfrEntityPickListView = class(TfrCustomDialogView, IEntityPickListView)
    ListDataSource: TDataSource;
    pnFilter: TcxGroupBox;
    edFilter: TcxTextEdit;
    cxLabel1: TcxLabel;
    grList: TcxGrid;
    grListView: TcxGridDBTableView;
    grListLevel1: TcxGridLevel;
    procedure edFilterPropertiesChange(Sender: TObject);
    procedure grListViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
  protected
    //IPickListView
    function Selection: ISelection;
    procedure SetFilterText(const AText: string);
    function GetFilterText: string;
    procedure SetListDataSet(ADataSet: TDataSet);

  end;


implementation

{$R *.dfm}

{ TfrCustomEntityPickListView }



function TfrEntityPickListView.GetFilterText: string;
begin
  Result := edFilter.Text;
end;

function TfrEntityPickListView.Selection: ISelection;
begin
  Result := GetChildInterface(grListView.Name) as ISelection;
end;

procedure TfrEntityPickListView.SetFilterText(const AText: string);
begin
  edFilter.Properties.OnChange := nil;
  edFilter.Text := AText;
  edFilter.Properties.OnChange := edFilterPropertiesChange;
end;

procedure TfrEntityPickListView.SetListDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(ListDataSource, ADataSet);
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

end.
