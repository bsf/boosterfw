inherited frEntityNewView: TfrEntityNewView
  Left = 640
  Top = 441
  Caption = 'frEntityNewView'
  ExplicitHeight = 543
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    object grMain: TcxDBVerticalGrid [0]
      Left = 0
      Top = 40
      Width = 765
      Height = 475
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
      OptionsData.CancelOnExit = False
      OptionsData.Appending = False
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      TabOrder = 0
      OnKeyDown = grMainKeyDown
      DataController.DataSource = ItemDataSource
      Version = 1
    end
    inherited pnButtons: TcxGroupBox
      TabOrder = 1
    end
  end
  object ItemDataSource: TDataSource
    Left = 146
    Top = 118
  end
end
