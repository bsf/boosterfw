inherited frSecurityPermEffectiveView: TfrSecurityPermEffectiveView
  Left = 481
  Top = 220
  Caption = 'frSecurityPermEffectiveView'
  ClientWidth = 1006
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    Width = 1006
    inherited pnButtons: TcxGroupBox
      Width = 1002
    end
    object grList: TcxGrid
      Left = 2
      Top = 42
      Width = 1002
      Height = 479
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      object grListView: TcxGridTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
        Preview.Visible = True
        object grListUSER: TcxGridColumn
          Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
          Width = 236
        end
        object grListPERM: TcxGridColumn
          Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077
          Width = 185
        end
        object grListSTATE: TcxGridColumn
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ValueChecked = '1'
          Properties.ValueGrayed = '0'
          Properties.ValueUnchecked = '2'
        end
        object grListINHERITBY_PERM: TcxGridColumn
          Caption = #1059#1085#1072#1089#1083#1077#1076#1086#1074#1072#1085#1085#1086' '#1086#1090' '#1088#1072#1079#1088#1077#1096#1077#1085#1080#1103
          Width = 235
        end
        object grListINHERITBY_RES: TcxGridColumn
          Caption = #1059#1085#1072#1089#1083#1077#1076#1086#1074#1072#1085#1085#1086' '#1086#1090
          Width = 278
        end
      end
      object grListLevel1: TcxGridLevel
        GridView = grListView
      end
    end
  end
end
