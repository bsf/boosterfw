unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  IBConnectionBroker, IBSQL, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, Provider, DBClient, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, Grids, DBGrids, IBDatabase, IBCustomDataSet,
  IBQuery,
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
  cxGridBandedTableView, cxGridDBBandedTableView, cxPropertiesStore, cxCalc,
  ICommandBarImpl, coreClasses, UIClasses, IBServices, IBScript, IBExtract;

type
  TForm2 = class(TForm)
    DataSource1: TDataSource;
    IBDatabase1: TIBDatabase;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
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
    cxButton7: TcxButton;
    cxButton1: TcxButton;
    pnButtons: TcxGroupBox;
    cxGroupBox2: TcxGroupBox;
    IBBackupService1: TIBBackupService;
    IBSQL1: TIBSQL;
    IBExtract1: TIBExtract;
    IBScript1: TIBScript;
    procedure cxGrid1DBBandedTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure cxButton6Click(Sender: TObject);
    procedure cxButton7Click(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    bttest: TcxButton;
    barImpl: TICommandBarImpl;
    WorkItem: TWorkItem;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.cxButton1Click(Sender: TObject);
begin
  WorkItem.Commands['cmd2'].Status := csEnabled;
end;

procedure TForm2.cxButton6Click(Sender: TObject);
begin
  // bttest.Visible := not bttest.Visible;
  pnButtons.Parent := cxGroupBox2;
  WorkItem.Commands['cmd2'].Status := csUnavailable;
  pnButtons.Visible := true;
end;

procedure TForm2.cxButton7Click(Sender: TObject);
  function AddButton(ACaption: string): TcxButton;
  var
    left: integer;
  begin
    Result := TcxButton.Create(Self);
    Result.Caption := ACaption;
    left := 0;
    if pnButtons.ControlCount <> 0 then
    begin
     left := pnButtons.Controls[pnButtons.ControlCount - 1].Left +
        pnButtons.Controls[pnButtons.ControlCount - 1].Width;
    end;
    Result.Left := left;
    Result.Parent := pnButtons;
    Result.Align := TAlign.alLeft;
    Result.AlignWithMargins := true;
    Result.LookAndFeel.Kind := pnButtons.LookAndFeel.Kind;
  end;

begin

  AddButton('1');
  bttest := AddButton('2');
  bttest.Visible := false;
  AddButton('3');
  pnButtons.Visible := true;
  bttest.Visible := true;
  { (barImpl as ICommandBar).AddCommand('cmd1', '1');
    (barImpl as ICommandBar).AddCommand('cmd2', '2');
    (barImpl as ICommandBar).AddCommand('cmd3', '3'); }
end;

procedure TForm2.cxGrid1DBBandedTableView1CellClick
  (Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  ShowMessage('test');
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  WorkItem := TWorkItem.Create(nil, nil, '', nil);
  barImpl := TICommandBarImpl.Create(Self, WorkItem, pnButtons);
end;

end.
