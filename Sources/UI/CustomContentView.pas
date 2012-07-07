unit CustomContentView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxLookAndFeelPainters, ImgList, cxGraphics,
  ActnList, cxPropertiesStore, cxControls, cxContainer, cxEdit, cxGroupBox,
  Menus, cxLabel, StdCtrls, cxButtons, cxLookAndFeels, UIClasses,
  ICommandBarImpl;

type
  TfrCustomContentView = class(TfrCustomView, IContentView)
    pnButtons: TcxGroupBox;
  private
    FICommandBarImpl: TICommandBarImpl;
  protected
    function CommandBar: ICommandBar; override;
    procedure DoInitialize; override;
  end;


implementation

{$R *.dfm}

{ TfrCustomContentView }


function TfrCustomContentView.CommandBar: ICommandBar;
begin
  Result := FICommandBarImpl as ICommandBar;
end;

procedure TfrCustomContentView.DoInitialize;
begin
  FICommandBarImpl := TICommandBarImpl.Create(Self, WorkItem, pnButtons);
  inherited;
end;


end.
