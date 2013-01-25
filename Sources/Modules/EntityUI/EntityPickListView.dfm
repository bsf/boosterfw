inherited frEntityPickListView: TfrEntityPickListView
  Caption = 'frEntityPickListView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    inherited pnButtons: TcxGroupBox
      TabOrder = 1
    end
    object pnFilter: TcxGroupBox
      Left = 0
      Top = 0
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
        670
        29)
      Height = 29
      Width = 670
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
      Left = 0
      Top = 29
      Width = 670
      Height = 446
      Align = alClient
      TabOrder = 0
      TabStop = False
      Properties.ActivePage = tsTreeList
      Properties.HideTabs = True
      Properties.ImageBorder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      ClientRectBottom = 446
      ClientRectRight = 670
      ClientRectTop = 0
      object tsGridList: TcxTabSheet
        Caption = 'tsGridList'
        ImageIndex = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object grList: TcxGrid
          Left = 0
          Top = 0
          Width = 670
          Height = 446
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          object grListView: TcxGridDBTableView
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
        ExplicitWidth = 0
        ExplicitHeight = 0
        object grTreeList: TcxDBTreeList
          Left = 0
          Top = 0
          Width = 670
          Height = 446
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
    Top = 110
  end
  object ListDataSource: TDataSource
    Left = 144
    Top = 106
  end
end
