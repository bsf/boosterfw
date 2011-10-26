unit bfwEntityCatalogModuleInit;

interface
uses CoreClasses, EntityCatalogController;
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
