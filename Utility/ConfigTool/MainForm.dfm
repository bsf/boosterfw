object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 552
  ClientWidth = 970
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 0
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    Caption = 'cxGroupBox1'
    PanelStyle.Active = True
    Style.BorderStyle = ebsNone
    Style.LookAndFeel.Kind = lfOffice11
    Style.Shadow = False
    Style.TransparentBorder = True
    StyleDisabled.LookAndFeel.Kind = lfOffice11
    StyleFocused.LookAndFeel.Kind = lfOffice11
    StyleHot.LookAndFeel.Kind = lfOffice11
    TabOrder = 0
    Height = 552
    Width = 970
    object Button1: TButton
      Left = 416
      Top = 152
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object DBGrid1: TDBGrid
      Left = 654
      Top = 296
      Width = 275
      Height = 233
      DataSource = DataSource1
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object cxGroupBox2: TcxGroupBox
      Left = 2
      Top = 2
      Align = alTop
      Caption = 'cxGroupBox2'
      TabOrder = 2
      Height = 175
      Width = 966
      object cxButton1: TcxButton
        Left = 24
        Top = 15
        Width = 75
        Height = 25
        Caption = 'cxButton1'
        TabOrder = 0
        OnClick = cxButton1Click
      end
      object cxButton2: TcxButton
        Left = 128
        Top = 16
        Width = 75
        Height = 25
        Caption = 'cxButton2'
        TabOrder = 1
        OnClick = cxButton2Click
      end
      object cxButton3: TcxButton
        Left = 240
        Top = 16
        Width = 75
        Height = 25
        Caption = 'cxButton3'
        TabOrder = 2
        OnClick = cxButton3Click
      end
      object cxDBCheckListBox1: TcxDBCheckListBox
        Left = 495
        Top = 57
        Width = 121
        Height = 97
        Items = <>
        ParentColor = False
        TabOrder = 3
      end
      object cxDBCheckComboBox1: TcxDBCheckComboBox
        Left = 680
        Top = 16
        Properties.EditValueFormat = cvfIndices
        Properties.Items = <
          item
          end>
        TabOrder = 4
        Text = 'None selected'
        Width = 217
      end
    end
    object cxDBVerticalGrid1: TcxDBVerticalGrid
      Left = 3
      Top = 183
      Width = 646
      Height = 346
      OptionsView.RowHeaderWidth = 211
      TabOrder = 3
      DataController.DataSource = DataSource1
      Version = 1
      object cxDBVerticalGrid1ID: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'ID'
        ID = 0
        ParentID = -1
        Index = 0
        Version = 1
      end
      object cxDBVerticalGrid1IMG: TcxDBEditorRow
        Height = 150
        Properties.EditPropertiesClassName = 'TcxImageProperties'
        Properties.EditProperties.ClearKey = 46
        Properties.EditProperties.GraphicClassName = 'TJPEGImage'
        Properties.EditProperties.ImmediatePost = True
        Properties.EditProperties.OnAssignPicture = cxDBVerticalGrid1IMGEditPropertiesAssignPicture
        Properties.EditProperties.OnEditValueChanged = cxDBVerticalGrid1IMGEditPropertiesEditValueChanged
        Properties.DataBinding.FieldName = 'IMG'
        ID = 1
        ParentID = -1
        Index = 1
        Version = 1
      end
      object cxDBVerticalGrid1NAME: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'NAME'
        ID = 2
        ParentID = -1
        Index = 2
        Version = 1
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 216
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
    ReportOptions.CreateDate = 40693.610133379600000000
    ReportOptions.LastChange = 40693.610133379600000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 104
    Top = 104
    Datasets = <>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
      object ReportTitle1: TfrxReportTitle
        Height = 140.000000000000000000
        Top = 16.000000000000000000
        Width = 718.110700000000000000
        object Memo1: TfrxMemoView
          Left = 16.000000000000000000
          Top = 16.000000000000000000
          Width = 296.000000000000000000
          Height = 68.000000000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -32
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          Memo.UTF8W = (
            'trwetqwetwt')
          ParentFont = False
        end
      end
    end
  end
  object ClientDataSet1: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProvider1'
    AfterInsert = ClientDataSet1AfterInsert
    Left = 312
    Top = 120
    object ClientDataSet1ID: TIntegerField
      FieldName = 'ID'
      Origin = 'TEST.ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object ClientDataSet1IMG: TBlobField
      FieldName = 'IMG'
      Origin = 'TEST.IMG'
      ProviderFlags = [pfInUpdate]
      Size = 8
    end
    object ClientDataSet1NAME: TWideStringField
      FieldName = 'NAME'
      Origin = 'TEST.NAME'
      Size = 50
    end
  end
  object DataSetProvider1: TDataSetProvider
    DataSet = IBQuery1
    Left = 400
    Top = 88
  end
  object ClientDataSet2: TClientDataSet
    Aggregates = <>
    Params = <
      item
        DataType = ftBlob
        ParamType = ptUnknown
      end>
    Left = 800
    Top = 224
  end
  object DataSetProvider2: TDataSetProvider
    Left = 840
    Top = 160
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    Active = True
    CachedUpdates = True
    SQL.Strings = (
      'select * from test')
    UpdateObject = IBUpdateSQL1
    Left = 672
    Top = 80
  end
  object IBDatabase1: TIBDatabase
    Connected = True
    DatabaseName = 'server:b52'
    Params.Strings = (
      'user_name=sysdba'
      'password=211834'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    SQLDialect = 1
    Left = 752
    Top = 80
  end
  object IBTransaction1: TIBTransaction
    Active = True
    DefaultDatabase = IBDatabase1
    Left = 832
    Top = 80
  end
  object DataSource2: TDataSource
    DataSet = IBQuery1
    Left = 304
    Top = 64
  end
  object IBQuery2: TIBQuery
    Left = 760
    Top = 136
  end
  object IBUpdateSQL1: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  IMG,'
      '  NAME'
      'from test '
      'where'
      '  ID = :ID')
    ModifySQL.Strings = (
      'update test'
      'set'
      '  IMG = :IMG,'
      '  NAME = :NAME'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into test'
      '  (IMG, NAME)'
      'values'
      '  (:IMG, :NAME)')
    DeleteSQL.Strings = (
      'delete from test'
      'where'
      '  ID = :OLD_ID')
    Left = 720
    Top = 208
  end
end
