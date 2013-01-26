unit SecurityPolicyResPresenter;

interface
uses CustomPresenter, UIClasses, coreClasses, ShellIntf, SecurityIntf,
  AdminConst, sysutils, classes, variants, UIStr;

const
  COMMAND_SET_PERM_UNDEFINED = '{4FF1A7B8-9CC1-42B8-9F47-60D6037A69F1}';
  COMMAND_SET_PERM_ALLOW = '{B8E352D3-3697-4E98-8F3A-B60AE00679D5}';
  COMMAND_SET_PERM_DENY = '{02ACF144-175E-4BA8-BB2E-1B5AF686B76C}';
  COMMAND_USERLIST_FILL = '{5BCF16D9-2A4C-4F9E-ABA4-72F02F205AD4}';
  COMMAND_USERLIST_CLEAR = '{059C1B8D-DECC-4F75-9A11-8BA474640CBC}';
  COMMAND_PERMEFFECTIVE = '{8C839B4C-E6D3-4713-98FB-6FF44AA044A8}';
  COMMAND_CHILD_FILL = '{D5989BB4-697E-4452-A149-67BDA52770CD}';

  COMMAND_ACCESS_TO_ALL = '{03242CAE-C61B-416F-8EA5-CE9BF44EEEDD}';

type


  ISecurityPolicyResView = interface(IContentView)
  ['{053D18E3-27C6-4FA2-B070-7DBEC803B28C}']
    procedure AddTopRes(AID: variant; const AName, ADescription: string; AHasChildren: boolean);
    procedure AddChildRes(AID, APARENTID: variant; const AName, ADescription: string;
      AHasChildren: boolean);
    procedure ClearUserList;
    function GetResSelection: variant;
    procedure AddPermission(const AName: string);

    procedure AddUser(AUserID: variant; const AUserName: string; AIsRole: boolean;
      APermStates: array of TPermissionState);
    function UserSelection: ISelection;
  end;

  TSecurityPolicyResPresenter = class(TCustomPresenter)
  private
    FPolicy: ISecurityPolicy;
    FResProvider: ISecurityResProvider;
    function View: ISecurityPolicyResView;

    procedure FillUserList(AResID: variant);
    procedure FillPermissionList;
    procedure FillTopResList;
    procedure CmdChildFill(Sender: TObject);
    procedure CmdSetPermState(Sender: TObject);
    procedure CmdUserListFill(Sender: TObject);
    procedure CmdUserListClear(Sender: TObject);
    procedure CmdPermEffective(Sender: TObject);
    procedure CmdAccessToAll(Sender: TObject);
  protected
    procedure OnViewReady; override;
  end;

implementation

{ TSecurityPolicyResPresenter }

procedure TSecurityPolicyResPresenter.CmdAccessToAll(Sender: TObject);
var
  activity: IActivity;
begin
  activity := WorkItem.Activities[VIEW_SECURITYPOLICY];
  activity.Params[TSecurityPolicyActivityParams.PolID] := FPolicy.ID;
  activity.Execute(WorkItem);
end;

procedure TSecurityPolicyResPresenter.CmdChildFill(Sender: TObject);
var
  parentID: variant;
  intf: ICommand;
  I: integer;
  list: IInterfaceList;
  res: ISecurityResNode;
  hasChildren: boolean;
begin
  Sender.GetInterface(ICommand, intf);

  parentID := intf.Data['NODE_ID'];

  list := FResProvider.GetChildRes(parentID);
  for I := 0 to list.Count - 1 do
  begin
    res := list[I] as ISecurityResNode;
    hasChildren := FResProvider.GetChildRes(res.ID).Count <> 0;
    View.AddChildRes(res.ID, parentID, res.name, res.description, hasChildren);
  end;
end;

procedure TSecurityPolicyResPresenter.CmdPermEffective(Sender: TObject);
begin
  if VarIsEmpty(View.GetResSelection) then Exit;

  with WorkItem.Activities[VIEW_SECURITYPERMEFFECTIVE] do
  begin
    Params[TSecurityPermEffectiveActivityParams.PolID] := FPolicy.ID;
    Params[TSecurityPermEffectiveActivityParams.PermID] := '';
    Params[TSecurityPermEffectiveActivityParams.ResID] := View.GetResSelection;
    Execute(WorkItem);
  end;
end;

