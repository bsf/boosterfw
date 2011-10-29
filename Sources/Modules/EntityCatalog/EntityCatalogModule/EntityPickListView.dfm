inherited frEntityPickListView: TfrEntityPickListView
  Caption = 'frEntityPickListView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    inherited pnButtons: TcxGroupBox
      TabOrder = 1
    end
    object pnFilter: TcxGroupBox
      Left = 2
      Top = 2
      Align = alTop
      PanelStyle.Active = True
      ParentBackground = False
      ParentColor = False
      Style.BorderStyle = ebsNone
      Style.Color = clInfoBk
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 2
      DesignSize = (
        666
        29)
      Height = 29
      Width = 666
      object edFilter: TcxTextEdit
        Left = 50
        Top = 4
        Anchors = [akLeft, akTop, akRight, akBottom]
        Properties.OnChange = edFilterPropertiesChange
        TabOrder = 0
        ExplicitWidth = 619
        Width = 611
      end
      object cxLabel1: TcxLabel
        Left = 2
        Top = 2
        Align = alLeft
        Caption = #1060#1080#1083#1100#1090#1088
        FocusControl = edFilter
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        AnchorY = 15
      end
    end
    object grList: TcxGrid
      Left = 2
      Top = 31
      Width = 666
      Height = 445
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      ExplicitWidth = 674
      ExplicitHeight = 453
      object grListView: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        OnCellDblClick = grListViewCellDblClick
        DataController.DataSource = ListDataSource
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.IncSearch = True
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
      end
      object grListLevel1: TcxGridLevel
        GridView = grListView
      end
    end
  end
  object ListDataSource: TDataSource
    Left = 48
    Top = 146
  end
end
