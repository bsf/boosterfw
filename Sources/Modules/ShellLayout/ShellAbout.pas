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
    LogoLabel: TLabel;
    lbVer: TLabel;
    imgLogo: TImage;
    procedure btCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure LoadAppLogoImage;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Localization;
  end;


procedure ShellAboutShow;

implementation

{$R *.dfm}

procedure ShellAboutShow;
var
  frm: TfrShellAbout;
begin
  frm := TfrShellAbout.Create(nil);
  frm.Localization;
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
  imgLogo.Picture.Bitmap.Assign(App.Logo);
end;

procedure TfrShellAbout.Localization;
begin
  if App.UI.Locale = 'ru-RU' then
  begin
    LogoLabel.Caption := 'Информационная Система';
  end;
end;

end.
