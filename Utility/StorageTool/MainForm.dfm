object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 605
  ClientWidth = 934
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object dxNavBar1: TdxNavBar
    Left = 0
    Top = 0
    Width = 193
    Height = 605
    Align = alLeft
    ActiveGroupIndex = 0
    TabOrder = 0
    View = 17
    ViewStyle.ColorSchemeName = 'Blue'
    ExplicitHeight = 615
    object dxNavBar1Group1: TdxNavBarGroup
      Caption = 'dxNavBar1Group1'
      SelectedLinkIndex = -1
      TopVisibleLinkIndex = 0
      Links = <
        item
          Item = dxNavBar1Item1
        end>
    end
    object dxNavBar1Group2: TdxNavBarGroup
      Caption = 'dxNavBar1Group2'
      SelectedLinkIndex = -1
      TopVisibleLinkIndex = 0
      Links = <
        item
          Item = dxNavBar1Item2
        end>
    end
    object dxNavBar1Item1: TdxNavBarItem
      Caption = 'dxNavBar1Item1'
    end
    object dxNavBar1Item2: TdxNavBarItem
      Caption = 'dxNavBar1Item2'
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 193
    Top = 0
    Width = 741
    Height = 605
    ActivePage = cxTabSheet4
    Align = alClient
    Color = 13603685
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    ParentBackground = False
    ParentColor = False
    TabOrder = 1
    ExplicitWidth = 751
    ExplicitHeight = 615
    ClientRectBottom = 601
    ClientRectLeft = 2
    ClientRectRight = 737
    ClientRectTop = 22
    object cxTabSheet1: TcxTabSheet
      Caption = 'cxTabSheet1'
      ImageIndex = 0
      ExplicitWidth = 745
      ExplicitHeight = 589
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 735
        Height = 579
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        ExplicitWidth = 745
        ExplicitHeight = 589
        object cxGrid1DBTableView1: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = DataSource1
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          object cxGrid1DBTableView1KOD: TcxGridDBColumn
            DataBinding.FieldName = 'KOD'
          end
          object cxGrid1DBTableView1NAME: TcxGridDBColumn
            DataBinding.FieldName = 'NAME'
          end
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGrid1DBTableView1
        end
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'cxTabSheet2'
      ImageIndex = 1
      ExplicitWidth = 745
      ExplicitHeight = 589
      object cxVerticalGrid1: TcxVerticalGrid
        Left = 144
        Top = 112
        Width = 433
        Height = 313
        OptionsView.RowHeaderWidth = 192
        TabOrder = 0
        Version = 1
        object cxVerticalGrid1EditorRow1: TcxEditorRow
          Properties.EditPropertiesClassName = 'TcxExtLookupComboBoxProperties'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 0
          ParentID = -1
          Index = 0
          Version = 1
        end
      end
      object cxLookupComboBox1: TcxLookupComboBox
        Left = 24
        Top = 16
        Properties.GridMode = True
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'NAME'
          end>
        Properties.ListOptions.FocusRowOnMouseMove = False
        Properties.ListSource = DataSource1
        Style.LookAndFeel.Kind = lfOffice11
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        TabOrder = 1
        Width = 225
      end
      object DBLookupComboBox1: TDBLookupComboBox
        Left = 408
        Top = 16
        Width = 145
        Height = 21
        KeyField = 'ID'
        ListField = 'NAME'
        ListSource = DataSource1
        TabOrder = 2
      end
      object cxComboBox1: TcxComboBox
        Left = 32
        Top = 72
        Properties.Items.Strings = (
          'ffdsafa'
          'fdasfffffffffffff'
          'fdsafffff'
          'fasffaaa'
          '2'
          '3'
          '5'
          '64'
          '7'
          '8'
          '9'
          '44'
          '222'
          '2222')
        TabOrder = 3
        Text = 'cxComboBox1'
        Width = 217
      end
      object cxDBExtLookupComboBox1: TcxDBExtLookupComboBox
        Left = 328
        Top = 85
        TabOrder = 4
        Width = 225
      end
      object cxDBComboBox1: TcxDBComboBox
        Left = 328
        Top = 43
        Properties.DropDownListStyle = lsEditFixedList
        Properties.OnInitPopup = cxDBComboBox1PropertiesInitPopup
        TabOrder = 5
        Width = 225
      end
    end
    object cxTabSheet3: TcxTabSheet
      Caption = 'cxTabSheet3'
      ImageIndex = 2
      ExplicitWidth = 745
      ExplicitHeight = 589
      object cxTreeList1: TcxTreeList
        Left = 0
        Top = 0
        Width = 193
        Height = 579
        Align = alLeft
        Bands = <
          item
          end>
        LookAndFeel.Kind = lfOffice11
        OptionsView.CategorizedColumn = cxTreeList1Column1
        OptionsView.PaintStyle = tlpsCategorized
        TabOrder = 0
        ExplicitHeight = 589
        Data = {
          00000500B10000000F00000044617461436F6E74726F6C6C6572310100000012
          000000546378537472696E6756616C75655479706502000000445855464D5400
          000800000076007800630076007A00780076007A00445855464D540000070000
          0066006400730061006600610066000100000000000000020001000000000000
          0000000000FFFFFFFFFFFFFFFFFFFFFFFF0100000008000000000000000000FF
          FFFFFFFFFFFFFFFFFFFFFF0A0001000000}
        object cxTreeList1Column1: TcxTreeListColumn
          DataBinding.ValueType = 'String'
          Width = 124
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object cxDBTreeList1: TcxDBTreeList
        Left = 238
        Top = 0
        Width = 497
        Height = 579
        Align = alRight
        Bands = <
          item
          end>
        DataController.DataSource = DataSource1
        DataController.ParentField = 'PARENT_ID'
        DataController.KeyField = 'ID'
        LookAndFeel.Kind = lfOffice11
        OptionsBehavior.HotTrack = True
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRect = False
        OptionsSelection.InvertSelect = False
        OptionsView.Buttons = False
        OptionsView.CategorizedColumn = cxDBTreeList1cxDBTreeListColumn1
        OptionsView.ColumnAutoWidth = True
        OptionsView.DropNodeIndicator = True
        OptionsView.DynamicIndent = True
        OptionsView.FocusRect = False
        OptionsView.Headers = False
        OptionsView.PaintStyle = tlpsCategorized
        OptionsView.ShowRoot = False
        OptionsView.TreeLineStyle = tllsNone
        RootValue = -1
        TabOrder = 1
        ExplicitLeft = 248
        ExplicitHeight = 589
        object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'PARENT'
          Width = 217
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn
          DataBinding.FieldName = 'NAME'
          Width = 216
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
    object cxTabSheet4: TcxTabSheet
      Caption = 'cxTabSheet4'
      ImageIndex = 3
      ExplicitLeft = 3
      ExplicitTop = 23
      ExplicitWidth = 745
      ExplicitHeight = 589
      object cxRichEdit1: TcxRichEdit
        Left = 200
        Top = 224
        Properties.SelectionBar = True
        Properties.WordWrap = False
        Lines.Strings = (
          'cxRichEdit1')
        TabOrder = 0
        Height = 121
        Width = 417
      end
      object cxMRUEdit1: TcxMRUEdit
        Left = 192
        Top = 416
        Properties.DropDownListStyle = lsEditFixedList
        Properties.DropDownSizeable = True
        Properties.LookupItems.Strings = (
          'fdsafasfa'
          'fdasfas'
          '2111'
          'dd'
          'd')
        TabOrder = 1
        Width = 217
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = IBQuery1
    Left = 144
    Top = 120
  end
  object frxReport1: TfrxReport
    Version = '4.10.5'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = #1055#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 40679.725505821750000000
    ReportOptions.LastChange = 40679.725505821750000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 72
    Top = 88
    Datasets = <>
    Variables = <>
    Style = <>
  end
  object ClientDataSet1: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    Left = 248
    Top = 328
    Data = {
      3E0000009619E0BD0100000018000000020000000000030000003E0002696404
      00010000000000046E616D650100490000000100055749445448020002003200
      0000}
    object ClientDataSet1id: TIntegerField
      FieldName = 'id'
    end
    object ClientDataSet1name: TStringField
      FieldName = 'name'
      Size = 50
    end
  end
  object IBDatabase1: TIBDatabase
    Connected = True
    DatabaseName = '192.168.0.253:b52'
    Params.Strings = (
      'user_name=sysdba'
      'password=211834'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    SQLDialect = 1
    Left = 264
    Top = 144
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    Active = True
    SQL.Strings = (
      'select p.name parent, i.id, i.name, i.parent_id '
      'from hrs_dept i'
      'left join hrs_dept p on (p.id = i.parent_id)'
      'order by p.name')
    Left = 128
    Top = 296
  end
  object IBTransaction1: TIBTransaction
    Active = True
    Left = 160
    Top = 248
  end
  object frxRichObject1: TfrxRichObject
    Left = 416
    Top = 80
  end
end
