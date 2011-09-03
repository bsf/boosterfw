unit ShellAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, Menus, StdCtrls, cxButtons, cxGroupBox,
  ExtCtrls, cxLabel, ShellIntf;

type
  TfrShellAbout = class(TForm)
    cxGroupBox1: TcxGroupBox;
    btClose: TcxButton;
    lbLogo: TLabel;
    lbVer: TLabel;
    imgLogo: TImage;
    procedure btCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure LoadAppLogoImage;
  public
    constructor Create(AOwner: TComponent); override;
  end;


procedure ShellAboutShow;

implementation

{$R *.dfm}

procedure ShellAboutShow;
var
  frm: TForm;
begin
  frm := TfrShellAbout.Create(nil);
  frm.ShowModal;
  frm.Free;
end;

procedure TfrShellAbout.btCloseClick(Sender: TObject);
begin
  Close;
end;

constructor TfrShellAbout.Create(AOwner: TComponent);
begin
  inherited;
  LoadAppLogoImage;
end;

procedure TfrShellAbout.FormShow(Sender: TObject);
begin
  lbVer.Caption := App.Version;
end;

procedure TfrShellAbout.LoadAppLogoImage;
begin
  if FindResource(HInstance, RES_ID_APP_LOGO, RT_BITMAP) <> 0 then
    imgLogo.Picture.Bitmap.LoadFromResourceName(HInstance, 'APP_LOGO');
end;

end.
