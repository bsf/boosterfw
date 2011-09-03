unit ShellUnlockForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellIntf;

type
  TfmShellUnlock = class(TForm)
    imgLogo: TImage;
    Bevel1: TBevel;
    pnClient: TPanel;
    UserNameLabel: TLabel;
    PasswordLabel: TLabel;
    Label1: TLabel;
    UserNameEdit: TEdit;
    PasswordEdit: TEdit;
    pnButtons: TPanel;
    btOK: TButton;
    btCancel: TButton;
    lbLogo: TLabel;
    lbVer: TLabel;
    procedure btOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FOkClickEvent: TNotifyEvent;
  end;

function CreateShellUnlockDialog(
  OkClickEvent: TNotifyEvent): TfmShellUnlock;

implementation

{$R *.dfm}

function CreateShellUnlockDialog(
  OkClickEvent: TNotifyEvent): TfmShellUnlock;
begin
  Result := TfmShellUnlock.Create(nil);
  Result.FOkClickEvent := OkClickEvent;
  if FindResource(HInstance, RES_ID_APP_LOGO, RT_BITMAP) <> 0 then
    Result.imgLogo.Picture.Bitmap.LoadFromResourceName(HInstance, 'APP_LOGO');
end;

procedure TfmShellUnlock.btOKClick(Sender: TObject);
begin
  if Assigned(FOkClickEvent) then
    FOkClickEvent(Self);
end;

procedure TfmShellUnlock.FormShow(Sender: TObject);
begin
  ActiveControl := PasswordEdit;
end;

end.
