unit EntityCatalogIntf;

interface
uses UIClasses, db, Classes, ShellIntf, CoreClasses, variants, EntityServiceIntf,
  CustomContentPresenter, CustomDialogPresenter, strUtils, sysutils;

type

  TEntityContentPresenter = class(TCustomContentPresenter)
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
  public
    function EntityName: string;
    function EntityViewName: string;
  end;

  TEntityDialogPresenter = class(TCustomDialogPresenter)
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
  public
    function EntityName: string;
    function EntityViewName: string;
  end;

implementation


function GetEntityViewValue(AWorkItem: TWorkItem; const AName: string; var Done: boolean): Variant;
const
  ENTITY_VIEW_VALUE_PREFIX = 'EV.';

var
  entityName: string;
  viewName: string;
  fieldName: string;
  tmpStr: string;
  Svc: IEntityService;
  entityView: IEntityView;
begin
  Result := Unassigned;

  if not AnsiStartsText(ENTITY_VIEW_VALUE_PREFIX, AName) then Exit;

  tmpStr := StringReplace(AName, ENTITY_VIEW_VALUE_PREFIX, '', [rfIgnoreCase]);

  if AWorkItem.Controller is TEntityContentPresenter then
    entityName := TEntityContentPresenter(AWorkItem.Controller).EntityName
  else if AWorkItem.Controller is TEntityDialogPresenter then
    entityName := TEntityDialogPresenter(AWorkItem.Controller).EntityName
  else
    entityName := '';

  if entityName = '' then Exit;


  viewName := AnsiLeftStr(tmpStr, Pos('.', tmpStr) - 1);
  fieldName :=  AnsiRightStr(tmpStr, Length(tmpStr) - Pos('.', tmpStr));

  if viewName = '' then Exit;
  
  Svc := AWorkItem.Services[IEntityService] as IEntityService;

  if not Svc.EntityViewExists(entityName, viewName) then Exit;

  entityView := Svc.Entity[entityName].GetView(viewName, AWorkItem);

  if not entityView.IsLoaded then Exit;

  if entityView.DataSet.FindField(fieldName) <> nil then
  begin
    Done := true;
    Result := entityView.DataSet[fieldName];
  end;

end;


{ TCustomEntityContentPresenter }

function TEntityContentPresenter.EntityName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityName);
end;

function TEntityContentPresenter.EntityViewName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityViewName);
end;

function TEntityContentPresenter.OnGetWorkItemState(const AName: string;
  var Done: boolean): Variant;
begin
  Result := GetEntityViewValue(WorkItem, AName, Done);
  if not Done then
    Result := inherited;
end;

{ TEntityDialogPresenter }

function TEntityDialogPresenter.EntityName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityName);
end;

function TEntityDialogPresenter.EntityViewName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityViewName);
end;

function TEntityDialogPresenter.OnGetWorkItemState(const AName: string;
  var Done: boolean): Variant;
begin
  Result := GetEntityViewValue(WorkItem, AName, Done);
  if not Done then
    Result := inherited;
end;

end.
