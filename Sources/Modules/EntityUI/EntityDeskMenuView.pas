unit EntityDeskMenuView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  EntityDeskMenuPresenter, db, ExtCtrls, cxButtons, Menus, StdCtrls,
  ShellIntf;

type
  TfrEntityDeskMenuView = class(TfrCustomView, IEntityDeskMenuView)
    flPanel: TFlowPanel;
  private
  protected
    procedure AddItem(const ACaption, ACommand: string);

  end;


implementation

{$R *.dfm}


{ TfrEntityDeskMenuView }

procedure TfrEntityDeskMenuView.AddItem(const ACaption, ACommand: string);
var
  btn: TcxButton;
begin
  btn := TcxButton.Create(Self);
  with btn do
  begin
    Caption := ACaption;
    Font.Size := 11;
    Width := 125;
    Height := 125;
    SpeedButtonOptions.CanBeFocused := false;
    SpeedButtonOptions.Transparent := true;
//    SpeedButtonOptions.Flat := true;
    LookAndFeel.Kind := lfFlat;
    LookAndFeel.NativeStyle := false;
    AlignWithMargins := true;
    Parent := flPanel;
    WordWrap := true;
  end;
  btn.ScaleBy(App.UI.Scale, 100);
  WorkItem.Commands[ACommand].AddInvoker(btn, 'OnClick');
end;

end.
