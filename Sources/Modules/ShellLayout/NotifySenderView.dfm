inherited frNotifySenderView: TfrNotifySenderView
  Caption = 'frNotifySenderView'
  ClientHeight = 330
  ClientWidth = 476
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    Height = 330
    Width = 476
    inherited pnButtons: TcxGroupBox
      Top = 291
      Width = 472
    end
    object cxGroupBox1: TcxGroupBox
      Left = 2
      Top = 2
      Align = alTop
      Caption = #1050#1086#1084#1091
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 1
      Height = 185
      Width = 472
      object lbUsers: TcxCheckListBox
        Left = 2
        Top = 18
        Width = 468
        Height = 165
        Align = alClient
        Columns = 3
        Items = <>
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.LookAndFeel.Kind = lfOffice11
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        TabOrder = 0
      end
    end
    object cxGroupBox2: TcxGroupBox
      Left = 2
      Top = 187
      Align = alClient
      Caption = #1058#1077#1082#1089#1090' '#1091#1074#1077#1076#1086#1084#1083#1077#1085#1080#1103
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 2
      Height = 104
      Width = 472
      object mmText: TcxMemo
        Left = 2
        Top = 18
        Align = alClient
        Style.LookAndFeel.Kind = lfOffice11
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        TabOrder = 0
        Height = 84
        Width = 468
      end
    end
  end
end
