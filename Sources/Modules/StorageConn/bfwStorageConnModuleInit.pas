unit bfwStorageConnModuleInit;

interface

uses classes, CoreClasses, StorageConnIBX, EntityServiceIntf;

type
  TbfwStorageConnModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;

implementation

{ TbfwtorageConnIBXModuleInit }

class function TbfwStorageConnModuleInit.Kind: TModuleKind;
begin
  Result := mkInfrastructure;
end;

procedure TbfwStorageConnModuleInit.Load;
begin
  (WorkItem.Services[IEntityService] as IEntityService).
    Connections.
      RegisterConnectionFactory(TIBStorageConnectionFactory.Create(Self));
end;

initialization
  RegisterModule(TbfwStorageConnModuleInit);

end.
