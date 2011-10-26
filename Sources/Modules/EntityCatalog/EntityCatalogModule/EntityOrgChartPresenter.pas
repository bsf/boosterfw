unit EntityOrgChartPresenter;

interface
uses CustomContentPresenter, EntityCatalogIntf, EntityServiceIntf, CoreClasses,
  CommonViewIntf, db, sysutils;

const
  ENT_VIEW_ORGCHART = 'OrgChart';

type
  IEntityOrgChartView = interface(IContentView)
  ['{A646F00E-AB1E-4BF6-9F05-EA609209B2E5}']
    procedure LinkData(AData: TDataSet);
    procedure Rotate;
    procedure Zoom;
  end;

  TEntityOrgChartPresenter = class(TCustomContentPresenter)
  private
    procedure CmdReload(Sender: TObject);
    procedure CmdRotate(Sender: TObject);
    procedure CmdZoom(Sender: TObject);
    procedure CmdOpenNode(Sender: TObject);
    function View: IEntityOrgChartView;
    function GetEVChart: IEntityView;
  protected
    function OnGetWorkItemState(const AName: string): Variant; override;
    procedure OnViewReady; override;
  public
    class function ExecuteDataClass: TActionDataClass; override;
  end;

implementation

{ TEntityOrgChartPresenter }

procedure TEntityOrgChartPresenter.CmdOpenNode(Sender: TObject);
begin
  (WorkItem.Actions[GetViewURI].Data as TEntityOrgChartData).ROOT_ID := WorkItem.State['ITEM_ID'];
  WorkItem.Actions[GetViewURI].Execute(WorkItem);
end;

procedure TEntityOrgChartPresenter.CmdReload(Sender: TObject);
begin
  GetEVChart.Reload;
end;

procedure TEntityOrgChartPresenter.CmdRotate(Sender: TObject);
begin
  View.Rotate;
end;

procedure TEntityOrgChartPresenter.CmdZoom(Sender: TObject);
begin
  View.Zoom;
end;

class function TEntityOrgChartPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TEntityOrgChartData;
end;

function TEntityOrgChartPresenter.GetEVChart: IEntityView;
var
  evName: string;
begin
  evName := ViewInfo.EntityViewName;
  if evName = '' then evName := ENT_VIEW_ORGCHART;

   Result := GetEView(ViewInfo.EntityName, evName);
end;

function TEntityOrgChartPresenter.OnGetWorkItemState(
  const AName: string): Variant;
begin
  if SameText(AName, 'ITEM_ID') then
    Result := GetEVChart.Values['ID'];
end;

procedure TEntityOrgChartPresenter.OnViewReady;
begin
  FreeOnViewClose := true;
  ViewTitle := ViewInfo.Title;

  View.CommandBar.
    AddCommand(COMMAND_CLOSE, COMMAND_CLOSE_CAPTION, COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, COMMAND_RELOAD_CAPTION, COMMAND_RELOAD_SHORTCUT, CmdReload);

  WorkItem.Commands[COMMAND_RELOAD].Status := csDisabled; //TODO - AV при обновлении!
    
  View.CommandBar.
    AddCommand('cmd.rotate', 'Развернуть', '', CmdRotate);

  View.CommandBar.
    AddCommand('cmd.zoom', 'Маштабировать', '', CmdZoom);

  View.CommandBar.
    AddCommand('cmd.opennode', 'Открыть узел', '', CmdOpenNode);

  View.LinkData(GetEVChart.DataSet);

end;

function TEntityOrgChartPresenter.View: IEntityOrgChartView;
begin
  Result := GetView as IEntityOrgChartView;  
end;

end.
