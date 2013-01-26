inherited frSecurityPolicyView: TfrSecurityPolicyView
  Left = 614
  Top = 301
  Caption = 'frSecurityPolicyView'
  ClientHeight = 645
  ClientWidth = 977
  ExplicitWidth = 983
  ExplicitHeight = 673
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 977
    ExplicitHeight = 645
    Height = 645
    Width = 977
    inherited pnButtons: TcxGroupBox
      ExplicitWidth = 977
      Width = 977
    end
    object grPermissions: TcxGrid
      Left = 0
      Top = 40
      Width = 485
      Height = 605
      Align = alLeft
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      object grPermissionsView: TcxGridTableView
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
        Preview.Column = grPermissionsViewDESCRIPTION
        object grPermissionsViewID: TcxGridColumn
          Visible = False
          Options.Editing = False
          VisibleForCustomization = False
        end
        object grPermissionsViewNAME: TcxGridColumn
          Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077
          Width = 261
        end
        object grPermissionsViewNAME2: TcxGridColumn
          Caption = #1053#1072#1089#1083#1077#1076#1091#1077#1090' '#1086#1090' '
          Visible = False
          Width = 222
        end
        object grPermissionsViewDESCRIPTION: TcxGridColumn
        end
      end
      object grPermissionsLevel1: TcxGridLevel
        GridView = grPermissionsView
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 485
      Top = 40
      Width = 8
      Height = 605
      Control = grPermissions
    end
    object TcxGroupBox
      Left = 493
      Top = 40
      Align = alClient
      PanelStyle.Active = True
      Style.BorderStyle = ebsNone
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 3
      Height = 605
      Width = 484
      object cxGroupBox2: TcxGroupBox
        Left = 2
        Top = 2
        Align = alTop
        PanelStyle.Active = True
        Style.BorderStyle = ebsNone
        Style.LookAndFeel.Kind = lfOffice11
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        TabOrder = 0
        Height = 39
        Width = 480
        object btUsersShowAll: TcxButton
          Left = 6
          Top = 6
          Width = 75
          Height = 25
          Caption = #1042#1089#1077
          LookAndFeel.Kind = lfOffice11
          SpeedButtonOptions.GroupIndex = 1
          SpeedButtonOptions.CanBeFocused = False
          SpeedButtonOptions.Down = True
          TabOrder = 0
          OnClick = btUsersShowAllClick
        end
        object btUsersShowUsers: TcxButton
          Left = 87
          Top = 6
          Width = 83
          Height = 25
          Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
          LookAndFeel.Kind = lfOffice11
          SpeedButtonOptions.GroupIndex = 1
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 1
          OnClick = btUsersShowAllClick
        end
        object btUsersShowRoles: TcxButton
          Left = 176
          Top = 6
          Width = 75
          Height = 25
          Caption = #1056#1086#1083#1080
          LookAndFeel.Kind = lfOffice11
          SpeedButtonOptions.GroupIndex = 1
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 2
          OnClick = btUsersShowAllClick
        end
      end
      object grUsers: TcxGrid
        Left = 2
        Top = 41
        Width = 480
        Height = 562
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        object grUsersView: TcxGridTableView
          FilterBox.Visible = fvNever
          DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object grUsersUserID: TcxGridColumn
            Tag = -1
            Visible = False
            VisibleForCustomization = False
          end
          object grUsersUserName: TcxGridColumn
            Tag = -1
            Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
            Options.Editing = False
            Width = 379
          end
          object grUsersViewIsRole: TcxGridColumn
            Caption = #1056#1086#1083#1100
            PropertiesClassName = 'TcxCheckBoxProperties'
            Visible = False
            Options.Editing = False
          end
          object grUsersPermissionState: TcxGridColumn
            Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1086
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.AllowGrayed = True
            Properties.ImmediatePost = True
            Properties.ValueChecked = '1'
            Properties.ValueGrayed = '0'
            Properties.ValueUnchecked = '2'
            Properties.OnEditValueChanged = grUsersPermissionStatePropertiesEditValueChanged
            Width = 94
          end
        end
        object grUsersLevel1: TcxGridLevel
          GridView = grUsersView
        end
      end
    end
  end
end
