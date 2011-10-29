unit EntitySelectorPresenter;

interface
uses CustomDialogPresenter, CoreClasses, EntityCatalogIntf, UIClasses,
  controls, db, EntityServiceIntf;

type
  IEntitySelectorView = interface(IContentView)
  ['{7A7171B2-A22A-4956-987A-A8C133757483}']
    procedure LinkData(AData: TDataSet);
  end;

  TEntitySelectorPresenter = class(TCustomDialogPresenter)
  private
    function View: IEntitySelectorView;
    procedure CmdCancel(Sender: TObject);
    procedure CmdOK(Sender: TObject);
    function GetEVList: IEntityView;
  protected
    procedure OnViewReady; override;
  public
    class function ExecuteDataClass: TActionDataClass; override;
  end;

implementation

{ TEntitySelectorPresenter }

procedure TEntitySelectorPresenter.CmdCancel(Sender: TObject);
begin
  WorkItem.State['ModalResult'] := mrCancel;
  CloseView;
end;

procedure TEntitySelectorPresenter.CmdOK(Sender: TObject);
var
  I: integer;
begin
  if GetEVList.DataSet.State in [dsEdit] then GetEVList.DataSet.Post;

  for I := 0 to GetEVList.DataSet.FieldCount - 1 do
    WorkItem.State[GetEVList.DataSet.Fields[I].FieldName] :=
      GetEVList.DataSet.Fields[I].Value;

  WorkItem.State['ModalResult'] := mrOk;
  CloseView;
end;

class function TEntitySelectorPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TEntitySelectorPresenterData;
end;

function TEntitySelectorPresenter.GetEVList: IEntityView;
begin
  Result := GetEView(ViewInfo.EntityName, 'Selector');
end;

procedure TEntitySelectorPresenter.OnViewReady;
begin
  ViewTitle := ViewInfo.Title;
  WorkItem.State['ModalResult'] := mrCancel;

  View.CommandBar.AddCommand(COMMAND_CANCEL, COMMAND_CANCEL_CAPTION, 'Esc', cmdCancel);
  View.CommandBar.AddCommand(COMMAND_OK, COMMAND_OK_CAPTION, 'Enter', cmdOK);

  View.LinkData(GetEVList.DataSet);
end;

function TEntitySelectorPresenter.View: IEntitySelectorView;
begin
  Result := GetView as IEntitySelectorView;
end;

end.
