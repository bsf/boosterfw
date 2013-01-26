unit CustomDialogView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  UIClasses, ICommandBarImpl;

type
  TfrCustomDialogView = class(TfrCustomView)
  protected
    function GetCommandBarAlignment: TButtonAlignment; override;
  end;


implementation

{$R *.dfm}



{ TfrCustomDialogView }

function TfrCustomDialogView.GetCommandBarAlignment: TButtonAlignment;
begin
  Result := alRight;
end;

end.
