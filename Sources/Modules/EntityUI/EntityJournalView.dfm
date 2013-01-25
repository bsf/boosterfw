inherited frEntityJournalView: TfrEntityJournalView
  Left = 629
  Caption = 'frEntityJournalView'
  ExplicitWidth = 320
  ExplicitHeight = 543
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object tcStates: TcxTabControl
      Left = 0
      Top = 40
      Width = 765
      Height = 475
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      ClientRectBottom = 475
      ClientRectRight = 765
      ClientRectTop = 0
      object pnInfo: TcxGroupBox
        Left = 0
        Top = 0
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
        TabOrder = 0
        Visible = False
        Height = 30
        Width = 765
      end
      object grList: TcxGrid
        Left = 0
        Top = 30
        Width = 765
        Height = 445
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        object grJrnView: TcxGridDBTableView
          FilterBox.Position = fpTop
          OnCellDblClick = grJrnViewCellDblClick
          DataController.DataSource = JrnDataSource
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          Filtering.ColumnFilteredItemsList = True
          OptionsBehavior.IncSearch = True
          OptionsBehavior.PullFocusing = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.MultiSelect = True
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
        end
        object grListLevel1: TcxGridLevel
          Caption = 'Table'
          GridView = grJrnView
        end
      end
    end
  end
  object JrnDataSource: TDataSource
    Left = 46
    Top = 146
  end
end
