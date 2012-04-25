object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 660
  ClientWidth = 983
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GridPanel1: TGridPanel
    Left = 0
    Top = 0
    Width = 297
    Height = 660
    Align = alLeft
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = cxButton1
        Row = 0
      end
      item
        Column = 0
        Control = cxButton2
        Row = 1
      end
      item
        Column = 0
        Control = cxButton3
        Row = 2
      end>
    RowCollection = <
      item
        Value = 9.988777075419982000
      end
      item
        Value = 9.976202947710620000
      end
      item
        Value = 9.987033426881162000
      end
      item
        Value = 10.001974652924070000
      end
      item
        Value = 10.009902392686720000
      end
      item
        Value = 10.012382398054110000
      end
      item
        Value = 10.011088592403550000
      end
      item
        Value = 10.007722846020730000
      end
      item
        Value = 10.003903135748910000
      end
      item
        Value = 10.001012532150170000
      end>
    TabOrder = 0
    object cxButton1: TcxButton
      Left = 1
      Top = 1
      Width = 295
      Height = 65
      Margins.Top = 5
      Align = alClient
      Caption = 'cxButton1'
      LookAndFeel.Kind = lfFlat
      LookAndFeel.NativeStyle = False
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 0
      ExplicitTop = -7
    end
    object cxButton2: TcxButton
      Left = 1
      Top = 66
      Width = 295
      Height = 65
      Margins.Top = 5
      Align = alClient
      Caption = 'cxButton1'
      LookAndFeel.Kind = lfFlat
      LookAndFeel.NativeStyle = False
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 1
      ExplicitLeft = 56
      ExplicitTop = 16
      ExplicitWidth = 75
      ExplicitHeight = 25
    end
    object cxButton3: TcxButton
      Left = 1
      Top = 131
      Width = 295
      Height = 65
      Margins.Top = 5
      Align = alClient
      Caption = 'cxButton1'
      LookAndFeel.Kind = lfFlat
      LookAndFeel.NativeStyle = False
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 2
      ExplicitLeft = 56
      ExplicitTop = 16
      ExplicitWidth = 75
      ExplicitHeight = 25
    end
  end
  object DataSource1: TDataSource
    DataSet = IBQuery1
    Left = 352
    Top = 48
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
    Left = 448
    Top = 48
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    SQL.Strings = (
      'select * from spr_dept')
    Left = 520
    Top = 48
  end
  object IBTransaction1: TIBTransaction
    Active = True
    DefaultDatabase = IBDatabase1
    Left = 480
    Top = 104
  end
end
