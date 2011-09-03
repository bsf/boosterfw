unit bfwSecurityManagerModuleInit;

interface
uses classes, CoreClasses,  AdminController;

type
  TdxbSecurityManagerModuleInit = class(TComponent, IModule)
  protected
    //IModule
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;
  end;

implementation

{ TdxbSecurityManagerModuleInit }

procedure TdxbSecurityManagerModuleInit.AddServices(AWorkItem: TWorkItem);
begin
  AWorkItem.WorkItems.Add(TAdminController.ClassName, TAdminController);
end;

procedure TdxbSecurityManagerModuleInit.Load;
begin

end;

procedure TdxbSecurityManagerModuleInit.UnLoad;
begin

end;

initialization
  RegisterEmbededModule(TdxbSecurityManagerModuleInit, mkExtension);
end.
