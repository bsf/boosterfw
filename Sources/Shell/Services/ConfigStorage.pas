unit ConfigStorage;

interface
uses classes, inifiles, ConfigServiceIntf, sysutils;

const
  APPCONFIG_DEFAULT_SECTION = 'Default';

type
  TConfigStorage = class(TComponent)
  private
    FUserProfile: IProfile;
    FHostProfile: IProfile;
    FConfigFileName: string;
    FAliases: TStringList;
    FCurrentAlias: string;
  public
    constructor Create(const AFileName: string); reintroduce;
    destructor Destroy; override;
    function GetAliases: TStrings;
    function LoadValue(const AName: string; ALevel: TSettingStorageLevel): string;
    procedure SaveValue(const AName, AValue: string; ALevel: TSettingStorageLevel);
    procedure SetUserProfile(AProfile: IProfile);
    procedure SetHostProfile(AProfile: IProfile);
    procedure SetCurrentAlias(const AAlias: string);
  end;

implementation

{ TConfigStorage }

constructor TConfigStorage.Create(const AFileName: string);
begin
  inherited Create(nil);
  FConfigFileName := AFileName;
  FAliases := TStringList.Create;
end;

destructor TConfigStorage.Destroy;
begin
  FAliases.Free;
  inherited;
end;

function TConfigStorage.GetAliases: TStrings;
var
  ini: TMemIniFile;
  I: integer;
begin
  FAliases.Clear;
  ini := TMemIniFile.Create(FConfigFileName);
  try
    ini.ReadSections(FAliases);
  finally
    ini.Free;
  end;

  for I := FAliases.Count - 1 downto 0 do
    if (Pos('.HOST.', UpperCase(FAliases[I])) > 0) or
       (Pos('.USER.', UpperCase(FAliases[I])) > 0) or
       (SameText(FAliases[I], APPCONFIG_DEFAULT_SECTION)) then
       FAliases.Delete(I);
  Result := FAliases;

end;

function TConfigStorage.LoadValue(const AName: string;
  ALevel: TSettingStorageLevel): string;

  function GetValueFromIni(const AFileName, ASection, AName: string): string;
  var
    Ini: TMemIniFile;
  begin
    Ini := TMemIniFile.Create(AFileName);
    try
      Result := Ini.ReadString(ASection, AName, '');
    finally
      Ini.Free;
    end;
  end;

var
  section: string;
  fileName: string;
begin
  fileName := '';
  case ALevel of
    slCommon: begin
      section := APPCONFIG_DEFAULT_SECTION;
      fileName := FConfigFileName;
    end;
    slAlias: begin
      section := FCurrentAlias;
      fileName := FConfigFileName;
    end;
    slHostProfile: begin
       if Assigned(FHostProfile) then
         fileName := FHostProfile.GetLocation + 'settings.ini';
       section := '';
    end;
    slUserProfile: begin
       if Assigned(FUserProfile) then
         fileName := FUserProfile.GetLocation + 'settings.ini';
       section := '';
    end;
  end;

  if fileName <> '' then
    Result := GetValueFromIni(fileName, Section, AName);

end;


procedure TConfigStorage.SaveValue(const AName, AValue: string; ALevel: TSettingStorageLevel);
  function SetValueToIni(const AFileName, ASection, AName, AValue: string): string;
  var
    Ini: TMemIniFile;
  begin
    Ini := TMemIniFile.Create(AFileName);
    try
      if AValue = '' then
        Ini.DeleteKey(ASection, AName)
      else
        Ini.WriteString(ASection, AName, AValue);
      Ini.UpdateFile;
    finally
      Ini.Free;
    end;
  end;

var
  section: string;
  fileName: string;
begin
  fileName := '';
  case ALevel of
    slCommon: begin
      section := APPCONFIG_DEFAULT_SECTION;
      fileName := FConfigFileName;
    end;
    slAlias: begin
      section := FCurrentAlias;
      fileName := FConfigFileName;
    end;
    slHostProfile: begin
       if Assigned(FHostProfile) then
         fileName := FHostProfile.GetLocation + 'settings.ini';
       section := '';
    end;
    slUserProfile: begin
       if Assigned(FUserProfile) then
         fileName := FUserProfile.GetLocation + 'settings.ini';
       section := '';
    end;
  end;

  if fileName <> '' then
    SetValueToIni(fileName, Section, AName, AValue);
end;

procedure TConfigStorage.SetCurrentAlias(const AAlias: string);
begin
  FCurrentAlias := AAlias;
end;

procedure TConfigStorage.SetHostProfile(AProfile: IProfile);
begin
  FHostProfile := AProfile;
end;

procedure TConfigStorage.SetUserProfile(AProfile: IProfile);
begin
  FUserProfile := AProfile;
  
end;

end.
