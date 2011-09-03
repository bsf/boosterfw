unit ReportSetupView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxLookAndFeelPainters, ActnList, cxControls,
  cxContainer, cxEdit, cxGroupBox, cxStyles, cxGraphics,
  cxInplaceContainer, cxVGrid, cxDBVGrid, cxPC, cxCustomData, cxFilter,
  cxData, cxDataStorage, DB, cxDBData, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, CommonViewIntf,
  cxGridDBTableView, cxGrid,  cxDBLookupComboBox, cxTextEdit, cxMemo,
  cxLookAndFeels, ReportSetupPresenter;


type
  TfrReportSetupView = class(TfrCustomView, IReportSetupView)
    pcMain: TcxPageControl;
    tsParams: TcxTabSheet;
    cxSplitter1: TcxSplitter;
    ItemsDataSource: TDataSource;
    tcNoSetup: TcxTabSheet;
    ItemLinksDataSource: TDataSource;
    ItemLinksLookupDataSource: TDataSource;
    cxGroupBox2: TcxGroupBox;
    grItemLinks: TcxGrid;
    grItemLinksView: TcxGridDBTableView;
    grItemLinksViewColumn1: TcxGridDBColumn;
    grItemLinksLevel1: TcxGridLevel;
    grItemLinksViewColumn2: TcxGridDBColumn;
    grItemLinksViewColumn3: TcxGridDBColumn;
    cxGroupBox3: TcxGroupBox;
    cxGroupBox4: TcxGroupBox;
    grItems: TcxGrid;
    grItemsView: TcxGridDBTableView;
    grItemsViewColumn1: TcxGridDBColumn;
    grItemsViewColumn2: TcxGridDBColumn;
    grItemsViewColumn3: TcxGridDBColumn;
    grItemsViewColumn4: TcxGridDBColumn;
    grItemsViewColumn5: TcxGridDBColumn;
    grItemsLevel1: TcxGridLevel;
    mmInfo: TcxMemo;
    cxMemo1: TcxMemo;
    procedure grItemsViewFocusedRecordChanged(
      Sender: TcxCustomGridTableView; APrevFocusedRecord,
      AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  private
    FItemSelectionChangedHandler: TNotifyEvent;
    procedure SetItemSelectionChangedHandler(AHandler: TNotifyEvent);
    function GetItemSelection: Variant;
    procedure SetNoSetupStyle;
    procedure SetDoSetupStyle;
    procedure SetItemsDataSet(ADataSet: TDataSet);
    procedure SetItemLinksDataSet(ADataSet: TDataSet);
    procedure SetItemLinksLookupDataSet(ADataSet: TDataSet);

  public
    { Public declarations }
  end;



implementation

{$R *.dfm}


{ TfrReportSetupView }

procedure TfrReportSetupView.grItemsViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if Assigned(FItemSelectionChangedHandler) then
    FItemSelectionChangedHandler(nil);
end;

function TfrReportSetupView.GetItemSelection: Variant;
var
  KeyFieldIndex: integer;
begin
  if grItemsView.DataController.FocusedRecordIndex > -1 then
  begin
    KeyFieldIndex := grItemsView.GetColumnByFieldName(grItemsView.DataController.KeyFieldNames).Index;
    Result := grItemsView.DataController.Values[
      grItemsView.DataController.FocusedRecordIndex, KeyFieldIndex];
  end
  else
    Result := Unassigned;
end;

procedure TfrReportSetupView.SetItemSelectionChangedHandler(
  AHandler: TNotifyEvent);
begin
  FItemSelectionChangedHandler := AHandler;
end;

procedure TfrReportSetupView.SetDoSetupStyle;
begin
  pcMain.HideTabs := true;
  pcMain.ActivePageIndex := 1;
end;

procedure TfrReportSetupView.SetNoSetupStyle;
begin
  pcMain.HideTabs := true;
  pcMain.ActivePageIndex := 0;
end;

procedure TfrReportSetupView.SetItemLinksDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(ItemLinksDataSource, ADataSet);
end;

procedure TfrReportSetupView.SetItemLinksLookupDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(ItemLinksLookupDataSource, ADataSet);
end;

procedure TfrReportSetupView.SetItemsDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(ItemsDataSource, ADataSet);
end;

end.
