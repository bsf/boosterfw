unit bfwEntityCatalogModuleInit;

interface
uses classes, CoreClasses, EntityCatalogIntf, EntityCatalogManager, EntityUIController,
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

  TEntityCatalogModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;

implementation


{ EntityCatalogModuleInit }

class function TEntityCatalogModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

procedure TEntityCatalogModuleInit.Load;
begin
  WorkItem.WorkItems.Add(TEntityCatalogController);
end;


initialization
  RegisterModule(TEntityCatalogModuleInit);

end.
