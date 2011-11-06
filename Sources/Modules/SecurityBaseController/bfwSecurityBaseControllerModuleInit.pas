unit bfwSecurityBaseControllerModuleInit;

interface
uses classes, CoreClasses,  bfwSecurityBaseController, EntityServiceIntf, SecurityIntf;

type
  TdxbStorageSecurityControllerModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;

implementation

{ TdxbStorageSecurityControllerModuleInit }

class function TdxbStorageSecurityControllerModuleInit.Kind: TModuleKind;
begin
  Result := mkInfrastructure;
end;

procedure TdxbStorageSecurityControllerModuleInit.Load;
begin
  (WorkItem.Services[ISecurityService] as ISecurityService).RegisterSecurityBaseController(
      TSecurityBaseController.Create(Self, WorkItem.Root));
end;


initialization
  RegisterModule(TdxbStorageSecurityControllerModuleInit);

end.
