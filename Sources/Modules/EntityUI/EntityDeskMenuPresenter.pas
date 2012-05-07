unit EntityDeskMenuPresenter;

interface

uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr;

type
  IEntityDeskMenuView = interface(IContentView)
  ['{1DBB5B01-51A0-4BB0-85D2-D6724AEDC6F4}']
    procedure LinkItems(ADataSet: TDataSet);
  end;

  TEntityDeskMenuPresenter = class(TEntityContentPresenter)
  private
    FEntityViewReady: boolean;
    function View: IEntityDeskMenuView;
    procedure CmdItemHandler(Sender: TObject);
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    function GetEVItems: IEntityView; virtual;
    //
    procedure OnViewReady; override;
  end;

implementation

{ TEntityDeskMenuPresenter }

procedure TEntityDeskMenuPresenter.CmdItemHandler(Sender: TObject);
var
  Intf: ICommand;
begin
  Sender.GetInterface(ICommand, intf);

  WorkItem.Activities[Intf.Name].Execute(WorkItem.Root);

end;

function TEntityDeskMenuPresenter.GetEVItems: IEntityView;
begin
  Result := (WorkItem.Services[IEntityService] as IEntityService).
    Entity[EntityName].GetView(EntityViewName, WorkItem);

  Result.Load(false);

end;

function TEntityDeskMenuPresenter.OnGetWorkItemState(const AName: string;
  var Done: boolean): Variant;
begin

end;

procedure TEntityDeskMenuPresenter.OnViewReady;
var
  ds: TDataSet;
begin
  ViewTitle := ViewInfo.Title;

  ds := GetEVItems.DataSet;
  while not ds.Eof  do
  begin
    WorkItem.Commands[ds['URI']].SetHandler(CmdItemHandler);
    ds.Next;
  end;


  View.LinkItems(GetEVItems.DataSet);
end;

function TEntityDeskMenuPresenter.View: IEntityDeskMenuView;
begin
  Result := GetView as IEntityDeskMenuView;
end;

end.
