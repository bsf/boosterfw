unit bfwStorageConnIBXModuleInit;

interface

uses classes, CoreClasses,  bfwStorageConnIBX, EntityServiceIntf;

type
  TdxbStorageConnIBXModuleInit = class(TComponent, IModule)
  protected
    //IModule
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;
  end;

implementation

{ TdxbStorageConnIBXModuleInit }

procedure TdxbStorageConnIBXModuleInit.AddServices(AWorkItem: TWorkItem);
begin
  (AWorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Connections.
      RegisterConnectionFactory(TIBStorageConnectionFactory.Create(Self));
end;

procedure TdxbStorageConnIBXModuleInit.Load;
begin

end;

procedure TdxbStorageConnIBXModuleInit.UnLoad;
begin

end;

initialization
  RegisterEmbededModule(TdxbStorageConnIBXModuleInit, mkInfrastructure);

end.
