inherited frSecurityPoliciesView: TfrSecurityPoliciesView
  Left = 658
  Top = 282
  Caption = 'frSecurityPoliciesView'
  ClientHeight = 564
  ClientWidth = 1177
  ExplicitWidth = 1183
  ExplicitHeight = 592
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 1177
    ExplicitHeight = 564
    Height = 564
    Width = 1177
    inherited pnButtons: TcxGroupBox
      ExplicitWidth = 1177
      Width = 1177
    end
    object cxSplitter1: TcxSplitter
      Left = 309
      Top = 40
      Width = 8
      Height = 524
      Control = trPolicies
    end
    object grPermissions: TcxGrid
      Left = 317
      Top = 40
      Width = 860
      Height = 524
      Align = alClient
      TabOrder = 2
      LookAndFeel.Kind = lfOffice11
      object grPermissionsView: TcxGridTableView
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
        Preview.Column = grPermissionsViewDESCRIPTION
        Preview.Visible = True
        object grPermissionsViewPERMID: TcxGridColumn
          Visible = False
        end
        object grPermissionsViewNAME: TcxGridColumn
          Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077
          Width = 347
        end
        object grPermissionsViewINHERITBY: TcxGridColumn
          Caption = #1053#1072#1089#1083#1077#1076#1091#1077#1090' '#1086#1090' '
          Width = 337
        end
        object grPermissionsViewDESCRIPTION: TcxGridColumn
        end
      end
      object grPermissionsLevel1: TcxGridLevel
        GridView = grPermissionsView
      end
    end
    object trPolicies: TcxTreeList
      Left = 0
      Top = 40
      Width = 309
      Height = 524
      Align = alLeft
      Bands = <
        item
        end>
      LookAndFeel.Kind = lfOffice11
      OptionsBehavior.CellHints = True
      OptionsData.Editing = False
      OptionsData.Deleting = False
      OptionsSelection.InvertSelect = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.Headers = False
      TabOrder = 3
      OnCustomDrawDataCell = trPoliciesCustomDrawDataCell
      OnSelectionChanged = trPoliciesSelectionChanged
      object colName: TcxTreeListColumn
        Caption.Text = 'Name'
        DataBinding.ValueType = 'String'
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object colID: TcxTreeListColumn
        Visible = False
        Caption.Text = 'ID'
        DataBinding.ValueType = 'Variant'
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object colParentID: TcxTreeListColumn
        Visible = False
        Caption.Text = 'parentID'
        DataBinding.ValueType = 'Variant'
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object colState: TcxTreeListColumn
        Visible = False
        DataBinding.ValueType = 'String'
        Position.ColIndex = 3
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
  end
end
