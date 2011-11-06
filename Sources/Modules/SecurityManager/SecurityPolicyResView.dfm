inherited frSecurityPolicyResView: TfrSecurityPolicyResView
  Left = 462
  Top = 241
  Caption = 'frSecurityPolicyResView'
  ClientHeight = 626
  ClientWidth = 1031
  ExplicitWidth = 320
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 1031
    ExplicitHeight = 626
    Height = 626
    Width = 1031
    inherited pnButtons: TcxGroupBox
      ExplicitWidth = 1027
      Width = 1027
    end
    object trRes: TcxTreeList
      Left = 2
      Top = 42
      Width = 485
      Height = 582
      Align = alLeft
      Bands = <
        item
        end>
      LookAndFeel.Kind = lfOffice11
      OptionsBehavior.ExpandOnIncSearch = True
      OptionsBehavior.IncSearch = True
      OptionsData.Editing = False
      OptionsData.Deleting = False
      OptionsSelection.HideFocusRect = False
      OptionsView.ColumnAutoWidth = True
      TabOrder = 1
      OnSelectionChanged = trResSelectionChanged
      object grResID: TcxTreeListColumn
        Visible = False
        DataBinding.ValueType = 'String'
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object grResNAME: TcxTreeListColumn
        Caption.Text = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        DataBinding.ValueType = 'String'
        Width = 284
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object grResDESCRIPTION: TcxTreeListColumn
        DataBinding.ValueType = 'String'
        Width = 199
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object grResPARENTID: TcxTreeListColumn
        Visible = False
        DataBinding.ValueType = 'String'
        Position.ColIndex = 3
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 487
      Top = 42
      Width = 8
      Height = 582
      Control = trRes
    end
    object TcxGroupBox
      Left = 495
      Top = 42
      Align = alClient
      PanelStyle.Active = True
      Style.BorderStyle = ebsNone
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 3
      Height = 582
      Width = 534
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
        Width = 530
        object btUsersShowAll: TcxButton
          Left = 7
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
        Width = 530
        Height = 539
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        object grUsersView: TcxGridTableView
          NavigatorButtons.ConfirmDelete = False
          FilterBox.Visible = fvNever
          OnEditChanged = grUsersViewEditChanged
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
        end
        object grUsersLevel1: TcxGridLevel
          GridView = grUsersView
        end
      end
    end
  end
  object cxEditRepository1: TcxEditRepository
    Left = 90
    Top = 120
    object PermColumnProp: TcxEditRepositoryCheckBoxItem
      Properties.AllowGrayed = True
      Properties.ImmediatePost = True
      Properties.ValueChecked = '1'
      Properties.ValueGrayed = '0'
      Properties.ValueUnchecked = '2'
    end
  end
end
