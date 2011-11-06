unit bfwEntityUIModuleInit;

interface
uses CoreClasses, EntityCatalogController;

type
  TEntityUIModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation



{ TEntityUIModuleInit }

procedure TEntityUIModuleInit.Load;
begin
  WorkItem.WorkItems.Add(TEntityCatalogController)
end;

initialization
  RegisterModule(TEntityUIModuleInit);
end.
