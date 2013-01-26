inherited frEntityDeskMenuView: TfrEntityDeskMenuView
  Caption = 'frEntityDeskMenuView'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ViewControl: TcxGroupBox
    inherited pnButtons: TcxGroupBox
      TabOrder = 1
      Visible = False
    end
    object grMenu: TcxGrid
      Left = 0
      Top = 40
      Width = 670
      Height = 475
      Align = alClient
      BorderStyle = cxcbsNone
      TabOrder = 0
      object grMenuView: TcxGridDBCardView
        OnCellClick = grMenuViewCellClick
        DataController.DataSource = dsItems
        DataController.KeyFieldNames = 'URI'
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        LayoutDirection = ldVertical
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.HideSelection = True
        OptionsSelection.InvertSelect = False
        OptionsSelection.CardBorderSelection = False
        OptionsView.FocusRect = False
        OptionsView.CardAutoWidth = True
        OptionsView.CardIndent = 7
        OptionsView.CellAutoHeight = True
        OptionsView.SeparatorWidth = 0
        object grMenuViewRowTitle: TcxGridDBCardViewRow
          DataBinding.FieldName = 'TITLE'
          PropertiesClassName = 'TcxLabelProperties'
          Properties.Alignment.Horz = taCenter
          Properties.Alignment.Vert = taVCenter
          Properties.WordWrap = True
          Kind = rkCaption
          Options.Focusing = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.LineCount = 5
          Styles.CaptionRow = cxStyle1
          VisibleForCustomization = False
        end
        object grMenuViewRowURI: TcxGridDBCardViewRow
          DataBinding.FieldName = 'URI'
          Visible = False
          Position.BeginsLayer = True
          VisibleForCustomization = False
        end
      end
      object grMenuLevel1: TcxGridLevel
        GridView = grMenuView
      end
    end
  end
  object dsItems: TDataSource
    Left = 72
    Top = 184
  end
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
    end
  end
end
