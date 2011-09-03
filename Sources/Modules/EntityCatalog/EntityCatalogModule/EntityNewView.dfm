inherited frEntityNewView: TfrEntityNewView
  Left = 640
  Top = 441
  Caption = 'frEntityNewView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grMain: TcxDBVerticalGrid [0]
      Left = 2
      Top = 42
      Width = 769
      Height = 479
      Align = alClient
      LayoutStyle = lsMultiRecordView
      LookAndFeel.Kind = lfOffice11
      OptionsView.ShowEditButtons = ecsbAlways
      OptionsView.CategoryExplorerStyle = True
      OptionsView.GridLineColor = clBtnFace
      OptionsView.RowHeaderWidth = 300
      OptionsView.ValueWidth = 300
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsData.Appending = False
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      TabOrder = 0
      DataController.DataSource = ItemDataSource
      Version = 1
    end
    inherited pnButtons: TcxGroupBox
      TabOrder = 1
    end
  end
  object ItemDataSource: TDataSource
    Left = 74
    Top = 118
  end
end
