unit bfwGadgetCatalogModuleInit;

interface

uses classes, CoreClasses, BarCodeScanerController;


type
  TGadgetCatalogModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation



{ TGadgetCatalogModuleInit }

procedure TGadgetCatalogModuleInit.Load;
begin
  WorkItem.WorkItems.Add(TBarCodeScanerController)
end;

initialization
  RegisterModule(TGadgetCatalogModuleInit);
  
end.
