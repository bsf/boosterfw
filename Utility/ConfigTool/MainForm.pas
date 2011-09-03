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
  cxRichEdit;

type
  TForm2 = class(TForm)
    DataSource1: TDataSource;
    IBDatabase1: TIBDatabase;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
    cxGroupBox1: TcxGroupBox;
    dxNavBar1: TdxNavBar;
    dxNavBar1Group1: TdxNavBarGroup;
    dxNavBar1Group2: TdxNavBarGroup;
    dxNavBar1Group3: TdxNavBarGroup;
    dxNavBar1Item1: TdxNavBarItem;
    dxNavBar1Item2: TdxNavBarItem;
    dxNavBar1Item3: TdxNavBarItem;
    dxNavBar1Item4: TdxNavBarItem;
    dxNavBar1Item5: TdxNavBarItem;
    dxNavBar1Item6: TdxNavBarItem;
    frxReport1: TfrxReport;
    cxDBComboBox1: TcxDBComboBox;
    cxMRUEdit1: TcxMRUEdit;
    Button1: TButton;
    ClientDataSet1: TClientDataSet;
    DBGrid1: TDBGrid;
    DataSetProvider1: TDataSetProvider;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2ID: TcxDBEditorRow;
    cxDBVerticalGrid2IMG: TcxDBEditorRow;
    procedure dxNavBar1Item1Click(Sender: TObject);
    procedure dxNavBar1Item2Click(Sender: TObject);
    procedure cxMRUEdit1PropertiesInitPopup(Sender: TObject);
    procedure cxMRUEdit1PropertiesDeleteLookupItem(
      AProperties: TcxCustomMRUEditProperties; AItemIndex: Integer);
    procedure cxMRUEdit1PropertiesNewLookupDisplayText(Sender: TObject;
      const AText: TCaption);
    procedure cxVerticalGrid1EditValueChanged(Sender: TObject;
      ARowProperties: TcxCustomEditorRowProperties);
    procedure Button1Click(Sender: TObject);
    procedure ClientDataSet1AfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  ShowMessage(#53#79#78#59);
end;

procedure TForm2.ClientDataSet1AfterInsert(DataSet: TDataSet);
begin
//
end;

procedure TForm2.cxMRUEdit1PropertiesDeleteLookupItem(
  AProperties: TcxCustomMRUEditProperties; AItemIndex: Integer);
begin
//
end;

procedure TForm2.cxMRUEdit1PropertiesInitPopup(Sender: TObject);
begin
 // cxMRUEdit1.PostEditValue;
 // cxMRUEdit1.Properties.LookupItems.Add(vartostr(cxMRUEdit1.EditValue));
end;

procedure TForm2.cxMRUEdit1PropertiesNewLookupDisplayText(Sender: TObject;
  const AText: TCaption);
begin
//
end;

procedure TForm2.cxVerticalGrid1EditValueChanged(Sender: TObject;
  ARowProperties: TcxCustomEditorRowProperties);
begin
//
end;

procedure TForm2.dxNavBar1Item1Click(Sender: TObject);
begin
  frxReport1.PreviewPages.LoadFromFile('c:\1.fp3', true);
  frxReport1.ShowPreparedReport;
 // frxPreview1.Zoom := 50;
//  frxPreview1.ZoomMode := zmDefault;
end;

procedure TForm2.dxNavBar1Item2Click(Sender: TObject);
begin
  frxReport1.ShowReport;
end;

end.
