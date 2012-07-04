inherited frEntityItemExtView: TfrEntityItemExtView
  Caption = 'frEntityItemExtView'
  ExplicitHeight = 543
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grHeader: TcxDBVerticalGrid
      Left = 0
      Top = 40
      Width = 765
      Height = 201
      Align = alTop
      LayoutStyle = lsMultiRecordView
      LookAndFeel.Kind = lfOffice11
      OptionsView.CategoryExplorerStyle = True
      OptionsView.GridLineColor = clBtnFace
      OptionsView.RowHeaderWidth = 300
      OptionsView.ValueWidth = 300
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsData.Editing = False
      OptionsData.Appending = False
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      TabOrder = 1
      DataController.DataSource = HeadDataSource
      ExplicitTop = 42
      Version = 1
    end
    object cxSplitter1: TcxSplitter
      Left = 0
      Top = 241
      Width = 765
      Height = 8
      AlignSplitter = salTop
      Control = grHeader
    end
    object grDetails: TcxGrid
      Left = 0
      Top = 249
      Width = 765
      Height = 266
      Align = alClient
      TabOrder = 3
      LookAndFeel.Kind = lfOffice11
      object grDetailsView: TcxGridDBTableView
        FilterBox.Position = fpTop
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
      end
      object grDetailsLevel1: TcxGridLevel
        Caption = 'Table'
        GridView = grDetailsView
        Options.DetailTabsPosition = dtpTop
      end
    end
  end
  object HeadDataSource: TDataSource
    Left = 144
    Top = 120
  end
end
