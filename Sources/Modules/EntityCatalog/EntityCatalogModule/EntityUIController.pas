unit EntityUIController;

interface
uses classes, CoreClasses, CustomUIController, ShellIntf, db, sysutils,
  ActivityServiceIntf,  Variants, EntityServiceIntf, ViewServiceIntf,
  Controls, EntityCatalogConst,
  EntityJournalPresenter, EntityJournalView,
  EntityListPresenter, EntityListView,
  EntityItemPresenter, EntityItemView,
  EntityPickListPresenter, EntityPickListView;

const
  ENT_UI = 'INF_EntityUI';
  ENT_UI_VIEW_LIST = 'List';
  ENT_UI_VIEW_ITEM = 'Item';


type
  TUIClasses = (uicNone, uicList, uicItem, uicItemNew, uicPickList, uicTreeList,
    uicJournal, uicDoc, uicDocNew, uicJournal2);

  TEntityUIController = class(TCustomUIController)
  private
    procedure RegisterUIViews;
  protected
    procedure OnInitialize; override;
  end;

implementation

{ TEntityUIController }

procedure TEntityUIController.OnInitialize;
begin
  RegisterUIViews;
end;

procedure TEntityUIController.RegisterUIViews;
var
  list: TDataSet;
  uiClass: TUIClasses;
  URI: string;
  title: string;
  category: string;
  group: string;
  eviewList: IEntityView;
begin
  eviewList := App.Entities[ENT_UI].GetView(ENT_UI_VIEW_LIST, WorkItem);
  eviewList.Load([]);
  list := eviewList.DataSet;
  while not list.Eof do
  begin
    uiClass := list['UIClass'];
    URI :=  list['URI'];
    title := list['Title'];
    category := VarToStr(list['Category']);
    group := VarToStr(list['Grp']);
    case uiClass of
      uicList:
        RegisterActivity(URI, category, group, title, TEntityListPresenter, TfrEntityListView); 

      uicItemNew:
        RegisterView(URI, TEntityItemPresenter, TfrEntityItemView);

      uicItem:
        RegisterView(URI, TEntityItemPresenter, TfrEntityItemView);

      uicPickList:
        RegisterView(URI, TEntityPickListPresenter, TfrEntityPickListView);

      uicJournal2: begin
        if (category <> '') and (group <> '') then
          RegisterActivity(URI, category, group, title, TEntityJournalPresenter, TfrEntityJournalView)
        else
          RegisterView(URI, TEntityJournalPresenter, TfrEntityJournalView);
      end;


      uicDoc:
        RegisterView(URI, TEntityItemPresenter, TfrEntityItemView);

      uicDocNew:
        RegisterView(URI, TEntityItemPresenter, TfrEntityItemView);

    end;

    list.Next;
  end;
end;

end.
