unit EntityItemExtPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr, strUtils;

const
  COMMAND_CHANGE_ACTIVE_DETAIL_DATA = '{20C7D329-597B-409C-B653-4CD9C087D468}';
  COMMAND_DETAIL_DBLCLICK = 'cmd.Detail.DblClick';

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
    procedure CmdChangeActiveDitailData(Sender: TObject);
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

procedure TEntityItemExtPresenter.CmdChangeActiveDitailData(Sender: TObject);
begin
  Self.UpdateCommandStatus;
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
    Entity[EntityName].GetView('Head', WorkItem);
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

  if SameText(AName, 'ACTIVE_DETAIL') then
  begin
    Result := View.GetActiveDetailData;
    Done := true;
    Exit;
  end;

  if FHeadEntityViewReady then
  begin
    ds := App.Entities[EntityName].GetView('Head', WorkItem).DataSet;  //Result := GetEVItem.Values['ID']; пейспяхъ !!!}
    if ds.FindField(AName) <> nil then
    begin
      Result := ds[AName];
      Done := true;
      Exit;
    end;
  end;

end;

procedure TEntityItemExtPresenter.OnViewReady;
var
  fieldTitle: TField;
  ds: TDataSet;
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

  WorkItem.Commands[COMMAND_CHANGE_ACTIVE_DETAIL_DATA].SetHandler(CmdChangeActiveDitailData);

  View.LinkHeadData(GetEVHead.DataSet);

  if App.Entities.EntityViewExists(EntityName, 'DetailEViews') then
  begin
    ds := GetEVDetailEViews.DataSet;
    while not ds.Eof do
    begin
      View.LinkDetailData(ds['EVIEW'], VarToStr(ds['CAPTION']), GetEVDetail(ds['EVIEW']).DataSet);
      ds.Next;
    end;
  end;

  FIsReady := true;
end;

function TEntityItemExtPresenter.View: IEntityItemExtView;
begin
  Result := GetView as IEntityItemExtView;
end;

end.
