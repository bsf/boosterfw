unit NumLockDotHook;

interface
uses Windows, Messages, Sysutils;

implementation

var
  FChangeKey: Boolean = false;
  FMsgHook: HHOOK;

function MsgHook(Code: Integer; WParam: WPARAM; Msg: PMsg): Longint; stdcall;
begin
  case Msg.Message of
    WM_KEYDOWN:
    begin
      if wParam = PM_REMOVE then
        if Msg.wParam = VK_DECIMAL then
        begin
          FChangeKey := True;
        end;
    end;
    WM_CHAR:
    begin
      if wParam = PM_REMOVE then
        if FChangeKey then
        begin
          Msg.wParam := Ord(DecimalSeparator);
          FChangeKey := false;
          result:=0;
          exit;
        end
    end;
  end;

  Result := CallNextHookEx(FMsgHook, Code, WParam, Longint(Msg));
end;

initialization
  FMsgHook := SetWindowsHookEx(WH_GETMESSAGE, @MsgHook, 0, GetCurrentThreadID);

finalization
  UnhookWindowsHookEx(FMsgHook);
end.
