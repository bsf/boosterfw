unit CustomDialogView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  CommonViewIntf, ICommandBarImpl;

type
  TfrCustomDialogView = class(TfrCustomView)
    pnButtons: TcxGroupBox;
  private
    FICommandBarImpl: TICommandBarImpl;
  protected
    function CommandBar: ICommandBar; override;
    procedure DoInitialize; override;
  end;


implementation

{$R *.dfm}

{ TfrCustomDialogView }

function TfrCustomDialogView.CommandBar: ICommandBar;
begin
  Result := FICommandBarImpl as ICommandBar;
end;

procedure TfrCustomDialogView.DoInitialize;
begin
  FICommandBarImpl := TICommandBarImpl.Create(Self, WorkItem, pnButtons, alRight);
  inherited;
end;

end.
