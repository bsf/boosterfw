unit SecurityPolicyView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  SecurityPolicyPresenter, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxSplitter, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxClasses, cxGridCustomView, cxGrid, cxCheckBox,
  CommonViewIntf, SecurityIntf, cxDropDownEdit, Menus, StdCtrls, cxButtons;

type
  TfrSecurityPolicyView = class(TfrCustomContentView, ISecurityPolicyView)
    grPermissions: TcxGrid;
    grPermissionsView: TcxGridTableView;
    grPermissionsViewNAME: TcxGridColumn;
    grPermissionsViewNAME2: TcxGridColumn;
    grPermissionsLevel1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    grPermissionsViewID: TcxGridColumn;
    grPermissionsViewDESCRIPTION: TcxGridColumn;
    cxGroupBox2: TcxGroupBox;
    grUsers: TcxGrid;
    grUsersView: TcxGridTableView;
    grUsersUserID: TcxGridColumn;
    grUsersUserName: TcxGridColumn;
    grUsersViewIsRole: TcxGridColumn;
    grUsersPermissionState: TcxGridColumn;
    grUsersLevel1: TcxGridLevel;
    btUsersShowAll: TcxButton;
    btUsersShowUsers: TcxButton;
    btUsersShowRoles: TcxButton;
    procedure grUsersPermissionStatePropertiesEditValueChanged(
      Sender: TObject);
    procedure btUsersShowAllClick(Sender: TObject);
  private
  protected
    procedure AddPermission(AID: variant; const AName, ADescription: string);
    procedure AddUser(AUserID: variant; const AUserName: string; AIsRole: boolean; APermState: TPermissionState);
    procedure ClearUserList;
    function PermissionSelection: ISelection;
    function UserSelection: ISelection;
    procedure OnInitialize; override;
  end;

implementation

{$R *.dfm}

{ TfrSecurityPolicyView }

procedure TfrSecurityPolicyView.AddPermission(AID: variant;
  const AName, ADescription: string);
var
  row: integer;
begin
  row := grPermissionsView.DataController.RecordCount;

  grPermissionsView.DataController.RecordCount :=row + 1;
  grPermissionsView.DataController.Values[row, grPermissionsViewID.Index] := AID;
  grPermissionsView.DataController.Values[row, grPermissionsViewNAME.Index] := AName;
  grPermissionsView.DataController.Values[row, grPermissionsViewDESCRIPTION.Index] := ADescription;
end;

procedure TfrSecurityPolicyView.AddUser(AUserID: variant;
  const AUserName: string; AIsRole: boolean; APermState: TPermissionState);
var
  row: integer;
  uName: string;
begin
  row := grUsersView.DataController.RecordCount;

  grUsersView.DataController.RecordCount :=row + 1;
  grUsersView.DataController.Values[row, grUsersUserID.Index] := AUserID;
  if not AIsRole and (AUserID <> AUserName) then
    uName := AUserName + '   [' + AUserID + ']'
  else
    uName := AUserName;
  grUsersView.DataController.Values[row, grUsersUserName.Index] := uName;

  grUsersView.DataController.Values[row, grUsersViewIsRole.Index] := AIsRole;
  grUsersView.DataController.Values[row, grUsersPermissionState.Index] := Ord(APermState);
end;

procedure TfrSecurityPolicyView.ClearUserList;
begin
  grUsersView.DataController.RecordCount := 0;
end;

procedure TfrSecurityPolicyView.OnInitialize;
begin
  with (grUsersPermissionState.Properties as TcxCustomCheckBoxProperties) do
  begin
    ValueChecked := Ord(psAllow);
    ValueUnchecked := Ord(psDeny);
    ValueGrayed := Ord(psUndefined);
  end;
end;

function TfrSecurityPolicyView.PermissionSelection: ISelection;
begin
  Result := GetChildInterface(grPermissionsView.Name) as ISelection;
end;

function TfrSecurityPolicyView.UserSelection: ISelection;
begin
  Result := GetChildInterface(grUsersView.Name) as ISelection;
end;

procedure TfrSecurityPolicyView.grUsersPermissionStatePropertiesEditValueChanged(
  Sender: TObject);
var
  RecIdx: integer;
  pStateVal: integer;
begin
  RecIdx := grUsersView.DataController.FocusedRecordIndex;
  pStateVal := grUsersView.DataController.Values[RecIdx,
    grUsersPermissionState.Index];

  case TPermissionState(pStateVal) of
    psAllow: WorkItem.Commands[COMMAND_SET_PERM_ALLOW].Execute;
    psDeny: WorkItem.Commands[COMMAND_SET_PERM_DENY].Execute;
  else
    WorkItem.Commands[COMMAND_SET_PERM_UNDEFINED].Execute;
  end;


end;

procedure TfrSecurityPolicyView.btUsersShowAllClick(Sender: TObject);
begin
  grUsersView.DataController.Filter.Root.Clear;

  if Sender = btUsersShowRoles then
    grUsersView.DataController.Filter.Root.AddItem(grUsersViewIsRole, foEqual, true, 'Да')
  else if Sender = btUsersShowUsers then
    grUsersView.DataController.Filter.Root.AddItem(grUsersViewIsRole, foEqual, false, 'Нет');

  grUsersView.DataController.Filter.Active := Sender <> btUsersShowAll;
end;

end.
