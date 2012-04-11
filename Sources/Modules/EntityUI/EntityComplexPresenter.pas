unit EntityComplexPresenter;

interface
uses CoreClasses, CustomContentPresenter, ShellIntf, EntityServiceIntf, SysUtils,
  variants, db,  UIClasses, EntityCatalogIntf, StrUtils, controls, UIStr;

const

  ENT_VIEW_HEAD_DEFAULT = 'Head';
  ENT_VIEW_HEAD_EDIT_DEFAULT = 'HeadEdit';
  ENT_VIEW_DETAILS_DEFAULT = 'Details';
  ENT_VIEW_DETAIL_DEFAULT = 'Detail';
  ENT_VIEW_DETAIL_NEW_DEFAULT = 'DetailNew';

  COMMAND_HEAD_OPEN = '{785FB60E-33B4-40B4-9E60-40F3FBA9DF87}';
  COMMAND_DETAIL_COLLECT = '{D25EFE28-7739-47C5-815F-F3F3D1E8F1C4}';
  VIEW_HEAD_EDIT = 'views.%s.Head';
  VIEW_DETAIL_NEW_URI = 'views.%s.DetailNewURI';
  VIEW_DETAIL_NEW = 'views.%s.DetailNew';
  VIEW_DETAIL_ITEM = 'views.%s.Detail';
  VIEW_DETAIL_COLLECT = 'views.%s.Collect';

type
  IEntityComplexView = interface(IContentView)
  ['{55DC9892-D25A-41EB-A891-CCE81BDF4988}']
    procedure LinkData(AHead, ADetails: TDataSet);
    function DetailSelection: ISelection;
  end;

  TEntityComplexPresenter = class(TEntityContentPresenter)
  private
    procedure CmdHeadEdit(Sender: TObject);
    procedure CmdDetailCollect(Sender: TObject);
    procedure CmdDetailNew(Sender: TObject);
    procedure CmdDetailDel(Sender: TObject);
    procedure CmdReload(Sender: TObject);
    procedure DetailSelectionChangedHandler;
    function View: IEntityComplexView;
  protected
    procedure OnUpdateCommandStatus; override;
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnInit(Sender: IActivity); override;
    procedure OnViewReady; override;
    function GetEVHead: IEntityView;
    function GetEVDetails: IEntityView;
  end;


implementation

{ TEntityComplexPresenter }

procedure TEntityComplexPresenter.CmdHeadEdit(Sender: TObject);
var
  actionName: string;
begin
  actionName := format(VIEW_HEAD_EDIT, [EntityName]);
  with WorkItem.Activities[actionName] do
  begin
    Params['ID'] := WorkItem.State['HID'];
    Execute(WorkItem);
  end;
end;

procedure TEntityComplexPresenter.CmdDetailDel(Sender: TObject);
var
  cResult: boolean;
begin
  cResult := App.UI.MessageBox.ConfirmYesNo('Удалить выделеную запись?');
  if cResult then
  begin
    try
      GetEVDetails.DataSet.Delete;
      GetEVDetails.Save;
    except
      GetEVDetails.CancelUpdates;
      raise;
    end;
  end;

end;

procedure TEntityComplexPresenter.CmdDetailNew(Sender: TObject);

  function GetNewViewURI: string;
  var
    actionURI: IActivity;
  begin
    if App.Entities.EntityViewExists(EntityName, 'DetailNewURI') then
    begin
      actionURI := WorkItem.Activities[format(VIEW_DETAIL_NEW_URI, [EntityName])];
      actionURI.Execute(WorkItem);
      if actionURI.Outs[TViewActivityOuts.ModalResult] = mrOk then
        Result := actionURI.Outs['URI']
      else
        Result := '';
    end
    else
      Result := format(VIEW_DETAIL_NEW, [EntityName]);
  end;

var
  actionName: string;
begin
  actionName := GetNewViewURI;
  if actionName <> '' then
    with WorkItem.Activities[actionName] do
    begin
      Params['HID'] := WorkItem.State['HID'];
      Execute(WorkItem);
    end;
end;

function TEntityComplexPresenter.GetEVHead: IEntityView;
begin
  Result := GetEView(EntityName, ENT_VIEW_HEAD_DEFAULT);
end;

function TEntityComplexPresenter.GetEVDetails: IEntityView;
begin
  Result := GetEView(EntityName, ENT_VIEW_DETAILS_DEFAULT);
end;

function TEntityComplexPresenter.OnGetWorkItemState(
  const AName: string; var Done: boolean): Variant;
begin
  if SameText(AName, 'DETAIL_ID') then
  begin
    Result := (GetView as IEntityComplexView).DetailSelection.First;
    Done := true;
  end;
end;

