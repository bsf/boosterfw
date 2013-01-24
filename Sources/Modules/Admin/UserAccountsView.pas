unit UserAccountsView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  UserAccountsPresenter, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxCheckBox, cxSplitter, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView,
  cxGrid, cxPC, UIClasses, cxPCdxBarPopupMenu;

type
  TfrUserAccountsView = class(TfrCustomContentView, IUserAccountsView)
    pcMain: TcxPageControl;
    tsUsers: TcxTabSheet;
    tsRoles: TcxTabSheet;
    grUsers: TcxGrid;
    grUsersView: TcxGridTableView;
    grUsersViewUSERID: TcxGridColumn;
    grUsersViewUSERNAME: TcxGridColumn;
    grUsersLevel1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    grUserRoles: TcxGrid;
    grUserRolesView: TcxGridTableView;
    grUserRolesLevel1: TcxGridLevel;
    grUserRolesViewROLEID: TcxGridColumn;
    grUserRolesViewROLENAME: TcxGridColumn;
    grUserRolesViewSTATUS: TcxGridColumn;
    grRoles: TcxGrid;
    grRolesView: TcxGridTableView;
    grRolesViewROLEID: TcxGridColumn;
    grRolesViewROLENAME: TcxGridColumn;
    cxGridLevel1: TcxGridLevel;
    cxSplitter2: TcxSplitter;
    grRoleUsers: TcxGrid;
    grRoleUsersView: TcxGridTableView;
    grRoleUsersViewUSERID: TcxGridColumn;
    grRoleUsersViewUSERNAME: TcxGridColumn;
    grRoleUsersViewSTATUS: TcxGridColumn;
    cxGridLevel2: TcxGridLevel;
    procedure grUserRolesViewSTATUSPropertiesEditValueChanged(
      Sender: TObject);
    procedure grRoleUsersViewSTATUSPropertiesEditValueChanged(
      Sender: TObject);
  protected
    procedure AddUser(const AUserID, AUserName: string);
    procedure ClearUserRoles;
    procedure AddUserRoles(const ARoleID, ARoleName: string; AStatus: boolean);
    function UsersSelection: ISelection;
    function UserRolesSelection: ISelection;

    procedure AddRole(const ARoleID, ARoleName: string);
    procedure AddRoleUsers(const AUserID, AUserName: string; AStatus: boolean);
    procedure ClearRoleUsers;
    function RolesSelection: ISelection;
    function RoleUsersSelection: ISelection;

    procedure Initialize; override;
  end;

implementation

{$R *.dfm}

{ TfrUserAccountsView }

procedure TfrUserAccountsView.AddUser(const AUserID, AUserName: string);
var
  row: integer;
begin
  row := grUsersView.DataController.RecordCount;

  grUsersView.DataController.RecordCount :=row + 1;
  grUsersView.DataController.Values[row, grUsersViewUSERID.Index] := AUserID;
  grUsersView.DataController.Values[row, grUsersViewUSERNAME.Index] := AUserName;

end;

procedure TfrUserAccountsView.AddUserRoles(const ARoleID,
  ARoleName: string; AStatus: boolean);
var
  row: integer;
begin
  row := grUserRolesView.DataController.RecordCount;

  grUserRolesView.DataController.RecordCount :=row + 1;
  grUserRolesView.DataController.Values[row, grUserRolesViewROLEID.Index] := ARoleID;
  grUserRolesView.DataController.Values[row, grUserRolesViewROLENAME.Index] := ARoleName;
  grUserRolesView.DataController.Values[row, grUserRolesViewSTATUS.Index] := AStatus;

end;

procedure TfrUserAccountsView.ClearUserRoles;
begin
  grUserRolesView.DataController.RecordCount := 0;
end;

function TfrUserAccountsView.UserRolesSelection: ISelection;
begin
  Result := GetChildInterface(grUserRolesView.Name) as ISelection;
end;

function TfrUserAccountsView.UsersSelection: ISelection;
begin
  Result := GetChildInterface(grUsersView.Name) as ISelection;
end;

procedure TfrUserAccountsView.grUserRolesViewSTATUSPropertiesEditValueChanged(
  Sender: TObject);
var
  RecIdx: integer;
  status: boolean;
begin
  RecIdx := grUserRolesView.DataController.FocusedRecordIndex;
  status := grUserRolesView.DataController.Values[RecIdx,
    grUserRolesViewSTATUS.Index];

  if status then
    WorkItem.Commands[COMMAND_USERROLE_ADD].Execute
  else
    WorkItem.Commands[COMMAND_USERROLE_REMOVE].Execute;
end;

procedure TfrUserAccountsView.AddRole(const ARoleID, ARoleName: string);
var
  row: integer;
begin
  row := grRolesView.DataController.RecordCount;

  grRolesView.DataController.RecordCount :=row + 1;
  grRolesView.DataController.Values[row, grRolesViewROLEID.Index] := ARoleID;
  grRolesView.DataController.Values[row, grRolesViewROLENAME.Index] := ARoleName;
end;

procedure TfrUserAccountsView.AddRoleUsers(const AUserID,
  AUserName: string; AStatus: boolean);
var
  row: integer;
begin
  row := grRoleUsersView.DataController.RecordCount;

  grRoleUsersView.DataController.RecordCount :=row + 1;
  grRoleUsersView.DataController.Values[row, grRoleUsersViewUSERID.Index] := AUserID;
  grRoleUsersView.DataController.Values[row, grRoleUsersViewUSERNAME.Index] := AUserName;
  grRoleUsersView.DataController.Values[row, grRoleUsersViewSTATUS.Index] := AStatus;

end;

procedure TfrUserAccountsView.ClearRoleUsers;
begin
  grRoleUsersView.DataController.RecordCount := 0;
end;

function TfrUserAccountsView.RolesSelection: ISelection;
begin
  Result := GetChildInterface(grRolesView.Name) as ISelection;
end;

function TfrUserAccountsView.RoleUsersSelection: ISelection;
begin
  Result := GetChildInterface(grRoleUsersView.Name) as ISelection;
end;

procedure TfrUserAccountsView.grRoleUsersViewSTATUSPropertiesEditValueChanged(
  Sender: TObject);
var
  RecIdx: integer;
  status: boolean;
begin
  RecIdx := grRoleUsersView.DataController.FocusedRecordIndex;
  status := grRoleUsersView.DataController.Values[RecIdx,
    grRoleUsersViewSTATUS.Index];

  if status then
    WorkItem.Commands[COMMAND_ROLEUSER_ADD].Execute
  else
    WorkItem.Commands[COMMAND_ROLEUSER_REMOVE].Execute;

end;

procedure TfrUserAccountsView.Initialize;
begin
  pcMain.ActivePageIndex := 0;
end;

end.
