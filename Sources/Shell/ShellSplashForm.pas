unit ShellSplashForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ShellIntf, ExtCtrls;

type
  TfrShellSplash = class(TForm)
    Panel1: TPanel;
    imgLogo: TImage;
    lbLogo: TLabel;
    lbVer: TLabel;
    lbInfoText: TLabel;
    ProgressBar: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TShellSplash = class(TObject)
  private
    FForm: TfrShellSplash;
  public
    procedure Show(AInfoStr: string; CountUpdate: integer);
    procedure Hide;
    procedure Update(AInfoStr: string; AIncrement: boolean = true);
  end;

implementation

{$R *.dfm}

{ TShellSplash }

procedure TShellSplash.Hide;
begin
  FForm.Hide;
  FForm.Free;
end;

procedure TShellSplash.Show(AInfoStr: string; CountUpdate: integer);
begin
  FForm := TfrShellSplash.Create(Application);
  FForm.Parent := nil;
  FForm.Show;
  FForm.lbInfoText.Caption := AInfoStr;
  FForm.ProgressBar.Max := CountUpdate + 1;
  FForm.ProgressBar.Position := 0;
  FForm.Update;

  if FindResource(HInstance, RES_ID_APP_LOGO, RT_BITMAP) <> 0 then
    FForm.imgLogo.Picture.Bitmap.LoadFromResourceName(HInstance, 'APP_LOGO');

end;

procedure TShellSplash.Update(AInfoStr: string; AIncrement: boolean);
begin
  FForm.lbInfoText.Caption := AInfoStr;
  if AIncrement then
    FForm.ProgressBar.StepIt;
  FForm.Update;
end;

end.
