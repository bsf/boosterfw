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
      Left = 752
      Top = 224
      Width = 193
      Height = 193
      DataSource = DataSource1
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object cxDBPivotGrid1: TcxDBPivotGrid
      Left = 2
      Top = 281
      Width = 966
      Height = 269
      Align = alClient
      DataSource = DataSource1
      Groups = <>
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      TabOrder = 2
      ExplicitTop = 57
      ExplicitHeight = 493
      object cxDBPivotGrid1NAME: TcxDBPivotGridField
        Area = faRow
        AreaIndex = 1
        DataBinding.FieldName = 'NAME'
        Visible = True
        Width = 258
      end
      object cxDBPivotGrid1GRP: TcxDBPivotGridField
        Area = faRow
        AreaIndex = 0
        DataBinding.FieldName = 'GRP'
        Visible = True
      end
      object cxDBPivotGrid1WEIGHT: TcxDBPivotGridField
        Area = faData
        AreaIndex = 0
        DataBinding.FieldName = 'WEIGHT'
        Visible = True
      end
    end
    object cxGroupBox2: TcxGroupBox
      Left = 2
      Top = 2
      Align = alTop
      Caption = 'cxGroupBox2'
      TabOrder = 3
      Height = 279
      Width = 966
      object cxButton1: TcxButton
        Left = 24
        Top = 16
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
        Left = 512
        Top = 16
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
      object cxDBVerticalGrid1: TcxDBVerticalGrid
        Left = 232
        Top = 73
        Width = 241
        Height = 200
        TabOrder = 5
        Version = 1
        object cxDBVerticalGrid1DBEditorRow1: TcxDBEditorRow
          Properties.EditPropertiesClassName = 'TcxCheckComboBoxProperties'
          Properties.EditProperties.Items = <>
          ID = 0
          ParentID = -1
          Index = 0
          Version = 1
        end
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 256
    Top = 280
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
    Left = 128
    Top = 160
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
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProvider1'
    AfterInsert = ClientDataSet1AfterInsert
    Left = 320
    Top = 368
  end
  object DataSetProvider1: TDataSetProvider
    Left = 248
    Top = 400
  end
end
