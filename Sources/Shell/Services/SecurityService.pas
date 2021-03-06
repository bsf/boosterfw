unit SecurityService;

interface
uses SecurityIntf, CoreClasses, classes, ConfigServiceIntf, SysUtils, Contnrs,
  IniFiles, EntityServiceIntf, variants;

type

  TSecurityService = class(TComponent, ISecurityService, IAuthenticationService, IActivityPermissionHandler)
  const
    PERMISSION_ACTIVITY_EXECUTE = 'app.activity.execute';

  private
    FWorkItem: TWorkItem;
    FResProviders: TInterfaceList;
    FIsAuthenticated: boolean;
    FBaseController: ISecurityBaseController;
    function AppSettings: ISettings;
    procedure LoginAuthenticateFunc(AUserData: ILoginUserData);
  protected
    //IAutenticationService
    procedure Authenticate;
    //ISecurityService
    procedure RegisterSecurityBaseController(AController: ISecurityBaseController);

    procedure RegisterResProvider(AProvider: ISecurityResProvider);
    procedure RemoveResProvider(AProvider: ISecurityResProvider);
    function GetResProvider(AProviderID: string): ISecurityResProvider;

    procedure DemandPermission(const APermID, AResID: string);
    function CheckPermission(const APermID, AResID: string): boolean;

    function CurrentPrincipal: IPrincipal;
    function Accounts: IUserAccounts;
    function Policies: ISecurityPolicies;
    function FindPolicy(const APolID: string): ISecurityPolicy;
    //IActivityPermissionHandler
    function ActivityCheckPermission(Activity: IActivity): boolean;
    procedure ActivityDemandPermission(Activity: IActivity);
    function IActivityPermissionHandler.CheckPermission = ActivityCheckPermission;
    procedure IActivityPermissionHandler.DemandPermission = ActivityDemandPermission;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;

  end;

implementation

{ TSecurityService }

function TSecurityService.Accounts: IUserAccounts;
begin
  Result := FBaseController.GetAccounts;
end;

function TSecurityService.ActivityCheckPermission(Activity: IActivity): boolean;
begin
  Result := CheckPermission(PERMISSION_ACTIVITY_EXECUTE, Activity.URI);
end;

procedure TSecurityService.ActivityDemandPermission(Activity: IActivity);
begin
  DemandPermission(PERMISSION_ACTIVITY_EXECUTE, Activity.URI);
end;

function TSecurityService.AppSettings: ISettings;
begin
  Result := IConfigurationService(
    FWorkItem.Services[IConfigurationService]).Settings;
end;

procedure TSecurityService.Authenticate;
var
  UserSelectorSvc: ILoginUserSelectorService;
begin
  UserSelectorSvc := ILoginUserSelectorService(FWorkItem.Services[ILoginUserSelectorService]);
  UserSelectorSvc.SelectUser(LoginAuthenticateFunc);
  if not FIsAuthenticated then
  begin

    NoErrMsg := true;

    Halt(1);
  end;
end;

function TSecurityService.CheckPermission(const APermID, AResID: string): boolean;
begin
  Result :=
    FBaseController.CheckPermission(FBaseController.GetCurrentPrincipal.ID,
      APermID, AResID) = psAllow;
end;

constructor TSecurityService.Create(AOwner: TComponent;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FResProviders := TInterfaceList.Create;
  FWorkItem.Activities.RegisterPermissionHandler(Self);
//  Actions.RegisterCondition(SecurityActionCondition); //??
end;

function TSecurityService.CurrentPrincipal: IPrincipal;
begin
  Result := FBaseController.GetCurrentPrincipal;
end;

procedure TSecurityService.DemandPermission(const APermID, AResID: string);
begin
  if not CheckPermission(APermID, AResID) then
    raise ESecurity.Create('�������� � ������� � �������');
end;

destructor TSecurityService.Destroy;
begin
  FResProviders.Clear;
  FResProviders.Free;
  inherited;
end;

function TSecurityService.FindPolicy(
  const APolID: string): ISecurityPolicy;

  function FindPol(const AID: string; APolicies: ISecurityPolicies): ISecurityPolicy;
  var
    I: integer;
  begin
    for I := 0 to APolicies.Count - 1 do
    begin
      if APolicies.Get(I).ID = AID then
      begin
        Result := APolicies.Get(I);
        Exit;
      end;
      Result := FindPol(AID, APolicies.Get(I).Policies);
      if Result <> nil then Exit;
    end;
    Result := nil;
  end;

begin
  Result := FindPol(APolID, Policies);
end;

function TSecurityService.GetResProvider(
  AProviderID: string): ISecurityResProvider;
var
  I: integer;
begin
  for I := 0 to FResProviders.Count - 1 do
  begin
    Result := ISecurityResProvider(FResProviders[I]);
    if Result.ID = AProviderID then Exit;
  end;
  raise Exception.CreateFmt('SecurityResProvider %s not found', [AProviderID]);
  //Result := nil;
end;

procedure TSecurityService.LoginAuthenticateFunc(AUserData: ILoginUserData);
var
  connEngine: string;
  connParams: string;
  entitySvc: IEntityService;
begin

  AppSettings.UserID := UpperCase(AUserData.ID);
  AppSettings['USERID'] := AppSettings.UserID;
  AppSettings['PASSWORD'] := AUserData.Password;
  AppSettings.CurrentAlias := AUserData.Options.Values['ALIAS'];

  connEngine := AppSettings['Connection.Engine'];
  connParams := AppSettings['Connection.Params'];

  if connEngine = '' then
    raise Exception.Create('�� ������ �������� ����������� (Connection.Engine)');

  if connParams = '' then
    raise Exception.Create('�� ������� ��������� ����������� (Connection.Params)');

  entitySvc := (FWorkItem.Services[IEntityService] as IEntityService);

  entitySvc.Connect(connEngine, connParams);

  try
    FBaseController.Connect(AppSettings.UserID);
  except
    entitySvc.Disconnect;
    raise;
  end;

  AppSettings['USERNAME'] := CurrentPrincipal.Name;

  FIsAuthenticated := true;
end;

function TSecurityService.Policies: ISecurityPolicies;
begin
  Result := FBaseController.GetPolicies;
end;

procedure TSecurityService.RegisterResProvider(
  AProvider: ISecurityResProvider);
begin
  FResProviders.Add(AProvider);
end;

procedure TSecurityService.RegisterSecurityBaseController(
  AController: ISecurityBaseController);
begin
  FBaseController := AController;
end;

procedure TSecurityService.RemoveResProvider(
  AProvider: ISecurityResProvider);
begin

end;

end.
