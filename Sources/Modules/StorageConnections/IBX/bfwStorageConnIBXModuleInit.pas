unit bfwStorageConnIBXModuleInit;

interface

uses classes, CoreClasses,  bfwStorageConnIBX, EntityServiceIntf;

type
  TdxbStorageConnIBXModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;

implementation

{ TdxbStorageConnIBXModuleInit }

class function TdxbStorageConnIBXModuleInit.Kind: TModuleKind;
begin
  Result := mkInfrastructure;
end;

procedure TdxbStorageConnIBXModuleInit.Load;
begin
  (WorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Connections.
      RegisterConnectionFactory(TIBStorageConnectionFactory.Create(Self));
end;

initialization
  RegisterModule(TdxbStorageConnIBXModuleInit);

end.
