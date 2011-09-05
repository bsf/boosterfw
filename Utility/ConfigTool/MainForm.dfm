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
    ExplicitLeft = -32
    ExplicitTop = -5
    Height = 552
    Width = 970
    object dxNavBar1: TdxNavBar
      Left = 2
      Top = 2
      Width = 239
      Height = 548
      ParentCustomHint = False
      Align = alLeft
      ActiveGroupIndex = 0
      TabOrder = 0
      View = 13
      OptionsBehavior.NavigationPane.AllowCustomizing = False
      OptionsBehavior.NavigationPane.Collapsible = True
      OptionsBehavior.NavigationPane.ShowOverflowPanelHints = False
      OptionsView.Common.ShowGroupCaptions = False
      OptionsView.ExplorerBar.ShowSpecialGroup = True
      OptionsView.NavigationPane.ShowActiveGroupCaptionWhenCollapsed = True
      OptionsView.NavigationPane.ShowOverflowPanel = False
      object dxNavBar1Group1: TdxNavBarGroup
        Caption = 'dxNavBar1Group1'
        SelectedLinkIndex = -1
        TopVisibleLinkIndex = 0
        Links = <
          item
            Item = dxNavBar1Item3
          end
          item
            Item = dxNavBar1Item1
          end
          item
            Item = dxNavBar1Item2
          end>
      end
      object dxNavBar1Group2: TdxNavBarGroup
        Caption = 'dxNavBar1Group2'
        SelectedLinkIndex = -1
        TopVisibleLinkIndex = 0
        Links = <
          item
            Item = dxNavBar1Item6
          end
          item
            Item = dxNavBar1Item5
          end
          item
            Item = dxNavBar1Item4
          end>
      end
      object dxNavBar1Group3: TdxNavBarGroup
        Caption = 'dxNavBar1Group3'
        SelectedLinkIndex = -1
        TopVisibleLinkIndex = 0
        Links = <>
      end
      object dxNavBar1Item1: TdxNavBarItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        OnClick = dxNavBar1Item1Click
      end
      object dxNavBar1Item2: TdxNavBarItem
        Caption = #1055#1088#1077#1074#1100#1102
        OnClick = dxNavBar1Item2Click
      end
      object dxNavBar1Item3: TdxNavBarItem
        Caption = #1055#1077#1095#1072#1090#1100
      end
      object dxNavBar1Item4: TdxNavBarItem
        Caption = 'dxNavBar1Item4'
      end
      object dxNavBar1Item5: TdxNavBarItem
        Caption = 'dxNavBar1Item5'
      end
      object dxNavBar1Item6: TdxNavBarItem
        Caption = 'dxNavBar1Item6'
      end
    end
    object cxDBComboBox1: TcxDBComboBox
      Left = 559
      Top = 109
      TabOrder = 1
      Width = 121
    end
    object cxMRUEdit1: TcxMRUEdit
      Left = 472
      Top = 48
      Properties.ImmediatePost = True
      Properties.OnDeleteLookupItem = cxMRUEdit1PropertiesDeleteLookupItem
      Properties.OnInitPopup = cxMRUEdit1PropertiesInitPopup
      Properties.OnNewLookupDisplayText = cxMRUEdit1PropertiesNewLookupDisplayText
      TabOrder = 2
      Width = 329
    end
    object Button1: TButton
      Left = 416
      Top = 152
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 3
      OnClick = Button1Click
    end
    object DBGrid1: TDBGrid
      Left = 752
      Top = 224
      Width = 193
      Height = 193
      DataSource = DataSource1
      TabOrder = 4
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object cxDBVerticalGrid2: TcxDBVerticalGrid
      Left = 239
      Top = 152
      Width = 586
      Height = 357
      OptionsView.ShowEditButtons = ecsbAlways
      OptionsView.RowHeaderWidth = 228
      TabOrder = 5
      DataController.DataSource = DataSource1
      Version = 1
      object cxDBVerticalGrid2ID: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'ID'
        ID = 0
        ParentID = -1
        Index = 0
        Version = 1
      end
      object cxDBVerticalGrid2IMG: TcxDBEditorRow
        Height = 150
        Properties.EditPropertiesClassName = 'TcxImageProperties'
        Properties.EditProperties.GraphicClassName = 'TJPEGImage'
        Properties.EditProperties.Stretch = True
        Properties.DataBinding.FieldName = 'IMG'
        Properties.Options.ShowEditButtons = eisbAlways
        ID = 1
        ParentID = -1
        Index = 1
        Version = 1
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 256
    Top = 280
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
    Left = 80
    Top = 280
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    SQL.Strings = (
      'select * from test')
    Left = 192
    Top = 280
  end
  object IBTransaction1: TIBTransaction
    Active = True
    Left = 128
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
    Active = True
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProvider1'
    AfterInsert = ClientDataSet1AfterInsert
    Left = 320
    Top = 368
  end
  object DataSetProvider1: TDataSetProvider
    DataSet = IBQuery1
    Left = 248
    Top = 400
  end
end
