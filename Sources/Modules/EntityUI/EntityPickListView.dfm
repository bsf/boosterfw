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
      Style.Edges = [bLeft, bTop, bRight, bBottom]
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
        Width = 611
      end
      object lbFilter: TcxLabel
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
    object pcListContainer: TcxPageControl
      Left = 2
      Top = 31
      Width = 666
      Height = 445
      ActivePage = tsTreeList
      Align = alClient
      HideTabs = True
      ImageBorder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      TabOrder = 0
      TabStop = False
      ClientRectBottom = 445
      ClientRectRight = 666
      ClientRectTop = 0
      object tsGridList: TcxTabSheet
        Caption = 'tsGridList'
        ImageIndex = 0
        object grList: TcxGrid
          Left = 0
          Top = 0
          Width = 666
          Height = 445
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
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
      object tsTreeList: TcxTabSheet
        Caption = 'tsTreeList'
        ImageIndex = 1
        object grTreeList: TcxDBTreeList
          Left = 0
          Top = 0
          Width = 666
          Height = 445
          Align = alClient
          Bands = <
            item
            end>
          LookAndFeel.Kind = lfOffice11
          OptionsBehavior.ExpandOnIncSearch = True
          OptionsBehavior.IncSearch = True
          OptionsCustomizing.BandVertSizing = False
          OptionsCustomizing.ColumnsQuickCustomization = True
          OptionsData.Editing = False
          OptionsData.Deleting = False
          OptionsView.ColumnAutoWidth = True
          RootValue = -1
          TabOrder = 0
          OnDblClick = grTreeListDblClick
        end
      end
    end
  end
  inherited ActionList: TActionList
    Left = 62
    Top = 110
  end
  object ListDataSource: TDataSource
    Left = 144
    Top = 106
  end
end
