unit bfwSecurityBaseControllerModuleInit;

interface
uses classes, CoreClasses,  bfwSecurityBaseController, EntityServiceIntf, SecurityIntf;

type
  TdxbStorageSecurityControllerModuleInit = class(TComponent, IModule)
  protected
    //IModule
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;
  end;

implementation

{ TdxbStorageSecurityControllerModuleInit }

procedure TdxbStorageSecurityControllerModuleInit.AddServices(AWorkItem: TWorkItem);
begin
    (AWorkItem.Services[ISecurityService] as ISecurityService).RegisterSecurityBaseController(
      TSecurityBaseController.Create(Self, AWorkItem));
end;

procedure TdxbStorageSecurityControllerModuleInit.Load;
begin

end;

procedure TdxbStorageSecurityControllerModuleInit.UnLoad;
begin

end;

initialization
  RegisterEmbededModule(TdxbStorageSecurityControllerModuleInit, mkInfrastructure);

end.
