inherited frNotifySenderView: TfrNotifySenderView
  Caption = 'frNotifySenderView'
  ClientHeight = 330
  ClientWidth = 476
  ExplicitWidth = 482
  ExplicitHeight = 358
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 476
    ExplicitHeight = 330
    Height = 330
    Width = 476
    inherited pnButtons: TcxGroupBox
      Top = 290
      ExplicitTop = 290
      ExplicitWidth = 476
      Width = 476
    end
    object cxGroupBox1: TcxGroupBox
      Left = 0
      Top = 0
      Align = alTop
      Caption = #1050#1086#1084#1091
      PanelStyle.OfficeBackgroundKind = pobkStyleColor
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 1
      ExplicitTop = -6
      Height = 185
      Width = 476
      object lbUsers: TcxCheckListBox
        Left = 2
        Top = 18
        Width = 472
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
      Left = 0
      Top = 185
      Align = alClient
      Caption = #1058#1077#1082#1089#1090' '#1091#1074#1077#1076#1086#1084#1083#1077#1085#1080#1103
      PanelStyle.OfficeBackgroundKind = pobkStyleColor
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 2
      Height = 105
      Width = 476
      object mmText: TcxMemo
        Left = 2
        Top = 18
        Align = alClient
        Style.LookAndFeel.Kind = lfOffice11
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        TabOrder = 0
        Height = 85
        Width = 472
      end
    end
  end
end
