unit Updater;

interface
uses classes, constUnit, forms, sysutils, windows, DBXJSON, wininet;

type
  TUpdater = class(TComponent)
  private
    FUserCancel: boolean;

    FProcessMarker: THandle;
    FUpdateFolder: string;
    FUpdateFileName: string;
    FAppFileName: string;
    FCurVer: string;
    FNewVer: string;
    FNewVerUrl: string;


    FConfigFileName: string;
    FConfig: TStringList;
    FServerUrl: string;
    FAppID: string;

    FShellView: IShellView;
    FShellViewClass: TFormClass;
    FShellViewObj: TForm;

    procedure SetShellViewClass(const Value: TFormClass);

    function GetProcessMarker: THandle;
    function GetCurrentAppVersion(const AFileName: string): string;
    function GetNewAppVersionInfo(const CurVer, AppID, ServerURL: string;
      var NewVer, NewVerUrl: string): boolean;

    function DownloadUpdate(const AURL, AFileName: string): boolean;
    function InstallUpdate: boolean;

    procedure SetViewProgressMax(AValue: integer);
    procedure SetViewProgressPosition(AValue: integer);

    procedure OnShellShow;
    procedure OnUserCancel;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ShellViewClass: TFormClass read FShellViewClass write SetShellViewClass;
    procedure Run;
  end;

implementation

{ TUpdater }

constructor TUpdater.Create(AOwner: TComponent);
begin
  inherited ;

  FConfig := TStringList.Create;
  FProcessMarker := GetProcessMarker;

end;

destructor TUpdater.Destroy;
begin

  FConfig.Free;
  CloseHandle(FProcessMarker);

  inherited;
end;

function TUpdater.DownloadUpdate(const AURL, AFileName: string): boolean;
var
  hInet: HINTERNET;
  hFile: HINTERNET;
  f: File;
  buffer: array[1..1024] of byte;
  bytesRead: DWORD;
  sizeDownloaded: integer;
  fSize: integer;
  err: boolean;
