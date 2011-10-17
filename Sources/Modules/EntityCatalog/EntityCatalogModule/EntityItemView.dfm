inherited frEntityItemView: TfrEntityItemView
  Left = 393
  Top = 331
  Caption = 'frEntityItemView'
  ExplicitHeight = 543
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grMain: TcxDBVerticalGrid [0]
      Left = 2
      Top = 42
      Width = 761
      Height = 471
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
      ExplicitLeft = 3
      ExplicitTop = 48
      Version = 1
    end
    inherited pnButtons: TcxGroupBox
      TabOrder = 1
    end
  end
  object ItemDataSource: TDataSource
    Left = 106
    Top = 118
  end
end
