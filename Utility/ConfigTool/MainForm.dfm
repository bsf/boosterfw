object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 504
  ClientWidth = 920
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 46
    Align = alLeft
    Caption = 'cxGroupBox1'
    PanelStyle.Active = True
    Style.Shadow = False
    TabOrder = 0
    Height = 458
    Width = 289
    object cxGrid1: TcxGrid
      AlignWithMargins = True
      Left = 5
      Top = 60
      Width = 279
      Height = 338
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = cxcbsNone
      TabOrder = 0
      LookAndFeel.Kind = lfFlat
      LookAndFeel.NativeStyle = True
      object cxGrid1DBTableView1: TcxGridDBTableView
        DataController.DataSource = DataSource1
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.ScrollBars = ssNone
        OptionsView.ColumnAutoWidth = True
        OptionsView.GridLines = glNone
        OptionsView.RowSeparatorColor = clInfoBk
        OptionsView.RowSeparatorWidth = 4
        object cxGrid1DBTableView1NAME: TcxGridDBColumn
          DataBinding.FieldName = 'NAME'
        end
        object cxGrid1DBTableView1KOD: TcxGridDBColumn
          DataBinding.FieldName = 'KOD'
        end
        object cxGrid1DBTableView1ORG: TcxGridDBColumn
          DataBinding.FieldName = 'ORG'
        end
      end
      object cxGrid1DBBandedTableView1: TcxGridDBBandedTableView
        Navigator.InfoPanel.Visible = True
        OnCellClick = cxGrid1DBBandedTableView1CellClick
        DataController.DataSource = DataSource1
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Editing = False
        OptionsSelection.InvertSelect = False
        OptionsView.FocusRect = False
        OptionsView.ScrollBars = ssNone
        OptionsView.ColumnAutoWidth = True
        OptionsView.DataRowHeight = 50
        OptionsView.GridLines = glNone
        OptionsView.GroupByBox = False
        OptionsView.Header = False
        OptionsView.RowSeparatorColor = clMenu
        OptionsView.RowSeparatorWidth = 6
        OptionsView.BandHeaders = False
        Bands = <
          item
          end>
        object cxGrid1DBBandedTableView1KOD: TcxGridDBBandedColumn
          DataBinding.FieldName = 'KOD'
          Visible = False
          Position.BandIndex = 0
          Position.ColIndex = 0
          Position.RowIndex = 1
        end
        object cxGrid1DBBandedTableView1NAME: TcxGridDBBandedColumn
          DataBinding.FieldName = 'NAME'
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.Alignment.Horz = taCenter
          Options.Focusing = False
          Options.CellMerging = True
          Styles.Content = cxStyle1
          Position.BandIndex = 0
          Position.ColIndex = 0
          Position.RowIndex = 0
        end
        object cxGrid1DBBandedTableView1ORG: TcxGridDBBandedColumn
          DataBinding.FieldName = 'ORG'
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.Alignment.Horz = taRightJustify
          Options.Focusing = False
          Position.BandIndex = 0
          Position.ColIndex = 1
          Position.RowIndex = 1
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = cxGrid1DBBandedTableView1
      end
    end
    object cxButton4: TcxButton
      Left = 2
      Top = 2
      Width = 285
      Height = 55
      Align = alTop
      Caption = 'cxButton4'
      LookAndFeel.Kind = lfFlat
      LookAndFeel.NativeStyle = False
      SpeedButtonOptions.Flat = True
      TabOrder = 1
    end
    object cxButton5: TcxButton
      Left = 2
      Top = 401
      Width = 285
      Height = 55
      Align = alBottom
      Caption = 'cxButton4'
      LookAndFeel.Kind = lfFlat
      LookAndFeel.NativeStyle = False
      SpeedButtonOptions.Flat = True
      TabOrder = 2
    end
  end
  object cxButton6: TcxButton
    Left = 448
    Top = 46
    Width = 75
    Height = 25
    Caption = 'cxButton6'
    TabOrder = 1
    OnClick = cxButton6Click
  end
  object cxDBVerticalGrid1: TcxDBVerticalGrid
    Left = 312
    Top = 344
    Width = 289
    Height = 81
    OptionsView.RowHeaderWidth = 141
    TabOrder = 2
    Version = 1
    object cxDBVerticalGrid1DBEditorRow1: TcxDBEditorRow
      Properties.EditPropertiesClassName = 'TcxPopupEditProperties'
      Properties.EditProperties.ImmediateDropDownWhenActivated = False
      ID = 0
      ParentID = -1
      Index = 0
      Version = 1
    end
    object cxDBVerticalGrid1DBEditorRow2: TcxDBEditorRow
      Properties.EditPropertiesClassName = 'TcxCalcEditProperties'
      Properties.EditProperties.ImmediateDropDownWhenKeyPressed = True
      ID = 1
      ParentID = -1
      Index = 1
      Version = 1
    end
  end
  object cxButton7: TcxButton
    Left = 352
    Top = 46
    Width = 75
    Height = 25
    Caption = 'add'
    TabOrder = 3
    OnClick = cxButton7Click
  end
  object cxButton1: TcxButton
    Left = 544
    Top = 46
    Width = 75
    Height = 25
    Caption = 'cxButton6'
    TabOrder = 4
    OnClick = cxButton1Click
  end
  object pnButtons: TcxGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Align = alTop
    PanelStyle.Active = True
    PanelStyle.OfficeBackgroundKind = pobkGradient
    Style.BorderStyle = ebsNone
    Style.LookAndFeel.Kind = lfOffice11
    StyleDisabled.LookAndFeel.Kind = lfOffice11
    StyleFocused.LookAndFeel.Kind = lfOffice11
    StyleHot.LookAndFeel.Kind = lfOffice11
    TabOrder = 5
    Height = 40
    Width = 914
  end
  object cxGroupBox2: TcxGroupBox
    Left = 464
    Top = 112
    Caption = 'cxGroupBox2'
    TabOrder = 6
    Height = 161
    Width = 417
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 272
    Top = 16
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
    Left = 224
    Top = 40
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    SQL.Strings = (
      'select * from spr_podr where name containing '#39#1057#39)
    Left = 128
    Top = 72
  end
  object IBTransaction1: TIBTransaction
    DefaultDatabase = IBDatabase1
    Left = 176
    Top = 192
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    CommandText = 'select * from spr_podr where name containing '#39#1057#39
    Params = <>
    ProviderName = 'DataSetProvider1'
    Left = 152
    Top = 248
  end
  object DataSetProvider1: TDataSetProvider
    DataSet = IBQuery1
    Options = [poAllowCommandText, poUseQuoteChar]
    Left = 208
    Top = 136
  end
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <>
    StorageName = 'cxPropertiesStore1'
    Left = 368
    Top = 104
  end
  object IBBackupService1: TIBBackupService
    TraceFlags = []
    BlockingFactor = 0
    Options = []
    Left = 688
    Top = 328
  end
  object IBSQL1: TIBSQL
    Left = 328
    Top = 224
  end
  object IBExtract1: TIBExtract
    Left = 384
    Top = 216
  end
  object IBScript1: TIBScript
    Terminator = ';'
    Left = 400
    Top = 280
  end
end
