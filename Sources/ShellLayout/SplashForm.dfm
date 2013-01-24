object frShellSplash: TfrShellSplash
  Left = 898
  Top = 429
  BorderStyle = bsNone
  BorderWidth = 1
  Caption = 'frShellSplash'
  ClientHeight = 144
  ClientWidth = 390
  Color = clBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 390
    Height = 144
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object imgLogo: TImage
      Left = 0
      Top = 0
      Width = 390
      Height = 125
      Align = alClient
      Center = True
      Stretch = True
      ExplicitWidth = 385
      ExplicitHeight = 123
    end
    object lbLogo: TLabel
      Left = 10
      Top = 10
      Width = 229
      Height = 20
      Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1086#1085#1085#1072#1103' '#1057#1080#1089#1090#1077#1084#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbVer: TLabel
      Left = 10
      Top = 32
      Width = 45
      Height = 13
      Caption = 'ver. 1.0.0'
      Transparent = True
    end
    object lbInfoText: TLabel
      Left = 0
      Top = 125
      Width = 3
      Height = 13
      Align = alBottom
      Alignment = taCenter
    end
    object ProgressBar: TProgressBar
      Left = 0
      Top = 138
      Width = 390
      Height = 6
      Align = alBottom
      Smooth = True
      TabOrder = 0
    end
  end
end
