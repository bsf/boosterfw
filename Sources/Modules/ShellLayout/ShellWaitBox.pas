unit ShellWaitBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, cxImage, cxLabel, cxControls,
  cxContainer, cxEdit, cxGroupBox, ExtCtrls, cxGraphics, cxLookAndFeels;

resourcestring
  StrWaitMessage = 'Загрузка данных. Подождите пожалуйста...';

type
  TfrWaitBox = class(TForm)
    pnMain: TcxGroupBox;
    lbMessageText: TcxLabel;
    Image: TImage;
  private
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TShellWaitBox = class(TComponent)
  private
    FScale: integer;
    FSaveCursor: TCursor;
    FWaitBoxView: TfrWaitBox;
  public
    procedure ScaleBy(M: integer);
    procedure Show;
    procedure Hide;
    procedure Update;
  end;

implementation

{$R *.dfm}

{ TShellWaitBox }

procedure TShellWaitBox.Hide;
begin
  if Assigned(FWaitBoxView) then
    FWaitBoxView.Hide;
  Screen.Cursor := FSaveCursor;
end;

procedure TShellWaitBox.ScaleBy(M: integer);
begin
  FScale := M;
end;

procedure TShellWaitBox.Show;
begin
  if Screen.Cursor <> crHourGlass then
    FSaveCursor := Screen.Cursor;

  Screen.Cursor := crHourGlass;    { Show hourglass cursor }

  if not Assigned(FWaitBoxView) then
  begin
    FWaitBoxView := TfrWaitBox.Create(Self);
    FWaitBoxView.ScaleBy(FScale, 100);
  end;

  FWaitBoxView.Show;
end;

procedure TShellWaitBox.Update;
begin
  if Assigned(FWaitBoxView) then
    FWaitBoxView.Update;
end;

{ TfrWaitBox }

constructor TfrWaitBox.Create(AOwner: TComponent);
begin
  inherited;
  lbMessageText.Caption := StrWaitMessage;
  Parent := Application.MainForm;
  Image.Picture.Icon := Application.Icon;
end;

procedure TfrWaitBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
 // Params.Style := Params.Style or WS_DLGFRAME;
end;

end.
