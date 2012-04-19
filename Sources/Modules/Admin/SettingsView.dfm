inherited frSettingsView: TfrSettingsView
  Caption = 'frSettingsView'
  ClientHeight = 429
  ExplicitHeight = 457
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    Height = 429
    object cxGroupBox1: TcxGroupBox
      Left = 2
      Top = 42
      Align = alTop
      PanelStyle.Active = True
      Style.BorderStyle = ebsNone
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 1
      ExplicitLeft = -6
      ExplicitTop = 66
      Height = 31
      Width = 761
      object chCommonAppSettings: TcxRadioButton
        Left = 12
        Top = 8
        Width = 113
        Height = 17
        Caption = #1054#1073#1097#1080#1077
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = chAppSettingsKindClick
        LookAndFeel.Kind = lfOffice11
        Transparent = True
      end
      object chAliasAppSettings: TcxRadioButton
        Tag = 1
        Left = 138
        Top = 8
        Width = 113
        Height = 17
        Caption = #1040#1083#1080#1072#1089
        TabOrder = 1
        OnClick = chAppSettingsKindClick
        Transparent = True
      end
      object chHostAppSettings: TcxRadioButton
        Tag = 2
        Left = 268
        Top = 8
        Width = 113
        Height = 17
        Caption = #1061#1086#1089#1090
        TabOrder = 2
        OnClick = chAppSettingsKindClick
        Transparent = True
      end
    end
    object pcAppSettings: TcxPageControl
      Left = 2
      Top = 73
      Width = 761
      Height = 354
      Align = alClient
      Focusable = False
      TabOrder = 2
      Properties.ActivePage = tsCommonAppSettings
      LookAndFeel.Kind = lfOffice11
      ExplicitLeft = 0
      ExplicitTop = 31
      ExplicitWidth = 753
      ExplicitHeight = 412
      ClientRectBottom = 350
      ClientRectLeft = 4
      ClientRectRight = 757
      ClientRectTop = 24
      object tsCommonAppSettings: TcxTabSheet
        Caption = 'Common'
        ImageIndex = 0
        ExplicitWidth = 745
        ExplicitHeight = 415
        object grCommonAppSettings: TcxDBVerticalGrid
          Left = 0
          Top = 0
          Width = 753
          Height = 326
          Align = alClient
          LayoutStyle = lsMultiRecordView
          OptionsView.ShowEditButtons = ecsbAlways
          OptionsView.CategoryExplorerStyle = True
          OptionsView.RowHeaderWidth = 300
          OptionsView.ValueWidth = 300
          OptionsBehavior.AlwaysShowEditor = False
          OptionsBehavior.GoToNextCellOnEnter = True
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          TabOrder = 0
          OnDrawValue = grCommonAppSettingsDrawValue
          DataController.DataSource = dsCommonAppSettings
          ExplicitWidth = 745
          ExplicitHeight = 415
          Version = 1
        end
      end
      object tsAliasAppSettings: TcxTabSheet
        Caption = 'Alias'
        ImageIndex = 1
        object cxDBVerticalGrid1: TcxDBVerticalGrid
          Left = 0
          Top = 0
          Width = 753
          Height = 326
          Align = alClient
          LayoutStyle = lsMultiRecordView
          OptionsView.ShowEditButtons = ecsbAlways
          OptionsView.CategoryExplorerStyle = True
          OptionsView.RowHeaderWidth = 300
          OptionsView.ValueWidth = 300
          OptionsBehavior.AlwaysShowEditor = False
          OptionsBehavior.GoToNextCellOnEnter = True
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          TabOrder = 0
          OnDrawValue = grCommonAppSettingsDrawValue
          DataController.DataSource = dsAliasAppSettings
          Version = 1
        end
      end
      object tsHostAppSettings: TcxTabSheet
        Caption = 'Host'
        ImageIndex = 2
        object cxDBVerticalGrid2: TcxDBVerticalGrid
          Left = 0
          Top = 0
          Width = 753
          Height = 326
          Align = alClient
          LayoutStyle = lsMultiRecordView
          OptionsView.ShowEditButtons = ecsbAlways
          OptionsView.CategoryExplorerStyle = True
          OptionsView.RowHeaderWidth = 300
          OptionsView.ValueWidth = 300
          OptionsBehavior.AlwaysShowEditor = False
          OptionsBehavior.GoToNextCellOnEnter = True
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          TabOrder = 0
          OnDrawValue = grCommonAppSettingsDrawValue
          DataController.DataSource = dsHostAppSettings
          Version = 1
        end
      end
    end
  end
  inherited ActionList: TActionList
    Left = 32
    Top = 194
  end
  object dsCommonAppSettings: TDataSource
    Left = 120
    Top = 173
  end
  object dsAliasAppSettings: TDataSource
    Left = 112
    Top = 241
  end
  object dsHostAppSettings: TDataSource
    Left = 112
    Top = 309
  end
end
