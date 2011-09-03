inherited frReportSetupView: TfrReportSetupView
  Left = 732
  Top = 290
  Caption = 'frReportSetupView'
  ClientWidth = 838
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    Width = 838
    object pcMain: TcxPageControl
      Left = 2
      Top = 2
      Width = 834
      Height = 519
      ActivePage = tsParams
      Align = alClient
      LookAndFeel.Kind = lfOffice11
      TabOrder = 0
      ClientRectBottom = 519
      ClientRectRight = 834
      ClientRectTop = 24
      object tcNoSetup: TcxTabSheet
        Caption = 'tcNoSetup'
        ImageIndex = 2
        object cxMemo1: TcxMemo
          Left = 0
          Top = 0
          TabStop = False
          Align = alTop
          Lines.Strings = (
            #1054#1090#1095#1077#1090' '#1085#1077' '#1090#1088#1077#1073#1091#1077#1090' '#1085#1072#1089#1090#1088#1086#1077#1082)
          Properties.HideSelection = False
          Properties.ReadOnly = True
          Style.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.Kind = lfOffice11
          TabOrder = 0
          Height = 35
          Width = 834
        end
      end
      object tsParams: TcxTabSheet
        Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
        ImageIndex = 1
        object cxSplitter1: TcxSplitter
          Left = 326
          Top = 33
          Width = 6
          Height = 462
          Control = cxGroupBox4
        end
        object cxGroupBox2: TcxGroupBox
          Left = 332
          Top = 33
          Align = alClient
          Caption = 'cxGroupBox2'
          PanelStyle.Active = True
          Style.BorderStyle = ebsNone
          Style.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.Kind = lfOffice11
          TabOrder = 1
          Height = 462
          Width = 502
          object grItemLinks: TcxGrid
            Left = 2
            Top = 2
            Width = 498
            Height = 458
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            object grItemLinksView: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.DataSource = ItemLinksDataSource
              DataController.KeyFieldNames = 'LINK_ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.Appending = True
              OptionsView.ShowEditButtons = gsebForFocusedRecord
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object grItemLinksViewColumn1: TcxGridDBColumn
                Caption = #1069#1083#1077#1084#1077#1085#1090
                DataBinding.FieldName = 'LINK_ID'
                PropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.DropDownListStyle = lsFixedList
                Properties.KeyFieldNames = 'id'
                Properties.ListColumns = <
                  item
                    FieldName = 'name'
                  end>
                Properties.ListOptions.ShowHeader = False
                Properties.ListSource = ItemLinksLookupDataSource
                Width = 364
              end
              object grItemLinksViewColumn2: TcxGridDBColumn
                DataBinding.FieldName = 'RPT_ID'
                Visible = False
              end
              object grItemLinksViewColumn3: TcxGridDBColumn
                DataBinding.FieldName = 'ITEM_ID'
                Visible = False
              end
            end
            object grItemLinksLevel1: TcxGridLevel
              GridView = grItemLinksView
            end
          end
        end
        object cxGroupBox3: TcxGroupBox
          Left = 0
          Top = 0
          Align = alTop
          PanelStyle.Active = True
          Style.BorderStyle = ebsNone
          Style.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.Kind = lfOffice11
          TabOrder = 2
          Height = 33
          Width = 834
          object mmInfo: TcxMemo
            Left = 2
            Top = 2
            TabStop = False
            Align = alClient
            Properties.HideSelection = False
            Properties.ReadOnly = True
            Style.LookAndFeel.Kind = lfOffice11
            StyleDisabled.LookAndFeel.Kind = lfOffice11
            StyleFocused.LookAndFeel.Kind = lfOffice11
            StyleHot.LookAndFeel.Kind = lfOffice11
            TabOrder = 0
            Height = 29
            Width = 830
          end
        end
        object cxGroupBox4: TcxGroupBox
          Left = 0
          Top = 33
          Align = alLeft
          Caption = 'cxGroupBox4'
          PanelStyle.Active = True
          Style.BorderStyle = ebsNone
          Style.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.Kind = lfOffice11
          TabOrder = 3
          Height = 462
          Width = 326
          object grItems: TcxGrid
            Left = 2
            Top = 2
            Width = 322
            Height = 458
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            object grItemsView: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              OnFocusedRecordChanged = grItemsViewFocusedRecordChanged
              DataController.DataSource = ItemsDataSource
              DataController.KeyFieldNames = 'ITEM_ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.Deleting = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object grItemsViewColumn1: TcxGridDBColumn
                Caption = #1055#1072#1088#1072#1084#1077#1090#1088
                DataBinding.FieldName = 'ITEM_ID'
              end
              object grItemsViewColumn2: TcxGridDBColumn
                Caption = #1054#1087#1080#1089#1072#1085#1080#1077
                DataBinding.FieldName = 'DESCRIPTION'
                Width = 223
              end
              object grItemsViewColumn3: TcxGridDBColumn
                Caption = #1043#1088#1091#1087#1087#1072
                DataBinding.FieldName = 'GRP_NAME'
                Visible = False
                GroupIndex = 0
              end
              object grItemsViewColumn4: TcxGridDBColumn
                DataBinding.FieldName = 'GRP_ID'
                Visible = False
              end
              object grItemsViewColumn5: TcxGridDBColumn
                DataBinding.FieldName = 'EDITOR'
                Visible = False
              end
            end
            object grItemsLevel1: TcxGridLevel
              GridView = grItemsView
            end
          end
        end
      end
    end
  end
  object ItemsDataSource: TDataSource
    Left = 28
    Top = 193
  end
  object ItemLinksDataSource: TDataSource
    Left = 26
    Top = 249
  end
  object ItemLinksLookupDataSource: TDataSource
    Left = 54
    Top = 249
  end
end
