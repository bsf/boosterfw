unit NotifyReceiver;

interface
uses CoreClasses, ExtCtrls, windows, EntityServiceIntf, UIServiceIntf,
  db, variants, ConfigServiceIntf, ShellIntf, sysutils;

const
  const_AppInstanceID = 'Hermes Trade %s %s';
  const_ReceiveIntervalDef = 60; //sec
  ENT_MSG_BOX = 'BFW_INF_MSG';
  ENT_MSG_BOX_OPER_POP = 'POP';
  ENT_MSG_BOX_OPER_MARK = 'MARK';

  SETTING_RECEIVER_INTERVAL = 'NotifyReceiver.Interval';
  SETTING_RECEIVER_ENABLED = 'NotifyReceiver.Enabled';

type
  TNotifyReceiver = class(TWorkItemController)
  private
    FLastMessageID: Variant;
    FRunningFlag: THandle;
    FAppInstanceID: string;
    FUISvc: IUIService;
    FEntitySvc: IEntityService;
    FTimer: TTimer;
    function CanInstanceReceive: boolean;
    procedure ReceiveMessages;
    procedure OnTimer(Sender: TObject);
    procedure RegisterSettings;
    procedure NotifyAcceptHandler(EventData: Variant);
  protected
    procedure Terminate; override;
    procedure Initialize; override;
  end;

implementation

{ TNotifyReceiver }


function TNotifyReceiver.CanInstanceReceive: boolean;
begin
  // Создаем в страничной памяти 1-байтовый "файл" с уникальным
  // именем FAppInstanceID, проецируем его в свое адресное пространство
  // и проверяем, был ли он создан или просто открыт.
  if FRunningFlag = 0 then
  begin
    FRunningFlag := CreateFileMapping($FFFFFFFF, nil, PAGE_READONLY, 0, 1, PChar(FAppInstanceID));
    Result := not (GetLastError = ERROR_ALREADY_EXISTS);
    if not Result then
    begin
      CloseHandle(FRunningFlag);
      FRunningFlag := 0;
    end
  end
  else
    Result := true;
end;

procedure TNotifyReceiver.Initialize;
var
  intervalR: integer;
begin
  RegisterSettings;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := false;

  intervalR := StrToIntDef(App.Settings[SETTING_RECEIVER_INTERVAL], const_ReceiveIntervalDef);
  if intervalR < 30 then
    intervalR := 30;

  FTimer.Interval := intervalR * 1000;
  FTimer.OnTimer := OnTimer;

  FEntitySvc := (WorkItem.Services[IEntityService] as IEntityService);
  FUISvc := (WorkItem.Services[IUIService] as IUIService);

  FAppInstanceID := format(const_AppInstanceID, [App.Settings.CurrentAlias, App.Settings.UserID]);
  FRunningFlag := 0;

  WorkItem.Root.EventTopics[ET_NOTIFY_ACCEPT].AddSubscription(Self, NotifyAcceptHandler);

  FTimer.Enabled := App.Settings[SETTING_RECEIVER_ENABLED] = '1';
end;

procedure TNotifyReceiver.NotifyAcceptHandler(EventData: Variant);
begin
  FEntitySvc.Entity[ENT_MSG_BOX].GetOper(ENT_MSG_BOX_OPER_MARK, WorkItem).Execute([EventData]);
end;

procedure TNotifyReceiver.OnTimer(Sender: TObject);
begin
  try
    ReceiveMessages;
  except
    FTimer.Enabled := false;
    raise;
  end;
end;

procedure TNotifyReceiver.ReceiveMessages;
var
  ds: TDataSet;
begin
  if not CanInstanceReceive then Exit;
  ds := FEntitySvc.Entity[ENT_MSG_BOX].GetOper(ENT_MSG_BOX_OPER_POP, WorkItem).Execute([FLastMessageID]);
  while not ds.Eof do
  begin
    FUISvc.NotifyExt(VarToStr(ds['ID']), VarToStr(ds['SENDER']), VarToStr(ds['TXT']), ds['SDAT']);
    FLastMessageID := ds['ID'];
    ds.Next;
  end
end;

procedure TNotifyReceiver.RegisterSettings;
begin

  with App.Settings.Add(SETTING_RECEIVER_ENABLED) do
  begin
    Caption := 'Получение';
    Category := 'Уведомления';
    DefaultValue := '0';
    Editor := seBoolean;
    StorageLevels := [slUserProfile, slHostProfile, slAlias, slCommon];
  end;

  with App.Settings.Add(SETTING_RECEIVER_INTERVAL) do
  begin
    Caption := 'Интервал получения, сек';
    Category := 'Уведомления';
    DefaultValue := IntToStr(const_ReceiveIntervalDef);
    Editor := seInteger;
    StorageLevels := [slUserProfile, slHostProfile, slAlias, slCommon];
  end;

end;

procedure TNotifyReceiver.Terminate;
begin
  FTimer.Enabled := false;
  CloseHandle(FRunningFlag);
end;

end.
