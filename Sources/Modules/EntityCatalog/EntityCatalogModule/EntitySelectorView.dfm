inherited frEntitySelectorView: TfrEntitySelectorView
  Caption = 'frEntitySelectorView'
  ClientHeight = 312
  ClientWidth = 537
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    Height = 312
    Width = 537
    inherited pnButtons: TcxGroupBox
      Top = 273
      Width = 533
    end
    object grMain: TcxDBVerticalGrid
      Left = 2
      Top = 2
      Width = 533
      Height = 271
      Align = alClient
      LayoutStyle = lsMultiRecordView
      LookAndFeel.Kind = lfOffice11
      OptionsView.ShowEditButtons = ecsbAlways
      OptionsView.CategoryExplorerStyle = True
      OptionsView.GridLineColor = clBtnFace
      OptionsView.RowHeaderWidth = 250
      OptionsView.ValueWidth = 250
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsData.Appending = False
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      TabOrder = 1
      DataController.DataSource = MainDataSource
      Version = 1
    end
  end
  object MainDataSource: TDataSource
    Left = 74
    Top = 118
  end
end