procedure TEntityComplexPresenter.OnInit(Sender: IActivity);
begin
  WorkItem.State['HID'] := WorkItem.State['ID'];
end;

procedure TEntityComplexPresenter.OnViewReady;
var
  fieldTitle: TField;
begin
  ViewTitle := ViewInfo.Title;

  fieldTitle := GetEVHead.DataSet.FindField('VIEW_TITLE');
  if not Assigned(fieldTitle) then
    fieldTitle := GetEVHead.DataSet.FindField('NAME');

  if Assigned(fieldTitle) and (VarToStr(fieldTitle.Value) <> '') then
    ViewTitle := VarToStr(fieldTitle.Value);

  WorkItem.Commands[COMMAND_RELOAD].SetHandler(CmdReload);

//----------------- CommandBar
  View.CommandBar.
    AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT, CmdClose);

  if ViewInfo.OptionExists('CanHeadEdit') then
    View.CommandBar.
      AddCommand(COMMAND_HEAD_OPEN, 'Изменить заголовок', 'Ctrl+H', CmdHeadEdit);

  if ViewInfo.OptionExists('CanAdd') or ViewInfo.OptionExists('CanDetailsEdit') then
  begin
    if ViewInfo.OptionExists('UseCollectOnly') then
      View.CommandBar.
        AddCommand(COMMAND_DETAIL_COLLECT, 'Добавить записи', 'Ins', CmdDetailCollect)
    else if ViewInfo.OptionExists('UseCollect') then
    begin
      View.CommandBar.
        AddCommand(COMMAND_DETAIL_COLLECT, 'Подбор', 'Ins', CmdDetailCollect, 'Добавить', true);
      View.CommandBar.
        AddCommand(COMMAND_DETAIL_NEW, 'Добавить запись', 'Ctrl+Ins', CmdDetailNew, 'Добавить');
    end
    else
      View.CommandBar.
        AddCommand(COMMAND_DETAIL_NEW, 'Добавить запись', 'Ins', CmdDetailNew);
  end;

  if ViewInfo.OptionExists('CanOpen') or ViewInfo.OptionExists('CanDetailsEdit') then
    View.CommandBar.
      AddCommand(COMMAND_DETAIL_OPEN, 'Открыть запись', 'Ctrl+Enter', '', false);

  if ViewInfo.OptionExists('CanDelete') or ViewInfo.OptionExists('CanDetailsEdit') then
    View.CommandBar.
      AddCommand(COMMAND_DETAIL_DELETE, 'Удалить запись', 'Ctrl+Del', CmdDetailDel);

//-----------------------------------------------------------------

  GetEVHead.SynchronizeOnEntityChange(GetEVHead.EntityName, ENT_VIEW_HEAD_EDIT_DEFAULT);
  GetEVDetails.SynchronizeOnEntityChange(GetEVDetails.EntityName, ENT_VIEW_DETAIL_NEW_DEFAULT);
  GetEVDetails.SynchronizeOnEntityChange(GetEVDetails.EntityName, ENT_VIEW_DETAIL_DEFAULT);

  if not GetEVDetails.Info.ReadOnly then
   GetEVDetails.ImmediateSave := true;

  (GetView as IEntityComplexView).LinkData(GetEVHead.DataSet, GetEVDetails.DataSet);

  View.DetailSelection.SetSelectionChangedHandler(DetailSelectionChangedHandler);

  DetailSelectionChangedHandler;
end;


function TEntityComplexPresenter.View: IEntityComplexView;
begin
  Result := GetView as IEntityComplexView;
end;

procedure TEntityComplexPresenter.DetailSelectionChangedHandler;
begin
  UpdateCommandStatus;
end;

procedure TEntityComplexPresenter.OnUpdateCommandStatus;
begin
  WorkItem.Commands[COMMAND_DETAIL_OPEN].Status := csDisabled;
  WorkItem.Commands[COMMAND_DETAIL_DELETE].Status := csDisabled;

  if View.DetailSelection.Count > 0 then
    WorkItem.Commands[COMMAND_DETAIL_OPEN].Status := csEnabled;

  if View.DetailSelection.Count > 0 then
    WorkItem.Commands[COMMAND_DETAIL_DELETE].Status := csEnabled;
end;

procedure TEntityComplexPresenter.CmdReload(Sender: TObject);
begin
//  GetEVHead.Reload;
  GetEVDetails.Load;
end;

procedure TEntityComplexPresenter.CmdDetailCollect(Sender: TObject);
begin
  with WorkItem.Activities[format(VIEW_DETAIL_COLLECT, [EntityName])] do
  begin
    Params['ID']:= WorkItem.State['ID'];
    Execute(WorkItem);
  end;
end;

end.
