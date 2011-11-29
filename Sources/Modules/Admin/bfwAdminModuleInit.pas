unit bfwAdminModuleInit;

interface
uses classes, CoreClasses,  AdminController, AdminConst, UIServiceIntf;

type
  TbfwAdminModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation

{ TbfwAdminModuleInit }

procedure TbfwAdminModuleInit.Load;
begin
  Localization((WorkItem.Services[IUIService] as IUIService).Locale);

  WorkItem.WorkItems.Add(TAdminController);

end;

initialization
  RegisterModule(TbfwAdminModuleInit);
end.
