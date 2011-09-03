inherited frEntityCollectView: TfrEntityCollectView
  Left = 665
  Top = 386
  Caption = 'frEntityCollectView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object pnTop: TcxGroupBox
      Left = 2
      Top = 42
      Align = alClient
      PanelStyle.Active = True
      Style.BorderStyle = ebsNone
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 1
      Height = 185
      Width = 769
      object grList: TcxGrid
        Left = 303
        Top = 2
        Width = 464
        Height = 181
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        object grListView: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          FilterBox.Position = fpTop
          OnCellDblClick = grListViewCellDblClick
          DataController.DataSource = ListDataSource
          DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.PullFocusing = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
        end
        object grListLevel1: TcxGridLevel
          Caption = 'Table'
          GridView = grListView
        end
      end
      object cxSplitter2: TcxSplitter
        Left = 295
        Top = 2
        Width = 8
        Height = 181
        HotZoneClassName = 'TcxXPTaskBarStyle'
        Control = grInfo
      end
      object grInfo: TcxDBVerticalGrid
        Left = 2
        Top = 2
        Width = 293
        Height = 181
        Align = alLeft
        LookAndFeel.Kind = lfOffice11
        OptionsView.ShowEditButtons = ecsbAlways
        OptionsView.CategoryExplorerStyle = True
        OptionsView.GridLineColor = clBtnFace
        OptionsView.RowHeaderWidth = 148
        OptionsView.ValueWidth = 300
        OptionsBehavior.AlwaysShowEditor = True
        OptionsBehavior.GoToNextCellOnEnter = True
        OptionsData.Appending = False
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        Styles.Background = cxStyle1
        TabOrder = 2
        DataController.DataSource = InfoDataSource
        Version = 1
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 2
      Top = 227
      Width = 769
      Height = 8
      AlignSplitter = salBottom
      Control = grItems
    end
    object grItems: TcxGrid
      Left = 2
      Top = 235
      Width = 769
      Height = 286
      Align = alBottom
      TabOrder = 3
      LookAndFeel.Kind = lfOffice11
      object grItemsView: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        FilterBox.Position = fpTop
        OnCellDblClick = grItemsViewCellDblClick
        DataController.DataSource = ItemsDataSource
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.PullFocusing = True
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsSelection.MultiSelect = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
      end
      object grItemsLevel1: TcxGridLevel
        Caption = 'Table'
        GridView = grItemsView
      end
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor]
      Color = clInfoBk
    end
  end
  object InfoDataSource: TDataSource
    Left = 76
    Top = 118
  end
  object ListDataSource: TDataSource
    Left = 108
    Top = 116
  end
  object ItemsDataSource: TDataSource
    Left = 140
    Top = 114
  end
end
