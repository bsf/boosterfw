unit ReportSetupPresenter;

interface

uses classes, CoreClasses, CustomPresenter, Variants, ReportCatalogConst,
  EntityServiceIntf, Sysutils, DB, ShellIntf, CommonViewIntf;

type

  IReportSetupView = interface(ICustomView)
  ['{C1A91632-304C-413B-B705-69A263CC5DFE}']
    //procedure SetupVisibleTabs();
    procedure SetNoSetupStyle;
    procedure SetDoSetupStyle;
    function GetItemSelection: Variant;
    procedure SetItemSelectionChangedHandler(AHandler: TNotifyEvent);
    procedure SetItemsDataSet(ADataSet: TDataSet);
    procedure SetItemLinksDataSet(ADataSet: TDataSet);
    procedure SetItemLinksLookupDataSet(ADataSet: TDataSet);
  end;

  TReportSetupPresenterData = class(TPresenterData)
  private
    FReportID: string;
    procedure SetReportID(const Value: string);
  published
    property ReportID: string read FReportID write SetReportID;
  end;

  TReportSetupPresenter = class(TCustomPresenter)
  private
    FReportID: string;
    function GetEVItems: IEntityView;
    function GetEVItemLinks: IEntityView;
    function GetEVItemLinksLookup: IEntityView;
    function GetEVItemEditor: IEntityView;
    function View: IReportSetupView;
    procedure ItemSelectedChangedHandler(Sender: TObject);
    procedure EVItemLinksAfterInsert(DataSet: TDataSet);
  protected
    procedure OnInit(Sender: IAction); override;
    procedure OnViewReady; override;
    procedure OnViewClose; override;
  public
    class function ExecuteDataClass: TActionDataClass; override;
  end;


implementation

{ TReportSetupPresenter }

procedure TReportSetupPresenter.ItemSelectedChangedHandler(Sender: TObject);
begin
  View.SetItemLinksDataSet(GetEVItemLinks.DataSet);
  if (not VarIsEmpty(View.GetItemSelection)) and
    (not GetEVItems.DataSet.IsEmpty) and (GetEVItems.Values['EDITOR'] = 'List') then
    View.SetItemLinksLookupDataSet(GetEVItemLinksLookup.DataSet)
    //LinkDataSet('ItemLinksLookup', GetEVItemLinksLookup.DataSet)
  else
    View.SetItemLinksLookupDataSet(nil);
    //View.LinkDataSet('ItemLinksLookup', nil);
end;

procedure TReportSetupPresenter.EVItemLinksAfterInsert(DataSet: TDataSet);
begin
  DataSet['RPT_ID'] := FReportID;
  DataSet['ITEM_ID'] := View.GetItemSelection;
end;

function TReportSetupPresenter.GetEVItemLinks: IEntityView;
begin
  Result := GetEView(ENT_RPT_SETUP, 'ItemLinks', [FReportID, View.GetItemSelection]);
  Result.Reload;
  Result.ImmediateSave := true;
  Result.DataSet.AfterInsert := EVItemLinksAfterInsert;
end;

function TReportSetupPresenter.GetEVItemLinksLookup: IEntityView;
var
  _lookupE: string;
  _lookupEV: string;
begin
  GetEVItemEditor.Reload;
  if GetEVItemEditor.DataSet.Locate('EPRM', 'EntityName', []) then
    _lookupE := GetEVItemEditor.Values['EVAL']
  else
   _lookupE := '';

  if GetEVItemEditor.DataSet.Locate('EPRM', 'EntityViewName', []) then
    _lookupEV := GetEVItemEditor.Values['EVAL'];
  if (_lookupE = '') or (_lookupEV = '') then
    raise Exception.Create('Entity view for lookup not setting!');

  Result := GetEView(_lookupE, _lookupEV, []);
end;

function TReportSetupPresenter.GetEVItems: IEntityView;
begin
  Result := GetEView(ENT_RPT_SETUP, 'Items', [FReportID]);
end;


procedure TReportSetupPresenter.OnInit(Sender: IAction);
begin
  FReportID := WorkItem.State['ReportID'];
  ViewTitle := FReportID;
end;

procedure TReportSetupPresenter.OnViewReady;
begin
  View.SetItemsDataSet(GetEVItems.DataSet);
  //View.LinkDataSet('Items', GetEVItems.DataSet);
  if not GetEVItems.DataSet.IsEmpty then
  begin
    View.SetDoSetupStyle;
    View.SetItemLinksDataSet(GetEVItemLinks.DataSet);
    //View.LinkDataSet('ItemLinks', GetEVItemLinks.DataSet);
    View.SetItemSelectionChangedHandler(ItemSelectedChangedHandler);
    ItemSelectedChangedHandler(nil);
  end
  else
    View.SetNoSetupStyle;
end;

function TReportSetupPresenter.View: IReportSetupView;
begin
  Result := GetView as IReportSetupView;
end;

function TReportSetupPresenter.GetEVItemEditor: IEntityView;
begin
  Result := GetEView(ENT_RPT_SETUP, 'ItemEditor', [FReportID, View.GetItemSelection]);
end;

procedure TReportSetupPresenter.OnViewClose;
begin
  View.SetItemSelectionChangedHandler(nil);
end;

class function TReportSetupPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TReportSetupPresenterData;
end;




{ TReportSetupPresenterData }

procedure TReportSetupPresenterData.SetReportID(const Value: string);
begin
  FReportID := Value;
  PresenterID := Value;
end;

end.
