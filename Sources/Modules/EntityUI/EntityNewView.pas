unit EntityNewView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, ActnList, StdCtrls,
  cxButtons, cxGroupBox, cxStyles, cxInplaceContainer, cxVGrid, cxDBVGrid,
  DB, EntityNewPresenter, UIClasses;

type
  TfrEntityNewView = class(TfrCustomContentView, IEntityNewView)
    ItemDataSource: TDataSource;
    grMain: TcxDBVerticalGrid;
    procedure grMainKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  protected
    procedure CancelEdit;
    procedure SetData(ADataSet: TDataSet);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TfrCustomEntityItemView }

procedure TfrEntityNewView.CancelEdit;
begin
  grMain.DataController.DataSource := nil;
  grMain.DataController.DataSource := ItemDataSource;
end;

procedure TfrEntityNewView.grMainKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
     Key := 0 //Blocked cancel inserted record
  else if (Key = VK_RETURN) and (Shift = []) and (not grMain.DataController.IsEditing)
      and (grMain.FocusedRow.IsLastVisible) then
    WorkItem.Commands[COMMAND_SAVE].Execute;

end;

procedure TfrEntityNewView.SetData(ADataSet: TDataSet);
begin
  LinkDataSet(ItemDataSource, ADataSet);
end;

end.
