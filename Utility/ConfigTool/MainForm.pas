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
  cxDBCheckListBox;

type
  TForm2 = class(TForm)
    DataSource1: TDataSource;
    cxGroupBox1: TcxGroupBox;
    frxReport1: TfrxReport;
    Button1: TButton;
    ClientDataSet1: TClientDataSet;
    DBGrid1: TDBGrid;
    DataSetProvider1: TDataSetProvider;
    cxDBPivotGrid1: TcxDBPivotGrid;
    cxDBPivotGrid1NAME: TcxDBPivotGridField;
    cxDBPivotGrid1GRP: TcxDBPivotGridField;
    cxDBPivotGrid1WEIGHT: TcxDBPivotGridField;
    cxGroupBox2: TcxGroupBox;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    cxDBCheckListBox1: TcxDBCheckListBox;
    cxDBCheckComboBox1: TcxDBCheckComboBox;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBVerticalGrid1DBEditorRow1: TcxDBEditorRow;
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
    procedure cxButton1Click(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
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

procedure TForm2.cxButton1Click(Sender: TObject);
begin
  cxExportPivotGridToExcel('c:\pe1', cxDBPivotGrid1);
end;

procedure TForm2.cxButton2Click(Sender: TObject);
begin
cxExportPivotGridToXML('c:\pe1', cxDBPivotGrid1)
end;

procedure TForm2.cxButton3Click(Sender: TObject);
begin
cxExportPivotGridToText('c:\pe1', cxDBPivotGrid1)
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