begin
  Result := false;

  err := false;
  sizeDownloaded := 0;

  AssignFile(f, AFileName);
  if FileExists(AFileName) then
  begin
    Reset(f, 1); //Ах, есть? Откроем!
    sizeDownloaded := FileSize(f); //Откуда докачать
    Seek(f, FileSize(f)); //А писать будем в конец
  end
  else
    Rewrite(f, 1);

  hInet := InternetOpen(AGENT_NAME, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  hFile := InternetOpenURL(hInet, PWideChar(AUrl), nil, 0, 0, 0);
  if Assigned(hFile) then
  begin

    fSize := InternetSetFilePointer(hFile, 0, nil, FILE_END, 0);

    SetViewProgressMax(fSize);
    SetViewProgressPosition(sizeDownloaded);

    if fSize <> sizeDownloaded then
    begin

      InternetSetFilePointer(hFile, sizeDownloaded, nil, 0, 0); //Cместимся

      repeat
        err := InternetReadFile(hFile, @buffer, SizeOf(buffer), bytesRead); //Читаем буфер

        if err = false then //Ошибка чтения
          break;

        BlockWrite(f, buffer, bytesRead); //Пишем в файл

        sizeDownloaded := sizeDownloaded + bytesRead;
        Application.ProcessMessages;
        SetViewProgressPosition(sizeDownloaded);

      until (bytesRead = 0) or FUserCancel;

    end;

    CloseFile(f);

    Result := (not FUserCancel) and (not err);

    InternetCloseHandle(hFile);

  end;
  InternetCloseHandle(hInet);

end;

function TUpdater.GetCurrentAppVersion(const AFileName: string): string;
var
  exeDate: TDateTime;
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  Result := '';
  if FileAge(AFileName, exeDate, true) then
  begin
    DecodeDate(exeDate, Year, Month, Day);
    DecodeTime(exeDate, Hour, Min, Sec, MSec);
    Result := format('%d.%d.%d.%d.%d', [Year, Month, Day, Hour, Min]);
  end;

end;

function TUpdater.GetNewAppVersionInfo(const CurVer, AppID, ServerURL: string;
  var NewVer, NewVerUrl: string): boolean;
var
  hSession: HInternet;
  hUrl: HInternet;
  dwFlags: LPDWORD;
  bufferLen: DWORD;
  buffer: array[1..1024] of AnsiChar;
  I: integer;
  url: string;
  responseText: UTF8String;
  responseObj: TJSONObject;
  responseVal: TJSONPair;
begin

  Result := false;
  NewVer := '';
  NewVerUrl := '';

  dwFlags := nil;
  if not InternetGetConnectedState(dwFlags,0) then Exit;

  hSession:= InternetOpen('BoosterUpdater', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  url := serverURL + '?q=GetNewVersion' + '&a=' + appID + '&c=' + CurVer;
  hUrl := InternetOpenUrl(hSession, PWideChar(url), nil, 0, 0, 0);

  for I := 1 to 1024 do Buffer[I] := #0;

  if InternetReadFile(hUrl, @buffer, SizeOf(buffer), bufferLen) then
  begin

    responseText := Copy(buffer, 1, bufferLen);
    SetLength(responseText, bufferLen);
    //responseText := '{"ver":"2012.02.11","url":"https://github.com/downloads/bsf/boosterfw/BoosterApp.zip"}';
    responseObj := TJSONObject.ParseJSONValue(responseText) as TJSONObject;
    if Assigned(responseObj) then //парсинг прошел успешно - считываем названия пар
    begin
      responseVal := responseObj.Get('ver');
      if responseVal <> nil then
        NewVer := responseVal.JsonValue.Value;

      responseVal := responseObj.Get('url');
      if responseVal <> nil then
        NewVerUrl := responseVal.JsonValue.Value;

      Result := (NewVer <> '') and (NewVerUrl <> '');

    end;
  end;

  InternetCloseHandle(hUrl);
  InternetCloseHandle(hSession);

end;

function TUpdater.GetProcessMarker: THandle;
var
  updateProcessID: string;
begin
    // Создаем в страничной памяти 1-байтовый "файл" с уникальным
    // именем updateProcessID, проецируем его в свое адресное пространство
    // и проверяем, был ли он создан или просто открыт.
  updateProcessID := StringReplace(ExtractFilePath(ParamStr(0)) + '.updateProcess', '\', '.', [rfReplaceAll]); //slash bad simbol for CreateFileMappin

  Result := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READONLY, 0, 1, PChar(updateProcessID));


  if GetLastError = ERROR_ALREADY_EXISTS then
    Result := 0;
end;

function TUpdater.InstallUpdate: boolean;
begin

end;

procedure TUpdater.OnShellShow;
begin
  try
    if DownloadUpdate(FNewVerUrl, FUpdateFileName) then
      if InstallUpdate then
      begin

      end;

  finally
    Application.Terminate;
  end;
end;

procedure TUpdater.OnUserCancel;
begin
  FUserCancel := true;
end;

procedure TUpdater.Run;
var
  idx: integer;
begin
  if FProcessMarker = 0 then Exit;

  FAppFileName := ParamStr(1);
  if FAppFileName = '' then Exit;

  FConfigFileName := ChangeFileExt(ParamStr(0), '.ini');
  if not FileExists(FConfigFileName) then Exit;
  FConfig.LoadFromFile(FConfigFileName);

  FServerUrl := FConfig.Values['Server'];
  if FServerUrl = '' then Exit;

  FAppID := FConfig.Values['AppID'];
  if FAppID = '' then FAppID := 'BoosterLauncher';

  FCurVer := GetCurrentAppVersion(FAppFileName);
  if FCurVer = '' then Exit;

  if GetNewAppVersionInfo(FCurVer, FAppID, FServerURL, FNewVer, FNewVerUrl) then
  begin

    FUpdateFolder := ExtractFilePath(ParamStr(0)) + 'Downloads\' + FNewVer + '\';

    if not DirectoryExists(FUpdateFolder) then
      if not ForceDirectories(FUpdateFolder) then Exit;

    idx := LastDelimiter('\:/', FNewVerUrl);
    FUpdateFileName := Copy(FNewVerUrl, idx + 1, MaxInt);
    FUpdateFileName := FUpdateFolder + FUpdateFileName;

    Application.Initialize;
    Application.CreateForm(FShellViewClass, FShellViewObj);
    FShellViewObj.GetInterface(IShellView, FShellView);

    FShellView.SetOnShowCallback(OnShellShow);
    FShellView.SetOnUserCancelCallback(OnUserCancel);

    FShellView.SetTitle(FConfig.Values['Title']);
    FShellView.SetInfo(FConfig.Values['Info']);

    Application.Run;
  end;

end;

procedure TUpdater.SetShellViewClass(const Value: TFormClass);
begin
  FShellViewClass := Value;
end;


procedure TUpdater.SetViewProgressMax(AValue: integer);
begin
  FShellView.SetProgressMax(AValue);
end;

procedure TUpdater.SetViewProgressPosition(AValue: integer);
begin
  FShellView.SetProgressPosition(AValue);
end;

end.
