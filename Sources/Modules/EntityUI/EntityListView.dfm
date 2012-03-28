inherited frEntityListView: TfrEntityListView
  Left = 636
  Top = 519
  Caption = 'frEntityListView'
  ExplicitHeight = 543
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object pnInfo: TcxGroupBox
      Left = 2
      Top = 42
      Align = alTop
      PanelStyle.Active = True
      PanelStyle.CaptionIndent = 5
      PanelStyle.OfficeBackgroundKind = pobkStyleColor
      ParentBackground = False
      ParentColor = False
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Color = clInfoBk
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'MS Sans Serif'
      Style.Font.Style = []
      Style.LookAndFeel.Kind = lfOffice11
      Style.TransparentBorder = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 1
      Visible = False
      Height = 30
      Width = 761
    end
    object grList: TcxGrid
      Left = 2
      Top = 72
      Width = 761
      Height = 441
      Align = alClient
      TabOrder = 2
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      object grListView: TcxGridDBTableView
        FilterBox.Position = fpTop
        OnCellDblClick = grListViewCellDblClick
        DataController.DataSource = ListDataSource
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        Filtering.ColumnFilteredItemsList = True
        FilterRow.ApplyChanges = fracImmediately
        OptionsBehavior.IncSearch = True
        OptionsBehavior.PullFocusing = True
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsSelection.MultiSelect = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
      end
      object grListLevel1: TcxGridLevel
        Caption = 'Table'
        GridView = grListView
      end
    end
  end
  object ListDataSource: TDataSource
    Left = 44
    Top = 190
  end
end
