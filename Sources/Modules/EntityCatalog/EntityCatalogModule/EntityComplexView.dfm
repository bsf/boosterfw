inherited frEntityComplexView: TfrEntityComplexView
  Left = 801
  Top = 309
  Caption = 'frEntityComplexView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grHeader: TcxDBVerticalGrid
      Left = 2
      Top = 42
      Width = 769
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
      Version = 1
    end
    object cxSplitter1: TcxSplitter
      Left = 2
      Top = 243
      Width = 769
      Height = 8
      AlignSplitter = salTop
      Control = grHeader
    end
    object grDetails: TcxGrid
      Left = 2
      Top = 251
      Width = 769
      Height = 270
      Align = alClient
      TabOrder = 3
      LookAndFeel.Kind = lfOffice11
      object grDetailsView: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
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
      end
    end
  end
  object HeadDataSource: TDataSource
    Left = 48
    Top = 144
  end
  object DetailsDataSource: TDataSource
    Left = 76
    Top = 144
  end
end
