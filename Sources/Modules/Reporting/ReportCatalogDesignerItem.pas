unit ReportCatalogDesignerItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, cxControls, cxContainer, cxEdit,
  cxGroupBox, CoreClasses, ReportCatalogClasses, ShellIntf, Contnrs, Menus,
  ActnList, StdCtrls, cxButtons, ReportServiceIntf, cxGraphics,
  cxLookAndFeels;

type
  TViewCommand = (vcNone, vcSave, vcRefresh, vcOpenTemplate, vcTest);

  TViewCommandHandler = procedure(ViewCommand: TViewCommand) of object;

  IReportCatalogDesignerItemView = interface
  ['{6CE91417-2491-4F18-B925-A98172BC9B77}']
    procedure SetTitle(const Value: string);
    procedure SetCommandHandler(Value: TViewCommandHandler);
  end;

  TReportCatalogDesignerItemPresenter = class(TComponent)
  private
    FWorkItem: TWorkItem;
    FReportCatalog: TReportCatalog;
    FReportCatalogItem: TReportCatalogItem;
    FView: IReportCatalogDesignerItemView;
    FItemID: string;
    procedure ViewCommandHandler(ViewCommand: TViewCommand);
    procedure OpenTemplate;
    procedure Test;
  public
    constructor Create(AOwner: TComponent;
      AView: IReportCatalogDesignerItemView; AWorkItem: TWorkItem;
      AReportCatalog: TReportCatalog; const ItemID: string); reintroduce;
    destructor Destroy; override;
  end;


  TReportCatalogDesignerItemView = class(TForm, IReportCatalogDesignerItemView)
    ViewControl: TcxGroupBox;
    pnButtons: TcxGroupBox;
    btSave: TcxButton;
    btOpenTemplate: TcxButton;
    ActionList: TActionList;
    btTest: TcxButton;
    btRefresh: TcxButton;
    procedure ViewCommandInvoke(Sender: TObject);
  private
    FPresenter: TReportCatalogDesignerItemPresenter;
    FID: string;
    FCommandHandler: TViewCommandHandler;
  protected
    procedure SetTitle(const Value: string);
    procedure SetCommandHandler(Value: TViewCommandHandler);
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem;
      AReportCatalog: TReportCatalog; const ItemID: string); reintroduce;
    property ID: string read FID write FID;
  end;


procedure ShowReportCatalogDesignerItemView(AOwner: TComponent;
  AWorkItem: TWorkItem; AReportCatalog: TReportCatalog; const ItemID: string);

implementation

{$R *.dfm}

var
  ViewList: TComponentList;

procedure ShowReportCatalogDesignerItemView(AOwner: TComponent;
  AWorkItem: TWorkItem; AReportCatalog: TReportCatalog; const ItemID: string);
var
  I: integer;
  Idx: integer;
  ViewID: string;
  View: TReportCatalogDesignerItemView;
begin
  ViewID := IntToStr(integer(AWorkItem)) + IntToStr(integer(AReportCatalog)) +
    ItemID;

  Idx := -1;
  for I := 0 to ViewList.Count - 1 do
    if TReportCatalogDesignerItemView(ViewList[I]).ID = ViewID then
    begin
      Idx := I;
      Break;
    end;

  if Idx = -1 then
  begin
    View := TReportCatalogDesignerItemView.Create(AOwner, AWorkItem,
      AReportCatalog, ItemID);
    View.ID := ViewID;  
    Idx := ViewList.Add(View);
  end;

  View := TReportCatalogDesignerItemView(ViewList[Idx]);

  //AWorkItem.Workspaces[WS_CONTENT].
//  App.ContentWorkspace.Show(View.ViewControl, View.Caption);
end;

{ TReportCatalogDesignerItemView }

constructor TReportCatalogDesignerItemView.Create(AOwner: TComponent;
    AWorkItem: TWorkItem; AReportCatalog: TReportCatalog; const ItemID: string);
begin
  inherited Create(AOwner);
  FPresenter := TReportCatalogDesignerItemPresenter.Create(Self,
    Self, AWorkItem, AReportCatalog, ItemID);

  {acSave.Tag := Ord(vcSave);
  acOpenTemplate.Tag := Ord(vcOpenTemplate);
  acRefresh.Tag := Ord(vcRefresh);
  acTest.Tag := Ord(vcTest);}
end;

procedure TReportCatalogDesignerItemView.SetTitle(const Value: string);
begin
  Caption := Value;
end;

procedure TReportCatalogDesignerItemView.SetCommandHandler(
  Value: TViewCommandHandler);
begin
  FCommandHandler := Value;
end;

procedure TReportCatalogDesignerItemView.ViewCommandInvoke(
  Sender: TObject);
begin
  FCommandHandler(TViewCommand(TAction(Sender).Tag));
end;

{ TReportCatalogDesignerItemPresenter }

constructor TReportCatalogDesignerItemPresenter.Create(AOwner: TComponent;
  AView: IReportCatalogDesignerItemView; AWorkItem: TWorkItem;
  AReportCatalog: TReportCatalog; const ItemID: string);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FReportCatalog := AReportCatalog;
  FView := AView;
  FItemID := ItemID;


  FReportCatalogItem := FReportCatalog.GetItem(FItemID);
  FView.SetTitle('Дизайнер отчета: ' + FItemID);
  FView.SetCommandHandler(ViewCommandHandler);

end;

destructor TReportCatalogDesignerItemPresenter.Destroy;
begin

  inherited;
end;

procedure TReportCatalogDesignerItemPresenter.OpenTemplate;
begin
  IReportService(
    FWorkItem.Services[IReportService]).
      Report[FItemID].Design(FWorkItem);
end;

procedure TReportCatalogDesignerItemPresenter.Test;
begin
  IReportService(
    FWorkItem.Services[IReportService]).
      Report[FItemID].Execute(FWorkItem);
end;

procedure TReportCatalogDesignerItemPresenter.ViewCommandHandler(
  ViewCommand: TViewCommand);
begin
  case ViewCommand of
    vcSave:;
    vcOpenTemplate: OpenTemplate;
    vcRefresh:;
    vcTest: Test;
  end;
end;



initialization
  ViewList := TComponentList.Create(false);

finalization
  ViewList.Free;

end.
