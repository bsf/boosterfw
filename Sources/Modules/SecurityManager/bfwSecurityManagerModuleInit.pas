unit bfwSecurityManagerModuleInit;

interface
uses classes, CoreClasses,  AdminController;

type
  TdxbSecurityManagerModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation

{ TdxbSecurityManagerModuleInit }

procedure TdxbSecurityManagerModuleInit.Load;
begin
  WorkItem.Root.WorkItems.Add(TAdminController, TAdminController.ClassName);
end;

initialization
  RegisterModule(TdxbSecurityManagerModuleInit);
end.
