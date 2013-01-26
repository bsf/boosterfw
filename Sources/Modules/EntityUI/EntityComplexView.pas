unit EntityComplexView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxSplitter, UIClasses,
  cxInplaceContainer, cxVGrid, cxDBVGrid, EntityComplexPresenter,
  cxDBLookupComboBox;

type
  TfrEntityComplexView = class(TfrCustomView, IEntityComplexView)
    HeadDataSource: TDataSource;
    DetailsDataSource: TDataSource;
    grHeader: TcxDBVerticalGrid;
    cxSplitter1: TcxSplitter;
    grDetails: TcxGrid;
    grDetailsView: TcxGridDBTableView;
    grDetailsLevel1: TcxGridLevel;
    procedure grDetailsViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
  protected
    procedure LinkData(AHead, ADetails: TDataSet);
    function DetailSelection: ISelection;
  public
  end;


implementation

{$R *.dfm}

{ TfrEntityComplexView }

function TfrEntityComplexView.DetailSelection: ISelection;
begin
  Result := GetChildInterface(grDetailsView.Name) as ISelection;
end;

procedure TfrEntityComplexView.LinkData(AHead, ADetails: TDataSet);
begin
  LinkDataSet(HeadDataSource, AHead);
  LinkDataSet(DetailsDataSource, ADetails);
end;

procedure TfrEntityComplexView.grDetailsViewCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[COMMAND_DETAIL_OPEN].Execute;
end;

end.
