unit bfwServeModuleInit;

interface
uses classes, CoreClasses, BarCodeScanerController;


type
  TbfwServModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation



{ TbfwServModuleInit }

procedure TbfwServModuleInit.Load;
begin
  WorkItem.WorkItems.Add(TBarCodeScanerController)
end;

initialization
  RegisterModule(TbfwServModuleInit);

end.
