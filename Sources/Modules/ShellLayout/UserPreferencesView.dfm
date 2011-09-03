inherited frUserPreferencesView: TfrUserPreferencesView
  Caption = 'frUserPreferencesView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object pcMain: TcxPageControl
      Left = 2
      Top = 42
      Width = 761
      Height = 471
      ActivePage = tsDBPreferences
      Align = alClient
      LookAndFeel.Kind = lfOffice11
      TabOrder = 1
      ClientRectBottom = 471
      ClientRectRight = 761
      ClientRectTop = 24
      object tsAppPreferences: TcxTabSheet
        Caption = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1077
        ImageIndex = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object grAppPreference: TcxDBVerticalGrid
          Left = 0
          Top = 0
          Width = 761
          Height = 447
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
          OnDrawRowHeader = grAppPreferenceDrawRowHeader
          OnDrawValue = grAppPreferenceDrawValue
          DataController.DataSource = AppPreferencesDataSource
          Version = 1
        end
      end
      object tsDBPreferences: TcxTabSheet
        Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1086#1085#1085#1072#1103' '#1073#1072#1079#1072
        ImageIndex = 1
        object grDBPreference: TcxDBVerticalGrid
          Left = 0
          Top = 0
          Width = 761
          Height = 447
          Align = alClient
          LayoutStyle = lsMultiRecordView
          OptionsView.ShowEditButtons = ecsbAlways
          OptionsView.CategoryExplorerStyle = True
          OptionsView.RowHeaderWidth = 300
          OptionsView.ValueWidth = 300
          TabOrder = 0
          OnDrawValue = grDBPreferenceDrawValue
          DataController.DataSource = DBPreferencesDataSource
          Version = 1
        end
      end
    end
  end
  object AppPreferencesDataSource: TDataSource
    Left = 46
    Top = 146
  end
  object DBPreferencesDataSource: TDataSource
    Left = 46
    Top = 176
  end
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object cxStyleValueChanged: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
  end
end
