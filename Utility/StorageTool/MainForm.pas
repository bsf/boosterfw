unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxNavBarCollns, cxClasses, dxNavBarBase, cxPC, dxNavBar, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxGridLevel, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, frxClass, DBClient, DBTables, IBDatabase,
  CategoryButtons, ExtCtrls, cxContainer, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox,
  IBCustomDataSet, IBQuery, cxInplaceContainer, cxVGrid, DBCtrls,
  cxDBExtLookupComboBox, cxDBEdit, cxTL, cxTLdxBarBuiltInMenu, cxDBTL, cxTLData,
  frxRich, cxMemo, cxRichEdit, cxMRUEdit;

type
  TForm1 = class(TForm)
    dxNavBar1: TdxNavBar;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    dxNavBar1Group1: TdxNavBarGroup;
    dxNavBar1Group2: TdxNavBarGroup;
    dxNavBar1Item1: TdxNavBarItem;
    dxNavBar1Item2: TdxNavBarItem;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    DataSource1: TDataSource;
    cxGrid1DBTableView1KOD: TcxGridDBColumn;
    cxGrid1DBTableView1NAME: TcxGridDBColumn;
    frxReport1: TfrxReport;
    ClientDataSet1: TClientDataSet;
    ClientDataSet1id: TIntegerField;
    ClientDataSet1name: TStringField;
    IBDatabase1: TIBDatabase;
    cxVerticalGrid1: TcxVerticalGrid;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
    cxLookupComboBox1: TcxLookupComboBox;
    DBLookupComboBox1: TDBLookupComboBox;
    cxComboBox1: TcxComboBox;
    cxDBExtLookupComboBox1: TcxDBExtLookupComboBox;
    cxVerticalGrid1EditorRow1: TcxEditorRow;
    cxDBComboBox1: TcxDBComboBox;
    cxTabSheet3: TcxTabSheet;
    cxTreeList1: TcxTreeList;
    cxTreeList1Column1: TcxTreeListColumn;
    cxDBTreeList1: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    frxRichObject1: TfrxRichObject;
    cxTabSheet4: TcxTabSheet;
    cxRichEdit1: TcxRichEdit;
    cxMRUEdit1: TcxMRUEdit;
    procedure cxDBComboBox1PropertiesInitPopup(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.cxDBComboBox1PropertiesInitPopup(Sender: TObject);
begin
//                   TStringDynArray
end;

end.
