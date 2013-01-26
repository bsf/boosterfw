inherited frEntityOrgChartView: TfrEntityOrgChartView
  Left = 612
  Top = 323
  Caption = 'frEntityOrgChartView'
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object OrgChart: TdxDbOrgChart
      Left = 0
      Top = 40
      Width = 670
      Height = 475
      Antialiasing = True
      DataSource = OrgChartDataSource
      KeyFieldName = 'ID'
      ParentFieldName = 'PARENT_ID'
      TextFieldName = 'NAME'
      OrderFieldName = 'NAME'
      OnLoadNode = OrgChartLoadNode
      LookAndFeel.Kind = lfOffice11
      DefaultNodeWidth = 120
      DefaultNodeHeight = 80
      Options = [ocSelect, ocFocus, ocButtons, ocDblClick, ocShowDrag, ocAnimate]
      EditMode = [emCenter, emVCenter, emWrap]
      BorderStyle = bsNone
      Align = alClient
      Color = clDefault
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 765
    end
  end
  object OrgChartDataSource: TDataSource
    Left = 188
    Top = 126
  end
end
