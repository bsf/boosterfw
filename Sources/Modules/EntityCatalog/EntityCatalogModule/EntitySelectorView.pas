unit EntitySelectorView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomDialogView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  EntitySelectorPresenter, cxStyles, cxInplaceContainer, cxVGrid, cxDBVGrid,
  DB;

type
  TfrEntitySelectorView = class(TfrCustomDialogView, IEntitySelectorView)
    grMain: TcxDBVerticalGrid;
    MainDataSource: TDataSource;
  private
  protected
    procedure LinkData(AData: TDataSet);
  end;


implementation

{$R *.dfm}

{ TfrEntitySelectorView }

procedure TfrEntitySelectorView.LinkData(AData: TDataSet);
begin
  LinkDataSet(MainDataSource, AData);
end;

end.
