inherited frEntityTreeListView: TfrEntityTreeListView
  Caption = 'frEntityTreeListView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object pnInfo: TcxGroupBox
      Left = 2
      Top = 42
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
      Height = 30
      Width = 761
    end
    object grList: TcxDBTreeList
      Left = 2
      Top = 72
      Width = 761
      Height = 441
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
    end
  end
  object ListDataSource: TDataSource
    Left = 64
    Top = 184
  end
end
