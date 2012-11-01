object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 534
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
    Height = 534
    Align = alLeft
    ActiveGroupIndex = 0
    TabOrder = 0
    View = 17
    ViewStyle.ColorSchemeName = 'Blue'
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
  object cxGrid1: TcxGrid
    Left = 193
    Top = 0
    Width = 741
    Height = 534
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    object cxGrid1DBBandedTableView1: TcxGridDBBandedTableView
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Editing = False
      OptionsSelection.InvertSelect = False
      OptionsView.FocusRect = False
      OptionsView.ScrollBars = ssNone
      OptionsView.ColumnAutoWidth = True
      OptionsView.GridLines = glNone
      OptionsView.GroupByBox = False
      OptionsView.Header = False
      OptionsView.RowSeparatorColor = clGradientActiveCaption
      OptionsView.RowSeparatorWidth = 3
      OptionsView.BandHeaders = False
      Bands = <
        item
        end>
      object cxGrid1DBBandedTableView1PARENT: TcxGridDBBandedColumn
        DataBinding.FieldName = 'PARENT'
        Options.Focusing = False
        SortIndex = 0
        SortOrder = soAscending
        Position.BandIndex = 0
        Position.ColIndex = 0
        Position.RowIndex = 1
      end
      object cxGrid1DBBandedTableView1ID: TcxGridDBBandedColumn
        DataBinding.FieldName = 'ID'
        Options.Focusing = False
        Position.BandIndex = 0
        Position.ColIndex = 1
        Position.RowIndex = 1
      end
      object cxGrid1DBBandedTableView1NAME: TcxGridDBBandedColumn
        DataBinding.FieldName = 'NAME'
        Options.Focusing = False
        Styles.Content = cxStyle17
        Position.BandIndex = 0
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object cxGrid1DBBandedTableView1PARENT_ID: TcxGridDBBandedColumn
        DataBinding.FieldName = 'PARENT_ID'
        Visible = False
        Position.BandIndex = 0
        Position.ColIndex = 1
        Position.RowIndex = 0
      end
    end
    object cxGrid1DBCardView1: TcxGridDBCardView
      OnCellClick = cxGrid1DBCardView1CellClick
      DataController.DataSource = DataSource1
      DataController.KeyFieldNames = 'ID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.RowMoving = True
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.InvertSelect = False
      OptionsSelection.CardBorderSelection = False
      OptionsView.CaptionSeparator = #0
      OptionsView.CardAutoWidth = True
      OptionsView.CardIndent = 5
      OptionsView.CardWidth = 210
      OptionsView.CellAutoHeight = True
      OptionsView.EmptyRows = False
      OptionsView.LayerSeparatorWidth = 5
      Styles.Background = cxStyle20
      object cxGrid1DBCardView1PARENT: TcxGridDBCardViewRow
        DataBinding.FieldName = 'PARENT'
        Visible = False
        Options.ShowCaption = False
        Position.BeginsLayer = True
      end
      object cxGrid1DBCardView1ID: TcxGridDBCardViewRow
        DataBinding.FieldName = 'ID'
        Options.ShowCaption = False
        Position.BeginsLayer = True
      end
      object cxGrid1DBCardView1NAME: TcxGridDBCardViewRow
        DataBinding.FieldName = 'NAME'
        Options.ShowCaption = False
        Position.BeginsLayer = False
        Styles.Content = cxStyle18
        Styles.Caption = cxStyle18
      end
      object cxGrid1DBCardView1PARENT_ID: TcxGridDBCardViewRow
        DataBinding.FieldName = 'PARENT_ID'
        Options.ShowCaption = False
        Position.BeginsLayer = True
      end
    end
    object cxGrid1Level1: TcxGridLevel
      Caption = 'ytrye6'
      GridView = cxGrid1DBBandedTableView1
    end
  end
  object Edit1: TEdit
    Left = 816
    Top = 168
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'Edit1'
  end
  object cxDBButtonEdit1: TcxDBButtonEdit
    Left = 520
    Top = 312
    ParentShowHint = False
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.ViewStyle = vsButtonsOnly
    ShowHint = False
    TabOrder = 3
    Width = 121
  end
  object cxDBListBox1: TcxDBListBox
    Left = 360
    Top = 352
    Width = 121
    Height = 97
    ItemHeight = 13
    TabOrder = 4
  end
  object cxDBBlobEdit1: TcxDBBlobEdit
    Left = 464
    Top = 184
    Properties.BlobEditKind = bekBlob
    Properties.BlobPaintStyle = bpsText
    TabOrder = 5
    Width = 121
  end
  object cxDBImage1: TcxDBImage
    Left = 384
    Top = 240
    TabOrder = 6
    Height = 100
    Width = 140
  end
  object cxDBMemo1: TcxDBMemo
    Left = 664
    Top = 232
    TabOrder = 7
    Height = 89
    Width = 185
  end
  object cxButton1: TcxButton
    Left = 552
    Top = 408
    Width = 75
    Height = 25
    Caption = 'cxButton1'
    TabOrder = 8
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
    DatabaseName = '192.168.0.5:b52'
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
    SQL.Strings = (
      'select p.name parent, i.id, i.name, i.parent_id '
      'from hrs_dept i'
      'left join hrs_dept p on (p.id = i.parent_id)'
      'order by p.name')
    Left = 128
    Top = 296
  end
  object IBTransaction1: TIBTransaction
    Left = 160
    Top = 248
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 408
    Top = 56
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor]
      Color = 15451300
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 16247513
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      TextColor = clBlack
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 16247513
      TextColor = clBlack
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 16247513
      TextColor = clBlack
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 14811135
      TextColor = clBlack
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14811135
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      TextColor = clNavy
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor]
      Color = 14872561
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 4707838
      TextColor = clBlack
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 12937777
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      TextColor = clWhite
    end
    object cxStyle11: TcxStyle
      AssignedValues = [svColor]
      Color = 15451300
    end
    object cxStyle12: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 4707838
      TextColor = clBlack
    end
    object cxStyle13: TcxStyle
      AssignedValues = [svColor]
      Color = 15451300
    end
    object cxStyle14: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14811135
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      TextColor = clNavy
    end
    object cxStyle15: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 12937777
      TextColor = clWhite
    end
    object cxStyle16: TcxStyle
    end
    object cxStyle17: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
    object cxStyle18: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
    object cxStyle19: TcxStyle
    end
    object cxStyle20: TcxStyle
    end
    object cxGridTableViewStyleSheet1: TcxGridTableViewStyleSheet
      BuiltIn = True
    end
    object GridTableViewStyleSheetDevExpress: TcxGridTableViewStyleSheet
      Caption = 'DevExpress'
      Styles.Background = cxStyle2
      Styles.Content = cxStyle3
      Styles.ContentEven = cxStyle4
      Styles.ContentOdd = cxStyle5
      Styles.FilterBox = cxStyle6
      Styles.Inactive = cxStyle11
      Styles.IncSearch = cxStyle12
      Styles.Selection = cxStyle15
      Styles.Footer = cxStyle7
      Styles.Group = cxStyle8
      Styles.GroupByBox = cxStyle9
      Styles.Header = cxStyle10
      Styles.Indicator = cxStyle13
      Styles.Preview = cxStyle14
      BuiltIn = True
    end
  end
  object Query1: TQuery
    Left = 304
    Top = 48
  end
end
