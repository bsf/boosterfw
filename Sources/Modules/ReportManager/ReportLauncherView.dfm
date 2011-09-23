inherited frReportLauncherView: TfrReportLauncherView
  Left = 872
  Top = 385
  Caption = 'frReportLauncherView'
  ClientWidth = 888
  ExplicitWidth = 894
  ExplicitHeight = 551
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 888
    Width = 888
    inherited pnButtons: TcxGroupBox
      ExplicitWidth = 884
      Width = 884
    end
    object grParams: TcxDBVerticalGrid
      Left = 2
      Top = 42
      Width = 884
      Height = 471
      Align = alClient
      LayoutStyle = lsMultiRecordView
      LookAndFeel.Kind = lfOffice11
      OptionsView.ShowEditButtons = ecsbAlways
      OptionsView.CategoryExplorerStyle = True
      OptionsView.RowHeaderWidth = 330
      OptionsView.ValueWidth = 300
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsData.CancelOnExit = False
      OptionsData.Appending = False
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      TabOrder = 1
      OnEditValueChanged = grParamsEditValueChanged
      DataController.DataSource = ParamDataSource
      Version = 1
      object grParamsCategoryTop: TcxCategoryRow
        Options.Focusing = False
        Options.ShowExpandButton = False
        Options.TabStop = False
        Properties.Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1086#1090#1095#1077#1090#1072
        ID = 0
        ParentID = -1
        Index = 0
        Version = 1
      end
    end
  end
  inherited ActionList: TActionList
    Left = 52
    Top = 114
  end
  object ParamDataSource: TDataSource
    Left = 46
    Top = 261
  end
end
