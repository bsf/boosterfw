unit EntityWebPresenter;

interface

uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr, SHDocVw, MSHTML,
  strUtils, WBCtrl;

const
  COMMAND_STATE_SET = 'command.state.set';
  COMMAND_STATE_GET = 'command.state.get';

type
  IEntityWebView = interface(IContentView)
  ['{11008510-83A2-4451-B554-CEB1CD20FA4D}']
    function WebBrowser: TWebBrowserCtrl;
  end;

  TEntityWebPresenter = class(TEntityContentPresenter)
  private
    procedure OnWebBrowserTitleChange(ASender: TObject; const Text: WideString);
    procedure OnWebBrowserDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);

    procedure ExecuteJS(const AName: string);
    function View: IEntityWebView;

    procedure CmdGetState(Sender: TObject);
    procedure CmdSetState(Sender: TObject);

    procedure CmdReload(Sender: TObject);
    procedure CmdTest(Sender: TObject);

    function ScriptFunc_Hello(AParams: array of OleVariant): OleVariant;
  protected
    //function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;
  end;

implementation

{ TEntityWebPresenter }

procedure TEntityWebPresenter.CmdGetState(Sender: TObject);
var
  cmd: ICommand;
  stateName: string;
begin
  Sender.GetInterface(ICommand, cmd);
  stateName := cmd.Data['DATA'];
  ExecuteJS('WI.getStateCallback("' + stateName + '", "' + VarToStr(WorkItem.State[stateName]) + '")');
end;

procedure TEntityWebPresenter.CmdReload(Sender: TObject);
begin
  View.WebBrowser.Refresh;
end;

procedure TEntityWebPresenter.CmdSetState(Sender: TObject);
begin

end;

procedure TEntityWebPresenter.CmdTest(Sender: TObject);
begin
  ExecuteJS('Test()');
end;

procedure TEntityWebPresenter.ExecuteJS(const AName: string);
begin
  (View.WebBrowser.Document as IHTMLDocument2).parentWindow.execScript(AName, 'JavaScript');
end;

procedure TEntityWebPresenter.OnViewReady;
var
  fieldAux: TField;
  dsItem: TDataSet;
begin
 ViewTitle := ViewInfo.Title;

{  dsItem := GetEVItem.DataSet;

  fieldAux := dsItem.FindField('UI_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := dsItem.FindField('VIEW_TITLE');
  if not Assigned(fieldAux) then
    fieldAux := dsItem.FindField('NAME');

  if Assigned(fieldAux) and (VarToStr(fieldAux.Value) <> '') then
    ViewTitle := VarToStr(fieldAux.Value);}

  View.CommandBar.AddCommand(COMMAND_CLOSE,  GetLocaleString(@COMMAND_CLOSE_CAPTION));

  View.CommandBar.
    AddCommand(COMMAND_RELOAD, GetLocaleString(@COMMAND_RELOAD_CAPTION), COMMAND_RELOAD_SHORTCUT);
  WorkItem.Commands[COMMAND_RELOAD].SetHandler(CmdReload);

  View.CommandBar.AddCommand('cmd.Test', 'Test');
  WorkItem.Commands['cmd.Test'].SetHandler(CmdTest);

  WorkItem.Commands[COMMAND_STATE_GET].SetHandler(CmdGetState);
  WorkItem.Commands[COMMAND_STATE_SET].SetHandler(CmdSetState);

  View.WebBrowser.RegisterScriptFunc('Hello', ScriptFunc_Hello);
  View.WebBrowser.OnTitleChange := OnWebBrowserTitleChange;
  View.WebBrowser.OnDocumentComplete := OnWebBrowserDocumentComplete;
  View.WebBrowser.Navigate(ExtractFilePath(ParamStr(0)) + 'html\' + Self.ViewInfo.OptionValue('html'));

end;

procedure TEntityWebPresenter.OnWebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin

end;

procedure TEntityWebPresenter.OnWebBrowserTitleChange(ASender: TObject;
  const Text: WideString);
var
  cmdName: string;
  cmdData: string;
begin
  if Pos(WideString('##'), Text) = 1 then
  begin
    cmdName := Copy(Text, 3, MAXINT);
    cmdData := '';

    if Pos('#', cmdName) > 0 then
    begin
      cmdData := Copy(cmdName, Pos('#', cmdName) + 1, MAXINT);
      cmdName := Copy(cmdName, 1, Pos('#', cmdName) - 1);
    end;

    WorkItem.Commands[cmdName].Data['DATA'] := cmdData;

    WorkItem.Commands[cmdName].Execute;
  end;


end;

function TEntityWebPresenter.ScriptFunc_Hello(
  AParams: array of OleVariant): OleVariant;
begin
  App.UI.MessageBox.InfoMessage('Hello world!');
end;

function TEntityWebPresenter.View: IEntityWebView;
begin
  Result := GetView as IEntityWebView;
end;


end.
