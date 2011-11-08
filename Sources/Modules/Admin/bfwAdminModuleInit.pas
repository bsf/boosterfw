unit bfwAdminModuleInit;

interface
uses classes, CoreClasses,  AdminController;

type
  TbfwAdminModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation

{ TbfwAdminModuleInit }

procedure TbfwAdminModuleInit.Load;
begin
  WorkItem.WorkItems.Add(TAdminController);

end;

initialization
  RegisterModule(TbfwAdminModuleInit);
end.
