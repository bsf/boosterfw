inherited frfrReportPreviewView: TfrfrReportPreviewView
  Caption = 'frfrReportPreviewView'
  ClientHeight = 525
  ClientWidth = 933
  ExplicitWidth = 939
  ExplicitHeight = 553
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 933
    ExplicitHeight = 525
    Height = 525
    Width = 933
    object pnButtons: TcxGroupBox
      Left = 2
      Top = 2
      Align = alTop
      PanelStyle.Active = True
      PanelStyle.OfficeBackgroundKind = pobkGradient
      Style.BorderStyle = ebsNone
      Style.LookAndFeel.Kind = lfOffice11
      Style.TransparentBorder = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 0
      Height = 40
      Width = 929
      object btClose: TcxButton
        Left = 4
        Top = 9
        Width = 75
        Height = 25
        Caption = #1047#1072#1082#1088#1099#1090#1100
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 0
      end
      object btPrint: TcxButton
        Left = 85
        Top = 9
        Width = 109
        Height = 25
        Caption = #1041#1099#1089#1090#1088#1072#1103' '#1087#1077#1095#1072#1090#1100
        DropDownMenu = ppmPrint
        Kind = cxbkDropDownButton
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 1
      end
      object btExport: TcxButton
        Left = 281
        Top = 9
        Width = 75
        Height = 25
        Caption = 'Excel'
        DropDownMenu = ppmExport
        Kind = cxbkDropDownButton
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 2
      end
      object btZoom: TcxButton
        Left = 200
        Top = 9
        Width = 75
        Height = 25
        Caption = 'Zoom'
        DropDownMenu = ppmZoome
        Kind = cxbkDropDown
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 3
      end
      object btPagePrior: TcxButton
        Left = 407
        Top = 9
        Width = 39
        Height = 25
        Caption = '<'
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 4
      end
      object btPageNext: TcxButton
        Left = 452
        Top = 9
        Width = 39
        Height = 25
        Caption = '>'
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 5
      end
      object lbPages: TcxLabel
        Left = 542
        Top = 10
        Caption = 'lbPages'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -16
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.LookAndFeel.Kind = lfOffice11
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        Transparent = True
      end
      object btPageFirst: TcxButton
        Left = 362
        Top = 9
        Width = 39
        Height = 25
        Caption = '<<'
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 7
      end
      object btPageLast: TcxButton
        Left = 497
        Top = 9
        Width = 39
        Height = 25
        Caption = '>>'
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 8
      end
    end
    object frxPreview: TfrxPreview
      Left = 2
      Top = 42
      Width = 929
      Height = 481
      Align = alClient
      BackColor = clWhite
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      OutlineVisible = False
      OutlineWidth = 120
      ThumbnailVisible = False
      OnClick = frxPreviewClick
      OnPageChanged = frxPreviewPageChanged
      UseReportHints = True
    end
  end
  inherited ActionList: TActionList
    Top = 206
  end
  object ppmPrint: TPopupMenu
    Left = 136
    Top = 56
    object miPrintDef: TMenuItem
      Caption = #1041#1099#1089#1090#1088#1072#1103' '#1087#1077#1095#1072#1090#1100
      Default = True
    end
    object miPrint: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100'...'
    end
  end
  object ppmZoome: TPopupMenu
    Left = 224
    Top = 56
    object miZoom25: TMenuItem
      Tag = 25
      Caption = '25%'
      OnClick = miZoomClick
    end
    object miZoom50: TMenuItem
      Tag = 50
      Caption = '50%'
      OnClick = miZoomClick
    end
    object miZoom75: TMenuItem
      Tag = 75
      Caption = '75%'
      OnClick = miZoomClick
    end
    object miZoom100: TMenuItem
      Tag = 100
      Caption = '100%'
      OnClick = miZoomClick
    end
    object miZoom150: TMenuItem
      Tag = 150
      Caption = '150%'
      OnClick = miZoomClick
    end
    object miZoom200: TMenuItem
      Tag = 200
      Caption = '200%'
      OnClick = miZoomClick
    end
    object miZoomPageWidth: TMenuItem
      Tag = 2
      Caption = #1055#1086' '#1096#1080#1088#1080#1085#1077
      OnClick = miZoomModeClick
    end
    object miZoomWholePage: TMenuItem
      Tag = 1
      Caption = #1057#1090#1088#1072#1085#1080#1094#1072' '#1094#1077#1083#1080#1082#1086#1084
      OnClick = miZoomModeClick
    end
  end
  object ppmExport: TPopupMenu
    Left = 304
    Top = 56
    object miExportExcel: TMenuItem
      Caption = #1044#1086#1082#1091#1084#1077#1085#1090' Excel'
    end
    object miExportPDF: TMenuItem
      Caption = #1044#1086#1082#1091#1084#1077#1085#1090' PDF'
    end
    object miExportHTML: TMenuItem
      Caption = #1044#1086#1082#1091#1084#1077#1085#1090' HTML'
    end
    object miExportCSV: TMenuItem
      Caption = 'CSV '#1092#1072#1081#1083
    end
  end
end
