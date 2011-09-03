unit ReportCatalogView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, Menus,
  StdCtrls, cxButtons, cxPC, cxSplitter, dxNavBar, dxNavBarCollns,
  cxClasses, dxNavBarBase, cxTextEdit, cxHyperLinkEdit, cxLabel, cxStyles,
  cxInplaceContainer, cxVGrid, cxDBVGrid, DB, ReportCatalogPresenter;


type
  TItemInfo = class(TComponent)
  private
    FID: string;
  end;

  TfrReportCatalogView = class(TfrCustomView, IReportCatalogView)
    pnButtons: TcxGroupBox;
    btCreate: TcxButton;
    btOpen: TcxButton;
    NavBar: TdxNavBar;
    cxSplitter1: TcxSplitter;
    pcItems: TcxPageControl;
    tsCatalogInfo: TcxTabSheet;
    NavBarGroup1: TdxNavBarGroup;
    NavBarGroup2: TdxNavBarGroup;
    NavBarItem1: TdxNavBarItem;
    NavBarItem2: TdxNavBarItem;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    cxTabSheet2: TcxTabSheet;
    CatalogInfoDataSource: TDataSource;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    procedure NavBarLinkClick(Sender: TObject; ALink: TdxNavBarItemLink);
    procedure NavBarActiveGroupChanged(Sender: TObject);
    procedure pcItemsCanClose(Sender: TObject;
      var ACanClose: Boolean);
  private
    function GetItemInfoByLink(ALink: TdxNavBarItemLink): TItemInfo;
    function GetGroupByName(const AName: string): TdxNavBarGroup;
    function GetItemByName(const AGroup, AName: string): TdxNavBarItem;
    function GetItemPageByName(const AGroup, AName: string): TcxTabSheet;
    procedure NavBarSelectedLinkChanged(Sender: TObject);
  protected
    //CustomView
    procedure OnInitialize; override;

    //IReportCatalogView
    procedure ClearAllItems;

    procedure GroupAdd(const AName: string);
    procedure GroupDelete(const AName: string);
    procedure GroupRename(const OldName, NewName: string);
    function GetGroupSelected: string;

    procedure ItemAdd(const AGroup, AName, AID: string);
    procedure ItemDelete(const AGroup, AName: string);
    procedure ItemOpen(const AGroup, AName: string);
    procedure ItemClose(const AGroup, AName: string);

    function GetItemSelected: string;
    function GetItemSelectedID: string;

    procedure SetCatalogInfoDataSet(ADataSet: TDataSet);
  public

    { Public declarations }
  end;


implementation

{$R *.dfm}


{ TfrReportCatalogView }

procedure TfrReportCatalogView.GroupAdd(const AName: string);
var
  _group: TdxNavBarGroup;
begin
  _group := NavBar.Groups.Add;
  _group.Caption := AName;
  _group.OnSelectedLinkChanged := NavBarSelectedLinkChanged;
end;

procedure TfrReportCatalogView.GroupDelete(const AName: string);
var
  _group: TdxNavBarGroup;
  I: integer;
begin
  _group := GetGroupByName(AName);
  if _group <> nil then
  begin
    for I := _group.LinkCount - 1 downto 0 do
      _group.Links[I].Item.Free;
    _group.Free;
  end
end;

function TfrReportCatalogView.GetGroupSelected: string;
begin
  if NavBar.ActiveGroupIndex <> -1 then
    Result := NavBar.Groups[NavBar.ActiveGroupIndex].Caption
  else
    Result := '';
end;

procedure TfrReportCatalogView.GroupRename(const OldName, NewName: string);
begin

end;

procedure TfrReportCatalogView.ClearAllItems;
begin
  NavBar.Groups.Clear;
  NavBar.Items.Clear;
end;

procedure TfrReportCatalogView.ItemAdd(const AGroup, AName, AID: string);
var
  _Item: TdxNavBarItem;
  _ItemInfo: TItemInfo;
  _Group: TdxNavBarGroup;
begin
  _group := GetGroupByName(AGroup);
  if _Group = nil then
    raise Exception.CreateFmt('NavBar Group %s not found', [AGroup]);

  _Item := NavBar.Items.Add;
  _Item.Caption := AName;


  _Group.CreateLink(_Item);
  _ItemInfo := TItemInfo.Create(_Item);
  _ItemInfo.Name := 'ItemLinkInfo';
 _ItemInfo.FID := AID;

end;

procedure TfrReportCatalogView.NavBarLinkClick(Sender: TObject;
  ALink: TdxNavBarItemLink);
