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
    FEntityViewReady: boolean;
    procedure OnWebBrowserDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);

    function View: IEntityWebView;
    function GetEV: IEntityView;
    procedure CmdReload(Sender: TObject);

  protected
    //function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;
  end;

implementation

{ TEntityWebPresenter }

procedure TEntityWebPresenter.CmdReload(Sender: TObject);
begin
  View.WebBrowser.Refresh;
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
