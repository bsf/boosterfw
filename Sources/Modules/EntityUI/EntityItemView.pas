unit EntityItemView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, ActnList, StdCtrls,
  cxButtons, cxGroupBox, cxStyles, cxInplaceContainer, cxVGrid, cxDBVGrid,
  DB, EntityCatalogIntf, EntityCatalogConst, EntityItemPresenter;

type
  TfrEntityItemView = class(TfrCustomContentView, IEntityItemView)
    ItemDataSource: TDataSource;
    grMain: TcxDBVerticalGrid;
  protected
    procedure SetItemDataSet(ADataSet: TDataSet);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TfrCustomEntityItemView }

procedure TfrEntityItemView.SetItemDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(ItemDataSource, ADataSet);
end;

end.
