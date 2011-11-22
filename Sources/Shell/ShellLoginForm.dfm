object fmShellLogin: TfmShellLogin
  Left = 900
  Top = 363
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #1056#1077#1075#1080#1089#1090#1088#1072#1094#1080#1103
  ClientHeight = 298
  ClientWidth = 390
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object imgLogo: TImage
    Left = 0
    Top = 0
    Width = 390
    Height = 125
    Align = alTop
    Center = True
    Stretch = True
    ExplicitWidth = 385
  end
  object Bevel1: TBevel
    Left = 0
    Top = 125
    Width = 390
    Height = 4
    Align = alTop
    Shape = bsTopLine
    ExplicitTop = 123
    ExplicitWidth = 387
  end
  object lbVer: TLabel
    Left = 10
    Top = 32
    Width = 45
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
  object pnButtons: TPanel
    Left = 0
    Top = 256
    Width = 390
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      390
      42)
    object btOK: TButton
      Left = 216
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btOKClick
    end
    object btCancel: TButton
      Left = 300
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnClient: TPanel
    Left = 0
    Top = 129
    Width = 390
    Height = 127
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object UserNameLabel: TLabel
      Left = 14
      Top = 41
      Width = 105
      Height = 13
      AutoSize = False
      Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      FocusControl = UserNameEdit
      Transparent = True
    end
    object PasswordLabel: TLabel
      Left = 14
      Top = 73
      Width = 105
      Height = 13
      AutoSize = False
      Caption = #1055#1072#1088#1086#1083#1100
      FocusControl = PasswordEdit
      Transparent = True
    end
    object CustomLabel: TLabel
      Left = 14
      Top = 104
      Width = 123
      Height = 13
      AutoSize = False
      Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1086#1085#1085#1072#1103' '#1073#1072#1079#1072
      FocusControl = CustomCombo
      Transparent = True
    end
    object Label1: TLabel
      Left = 14
      Top = 6
      Width = 240
      Height = 13
      Caption = #1042#1074#1077#1076#1080#1090#1077' '#1074#1072#1096#1077' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1086#1077' '#1080#1084#1103' '#1080' '#1087#1072#1088#1086#1083#1100
    end
    object UserNameEdit: TEdit
      Left = 144
      Top = 37
      Width = 231
      Height = 21
      Cursor = crIBeam
      TabOrder = 0
    end
    object PasswordEdit: TEdit
      Left = 144
      Top = 69
      Width = 231
      Height = 21
      Cursor = crIBeam
      PasswordChar = '*'
      TabOrder = 1
    end
    object CustomCombo: TComboBox
      Left = 144
      Top = 99
      Width = 231
      Height = 21
      Style = csDropDownList
      Sorted = True
      TabOrder = 2
    end
  end
end
