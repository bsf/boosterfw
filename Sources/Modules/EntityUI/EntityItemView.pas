unit EntityItemView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, ActnList, StdCtrls,
  cxButtons, cxGroupBox, cxStyles, cxInplaceContainer, cxVGrid, cxDBVGrid,
  DB, EntityItemPresenter, UIClasses;

type
  TfrEntityItemView = class(TfrCustomView, IEntityItemView)
    ItemDataSource: TDataSource;
    grMain: TcxDBVerticalGrid;
    procedure grMainKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    procedure SetItemDataSet(ADataSet: TDataSet);
    procedure CancelEdit;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TfrCustomEntityItemView }

procedure TfrEntityItemView.CancelEdit;
begin
  grMain.DataController.DataSource := nil;
  grMain.DataController.DataSource := ItemDataSource;
end;

procedure TfrEntityItemView.grMainKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) and (not grMain.DataController.IsEditing)
      and (grMain.FocusedRow = grMain.LastVisibleRow) then
    WorkItem.Commands[COMMAND_SAVE].Execute;
end;

procedure TfrEntityItemView.SetItemDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(ItemDataSource, ADataSet);
end;

end.
