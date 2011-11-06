unit UserAccountsPresenter;

interface
uses coreClasses, CustomContentPresenter, UIClasses, ShellIntf,
  sysutils, Contnrs, classes, SecurityIntf;

const
  VIEW_USERACCOUNTS = 'views.security.useraccounts';
  VIEW_USERACCOUNTS_CAPTION = 'Диспетчер пользователей';

  COMMAND_USERROLE_ADD = '{C13E7F2B-3D91-4155-836C-61A001D6816A}';
  COMMAND_USERROLE_REMOVE = '{BCEF2BD2-F58E-4802-BB3C-824B2D510A6B}';
  COMMAND_ROLEUSER_ADD = '{33DDAC08-58C7-4F07-9BCC-600B9642A233}';
  COMMAND_ROLEUSER_REMOVE = '{514240EE-3E8D-4999-8D09-EC1BC9B61ED4}';

type
  IUserAccountsView = interface(IContentView)
  ['{0036C309-6D6D-43CF-8D38-7C72772A228A}']
    procedure AddUser(const AUserID, AUserName: string);
    procedure AddUserRoles(const ARoleID, ARoleName: string; AStatus: boolean);
    procedure ClearUserRoles;
    function UsersSelection: ISelection;
    function UserRolesSelection: ISelection;

    procedure AddRole(const ARoleID, ARoleName: string);
    procedure AddRoleUsers(const AUserID, AUserName: string; AStatus: boolean);
    procedure ClearRoleUsers;
    function RolesSelection: ISelection;
    function RoleUsersSelection: ISelection;
  end;

  TUserAccountsPresenter = class(TCustomContentPresenter)
  private
    FAccounts: IUserAccounts;
    function View: IUserAccountsView;

    procedure UserSelectionChangedHandler;
    procedure FillUserList;
    procedure FillUserRolesList(const AUserID: string);
    procedure CmdUserRolesChange(Sender: TObject);

    procedure RoleSelectionChangedHandler;
    procedure FillRoleList;
    procedure FillRoleUsersList(const ARoleID: string);
    procedure CmdRoleUsersChange(Sender: TObject);
  protected
    procedure OnViewReady; override;
  end;

implementation

{ TUserAccountsPresenter }

procedure TUserAccountsPresenter.CmdRoleUsersChange(Sender: TObject);
var
  intf: ICommand;
  userID, roleID: string;
begin

  roleID := View.RolesSelection.First;
  userID := View.RoleUsersSelection.First;

  Sender.GetInterface(ICommand, intf);
  if intf.Name = COMMAND_ROLEUSER_ADD then
    FAccounts.GetByID(userID).RoleAdd(roleID)
  else
    FAccounts.GetByID(userID).RoleRemove(roleID);

end;

procedure TUserAccountsPresenter.CmdUserRolesChange(Sender: TObject);
var
  intf: ICommand;
  userID, roleID: string;
begin

  userID := View.UsersSelection.First;
  roleID := View.UserRolesSelection.First;

  Sender.GetInterface(ICommand, intf);
  if intf.Name = COMMAND_USERROLE_ADD then
    FAccounts.GetByID(userID).RoleAdd(roleID)
  else
    FAccounts.GetByID(userID).RoleRemove(roleID);

end;

procedure TUserAccountsPresenter.FillRoleList;
var
  I: integer;
begin
  for I := 0 to FAccounts.Count - 1 do
    if FAccounts.Get(I).IsRole then
      View.AddRole(FAccounts.Get(I).ID, FAccounts.Get(I).Name);
end;

procedure TUserAccountsPresenter.FillRoleUsersList(const ARoleID: string);
var
  I: integer;
begin
  App.UI.WaitBox.StartWait;
  try
    for I := 0 to FAccounts.Count - 1 do
      if not FAccounts.Get(I).IsRole then
      begin
        View.AddRoleUsers(FAccounts.Get(I).ID, FAccounts.Get(I).Name,
          FAccounts.Get(I).RoleCheck(ARoleID));
      end;
  finally
    App.UI.WaitBox.StopWait;
  end;
end;

procedure TUserAccountsPresenter.FillUserList;
var
  I: integer;
begin
  for I := 0 to FAccounts.Count - 1 do
    if not FAccounts.Get(I).IsRole then
      View.AddUser(FAccounts.Get(I).ID, FAccounts.Get(I).Name);
end;

procedure TUserAccountsPresenter.FillUserRolesList(const AUserID: string);
var
  I: integer;
  uAccount: IUserAccount;
begin
  App.UI.WaitBox.StartWait;
  try
    uAccount := FAccounts.GetByID(AUserID);
    for I := 0 to FAccounts.Count - 1 do
      if FAccounts.Get(I).IsRole then
      begin
        View.AddUserRoles(FAccounts.Get(I).ID, FAccounts.Get(I).Name,
          uAccount.RoleCheck(FAccounts.Get(I).ID));
      end;
  finally
    App.UI.WaitBox.StopWait;
  end;
end;

procedure TUserAccountsPresenter.OnViewReady;
begin
  ViewTitle := VIEW_USERACCOUNTS_CAPTION;
  FreeOnViewClose := true;
  FAccounts := App.Security.Accounts;

  View.CommandBar.AddCommand(COMMAND_CLOSE, COMMAND_CLOSE_CAPTION,
    COMMAND_CLOSE_SHORTCUT, CmdClose);

  WorkItem.Commands[COMMAND_USERROLE_ADD].SetHandler(CmdUserRolesChange);
  WorkItem.Commands[COMMAND_USERROLE_REMOVE].SetHandler(CmdUserRolesChange);

  WorkItem.Commands[COMMAND_ROLEUSER_ADD].SetHandler(CmdRoleUsersChange);
  WorkItem.Commands[COMMAND_ROLEUSER_REMOVE].SetHandler(CmdRoleUsersChange);

  FillUserList;
  FillRoleList;

  View.UsersSelection.SetSelectionChangedHandler(UserSelectionChangedHandler);
  View.RolesSelection.SetSelectionChangedHandler(RoleSelectionChangedHandler);  
end;

procedure TUserAccountsPresenter.RoleSelectionChangedHandler;
begin
  View.ClearRoleUsers;
  if View.RolesSelection.Count <> 0 then
    FillRoleUsersList(View.RolesSelection.First);
end;

procedure TUserAccountsPresenter.UserSelectionChangedHandler;
begin
  View.ClearUserRoles;
  if View.UsersSelection.Count <> 0 then
    FillUserRolesList(View.UsersSelection.First);
end;

function TUserAccountsPresenter.View: IUserAccountsView;
begin
  Result := GetView as IUserAccountsView;
end;

end.
