unit AdminController;

interface
uses classes, CoreClasses, ShellIntf,
  ActivityServiceIntf, UIClasses,
  SecurityPoliciesPresenter, SecurityPoliciesView,
  SecurityPolicyPresenter, SecurityPolicyView,
  SecurityPolicyResPresenter, SecurityPolicyResView,
  SecurityPermEffectivePresenter, SecurityPermEffectiveView,
  UserAccountsPresenter, UserAccountsView,
  AdminConst;

type
  TAdminController = class(TWorkItemController)
  protected
    procedure Initialize; override;
  end;

implementation

{ TAdminController }

procedure TAdminController.Initialize;
var
  svc: IActivityService;
begin
  svc := WorkItem.Services[IActivityService] as IActivityService;

  with svc.RegisterActivityInfo(VIEW_SECURITYPOLICIES) do
  begin
    Title := VIEW_SECURITYPOLICIES_TITLE;
    Group := MAIN_MENU_SERVICE_GROUP;
    UsePermission := true;
  end;
  svc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_SECURITYPOLICIES, TSecurityPoliciesPresenter, TfrSecurityPoliciesView));

  with svc.RegisterActivityInfo(VIEW_USERACCOUNTS) do
  begin
    Title := VIEW_USERACCOUNTS_CAPTION;
    Group := MAIN_MENU_SERVICE_GROUP;
    UsePermission := true;
  end;
  svc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_USERACCOUNTS, TUserAccountsPresenter, TfrUserAccountsView));

  svc.RegisterActivityInfo(VIEW_SECURITYPOLICY);
  svc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
   VIEW_SECURITYPOLICY, TSecurityPolicyPresenter, TfrSecurityPolicyView));

  svc.RegisterActivityInfo(VIEW_SECURITYPOLICYRES);
  svc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_SECURITYPOLICYRES, TSecurityPolicyResPresenter, TfrSecurityPolicyResView));

  svc.RegisterActivityInfo(VIEW_SECURITYPERMEFFECTIVE);
  svc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_SECURITYPERMEFFECTIVE, TSecurityPermEffectivePresenter, TfrSecurityPermEffectiveView));


end;

end.
