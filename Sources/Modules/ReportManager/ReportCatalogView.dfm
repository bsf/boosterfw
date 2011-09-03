inherited frReportCatalogView: TfrReportCatalogView
  Left = 719
  Top = 309
  Caption = 'frReportCatalogView'
  ClientWidth = 908
  OldCreateOrder = True
  ExplicitWidth = 914
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    ExplicitWidth = 908
    Width = 908
    object pnButtons: TcxGroupBox
      Left = 2
      Top = 2
      TabStop = True
      Align = alTop
      PanelStyle.Active = True
      Style.BorderStyle = ebsNone
      Style.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 0
      Height = 40
      Width = 904
      object btCreate: TcxButton
        Left = 125
        Top = 8
        Width = 102
        Height = 25
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 0
      end
      object btOpen: TcxButton
        Left = 13
        Top = 8
        Width = 75
        Height = 25
        Caption = #1055#1077#1088#1077#1095#1080#1090#1072#1090#1100
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 1
      end
      object cxButton1: TcxButton
        Left = 367
        Top = 8
        Width = 102
        Height = 25
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1086#1090#1095#1077#1090
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 2
      end
      object cxButton2: TcxButton
        Left = 235
        Top = 8
        Width = 102
        Height = 25
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 3
      end
      object cxButton3: TcxButton
        Left = 477
        Top = 8
        Width = 102
        Height = 25
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1086#1090#1095#1077#1090
        LookAndFeel.Kind = lfOffice11
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 4
      end
    end
    object NavBar: TdxNavBar
      Left = 2
      Top = 42
      Width = 323
      Height = 471
      Align = alLeft
      ActiveGroupIndex = 0
      TabOrder = 1
      View = 17
      ViewStyle.ColorSchemeName = 'Blue'
      OptionsBehavior.Common.AllowSelectLinks = True
      OptionsView.NavigationPane.ShowOverflowPanel = False
      OnActiveGroupChanged = NavBarActiveGroupChanged
      OnLinkClick = NavBarLinkClick
      object NavBarGroup1: TdxNavBarGroup
        Caption = 'NavBarGroup1'
        SelectedLinkIndex = -1
        TopVisibleLinkIndex = 0
        Links = <
          item
            Item = NavBarItem2
          end
          item
            Item = NavBarItem1
          end>
      end
      object NavBarGroup2: TdxNavBarGroup
        Caption = 'NavBarGroup2'
        SelectedLinkIndex = -1
        TopVisibleLinkIndex = 0
        Links = <>
      end
      object NavBarItem1: TdxNavBarItem
        Caption = 'NavBarItem1'
      end
      object NavBarItem2: TdxNavBarItem
        Caption = 'NavBarItem2'
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 325
      Top = 42
      Width = 8
      Height = 471
      Control = NavBar
    end
    object pcItems: TcxPageControl
      Left = 333
      Top = 42
      Width = 573
      Height = 471
      ActivePage = tsCatalogInfo
      Align = alClient
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      Options = [pcoAlwaysShowGoDialogButton, pcoCloseButton, pcoGoDialog, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize, pcoUsePageColorForTab]
      Style = 8
      TabOrder = 3
      OnCanClose = pcItemsCanClose
      ClientRectBottom = 471
      ClientRectRight = 573
      ClientRectTop = 24
      object tsCatalogInfo: TcxTabSheet
        Caption = #1044#1072#1085#1085#1099#1077' '#1082#1072#1090#1072#1083#1086#1075#1072
        ImageIndex = 0
        object cxDBVerticalGrid1: TcxDBVerticalGrid
          Left = 0
          Top = 0
          Width = 573
          Height = 447
          Align = alClient
          OptionsView.RowHeaderWidth = 163
          OptionsData.Editing = False
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          TabOrder = 0
          DataController.DataSource = CatalogInfoDataSource
          Version = 1
        end
      end
      object cxTabSheet2: TcxTabSheet
        Caption = 'cxTabSheet2'
        ImageIndex = 1
        object cxDBVerticalGrid2: TcxDBVerticalGrid
          Left = 158
          Top = 96
          Width = 150
          Height = 200
          TabOrder = 0
          Version = 1
        end
      end
    end
  end
  inherited ActionList: TActionList
    Left = 38
    Top = 138
  end
  object CatalogInfoDataSource: TDataSource
    Left = 67
    Top = 138
  end
end
