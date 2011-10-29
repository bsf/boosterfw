unit BarCodeScanerController;

interface
uses classes, CoreClasses, ShellIntf, appevnts, Windows, Messages, GadgetCatalogIntf,
  ConfigServiceIntf;

const
  SETTING_BARSCAN_KEYBOARD_PREAMBLE = 'barscan.keyboard.preamble';
  SETTING_BARSCAN_KEYBOARD_POSTAMBLE = 'barscan.keyboard.postamble';

type
  TBarScanKeyboard = class(TComponent)
  private
    FPreambleLength: integer;
    FPreamble: string;
    FPostamble: char;
    FGrabStarted: boolean;
    FPreambleIdx: integer;
    FBarCodeBuff: string;
    FAppEvt: TApplicationEvents;
    function WorkItem: TWorkItem;
    procedure OnAppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure SendBarCodeEvent(const ABarCode: string);
    procedure GrabBarCode(var Key: Char);
    procedure LoadSettings;
    procedure RegisterSettings;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TBarCodeScanerController = class(TWorkItemController)
  private
    FBarScanKeyboard: TBarScanKeyboard;
  public
    constructor Create(AOwner: TWorkItem); override;
  end;

implementation

{ TBarCodeScanerController }

constructor TBarCodeScanerController.Create(AOwner: TWorkItem);
begin
  inherited Create(AOwner);
  FBarScanKeyboard := TBarScanKeyboard.Create(Self);

end;



{ TBarScanKeyboard }

constructor TBarScanKeyboard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterSettings;
  LoadSettings;
  FGrabStarted := false;
  FPreambleIdx := 1;
  FAppEvt := TApplicationEvents.Create(Self);
  if FPostamble <> #0 then
    FAppEvt.OnMessage := OnAppMessage;
end;

procedure TBarScanKeyboard.GrabBarCode(var Key: Char);
begin
  if FGrabStarted and (Key = FPostamble) then
  begin
    FGrabStarted := false;
    Key := #0;
    try
      SendBarCodeEvent(FBarCodeBuff);
    finally
      FBarCodeBuff := '';
    end;  
  end
  else if FGrabStarted and (Key <> FPostamble) then
  begin
    FBarCodeBuff := FBarCodeBuff + Key;
    Key := #0;
  end
  else if FPreamble[FPreambleIdx] = Key then
  begin
    Key := #0;
    if FPreambleLength = FPreambleIdx then
    begin
      FGrabStarted := true;
      FPreambleIdx := 1;
    end
    else
      Inc(FPreambleIdx);
  end
  else
    FPreambleIdx := 1;
end;

procedure TBarScanKeyboard.LoadSettings;
var
  _postamble: string;
begin
  FPreamble := App.Settings.Value[SETTING_BARSCAN_KEYBOARD_PREAMBLE];
  FPreambleLength := length(FPreamble);
  _postamble := App.Settings.Value[SETTING_BARSCAN_KEYBOARD_POSTAMBLE];
  if length(_postamble) > 0 then
    FPostamble := _postamble[1]
  else
    FPostamble := #0;
end;

procedure TBarScanKeyboard.OnAppMessage(var Msg: TMsg;
  var Handled: Boolean);
var Key: Char;
begin
  Handled := false;
  if (Msg.message = WM_CHAR) then
  begin
    Key := Char(Msg.wParam);
    GrabBarCode(Key);
    Msg.wParam := Word(Key);
  end;
end;

procedure TBarScanKeyboard.RegisterSettings;
begin
  with App.Settings.Add(SETTING_BARSCAN_KEYBOARD_PREAMBLE) do
  begin
    Category := 'Оборудование [Сканер штрих-кода]';
    Caption := 'Преамбула';
  end;

  with App.Settings.Add(SETTING_BARSCAN_KEYBOARD_POSTAMBLE) do
  begin
    Category := 'Оборудование [Сканер штрих-кода]';
    Caption := 'Постамбула';
  end;

end;

procedure TBarScanKeyboard.SendBarCodeEvent(const ABarCode: string);
begin
  WorkItem.Root.EventTopics[ET_BARSCAN_BARCODE].Fire(ABarCode);
end;

function TBarScanKeyboard.WorkItem: TWorkItem;
begin
  Result := TWorkItemController(Owner).WorkItem;
end;

end.
