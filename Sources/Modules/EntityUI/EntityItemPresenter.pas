unit EntityItemPresenter;

interface

uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst;

const
  ENT_VIEW_ITEM = 'Item';

type
  TEntityItemPresenter = class(TEntityContentPresenter)
  private
    procedure CmdCancel(Sender: TObject);
    procedure CmdSave(Sender: TObject);
    function View: IEntityItemView;
    procedure ReloadCallerWorkItem;
  protected
    function OnGetWorkItemState(const AName: string): Variant; override;
    function GetEVItem: IEntityView; virtual;
    //
    procedure OnViewReady; override;
  end;

implementation

{ TEntityItemPresenter }

procedure TEntityItemPresenter.CmdCancel(Sender: TObject);
begin
  CloseView;
end;

procedure TEntityItemPresenter.CmdSave(Sender: TObject);
var
  nextActionID: string;
  nextAction: IActivity;
  callerID: string;
  callerWI: TWorkItem;

begin
  callerWI := nil;

  GetEVItem.Save;

  if ViewInfo.OptionExists('ReloadCaller') then
    ReloadCallerWorkItem;

  nextActionID := WorkItem.State['NEXT_ACTION'];
  if nextActionID <> '' then
  begin
    nextAction := WorkItem.Activities[nextActionID];
    nextAction.Params['ID'] := GetEVItem.Values['ID'];

    callerID := WorkItem.State['CALLER_ID'];
    if callerID <> '' then
      callerWI := FindWorkItem(callerID, WorkItem.Root);
    if not Assigned(callerWI) then
      callerWI := WorkItem.Parent;
  end;

  CloseView;

  if Assigned(nextAction) then
    nextAction.Execute(callerWI);   //callerWI может быть не инициализ. !!!
end;

procedure TEntityItemPresenter.OnViewReady;
var
  fieldAux: TField;
begin
  ViewTitle := ViewInfo.Title;

  fieldAux := GetEVItem.DataSet.FindField('VIEW_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := GetEVItem.DataSet.FindField('NAME');

  if Assigned(fieldAux) and (VarToStr(fieldAux.Value) <> '') then
    ViewTitle := VarToStr(fieldAux.Value);

  if not GetEVItem.ViewInfo.ReadOnly then
  begin
    View.CommandBar.AddCommand(COMMAND_SAVE,
      COMMAND_SAVE_CAPTION, COMMAND_SAVE_SHORTCUT, CmdSave);

    View.CommandBar.AddCommand(COMMAND_CANCEL,
      COMMAND_CANCEL_CAPTION, COMMAND_CANCEL_SHORTCUT, CmdCancel);
  end
  else
    View.CommandBar.AddCommand(COMMAND_CLOSE,
      COMMAND_CLOSE_CAPTION, COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.SetItemDataSet(GetEVItem.DataSet);

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
    WorkItem.State['NEXT_ACTION'] := ViewInfo.OptionValue('Next');

  if WorkItem.State['NEXT_ACTION'] <> '' then
    WorkItem.Commands[COMMAND_SAVE].Caption := 'ƒалее >>';
end;

function TEntityItemPresenter.GetEVItem: IEntityView;
var
  evName: string;
begin
  evName := EntityViewName;
  if evName = '' then evName := ENT_VIEW_ITEM;
  Result := GetEView(EntityName, evName);
end;

function TEntityItemPresenter.OnGetWorkItemState(
  const AName: string): Variant;
begin
  {if SameText(AName, 'ID') then
    Result := GetEVItem.Values['ID']; –≈ ”–—»я !!!}
end;

function TEntityItemPresenter.View: IEntityItemView;
begin
  Result := GetView as IEntityItemView;
end;

procedure TEntityItemPresenter.ReloadCallerWorkItem;
var
  CallerWI: TWorkItem;
begin
  CallerWI := WorkItem.Root.WorkItems.Find(CallerURI);
  if CallerWI <> nil then
    CallerWI.Commands[COMMAND_RELOAD].Execute;
end;

end.
