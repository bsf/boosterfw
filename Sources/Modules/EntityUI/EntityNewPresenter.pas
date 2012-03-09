unit EntityNewPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr;

const
  ENT_VIEW_NEW = 'New';
  VIEW_ITEM = 'views.%s.Item';
  VIEW_COLLECT = 'views.%s.Collect';

type
  IEntityNewView = interface(IContentView)
  ['{AE156F18-E05A-49CC-85C2-5A8258111B5E}']
    procedure SetData(ADataSet: TDataSet);
  end;

  TEntityNewPresenter = class(TEntityContentPresenter)
  private
    procedure CmdCancel(Sender: TObject);
    procedure CmdSave(Sender: TObject);
    function View: IEntityNewView;
    procedure ReloadCallerWorkItem;
  protected
    function OnGetWorkItemState(const AName: string): Variant; override;
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
  callerID: string;
  callerWI: TWorkItem;
begin
  nextAction := nil;
  callerWI := nil;

  GetEVItem.Save;

  if ViewInfo.OptionExists('ReloadCaller') then
    ReloadCallerWorkItem;

  nextActionID := WorkItem.State['NEXT_ACTION'];
  if nextActionID <> '' then
  begin
    nextAction := WorkItem.Activities[nextActionID];
    if nextActionID = ACTION_ENTITY_ITEM then
    begin
       nextAction.Params[TEntityItemActionParams.ID] := GetEVItem.Values['ID'];
       nextAction.Params[TEntityItemActionParams.EntityName] := EntityName;
    end
    else
      nextAction.Params['ID'] := GetEVItem.Values['ID'];

    callerID := WorkItem.State['CALLER_ID'];
    if callerID <> '' then
      callerWI := FindWorkItem(callerID, WorkItem.Root);
    if not Assigned(callerWI) then
      callerWI := WorkItem.Parent;
  end;

  CloseView;

  if Assigned(nextAction) then
    nextAction.Execute(callerWI);
end;

procedure TEntityNewPresenter.OnViewReady;
var
  fieldAux: TField;
  NextOption: string;
  NextAction: string;
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
    GetLocaleString(@COMMAND_SAVE_CAPTION), COMMAND_SAVE_SHORTCUT, CmdSave);

  View.CommandBar.AddCommand(COMMAND_CANCEL,
    GetLocaleString(@COMMAND_CANCEL_CAPTION), COMMAND_CANCEL_SHORTCUT, CmdCancel);

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
  begin
    nextOption := ViewInfo.OptionValue('Next');

    if (nextOption = '') or (SameText(nextOption, 'Item'))then
      NextAction := ACTION_ENTITY_ITEM

      //NextAction := format(VIEW_ITEM, [EntityName])

    else if SameText(nextOption, 'Collect') then
      NextAction := format(VIEW_COLLECT, [EntityName])

    else
      NextAction := NextOption;

    WorkItem.State['NEXT_ACTION'] := NextAction;
  end;

  if WorkItem.State['NEXT_ACTION'] <> '' then
    WorkItem.Commands[COMMAND_SAVE].Caption := GetLocaleString(@COMMAND_NEXT_CAPTION);
end;

function TEntityNewPresenter.GetEVItem: IEntityView;
var
  mField: TField;
  evName: string;
begin
  evName := EntityViewName;
  if evName = '' then evName := ENT_VIEW_NEW;
  Result := GetEView(EntityName, evName);

  if Result.IsLoaded and (not Result.IsModified) then
  begin
    mField := Result.DataSet.FindField('MODIFIED');
    if Assigned(mField) then
    begin
      Result.DataSet.Edit;
      mField.Value := 1;
      Result.DataSet.Post;
    end;
  end
end;

function TEntityNewPresenter.OnGetWorkItemState(
  const AName: string): Variant;
begin
  {if SameText(AName, 'ID') then
    Result := GetEVItem.Values['ID']; пейспяхъ !!!}
end;

function TEntityNewPresenter.View: IEntityNewView;
begin
  Result := GetView as IEntityNewView;
end;

procedure TEntityNewPresenter.ReloadCallerWorkItem;
var
  CallerWI: TWorkItem;
begin
  CallerWI := WorkItem.Root.WorkItems.Find(CallerURI);
  if CallerWI <> nil then
    CallerWI.Commands[COMMAND_RELOAD].Execute;
end;

end.
