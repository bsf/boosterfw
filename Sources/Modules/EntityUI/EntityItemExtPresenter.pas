unit EntityItemExtPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr, strUtils;

const
  COMMAND_DETAIL_DELETE = 'commands.Detail.Delete';
  COMMAND_PICK_PANEL_SHOW = 'commands.PickPanel.Show';
  COMMAND_PICK_PANEL_HIDE = '{BA085EFD-77DA-436C-92E9-F82B26CDC2DA}';
  COMMAND_PICK_SEARCH = '{5029AB50-DE3D-4862-BC74-8DBC02C3BBF1}';
  COMMAND_PICK_ITEM_SELECTED = '{3978566F-7545-4D8E-AE70-56087488CE1F}';
  COMMAND_PICK_ITEM_ADD = '{B52AA2E3-CD8F-4227-AD88-43A4BF2833EC}';
  COMMAND_PICK_ITEM_CANCEL = '{D1F2BB98-B868-493E-B110-7AC9D79E6BD4}';

type
  IEntityItemExtView = interface(IContentView)
  ['{F2CB6C89-5688-4566-A972-5D787A528C0C}']
    procedure LinkHeadData(AData: TDataSet);
    procedure LinkDetailData(const AName, ACaption: string; AData: TDataSet);
    procedure LinkPickListData(AData: TDataSet);
    procedure LinkPickItemData(AData: TDataSet);
    function GetActiveDetailData: string;
    procedure ShowPickPanel;
    procedure HidePickPanel;
    procedure ShowPickItemPanel;
    procedure HidePickItemPanel;
    procedure SetPickBulkMode;
    function GetPickSeartText: string;
    function PickListSelection: ISelection;
  end;

  TEntityItemExtPresenter = class(TEntityContentPresenter)
  const
    CMD_CLOSE = 'cmd.Close';
  private
    FIsReady: boolean;
    FHeadEntityViewReady: boolean;
    FEVDetailList: TStringList;
    FPickBulkMode: boolean;
    procedure CmdReload(Sender: Tobject);
    procedure CmdDetailDelete(Sender: TObject);
    procedure CmdPickPanelShow(Sender: TObject);
    procedure CmdPickPanelHide(Sender: TObject);
    procedure CmdPickSearch(Sender: TObject);
    procedure CmdPickItemSelected(Sender: TObject);
    procedure CmdPickItemAdd(Sender: TObject);
    procedure CmdPickItemCancel(Sender: TObject);

    function View: IEntityItemExtView;
    function GetEVHead: IEntityView;
    function GetEVDetailEViews: IEntityView;
    function GetEVDetail(const AName: string): IEntityView;
    function GetEVPickList: IEntityView;
    function GetEVPickItem: IEntityView;
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;
  public
    destructor Destroy; override;
  end;

implementation

{ TEntityItemExtPresenter }

procedure TEntityItemExtPresenter.CmdDetailDelete(Sender: TObject);
var
  cResult: boolean;
  evDetail: IEntityView;
begin
  cResult := App.UI.MessageBox.ConfirmYesNo('”далить выделенные записи?');
  if cResult then
  begin
    try
      evDetail := GetEVDetail(View.GetActiveDetailData);
      evDetail.DataSet.Delete;
      evDetail.Save;
    except
      evDetail.CancelUpdates;
      raise;
    end;
  end;


end;

procedure TEntityItemExtPresenter.CmdPickPanelHide(Sender: TObject);
begin
  WorkItem.Commands[COMMAND_PICK_SEARCH].Status := csDisabled;
  View.LinkPickItemData(nil);
  View.HidePickItemPanel;
  View.HidePickPanel;
end;

procedure TEntityItemExtPresenter.CmdPickItemAdd(Sender: TObject);
begin
  if not FPickBulkMode then
  begin
    GetEVPickItem.Save;
    View.HidePickItemPanel;
  end;
  WorkItem.Commands[COMMAND_PICK_ITEM_ADD].Status := csDisabled;
  WorkItem.Commands[COMMAND_PICK_ITEM_CANCEL].Status := csDisabled;
end;

