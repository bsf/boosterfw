object frShellAbout: TfrShellAbout
  Left = 902
  Top = 562
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'frShellAbout'
  ClientHeight = 210
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 0
    Align = alClient
    PanelStyle.Active = True
    Style.LookAndFeel.Kind = lfUltraFlat
    StyleDisabled.LookAndFeel.Kind = lfUltraFlat
    StyleFocused.LookAndFeel.Kind = lfUltraFlat
    StyleHot.LookAndFeel.Kind = lfUltraFlat
    TabOrder = 0
    DesignSize = (
      394
      210)
    Height = 210
    Width = 394
    object imgLogo: TImage
      Left = 2
      Top = 2
      Width = 390
      Height = 125
      Align = alTop
      Center = True
      Stretch = True
    end
    object lbLogo: TLabel
      Left = 10
      Top = 10
      Width = 216
      Height = 19
      Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1086#1085#1085#1072#1103' '#1057#1080#1089#1090#1077#1084#1072
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbVer: TLabel
      Left = 10
      Top = 32
      Width = 46
      Height = 14
      Caption = 'ver. 1.0.0'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object btClose: TcxButton
      Left = 301
      Top = 170
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      LookAndFeel.Kind = lfOffice11
      TabOrder = 0
      OnClick = btCloseClick
    end
  end
end
