unit SecurityController;

interface
uses SecurityIntf, classes, Contnrs, SysUtils, EntityServiceIntf,
   db, CoreClasses, StrUtils, variants;

const
  const_RESID_MAX_LENGTH = 38;

  ENT_USERS = 'SEC_USER';
  ENT_PERM = 'SEC_PERM';
  ENT_POLICIES = 'SEC_POLICY';

  ENT_USERS_VIEW_LIST = 'List';
  ENT_USERS_VIEW_ITEM = 'Item';
  ENT_USERS_OPER_USERROLECHECK = 'UserRoleCheck';
  ENT_USERS_OPER_USERROLEADD = 'UserRoleAdd';
  ENT_USERS_OPER_USERROLEREMOVE = 'UserRoleRemove';

  ENT_POLICY_OPER_STATE_GET = 'StateGet';
  ENT_POLICY_OPER_STATE_SET = 'StateSet';
  ENT_POLICY_OPER_RESET = 'Reset';
  
  ENT_PERM_OPER_CHECK = 'Check';
  ENT_PERM_OPER_STATE_GET = 'StateGet';
  ENT_PERM_OPER_STATE_SET = 'StateSet';
  ENT_PERM_VIEW_LIST = 'List';
  ENT_PERM_VIEW_EFFECTIVE = 'Effective';

  ENT_POLICIES_VIEW_LIST = 'List';

