unit EntityCollectView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  EntityCollectPresenter, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, DB, cxDBData, cxInplaceContainer, cxVGrid, cxDBVGrid,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxSplitter, UIClasses;

type
  TfrEntityCollectView = class(TfrCustomContentView, IEntityCollectView)
    pnTop: TcxGroupBox;
    cxSplitter1: TcxSplitter;
    grItems: TcxGrid;
    grItemsView: TcxGridDBTableView;
    grItemsLevel1: TcxGridLevel;
    grList: TcxGrid;
    grListView: TcxGridDBTableView;
    grListLevel1: TcxGridLevel;
    cxSplitter2: TcxSplitter;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    grInfo: TcxDBVerticalGrid;
    InfoDataSource: TDataSource;
    ListDataSource: TDataSource;
    ItemsDataSource: TDataSource;
    procedure grListViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure grItemsViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    FCommandAddDef: string;
  protected
    procedure SetCommandAddDef(const AName: string);
    function SelectionList: ISelection;
    function SelectionItems: ISelection;
    procedure SetData(AInfo, AList, AItems: TDataSet);
  end;


implementation

{$R *.dfm}

{ TfrEntityCollectView }

function TfrEntityCollectView.SelectionItems: ISelection;
begin
  Result := GetChildInterface(grItemsView.Name) as ISelection;
end;

function TfrEntityCollectView.SelectionList: ISelection;
begin
  Result := GetChildInterface(grListView.Name) as ISelection;
end;

procedure TfrEntityCollectView.SetCommandAddDef(const AName: string);
begin
  FCommandAddDef := AName;
end;

procedure TfrEntityCollectView.SetData(AInfo, AList, AItems: TDataSet);
begin
  LinkDataSet(InfoDataSource, AInfo);
  LinkDataSet(ListDataSource, AList);
  LinkDataSet(ItemsDataSource, AItems);
end;

procedure TfrEntityCollectView.grListViewCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[FCommandAddDef].Execute;
end;

procedure TfrEntityCollectView.grItemsViewCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[COMMAND_OPEN].Execute;
end;

end.
