object fmShellLogin: TfmShellLogin
  Left = 900
  Top = 363
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Registration'
  ClientHeight = 300
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
  object LogoLabel: TLabel
    Left = 8
    Top = 8
    Width = 148
    Height = 19
    Caption = 'Information System'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Bevel2: TBevel
    Left = 0
    Top = 254
    Width = 390
    Height = 4
    Align = alBottom
    Shape = bsTopLine
    ExplicitTop = 133
  end
  object pnButtons: TPanel
    Left = 0
    Top = 258
    Width = 390
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 256
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
    Height = 125
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 127
    object UserNameLabel: TLabel
      Left = 14
      Top = 41
      Width = 105
      Height = 13
      AutoSize = False
      Caption = 'User name'
      FocusControl = UserNameEdit
      Transparent = True
    end
    object PasswordLabel: TLabel
      Left = 14
      Top = 73
      Width = 105
      Height = 13
      AutoSize = False
      Caption = 'Password'
      FocusControl = PasswordEdit
      Transparent = True
    end
    object CustomLabel: TLabel
      Left = 14
      Top = 104
      Width = 123
      Height = 13
      AutoSize = False
      Caption = 'Information base'
      FocusControl = CustomCombo
      Transparent = True
    end
    object InfoLabel: TLabel
      Left = 14
      Top = 6
      Width = 168
      Height = 13
      Caption = 'Input your user name and passowrd'
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
