unit ReportCatalogDesigner;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ReportCatalogClasses, CoreClasses, ShellIntf,
  cxLookAndFeelPainters, cxControls, cxContainer, cxEdit, cxGroupBox,
  ReportCatalogDesignerItem, cxGraphics, cxLookAndFeels;

type
  TfrReportCatalogDesigner = class(TForm)
    ViewControl: TcxGroupBox;
  private
    { Private declarations }
  public
    procedure Initialize(AReportCatalog: TReportCatalog);
  end;

  TReportCatalogDesigner = class(TComponent)
  private
    FWorkItem: TWorkItem;
    FReportCatalog: TReportCatalog;
  public
   constructor Create(AOwner: TComponent; AWorkItem: TWorkItem;
      AReportCatalog: TReportCatalog); reintroduce;
    procedure Design(const ItemID: string);
  end;

implementation

{$R *.dfm}

{ TReportCatalogDesigner }

constructor TReportCatalogDesigner.Create(AOwner: TComponent;
  AWorkItem: TWorkItem; AReportCatalog: TReportCatalog);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FReportCatalog := AReportCatalog;
end;

procedure TReportCatalogDesigner.Design(const ItemID: string);
begin
{  if not Assigned(FView) then
  begin
    FView := TfrReportCatalogDesigner.Create(Self);
    FView.Caption := FView.Caption + ':'+ FReportCatalog.Catalog;
    FView.Initialize(FReportCatalog);
  end;

  FWorkItem.Workspaces[WS_CONTENT].Show(FView.ViewControl, FView.Caption);}
  ShowReportCatalogDesignerItemView(Self, FWorkItem, FReportCatalog, ItemID);

end;

{ TfrReportCatalogDesigner }

procedure TfrReportCatalogDesigner.Initialize(
  AReportCatalog: TReportCatalog);
begin

end;

end.
