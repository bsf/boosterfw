unit DAL_DSE;

interface
uses DAL, classes, provider, SqlExpr, DSConnect, DBClient, DbxDatasnap,
  DSHTTPLayer, DAL_DSE_ClientProxy;

type
  TDAL_DSE = class(TCustomDAL)
  private
    FSQLConnection: TSQLConnection;
    FDSProviderConnection: TDSProviderConnection;
    procedure RemoteConnect(const AUserName, APassword: string);
  public
    class function EngineName: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect(const AConnectionString: string); override;
    procedure Disconnect; override;
    function RemoteServer: TCustomRemoteServer; override;
  end;

implementation

{ TDAL_DSE }

procedure TDAL_DSE.Connect(const AConnectionString: string);
var
  prm: TStringList;
  I: integer;
  user: string;
  pass: string;
begin

  prm := TStringList.Create;
  try
    ExtractStrings([';'], [], PChar(AConnectionString), prm);
    user := prm.Values['UserName'];
    pass := prm.Values['Password'];
    for I := 0 to prm.Count - 1 do
      FSQLConnection.Params.Values[prm.Names[I]] := prm.ValueFromIndex[I];
  finally
    prm.Free;
  end;

  FDSProviderConnection.Connected := true;
  try
    RemoteConnect(user, pass);
  except
    FDSProviderConnection.Connected := false;
    raise;
  end;

end;

constructor TDAL_DSE.Create(AOwner: TComponent);
begin
  inherited;
  FDSProviderConnection := TDSProviderConnection.Create(Self);
  FDSProviderConnection.ServerClassName := SERVER_CLASS_NAME;

  FSQLConnection := TSQLConnection.Create(Self);
  FSQLConnection.DriverName := 'DataSnap';
  FSQLConnection.LoginPrompt := false;

  FSQLConnection.Params.Values['CommunicationProtocol'] := 'http';
  FSQLConnection.Params.Values['DatasnapContext'] := 'datasnap/';

  FDSProviderConnection.SQLConnection := FSQLConnection;

end;

destructor TDAL_DSE.Destroy;
begin

  inherited;
end;

procedure TDAL_DSE.Disconnect;
begin
  inherited;

end;

class function TDAL_DSE.EngineName: string;
begin
  Result := 'DSE';
end;

procedure TDAL_DSE.RemoteConnect(const AUserName, APassword: string);
var
  clientProxy: TBoosterFrameWorkClient;
begin
  clientProxy := TBoosterFrameWorkClient.Create(FSQLConnection.DBXConnection);
  try
    clientProxy.Connect(AUserName, APassword);
  finally
    clientProxy.Free;
  end;
end;

function TDAL_DSE.RemoteServer: TCustomRemoteServer;
begin
  Result := FDSProviderConnection;
end;


initialization
  DAL.RegisterDALEngine(TDAL_DSE);

end.
