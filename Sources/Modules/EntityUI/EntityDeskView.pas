unit EntityDeskView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  EntityDeskPresenter, cxStyles, DB, cxSplitter, cxInplaceContainer,
  cxVGrid, cxDBVGrid, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  UIClasses, cxPC;

type
  TfrEntityDeskView = class(TfrCustomContentView, IEntityDeskView)
    grParams: TcxDBVerticalGrid;
    cxSplitter1: TcxSplitter;
    ParamsDataSource: TDataSource;
    ListDataSource: TDataSource;
    tcStates: TcxTabControl;
    grList: TcxGrid;
    grListView: TcxGridDBTableView;
    grListLevel1: TcxGridLevel;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    procedure grListViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure grParamsEditValueChanged(Sender: TObject;
      ARowProperties: TcxCustomEditorRowProperties);
  protected
    function Selection: ISelection;
    function Tabs: ITabs;  
    procedure SetData(AParams, AList: TDataSet);  
  public
  end;


implementation

{$R *.dfm}

{ TfrEntityDeskView }

function TfrEntityDeskView.Selection: ISelection;
begin
  Result := GetChildInterface(grListView.Name) as ISelection;
end;

procedure TfrEntityDeskView.SetData(AParams, AList: TDataSet);
begin
  LinkDataSet(ParamsDataSource, AParams);
  LinkDataSet(ListDataSource, AList);
end;

function TfrEntityDeskView.Tabs: ITabs;
begin
  Result := GetChildInterface(tcStates.Name) as ITabs;
end;

procedure TfrEntityDeskView.grListViewCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[COMMAND_OPEN].Execute;
end;

procedure TfrEntityDeskView.grParamsEditValueChanged(Sender: TObject;
  ARowProperties: TcxCustomEditorRowProperties);
begin
  WorkItem.Commands[COMMAND_RELOAD].Execute;
end;

end.
