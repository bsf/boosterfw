unit EntityTreeListView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer,
  cxTLData, cxDBTL, DB, EntityTreeListPresenter, UIClasses;

type
  TfrEntityTreeListView = class(TfrCustomContentView, IEntityTreeListView)
    pnInfo: TcxGroupBox;
    grList: TcxDBTreeList;
    ListDataSource: TDataSource;
  private
    { Private declarations }
  protected
    procedure SetInfoText(const AText: string);
    function Selection: ISelection;
    procedure SetListDataSet(ADataSet: TDataSet);
  end;

implementation

{$R *.dfm}

{ TfrEntityTreeListView }

function TfrEntityTreeListView.Selection: ISelection;
begin
  Result := GetChildInterface(grList.Name) as ISelection;
end;

procedure TfrEntityTreeListView.SetInfoText(const AText: string);
begin
  pnInfo.Caption := AText;
  pnInfo.Visible := Trim(AText) <> '';
end;

procedure TfrEntityTreeListView.SetListDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(ListDataSource, ADataSet);
end;

end.
