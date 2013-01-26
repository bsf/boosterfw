unit SecurityPolicyResView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu, Menus, cxFilter,
  cxData, cxDataStorage, cxCheckBox, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxClasses, cxGridCustomView, cxGrid, StdCtrls,
  cxButtons, cxSplitter, cxInplaceContainer, cxTextEdit, SecurityPolicyResPresenter,
  SecurityIntf, cxEditRepositoryItems, UIClasses;

type
  TfrSecurityPolicyResView = class(TfrCustomView, ISecurityPolicyResView)
    trRes: TcxTreeList;
    cxSplitter1: TcxSplitter;
    cxGroupBox2: TcxGroupBox;
    btUsersShowAll: TcxButton;
    btUsersShowUsers: TcxButton;
    btUsersShowRoles: TcxButton;
    grUsers: TcxGrid;
    grUsersView: TcxGridTableView;
    grUsersUserID: TcxGridColumn;
    grUsersUserName: TcxGridColumn;
    grUsersViewIsRole: TcxGridColumn;
    grUsersLevel1: TcxGridLevel;
    grResID: TcxTreeListColumn;
    grResNAME: TcxTreeListColumn;
    grResDESCRIPTION: TcxTreeListColumn;
    grResPARENTID: TcxTreeListColumn;
    cxEditRepository1: TcxEditRepository;
    PermColumnProp: TcxEditRepositoryCheckBoxItem;
    procedure btUsersShowAllClick(Sender: TObject);
    procedure trResSelectionChanged(Sender: TObject);
    procedure grUsersViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure trResExpanding(Sender: TcxCustomTreeList; ANode: TcxTreeListNode;
      var Allow: Boolean);
  private
    FLastPermIndex: integer;
    FPrevResSelection: variant;
  protected
    procedure AddTopRes(AID: variant; const AName, ADescription: string;
      AHasChildren: boolean);
    procedure AddChildRes(AID, APARENTID: variant; const AName, ADescription: string;
      AHasChildren: boolean);
    procedure ClearUserList;
    function GetResSelection: variant;
    procedure AddUser(AUserID: variant; const AUserName: string; AIsRole: boolean;
      APermStates: array of TPermissionState);
    procedure AddPermission(const AName: string);
    function UserSelection: ISelection;
  end;

var
  frSecurityPolicyResView: TfrSecurityPolicyResView;

implementation

{$R *.dfm}

{ TfrSecurityPolicyResView }

procedure TfrSecurityPolicyResView.AddPermission(const AName: string);
var
  prmColumn: TcxGridColumn;
begin
  Inc(FLastPermIndex);
  prmColumn := grUsersView.CreateColumn;
  prmColumn.Caption := AName;
  prmColumn.Tag := FLastPermIndex;
  prmColumn.RepositoryItem := PermColumnProp;
end;

procedure TfrSecurityPolicyResView.AddTopRes(AID: variant; const AName,
  ADescription: string; AHasChildren: boolean);
var
  node: TcxTreeListNode;
begin
  node := trRes.Add;
  node.HasChildren := AHasChildren;
  node.AssignValues([AID, AName, ADescription]);
end;

procedure TfrSecurityPolicyResView.AddUser(AUserID: variant;
  const AUserName: string; AIsRole: boolean;
  APermStates: array of TPermissionState);
var
  row: integer;
  I: integer;
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
  for I := 0 to High(APermStates) do
    grUsersView.DataController.Values[row, grUsersView.FindItemByTag(I + 1).Index] := Ord(APermStates[I]);


end;

procedure TfrSecurityPolicyResView.btUsersShowAllClick(Sender: TObject);
begin
  grUsersView.DataController.Filter.Root.Clear;

  if Sender = btUsersShowRoles then
    grUsersView.DataController.Filter.Root.AddItem(grUsersViewIsRole, foEqual, true, 'Да')
  else if Sender = btUsersShowUsers then
    grUsersView.DataController.Filter.Root.AddItem(grUsersViewIsRole, foEqual, false, 'Нет');

  grUsersView.DataController.Filter.Active := Sender <> btUsersShowAll;
end;

procedure TfrSecurityPolicyResView.ClearUserList;
begin
  grUsersView.DataController.RecordCount := 0;
end;

function TfrSecurityPolicyResView.GetResSelection: variant;
begin
  if trRes.SelectionCount > 0 then
    Result := trRes.Selections[0].Values[0]
  else
    Result := Unassigned;
end;

procedure TfrSecurityPolicyResView.trResExpanding(Sender: TcxCustomTreeList;
  ANode: TcxTreeListNode; var Allow: Boolean);
begin
  if ANode.Count = 0 then
  begin
    WorkItem.Commands[COMMAND_CHILD_FILL].Data['NODE_ID'] := ANode.Values[0];
    WorkItem.Commands[COMMAND_CHILD_FILL].Execute;
  end;
end;

procedure TfrSecurityPolicyResView.trResSelectionChanged(Sender: TObject);
begin
  if FPrevResSelection <> GetResSelection then
  begin
    FPrevResSelection := GetResSelection;
    WorkItem.Commands[COMMAND_USERLIST_FILL].Execute;
  end;
end;

procedure TfrSecurityPolicyResView.grUsersViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
var
  RecIdx: integer;
  pStateVal: integer;
  nameCommand: string;
begin

  if AItem.Tag = 0 then Exit;

  RecIdx := grUsersView.DataController.FocusedRecordIndex;
  pStateVal := grUsersView.DataController.Values[RecIdx,
    AItem.Index];

  case TPermissionState(pStateVal) of
    psAllow: nameCommand := COMMAND_SET_PERM_ALLOW;
    psDeny: nameCommand := COMMAND_SET_PERM_DENY;
  else
    nameCommand := COMMAND_SET_PERM_UNDEFINED;
  end;

  WorkItem.Commands[nameCommand].Data['PERM_INDEX'] := AItem.Tag - 1;
  WorkItem.Commands[nameCommand].Execute;
end;

function TfrSecurityPolicyResView.UserSelection: ISelection;
begin
  Result := GetChildInterface(grUsersView.Name) as ISelection;
end;

procedure TfrSecurityPolicyResView.AddChildRes(AID, APARENTID: variant;
  const AName, ADescription: string; AHasChildren: boolean);
var
  parentNode, node: TcxTreeListNode;
begin
  parentNode := trRes.FindNodeByText(AParentID, grResID, nil, false, true, true, tlfmExact, nil, false);
  if Assigned(parentNode) then
  begin
    node := parentNode.AddChild;
    node.HasChildren := AHasChildren;
    node.AssignValues([AID, AName, ADescription, APARENTID]);
  end;
end;

end.
