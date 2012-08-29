unit EntityWebPresenter;

interface

uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr, SHDocVw, MSHTML,
  strUtils, WBCtrl;

const
  COMMAND_INVOKE_SCRIPT = 'command.view.invokescript';

type
  IEntityWebView = interface(IContentView)
  ['{11008510-83A2-4451-B554-CEB1CD20FA4D}']
    function WebBrowser: TWebBrowserCtrl;
  end;

  TEntityWebPresenter = class(TEntityContentPresenter)
  private
    FEntityViewReady: boolean;
    procedure OnWebBrowserDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);

    function View: IEntityWebView;
    function GetEV: IEntityView;
    procedure CmdReload(Sender: TObject);
    procedure CmdCancel(Sender: TObject);
    procedure CmdSave(Sender: TObject);
    procedure CmdInvokeScript(Sender: TObject);
  protected
    //function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;
  end;

implementation

{ TEntityWebPresenter }

procedure TEntityWebPresenter.CmdCancel(Sender: TObject);
begin
  CloseView;
end;

procedure TEntityWebPresenter.CmdInvokeScript(Sender: TObject);
var
  cmd: ICommand;
begin
  Sender.GetInterface(ICommand, cmd);
  View.WebBrowser.InvokeScript(cmd.Data['Script'], []);
end;

procedure TEntityWebPresenter.CmdReload(Sender: TObject);
begin
  View.WebBrowser.Refresh;
end;

procedure TEntityWebPresenter.CmdSave(Sender: TObject);
var
  nextActionID: string;
  nextAction: IActivity;
  callerWI: TWorkItem;
begin

  GetEV.Save;

  callerWI := WorkItem.Root.WorkItems.Find(CallerURI);
  if callerWI = nil then
    callerWI := WorkItem.Parent;

  if ViewInfo.OptionExists('ReloadCaller') then
    callerWI.Commands[COMMAND_RELOAD].Execute;

  nextAction := nil;
  nextActionID := WorkItem.State['NEXT_ACTION'];
  if nextActionID <> '' then
    nextAction := WorkItem.Activities[nextActionID];

  if Assigned(nextAction) then
    nextAction.Params.Assign(WorkItem);

  CloseView;

  if Assigned(nextAction) then
    nextAction.Execute(callerWI);

end;

function TEntityWebPresenter.GetEV: IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView(EntityViewName, WorkItem);

  Result.Load(false);

  FEntityViewReady := true;
end;

procedure TEntityWebPresenter.OnViewReady;
var
  fieldAux: TField;
  dsItem: TDataSet;
begin
 ViewTitle := ViewInfo.Title;

  dsItem := GetEV.DataSet;

  fieldAux := dsItem.FindField('UI_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := dsItem.FindField('VIEW_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := dsItem.FindField('NAME');

  if Assigned(fieldAux) and (VarToStr(fieldAux.Value) <> '') then
    ViewTitle := VarToStr(fieldAux.Value);

  if (not GetEV.Info.ReadOnly) and (not ViewInfo.OptionExists('CloseOnly')) then
  begin
    View.CommandBar.AddCommand(COMMAND_SAVE,
      GetLocaleString(@COMMAND_SAVE_CAPTION), COMMAND_SAVE_SHORTCUT);
    WorkItem.Commands[COMMAND_SAVE].SetHandler(CmdSave);

    View.CommandBar.AddCommand(COMMAND_CANCEL,
      GetLocaleString(@COMMAND_CANCEL_CAPTION), COMMAND_CANCEL_SHORTCUT);
    WorkItem.Commands[COMMAND_CANCEL].SetHandler(CmdCancel);
  end
  else
  begin
    View.CommandBar.AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
    WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);
  end;

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, GetLocaleString(@COMMAND_RELOAD_CAPTION), COMMAND_RELOAD_SHORTCUT);
  WorkItem.Commands[COMMAND_RELOAD].SetHandler(CmdReload);

  if ViewInfo.OptionExists('Next') then
    WorkItem.State['NEXT_ACTION'] := ViewInfo.OptionValue('Next');

  if WorkItem.State['NEXT_ACTION'] <> '' then
    WorkItem.Commands[COMMAND_SAVE].Caption := GetLocaleString(@COMMAND_NEXT_CAPTION); //'Далее >>';

  WorkItem.Commands[COMMAND_INVOKE_SCRIPT].SetHandler(CmdInvokeScript);

  View.WebBrowser.OnDocumentComplete := OnWebBrowserDocumentComplete;
  View.WebBrowser.Navigate(ExtractFilePath(ParamStr(0)) + 'html\' + Self.ViewInfo.OptionValue('html'));

end;

procedure TEntityWebPresenter.OnWebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin

end;


function TEntityWebPresenter.View: IEntityWebView;
begin
  Result := GetView as IEntityWebView;
end;


end.
