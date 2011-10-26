unit AdminController;

interface
uses classes, CoreClasses, ShellIntf, CustomUIController,
  ActivityServiceIntf, CommonViewIntf,
  SecurityPoliciesPresenter, SecurityPoliciesView,
  SecurityPolicyPresenter, SecurityPolicyView,
  SecurityPolicyResPresenter, SecurityPolicyResView,
  SecurityPermEffectivePresenter, SecurityPermEffectiveView,
  UserAccountsPresenter, UserAccountsView,
  AdminConst;

type
  TAdminController = class(TCustomUIController)
  protected
    procedure OnInitialize; override;
  end;

implementation

{ TAdminController }

procedure TAdminController.OnInitialize;
var
  svc: IActivityService;
begin
  svc := WorkItem.Services[IActivityService] as IActivityService;

  with svc.RegisterActivityInfo(VIEW_SECURITYPOLICIES) do
  begin
    Title := VIEW_SECURITYPOLICIES_TITLE;
    Group := MAIN_MENU_SERVICE_GROUP;
  end;
  svc.RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
    VIEW_SECURITYPOLICIES, TSecurityPoliciesPresenter, TfrSecurityPoliciesView));


  RegisterView(VIEW_SECURITYPOLICY, TSecurityPolicyPresenter, TfrSecurityPolicyView);

  RegisterView(VIEW_SECURITYPOLICYRES, TSecurityPolicyResPresenter, TfrSecurityPolicyResView);

  RegisterView(VIEW_SECURITYPERMEFFECTIVE, TSecurityPermEffectivePresenter, TfrSecurityPermEffectiveView);

  RegisterActivity(VIEW_USERACCOUNTS, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_USERACCOUNTS_CAPTION, TUserAccountsPresenter, TfrUserAccountsView);

end;

end.
