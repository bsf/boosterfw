unit EntityOrgChartPresenter;

interface
uses CustomPresenter, EntityServiceIntf, CoreClasses,
  UIClasses, db, sysutils, UIStr;

const
  ENT_VIEW_ORGCHART = 'OrgChart';

type
  IEntityOrgChartView = interface(ICustomView)
  ['{A646F00E-AB1E-4BF6-9F05-EA609209B2E5}']
    procedure LinkData(AData: TDataSet);
    procedure Rotate;
    procedure Zoom;
  end;

  TEntityOrgChartPresenter = class(TCustomPresenter)
  private
    procedure CmdReload(Sender: TObject);
    procedure CmdRotate(Sender: TObject);
    procedure CmdZoom(Sender: TObject);
    procedure CmdOpenNode(Sender: TObject);
    function View: IEntityOrgChartView;
    function GetEVChart: IEntityView;
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;
  end;

implementation

{ TEntityOrgChartPresenter }

procedure TEntityOrgChartPresenter.CmdOpenNode(Sender: TObject);
begin
  with WorkItem.Activities[GetViewURI] do
  begin
    Params['ROOT_ID'] := WorkItem.State['ITEM_ID'];
    Execute(WorkItem);
  end;
end;

procedure TEntityOrgChartPresenter.CmdReload(Sender: TObject);
begin
  GetEVChart.Load;
end;

procedure TEntityOrgChartPresenter.CmdRotate(Sender: TObject);
begin
  View.Rotate;
end;

procedure TEntityOrgChartPresenter.CmdZoom(Sender: TObject);
begin
  View.Zoom;
end;

function TEntityOrgChartPresenter.GetEVChart: IEntityView;
var
  evName: string;
begin
  evName := EntityViewName;
  if evName = '' then evName := ENT_VIEW_ORGCHART;

   Result := GetEView(EntityName, evName);
end;

function TEntityOrgChartPresenter.OnGetWorkItemState(
  const AName: string; var Done: boolean): Variant;
begin
  if SameText(AName, 'ITEM_ID') then
  begin
    Result := GetEVChart.DataSet['ID'];
    Done := true;
  end;
end;

procedure TEntityOrgChartPresenter.OnViewReady;
begin
  FreeOnViewClose := true;
  ViewTitle := ViewInfo.Title;

  View.CommandBar.
    AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

  View.CommandBar.
    AddCommand(COMMAND_RELOAD,
      GetLocaleString(@COMMAND_RELOAD_CAPTION), COMMAND_RELOAD_SHORTCUT);
  WorkItem.Commands[COMMAND_RELOAD].SetHandler(CmdReload);

  WorkItem.Commands[COMMAND_RELOAD].Status := csDisabled; //TODO - AV при обновлении!

  View.CommandBar.
    AddCommand('cmd.rotate', 'Развернуть');
  WorkItem.Commands['cmd.rotate'].SetHandler(CmdRotate);

  View.CommandBar.
    AddCommand('cmd.zoom', 'Маштабировать');
  WorkItem.Commands['cmd.zoom'].SetHandler(CmdZoom);

  View.CommandBar.
    AddCommand('cmd.opennode', 'Открыть узел');
  WorkItem.Commands['cmd.opennode'].SetHandler(CmdOpenNode);

  View.LinkData(GetEVChart.DataSet);

end;

function TEntityOrgChartPresenter.View: IEntityOrgChartView;
begin
  Result := GetView as IEntityOrgChartView;
end;

end.
