unit SecurityPoliciesView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  SecurityPoliciesPresenter, ComCtrls, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxSplitter, cxTL, cxTextEdit,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, SecurityIntf;

type
  TPolicyData = class(TComponent)
  protected
    ID: variant;
  end;

  TfrSecurityPoliciesView = class(TfrCustomContentView, ISecurityPoliciesView)
    cxSplitter1: TcxSplitter;
    grPermissionsLevel1: TcxGridLevel;
    grPermissions: TcxGrid;
    trPolicies: TcxTreeList;
    colName: TcxTreeListColumn;
    colID: TcxTreeListColumn;
    colParentID: TcxTreeListColumn;
    grPermissionsView: TcxGridTableView;
    grPermissionsViewNAME: TcxGridColumn;
    grPermissionsViewINHERITBY: TcxGridColumn;
    grPermissionsViewPERMID: TcxGridColumn;
    grPermissionsViewDESCRIPTION: TcxGridColumn;
    colState: TcxTreeListColumn;
    procedure trPoliciesSelectionChanged(Sender: TObject);
    procedure trPoliciesCustomDrawDataCell(Sender: TcxCustomTreeList;
      ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo;
      var ADone: Boolean);
  private
    FChangeSelectedPolicyHandler: TChangeSelectedPolicyHandler;
  protected
    procedure AddPolicyItem(const AName: string; AID, AParentID: variant; AState: TPolicyState);
    procedure SetPolicyState(AState: TPolicyState);
    function SelectedPolicyItem: Variant;
    procedure SetChangeSelectedPolicyHandler(AHandler: TChangeSelectedPolicyHandler);
    procedure AddPermission(APermID: variant; const APermName, ADescription, InheritBy: string);
    procedure ClearPermissions;
  end;


implementation

{$R *.dfm}

{ TfrSecurityPoliciesView }

procedure TfrSecurityPoliciesView.AddPermission(APermID: variant;
  const APermName, ADescription, InheritBy: string);
var
  row: integer;
begin
  row := grPermissionsView.DataController.RecordCount;

  grPermissionsView.DataController.RecordCount :=row + 1;
  grPermissionsView.DataController.Values[row, grPermissionsViewPERMID.Index] := APermID;
  grPermissionsView.DataController.Values[row, grPermissionsViewNAME.Index] := APermName;
  grPermissionsView.DataController.Values[row, grPermissionsViewDESCRIPTION.Index] := ADescription;
  grPermissionsView.DataController.Values[row, grPermissionsViewINHERITBY.Index] := InheritBy;  
end;

procedure TfrSecurityPoliciesView.AddPolicyItem(const AName: string;
  AID, AParentID: variant; AState: TPolicyState);
var
  node, parentNode: TcxTreeListNode;
begin
  parentNode := trPolicies.FindNodeByText(VarToStr(AParentID), colID, nil, false, true, true, tlfmExact, nil, false);
  node := trPolicies.AddChild(parentNode);
  node.AssignValues([AName, AID, AParentID, AState]);
end;


procedure TfrSecurityPoliciesView.ClearPermissions;
begin
  grPermissionsView.DataController.RecordCount := 0;
end;

function TfrSecurityPoliciesView.SelectedPolicyItem: Variant;
begin
  Result := Unassigned;
  if trPolicies.FocusedNode <> nil then
    Result := trPolicies.FocusedNode.Values[colID.ItemIndex];
end;

procedure TfrSecurityPoliciesView.SetChangeSelectedPolicyHandler(
  AHandler: TChangeSelectedPolicyHandler);
begin
  FChangeSelectedPolicyHandler := AHandler;
end;

procedure TfrSecurityPoliciesView.trPoliciesSelectionChanged(
  Sender: TObject);
begin
  if Assigned(FChangeSelectedPolicyHandler) then
    FChangeSelectedPolicyHandler;
end;

procedure TfrSecurityPoliciesView.trPoliciesCustomDrawDataCell(
  Sender: TcxCustomTreeList; ACanvas: TcxCanvas;
  AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
begin
  if AViewInfo.Node.Values[colState.ItemIndex] <> psActive then
    ACanvas.Font.Color := clGray;
end;

procedure TfrSecurityPoliciesView.SetPolicyState(AState: TPolicyState);
var
  node: TcxTreeListNode;
begin
  node := trPolicies.FocusedNode;
  if node <> nil then
    node.Values[colState.ItemIndex] := AState;
end;

end.
