unit ReportCatalogPresenter;

interface
uses classes, CoreClasses, CustomPresenter, ShellIntf, CommonViewIntf, SysUtils,
  db, ReportCatalogConst, ReportCatalogClasses, dxMdaset,
  CommonUtils, ReportServiceIntf;

const
  constPageTitleFrm = '%s [%s]';

  COMMAND_CATALOG_OPEN = '{B0691B3F-0D2A-4B4C-A94B-82E9A09499D5}';
  COMMAND_GROUP_ADD = '{2D88CC92-73C0-4439-B663-218D1948FB75}';
  COMMAND_GROUP_DELETE = '{CB8251BF-D8F2-41FD-A46A-2BAF570FADEF}';
  COMMAND_ITEM_ADD = '{550F2507-C90D-4BAE-B8EF-4ED3B99CCD49}';
  COMMAND_ITEM_DELETE = '{E81ECAA3-5F4C-4D10-89AE-B22D2B37EE62}';
  COMMAND_ITEM_SELECTED = '{7A410ABB-001F-49A1-A998-F6BC3916C961}';
  COMMAND_ITEM_CLOSE = '{E858FFB3-FA6B-4A2E-A8EB-6A9154DDD1B8}';

  WS_ITEMS = '{2CD8D07E-24B5-4B1B-9298-990D814A4CA9}';

type
  IReportCatalogView = interface
  ['{4D0DA5C1-913F-40EA-9655-AB891177AC9E}']
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
  end;

  TDataFieldClass = class of TField;

  TReportCatalogPresenter = class(TCustomPresenter)
  private
    FCatalogData: TdxMemData;
    FCatalog: TReportCatalog;
    function View: IReportCatalogView;
    procedure CmdCatalogOpen(Sender: TObject);
    procedure CmdGroupAdd(Sender: TObject);
    procedure CmdGroupDelete(Sender: TObject);
    procedure CmdItemAdd(Sender: TObject);
    procedure CmdItemDelete(Sender: TObject);
    procedure CmdItemSelected(Sender: TObject);

    procedure CatalogDataInit;
  protected
    procedure OnInit(Sender: IAction); override;
    procedure OnViewReady; override;
  end;


implementation

{ TReportCatalogPresenter }

procedure TReportCatalogPresenter.CmdGroupAdd(Sender: TObject);
var
  _groupName: string;
begin
  if not App.UI.InputBox.InputString('Наименование группы', _groupName) then Exit;

  FCatalog.Groups.Add(_groupName);
  View.GroupAdd(_groupName);
end;


procedure TReportCatalogPresenter.CmdCatalogOpen(Sender: TObject);
var
  _catalogPath: string;
  I, Y: integer;
begin
  _catalogPath := App.Settings['Reports.Path'];
  if _catalogPath = '' then
    _catalogPath := ExtractFilePath(ParamStr(0)) + 'Reports\';

  FCatalog.Open(_catalogPath);

 { FCatalogData.Edit;
  FCatalogData['Path'] := _catalogPath;
  FCatalogData.Post;}

  View.ClearAllItems;
  for I := 0 to FCatalog.Groups.Count - 1 do
  begin
    View.GroupAdd(FCatalog.Groups[I].Caption);
    for Y := 0 to FCatalog.Groups[I].Items.Count - 1 do
      View.ItemAdd(FCatalog.Groups[I].Caption,
        FCatalog.Groups[I].Items[Y].Caption, FCatalog.Groups[I].Items[Y].id);
  end;
end;

procedure TReportCatalogPresenter.CmdItemAdd(Sender: TObject);
var
  _itemName: string;
  _groupName: string;
  _group: TReportCatalogGroup;
begin
  _groupName := View.GetGroupSelected;
  if _groupName = '' then Exit;

  if not App.UI.InputBox.InputString('Наименование отчета', _itemName) then Exit;

  _group := FCatalog.Groups.Find(_groupName);

  _group.Items.Add(_itemName);
  View.ItemAdd(_groupName, _itemName, '');

end;

procedure TReportCatalogPresenter.OnInit(Sender: IAction);
begin

  ViewTitle := VIEW_RPT_CATALOG_CAPTION;
  FCatalog := TReportCatalog.Create(Self);

  FCatalogData := TdxMemData.Create(Self);
  CatalogDataInit;
end;

procedure TReportCatalogPresenter.OnViewReady;
begin
  WorkItem.Commands[COMMAND_CATALOG_OPEN].SetHandler(CmdCatalogOpen);
  WorkItem.Commands[COMMAND_GROUP_ADD].SetHandler(CmdGroupAdd);
  WorkItem.Commands[COMMAND_GROUP_DELETE].SetHandler(CmdGroupDelete);
  WorkItem.Commands[COMMAND_ITEM_ADD].SetHandler(CmdItemAdd);
  WorkItem.Commands[COMMAND_ITEM_DELETE].SetHandler(CmdItemDelete);
  WorkItem.Commands[COMMAND_ITEM_DELETE].Status := csDisabled;
  //SetCommandStatus(COMMAND_ITEM_DELETE, false);

  WorkItem.Commands[COMMAND_ITEM_SELECTED].SetHandler(CmdItemSelected);

  CmdCatalogOpen(nil);
  (GetView as IReportCatalogView).SetCatalogInfoDataSet(FCatalogData);
  //.LinkDataSet('CatalogInfo', FCatalogData);
end;

function TReportCatalogPresenter.View: IReportCatalogView;
begin
  Result := GetView as IReportCatalogView;
end;

procedure TReportCatalogPresenter.CmdGroupDelete(Sender: TObject);
var
  _groupName: string;
begin
  _groupName := View.GetGroupSelected;
  if _groupName = '' then Exit;
  if not App.UI.MessageBox.ConfirmYesNo('Удалить группу отчетов?') then Exit;

  FCatalog.Groups.Delete(FCatalog.Groups.Find(_groupName).Index);
  View.GroupDelete(_groupName);

end;

procedure TReportCatalogPresenter.CmdItemDelete(Sender: TObject);
var
  _itemName: string;
  _group: TReportCatalogGroup;
begin
  _itemName := View.GetItemSelected;

  if _itemName = '' then Exit;
  if not App.UI.MessageBox.ConfirmYesNo('Удалить отчет?') then Exit;

  _group := FCatalog.Groups.Find(View.GetGroupSelected);

  _group.Items.Delete(_group.Items.Find(_itemName).Index);
  View.ItemDelete(_group.Name, _itemName);
end;


procedure TReportCatalogPresenter.CmdItemSelected(Sender: TObject);
var
  _itemName, _itemID: string;
begin
  _itemName := View.GetItemSelected;
  _itemID := View.GetItemSelectedID;
  if _itemName <> '' then
    WorkItem.Commands[COMMAND_ITEM_DELETE].Status := csEnabled
  else
    WorkItem.Commands[COMMAND_ITEM_DELETE].Status := csDisabled;
  //SetCommandStatus(COMMAND_ITEM_DELETE, _itemName <> '');

  if _itemName <> '' then
    if IsControlKeyDown then
      IReportService(
        WorkItem.Services[IReportService]).
          Report[_itemID].Design(WorkItem)
    else
      View.ItemOpen(View.GetGroupSelected, _itemName);
end;

procedure TReportCatalogPresenter.CatalogDataInit;
begin
  FCatalogData.Open;
  FCatalogData.Insert;
  FCatalogData.Post;
end;

end.
