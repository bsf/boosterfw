unit EntityNewPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr;

type
  IEntityNewView = interface(IContentView)
  ['{AE156F18-E05A-49CC-85C2-5A8258111B5E}']
    procedure SetData(ADataSet: TDataSet);
  end;

  TEntityNewPresenter = class(TEntityContentPresenter)
  private
    FEntityViewReady: boolean;
    procedure CmdCancel(Sender: TObject);
    procedure CmdSave(Sender: TObject);
    function View: IEntityNewView;
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    function GetEVItem: IEntityView; virtual;
    //
    procedure OnViewReady; override;
  end;

implementation

{ TEntityNewPresenter }

procedure TEntityNewPresenter.CmdCancel(Sender: TObject);
begin
  CloseView;
end;

procedure TEntityNewPresenter.CmdSave(Sender: TObject);
var
  nextActionID: string;
  nextAction: IActivity;
  callerWI: TWorkItem;
begin

  GetEVItem.Save;

  callerWI := WorkItem.Root.WorkItems.Find(CallerURI);
  if callerWI = nil then
    callerWI := WorkItem.Parent;

  if ViewInfo.OptionExists('ReloadCaller') then
    callerWI.Commands[COMMAND_RELOAD].Execute;

  nextAction := nil;
  nextActionID := WorkItem.State['NEXT_ACTION'];
  if nextActionID <> '' then
    nextAction := WorkItem.Activities[nextActionID];

  if nextAction <> nil then
    nextAction.Params.Assign(WorkItem);

  CloseView;

  if Assigned(nextAction) then
    nextAction.Execute(callerWI);

end;

procedure TEntityNewPresenter.OnViewReady;
var
  fieldAux: TField;
begin
  ViewTitle := ViewInfo.Title;

  fieldAux := GetEVItem.DataSet.FindField('UI_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := GetEVItem.DataSet.FindField('VIEW_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := GetEVItem.DataSet.FindField('NAME');

  if Assigned(fieldAux) and (VarToStr(fieldAux.Value) <> '') then
    ViewTitle := VarToStr(fieldAux.Value);

  View.CommandBar.AddCommand(COMMAND_SAVE,
    GetLocaleString(@COMMAND_SAVE_CAPTION), COMMAND_SAVE_SHORTCUT);
  WorkItem.Commands[COMMAND_SAVE].SetHandler(CmdSave);

  View.CommandBar.AddCommand(COMMAND_CANCEL,
    GetLocaleString(@COMMAND_CANCEL_CAPTION), COMMAND_CANCEL_SHORTCUT);
  WorkItem.Commands[COMMAND_CANCEL].SetHandler(CmdCancel);

  View.SetData(GetEVItem.DataSet);

  // FocusField
  if VarToStr(WorkItem.State['FOCUS_FIELD']) = '' then
  begin
    fieldAux := GetEVItem.DataSet.FindField('FOCUS_FIELD');
    if Assigned(fieldAux) then
      WorkItem.State['FOCUS_FIELD'] := VarToStr(fieldAux.Value)
    else
      WorkItem.State['FOCUS_FIELD'] := ViewInfo.OptionValue('Focus');
  end;
  View.FocusDataSetControl(GetEVItem.DataSet, VarToStr(WorkItem.State['FOCUS_FIELD']));


  if ViewInfo.OptionExists('Next') then
    WorkItem.State['NEXT_ACTION'] :=ViewInfo.OptionValue('Next');

  if WorkItem.State['NEXT_ACTION'] <> '' then
    WorkItem.Commands[COMMAND_SAVE].Caption := GetLocaleString(@COMMAND_NEXT_CAPTION);

  if GetEVItem.DataSet.IsEmpty then
  begin
    GetEVItem.DataSet.Insert;
   // GetEVItem.DataSet.Post; ReqFields!!!
  end;
end;

function TEntityNewPresenter.GetEVItem: IEntityView;
var
  mField: TField;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView(EntityViewName, WorkItem);

  Result.Load(false);

  if Result.IsLoaded and (not Result.IsModified) then
  begin
    mField := Result.DataSet.FindField('MODIFIED');
    if Assigned(mField) then
    begin
      Result.DataSet.Edit;
      mField.Value := 1;
      Result.DataSet.Post;
    end;
  end;

  FEntityViewReady := true;
end;

function TEntityNewPresenter.OnGetWorkItemState(
  const AName: string; var Done: boolean): Variant;
var
  ds: TDataSet;
begin
  {if SameText(AName, 'ID') then
    Result := GetEVItem.Values['ID']; �������� !!!}
  if FEntityViewReady then
  begin
    ds := App.Entities[EntityName].GetView(EntityViewName, WorkItem).DataSet;
    if ds.FindField(AName) <> nil then
    begin
      Result := ds[AName];
      Done := true;
    end;
  end;
end;

function TEntityNewPresenter.View: IEntityNewView;
begin
  Result := GetView as IEntityNewView;
end;


end.
