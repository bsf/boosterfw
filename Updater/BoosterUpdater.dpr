program BoosterUpdater;

uses
  windows,
  sysutils,
  Wininet,
  classes,
  strUtils,
  forms,
  DBXJSON,
  ShellApi,
  ShellView in 'ShellView.pas' {frMain},
  ConstUnit in 'ConstUnit.pas',
  Updater in 'Updater.pas';

{$R *.res}

{$R uac.res}

function GetNewAppVersionInfo(const AppVersion, AppID, ServerURL: string;
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

  url := serverURL + '?q=GetNewVersion' + '&a=' + appID + '&c=' + AppVersion;
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

function GetCurrentAppVersion(const AppPath: string): string;
var
  exeDate: TDateTime;
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  Result := '';
  if FileAge(AppPath, exeDate, true) then
  begin
    DecodeDate(exeDate, Year, Month, Day);
    DecodeTime(exeDate, Hour, Min, Sec, MSec);
    Result := format('%d.%d.%d.%d.%d', [Year, Month, Day, Hour, Min]);
  end;
end;

function GetProcessMarker(const AUpdateFolder: string): THandle;
var
  updateProcessID: string;
begin
    // Создаем в страничной памяти 1-байтовый "файл" с уникальным
    // именем updateProcessID, проецируем его в свое адресное пространство
    // и проверяем, был ли он создан или просто открыт.
  updateProcessID := StringReplace(AUpdateFolder + '.updateProcess', '\', '.', [rfReplaceAll]); //slash bad simbol for CreateFileMappin

  Result := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READONLY, 0, 1, PChar(updateProcessID));


  if GetLastError = ERROR_ALREADY_EXISTS then
    Result := 0;

end;

var
  processMarker: THandle;
  updateFolder: string;
  appPath: string;

  curVer: string;
  newVer: string;
  newVerUrl: string;

  configFileName: string;
  config: TStringList;
  serverUrl: string;
  appID: string;
  updater: TUpdater;
begin

  updater := TUpdater.Create(nil);
  try
    updater.ShellViewClass := TfrMain;
    updater.Run;
  finally
    updater.Free;
  end;

{  updateFolder := ExtractFilePath(ParamStr(0));
  appPath := ParamStr(1);

  if appPath = '' then Exit;

  configFileName := ChangeFileExt(ParamStr(0), '.ini');
  if not FileExists(configFileName) then Exit;

  config := TStringList.Create;
  config.LoadFromFile(configFileName);


  serverUrl := config.Values['Server'];
  if serverUrl = '' then Exit;

  appID := config.Values['AppID'];
  if appID = '' then appID := 'BoosterLauncher';

  processMarker := GetProcessMarker(updateFolder);
  if processMarker = 0 then Exit;

  try
    curVer := GetCurrentAppVersion(appPath);

    if GetNewAppVersionInfo(curVer, appID, serverURL, newVer, newVerUrl) then
    begin
      //load and update app
      Application.Initialize;
      Application.CreateForm(TfrMain, frMain);

      frMain.Url := newVerUrl;

      frMain.Title := config.Values['Title'];
      if frMain.Title = '' then frMain.Title := 'Update Booster Framework';

      frMain.Info := config.Values['Info'];
      if frMain.Info = '' then frMain.Info := 'Update Booster Framework...';

      Application.Run;
    end;

  finally
    CloseHandle(processMarker);
  end;
 }
end.
