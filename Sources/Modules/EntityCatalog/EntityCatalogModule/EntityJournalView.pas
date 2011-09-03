unit EntityJournalView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridBandedTableView, cxGridDBBandedTableView, cxGrid,
  cxPC, coreClasses, EntityCatalogIntf, EntityCatalogConst, CommonViewIntf,
  cxGridDBTableView;

type
  TfrEntityJournalView = class(TfrCustomContentView, IEntityJournalView)
    JrnDataSource: TDataSource;
    tcStates: TcxTabControl;
    pnInfo: TcxGroupBox;
    grList: TcxGrid;
    grJrnView: TcxGridDBTableView;
    grListLevel1: TcxGridLevel;
    procedure grJrnViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  protected
    //IJournalView
    procedure SetInfoText(const AText: string);
    function Selection: ISelection;
    function Tabs: ITabs;
    procedure SetJournalDataSet(ADataSet: TDataSet);
  end;

implementation

{$R *.dfm}

{ TfrCustomEntityJournalView }

function TfrEntityJournalView.Selection: ISelection;
begin
  Result := GetChildInterface(grJrnView.Name) as ISelection;
end;

procedure TfrEntityJournalView.SetInfoText(const AText: string);
begin
  pnInfo.Caption := AText;
  pnInfo.Visible := Trim(AText) <> '';
end;

procedure TfrEntityJournalView.SetJournalDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(JrnDataSource, ADataSet);
end;

function TfrEntityJournalView.Tabs: ITabs;
begin
  Result := GetChildInterface(tcStates.Name) as ITabs;
end;

procedure TfrEntityJournalView.grJrnViewCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[COMMAND_OPEN].Execute;
end;

end.
