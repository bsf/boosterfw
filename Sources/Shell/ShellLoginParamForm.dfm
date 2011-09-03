object frShellLoginParam: TfrShellLoginParam
  Left = 683
  Top = 387
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
  ClientHeight = 183
  ClientWidth = 344
  Color = clBtnFace
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
  object Bevel1: TBevel
    Left = 0
    Top = 137
    Width = 344
    Height = 4
    Align = alBottom
    Shape = bsTopLine
  end
  object Bevel2: TBevel
    Left = 0
    Top = 77
    Width = 344
    Height = 4
    Align = alTop
    Shape = bsTopLine
  end
  object pnButtons: TPanel
    Left = 0
    Top = 141
    Width = 344
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      344
      42)
    object btCancel: TButton
      Left = 255
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = #1047#1072#1082#1088#1099#1090#1100
      ModalResult = 2
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 81
    Width = 344
    Height = 56
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object UserNameLabel: TLabel
      Left = 8
      Top = 9
      Width = 273
      Height = 13
      AutoSize = False
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
      FocusControl = UserNameEdit
      Transparent = True
    end
    object UserNameEdit: TEdit
      Left = 7
      Top = 29
      Width = 328
      Height = 21
      Cursor = crIBeam
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 344
    Height = 77
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label1: TLabel
      Left = 9
      Top = 13
      Width = 230
      Height = 13
      AutoSize = False
      Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1086#1085#1085#1072#1103' '#1073#1072#1079#1072
      FocusControl = UserNameEdit
      Transparent = True
    end
    object CustomCombo: TComboBox
      Left = 8
      Top = 32
      Width = 231
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
    end
    object Button1: TButton
      Left = 258
      Top = 11
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
    end
    object Button2: TButton
      Left = 258
      Top = 42
      Width = 75
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 2
    end
  end
end