procedure TSecurityPolicyResPresenter.CmdSetPermState(Sender: TObject);
var
  intf: ICommand;
  pState: TPermissionState;
  pIndex: integer;
begin
  Sender.GetInterface(ICommand, intf);
  if intf.Name = COMMAND_SET_PERM_ALLOW then
    pState := psAllow
  else if intf.Name = COMMAND_SET_PERM_DENY then
      pState := psDeny
  else
    pState := psUndefined;

  pIndex := intf.Data['PERM_INDEX'];
  intf := nil;

  FPolicy.Permissions.Get(pIndex).SetState(View.UserSelection.First,
    View.GetResSelection, pState);

end;

procedure TSecurityPolicyResPresenter.CmdUserListClear(Sender: TObject);
begin
  View.ClearUserList;
end;

procedure TSecurityPolicyResPresenter.CmdUserListFill(Sender: TObject);
begin
  View.ClearUserList;
  if not VarIsEmpty(View.GetResSelection) then
    FillUserList(View.GetResSelection);
end;

procedure TSecurityPolicyResPresenter.FillPermissionList;
var
  I: integer;
begin
  for I := 0 to FPolicy.Permissions.Count - 1 do
    View.AddPermission(FPolicy.Permissions.Get(I).Name);
end;

procedure TSecurityPolicyResPresenter.FillTopResList;
var
  I: integer;
  list: IInterfaceList;
  res: ISecurityResNode;
  hasChildren: boolean;
begin
  list := FResProvider.GetTopRes;
  for I := 0 to list.Count - 1 do
  begin
    res := list[I] as ISecurityResNode;
    hasChildren := FResProvider.GetChildRes(res.ID).Count <> 0;
    View.AddTopRes(res.ID, res.name, res.description, hasChildren);
  end;
end;

procedure TSecurityPolicyResPresenter.FillUserList(AResID: variant);
var
  I, Y: integer;
  pStates: array of TPermissionState;
  userAccount: IUserAccount;
begin
  App.UI.WaitBox.StartWait;
  try
    SetLength(pStates, FPolicy.Permissions.Count);
    for I := 0 to App.Security.Accounts.Count - 1 do
    begin
      userAccount := App.Security.Accounts.Get(I);
      for Y := 0 to FPolicy.Permissions.Count - 1 do
        pStates[Y] := FPolicy.Permissions.Get(Y).GetState(userAccount.ID, AResID);

      View.AddUser(userAccount.ID, userAccount.Name, userAccount.IsRole, pStates);
    end;
  finally
    App.UI.WaitBox.StopWait;
  end;
end;

procedure TSecurityPolicyResPresenter.OnViewReady;
begin
  FreeOnViewClose := true;
  FPolicy := App.Security.FindPolicy(WorkItem.State['POLID']);
  FResProvider := App.Security.GetResProvider(FPolicy.ResProviderID);

  ViewTitle := FPolicy.Name;

  View.CommandBar.AddCommand(COMMAND_CLOSE,
    GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

  View.CommandBar.AddCommand(COMMAND_PERMEFFECTIVE, 'Действующие разрешения');
  WorkItem.Commands[COMMAND_PERMEFFECTIVE].SetHandler(CmdPermEffective);

  View.CommandBar.AddCommand(COMMAND_ACCESS_TO_ALL, 'Доступ ко всем элементам');
  WorkItem.Commands[COMMAND_ACCESS_TO_ALL].SetHandler(CmdAccessToAll);

  WorkItem.Commands[COMMAND_SET_PERM_UNDEFINED].SetHandler(CmdSetPermState);
  WorkItem.Commands[COMMAND_SET_PERM_ALLOW].SetHandler(CmdSetPermState);
  WorkItem.Commands[COMMAND_SET_PERM_DENY].SetHandler(CmdSetPermState);
  WorkItem.Commands[COMMAND_USERLIST_FILL].SetHandler(CmdUserListFill);
  WorkItem.Commands[COMMAND_USERLIST_CLEAR].SetHandler(CmdUserListClear);
  WorkItem.Commands[COMMAND_CHILD_FILL].SetHandler(CmdChildFill);

  FillTopResList;
  FillPermissionList;
  CmdUserListFill(nil);
end;

function TSecurityPolicyResPresenter.View: ISecurityPolicyResView;
begin
  Result := GetView as ISecurityPolicyResView;
end;

end.
