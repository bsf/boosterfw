unit SecurityPermEffectiveView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxGridCustomTableView, cxGridTableView, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, SecurityPermEffectivePresenter, SecurityIntf,
  cxCheckBox;

type
  TfrSecurityPermEffectiveView = class(TfrCustomContentView, ISecurityPermEffectiveView)
    grList: TcxGrid;
    grListView: TcxGridTableView;
    grListLevel1: TcxGridLevel;
    grListUSER: TcxGridColumn;
    grListPERM: TcxGridColumn;
    grListSTATE: TcxGridColumn;
    grListINHERITBY_PERM: TcxGridColumn;
    grListINHERITBY_RES: TcxGridColumn;
  private
  protected
    procedure AddItem(const UserName, Perm, InheritByPerm, InheritByRes: string;
      State: TPermissionState);
  public
  end;


implementation

{$R *.dfm}

{ TfrSecurityPermEffectiveView }

procedure TfrSecurityPermEffectiveView.AddItem(const UserName, Perm,
  InheritByPerm, InheritByRes: string; State: TPermissionState);
var
  row: integer;
begin
  row := grListView.DataController.RecordCount;

  grListView.DataController.RecordCount :=row + 1;
  grListView.DataController.Values[row, grListUSER.Index] := UserName;
  grListView.DataController.Values[row, grListPERM.Index] := Perm;
  grListView.DataController.Values[row, grListINHERITBY_PERM.Index] := InheritByPerm;
  grListView.DataController.Values[row, grListINHERITBY_RES.Index] := InheritByRes;
  grListView.DataController.Values[row, grListSTATE.Index] := State;

end;

end.
