unit AbstractApp;

interface
uses Classes, CoreClasses, SysUtils, Contnrs, Generics.Collections;

type
  TAbstractApplication = class(TComponent)
  private
    FRootWorkItem: TWorkItem;
    FModules: TObjectList<TModule>;
    procedure RegisterUnhandledExceptionHandler;
    procedure AuthenticateUser;
    procedure InstModules;
    procedure LoadModules(Kind: TModuleKind);
    procedure UnLoadModules;
  protected
    procedure OnLoadModule(const AModuleName, AInfo: string; Kind: TModuleKind); virtual;
    function GetRootWorkItem: TWorkItem;
    function GetWorkItemClass: TWorkItemClass; virtual;
    procedure AddServices; virtual;
    procedure ShellInitialization; virtual;
    procedure Start; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Run;
    property RootWorkItem: TWorkItem read GetRootWorkItem;
  end;

implementation


{ TAbstractApplication }


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


constructor TAbstractApplication.Create(AOwner: TComponent);
begin
  inherited;
  FModules := TObjectList<TModule>.Create(false);
end;

function TAbstractApplication.GetRootWorkItem: TWorkItem;
begin
  Result := FRootWorkItem;
end;

function TAbstractApplication.GetWorkItemClass: TWorkItemClass;
begin
  Result := TWorkItem;
end;

procedure TAbstractApplication.InstModules;
var
  I: integer;
begin
  for I := 0 to CoreClasses.ModuleClasses.Count - 1 do
    FModules.Add(TModuleClass(CoreClasses.ModuleClasses[I]).Create(RootWorkItem));
end;

procedure TAbstractApplication.LoadModules(Kind: TModuleKind);
var
  I: integer;
begin
  for I := 0 to FModules.Count - 1 do
    if FModules[I].Kind = Kind then FModules[I].Load;
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

  // Create RootWorkItem
  FRootWorkItem := GetWorkItemClass.Create(nil, nil, 'RootWorkItem', nil);

  AddServices;  //virtual

  InstModules;

  LoadModules(mkInfrastructure);

  AuthenticateUser;

  ShellInitialization; //virtual;

  LoadModules(mkFoundation);

  LoadModules(mkExtension);

  RootWorkItem.EventTopics[etAppStarted].Fire;

  Start;

  RootWorkItem.EventTopics[etAppStoped].Fire;

  UnLoadModules;

  FreeAndNil(FRootWorkItem);
end;

procedure TAbstractApplication.ShellInitialization;
begin

end;

procedure TAbstractApplication.UnLoadModules;
var
  I: integer;
begin
  for I := 0 to FModules.Count - 1 do
    FModules[I].UnLoad;

end;

initialization


end.
