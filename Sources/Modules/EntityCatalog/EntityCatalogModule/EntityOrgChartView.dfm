inherited frEntityOrgChartView: TfrEntityOrgChartView
  Left = 612
  Top = 323
  Caption = 'frEntityOrgChartView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object OrgChart: TdxDbOrgChart
      Left = 2
      Top = 42
      Width = 769
      Height = 479
      DataSource = OrgChartDataSource
      KeyFieldName = 'ID'
      ParentFieldName = 'PARENT_ID'
      TextFieldName = 'NAME'
      OrderFieldName = 'NAME'
      DefaultNodeWidth = 120
      DefaultNodeHeight = 80
      Options = [ocSelect, ocFocus, ocButtons, ocDblClick, ocShowDrag]
      EditMode = [emCenter, emVCenter, emWrap]
      BorderStyle = bsNone
      Zoom = True
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
  object OrgChartDataSource: TDataSource
    Left = 76
    Top = 118
  end
end
