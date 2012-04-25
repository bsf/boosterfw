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
  ButtonGroup, dxBreadcrumbEdit, dxDBBreadcrumbEdit, cxCalendar, cxCheckBox;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
