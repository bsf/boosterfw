unit AbstractApp;

interface
uses Classes, CoreClasses, SysUtils, Contnrs;

const
  swRunModeStandard = 'runmode:standard';
  swRunModeConfig = 'runmode:config';
  swRunModeAdmin = 'runmode:admin';

type
  TAbstractApplication = class(TComponent)
  private
    FRootWorkItem: TWorkItem;
    procedure RegisterUnhandledExceptionHandler;
    procedure AddRequiredServices;
    procedure AuthenticateUser;
    procedure LoadModules(Kind: TModuleKind);
    procedure UnLoadModules;
    procedure NotifyAppState(const AEventName: string);
    procedure MakeTemplateConfigFile;
  protected
    procedure OnLoadModule(const AModuleName, AInfo: string; Kind: TModuleKind); virtual;
    function GetRootWorkItem: TWorkItem;
    function GetWorkItemClass: TWorkItemClass; virtual;
    procedure AddServices; virtual;
    procedure ShellInitialization; virtual;
    procedure Start; virtual; abstract;
  public
    procedure Run;
    property RootWorkItem: TWorkItem read GetRootWorkItem;
  end;

implementation
uses ModuleLoader, ModuleEnumeratorEmbeded;

{ TAbstractApplication }

procedure TAbstractApplication.AddRequiredServices;
begin
  RootWorkItem.Services.Add(IModuleLoaderService(TModuleLoaderService.Create));
  RootWorkItem.Services.Add(IModuleEnumeratorEmbeded(TModuleEnumeratorEmbeded.Create));
end;

procedure TAbstractApplication.AddServices;
begin

end;

procedure TAbstractApplication.AuthenticateUser;
var
  Svc: IAuthenticationService;
begin
  if RootWorkItem.Services.Query(IAuthenticationService, Svc) then
    Svc.Authenticate;
end;


function TAbstractApplication.GetRootWorkItem: TWorkItem;
begin
  Result := FRootWorkItem;
end;

function TAbstractApplication.GetWorkItemClass: TWorkItemClass;
begin
  Result := TWorkItem;
end;

procedure TAbstractApplication.LoadModules(Kind: TModuleKind);
var
  loader: IModuleLoaderService;
  modInnerEnum: IModuleEnumeratorEmbeded;
  modEnum: IModuleEnumerator;
  modInnerList: TClassList;
  modList: TStringList;
begin
  if RootWorkItem.Services.Query(IModuleLoaderService, loader) then
  begin
    if RootWorkItem.Services.Query(IModuleEnumeratorEmbeded, modInnerEnum) then
    begin
      modInnerList := TClassList.Create;
      try
        modInnerEnum.Modules(modInnerList, Kind);
        loader.LoadEmbeded(RootWorkItem, modInnerList, Kind, OnLoadModule);
      finally
        modInnerList.Free;
      end;
    end;

    if RootWorkItem.Services.Query(IModuleEnumerator, modEnum) then
    begin
      modList := TStringList.Create;
      try
        modEnum.Modules(modList, Kind);
        loader.Load(RootWorkItem, modList, Kind, OnLoadModule);
      finally
        modList.Free;
      end;
    end;


  end;

end;

procedure TAbstractApplication.MakeTemplateConfigFile;
begin

end;

procedure TAbstractApplication.NotifyAppState(const AEventName: string);
begin
  RootWorkItem.EventTopics[AEventName].Fire;
end;

procedure TAbstractApplication.OnLoadModule(const AModuleName, AInfo: string;
  Kind: TModuleKind);
begin

end;

procedure TAbstractApplication.RegisterUnhandledExceptionHandler;
begin

end;

procedure TAbstractApplication.Run;
begin

  RegisterUnhandledExceptionHandler();

  if FindCmdLineSwitch('makeconfig') then
  begin
    MakeTemplateConfigFile;
    Halt(1);
  end;

  // Create RootWorkItem
  FRootWorkItem := GetWorkItemClass.Create(nil, nil, 'RootWorkItem', nil);

//	IVisualizer visualizer = CreateVisualizer();
//			if (visualizer != null)
//				visualizer.Initialize(rootWorkItem, builder);

  AddRequiredServices;

  AddServices;  //virtual

  LoadModules(mkInfrastructure);

  AuthenticateUser;

  ShellInitialization; //virtual;

  LoadModules(mkFoundation);

  LoadModules(mkExtension);

  NotifyAppState(etAppStarted);

  Start;

  NotifyAppState(etAppStoped);

  UnLoadModules;

  FreeAndNil(FRootWorkItem);
//  if (visualizer != null)
//	  visualizer.Dispose();
end;

procedure TAbstractApplication.ShellInitialization;
begin

end;

procedure TAbstractApplication.UnLoadModules;
var
  loader: IModuleLoaderService;
begin
  if RootWorkItem.Services.Query(IModuleLoaderService, loader) then
    loader.UnLoadAll;
end;

initialization


end.
