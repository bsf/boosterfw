unit AdminController;

interface
uses classes, CoreClasses, ShellIntf, CustomUIController,
  //SettingsPresenter, SettingsView,
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
begin
  {RegisterActivity(VIEW_SETTINGS, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_SETTINGS_CAPTION, TSettingsPresenter, TfrSettingsView);}

  RegisterActivity(VIEW_SECURITYPOLICIES, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_SECURITYPOLICIES_TITLE, TSecurityPoliciesPresenter, TfrSecurityPoliciesView);

  RegisterView(VIEW_SECURITYPOLICY, TSecurityPolicyPresenter, TfrSecurityPolicyView);

  RegisterView(VIEW_SECURITYPOLICYRES, TSecurityPolicyResPresenter, TfrSecurityPolicyResView);

  RegisterView(VIEW_SECURITYPERMEFFECTIVE, TSecurityPermEffectivePresenter, TfrSecurityPermEffectiveView);

  RegisterActivity(VIEW_USERACCOUNTS, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_USERACCOUNTS_CAPTION, TUserAccountsPresenter, TfrUserAccountsView);

end;

end.
