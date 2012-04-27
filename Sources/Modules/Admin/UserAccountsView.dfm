inherited frUserAccountsView: TfrUserAccountsView
  Left = 421
  Top = 178
  Caption = 'frUserAccountsView'
  ClientHeight = 572
  ClientWidth = 1155
  ExplicitWidth = 1161
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 1155
    ExplicitHeight = 572
    Height = 572
    Width = 1155
    inherited pnButtons: TcxGroupBox
      ExplicitWidth = 1151
      Width = 1151
    end
    object pcMain: TcxPageControl
      Left = 2
      Top = 42
      Width = 1151
      Height = 528
      Align = alClient
      TabOrder = 1
      Properties.ActivePage = tsUsers
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      ClientRectBottom = 528
      ClientRectRight = 1151
      ClientRectTop = 24
      object tsUsers: TcxTabSheet
        Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
        ImageIndex = 0
        ExplicitLeft = 4
        ExplicitWidth = 1143
        ExplicitHeight = 500
        object grUsers: TcxGrid
          Left = 0
          Top = 0
          Width = 485
          Height = 504
          Align = alLeft
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          ExplicitHeight = 500
          object grUsersView: TcxGridTableView
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            FilterRow.ApplyChanges = fracImmediately
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object grUsersViewUSERID: TcxGridColumn
              Caption = 'ID'
              Options.Editing = False
              Width = 180
            end
            object grUsersViewUSERNAME: TcxGridColumn
              Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
              Width = 303
            end
          end
          object grUsersLevel1: TcxGridLevel
            GridView = grUsersView
          end
        end
        object cxSplitter1: TcxSplitter
          Left = 485
          Top = 0
          Width = 8
          Height = 504
          Control = grUsers
          ExplicitHeight = 500
        end
        object grUserRoles: TcxGrid
          Left = 493
          Top = 0
          Width = 658
          Height = 504
          Align = alClient
          TabOrder = 2
          LookAndFeel.Kind = lfOffice11
          ExplicitWidth = 650
          ExplicitHeight = 500
          object grUserRolesView: TcxGridTableView
            FilterBox.Visible = fvNever
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object grUserRolesViewROLEID: TcxGridColumn
              Caption = #1056#1086#1083#1100
              Visible = False
              Options.Editing = False
            end
            object grUserRolesViewROLENAME: TcxGridColumn
              Caption = #1056#1086#1083#1080
              Options.Editing = False
              Width = 332
            end
            object grUserRolesViewSTATUS: TcxGridColumn
              Caption = #1042#1082#1083#1102#1095#1077#1085#1072
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = grUserRolesViewSTATUSPropertiesEditValueChanged
            end
          end
          object grUserRolesLevel1: TcxGridLevel
            GridView = grUserRolesView
          end
        end
      end
      object tsRoles: TcxTabSheet
        Caption = #1056#1086#1083#1080
        ImageIndex = 1
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object grRoles: TcxGrid
          Left = 0
          Top = 0
          Width = 485
          Height = 504
          Align = alLeft
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          object grRolesView: TcxGridTableView
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            FilterRow.ApplyChanges = fracImmediately
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object grRolesViewROLEID: TcxGridColumn
              Caption = 'ID'
              Visible = False
              Options.Editing = False
              Width = 180
            end
            object grRolesViewROLENAME: TcxGridColumn
              Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
              Width = 303
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = grRolesView
          end
        end
        object cxSplitter2: TcxSplitter
          Left = 485
          Top = 0
          Width = 8
          Height = 504
          Control = grRoles
        end
        object grRoleUsers: TcxGrid
          Left = 493
          Top = 0
          Width = 658
          Height = 504
          Align = alClient
          TabOrder = 2
          LookAndFeel.Kind = lfOffice11
          object grRoleUsersView: TcxGridTableView
            FilterBox.Visible = fvNever
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object grRoleUsersViewUSERID: TcxGridColumn
              Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
              Visible = False
              Options.Editing = False
            end
            object grRoleUsersViewUSERNAME: TcxGridColumn
              Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
              Options.Editing = False
              Width = 332
            end
            object grRoleUsersViewSTATUS: TcxGridColumn
              Caption = #1042#1082#1083#1102#1095#1077#1085
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = grRoleUsersViewSTATUSPropertiesEditValueChanged
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = grRoleUsersView
          end
        end
      end
    end
  end
end
