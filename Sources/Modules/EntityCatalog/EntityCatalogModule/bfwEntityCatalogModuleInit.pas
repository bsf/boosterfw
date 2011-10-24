unit bfwEntityCatalogModuleInit;

interface
uses classes, CoreClasses, CustomModule, EntityCatalogIntf, EntityCatalogManager, EntityUIController,
  EntityCatalogController,
  EntityJournalPresenter, EntityJournalView,
  EntityListPresenter, EntityListView,
  EntityNewPresenter, EntityNewView,
  EntityItemPresenter, EntityItemView,
  EntityComplexPresenter, EntityComplexView,
  EntityOrgChartPresenter, EntityOrgChartView,  
  EntityPickListPresenter, EntityPickListView,
  EntitySelectorPresenter, EntitySelectorView,
  EntityDeskPresenter, EntityDeskView,
  EntitySecResProvider;

type

  TdxbEntityCatalogModuleInit = class(TCustomModule)
  public
    class function Kind: TModuleKind; override;
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;

implementation


{ dxbEntityCatalogModuleInit }

class function TdxbEntityCatalogModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

procedure TdxbEntityCatalogModuleInit.OnLoaded;
begin
 // InstantiateController(TEntityCatalogManager);
  InstantiateController(TEntityCatalogController);
end;

procedure TdxbEntityCatalogModuleInit.OnLoading;
begin
 { RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityNewView', TEntityNewPresenter, TfrEntityNewView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityItemView', TEntityItemPresenter, TfrEntityItemView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityComplexView', TEntityComplexPresenter, TfrEntityComplexView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityListView', TEntityListPresenter, TfrEntityListView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityPickListView', TEntityPickListPresenter, TfrEntityPickListView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityJournalView', TEntityJournalPresenter, TfrEntityJournalView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntitySelectorView', TEntitySelectorPresenter, TfrEntitySelectorView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityDeskView', TEntityDeskPresenter, TfrEntityDeskView));
  RegisterEntityUIClass(TEntityUIClassPresenter.Create('IEntityOrgChartView', TEntityOrgChartPresenter, TfrEntityOrgChartView));
  RegisterEntityUIClass(TEntityUIClassSecurityResProvider.Create('ISecurityResProvider'));}
end;

initialization
  RegisterModule(TdxbEntityCatalogModuleInit);

end.
