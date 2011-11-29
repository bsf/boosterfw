unit AdminController;

interface
uses classes, CoreClasses, ShellIntf, SecurityIntf, UIClasses, db,
  SecurityPoliciesPresenter, SecurityPoliciesView,
  SecurityPolicyPresenter, SecurityPolicyView,
  SecurityPolicyResPresenter, SecurityPolicyResView,
  SecurityPermEffectivePresenter, SecurityPermEffectiveView,
  UserAccountsPresenter, UserAccountsView, SecurityResProvider,
  SettingsPresenter, SettingsView,
  AdminConst;

type
  TAdminController = class(TWorkItemController)
  protected
    procedure Initialize; override;

    type
      TSecurityPolicyActivityHandler = class(TViewActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
      TSecurityPermEffectiveActivityHandler = class(TViewActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
  end;

implementation

{ TAdminController }

procedure TAdminController.Initialize;
  procedure RegisterSecurityResourceProviders;
  const
    ENT = 'SEC_PROV';
  var
    svc: ISecurityService;
    list: TDataSet;
  begin
    svc := WorkItem.Services[ISecurityService] as ISecurityService;

    svc.RegisterResProvider(TActivitySecurityResProvider.Create(Self, WorkItem));

    list := App.Entities[ENT].GetView('List', WorkItem).Load([]);
    while not list.Eof do
    begin
      svc.RegisterResProvider(
        TEntitySecurityResProvider.Create(Self, list['URI'], list['ENTITYNAME'], WorkItem));
      list.Next;
    end;

  end;
begin
// Settings
  with WorkItem.Activities[VIEW_SETTINGS] do
  begin
    Title := GetLocaleString(@VIEW_SETTINGS_CAPTION);
    Group := GetLocaleString(@MENU_GROUP_SERVICE);
    UsePermission := true;
    RegisterHandler(TViewActivityHandler.Create(TSettingsPresenter, TfrSettingsView));
  end;

// Security objects
  with WorkItem.Activities[VIEW_SECURITYPOLICIES] do
  begin
    Title := GetLocaleString(@VIEW_SECURITYPOLICIES_TITLE);
    Group := GetLocaleString(@MENU_GROUP_SERVICE);
    UsePermission := true;
    RegisterHandler(TViewActivityHandler.Create(TSecurityPoliciesPresenter, TfrSecurityPoliciesView));
  end;

  with WorkItem.Activities[VIEW_USERACCOUNTS] do
  begin
    Title := GetLocaleString(@VIEW_USERACCOUNTS_CAPTION);
    Group := GetLocaleString(@MENU_GROUP_SERVICE);
    UsePermission := true;
    RegisterHandler(TViewActivityHandler.Create(TUserAccountsPresenter, TfrUserAccountsView));
  end;

  WorkItem.Activities[VIEW_SECURITYPOLICY].RegisterHandler(
    TSecurityPolicyActivityHandler.Create(TSecurityPolicyPresenter, TfrSecurityPolicyView));

  WorkItem.Activities[VIEW_SECURITYPOLICYRES].RegisterHandler(
    TSecurityPolicyActivityHandler.Create(TSecurityPolicyResPresenter, TfrSecurityPolicyResView));

  WorkItem.Activities[VIEW_SECURITYPERMEFFECTIVE].RegisterHandler(
    TSecurityPermEffectiveActivityHandler.Create(TSecurityPermEffectivePresenter, TfrSecurityPermEffectiveView));

  RegisterSecurityResourceProviders;

end;

{ TAdminController.TSecurityPolicyActivityHandler }

procedure TAdminController.TSecurityPolicyActivityHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
begin
  Activity.Params[TViewActivityParams.PresenterID] :=
    Activity.Params[TSecurityPolicyActivityParams.PolID];
  inherited Execute(Sender, Activity);
end;

{ TAdminController.TSecurityPermEffectiveActivityHandler }

procedure TAdminController.TSecurityPermEffectiveActivityHandler.Execute(
  Sender: TWorkItem; Activity: IActivity);
begin
  Activity.Params[TViewActivityParams.PresenterID] :=
    Activity.Params[TSecurityPermEffectiveActivityParams.PolID] +
    Activity.Params[TSecurityPermEffectiveActivityParams.PermID] +
    Activity.Params[TSecurityPermEffectiveActivityParams.ResID];
  inherited;
end;

end.
