unit SecurityPoliciesPresenter;

interface
uses coreClasses, CustomContentPresenter, UIClasses, cxCustomData, ShellIntf,
  sysutils, Contnrs, classes, db, CommonUtils, dxmdaset, SecurityIntf, variants,
  AdminConst;

const
  VIEW_SECURITYPOLICIES = 'views.security.policies';


  COMMAND_POLICY_ACTIVATE = '{4BBF82A6-7A65-4C39-A22B-3F18F2D16DD2}';
  COMMAND_POLICY_DEACTIVATE = '{BD133B3F-1E90-4230-9EDE-3BEDFBC2A1D4}';
  COMMAND_POLICY_RESET = '{3674CE61-E18F-49C1-A1B5-E28149A521D3}';

type
  TChangeSelectedPolicyHandler = procedure of object;

  ISecurityPoliciesView = interface(IContentView)
  ['{466F2289-FBD1-46B9-84F0-BDC6A7EE7C1D}']
    procedure AddPolicyItem(const AName: string; AID, AParentID: variant; AState: TPolicyState);
    procedure SetPolicyState(AState: TPolicyState);
    function SelectedPolicyItem: Variant;
    procedure SetChangeSelectedPolicyHandler(AHandler: TChangeSelectedPolicyHandler);
    procedure AddPermission(APermID: variant; const APermName, ADescription, InheritBy: string);
    procedure ClearPermissions;
  end;

  TSecurityPoliciesPresenter = class(TCustomContentPresenter)
  private
    procedure CmdOpen(Sender: TObject);
    procedure FillPoliciesList(APolicies: ISecurityPolicies);
    function View: ISecurityPoliciesView;
    procedure ChangeSelectedPolicyHandler;
    procedure CmdPolicyActivate(Sender: TObject);
    procedure CmdPolicyDeactivate(Sender: TObject);
    procedure CmdPolicyReset(Sender: TObject);
  protected
    procedure OnViewReady; override;
    procedure OnViewClose; override;
  end;

implementation

{ TSecurityPoliciesPresenter }

procedure TSecurityPoliciesPresenter.ChangeSelectedPolicyHandler;
var
  polID: variant;
  policy: ISecurityPolicy;
  I: integer;
begin
  View.ClearPermissions;

  polID := View.SelectedPolicyItem;
  if VarIsEmpty(polID) then Exit;

  policy := App.Security.FindPolicy(polID);
  for I := 0 to policy.Permissions.Count - 1 do
    View.AddPermission(policy.Permissions.Get(I).ID,
      policy.Permissions.Get(I).Name, policy.Permissions.Get(I).Description,
      policy.Permissions.Get(I).InheritBy);
end;

procedure TSecurityPoliciesPresenter.CmdOpen(Sender: TObject);
var
  activity: IActivity;
  polID: variant;
  policy: ISecurityPolicy;
begin
  polID := View.SelectedPolicyItem;
  if VarIsEmpty(polID) then exit;

  policy := App.Security.FindPolicy(polID);

  if policy.ResProviderID = '' then
    activity := WorkItem.Activities[VIEW_SECURITYPOLICY]
  else
    activity := WorkItem.Activities[VIEW_SECURITYPOLICYRES];

  activity.Params[TSecurityPolicyActivityParams.PolID] := polID;
  activity.Execute(WorkItem);
end;

procedure TSecurityPoliciesPresenter.CmdPolicyActivate(Sender: TObject);
var
  polID: variant;
  policy: ISecurityPolicy;
begin
  polID := View.SelectedPolicyItem;
  if VarIsEmpty(polID) then exit;

  policy := App.Security.FindPolicy(polID);
  policy.SetState(psActive);
  View.SetPolicyState(policy.GetState);
end;

procedure TSecurityPoliciesPresenter.CmdPolicyDeactivate(Sender: TObject);
var
  polID: variant;
  policy: ISecurityPolicy;
begin
  polID := View.SelectedPolicyItem;
  if VarIsEmpty(polID) then exit;

  policy := App.Security.FindPolicy(polID);
  policy.SetState(psInactive);
  View.SetPolicyState(policy.GetState);
end;

procedure TSecurityPoliciesPresenter.CmdPolicyReset(Sender: TObject);
var
  polID: variant;
  policy: ISecurityPolicy;
begin
  polID := View.SelectedPolicyItem;
  if VarIsEmpty(polID) then exit;

  policy := App.Security.FindPolicy(polID);
  if App.UI.MessageBox.
      ConfirmYesNo(
        format('Удалить все установленные разрешения для политики%s- %s ?', [#10#13, policy.Name])) then
  begin
    policy.Reset;
  end;
end;

procedure TSecurityPoliciesPresenter.FillPoliciesList(APolicies: ISecurityPolicies);
var
  I: integer;
  parentID: variant;
begin
  for I := 0 to APolicies.Count - 1 do
  begin
    if APolicies.Parent <> nil then
      parentID := APolicies.Parent.ID
    else
      parentID := Unassigned;
    View.AddPolicyItem(APolicies.Get(I).Name,
      APolicies.Get(I).ID, parentID, APolicies.Get(I).GetState);
    FillPoliciesList(APolicies.Get(I).Policies);
  end
end;

procedure TSecurityPoliciesPresenter.OnViewClose;
begin
  inherited;

end;

procedure TSecurityPoliciesPresenter.OnViewReady;
begin
  ViewTitle := VIEW_SECURITYPOLICIES_TITLE;

  View.CommandBar.AddCommand(COMMAND_CLOSE, GetLocaleString(@COMMAND_CLOSE_CAPTION),
    COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.AddCommand(COMMAND_OPEN, GetLocaleString(@COMMAND_OPEN_CAPTION),
    COMMAND_OPEN_SHORTCUT, CmdOpen);

  View.CommandBar.AddCommand(COMMAND_POLICY_ACTIVATE, 'Включить политику',
    '', CmdPolicyActivate);

  View.CommandBar.AddCommand(COMMAND_POLICY_DEACTIVATE, 'Отключить политику',
    '', CmdPolicyDeactivate);

  View.CommandBar.AddCommand(COMMAND_POLICY_RESET, 'Сбросить политику',
    '', CmdPolicyReset);

  FillPoliciesList(App.Security.Policies);
  View.SetChangeSelectedPolicyHandler(ChangeSelectedPolicyHandler);
  ChangeSelectedPolicyHandler;
end;

function TSecurityPoliciesPresenter.View: ISecurityPoliciesView;
begin
  Result := GetView as ISecurityPoliciesView;
end;

end.
