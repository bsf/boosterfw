unit ConfigService;

interface
uses coreClasses, ConfigServiceIntf, Classes, IniFiles, SysUtils, Contnrs, StrUtils, windows,
  ConfigStorage;

const
//Common settings names
  setting_PROFILE_KEY = 'Profile.Key';

type
  TSetting = class(TComponent, ISetting)
  private
    FSettingName: string;
    FCaption: string;
    FCategory: string;
    FDescription: string;
    FDefaultValue: string;
    FEditor: TSettingEditor;
    FStorageLevels: TSettingStorageLevels;
    FNeedRestartApp: boolean;
  protected
    //ISetting
    function GetSettingName: string;
    function ISetting.GetName = GetSettingName;
    function GetCaption: string;
    procedure SetCaption(const AValue: string);
    function GetCategory: string;
    procedure SetCategory(const AValue: string);
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    function GetDefaultValue: string;
    procedure SetDefaultValue(const AValue: string);
    function GetStoredValue(ALevel: TSettingStorageLevel; AUseDefault: boolean = true): string;
    procedure SetStoredValue(const AValue: string; ALevel: TSettingStorageLevel);
    function GetStoredLevel(ALevel: TSettingStorageLevel): TSettingStorageLevel;
    function GetEditor: TSettingEditor;
    procedure SetEditor(AValue: TSettingEditor);
    function GetStorageLevels: TSettingStorageLevels;
    procedure SetStorageLevels(ALevels: TSettingStorageLevels);

    function GetNeedRestartApp: boolean;
    procedure SetNeedRestartApp(AValue: boolean);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TSettings = class(TComponent, ISettings)
  private
    FConfigStorage: TConfigStorage;
    FItems: TComponentList;
    FFileName: string;
    FRuntimeIni: TMemIniFile;
    FCurrentAlias: string;
    FUserID: string;
   // FHost: string;
    FWorkItem: TWorkItem;
    function ParseValue(const Value: string): string;
    function GetStoredValue(const AName: string; ALevel: TSettingStorageLevel): string;
    procedure SetStoredValue(const AName, AValue: string; ALevel: TSettingStorageLevel);
    function GetStoredLevel(const AName: string; ALevel: TSettingStorageLevel): TSettingStorageLevel;
    function GetFileName: string;

  protected
    function GetValue(const AName: string): string;
    procedure SetValue(const AName, AValue: string);

    function Aliases: TStrings;

    function GetCurrentAlias: string;
    procedure SetCurrentAlias(const AliasName: string);
    property CurrentAlias: string read GetCurrentAlias write SetCurrentAlias;

    function GetUserID: string;
    procedure SetUserID(const AValue: string);
    property UserID: string read GetUserID write SetUserID;

    function Add(const AName: string): ISetting;
    function GetItem(AIndex: integer): ISetting;
    function GetItemByName(const AName: string): ISetting;
    function Count: integer;
  public
    constructor Create(AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    procedure LoadHostProfileSettings(AProfile: IProfile);
    procedure LoadUserProfileSettings(AProfile: IProfile);
  end;

  TProfile = class(TComponent, IProfile)
  const
    PROFILE_DATA_FOLDER = 'ViewPreference';
  private
    FWorkItem: TWorkItem;
    FLocation: string;
    function GetValuesFileName: string;
    function GetAbsolutePath(const ARelativePath: string): string;
  protected
    //IProfile
    function GetLocation: string;
    procedure LoadData(const ARelativePath, AFileName: string; AData: TStream);
    procedure SaveData(const ARelativePath, AFileName: string; AData: TStream);
    procedure SetValue(const AName, AValue: string);
    function GetValue(const AName: string): string;
  public
    constructor Create(const ALocation: string; AWorkItem: TWorkItem); reintroduce;
  end;

  TConfigurationService = class(TComponent, IConfigurationService)
  private
    FWorkItem: TWorkItem;
    FUserProfile: TProfile;
    FHostProfile: TProfile;
    FSettings: TSettings;
  protected
    function Settings: ISettings;
    function UserProfile: IProfile;
    function HostProfile: IProfile;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;


implementation



{ TConfigurationService }

function TConfigurationService.Settings: ISettings;
begin
  Result := FSettings;
end;

function TConfigurationService.UserProfile: IProfile;
begin
  Result := FUserProfile;
end;

constructor TConfigurationService.Create(AOwner: TComponent;
  AWorkItem: TWorkItem);
var
  profileHostLocation, profileUserLocation: string;
  localAppDataKey: string;
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;

  FSettings := TSettings.Create(FWorkItem);

  if Settings[setting_PROFILE_KEY] <> 'Portable' then
  begin
    localAppDataKey := Settings[setting_PROFILE_KEY];

    if localAppDataKey = '' then
      localAppDataKey := ChangeFileExt(ExtractFileName(ParamStr(0)), '');

    profileHostLocation := GetEnvironmentVariable('PROGRAMDATA'); //Win7
    if profileHostLocation <> '' then
      profileHostLocation := profileHostLocation + '\' + localAppDataKey + '\Profile\'
    else
     //WinXP
      profileHostLocation := GetEnvironmentVariable('ALLUSERSPROFILE') +
        '\Application Data\' + localAppDataKey + '\Profile\';

    profileUserLocation := GetEnvironmentVariable('APPDATA') + '\' + localAppDataKey + '\Profile\';

  end
  else
  begin
    profileHostLocation := ExtractFilePath(ParamStr(0)) + '\Profile\Host\';
    profileUserLocation := ExtractFilePath(ParamStr(0)) + '\Profile\User\';
  end;

  FHostProfile := TProfile.Create(profileHostLocation, FWorkItem);
  FSettings.LoadHostProfileSettings(FHostProfile);

  FUserProfile := TProfile.Create(profileUserLocation, FWorkItem);
  FSettings.LoadUserProfileSettings(FUserProfile);

end;

destructor TConfigurationService.Destroy;
begin
  FUserProfile.Free;
  inherited;
end;


function TConfigurationService.HostProfile: IProfile;
begin
  Result := FHostProfile;
end;

{ TSettings }

function TSettings.Add(const AName: string): ISetting;
var
  item: TSetting;
begin
  item := TSetting.Create(Self);
  item.FSettingName := AName;
  FItems.Add(item);
  Result := item as ISetting;
end;

function TSettings.Aliases: TStrings;
begin
  Result := FConfigStorage.GetAliases;
end;

function TSettings.Count: integer;
begin
  Result := FItems.Count;
end;

constructor TSettings.Create(AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FItems := TComponentList.Create(true);
  FWorkItem := AWorkItem;

  FConfigStorage := TConfigStorage.Create(GetFileName);
  FRuntimeIni := TMemIniFile.Create('');

  SetValue('ROOTDIR', ExtractFilePath(ParamStr(0)));
  SetValue('HOSTNAME', GetEnvironmentVariable('COMPUTERNAME'));
end;

destructor TSettings.Destroy;
begin
  FItems.Free;
  FRuntimeIni.Free;
  FConfigStorage.Free;
  inherited;
end;


function TSettings.GetCurrentAlias: string;
begin
  Result := FCurrentAlias;
end;

function TSettings.GetFileName: string;
begin
  if FFileName = '' then
  begin
    FFileName := ChangeFileExt(ParamStr(0), '.ini');
    if not FileExists(FFileName) then
    begin
      Windows.MessageBox(0,
        PChar(format('Config file %s not found.' +  #10#13 +
                     'Run application with command switch -makeconfig and edit new config file.'
         , [FFileName])),
        PChar(ExtractFileName(ParamStr(0))), MB_OK);
      Halt(1);
    end;
  end;
  Result := FFileName;
end;

function TSettings.GetItem(AIndex: integer): ISetting;
begin
  Result := FItems[AIndex] as ISetting;
end;

function TSettings.GetItemByName(const AName: string): ISetting;
var
  I: integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Result := FItems[I] as ISetting;
    if SameText(Result.Name, AName) then Exit;
  end;
  Result := nil;
end;

function TSettings.GetStoredLevel(const AName: string;
   ALevel: TSettingStorageLevel): TSettingStorageLevel;
var
  I: TSettingStorageLevel;
begin
  for I := ALevel to High(TSettingStorageLevel) do
  begin
    Result := I;
    if FConfigStorage.LoadValue(AName,  I) <> '' then Exit;
  end;

  Result := slNone;
end;

function TSettings.GetStoredValue(const AName: string; ALevel: TSettingStorageLevel): string;
var
  I: TSettingStorageLevel;
begin
  for I := ALevel to High(TSettingStorageLevel) do
  begin
    Result := FConfigStorage.LoadValue(AName,  I);
    if Result <> '' then Exit;
  end;
end;

function TSettings.GetUserID: string;
begin
  Result := FUserID;
end;

function TSettings.GetValue(const AName: string): string;
var
  settingItem: ISetting;
begin
  Result := FRuntimeIni.ReadString('', AName, '');
  if Result <> '' then Exit;

  FindCmdLineSwitch(AName, Result);

  if Result = '' then
    Result := GetStoredValue(AName, slNone);
     
  if Result = '' then
  begin
    settingItem := GetItemByName(AName);
    if Assigned(settingItem) then
      Result := settingItem.DefaultValue;
  end;

  Result := ParseValue(Result);
end;

procedure TSettings.LoadHostProfileSettings(AProfile: IProfile);
begin
  FConfigStorage.SetHostProfile(AProfile);
end;

procedure TSettings.LoadUserProfileSettings(AProfile: IProfile);
begin
  FConfigStorage.SetUserProfile(AProfile);
end;

function TSettings.ParseValue(const Value: string): string;
var
  I: integer;
  Macro: string;
  MacroValue: string;
  OutStr: string;
  BeginMacro: boolean;
  CurChar: char;
begin

  BeginMacro := false;

  for I := 1 to Length(Value) do
  begin
    CurChar := Value[I];
    if BeginMacro then
    begin
      if CurChar = '%' then
      begin
        BeginMacro := false;
        if Macro <> '' then
          MacroValue := GetValue(Macro)//SysUtils.GetEnvironmentVariable(Macro)
        else
          MacroValue := '%%';
        OutStr := OutStr + MacroValue;
        Macro := '';
      end
      else
      begin
        Macro := Macro + CurChar;
      end
    end
    else
    begin
      if CurChar = '%' then
        BeginMacro := true
      else
        OutStr := OutStr + CurChar;
    end
  end;
  if BeginMacro then
    OutStr := OutStr + '%' + Macro;
  Result := OutStr;

end;

procedure TSettings.SetCurrentAlias(const AliasName: string);
begin
  FCurrentAlias := AliasName;
  FConfigStorage.SetCurrentAlias(FCurrentAlias);
end;

procedure TSettings.SetStoredValue(const AName, AValue: string;
  ALevel: TSettingStorageLevel);
begin
  FConfigStorage.SaveValue(AName, AValue, ALevel);
end;

procedure TSettings.SetUserID(const AValue: string);
begin
  FUserID := AValue;
end;

procedure TSettings.SetValue(const AName, AValue: string);
begin
  FRuntimeIni.WriteString('', AName, AValue);
end;


{ TProfile }

constructor TProfile.Create(const ALocation: string; AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FWorkItem := AWorkItem;
  FLocation := ALocation;

  if not DirectoryExists(FLocation) then
    if not ForceDirectories(FLocation) then
    begin
      Windows.MessageBox(0,
        PChar(format('Can not create profile folder %s', [FLocation])),
        PChar(ExtractFileName(ParamStr(0))), MB_OK);
      Halt(1);
    end;

end;

function TProfile.GetAbsolutePath(const ARelativePath: string): string;
begin
  Result := GetLocation + ARelativePath;
  if not DirectoryExists(Result) then
    ForceDirectories(Result);
end;

function TProfile.GetLocation: string;
begin
  Result := FLocation;
end;

function TProfile.GetValuesFileName: string;
begin
  Result := GetLocation + 'values.ini';
end;

procedure TProfile.LoadData(const ARelativePath, AFileName: string;
  AData: TStream);
var
  fileName: string;
  fileData: TFileStream;
begin
  fileName := GetAbsolutePath(PROFILE_DATA_FOLDER + ARelativePath) + AFileName;
  if FileExists(fileName) then
  begin
    fileData := TFileStream.Create(fileName, fmOpenRead or fmShareDenyWrite);
    try
      AData.CopyFrom(fileData, fileData.Size);
    finally
      fileData.Free;
    end;
  end;
end;

function TProfile.GetValue(const AName: string): string;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(GetValuesFileName);
  try
    Result := Ini.ReadString('Default', AName, '');
  finally
    Ini.Free;
  end;
end;

procedure TProfile.SaveData(const ARelativePath, AFileName: string;
  AData: TStream);
var
  fileName: string;
  fileData: TFileStream;
begin
  fileName :=  GetAbsolutePath(PROFILE_DATA_FOLDER + ARelativePath) + AFileName;
  fileData := TFileStream.Create(fileName, fmCreate);
  try
    AData.Position := 0;
    fileData.CopyFrom(AData, AData.Size);
  finally
    fileData.Free;
  end;
end;

procedure TProfile.SetValue(const AName, AValue: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(GetValuesFileName);
  try
    Ini.WriteString('Default', AName, AValue);
    Ini.UpdateFile;
    FWorkItem.EventTopics[ET_PROFILE_CHANGED].Fire(FWorkItem, AName);
  finally
    Ini.Free;
  end;
end;

{ TSetting }

constructor TSetting.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStorageLevels := [slHostProfile, slAlias, slDefault];// [Low(TSettingStorageLevel)..High(TSettingStorageLevel)] - [slNone];
end;

function TSetting.GetCaption: string;
begin
  Result := FCaption;
end;

function TSetting.GetCategory: string;
begin
  Result := FCategory;
end;

function TSetting.GetDefaultValue: string;
begin
  Result := FDefaultValue;
end;

function TSetting.GetDescription: string;
begin
  Result := FDescription;
end;

function TSetting.GetEditor: TSettingEditor;
begin
  Result := FEditor;
end;

function TSetting.GetNeedRestartApp: boolean;
begin
  Result := FNeedRestartApp;
end;

function TSetting.GetSettingName: string;
begin
  Result := FSettingName;
end;

function TSetting.GetStoredLevel(ALevel: TSettingStorageLevel): TSettingStorageLevel;
begin
  Result := (Owner as TSettings).GetStoredLevel(FSettingName, ALevel);
end;

function TSetting.GetStorageLevels: TSettingStorageLevels;
begin
  Result := FStorageLevels;
end;

function TSetting.GetStoredValue(ALevel: TSettingStorageLevel; AUseDefault: boolean): string;
begin
  Result := (Owner as TSettings).GetStoredValue(FSettingName, ALevel);
  if (Result = '') and AUseDefault then
    Result := GetDefaultValue;
end;


procedure TSetting.SetCaption(const AValue: string);
begin
  FCaption := AValue;
end;

procedure TSetting.SetCategory(const AValue: string);
begin
  FCategory := AValue;
end;

procedure TSetting.SetDefaultValue(const AValue: string);
begin
  FDefaultValue := AValue;
end;

procedure TSetting.SetDescription(const AValue: string);
begin
  FDescription := AValue;
end;

procedure TSetting.SetEditor(AValue: TSettingEditor);
begin
  FEditor := AValue;
end;

procedure TSetting.SetNeedRestartApp(AValue: boolean);
begin
  FNeedRestartApp := AValue;
end;


procedure TSetting.SetStorageLevels(ALevels: TSettingStorageLevels);
begin
  FStorageLevels := ALevels;
end;

procedure TSetting.SetStoredValue(const AValue: string;
  ALevel: TSettingStorageLevel);
begin
  (Owner as TSettings).SetStoredValue(FSettingName, AValue, ALevel);
end;

end.
