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
    dxNavBar1Group1: TdxNavBarGroup;
    dxNavBar1Group2: TdxNavBarGroup;
    dxNavBar1Item1: TdxNavBarItem;
    dxNavBar1Item2: TdxNavBarItem;
    DataSource1: TDataSource;
    frxReport1: TfrxReport;
    ClientDataSet1: TClientDataSet;
    ClientDataSet1id: TIntegerField;
    ClientDataSet1name: TStringField;
    IBDatabase1: TIBDatabase;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxGridTableViewStyleSheet1: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetDevExpress: TcxGridTableViewStyleSheet;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    cxGrid1DBTableView1Column2: TcxGridDBColumn;
    Query1: TQuery;
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
