unit EntityOrgChartView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, Menus,
  cxStyles, cxScheduler, cxSchedulerStorage, cxSchedulerCustomControls,
  cxSchedulerCustomResourceView, cxSchedulerDayView,
  cxSchedulerDateNavigator, cxSchedulerHolidays, cxSchedulerTimeGridView,
  cxSchedulerUtils, cxSchedulerWeekView, cxSchedulerYearView,
  cxSchedulerGanttView, dxorgchr, dxdborgc, EntityOrgChartPresenter, DB;

type
  TfrEntityOrgChartView = class(TfrCustomView, IEntityOrgChartView)
    OrgChart: TdxDbOrgChart;
    OrgChartDataSource: TDataSource;
    procedure OrgChartLoadNode(Sender: TObject; Node: TdxOcNode);
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

procedure TfrEntityOrgChartView.OrgChartLoadNode(Sender: TObject;
  Node: TdxOcNode);

  function GetTextWidth(AFont: TFont; const AText: string): integer;
  var
    BM: TBitmap;
  begin
    BM := TBitmap.Create;
    try
      BM.Canvas.Font := AFont;
      Result := BM.Canvas.TextWidth(AText);
    finally
      BM.Free;
    end;
  end;

var textWidth: integer;
begin
  textWidth := GetTextWidth(OrgChart.Font, Node.Text);
  if textWidth > Node.Width then
    Node.Width := textWidth;
  if Node.Width < 120 then
    Node.Width := 120;
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
