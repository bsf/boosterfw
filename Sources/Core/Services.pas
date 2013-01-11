unit Services;

interface
uses Classes, CoreClasses, ComObj, Sysutils;

type
  TServices = class(TComponent, IServices)
  private
    FItems: TInterfaceList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Add(const AService: IInterface);
    procedure Remove(const AService: IInterface);
    procedure Clear;
    function Query(const AService: TGUID; var Obj): boolean;
    function Get(const AService: TGUID): IInterface;
    property GetItem[const AService: TGUID]: IInterface read Get; default;
  end;

implementation

{ TServices }

constructor TServices.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TInterfaceList.Create;
end;

destructor TServices.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TServices.Add(const AService: IInterface);
begin
  FItems.Add(AService);
end;

procedure TServices.Remove(const AService: IInterface);
begin
  FItems.Remove(AService);
end;

function TServices.Get(const AService: TGUID): IInterface;
var
  I: integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].QueryInterface(AService, Result) = 0 then Exit;

  if Result = nil then
    raise Exception.Create('Service ' + GUIDToString(AService) + ' not found.');
end;


function TServices.Query(const AService: TGUID; var Obj): boolean;
var
  I: integer;
begin
  Result := False;
  for I := 0 to FItems.Count - 1 do
  begin
    Result := FItems[I].QueryInterface(AService, Obj) = 0;
    if Result then Exit;
  end;
end;

procedure TServices.Clear;
begin
  FItems.Clear;
end;

end.
