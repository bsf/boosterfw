unit LicenseService;

interface
uses LicenseServiceIntf, classes, coreclasses, ConfigServiceIntf, sysutils,
  LicenseUtils;

type
  TLicenseService = class(TComponent, ILicenseService)
  const
    LICENSE_FILE_NAME = 'license.dat';
    LICENSE_EXPIRED_KEY = 'Expires';
    LICENSE_TYPE_KEY = 'LT';
  private
    FWorkItem: TWorkItem;
    FLicenseData: TStringList;
    FInitialized: boolean;
    FLicenseStatus: TLicenseStatus;
    FLicenseType: TLicenseType;
    function Config: ISettings;
    procedure LoadLicenseData;
    function GetServer: string;
    procedure Initialize;
  protected
    //ILicenseService
    function GetStatus: TLicenseStatus;
    function GetType: TLicenseType;
    function GetExpires: string;
    function GetDescription: string;
    function GetData(const AName: string): string;
    function GetClientID: string;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;


implementation

{ TLicenseService }

function TLicenseService.Config: ISettings;
begin
  Result := IConfigurationService(FWorkItem.
    Services[IConfigurationService]).Settings;
end;

constructor TLicenseService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FLicenseData := TStringList.Create;
  FLicenseStatus := lsNotRegistered;
  FLicenseType := ltUndefined;
  LoadLicenseData;
end;

destructor TLicenseService.Destroy;
begin
  FLicenseData.Free;
  inherited;
end;


function TLicenseService.GetClientID: string;
begin
  if GetServer = '' then
    Result := LicenseUtils.GetClientID;
end;


function TLicenseService.GetData(const AName: string): string;
begin
  if not FInitialized then
    Initialize;
  Result := FLicenseData.Values[AName];
end;

function TLicenseService.GetDescription: string;
begin
  Result := FLicenseData.Values['Info'];
end;

function TLicenseService.GetExpires: string;
begin
  Result := FLicenseData.Values[LICENSE_EXPIRED_KEY];
end;

function TLicenseService.GetServer: string;
begin
  Result := Config['License.Server'];
end;

function TLicenseService.GetStatus: TLicenseStatus;
begin
  if not FInitialized then
    Initialize;
  Result := FLicenseStatus;
end;

function TLicenseService.GetType: TLicenseType;
begin
  if not FInitialized then
    Initialize;
  Result := FLicenseType;
end;

procedure TLicenseService.Initialize;
var
  expiredDateStr: string;
  dateFormat: TFormatSettings;
begin
  FInitialized := true;
  if LicenseUtils.CheckLicense(FLicenseData.Text) then
  begin
    FLicenseType := TLicenseType(StrToIntDef(FLicenseData.Values[LICENSE_TYPE_KEY], Ord(ltDemo)));

    FLicenseStatus := lsRegistered;

    expiredDateStr := FLicenseData.Values[LICENSE_EXPIRED_KEY];
    if expiredDateStr <> '' then
    begin
      dateFormat := TFormatSettings.Create;
      dateFormat.ShortDateFormat := 'yy-mm-dd';
      dateFormat.DateSeparator := '-';
      if Date > StrToDateDef(expiredDateStr, Date(), dateFormat) then
        FLicenseStatus := lsExpired;
    end;
  end;
end;

procedure TLicenseService.LoadLicenseData;
var
  licenseFile: string;
begin
  //check data do later!!! for best secure
  if GetServer = '' then
  begin
    licenseFile := ExtractFilePath(ParamStr(0)) + LICENSE_FILE_NAME;
    if FileExists(licenseFile) then
      FLicenseData.LoadFromFile(licenseFile);
  end;
end;

end.
