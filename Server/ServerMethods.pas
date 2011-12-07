unit ServerMethods;

interface

uses
  SysUtils, Classes, DSServer, Provider, DAL,  inifiles, strUtils;

type
  TBoosterFrameWork = class(TDSServerModule)
  const
    CONFIG_CONNECTION_ENGINE = 'Connection.Engine';
    CONFIG_CONNECTION_PARAMS = 'Connection.Params';

  private
    FConfigAlias: string;
    FConfig: TMemIniFile;
    FConnected: boolean;
    FDAL: TCustomDAL;
    function GetConnectionString(const AUserName, APassword: string): string;
    function GetConnectionEngine: string;
  protected
    function GetProvider(const ProviderName: string): TCustomProvider; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Connect(const AUserName, APassword: string);
  end;

implementation

{$R *.dfm}

{ TBoosterFrameWork }

procedure TBoosterFrameWork.Connect(const AUserName, APassword: string);
begin
  FDAL.Connect(GetConnectionString(AUserName, APassword));
  FConnected := true;
end;

constructor TBoosterFrameWork.Create(AOwner: TComponent);
begin
  inherited;
  FConfigAlias := 'Default';
  FConfig := TMemIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  FDAL := GetDALEngine(GetConnectionEngine).Create(Self);
end;

function TBoosterFrameWork.GetConnectionEngine: string;
begin
  Result := FConfig.ReadString(FConfigAlias, CONFIG_CONNECTION_ENGINE, 'IBE');
end;

function TBoosterFrameWork.GetConnectionString(const AUserName,
  APassword: string): string;
begin
  Result := FConfig.ReadString(FConfigAlias, CONFIG_CONNECTION_PARAMS, '');
  Result := ReplaceText(Result, '%USERID%', AUserName);
  Result := ReplaceText(Result, '%PASSWORD%', APassword);
end;

function TBoosterFrameWork.GetProvider(
  const ProviderName: string): TCustomProvider;
begin
  if not FConnected then
    raise Exception.Create('Client not connected');

  Result := FDAL.GetProvider(ProviderName);
end;

end.

