object frMain: TfrMain
  Left = 741
  Top = 208
  Caption = 'frMain'
  ClientHeight = 555
  ClientWidth = 993
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  ShowHint = True
  Visible = True
  WindowState = wsMaximized
  OnCloseQuery = FormCloseQuery
  OnKeyUp = FormKeyUp
  OnMouseWheel = FormMouseWheel
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object BarStatus: TdxStatusBar
    Left = 0
    Top = 535
    Width = 993
    Height = 20
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Bevel = dxpbNone
        Fixed = False
      end
      item
        PanelStyleClassName = 'TdxStatusBarContainerPanelStyle'
        PanelStyle.Container = BarStatusContainer1
        Bevel = dxpbNone
        Visible = False
        Width = 100
      end
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Bevel = dxpbNone
        Width = 20
      end>
    PaintStyle = stpsOffice11
    SizeGrip = False
    LookAndFeel.Kind = lfOffice11
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    object BarStatusContainer1: TdxStatusBarContainerControl
      Left = 506
      Top = 1
      Width = 102
      Height = 18
      object WaitProgressBar: TcxProgressBar
        Left = 0
        Top = 0
        TabStop = False
        Align = alClient
        Properties.AnimationRestartDelay = 1
        Properties.AnimationSpeed = 1
        Properties.BarStyle = cxbsAnimation
        Properties.BeginColor = clBlue
        Properties.ShowTextStyle = cxtsText
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        Style.LookAndFeel.Kind = lfOffice11
        Style.TransparentBorder = True
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        TabOrder = 0
        Transparent = True
        Width = 102
      end
    end
  end
  object NavBar: TdxNavBar
    Left = 0
    Top = 0
    Width = 299
    Height = 535
    ParentCustomHint = False
    Align = alLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ActiveGroupIndex = -1
    TabOrder = 1
    View = 13
    OptionsBehavior.Common.DragDropFlags = [fAllowDragLink, fAllowDropLink, fAllowDropGroup]
    OptionsBehavior.Common.ShowGroupsHint = True
    OptionsBehavior.Common.ShowLinksHint = True
    OptionsBehavior.NavigationPane.AllowCustomizing = False
    OptionsBehavior.NavigationPane.Collapsible = True
    OptionsImage.LargeImages = ilNavBarLarge
    OptionsImage.SmallImages = ilNavBarSmall
    OptionsView.Common.ShowGroupCaptions = False
    OptionsView.NavigationPane.OverflowPanelUseSmallImages = False
    OptionsView.NavigationPane.ShowActiveGroupCaptionWhenCollapsed = True
    OptionsView.NavigationPane.ShowOverflowPanel = False
  end
  object SplitterLeft: TcxSplitter
    Left = 299
    Top = 0
    Width = 8
    Height = 535
    HotZoneClassName = 'TcxXPTaskBarStyle'
    Control = NavBar
  end
  object Panel1: TPanel
    Left = 307
    Top = 0
    Width = 686
    Height = 535
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnMain'
    TabOrder = 3
    object SplitterNotifyPanel: TcxSplitter
      Left = 0
      Top = 403
      Width = 686
      Height = 4
      AlignSplitter = salBottom
      AutoSnap = True
      Control = cxGroupBox1
    end
    object pcMain: TcxPageControl
      Left = 0
      Top = 0
      Width = 686
      Height = 403
      Align = alClient
      Color = clBtnFace
      Focusable = False
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      ParentColor = False
      Style = 9
      TabOrder = 1
      ExplicitLeft = -2
      ExplicitTop = -2
      ClientRectBottom = 403
      ClientRectRight = 686
      ClientRectTop = 0
    end
    object cxGroupBox1: TcxGroupBox
      Left = 0
      Top = 407
      Align = alBottom
      Caption = #1059#1074#1077#1076#1086#1084#1083#1077#1085#1080#1103
      PanelStyle.OfficeBackgroundKind = pobkGradient
      ParentFont = False
      Style.BorderStyle = ebsOffice11
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'MS Sans Serif'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.Kind = lfOffice11
      TabOrder = 2
      Height = 128
      Width = 686
      object grNotify: TcxGrid
        Left = 2
        Top = 18
        Width = 682
        Height = 108
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = cxcbsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TabStop = False
        LookAndFeel.Kind = lfOffice11
        object grNotifyListView: TcxGridTableView
          NavigatorButtons.ConfirmDelete = False
          OnCellDblClick = grNotifyListViewCellDblClick
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          DataController.OnAfterDelete = grNotifyListViewDataControllerAfterDelete
          DataController.OnBeforeDelete = grNotifyListViewDataControllerBeforeDelete
          OptionsBehavior.PullFocusing = True
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.InvertSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.CellAutoHeight = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Header = False
          OptionsView.RowSeparatorColor = clWhite
          OptionsView.RowSeparatorWidth = 3
          Preview.Column = grNotifyListViewText
          Preview.Visible = True
          Styles.Background = cxStyleInfoBk
          object grNotifyListViewHeader: TcxGridColumn
          end
          object grNotifyListViewText: TcxGridColumn
            Width = 313
          end
          object grNotifyListViewID: TcxGridColumn
            Visible = False
            VisibleForCustomization = False
          end
          object grNotifyListViewSENDER: TcxGridColumn
            Visible = False
            VisibleForCustomization = False
            Width = 236
          end
          object grNotifyListViewTime: TcxGridColumn
            DataBinding.ValueType = 'DateTime'
            Visible = False
            VisibleForCustomization = False
            Width = 185
          end
        end
        object grNotifyLevel1: TcxGridLevel
          GridView = grNotifyListView
        end
      end
    end
  end
  object ilNavBarLarge: TcxImageList
    Height = 24
    Width = 24
    FormatVersion = 1
    DesignInfo = 3539000
  end
  object cxStyleRepositoryShellForm: TcxStyleRepository
    Left = 60
    Top = 110
    PixelsPerInch = 96
    object cxStyleInfoBk: TcxStyle
      AssignedValues = [svColor]
      Color = clInfoBk
    end
    object cxStyleNotifyCellTime: TcxStyle
    end
    object cxStyleNotifyCellText: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
  end
  object ilNavBarSmall: TImageList
    Left = 128
    Top = 56
  end
end
