unit CustomApp;

interface
uses Classes, CoreClasses, SysUtils, Contnrs, Generics.Collections, forms;

type
  TCustomShellForm = class(TForm)
  public
    procedure Initialize(AWorkItem: TWorkItem); virtual; abstract;
  end;

  TShellFormClass = class of TCustomShellForm;

  TCustomApplication = class(TComponent)
  private
    class var Instance: TCustomApplication;

    FShell: TForm;
    FWorkItem: TWorkItem;
    FModules: TObjectList<TModule>;
    procedure RegisterUnhandledExceptionHandler;
    procedure AuthenticateUser;
    procedure InstModules;
    procedure LoadModules(Kind: TModuleKind);
    procedure UnLoadModules;
  protected
    //procedure OnLoadModule(const AModuleName, AInfo: string; Kind: TModuleKind); virtual;
    procedure AddServices; virtual;
  public
    class function AppInstance: TCustomApplication;
    class var ShellFormClass: TShellFormClass;

    constructor Create(AOwner: TComponent); override;
    procedure Run;
    function WorkItem: TWorkItem;
  end;



implementation


{ TAbstractApplication }


procedure TCustomApplication.AddServices;
begin

end;

class function TCustomApplication.AppInstance: TCustomApplication;
begin
  if not Assigned(Instance) then
    Instance := Self.Create(nil);
  Result := Instance;
end;

procedure TCustomApplication.AuthenticateUser;
var
  Svc: IAuthenticationService;
begin
  if WorkItem.Services.Query(IAuthenticationService, Svc) then
    Svc.Authenticate;
end;


constructor TCustomApplication.Create(AOwner: TComponent);
begin
  inherited;
  FModules := TObjectList<TModule>.Create(false);
end;

function TCustomApplication.WorkItem: TWorkItem;
begin
  Result := FWorkItem;
end;

procedure TCustomApplication.InstModules;
var
  I: integer;
begin
  for I := 0 to CoreClasses.ModuleClasses.Count - 1 do
    FModules.Add(TModuleClass(CoreClasses.ModuleClasses[I]).Create(WorkItem));
end;

procedure TCustomApplication.LoadModules(Kind: TModuleKind);
var
  I: integer;
begin
  for I := 0 to FModules.Count - 1 do
    if FModules[I].Kind = Kind then
    begin
      FModules[I].Load;
    end;
end;

procedure TCustomApplication.RegisterUnhandledExceptionHandler;
begin

end;

procedure TCustomApplication.Run;
begin

  RegisterUnhandledExceptionHandler();

  // Create RootWorkItem
  FWorkItem := TWorkItem.Create(nil, nil, 'RootWorkItem', nil);

  AddServices;  //virtual

  InstModules;

  LoadModules(mkInfrastructure);

  AuthenticateUser;

  Application.Initialize;

  if not Assigned(ShellFormClass) then
    raise Exception.Create('MainForm class not setting');

  Application.CreateForm(ShellFormClass, FShell);

  TCustomShellForm(FShell).Initialize(WorkItem);

  LoadModules(mkFoundation);

  LoadModules(mkExtension);

  WorkItem.EventTopics[etAppStarted].Fire;

  Application.Run;

  WorkItem.EventTopics[etAppStoped].Fire;

  UnLoadModules;

  FreeAndNil(FWorkItem);
end;


procedure TCustomApplication.UnLoadModules;
var
  I: integer;
begin
  for I := 0 to FModules.Count - 1 do
    FModules[I].UnLoad;
end;



end.
