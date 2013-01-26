inherited frEntityTreeListView: TfrEntityTreeListView
  Caption = 'frEntityTreeListView'
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object pnInfo: TcxGroupBox
      Left = 0
      Top = 40
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
      ExplicitWidth = 765
      Height = 30
      Width = 670
    end
    object grList: TcxDBTreeList
      Left = 0
      Top = 70
      Width = 670
      Height = 445
      Align = alClient
      Bands = <
        item
        end>
      DataController.DataSource = ListDataSource
      OptionsBehavior.ExpandOnIncSearch = True
      OptionsBehavior.FocusCellOnCycle = True
      OptionsBehavior.IncSearch = True
      OptionsCustomizing.ColumnsQuickCustomization = True
      OptionsData.Editing = False
      OptionsData.Deleting = False
      OptionsView.GridLines = tlglBoth
      RootValue = -1
      TabOrder = 2
      OnDblClick = grListDblClick
      ExplicitWidth = 765
    end
  end
  object ListDataSource: TDataSource
    Left = 64
    Top = 184
  end
end
