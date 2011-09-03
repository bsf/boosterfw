unit EntityOrgChartView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, Menus,
  cxStyles, cxScheduler, cxSchedulerStorage, cxSchedulerCustomControls,
  cxSchedulerCustomResourceView, cxSchedulerDayView,
  cxSchedulerDateNavigator, cxSchedulerHolidays, cxSchedulerTimeGridView,
  cxSchedulerUtils, cxSchedulerWeekView, cxSchedulerYearView,
  cxSchedulerGanttView, dxorgchr, dxdborgc, EntityOrgChartPresenter, DB;

type
  TfrEntityOrgChartView = class(TfrCustomContentView, IEntityOrgChartView)
    OrgChart: TdxDbOrgChart;
    OrgChartDataSource: TDataSource;
  private
  protected
    procedure LinkData(AData: TDataSet);
    procedure Rotate;
    procedure Zoom;    
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

{ TfrOrgChartView }

procedure TfrEntityOrgChartView.LinkData(AData: TDataSet);
begin
  OrgChart.WidthFieldName := 'Width';
  OrgChart.HeightFieldName := 'Height';
  OrgChart.ShapeFieldName := 'Shape';
  LinkDataSet(OrgChartDataSource, AData);
end;

procedure TfrEntityOrgChartView.Rotate;
begin
  OrgChart.Rotated := not OrgChart.Rotated; 
end;

procedure TfrEntityOrgChartView.Zoom;
begin
  OrgChart.Zoom := not OrgChart.Zoom;
end;

end.
