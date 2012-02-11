unit ShellView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, wininet, constUnit, StdCtrls;

const
  WM_SHELL_SHOW = wm_USER + 100;

type
  TfrMain = class(TForm, IShellView)
    ProgressBar: TProgressBar;
    btUserCancel: TButton;
    lbInfo: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btUserCancelClick(Sender: TObject);
  private

    FTitle: string;
    FInfo: string;

    FProgressCoeff: integer;
    FOnShowCallback: TShellCallbackProc;
    FOnUserCancelCallback: TShellCallbackProc;
  protected
    procedure WMShellShow(var Message: TMessage); message WM_SHELL_SHOW;

    //IShellView
    procedure SetOnShowCallback(ACallback: TShellCallbackProc);
    procedure SetOnUserCancelCallback(ACallback: TShellCallbackProc);
    procedure SetProgressPosition(AValue: integer);
    procedure SetProgressMax(AValue: integer);
    procedure SetTitle(const AValue: string);
    procedure SetInfo(const AValue: string);

  end;

implementation

{$R *.dfm}


procedure TfrMain.btUserCancelClick(Sender: TObject);
begin
  FOnUserCancelCallback();
end;

procedure TfrMain.FormCreate(Sender: TObject);
begin
  FProgressCoeff := 1;
end;

procedure TfrMain.FormShow(Sender: TObject);
begin
  PostMessage(Self.Handle, WM_SHELL_SHOW, 0, 0);
end;

procedure TfrMain.SetInfo(const AValue: string);
begin
  FInfo := AValue;
  if FInfo = '' then
    FInfo := 'Update Booster Framework...';  
  lbInfo.Caption := FInfo;
end;

procedure TfrMain.SetOnShowCallback(ACallback: TShellCallbackProc);
begin
  FOnShowCallback := ACallback;
end;

procedure TfrMain.SetOnUserCancelCallback(ACallback: TShellCallbackProc);
begin
  FOnUserCancelCallback := ACallback;
end;

procedure TfrMain.SetProgressMax(AValue: integer);
begin
  FProgressCoeff := 1;
  if AValue > 10000 then
    FProgressCoeff := 1000;
  ProgressBar.Max := Round(AValue / FProgressCoeff);
end;

procedure TfrMain.SetProgressPosition(AValue: integer);
begin
  ProgressBar.Position := Round(AValue / FProgressCoeff) ;
end;

procedure TfrMain.SetTitle(const AValue: string);
begin
  FTitle := AValue;
  if FTitle = '' then
    FTitle := 'Update Booster Framework';
  Caption := FTitle;
end;

procedure TfrMain.WMShellShow(var Message: TMessage);
begin
  Update;
  FOnShowCallback();
end;

end.