type
  TUserAccount = class(TComponent, IUserAccount)
  private
    FWorkItem: TWorkItem;
    FID: string;
    FAccountName: string;
    FIsRole: boolean;
    procedure LoadData;
    procedure SaveData;
  protected
    function ID: string;
    function IsRole: boolean;
    function GetAccountName: string;
    procedure SetAccountName(const AValue: string);
    function IUserAccount.GetName = GetAccountName;
    procedure IUserAccount.SetName = SetAccountName;
    //
    function RoleCheck(const ARoleID: string): boolean;
    procedure RoleAdd(const ARoleID: string);
    procedure RoleRemove(const ARoleID: string);

  public
    constructor Create(const AID: string; AWorkItem: TWorkItem); reintroduce;
  end;

  TUserAccounts = class(TComponent, IUserAccounts)
  private
    FOpened: boolean;
    FWorkItem: TWorkItem;
    FList: TComponentList;
    function Find(AID: variant): integer;
  protected
    //IUserAccounts
    function Count: integer;
    function Get(AIndex: integer): IUserAccount;
    function GetByID(const AID: string): IUserAccount;

  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    procedure Open;
    property IsOpened: boolean read FOpened write FOpened;
  end;

  TSecurityPermission = class(TComponent, ISecurityPermission)
  private
    FID: variant;
    FPolID: variant;
    FWorkItem: TWorkItem;
    FPermName: string;
    FDescription: string;
    FInheritBy: string;
  protected
    function GetPermName: string;
    function ID: string;
    function ISecurityPermission.Name = GetPermName;
    function Description: string;
    function InheritBy: string;
    function GetState(AUserID, AResID: variant): TPermissionState;
    procedure SetState(AUserID, AResID: variant; AState: TPermissionState);
  public
    constructor Create(APolID, APermID: variant;
      const AName, ADescription, AInheritBy: string; AWorkItem: TWorkItem); reintroduce;
  end;

  TSecurityPermissions = class(TComponent, ISecurityPermissions)
  private
    FPolID: variant;
    FList: TComponentList;
    FOpened: boolean;
    FWorkItem: TWorkItem;
    function Find(AID: variant): integer;
  protected
    //ISecurityPermissions
    function Count: integer;
    function Get(AIndex: integer): ISecurityPermission;
    function GetByID(AID: variant): ISecurityPermission;
  public
    constructor Create(AOwner: TComponent; APolID: Variant; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    procedure Open;
    property IsOpened: boolean read FOpened;
  end;

  TSecurityPolicies = class;

  TSecurityPolicy = class(TComponent, ISecurityPolicy)
  private
    FWorkItem: TWorkItem;
    FID: string;
    FPolicyName: string;
    FResProviderID: string;
    FPolicies: TSecurityPolicies;
    FPermissions: TSecurityPermissions;
  protected
    function GetPolicyName: string;
    function ISecurityPolicy.Name = GetPolicyName;
    function ID: string;
    function ResProviderID: string;
    function GetState: TPolicyState;
    procedure SetState(AState: TPolicyState);
    function Policies: ISecurityPolicies;
    function GetPermissionState(const AUserID,
      APermID, AResID: string): TPermissionState;
    procedure SetPermissionState(const AUserID, APermID, AResID: string;
      APermState: TPermissionState);
    function Permissions: ISecurityPermissions;
    function GetPermEffective(const PermID, ResID: string): TDataSet;
    procedure Reset;
  public
    constructor Create(const APolID, AName, AResProviderID: string;
      AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

  TSecurityPolicies = class(TComponent, ISecurityPolicies)
  private
    FOpened: boolean;
    FParentID: string;
    FList: TComponentList;
    FWorkItem: TWorkItem;
    FPoliciesEntity: IEntity;
    function Find(const AID: string): integer;
    function GetPoliciesEntity: IEntity;
  protected
    //ISecurityPolicies
    function Parent: ISecurityPolicy;
    function Count: integer;
    procedure Delete(AIndex: integer);
    function Get(AIndex: integer): ISecurityPolicy;
    function GetByID(const AID: string): ISecurityPolicy;
  public
    constructor Create(AOwner: TComponent; const AParentID: string; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    procedure Open;
    property IsOpened: boolean read FOpened;
  end;

  TPrincipal = class(TComponent, IPrincipal)
  private
    FID: string;
    FName: string;
  protected
    function IPrincipal.ID = GetPrincipalID;
    function IPrincipal.Name = GetPrincipalName;
    function GetPrincipalID: string;
    function GetPrincipalName: string;
  end;

  TSecurityBaseController = class(TComponent, ISecurityBaseController)
  private
    FPrincipal: TPrincipal;
    FPolicies: TSecurityPolicies;
    FAccounts: TUserAccounts;
    FWorkItem: TWorkItem;
    procedure LoadPrincipal(const AUserID: string);
  protected
    procedure Connect(const AUserID: string);
    procedure Disconnect;
    function GetCurrentPrincipal: IPrincipal;
    function GetAccounts: IUserAccounts;
    function GetPolicies: ISecurityPolicies;
    function CheckPermission(const AUserID, APermID, AResID: string): TPermissionState;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TSecurityBaseController }

procedure TSecurityBaseController.Connect(const AUserID: string);
begin
  LoadPrincipal(AUserID);
end;

constructor TSecurityBaseController.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FAccounts := TUserAccounts.Create(Self, FWorkItem);
  FPolicies := TSecurityPolicies.Create(Self, '', FWorkItem);
  FPrincipal := TPrincipal.Create(Self);
end;

destructor TSecurityBaseController.Destroy;
begin
  inherited;
end;

procedure TSecurityBaseController.Disconnect;
begin

end;

function TSecurityBaseController.GetPolicies: ISecurityPolicies;
begin
  if not FPolicies.IsOpened then
    FPolicies.Open;
  Result := FPolicies;

end;

function TSecurityBaseController.GetAccounts: IUserAccounts;
begin
  if not FAccounts.IsOpened then
    FAccounts.Open;

  Result := FAccounts;
end;


function TSecurityBaseController.CheckPermission(const AUserID, APermID,
  AResID: string): TPermissionState;
var
  pState: TDataSet;
  effectiveResID: string;
begin
  effectiveResID := LeftStr(AResID, const_RESID_MAX_LENGTH);

  pState := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[ENT_PERM].GetOper(ENT_PERM_OPER_CHECK, FWorkItem).
      Execute([APermID, AUserID, effectiveResID]);

  if not pState.IsEmpty then
    case pState['STATE'] of
      1: Result := psAllow;
      2: Result := psDeny;
    else
      Result := psUndefined;
    end
  else
    Result := psUndefined;

end;

function TSecurityBaseController.GetCurrentPrincipal: IPrincipal;
begin
  Result := FPrincipal as IPrincipal;
end;

procedure TSecurityBaseController.LoadPrincipal(const AUserID: string);
var
  uProp: TDataSet;
begin
  uProp := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[ENT_USERS].GetView(ENT_USERS_VIEW_ITEM, FWorkItem).Load([AUserID]);

  FPrincipal.FID := uProp['USERID'];
  FPrincipal.FNAME := uProp['NAME'];

end;

{ TUserAccounts }

function TUserAccounts.Count: integer;
begin
  Result := FList.Count;
end;

constructor TUserAccounts.Create(AOwner: TComponent;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FList := TComponentList.Create(true);
end;

destructor TUserAccounts.Destroy;
begin
  FList.Free;
  inherited;
end;

function TUserAccounts.Find(AID: variant): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if TUserAccount(FList[Result]).ID = AID then Exit;
  Result := -1;
end;

function TUserAccounts.Get(AIndex: integer): IUserAccount;
begin
  Result := TUserAccount(FList[AIndex]);
end;

function TUserAccounts.GetByID(const AID: string): IUserAccount;
var
  Idx: integer;
begin
  Idx := Find(AID);
  if Idx <> -1 then
    Result := Get(Idx)
  else
    raise Exception.CreateFmt('User account %s not found', [AID]);
end;

procedure TUserAccounts.Open;
var
  pList: TDataSet;
  Item: TUserAccount;
begin
  FList.Clear;

  pList := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[ENT_USERS].GetView(ENT_USERS_VIEW_LIST, FWorkItem).Load([]);

  while not pList.Eof do
  begin
    Item := TUserAccount.Create(pList['USERID'], FWorkItem);
    FList.Add(Item);
    pList.Next;
  end;


  FOpened := true;

end;



{ TSecurityPolicy }

constructor TSecurityPolicy.Create(const APolID, AName, AResProviderID: string;
  AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FID := APolID;
  FPolicyName := AName;
  FWorkItem := AWorkItem;
  FResProviderID := AResProviderID;
  FPolicies := TSecurityPolicies.Create(Self, FID, FWorkItem);
  FPermissions := TSecurityPermissions.Create(Self, FID, FWorkItem);
end;

destructor TSecurityPolicy.Destroy;
begin

  inherited;
end;


function TSecurityPolicy.GetPermEffective(const PermID, ResID: string): TDataSet;
begin
  Result := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[ENT_PERM].GetView(ENT_PERM_VIEW_EFFECTIVE, FWorkItem).
      Load([FID, PermID, ResID]);

end;

function TSecurityPolicy.GetPermissionState(const AUserID, APermID,
  AResID: string): TPermissionState;
var
  pState: TDataSet;
  effectiveResID: string;
begin
  effectiveResID := LeftStr(AResID, const_RESID_MAX_LENGTH);

  pState := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
      Entity[ENT_PERM].GetOper(ENT_PERM_OPER_STATE_GET, FWorkItem).
        Execute([AUserID, APermID, effectiveResID]);

  if not pState.IsEmpty then
    case pState['STATE'] of
      1: Result := psAllow;
      2: Result := psDeny;
    else
      Result := psUndefined;
    end
  else
    Result := psUndefined;

end;


function TSecurityPolicy.GetPolicyName: string;
begin
  Result := FPolicyName;
end;

function TSecurityPolicy.GetState: TPolicyState;
var
  ds: TDataSet;
begin
  ds := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
      Entity[ENT_POLICIES].GetOper(ENT_POLICY_OPER_STATE_GET, FWorkItem).
        Execute([FID]);

  if ds['STATE'] = 1 then
    Result := psActive
  else
    Result := psInactive;

end;

function TSecurityPolicy.ID: string;
begin
  Result := FID;
end;

function TSecurityPolicy.Permissions: ISecurityPermissions;
begin
  if not FPermissions.IsOpened then
    FPermissions.Open;
    
  Result := FPermissions;
end;

function TSecurityPolicy.Policies: ISecurityPolicies;
begin
  if not FPolicies.IsOpened then
    FPolicies.Open;
  Result := FPolicies;
end;

procedure TSecurityPolicy.Reset;
begin
  (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
     Entity[ENT_POLICIES].GetOper(ENT_POLICY_OPER_RESET, FWorkItem).
       Execute([FID]);
end;

function TSecurityPolicy.ResProviderID: string;
begin
  Result := FResProviderID;
end;

procedure TSecurityPolicy.SetPermissionState(const AUserID, APermID,
  AResID: string; APermState: TPermissionState);
var
  effectiveResID: string;
begin
  effectiveResID := LeftStr(AResID, const_RESID_MAX_LENGTH);

  (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
     Entity[ENT_PERM].GetOper(ENT_PERM_OPER_STATE_SET, FWorkItem).
       Execute([AUserID, APermID, AResID, Ord(APermState)]);
end;

procedure TSecurityPolicy.SetState(AState: TPolicyState);
begin
  (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
     Entity[ENT_POLICIES].GetOper(ENT_POLICY_OPER_STATE_SET, FWorkItem).
       Execute([FID, Ord(AState)]);
end;

{ TSecurityPolicies }


function TSecurityPolicies.Count: integer;
begin
  Result := FList.Count;
end;

constructor TSecurityPolicies.Create(AOwner: TComponent;
  const AParentID: string; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FParentID := AParentID;
  FList := TComponentList.Create(True);
  FWorkItem := AWorkItem;
  FOpened := false;
end;

procedure TSecurityPolicies.Delete(AIndex: integer);
begin
  FList.Delete(AIndex);
end;

destructor TSecurityPolicies.Destroy;
begin
  FList.Free;
  inherited;
end;

function TSecurityPolicies.Find(const AID: string): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if TSecurityPolicy(FList[Result]).ID = AID then Exit;
  Result := -1;
end;

function TSecurityPolicies.Get(AIndex: integer): ISecurityPolicy;
begin
  Result := TSecurityPolicy(FList[AIndex]);
end;

function TSecurityPolicies.GetByID(const AID: string): ISecurityPolicy;
var
  Idx: integer;
begin
  Idx := Find(AID);
  if Idx <> -1 then
    Result := Get(Idx)
  else
    raise Exception.CreateFmt('Security Policy %s not found', [AID]);
end;

function TSecurityPolicies.GetPoliciesEntity: IEntity;
var
  svcEntityManager: IEntityManagerService;
begin
  if not Assigned(FPoliciesEntity) then
  begin
    svcEntityManager := IEntityManagerService(FWorkItem.Services[IEntityManagerService]);
    FPoliciesEntity := svcEntityManager.Entity[ENT_POLICIES];
  end;

  Result := FPoliciesEntity;
end;

procedure TSecurityPolicies.Open;
var
  pList: TDataSet;
  Item: TSecurityPolicy;
begin
  FList.Clear;

  pList := GetPoliciesEntity.GetView('List', FWorkItem).Load([FParentID]);
  while not pList.Eof do
  begin
    Item := TSecurityPolicy.Create(pList['POLID'], pList['NAME'], VarToStr(pList['RES_PROVID']), FWorkItem);
    FList.Add(Item);
    pList.Next;
  end;

  FOpened := true;
end;



function TSecurityPolicies.Parent: ISecurityPolicy;
var
  intf: IInterface;
begin
  if Owner.GetInterface(ISecurityPolicy, intf) then
    Result := intf as ISecurityPolicy
  else
    Result := nil;
end;

{ TSecurityPermissions }

function TSecurityPermissions.Count: integer;
begin
  Result := FList.Count;
end;

constructor TSecurityPermissions.Create(AOwner: TComponent;
  APolID: Variant; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FPolID := APolID;
  FWorkItem := AWorkItem;
  FOpened := false;
  FList := TComponentList.Create(true);
end;

destructor TSecurityPermissions.Destroy;
begin
  FList.Free;
  inherited;
end;

function TSecurityPermissions.Find(AID: variant): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if TSecurityPermission(FList[Result]).ID = AID then Exit;
  Result := -1;
end;

function TSecurityPermissions.Get(AIndex: integer): ISecurityPermission;
begin
  Result := TSecurityPermission(FList[AIndex]);
end;

function TSecurityPermissions.GetByID(
  AID: variant): ISecurityPermission;
var
  Idx: integer;
begin
  Idx := Find(AID);
  if Idx <> -1 then
    Result := Get(Idx)
  else
    raise Exception.CreateFmt('Security permission %s not found', [AID]);

end;

procedure TSecurityPermissions.Open;
var
  pList: TDataSet;
  Item: TSecurityPermission;
begin
  FList.Clear;

  pList := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[ENT_PERM].GetView(ENT_PERM_VIEW_LIST, FWorkItem).Load([FPolID]);

  while not pList.Eof do
  begin
    Item := TSecurityPermission.Create(FPolID, pList['PERMID'], pList['NAME'],
      VarToStr(pList['DESCRIPTION']), VarToStr(pList['INHERITBY']), FWorkItem);
    FList.Add(Item);
    pList.Next;
  end;


  FOpened := true;
end;

{ TSecurityPermission }

constructor TSecurityPermission.Create(APolID, APermID: variant;
  const AName, ADescription, AInheritBy: string; AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FID := APermID;
  FPolID := APolID;
  FPermName := AName;
  FDescription := ADescription;
  FInheritBy := AInheritBy;
  FWorkItem := AWorkItem;
end;

function TSecurityPermission.Description: string;
begin
  Result := FDescription;
end;

function TSecurityPermission.GetPermName: string;
begin
  Result := FPermName;
end;

function TSecurityPermission.GetState(AUserID, AResID: variant): TPermissionState;
var
  pState: TDataSet;
  effectiveResID: string;
begin
  effectiveResID := LeftStr(AResID, const_RESID_MAX_LENGTH);

  pState := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
      Entity[ENT_PERM].GetOper(ENT_PERM_OPER_STATE_GET, FWorkItem).
        Execute([FID, AUserID, effectiveResID]);

  if not pState.IsEmpty then
    case pState['STATE'] of
      1: Result := psAllow;
      2: Result := psDeny;
    else
      Result := psUndefined;
    end
  else
    Result := psUndefined;

end;

function TSecurityPermission.ID: string;
begin
  Result := FID;
end;

function TSecurityPermission.InheritBy: string;
begin
  Result := FInheritBy;
end;

procedure TSecurityPermission.SetState(AUserID, AResID: variant;
  AState: TPermissionState);
var
  effectiveResID: string;
begin
  effectiveResID := LeftStr(AResID, const_RESID_MAX_LENGTH);

  (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
     Entity[ENT_PERM].GetOper(ENT_PERM_OPER_STATE_SET, FWorkItem).
       Execute([FID, AUserID, AResID, Ord(AState)]);

end;

{ TPrincipal }

function TPrincipal.GetPrincipalID: string;
begin
  Result := FID;
end;

function TPrincipal.GetPrincipalName: string;
begin
  Result := FName;
end;

{ TUserAccount }

constructor TUserAccount.Create(const AID: string; AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FID := AID;
  FWorkItem := AWorkItem;
  LoadData;
end;

function TUserAccount.GetAccountName: string;
begin
  Result := FAccountName;
end;

function TUserAccount.ID: string;
begin
  Result := FID;
end;

function TUserAccount.IsRole: boolean;
begin
  Result := FIsRole;
end;

procedure TUserAccount.LoadData;
var
  prop: TDataSet;
begin
  prop := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[ENT_USERS].GetView(ENT_USERS_VIEW_ITEM, FWorkItem).Load([FID]);
  FAccountNAME := prop['NAME'];
  FIsRole := prop['ISROLE'] = 1;

end;

procedure TUserAccount.RoleAdd(const ARoleID: string);
begin
  (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
     Entity[ENT_USERS].GetOper(ENT_USERS_OPER_USERROLEADD, FWorkItem).
      Execute([FID, ARoleID]);
end;

function TUserAccount.RoleCheck(const ARoleID: string): boolean;
begin
  Result := (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[ENT_USERS].GetOper(ENT_USERS_OPER_USERROLECHECK, FWorkItem).
      Execute([FID, ARoleID])['STATUS'] = 1;
end;

procedure TUserAccount.RoleRemove(const ARoleID: string);
begin
  (FWorkItem.Services[IEntityManagerService] as IEntityManagerService).
     Entity[ENT_USERS].GetOper(ENT_USERS_OPER_USERROLEREMOVE, FWorkItem).
      Execute([FID, ARoleID]);
end;

procedure TUserAccount.SaveData;
begin

end;

procedure TUserAccount.SetAccountName(const AValue: string);
begin
  FAccountName := AValue;
  SaveData;
end;

end.
