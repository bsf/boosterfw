inherited frEntityItemView: TfrEntityItemView
  Left = 393
  Top = 331
  Caption = 'frEntityItemView'
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
      OptionsView.CellAutoHeight = True
      OptionsView.ShowEditButtons = ecsbAlways
      OptionsView.CategoryExplorerStyle = True
      OptionsView.GridLineColor = clBtnFace
      OptionsView.RowHeaderWidth = 300
      OptionsView.ValueWidth = 300
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsBehavior.GoToNextCellOnTab = True
      OptionsBehavior.RowSizing = True
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
  inherited ActionList: TActionList
    Left = 46
  end
  object ItemDataSource: TDataSource
    Left = 154
    Top = 126
  end
end
