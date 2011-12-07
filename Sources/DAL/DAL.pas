unit DAL;

interface
uses Classes, Provider, Sysutils, Contnrs, DBClient;

const
//METADATA
  DATASETPROXY_PROVIDER = 'PlainSQL';
  METADATA_PROVIDER = 'Metadata';
  SERVER_CLASS_NAME = 'TBoosterFrameWork';

type
  TCustomDAL = class(TComponent)
  private
    FNoCacheMetadata: boolean;
  published
  public
    class function EngineName: string; virtual;
    procedure Connect(const AConnectionString: string); virtual; abstract;
    procedure Disconnect; virtual; abstract;
    function RemoteServer: TCustomRemoteServer; virtual; abstract;
    function GetProvider(const AProviderName: string): TDataSetProvider; virtual; abstract;
    property NoCacheMetadata: boolean read FNoCacheMetadata write FNoCacheMetadata;
  end;

  TDALClass = class of TCustomDAL;

  TProviderNameBuilder = class
    const
      EV_PROVIDER = 'EV';
      EO_PROVIDER = 'EO';
    type
      TProviderKind = (pkNone, pkEntityView, pkEntityOper);
  public
    class procedure Decode(const AProviderName: string;
      var AKind: TProviderKind;  var AEntityName, AViewName: string);
    class function Encode(AKind: TProviderKind;
      const AEntityName, AViewName: string): string;
  end;

  TEntityDataRequestKind = (erkReloadRecord, erkInsertDefaults);

procedure RegisterDALEngine(DALClass: TDALClass);
function GetDALEngine(const AEngineName: string): TDALClass;

implementation

var
  EngineList: TClassList;

function Engines: TClassList;
begin
  if EngineList = nil then
    EngineList := TClassList.Create;

  Result := EngineList;
end;

procedure RegisterDALEngine(DALClass: TDALClass);
begin
  Engines.Add(DALClass);
end;

function GetDALEngine(const AEngineName: string): TDALClass;
var
  I: integer;
begin
  for I := 0 to Engines.Count - 1 do
  begin
    Result := TDALClass(Engines[I]);
    if SameText(Result.EngineName, AEngineName) then Exit;
  end;
  raise Exception.CreateFmt('DAL Engine %s not registered', [AEngineName]);
end;

{ TProviderNameBuilder }

class procedure TProviderNameBuilder.Decode(const AProviderName: string;
  var AKind: TProviderKind; var AEntityName, AViewName: string);
// EVXXENTITYNAMEVIEWNAME
// EOXXENTITYNAMEOPERNAME

var
  kindLabel: string;
  entNameLen: integer;
begin

  kindLabel := copy(AProviderName, 1, 2);

  if kindLabel = EV_PROVIDER then
    AKind := pkEntityView
  else if kindLabel = EO_PROVIDER then
    AKind := pkEntityOper
  else
    AKind := pkNone;

  entNameLen := StrToIntDef(copy(AProviderName, 3, 2), 0);

  AEntityName := copy(AProviderName, 5, entNameLen);
  AViewName := copy(AProviderName, entNameLen + 5, MAXINT);

end;

class function TProviderNameBuilder.Encode(AKind: TProviderKind;
  const AEntityName, AViewName: string): string;
var
  kindLabel: string;
begin
  if AKind = pkEntityView then
    kindLabel := EV_PROVIDER
  else if AKind = pkEntityOper then
    kindLabel := EO_PROVIDER
  else
    kindLabel := 'XX';

  Result := format('%s%.2d%s%s', [kindLabel, Length(AEntityName), AEntityName, AViewName]);
end;
{ TCustomDAL }

class function TCustomDAL.EngineName: string;
begin
  Result := '';
end;


end.
