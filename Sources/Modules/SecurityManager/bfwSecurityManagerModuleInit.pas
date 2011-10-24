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
  WorkItem.Root.WorkItems.Add(TAdminController.ClassName, TAdminController);
end;

initialization
  RegisterModule(TdxbSecurityManagerModuleInit);
end.
