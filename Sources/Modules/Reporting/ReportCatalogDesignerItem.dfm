object ReportCatalogDesignerItemView: TReportCatalogDesignerItemView
  Left = 525
  Top = 345
  Caption = 'ReportCatalogDesignerItemView'
  ClientHeight = 399
  ClientWidth = 754
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
    TabOrder = 0
    Height = 399
    Width = 754
    object pnButtons: TcxGroupBox
      Left = 2
      Top = 2
      Align = alTop
      PanelStyle.Active = True
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 0
      Height = 40
      Width = 750
      object btSave: TcxButton
        Left = 10
        Top = 6
        Width = 75
        Height = 25
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 0
        OnClick = ViewCommandInvoke
      end
      object btOpenTemplate: TcxButton
        Left = 92
        Top = 6
        Width = 75
        Height = 25
        Caption = #1064#1072#1073#1083#1086#1085
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 1
        OnClick = ViewCommandInvoke
      end
      object btTest: TcxButton
        Left = 175
        Top = 6
        Width = 75
        Height = 25
        Caption = #1058#1077#1089#1090
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 2
        OnClick = ViewCommandInvoke
      end
      object btRefresh: TcxButton
        Left = 258
        Top = 6
        Width = 75
        Height = 25
        Caption = #1054#1073#1085#1086#1074#1080#1090#1100
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 3
        OnClick = ViewCommandInvoke
      end
    end
  end
  object ActionList: TActionList
    Left = 16
    Top = 64
  end
end
