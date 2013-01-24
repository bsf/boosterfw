unit CustomDialogView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  UIClasses, ICommandBarImpl;

type
  TfrCustomDialogView = class(TfrCustomView)
    pnButtons: TcxGroupBox;
  private
    FICommandBarImpl: TICommandBarImpl;
  protected
    function CommandBar: ICommandBar; override;
  end;


implementation

{$R *.dfm}

{ TfrCustomDialogView }

function TfrCustomDialogView.CommandBar: ICommandBar;
begin
  if FICommandBarImpl = nil then
    FICommandBarImpl := TICommandBarImpl.Create(Self, WorkItem, pnButtons, alRight);
  Result := FICommandBarImpl as ICommandBar;
end;

end.
