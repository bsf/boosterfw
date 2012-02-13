unit Updater;

interface
uses classes, constUnit, forms, sysutils, windows, DBXJSON, wininet,
  OleAuto, IOUtils, dialogs;


type
  TUpdater = class(TComponent)
  const
    UPDATE_FILE_MARKER = 'update_package';

  private
    FUserCancel: boolean;

    FSilent: boolean;
    FProcessMarker: THandle;
    FUpdateFolder: string;
    FUpdateFolderUnzip: string;
    FUpdateFileName: string;

    FAppFileName: string;
    FAppID: string;
    FLastUpdate: string;
    FCurVer: string;
    FNewVer: string;
    FNewVerUrl: string;

    FConfigFileName: string;
    FConfig: TStringList;
    FRunMode: string;
    FServerUrl: string;

    FShellView: IShellView;
    FShellViewClass: TFormClass;
    FShellViewObj: TForm;

    procedure InstallUpdate;
    procedure CheckUpdate;

    procedure SetShellViewClass(const Value: TFormClass);

    function GetProcessMarker(const ASuffix: string): THandle;
    function GetCurrentAppVersion(const AFileName: string): string;
    function GetNewAppVersionInfo(const CurVer, AppID, ServerURL: string;
      var NewVer, NewVerUrl: string): boolean;

    procedure DownloadUpdate(const AURL, AFileName: string);

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

procedure TUpdater.CheckUpdate;
var
  idx: integer;
begin

  FConfigFileName := ChangeFileExt(ParamStr(0), '.ini');
  if not FileExists(FConfigFileName) then Exit;
  FConfig.LoadFromFile(FConfigFileName);

  FAppID := FConfig.Values['AppID'];
  if FAppID = '' then FAppID := 'BoosterLauncher';

  FLastUpdate := FConfig.Values['LastUpdate'];

  FCurVer := GetCurrentAppVersion(FAppFileName);
  if FCurVer = '' then Exit;

  FServerUrl := FConfig.Values['Server'];
  if FServerUrl = '' then Exit;

  if GetNewAppVersionInfo(FCurVer, FAppID, FServerURL, FNewVer, FNewVerUrl) then
  begin
    FProcessMarker := GetProcessMarker('.updateCheck');
    if FProcessMarker = 0 then Exit;

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
    FShellView.SetVerInfo(FCurVer + ' -> ' + FNewVer);

    if not FSilent then
      Application.Run
    else
      DownloadUpdate(FNewVerUrl, FUpdateFileName);

  end;


end;

constructor TUpdater.Create(AOwner: TComponent);
begin
  inherited ;
  FConfig := TStringList.Create;
end;

destructor TUpdater.Destroy;
begin

  FConfig.Free;

  CloseHandle(FProcessMarker);

  inherited;
end;

procedure TUpdater.DownloadUpdate(const AURL, AFileName: string);
var
  hInet: HINTERNET;
  hFile: HINTERNET;
  f: File;
  buffer: array[1..1024] of byte;
  bytesRead: DWORD;
  sizeDownloaded: integer;
  fSize: integer;
  fMarker: TStringList;
  fMarkerName: string;
  errDownload: boolean;
begin

  sizeDownloaded := 0;
  errDownload := false;

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
        if not InternetReadFile(hFile, @buffer, SizeOf(buffer), bytesRead) then //Читаем буфер
        begin
          errDownload := true;
          break;
        end;

        BlockWrite(f, buffer, bytesRead); //Пишем в файл

        sizeDownloaded := sizeDownloaded + bytesRead;
        Application.ProcessMessages;
        SetViewProgressPosition(sizeDownloaded);

      until (bytesRead = 0) or FUserCancel;

    end;

    if (not FUserCancel) and (not errDownload) then
    begin
      sizeDownloaded := FileSize(f); //Откуда докачать
      if sizeDownloaded = fSize then
      begin
        fMarker := TStringList.Create;
        try
          fMarker.Add(FUpdateFileName);
          fMarkerName := ExtractFilePath(FAppFileName) + UPDATE_FILE_MARKER;
          if FileExists(fMarkerName) then
            Sysutils.DeleteFile(fMarkerName);
          fMarker.SaveToFile(fMarkerName);
        finally
          fMarker.Free;
        end;
      end;
    end;

    CloseFile(f);
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

function TUpdater.GetProcessMarker(const ASuffix: string): THandle;
var
  I: integer;
  processMarker: string;
begin
  processMarker := ParamStr(0);
  for I := 1 to Length(processMarker) do
    if processMarker[I] = '\' then
      processMarker[I] := '/';

  processMarker := processMarker + ASuffix;


  Result := CreateMutex(nil, false, PWideChar(processMarker));

  if GetLastError = ERROR_ALREADY_EXISTS then
    Result := 0;
end;


procedure TUpdater.InstallUpdate;
begin

end;

procedure TUpdater.OnShellShow;
begin
  try
    DownloadUpdate(FNewVerUrl, FUpdateFileName);
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
  runModeSwitch: string;
begin

  FindCmdLineSwitch('app', FAppFileName);
  if FAppFileName = '' then Exit;

  FSilent := FindCmdLineSwitch('silent');

  FindCmdLineSwitch('mode', runModeSwitch);
  if runModeSwitch = '' then Exit;

  if SameText(runModeSwitch, 'Install') then
    InstallUpdate
  else if SameText(runModeSwitch, 'Check') then
    CheckUpdate;

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
