object frMain: TfrMain
  AlignWithMargins = True
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Load new version'
  ClientHeight = 102
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbInfo: TLabel
    Left = 8
    Top = 8
    Width = 49
    Height = 13
    Caption = 'Loading...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbVerInfo: TLabel
    Left = 8
    Top = 81
    Width = 44
    Height = 13
    Caption = 'lbVerInfo'
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 27
    Width = 424
    Height = 32
    Smooth = True
    TabOrder = 0
  end
  object btUserCancel: TButton
    Left = 357
    Top = 69
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btUserCancelClick
  end
end