begin
  //WorkItem.Commands[GetItemInfoByLink(ALink).FID].Execute;
end;

function TfrReportCatalogView.GetItemInfoByLink(
  ALink: TdxNavBarItemLink): TItemInfo;
begin
  Result := TItemInfo(ALink.Item.FindComponent('ItemLinkInfo'));
end;

procedure TfrReportCatalogView.ItemDelete(const AGroup, AName: string);
var
  _item: TdxNavBarItem;
begin
  _item := GetItemByName(AGroup, AName);

  if _item <> nil then
    _item.Free;
end;

function TfrReportCatalogView.GetItemSelected: string;
var
  _itemLink: TdxNavBarItemLink;
begin
  Result := '';
  _itemLink := NavBar.Groups[NavBar.ActiveGroupIndex].SelectedLink;

  if _itemLink <> nil then
    Result := _itemLink.Item.Caption;
end;

function TfrReportCatalogView.GetGroupByName(
  const AName: string): TdxNavBarGroup;
var
  I: integer;
begin

  for I := 0 to NavBar.Groups.Count - 1 do
  begin
    Result := NavBar.Groups[I];
    if SameText(Result.Caption, AName) then Exit;
  end;

  Result := nil;
end;

function TfrReportCatalogView.GetItemByName(
  const AGroup, AName: string): TdxNavBarItem;
var
  I: integer;
  _group: TdxNavBarGroup;
begin
  _group := GetGroupByName(AGroup);

  for I := 0 to _group.LinkCount - 1 do
  begin
    Result := _group.Links[I].Item;
    if SameText(Result.Caption, AName) then Exit;
  end;

  Result := nil;
end;

procedure TfrReportCatalogView.NavBarActiveGroupChanged(Sender: TObject);
begin
  NavBar.DeSelectLinks;
end;

procedure TfrReportCatalogView.NavBarSelectedLinkChanged(Sender: TObject);
begin
  WorkItem.Commands[COMMAND_ITEM_SELECTED].Execute;
end;

procedure TfrReportCatalogView.OnInitialize;
begin
  {
  WorkItem.Commands[COMMAND_CATALOG_OPEN].AddInvoker(acCatalogOpen, 'OnExecute');
  WorkItem.Commands[COMMAND_GROUP_ADD].AddInvoker(acGroupAdd, 'OnExecute');
  WorkItem.Commands[COMMAND_GROUP_DELETE].AddInvoker(acGroupDelete, 'OnExecute');
  WorkItem.Commands[COMMAND_ITEM_ADD].AddInvoker(acItemAdd, 'OnExecute');
  WorkItem.Commands[COMMAND_ITEM_DELETE].AddInvoker(acItemDelete, 'OnExecute');
   }

end;

procedure TfrReportCatalogView.pcItemsCanClose(Sender: TObject;
  var ACanClose: Boolean);
begin

  ACanClose := pcItems.ActivePage <> tsCatalogInfo;
end;

procedure TfrReportCatalogView.ItemClose(const AGroup, AName: string);
begin

end;

procedure TfrReportCatalogView.ItemOpen(const AGroup, AName: string);
var
  _itemPage: TcxTabSheet;
begin
  _itemPage := GetItemPageByName(AGroup, AName);

  if _itemPage = nil then
  begin
    _itemPage := TcxTabSheet.Create(Self);
    _itemPage.Caption := format(constPageTitleFrm, [AName, AGroup]);
    _itemPage.PageControl := pcItems;
  end;

  pcItems.ActivePage := _itemPage;
end;

function TfrReportCatalogView.GetItemPageByName(const AGroup,
  AName: string): TcxTabSheet;
var
  I: integer;
  _pageTitle: string;
begin
  _pageTitle := format(constPageTitleFrm, [AName, AGroup]);
  for I := 0 to pcItems.PageCount - 1 do
  begin
    Result := pcItems.Pages[I];
    if SameText(Result.Caption, _pageTitle) then Exit;
  end;

  Result := nil;
end;

function TfrReportCatalogView.GetItemSelectedID: string;
var
  _itemLink: TdxNavBarItemLink;
begin
  Result := '';
  _itemLink := NavBar.Groups[NavBar.ActiveGroupIndex].SelectedLink;

  if _itemLink <> nil then
    Result := GetItemInfoByLink(_itemLink).FID;

end;

procedure TfrReportCatalogView.SetCatalogInfoDataSet(ADataSet: TDataSet);
begin
  LinkDataSet(CatalogInfoDataSource, ADataSet);
end;

end.
