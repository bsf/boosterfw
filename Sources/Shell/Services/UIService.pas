unit UIService;

interface
uses classes, coreClasses, UIServiceIntf, forms, windows, dialogs, ConfigServiceIntf,
  sysutils, variants, Generics.Collections;

type
  TUIService = class(TComponent, IUIService, IMessageBox, IInputBox, IWaitBox)
  const
    APP_LOCALE_SETTING = 'Application.Locale';

  private
    FWorkItem: TWorkItem;
    FLocale: string;
    FStyles: TDictionary<string, TObject>;
  protected
    function MessageBox: IMessageBox;
    function InputBox: IInputBox;
    function WaitBox: IWaitBox;
    // IMessageBox
    function ConfirmYesNo(const AMessage: string): boolean;
    function ConfirmYesNoCancel(const AMessage: string): integer;
    procedure InfoMessage(const AMessage: string);
    procedure ErrorMessage(const AMessage: string);
    procedure StatusBarMessage(const AMessage: string);
    // InputBox
    function InputString(const APrompt: string; var AText: string): boolean;
    // WaitBox
    procedure StartWait;
    procedure StopWait;

    procedure Notify(const AMessage: string);
    procedure NotifyExt(const AID, ASender, AMessage: string; ADateTime: TDateTime);
    procedure NotifyAccept(const AID: string);
    //
    //ms-help://embarcadero.rs_xe/Intl/nls_238z.htm
    procedure SetLocale(AValue: string);
    function GetLocale: string;
    function Scale: integer;
    //
    procedure SetStyle(const AName: string; AValue: TObject);
    function GetStyle(const AName: string): TObject;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TUIService }

function TUIService.ConfirmYesNo(const AMessage: string): boolean;
begin
  Result := Application.MessageBox(PChar(AMessage), PChar(Application.Title),
     MB_YESNO + MB_ICONQUESTION) = ID_YES;
end;

function TUIService.ConfirmYesNoCancel(const AMessage: string): integer;
begin
  Result := Application.MessageBox(PChar(AMessage), PChar(Application.Title),
     MB_YESNOCANCEL + MB_ICONQUESTION);
end;

constructor TUIService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
var
  localeIdx: integer;
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FStyles := TDictionary<string, TObject>.Create;

  //Init Locale
  localeIdx := SysUtils.Languages.IndexOf(
    (FWorkItem.Services[IConfigurationService] as IConfigurationService).
      Settings[APP_LOCALE_SETTING]);

  if localeIdx = -1 then
    localeIdx := Sysutils.Languages.IndexOf(GetUserDefaultLCID);
  FLocale := Sysutils.Languages.LocaleName[localeIdx];


end;

destructor TUIService.Destroy;
begin
  FStyles.Free;
  inherited;
end;

procedure TUIService.ErrorMessage(const AMessage: string);
begin
  Windows.MessageBox(Application.Handle, PChar(AMessage),
    'Œ¯Ë·Í‡', MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_SETFOREGROUND + MB_TOPMOST);
end;

function TUIService.GetLocale: string;
begin
  Result := FLocale;
end;

function TUIService.GetStyle(const AName: string): TObject;
begin
  Result := nil;
  FStyles.TryGetValue(UpperCase(AName), Result);
end;

function TUIService.Scale: integer;
var
  conf_scale: string;
begin
  Result := 100;
  conf_scale := (FWorkItem.Services[IConfigurationService] as IConfigurationService).Settings['ViewStyle.Scale'];
  if conf_scale = '2' then
    Result := 120;
end;

procedure TUIService.InfoMessage(const AMessage: string);
begin
  Windows.MessageBox(Application.Handle, PChar(AMessage),
    PChar(Application.Title), MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_SETFOREGROUND + MB_TOPMOST);
end;

function TUIService.InputBox: IInputBox;
begin
  Result := Self as IInputBox;
end;

function TUIService.InputString(const APrompt: string;
  var AText: string): boolean;
begin
  Result := InputQuery(Application.Title, APrompt, AText);
end;

function TUIService.MessageBox: IMessageBox;
begin
  Result := Self as IMessageBox;
end;

procedure TUIService.Notify(const AMessage: string);
begin
  NotifyExt('', '', AMessage, Now());
end;

procedure TUIService.NotifyAccept(const AID: string);
begin
  FWorkItem.EventTopics[ET_NOTIFY_ACCEPT].Fire(AID);
end;

procedure TUIService.NotifyExt(const AID, ASender, AMessage: string;
  ADateTime: TDateTime);
begin
  FWorkItem.EventTopics[ET_NOTIFY_MESSAGE].Fire(VarArrayOf([AID, ASender, AMessage, ADateTime]));
end;

procedure TUIService.SetLocale(AValue: string);
begin
  if (FLocale <> AValue) and (SysUtils.Languages.IndexOf(AValue) <> -1) then
  begin
    FLocale := AVAlue;
    FWorkItem.EventTopics[ET_LOCALE_CHANGED].Fire(FLocale);
  end;
end;


procedure TUIService.SetStyle(const AName: string; AValue: TObject);
begin
  FStyles.AddOrSetValue(UpperCase(AName), AValue);
end;

procedure TUIService.StartWait;
begin
  FWorkItem.EventTopics[ET_WAITBOX_START].Fire;
end;

procedure TUIService.StatusBarMessage(const AMessage: string);
begin
  FWorkItem.EventTopics[ET_STATUSBARMESSAGE].Fire(AMessage);
end;

procedure TUIService.StopWait;
begin
  FWorkItem.EventTopics[ET_WAITBOX_STOP].Fire;
end;

function TUIService.WaitBox: IWaitBox;
begin
  Result := Self as IWaitBox;
end;

end.
