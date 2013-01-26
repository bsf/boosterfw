inherited frUserPreferencesView: TfrUserPreferencesView
  Caption = 'frUserPreferencesView'
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grAppPreference: TcxDBVerticalGrid
      Left = 0
      Top = 40
      Width = 670
      Height = 475
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
      TabOrder = 1
      OnDrawRowHeader = grAppPreferenceDrawRowHeader
      OnDrawValue = grAppPreferenceDrawValue
      DataController.DataSource = AppPreferencesDataSource
      ExplicitTop = 0
      ExplicitWidth = 753
      ExplicitHeight = 443
      Version = 1
    end
  end
  inherited ActionList: TActionList
    Left = 182
    Top = 94
  end
  object AppPreferencesDataSource: TDataSource
    Left = 62
    Top = 162
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 72
    Top = 96
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
