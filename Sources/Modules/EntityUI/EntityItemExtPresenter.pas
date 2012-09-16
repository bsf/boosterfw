unit EntityItemExtPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr, strUtils;

const
  COMMAND_DETAIL_DELETE = 'commands.Detail.Delete';

type
  IEntityItemExtView = interface(IContentView)
  ['{F2CB6C89-5688-4566-A972-5D787A528C0C}']
    procedure LinkHeadData(AData: TDataSet);
    procedure LinkDetailData(const AName, ACaption: string; AData: TDataSet);
    function GetActiveDetailData: string;
  end;

  TEntityItemExtPresenter = class(TEntityContentPresenter)
  private
    FIsReady: boolean;
    FHeadEntityViewReady: boolean;
    procedure CmdDetailDelete(Sender: TObject);
    function View: IEntityItemExtView;
    function GetEVHead: IEntityView;
    function GetEVDetailEViews: IEntityView;
    function GetEVDetail(const AName: string): IEntityView;
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;
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
    entityViews: TStringList;
    I: integer;
  begin
    entityViews := TStringList.Create;
    try
      GetDetailEViews(entityViews);
      for I := 0 to entityViews.Count - 1 do
      begin
        entityView := GetEVDetail(entityViews[I]);
        entityView.ImmediateSave := true;
        View.LinkDetailData(entityView.ViewName, entityView.Info.Title, entityView.DataSet);
      end;
    finally
      entityViews.Free;
    end;
  end;

var
  fieldTitle: TField;
begin
  ViewTitle := ViewInfo.Title;

  fieldTitle := GetEVHead.DataSet.FindField('UI_TITLE');
  if not Assigned(fieldTitle) then
    fieldTitle := GetEVHead.DataSet.FindField('NAME');

  if Assigned(fieldTitle) and (VarToStr(fieldTitle.Value) <> '') then
    ViewTitle := VarToStr(fieldTitle.Value);

//----------------- CommandBar
  View.CommandBar.
    AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);


  WorkItem.Commands[COMMAND_DETAIL_DELETE].SetHandler(CmdDetailDelete);

  View.LinkHeadData(GetEVHead.DataSet);

  DetailViewsInit;

  FIsReady := true;
end;

function TEntityItemExtPresenter.View: IEntityItemExtView;
begin
  Result := GetView as IEntityItemExtView;
end;

end.
