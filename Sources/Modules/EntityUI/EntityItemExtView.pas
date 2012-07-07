unit EntityItemExtView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxSplitter, cxInplaceContainer, cxVGrid, cxDBVGrid,
  EntityItemExtPresenter;

type
  TfrEntityItemExtView = class(TfrCustomContentView, IEntityItemExtView)
    grHeader: TcxDBVerticalGrid;
    cxSplitter1: TcxSplitter;
    grDetails: TcxGrid;
    HeadDataSource: TDataSource;
    cxGridViewRepository: TcxGridViewRepository;
    cxGridViewRepositoryDBTableView: TcxGridDBTableView;
    procedure grDetailsActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
    procedure cxGridViewRepositoryDBTableViewCellDblClick(
      Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    FDetails: TStringList;
  protected
    procedure LinkHeadData(AData: TDataSet);
    procedure LinkDetailData(const AName, ACaption: string; AData: TDataSet);
    function GetActiveDetailData: string;
    procedure Initialize; override;
  public
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TfrEntityItemExtView }

procedure TfrEntityItemExtView.cxGridViewRepositoryDBTableViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  WorkItem.Commands[COMMAND_DETAIL_DBLCLICK].Execute;

end;

destructor TfrEntityItemExtView.Destroy;
begin
  FDetails.Free;
  inherited;
end;

function TfrEntityItemExtView.GetActiveDetailData: string;
begin
  if grDetails.ActiveLevel <> nil then
    Result := FDetails[grDetails.ActiveLevel.Index]
  else
    Result := '';
end;


procedure TfrEntityItemExtView.LinkDetailData(const AName, ACaption: string;
  AData: TDataSet);

  function MakeValidViewName(const AName: string): string;
  const
    Alpha = ['A'..'Z', 'a'..'z', '_'];
    AlphaNumeric = Alpha + ['0'..'9'];
  var
    I: Integer;
  begin
    Result := AName;
    for I := 1 to Length(Result) do
      if not CharInSet(Result[I], AlphaNumeric) then
        Result[I] := '_';
  end;
var
  dataSource: TDataSource;
  level: TcxGridLevel;
  view: TcxGridDBTableView;
begin
  dataSource := TDataSource.Create(Self);
  level := grDetails.Levels.Add;
  level.Caption := ACaption;
  view := TcxGridDBTableView(grDetails.CreateView(TcxGridDBTableView));
  view.Name := MakeValidViewName('grDetails' + AName);
  view.AssignSettings(cxGridViewRepositoryDBTableView); //grDetails.Views[0]);
  view.DataController.DataSource := dataSource;
  level.GridView := view;
  FDetails.Add(AName);
  LinkDataSet(dataSource, AData);
end;

procedure TfrEntityItemExtView.LinkHeadData(AData: TDataSet);
begin
  LinkDataSet(HeadDataSource, AData);
end;

procedure TfrEntityItemExtView.Initialize;
begin
  inherited;
  FDetails := TStringList.Create;
  WorkItem.Commands[COMMAND_DETAIL_DBLCLICK];
end;

procedure TfrEntityItemExtView.grDetailsActiveTabChanged(Sender: TcxCustomGrid;
  ALevel: TcxGridLevel);
begin
  WorkItem.Commands[COMMAND_CHANGE_ACTIVE_DETAIL_DATA].Execute;
end;

end.
