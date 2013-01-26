inherited frEntityComplexView: TfrEntityComplexView
  Left = 801
  Top = 309
  Caption = 'frEntityComplexView'
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grHeader: TcxDBVerticalGrid
      Left = 0
      Top = 40
      Width = 670
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
      ExplicitWidth = 765
      Version = 1
    end
    object cxSplitter1: TcxSplitter
      Left = 0
      Top = 241
      Width = 670
      Height = 8
      AlignSplitter = salTop
      Control = grHeader
      ExplicitWidth = 765
    end
    object grDetails: TcxGrid
      Left = 0
      Top = 249
      Width = 670
      Height = 266
      Align = alClient
      TabOrder = 3
      LookAndFeel.Kind = lfOffice11
      ExplicitWidth = 765
      object grDetailsView: TcxGridDBTableView
        FilterBox.Position = fpTop
        OnCellDblClick = grDetailsViewCellDblClick
        DataController.DataSource = DetailsDataSource
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
  inherited ActionList: TActionList
    Left = 54
    Top = 78
  end
  object HeadDataSource: TDataSource
    Left = 48
    Top = 136
  end
  object DetailsDataSource: TDataSource
    Left = 164
    Top = 152
  end
end
