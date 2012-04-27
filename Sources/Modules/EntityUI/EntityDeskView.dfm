inherited frEntityDeskView: TfrEntityDeskView
  Left = 613
  Top = 171
  Caption = 'frEntityDeskView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grParams: TcxDBVerticalGrid
      Left = 2
      Top = 42
      Width = 761
      Height = 153
      Align = alTop
      LayoutStyle = lsMultiRecordView
      LookAndFeel.Kind = lfOffice11
      OptionsView.ShowEditButtons = ecsbAlways
      OptionsView.CategoryExplorerStyle = True
      OptionsView.GridLineColor = clBtnFace
      OptionsView.RowHeaderWidth = 300
      OptionsView.ValueWidth = 300
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsData.Appending = False
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      Styles.Background = cxStyle1
      TabOrder = 1
      OnEditValueChanged = grParamsEditValueChanged
      DataController.DataSource = ParamsDataSource
      Version = 1
    end
    object cxSplitter1: TcxSplitter
      Left = 2
      Top = 195
      Width = 761
      Height = 8
      HotZoneClassName = 'TcxXPTaskBarStyle'
      AlignSplitter = salTop
      Control = grParams
    end
    object tcStates: TcxTabControl
      Left = 2
      Top = 203
      Width = 761
      Height = 310
      Align = alClient
      TabOrder = 3
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      ClientRectBottom = 310
      ClientRectRight = 761
      ClientRectTop = 0
      object grList: TcxGrid
        Left = 0
        Top = 0
        Width = 761
        Height = 310
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        object grListView: TcxGridDBTableView
          FilterBox.Position = fpTop
          OnCellDblClick = grListViewCellDblClick
          DataController.DataSource = ListDataSource
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
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
  end
  object ParamsDataSource: TDataSource
    Left = 76
    Top = 118
  end
  object ListDataSource: TDataSource
    Left = 104
    Top = 118
  end
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor]
      Color = clInfoBk
    end
  end
end
