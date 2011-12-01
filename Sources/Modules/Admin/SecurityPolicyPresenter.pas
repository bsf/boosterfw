unit SecurityPolicyPresenter;

interface
uses CustomContentPresenter, UIClasses, coreClasses, ShellIntf, SecurityIntf,
  AdminConst, sysutils, classes, variants, UIStr;

const
  COMMAND_SET_PERM_UNDEFINED = '{4FF1A7B8-9CC1-42B8-9F47-60D6037A69F1}';
  COMMAND_SET_PERM_ALLOW = '{B8E352D3-3697-4E98-8F3A-B60AE00679D5}';
  COMMAND_SET_PERM_DENY = '{02ACF144-175E-4BA8-BB2E-1B5AF686B76C}';
  COMMAND_PERMEFFECTIVE = '{53B03BB9-FB54-48AD-AEBD-AE878D58F77D}';

type
  ISecurityPolicyView = interface(IContentView)
  ['{053D18E3-27C6-4FA2-B070-7DBEC803B28C}']
    procedure AddPermission(AID: variant; const AName, ADescription: string);
    procedure AddUser(AUserID: variant; const AUserName: string; AIsRole: boolean; APermState: TPermissionState);
    procedure ClearUserList;
    function PermissionSelection: ISelection;
    function UserSelection: ISelection;
  end;

  TSecurityPolicyPresenter = class(TCustomContentPresenter)
  private
    FPolicy: ISecurityPolicy;
    function View: ISecurityPolicyView;
    procedure FillUserList(APermID: variant);
    procedure FillPermissionList;
    procedure PermissionSelectionChangedHandler;
    procedure CmdSetPermState(Sender: TObject);
    procedure CmdPermEffective(Sender: TObject);
  protected
    procedure OnViewReady; override;
  end;

implementation

{ TSecurityPolicyPresenter }

procedure TSecurityPolicyPresenter.CmdPermEffective(Sender: TObject);
begin
//  if View.PermissionSelection.Count = 0 then Exit;

  with WorkItem.Activities[VIEW_SECURITYPERMEFFECTIVE] do
  begin
    Params[TSecurityPermEffectiveActivityParams.PolID] := FPolicy.ID;
    Params[TSecurityPermEffectiveActivityParams.PermID] := '';// View.PermissionSelection.First;
    Params[TSecurityPermEffectiveActivityParams.ResID] := '';
    Execute(WorkItem);
  end;
end;

procedure TSecurityPolicyPresenter.CmdSetPermState(Sender: TObject);
var
  intf: ICommand;
  pState: TPermissionState;
begin
  Sender.GetInterface(ICommand, intf);
  if intf.Name = COMMAND_SET_PERM_ALLOW then
    pState := psAllow
  else if intf.Name = COMMAND_SET_PERM_DENY then
      pState := psDeny
  else
    pState := psUndefined;

  intf := nil;

  FPolicy.Permissions.GetByID(View.PermissionSelection.First).SetState(
    View.UserSelection.First, Unassigned, pState);

end;


procedure TSecurityPolicyPresenter.FillPermissionList;
var
  I: integer;
begin
  for I := 0 to FPolicy.Permissions.Count - 1 do
    View.AddPermission(FPolicy.Permissions.Get(I).ID, FPolicy.Permissions.Get(I).Name,
      FPolicy.Permissions.Get(I).Description);
end;

procedure TSecurityPolicyPresenter.FillUserList(APermID: variant);
var
  I: integer;
  pState: TPermissionState;
  userAccount: IUserAccount;
begin
  App.UI.WaitBox.StartWait;
  try
    for I := 0 to App.Security.Accounts.Count - 1 do
    begin
      userAccount := App.Security.Accounts.Get(I);
      pState := FPolicy.Permissions.GetByID(APermID).GetState(userAccount.ID, Unassigned);
      View.AddUser(userAccount.ID, userAccount.Name, userAccount.IsRole, pState);
    end;
  finally
    App.UI.WaitBox.StopWait;
  end;
end;

procedure TSecurityPolicyPresenter.OnViewReady;
begin
  FreeOnViewClose := true;
  FPolicy := App.Security.FindPolicy(WorkItem.State['POLID']);
  ViewTitle := FPolicy.Name;

  View.CommandBar.AddCommand(COMMAND_CLOSE,
    GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.AddCommand(COMMAND_PERMEFFECTIVE, 'Действующие разрешения',
    '', CmdPermEffective);

  WorkItem.Commands[COMMAND_SET_PERM_UNDEFINED].SetHandler(CmdSetPermState);
  WorkItem.Commands[COMMAND_SET_PERM_ALLOW].SetHandler(CmdSetPermState);
  WorkItem.Commands[COMMAND_SET_PERM_DENY].SetHandler(CmdSetPermState);

  FillPermissionList;
  View.PermissionSelection.SetSelectionChangedHandler(PermissionSelectionChangedHandler);
  PermissionSelectionChangedHandler;
end;

procedure TSecurityPolicyPresenter.PermissionSelectionChangedHandler;
begin
  View.ClearUserList;

  if View.PermissionSelection.Count > 0 then
    FillUserList(View.PermissionSelection.First);
end;

function TSecurityPolicyPresenter.View: ISecurityPolicyView;
begin
  Result := GetView as ISecurityPolicyView;
end;

end.
