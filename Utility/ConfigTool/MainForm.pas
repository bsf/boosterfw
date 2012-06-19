unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  IBConnectionBroker, IBSQL, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, Provider, DBClient, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, Grids, DBGrids, IBDatabase, IBCustomDataSet, IBQuery,
  DSAzure, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxMRUEdit,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, ExtCtrls, dxNavBar,
  cxGroupBox, dxNavBarCollns, dxNavBarBase, frxClass, frxPreview, frxBarcode,
  frxExportCSV, frxExportXLS, frxExportHTML, frxExportPDF, frxExportDBF,
  frxExportXML, frxExportODF, cxDBEdit, cxListBox, cxVGrid, cxDBVGrid,
  cxInplaceContainer, cxDBExtLookupComboBox, ComCtrls, ShlObj, cxShellCommon,
  cxShellListView, cxShellTreeView, cxShellComboBox, cxImage, StdCtrls, cxMemo,
  cxRichEdit, cxCustomPivotGrid, cxDBPivotGrid, Menus, cxButtons,
  cxExportPivotGridLink, cxCheckComboBox, cxDBCheckComboBox, cxCheckListBox,
  cxDBCheckListBox, IBUpdateSQL, DBXDataSnap, DBXCommon, DSConnect, SqlExpr,
  DSHTTPLayer, cxColorComboBox, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, cxTL, cxTLdxBarBuiltInMenu, cxTLData, cxDBTL,
  ButtonGroup, dxBreadcrumbEdit, dxDBBreadcrumbEdit, cxCalendar, cxCheckBox,
  cxGridBandedTableView, cxGridDBBandedTableView, cxPropertiesStore, cxCalc;

type
  TForm2 = class(TForm)
    DataSource1: TDataSource;
    IBDatabase1: TIBDatabase;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
    GridPanel1: TGridPanel;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    ClientDataSet1: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxGroupBox1: TcxGroupBox;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1NAME: TcxGridDBColumn;
    cxGrid1DBTableView1KOD: TcxGridDBColumn;
    cxGrid1DBTableView1ORG: TcxGridDBColumn;
    cxGrid1DBBandedTableView1: TcxGridDBBandedTableView;
    cxGrid1DBBandedTableView1KOD: TcxGridDBBandedColumn;
    cxGrid1DBBandedTableView1NAME: TcxGridDBBandedColumn;
    cxGrid1DBBandedTableView1ORG: TcxGridDBBandedColumn;
    cxGrid1Level1: TcxGridLevel;
    cxButton4: TcxButton;
    cxButton5: TcxButton;
    cxButton6: TcxButton;
    cxPropertiesStore1: TcxPropertiesStore;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBVerticalGrid1DBEditorRow1: TcxDBEditorRow;
    cxDBVerticalGrid1DBEditorRow2: TcxDBEditorRow;
    procedure cxGrid1DBBandedTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.cxGrid1DBBandedTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  ShowMessage('test');
end;

end.
