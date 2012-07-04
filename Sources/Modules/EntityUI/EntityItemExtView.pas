unit EntityItemExtView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxSplitter, cxInplaceContainer, cxVGrid, cxDBVGrid,
  EntityItemExtPresenter;

type
  TfrEntityItemExtView = class(TfrCustomContentView, IEntityItemExtView)
    grHeader: TcxDBVerticalGrid;
    cxSplitter1: TcxSplitter;
    grDetails: TcxGrid;
    grDetailsView: TcxGridDBTableView;
    grDetailsLevel1: TcxGridLevel;
    HeadDataSource: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
