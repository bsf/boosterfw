unit EntityDeskMenuView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  EntityDeskMenuPresenter, db, ExtCtrls, cxButtons, Menus, StdCtrls,
  ShellIntf, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxDBData,
  cxGridCustomTableView, cxGridCardView, cxGridDBCardView, cxGridCustomView,
  cxGridCustomLayoutView, cxClasses, cxGridLevel, cxGrid, cxLabel;

type
  TfrEntityDeskMenuView = class(TfrCustomView, IEntityDeskMenuView)
    grMenuLevel1: TcxGridLevel;
    grMenu: TcxGrid;
    grMenuView: TcxGridDBCardView;
    dsItems: TDataSource;
    grMenuViewRowTitle: TcxGridDBCardViewRow;
    grMenuViewRowURI: TcxGridDBCardViewRow;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    procedure grMenuViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
  protected
    procedure LinkItems(ADataSet: TDataSet);

  end;


implementation

{$R *.dfm}


{ TfrEntityDeskMenuView }

procedure TfrEntityDeskMenuView.grMenuViewCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[ACellViewInfo.GridRecord.Values[grMenuViewRowURI.Index]].Execute;

end;

procedure TfrEntityDeskMenuView.LinkItems(ADataSet: TDataSet);
begin
  dsItems.DataSet := ADataSet;
end;

end.
