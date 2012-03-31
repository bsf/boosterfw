unit EntityItemPresenter;

interface

uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr;

type
  IEntityItemView = interface(IContentView)
  ['{1DBB5B01-51A0-4BB0-85D2-D6724AEDC6F4}']
    procedure SetItemDataSet(ADataSet: TDataSet);
  end;

  TEntityItemPresenter = class(TEntityContentPresenter)
  private
    FEntityViewReady: boolean;
    procedure CmdCancel(Sender: TObject);
    procedure CmdSave(Sender: TObject);
    function View: IEntityItemView;
    procedure ReloadCallerWorkItem;
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
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

  GetEVItem.Save;

  if ViewInfo.OptionExists('ReloadCaller') then
    ReloadCallerWorkItem;

  nextAction := nil;
  nextActionID := WorkItem.State['NEXT_ACTION'];
  if nextActionID <> '' then
    nextAction := WorkItem.Activities[nextActionID];

  callerWI := nil;
  callerID := WorkItem.State['CALLER_ID'];
  if callerID <> '' then
    callerWI := FindWorkItem(callerID, WorkItem.Root);
  if not Assigned(callerWI) then
    callerWI := WorkItem.Parent;

  if Assigned(nextAction) then
    nextAction.Params.Assign(WorkItem);

  CloseView;

  if Assigned(nextAction) then
    nextAction.Execute(callerWI);
end;

procedure TEntityItemPresenter.OnViewReady;
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

  if not GetEVItem.Info.ReadOnly then
  begin
    View.CommandBar.AddCommand(COMMAND_SAVE,
      GetLocaleString(@COMMAND_SAVE_CAPTION), COMMAND_SAVE_SHORTCUT, CmdSave);

    View.CommandBar.AddCommand(COMMAND_CANCEL,
      GetLocaleString(@COMMAND_CANCEL_CAPTION), COMMAND_CANCEL_SHORTCUT, CmdCancel);
  end
  else
    View.CommandBar.AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT, CmdClose);

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
    WorkItem.Commands[COMMAND_SAVE].Caption := GetLocaleString(@COMMAND_NEXT_CAPTION); //'ƒ‡ÎÂÂ >>';


end;

function TEntityItemPresenter.GetEVItem: IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView(EntityViewName, WorkItem);

  Result.Load(false);

  FEntityViewReady := true;
end;

function TEntityItemPresenter.OnGetWorkItemState(const AName: string;
  var Done: boolean): Variant;
var
  ds: TDataSet;
begin
  {if SameText(AName, 'ID') then
    Result := GetEVItem.Values['ID']; –≈ ”–—»ﬂ !!!}
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
