unit EntityNewView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, ActnList, StdCtrls,
  cxButtons, cxGroupBox, cxStyles, cxInplaceContainer, cxVGrid, cxDBVGrid,
  DB, EntityNewPresenter;

type
  TfrEntityNewView = class(TfrCustomContentView, IEntityNewView)
    ItemDataSource: TDataSource;
    grMain: TcxDBVerticalGrid;
  private
  protected
    procedure SetData(ADataSet: TDataSet);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TfrCustomEntityItemView }

procedure TfrEntityNewView.SetData(ADataSet: TDataSet);
begin
  LinkDataSet(ItemDataSource, ADataSet);
end;

end.
