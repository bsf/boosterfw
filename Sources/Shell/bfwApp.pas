unit bfwApp;

interface

uses windows, classes, forms, sysutils, graphics,
  CustomApp, CoreClasses, ShellIntf,
  ShellLogin, ShellSplashForm,
  ConfigServiceIntf, ConfigService,
  SecurityIntf, SecurityService, SecurityController,
  EntityServiceIntf, EntityService,
  UIServiceIntf, UIService;

const
  APP_VERSION = 'ver 1.0';

type
  TApp = class(TCustomApplication, IApp)
  private
    FLogo: Graphics.TBitmap;
    FSplash: TShellSplash;
    procedure SplashShow;
    procedure SplashHide;
    procedure SplashUpdate;
  protected
    procedure AddServices; override;
    procedure OnStart; override;
    procedure OnShellInitialization; override;
    procedure OnLoadModule(const AModuleName, AInfo: string; Kind: TModuleKind); override;
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

  //UI
  WorkItem.Services.Add(
    TUIService.Create(Self, WorkItem) as IUIService);

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

procedure TApp.OnShellInitialization;
begin
  SplashShow;
end;


procedure TApp.OnStart;
begin
  SplashHide;
end;

function TApp.UI: IUIService;
begin
  Result := WorkItem.Services[IUIService] as IUIService;
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
  SplashUpdate;
end;

procedure TApp.SplashHide;
begin
  if Assigned(FSplash) then FSplash.Hide;
end;

procedure TApp.SplashShow;
begin
//  FSplash := TShellSplash.Create;
 // FSplash.Show('', 100);
end;

procedure TApp.SplashUpdate;
begin
  if Assigned(FSplash) then FSplash.Update('');
end;



end.
