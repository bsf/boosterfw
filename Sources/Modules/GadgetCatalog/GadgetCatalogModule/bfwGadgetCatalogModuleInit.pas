unit bfwGadgetCatalogModuleInit;

interface

uses classes, CoreClasses, CustomModule, BarCodeScanerController;


type
  TdxbGadgetCatalogModuleInit = class(TCustomModule)
  public
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;

implementation



{ TdxbGadgetCatalogModuleInit }

procedure TdxbGadgetCatalogModuleInit.OnLoaded;
begin
  InstantiateController(TBarCodeScanerController);
end;

procedure TdxbGadgetCatalogModuleInit.OnLoading;
begin
  inherited;

end;

initialization
  RegisterModule(TdxbGadgetCatalogModuleInit);
  
end.