procedure TEntityItemExtPresenter.CmdPickItemCancel(Sender: TObject);
begin
  View.HidePickItemPanel;
  View.ShowPickPanel;
  WorkItem.Commands[COMMAND_PICK_ITEM_ADD].Status := csDisabled;
  WorkItem.Commands[COMMAND_PICK_ITEM_CANCEL].Status := csDisabled;
end;

procedure TEntityItemExtPresenter.CmdPickSearch(Sender: TObject);
var
  searchText: string;
begin
  searchText := Trim(View.GetPickSeartText);
  if searchText = '' then
    WorkItem.State['PICK_SEARCH'] := null
  else
    WorkItem.State['PICK_SEARCH'] := searchText;
  GetEVPickList.Load(true);
end;

procedure TEntityItemExtPresenter.CmdPickItemSelected(Sender: TObject);
var
  fieldAux: TField;
  focusField: string;
  ds: TDataSet;
begin
  WorkItem.Commands[COMMAND_PICK_ITEM_ADD].Status := csEnabled;
  WorkItem.Commands[COMMAND_PICK_ITEM_CANCEL].Status := csEnabled;

  if not FPickBulkMode then
  begin
    ds := GetEVPickItem.Load(true);
    View.LinkPickItemData(ds);
    GetEVPickItem.DoModify;
    View.ShowPickItemPanel;

    focusField := '';
    fieldAux := ds.FindField(FIELD_UI_FIRST_FOCUS);
    if Assigned(fieldAux) then
      focusField := VarToStr(fieldAux.Value);

    View.FocusDataSetControl(ds, focusField);
  end
  else
    WorkItem.Commands[COMMAND_PICK_ITEM_ADD].Execute;
end;

procedure TEntityItemExtPresenter.CmdPickPanelShow(Sender: TObject);
begin
  WorkItem.State['PICK_SEARCH'] := null;
  WorkItem.Commands[COMMAND_PICK_SEARCH].Status := csEnabled;
  View.ShowPickPanel;
  GetEVPickList.Load(true);
  View.LinkPickListData(GetEVPickList.DataSet);
end;

procedure TEntityItemExtPresenter.CmdReload(Sender: Tobject);
var
  I: integer;
begin
  GetEVHead.ReloadRecord(WorkItem.State['ID']);

  for I := 0 to FEVDetailList.Count - 1 do
    GetEVDetail(FEVDetailList[I]).Load(true);

  UpdateCommandStatus;
end;

destructor TEntityItemExtPresenter.Destroy;
begin
  if Assigned(FEVDetailList) then
    FEVDetailList.Free;
  inherited;
end;

function TEntityItemExtPresenter.GetEVDetail(const AName: string): IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView(AName, WorkItem);

  Result.Load(false);

end;

function TEntityItemExtPresenter.GetEVDetailEViews: IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView('DetailEViews', WorkItem);

  Result.Load(false);
end;

function TEntityItemExtPresenter.GetEVHead: IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView(EntityViewName, WorkItem);
  Result.Load(false);
  FHeadEntityViewReady := true;
end;

function TEntityItemExtPresenter.GetEVPickItem: IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView('DetailsPickItem', WorkItem);


  Result.Load(false);
end;

function TEntityItemExtPresenter.GetEVPickList: IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView('DetailsPickList', WorkItem);

  Result.Load(false);

end;

function TEntityItemExtPresenter.OnGetWorkItemState(const AName: string;
  var Done: boolean): Variant;
var
  ds: TDataSet;
  fieldName: string;
