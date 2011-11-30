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
    Left = 352
    Top = 144
    Width = 545
    Height = 385
    TabOrder = 1
    object cxGrid1DBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      object cxGrid1DBTableView1Column1: TcxGridDBColumn
        Styles.Content = cxStyle1
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
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
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
    end
  end
end
