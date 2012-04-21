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
  object CategoryPanelGroup1: TCategoryPanelGroup
    Left = 0
    Top = 0
    Height = 660
    VertScrollBar.Smooth = True
    VertScrollBar.Style = ssFlat
    VertScrollBar.Tracking = True
    ChevronAlignment = taRightJustify
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -11
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = []
    TabOrder = 0
    object CategoryPanel3: TCategoryPanel
      Top = 400
      Caption = 'CategoryPanel3'
      TabOrder = 0
    end
    object CategoryPanel2: TCategoryPanel
      Top = 200
      Caption = 'CategoryPanel2'
      TabOrder = 1
      object ButtonGroup1: TButtonGroup
        Left = 0
        Top = 0
        Width = 196
        Height = 174
        Align = alClient
        ButtonOptions = [gboFullSize, gboShowCaptions]
        Items = <
          item
          end
          item
          end
          item
          end
          item
            Caption = 'kiytiotiyt'
          end
          item
          end
          item
          end
          item
          end
          item
          end
          item
          end>
        TabOrder = 0
      end
    end
    object CategoryPanel1: TCategoryPanel
      Top = 0
      Caption = 'CategoryPanel1'
      TabOrder = 2
    end
  end
  object dxNavBar1: TdxNavBar
    Left = 728
    Top = 0
    Width = 255
    Height = 660
    Align = alRight
    ActiveGroupIndex = 0
    TabOrder = 1
    View = 16
    OptionsView.ExplorerBar.ShowSpecialGroup = True
    object dxNavBar1Group1: TdxNavBarGroup
      Caption = 'dxNavBar1Group1'
      SelectedLinkIndex = -1
      TopVisibleLinkIndex = 0
      UseRestSpace = True
      OptionsGroupControl.ShowControl = True
      OptionsGroupControl.UseControl = True
      Links = <
        item
          Item = dxNavBar1Item1
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
          Item = dxNavBar1Item1
        end
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
    object dxNavBar1Group1Control: TdxNavBarGroupControl
      Left = 0
      Top = 19
      Width = 255
      Height = 562
      Caption = 'dxNavBar1Group1Control'
      TabOrder = 4
      GroupIndex = 0
      OriginalHeight = 41
      object ButtonGroup2: TButtonGroup
        Left = 0
        Top = 0
        Width = 255
        Height = 562
        Align = alClient
        ButtonOptions = [gboAllowReorder, gboFullSize, gboGroupStyle, gboShowCaptions]
        Items = <
          item
          end
          item
          end
          item
          end
          item
            Caption = 'kiytiotiyt'
          end
          item
          end
          item
          end
          item
          end>
        TabOrder = 0
      end
    end
  end
  object cxDBTreeList1: TcxDBTreeList
    Left = 240
    Top = 8
    Width = 457
    Height = 405
    Bands = <>
    DataController.DataSource = DataSource1
    RootValue = -1
    TabOrder = 2
  end
  object cxDBDateEdit1: TcxDBDateEdit
    Left = 352
    Top = 472
    TabOrder = 3
    Width = 209
  end
  object cxDBCheckBox1: TcxDBCheckBox
    Left = 408
    Top = 560
    Caption = 'cxDBCheckBox1'
    TabOrder = 4
    Width = 121
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
