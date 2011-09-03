unit ShellLock;

interface


uses
  SysUtils, Classes, Messages, forms, Controls, ShellIntf,
  graphics, windows, CoreClasses, ShellUnlockForm;

type

  TShellLock = class(TComponent)
  private
    FLocked: boolean;
    FUnlockDlgShowing: boolean;
    procedure FOnOKUnlockClick(Sender: TObject);
    function UnlockHook(var Message: TMessage): Boolean;
    function DoUnlockDialog: Boolean;
  public
    procedure Lock;
  end;

procedure DoShellLock;

implementation

uses ConfigServiceIntf;

var
  ShellLockInstance: TShellLock;

procedure DoShellLock;
begin
  if not Assigned(ShellLockInstance) then
    ShellLockInstance := TShellLock.Create(nil);

  ShellLockInstance.Lock;
end;

{ TShellLock }

function TShellLock.DoUnlockDialog: Boolean;
var lForm: TfmShellUnlock;
begin
  lForm := CreateShellUnlockDialog(FOnOkUnlockClick);
  try
    lForm.UserNameEdit.Text := App.Settings.UserID;
    lForm.lbVer.Caption := App.Settings.CurrentAlias;
    Result := (lForm.ShowModal = mrOK);
  finally
    lForm.Free;
  end;
end;

procedure TShellLock.FOnOKUnlockClick(Sender: TObject);
var OK: boolean;
begin
  with TfmShellUnlock(Sender) do
  begin
    OK := SameText(App.Settings['PASSWORD'], PasswordEdit.Text);
    if Ok then ModalResult := mrOk
    else ModalResult := mrCancel;
  end;
end;

procedure TShellLock.Lock;
begin
  Application.Minimize;
  Application.HookMainWindow(UnlockHook);
  FLocked := True;
end;

function TShellLock.UnlockHook(var Message: TMessage): Boolean;
  function WindowClassName(Wnd: HWnd): string;
  var
    Buffer: array[0..255] of Char;
  begin
    SetString(Result, Buffer, GetClassName(Wnd, Buffer, SizeOf(Buffer) - 1));
  end;

  function DoUnlock: Boolean;
  var
    Popup: HWnd;
  begin
    with Application do
      if IsWindowVisible(Handle) and IsWindowEnabled(Handle) then
        SetForegroundWindow(Handle);
    if FUnlockDlgShowing then begin
      Popup := GetLastActivePopup(Application.Handle);
      if (Popup <> 0) and IsWindowVisible(Popup) and
        (WindowClassName(Popup) = TfmShellUnlock.ClassName) then
      begin
        SetForegroundWindow(Popup);
      end;
      Result := False;
      Exit;
    end;
    FUnlockDlgShowing := True;
    try
      Result := DoUnlockDialog;
    finally
      FUnlockDlgShowing := False;
    end;
    if Result then begin
      Application.UnhookMainWindow(UnlockHook);
      FLocked := False;
    end;
  end;

begin
  Result := False;
  if not FLocked then Exit;
  with Message do begin
    case Msg of
      WM_QUERYOPEN:
        begin
          UnlockHook := not DoUnlock;
        end;
      WM_SHOWWINDOW:
        if Bool(WParam) then begin
          UnlockHook := not DoUnlock;
        end;
      WM_SYSCOMMAND:
        if (WParam and $FFF0 = SC_RESTORE) or
          (WParam and $FFF0 = SC_ZOOM) then
        begin
          UnlockHook := not DoUnlock;
        end;
    end;
  end;


end;

end.
