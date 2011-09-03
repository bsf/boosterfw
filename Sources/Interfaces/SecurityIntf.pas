unit SecurityIntf;

interface
uses SysUtils, Classes, CoreClasses, db;

type
  ESecurity = class(Exception);


  ILoginUserData = interface
  ['{945C4A21-C285-49D6-B39B-FD563F822165}']
    function ID: string;
    function Password: string;
    function Options: TStrings;
  end;

  TLoginAuthenticateFunc = procedure(ALoginUserData: ILoginUserData) of object;

  ILoginUserSelectorService = interface
  ['{EA12E46D-45F6-4757-8CC7-9AC720D95706}']
    procedure SelectUser(AuthenticateFunc: TLoginAuthenticateFunc);
  end;


//-------------- Accounts ------------------------------------------------------


  IUserAccount = interface
    function ID: string;
    function IsRole: boolean;
    function GetName: string;
    procedure SetName(const AValue: string);
    property Name: string read GetName write SetName;
    function RoleCheck(const ARoleID: string): boolean;
    procedure RoleAdd(const ARoleID: string);
    procedure RoleRemove(const ARoleID: string);
  end;

  IUserAccounts = interface
  ['{7145845E-9048-4256-9411-FD4AFF59D726}']
    function Count: integer;
    function Get(AIndex: integer): IUserAccount;
    function GetByID(const AID: string): IUserAccount;
    property Item[const AID: string]: IUserAccount read GetByID; default;
  end;


//-------------------- Permissions ---------------------------------------------
  TPermissionState = (psUndefined, psAllow, psDeny);
  TPolicyState = (psInactive, psActive);

  ISecurityPermission = interface
  ['{42623D27-9D7B-4B50-A26F-FC00F757F163}']
    function ID: string;
    function Name: string;
    function Description: string;
    function InheritBy: string;
    function GetState(AUserID, AResID: variant): TPermissionState;
    procedure SetState(AUserID, AResID: variant; AState: TPermissionState);
  end;

  ISecurityPermissions = interface
  ['{B8D566B2-FF42-4124-8E5C-E747BD1A6A3B}']
    function Count: integer;
    function Get(AIndex: integer): ISecurityPermission;
    function GetByID(AID: variant): ISecurityPermission;
    property Item[AID: variant]: ISecurityPermission read GetByID; default;
  end;

  ISecurityPolicies = interface;

  ISecurityPolicy = interface
  ['{ED8AACFA-336D-4C2D-A235-CDE8DCEF5352}']
    function Name: string;
    function ID: string;
    function ResProviderID: string;
    function GetState: TPolicyState;
    procedure SetState(AValue: TPolicyState);
    function Policies: ISecurityPolicies;
    function Permissions: ISecurityPermissions;
    function GetPermEffective(const PermID, ResID: string): TDataSet;
    procedure Reset;
  end;

  ISecurityPolicies = interface
  ['{917CBB4B-34CB-4A7B-A853-5A44FFDB05EB}']
    function Parent: ISecurityPolicy;
    function Count: integer;
    function Get(AIndex: integer): ISecurityPolicy;
    function GetByID(const AID: string): ISecurityPolicy;
    property Item[const AID: string]: ISecurityPolicy read GetByID; default;
  end;

  ISecurityResNode = interface
  ['{A6DB4815-F445-41D5-BC3A-1EFBE4233035}']
    function ID: string;
    function Name: string;
    function Description: string;
  end;

  ISecurityResProvider = interface
  ['{7A25A9DE-286E-4125-9675-9B8D398CBA0E}']
    function ID: string;
    function GetTopRes: IInterfaceList;
    function GetChildRes(const ParentResID: string): IInterfaceList;
    function GetRes(const ID: string): ISecurityResNode;
  end;

//------------------------------------------------------------------------------

  IPrincipal = interface
  ['{D4D801CF-156A-4FCC-B39F-5A1F34EBA2D7}']
    function ID: string;
    function Name: string;
  end;

  ISecurityBaseController = interface
  ['{251133FB-5818-4D94-A9C9-CAF2A4121176}']
    procedure Connect(const AUserID: string);
    procedure Disconnect;
    function GetCurrentPrincipal: IPrincipal;
    function GetAccounts: IUserAccounts;
    function GetPolicies: ISecurityPolicies;
    function CheckPermission(const AUserID, APermID, AResID: string): TPermissionState;
  end;

  ISecurityService = interface(IAuthenticationService)
  ['{82144D5F-E1A9-4AD4-ABDC-F60AF715BEF9}']
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
  end;

implementation

end.
