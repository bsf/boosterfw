inherited frSettingsView: TfrSettingsView
  Caption = 'frSettingsView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object pcMain: TcxPageControl
      Left = 2
      Top = 42
      Width = 769
      Height = 479
      ActivePage = cxTabSheet1
      Align = alClient
      LookAndFeel.Kind = lfOffice11
      TabOrder = 1
      ClientRectBottom = 479
      ClientRectRight = 769
      ClientRectTop = 24
      object cxTabSheet1: TcxTabSheet
        Caption = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1077
        ImageIndex = 0
        object cxGroupBox1: TcxGroupBox
          Left = 0
          Top = 0
          Align = alTop
          PanelStyle.Active = True
          Style.BorderStyle = ebsNone
          Style.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.Kind = lfOffice11
          TabOrder = 0
          Height = 31
          Width = 769
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
          Left = 0
          Top = 31
          Width = 769
          Height = 424
          ActivePage = tsCommonAppSettings
          Align = alClient
          Focusable = False
          LookAndFeel.Kind = lfOffice11
          TabOrder = 1
          ClientRectBottom = 424
          ClientRectRight = 769
          ClientRectTop = 24
          object tsCommonAppSettings: TcxTabSheet
            Caption = 'Common'
            ImageIndex = 0
            object grCommonAppSettings: TcxDBVerticalGrid
              Left = 0
              Top = 0
              Width = 769
              Height = 400
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
              Version = 1
            end
          end
          object tsAliasAppSettings: TcxTabSheet
            Caption = 'Alias'
            ImageIndex = 1
            object cxDBVerticalGrid1: TcxDBVerticalGrid
              Left = 0
              Top = 0
              Width = 769
              Height = 400
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
              Width = 769
              Height = 400
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
      object cxTabSheet2: TcxTabSheet
        Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1086#1085#1085#1072#1103' '#1073#1072#1079#1072
        ImageIndex = 1
        object cxDBVerticalGrid3: TcxDBVerticalGrid
          Left = 0
          Top = 0
          Width = 769
          Height = 455
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
          DataController.DataSource = dsDBSettings
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
    Left = 32
    Top = 229
  end
  object dsAliasAppSettings: TDataSource
    Left = 32
    Top = 257
  end
  object dsHostAppSettings: TDataSource
    Left = 32
    Top = 285
  end
  object dsDBSettings: TDataSource
    Left = 60
    Top = 229
  end
end
