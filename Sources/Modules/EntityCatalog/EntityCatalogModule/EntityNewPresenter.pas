unit EntityNewPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, CommonViewIntf,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db, ViewServiceIntf,
  EntityCatalogIntf, EntityCatalogConst;

const
  ENT_VIEW_NEW = 'New';
  VIEW_ITEM = 'views.%s.Item';
  VIEW_COLLECT = 'views.%s.Collect';

type
  IEntityNewView = interface(IContentView)
  ['{AE156F18-E05A-49CC-85C2-5A8258111B5E}']
    procedure SetData(ADataSet: TDataSet);
  end;

  TEntityNewPresenter = class(TCustomContentPresenter)
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
  public
    class function ExecuteDataClass: TActionDataClass; override;
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
  nextAction: IAction;
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
    nextAction := WorkItem.Actions[nextActionID];
    nextAction.Data.Value['ID'] := GetEVItem.Values['ID'];
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

  fieldAux := GetEVItem.DataSet.FindField('VIEW_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := GetEVItem.DataSet.FindField('NAME');

  if Assigned(fieldAux) and (VarToStr(fieldAux.Value) <> '') then
    ViewTitle := VarToStr(fieldAux.Value);

  View.CommandBar.AddCommand(COMMAND_SAVE,
    COMMAND_SAVE_CAPTION, COMMAND_SAVE_SHORTCUT, CmdSave);

  View.CommandBar.AddCommand(COMMAND_CANCEL,
    COMMAND_CANCEL_CAPTION, COMMAND_CANCEL_SHORTCUT, CmdCancel);

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
      NextAction := format(VIEW_ITEM, [ViewInfo.EntityName])

    else if SameText(nextOption, 'Collect') then
      NextAction := format(VIEW_COLLECT, [ViewInfo.EntityName])

    else
      NextAction := NextOption;

    WorkItem.State['NEXT_ACTION'] := NextAction;
  end;

  if WorkItem.State['NEXT_ACTION'] <> '' then
    WorkItem.Commands[COMMAND_SAVE].Caption := 'ƒ‡ÎÂÂ >>';
end;

class function TEntityNewPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TEntityNewPresenterData;
end;

function TEntityNewPresenter.GetEVItem: IEntityView;
var
  mField: TField;
  evName: string;
begin
  evName := ViewInfo.EntityViewName;
  if evName = '' then evName := ENT_VIEW_NEW;
  Result := GetEView(ViewInfo.EntityName, evName);
  
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
    Result := GetEVItem.Values['ID']; –≈ ”–—»ﬂ !!!}
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