begin

  Result := inherited;

  if Done then Exit;

  if SameText(AName, 'HID') then
  begin
    Result := WorkItem.State['ID'];
    Done := true;
    Exit;
  end;

  if SameText(AName, 'ACTIVE_DETAIL') then
  begin
    Result := View.GetActiveDetailData;
    Done := true;
    Exit;
  end;

  if FIsReady and AnsiStartsText('Detail.', AName) then
  begin
    fieldName := StringReplace(AName, 'Detail.', '', [rfIgnoreCase]);
    Result := inherited OnGetWorkItemState('EV.' + WorkItem.State['ACTIVE_DETAIL'] + '.' + fieldName, Done);
    Done := true;
    Exit;
  end;

  if FHeadEntityViewReady then
  begin
    ds := App.Entities[EntityName].GetView(EntityViewName, WorkItem).DataSet;  //Result := GetEVItem.Values['ID']; –≈ ”–—»я !!!}
    if ds.FindField(AName) <> nil then
    begin
      Result := ds[AName];
      Done := true;
      Exit;
    end;
  end;

  if SameText(AName, 'PICK_ID') then
  begin
    Result := View.PickListSelection.First;
    Done := true;
    Exit;
  end;
end;

procedure TEntityItemExtPresenter.OnViewReady;

  procedure GetDetailEViews(AList: TStringList);
  var
    ds: TDataSet;
  begin
    if ViewInfo.OptionExists('DetailEViews') then
    begin
       ExtractStrings([','], [], PWideChar(ViewInfo.OptionValue('DetailEViews')), AList);
    end;

    if App.Entities.EntityViewExists(EntityName, 'DetailEViews') then
    begin
      ds := GetEVDetailEViews.DataSet;
      while not ds.Eof do
      begin
        AList.Add(ds.Fields[0].asString);
        ds.Next;
      end;
    end
    else if App.Entities.EntityViewExists(EntityName, 'Details') then
      AList.Add('Details');

  end;

  procedure DetailViewsInit;
  var
    entityView: IEntityView;
    I: integer;
  begin
    GetDetailEViews(FEVDetailList);
    for I := 0 to FEVDetailList.Count - 1 do
    begin
      entityView := GetEVDetail(FEVDetailList[I]);
      entityView.ImmediateSave := true;
      View.LinkDetailData(entityView.ViewName, entityView.Info.Title, entityView.DataSet);
      GetEVHead.SynchronizeOnEntityChange(entityView.EntityName, entityView.ViewName, 'HID');
    end;
  end;

var
  fieldTitle: TField;
begin
  FEVDetailList := TStringList.Create;
  ViewTitle := ViewInfo.Title;

  fieldTitle := GetEVHead.DataSet.FindField('UI_TITLE');
  if not Assigned(fieldTitle) then
    fieldTitle := GetEVHead.DataSet.FindField('NAME');

  if Assigned(fieldTitle) and (VarToStr(fieldTitle.Value) <> '') then
    ViewTitle := VarToStr(fieldTitle.Value);

//----------------- CommandBar
  View.CommandBar.
    AddCommand(CMD_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);

  WorkItem.Commands[CMD_CLOSE].SetHandler(CmdClose);

  WorkItem.Commands[COMMAND_RELOAD].SetHandler(CmdReload);

  WorkItem.Commands[COMMAND_DETAIL_DELETE].SetHandler(CmdDetailDelete);

  FPickBulkMode :=  ViewInfo.OptionExists('PickBulkMode');
  WorkItem.Commands[COMMAND_PICK_PANEL_SHOW].SetHandler(CmdPickPanelShow);
  WorkItem.Commands[COMMAND_PICK_PANEL_HIDE].SetHandler(CmdPickPanelHide);
  WorkItem.Commands[COMMAND_PICK_SEARCH].SetHandler(CmdPickSearch);
  WorkItem.Commands[COMMAND_PICK_ITEM_SELECTED].SetHandler(CmdPickItemSelected);
  WorkItem.Commands[COMMAND_PICK_ITEM_ADD].SetHandler(CmdPickItemAdd);
  WorkItem.Commands[COMMAND_PICK_ITEM_CANCEL].SetHandler(CmdPickItemCancel);
  WorkItem.Commands[COMMAND_PICK_ITEM_ADD].Status := csDisabled;
  WorkItem.Commands[COMMAND_PICK_ITEM_CANCEL].Status := csDisabled;

  View.LinkHeadData(GetEVHead.DataSet);

  DetailViewsInit;

  FIsReady := true;
end;

function TEntityItemExtPresenter.View: IEntityItemExtView;
begin
  Result := GetView as IEntityItemExtView;
end;

end.
