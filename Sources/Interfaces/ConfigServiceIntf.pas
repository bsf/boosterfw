unit ConfigServiceIntf;

interface
uses Classes;

const
  ET_PROFILE_CHANGED = '{78AA14D4-3317-4723-861F-044FE9D76A27}';

type
  TSettingStorageLevel = (slNone, slUserProfile, slHostProfile, slAlias, slCommon);
  TSettingStorageLevels = set of TSettingStorageLevel;

  TSettingEditor = (seString, seInteger, seBoolean);

  ISetting = interface
  ['{4EA3E558-3C10-4C6B-AD16-049053401006}']
    function GetName: string;
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

    function GetNeedRestartApp: boolean;
    procedure SetNeedRestartApp(AValue: boolean);
    function GetEditor: TSettingEditor;
    procedure SetEditor(AValue: TSettingEditor);
    function GetStorageLevels: TSettingStorageLevels;
    procedure SetStorageLevels(ALevels: TSettingStorageLevels);

    property Name: string read GetName;
    property Caption: string read GetCaption write SetCaption;
    property Category: string read GetCategory write SetCategory;
    property Description: string read GetDescription write SetDescription;
    property DefaultValue: string read GetDefaultValue write SetDefaultValue;
    property Editor: TSettingEditor read GetEditor write SetEditor;
    property StorageLevels: TSettingStorageLevels read GetStorageLevels write SetStorageLevels;
    property NeedRestartApp: boolean read GetNeedRestartApp write SetNeedRestartApp;
  end;

  ISettings = interface
  ['{767481FF-BCFC-4B0B-BD97-909FD88BBFEF}']
    function Aliases: TStrings;

    function GetUserID: string;
    procedure SetUserID(const AValue: string);
    property UserID: string read GetUserID write SetUserID;

    function GetCurrentAlias: string;
    procedure SetCurrentAlias(const AliasName: string);
    property CurrentAlias: string read GetCurrentAlias write SetCurrentAlias;

    function GetValue(const AName: string): string;
    procedure SetValue(const AName, AValue: string);
    property Value[const AName: string]: string read GetValue write SetValue; default;

    function Add(const AName: string): ISetting;
    function GetItem(AIndex: integer): ISetting;
    function GetItemByName(const AName: string): ISetting;
    function Count: integer;
  end;

  IProfile = interface
  ['{8BB41D33-686A-4691-B3BB-205A7606E2EE}']
    function GetLocation: string;
    procedure LoadData(const ARelativePath, AFileName: string; AData: TStream);
    procedure SaveData(const ARelativePath, AFileName: string; AData: TStream);
    //procedure RemoveData(const ARelativePath, AFileName: string);
    procedure SetValue(const AName, AValue: string);
    function GetValue(const AName: string): string;

  end;

  IConfigurationService = interface
  ['{8856F4F2-A486-4D5C-A6AF-3E9916201509}']
    function Settings: ISettings;
    function UserProfile: IProfile;
    function HostProfile: IProfile;
  end;


implementation

end.
