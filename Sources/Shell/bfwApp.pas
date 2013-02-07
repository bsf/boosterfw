unit bfwApp;

interface

uses windows, classes, forms, sysutils, graphics,
  CustomApp, CoreClasses, ShellIntf,
  ShellLogin,
  ConfigServiceIntf, ConfigService,
  SecurityIntf, SecurityService, SecurityController,
  EntityServiceIntf, EntityService,
  UIServiceIntf, UIService,
  LicenseServiceIntf, LicenseService;

const
  APP_VERSION = 'ver 1.0';

type
  TApp = class(TCustomApplication, IApp)
  private
    FLogo: Graphics.TBitmap;
    procedure UpdateApplication;
  protected
    procedure AddServices; override;
    procedure RemoveServices; override;
    procedure OnLoadModule(const AModuleName, AInfo: string; Kind: TModuleKind);
    //IApp
    function Version: string;
    function Logo: Graphics.TBitmap;
    function Settings: ISettings;
    function UserProfile: IProfile;
    function HostProfile: IProfile;
    function UI: IUIService;
    function Entities: IEntityService;
    function Security: ISecurityService;
  end;


implementation


{ TApp }

procedure TApp.AddServices;
var
  securityService: TSecurityService;
begin

  //Config
  WorkItem.Services.Add(
    IConfigurationService(TConfigurationService.Create(Self, WorkItem)));

  UpdateApplication;

  //UI
  WorkItem.Services.Add(
    TUIService.Create(Self, WorkItem) as IUIService);

  //License
  WorkItem.Services.Add(
    TLicenseService.Create(Self, WorkItem) as ILicenseService);

  //Security
  securityService := TSecurityService.Create(Self, WorkItem);
  WorkItem.Services.Add(ISecurityService(securityService));
  WorkItem.Services.Add(IAuthenticationService(securityService));
  (securityService as ISecurityService).RegisterSecurityBaseController(
    TSecurityBaseController.Create(Self, WorkItem));

  WorkItem.Services.Add(
    ILoginUserSelectorService(TLoginUserSelectorService.Create(Self, WorkItem)));

  //DAL
  WorkItem.Services.Add(
    IEntityService(TEntityService.Create(Self, WorkItem)));

end;

function TApp.Settings: ISettings;
begin
  Result := IConfigurationService(WorkItem.
    Services[IConfigurationService]).Settings;
end;

function TApp.UI: IUIService;
begin
  Result := WorkItem.Services[IUIService] as IUIService;
end;


procedure TApp.UpdateApplication;

type
  UpdaterRunMode = (rmInstall, rmCheck);

  procedure RunUpdater(ARunMode: UpdaterRunMode);
  const
    const_UpdaterFileName = 'BoosterUpdater.exe';

  var
    cpResult: boolean;
    startInfo: TStartupInfo;
    procInfo: TProcessInformation;
    commandLine: string;
    modeSwitch: string;
  begin
    case ARunMode of
      rmInstall: modeSwitch := 'Install';
      rmCheck: modeSwitch := 'Check';
    end;

    commandLine := ExtractFilePath(ParamStr(0)) + 'Update\' + const_UpdaterFileName +
      ' -silent -runApp ' + ' -app ' + ParamStr(0) + ' -mode ' + modeSwitch;

    FillChar(StartInfo, SizeOf(TStartUpInfo), #0);
    FillChar(ProcInfo, SizeOf(TProcessInformation), #0);
    StartInfo.cb := SizeOf(TStartUpInfo);
    StartInfo.dwFlags     := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
    StartInfo.wShowWindow := SW_SHOWNORMAL;

    UniqueString(commandLine);

    cpResult := CreateProcess(nil, pchar(commandLine), nil, nil, true,
      NORMAL_PRIORITY_CLASS, nil, nil, startInfo, procInfo);

    if cpResult then
    begin
    //  WaitForInputIdle(procInfo.hProcess, INFINITE); // ждем завершения инициализации
   //   WaitforSingleObject(procInfo.hProcess, INFINITE); // ждем завершения процесса
      CloseHandle(procInfo.hThread); // закрываем дескриптор процесса
      CloseHandle(procInfo.hProcess); // закрываем дескриптор потока
    end;

  end;

  function CheckProcessStarted(const AProcessMarker: string): boolean;
  var
    hFile: THandle;
  begin

    hFile := CreateMutex(nil, false, PChar(AProcessMarker));

    Result := (GetLastError = ERROR_ALREADY_EXISTS);

    CloseHandle(hFile);

  end;

const
  const_NeedInstallFile = 'update_package';

var
  processMarker: string;
  I: integer;
begin

  if Settings['Updater.Enabled'] <> '1' then Exit;

  processMarker := ParamStr(0);
  for I := 1 to Length(processMarker) do
    if processMarker[I] = '\' then
      processMarker[I] := '/';

  if CheckProcessStarted(processMarker + '.updateInstall') then Halt(0);

  if FileExists(ExtractFilePath(ParamStr(0)) + const_NeedInstallFile) then
  begin
    RunUpdater(rmInstall);
    Halt(0);
  end;

  if not CheckProcessStarted(processMarker + '.updateCheck') then
    RunUpdater(rmCheck);


end;

function TApp.UserProfile: IProfile;
begin
  Result := IConfigurationService(WorkItem.
    Services[IConfigurationService]).UserProfile;
end;

function TApp.HostProfile: IProfile;
begin
  Result := IConfigurationService(WorkItem.
    Services[IConfigurationService]).HostProfile;
end;

function TApp.Logo: Graphics.TBitmap;
var
  logoFileName: string;
begin
  if FLogo = nil then
  begin
    FLogo := TBitmap.Create;
    if FindResource(HInstance, RES_ID_APP_LOGO, RT_BITMAP) <> 0 then
      FLogo.LoadFromResourceName(HInstance, 'APP_LOGO')
    else
    begin
      logoFileName := ChangeFileExt(ParamStr(0), '.bmp');
      if FileExists(logoFileName) then
        FLogo.LoadFromFile(logoFileName);
    end;
  end;
  Result := FLogo;
end;

function TApp.Entities: IEntityService;
begin
  Result := IEntityService(WorkItem.Services[IEntityService]);
end;


function TApp.Security: ISecurityService;
begin
  Result := ISecurityService(WorkItem.Services[ISecurityService]);
end;


function TApp.Version: string;
var
  exeDate: TDateTime;
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  exeDate := FileDateToDateTime(FileAge(Application.ExeName));
  DecodeDate(exeDate, Year, Month, Day);
  DecodeTime(exeDate, Hour, Min, Sec, MSec);
  Result := format('%d.%d.%d.%d.%d', [Year, Month, Day, Hour, Min]);
  Result := APP_VERSION + ' [' + Result + ']';
end;

procedure TApp.OnLoadModule(const AModuleName, AInfo: string; Kind: TModuleKind);
begin

end;

procedure TApp.RemoveServices;
begin
  try
    (WorkItem.Services[IEntityService] as IEntityService).Disconnect;
  except

  end;
end;

end.
