object frCustomView: TfrCustomView
  Left = 694
  Top = 354
  BorderStyle = bsSingle
  Caption = 'frCustomView'
  ClientHeight = 515
  ClientWidth = 670
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ViewControl: TcxGroupBox
    Left = 0
    Top = 0
    Align = alClient
    PanelStyle.Active = True
    PanelStyle.OfficeBackgroundKind = pobkStyleColor
    Style.BorderStyle = ebsNone
    Style.Edges = [bLeft, bTop, bRight, bBottom]
    Style.LookAndFeel.Kind = lfOffice11
    Style.LookAndFeel.NativeStyle = True
    Style.TransparentBorder = False
    StyleDisabled.LookAndFeel.Kind = lfOffice11
    StyleDisabled.LookAndFeel.NativeStyle = True
    StyleFocused.LookAndFeel.Kind = lfOffice11
    StyleFocused.LookAndFeel.NativeStyle = True
    StyleHot.LookAndFeel.Kind = lfOffice11
    StyleHot.LookAndFeel.NativeStyle = True
    TabOrder = 0
    Transparent = True
    Height = 515
    Width = 670
    object pnButtons: TcxGroupBox
      Left = 0
      Top = 0
      Align = alTop
      PanelStyle.Active = True
      PanelStyle.OfficeBackgroundKind = pobkGradient
      Style.BorderStyle = ebsNone
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 0
      Height = 40
      Width = 670
    end
  end
  object ActionList: TActionList
    Left = 62
    Top = 118
  end
end
