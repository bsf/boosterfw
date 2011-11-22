unit ShellLoginForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellIntf;

type
  TfmShellLogin = class(TForm)
    imgLogo: TImage;
    lbVer: TLabel;
    lbLogo: TLabel;
    pnButtons: TPanel;
    pnClient: TPanel;
    btOK: TButton;
    btCancel: TButton;
    Bevel1: TBevel;
    UserNameLabel: TLabel;
    UserNameEdit: TEdit;
    PasswordLabel: TLabel;
    PasswordEdit: TEdit;
    CustomLabel: TLabel;
    CustomCombo: TComboBox;
    Label1: TLabel;
    procedure btOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FOkClickEvent: TNotifyEvent;
  public
    { Public declarations }
  end;

function CreateShellLoginDialog(OkClickEvent: TNotifyEvent): TfmShellLogin;

implementation

{$R *.dfm}

function CreateShellLoginDialog(OkClickEvent: TNotifyEvent): TfmShellLogin;
begin
  Result := TfmShellLogin.Create(nil);
  Result.FOkClickEvent := OkClickEvent;
  if FindResource(HInstance, RES_ID_APP_LOGO, RT_BITMAP) <> 0 then
    Result.imgLogo.Picture.Bitmap.LoadFromResourceName(HInstance, 'APP_LOGO');

end;

procedure TfmShellLogin.btOKClick(Sender: TObject);
begin
  if Assigned(FOkClickEvent) then
    FOkClickEvent(Self);
end;

procedure TfmShellLogin.FormShow(Sender: TObject);
begin
  if UserNameEdit.Text = '' then
    ActiveControl := UserNameEdit
  else
    ActiveControl := PasswordEdit;
end;

end.
