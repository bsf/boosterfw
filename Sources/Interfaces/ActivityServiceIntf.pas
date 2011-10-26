unit ActivityServiceIntf;

interface
uses classes, CoreClasses, Graphics, SecurityIntf;

const
  EVT_ACTIVITY_LOADING = 'events.OnActivityLoading';
  EVT_ACTIVITY_LOADED = 'events.OnActivityLoaded';

type

  IActivities = interface;

  TActivityCheckPermissionCallback = function(const ID: string): boolean;


  IActivity = interface
  ['{0A8B7686-2831-4A6E-9DDB-7A59EF00B880}']
    function ID: string;

    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function GetCategory: string;
    procedure SetCategory(const Value: string);
    function GetGroup: string;
    procedure SetGroup(const Value: string);
    function GetSection: integer;
    procedure SetSection(Value: integer);
    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
    function GetShortCut: string;
    procedure SetShortCut(const Value: string);
    function GetData(const AName: string): Variant;
    procedure SetData(const AName: string; AValue: Variant);
    procedure SetHandler(AHandler: TNotifyEvent);

    function Items: IActivities;
    function Parent: IActivity;

   // procedure AddMainBarLink;
   // procedure RemoveMainBarLink;

    function UsePermission: boolean;
    function UseActivityPermission: boolean;
    function HavePermission: boolean;
    function InheritPermission: boolean;
    procedure SetCustomPermissionOptions(const AResID, APermID: string);
    procedure Init(const ACategory, AGroup, ACaption: string; AHandler: TNotifyEvent = nil;
      ASection: integer = 0; AShortCut: string = '');
    property Caption: string read GetCaption write SetCaption;
    property Category: string read GetCategory write SetCategory;
    property Group: string read GetGroup write SetGroup;
    property Section: integer read GetSection write SetSection;
    property Image: Graphics.TBitmap read GetImage write SetImage;
    property ShortCut: string read GetShortCut write SetShortCut;
    property Data[const AName: string]: Variant read GetData write SetData;
  end;

  IActivities = interface
  ['{81212938-96AF-4322-A9F0-F40DA0E88B04}']
    function Add(const ID: string; AUseActivityPermission: boolean = true;
      InheritPermission: boolean = true): IActivity;
    procedure Remove(const ID: string);
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivity;
    function Find(const ID: string): IActivity;
    function GetByID(const ID: string): IActivity;
    property Item[const ID: string]: IActivity read GetByID; default;
  end;

//---------------------- LAYOUTS -----------------------------------------------
  IActivityLayoutCategory = interface;
  IActivityLayoutGroups = interface;
  IActivityLayoutGroup = interface;


  IActivityLayoutItemLink = interface
  ['{18CFB04C-FF8E-415B-A3AE-8E455B45017E}']
    function ItemID: string;
    function Group: IActivityLayoutGroup;
  end;

  IActivityLayoutItemLinks = interface
  ['{D5D2BB5A-E96A-4114-9744-F676B186A3D2}']
    function Add(const ItemID: string): IActivityLayoutItemLink;
    procedure Remove(const ItemID: string);
    procedure Delete(AIndex: integer);
    function GetItem(AIndex: integer): IActivityLayoutItemLink;
    function Count: integer;
  end;

  IActivityLayoutGroup = interface
  ['{80EF1802-1612-4443-97E8-8774C49AB53A}']
    function Caption: string;
    function ItemLinks: IActivityLayoutItemLinks;
    function Category: IActivityLayoutCategory;
  end;

  IActivityLayoutGroups = interface
  ['{3300D71F-2265-480E-B7A0-FEA0DAE38F31}']
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivityLayoutGroup;
    function FindOrCreate(const ACaption: string): IActivityLayoutGroup;
    property Item[const ACaption: string]: IActivityLayoutGroup read FindOrCreate; default;
  end;

  IActivityLayoutCategory = interface
  ['{4FE59F3F-A702-4B4F-A4F5-5CEC0EF8BAB3}']
    function Groups: IActivityLayoutGroups;
    function Caption: string;
    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
  end;

  IActivityLayoutCategories = interface
  ['{7C4A6EF1-01FB-48B2-A4B3-143EDD33BE54}']
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivityLayoutCategory;
    function FindOrCreate(const ACaption: string): IActivityLayoutCategory;
    property Item[const ACaption: string]: IActivityLayoutCategory read FindOrCreate; default;
  end;

  IActivityLayout = interface
  ['{B1B2C205-DD37-457E-B612-49281404D82D}']
    function Caption: string;
    function Categories: IActivityLayoutCategories;
  end;

  IActivityLayouts = interface
  ['{199FB763-DCA9-4975-A14D-05554018ED21}']
    function Add(const Caption: string): IActivityLayout;
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivityLayout;
    property Item[AIndex: integer]: IActivityLayout read GetItem; default;
    function Find(const ACaption: string): integer;
    function GetActive: integer;
    procedure SetActive(AIndex: integer);
    property Active: integer read GetActive write SetActive;
  end;

//--------------------------- MANAGER ------------------------------------------
  IActivityManagerService = interface
  ['{07F4CD9B-C9C6-4448-BB6C-96C068E6BAE4}']
    function Layouts: IActivityLayouts;
    function Items: IActivities;
  end;

  IActivityInfo = interface
  ['{0B5ABC3C-A45F-4C22-82F9-27BA2001BCFD}']
    function URI: string;

    procedure SetActivityClass(const Value: string);
    function GetActivityClass: string;
    property ActivityClass: string read GetActivityClass write SetActivityClass;

    function EntityName: string;
    function EntityViewName: string;
    function Params: TStrings;
    function Outs: TStrings;

    procedure SetTitle(const Value: string);
    function GetTitle: string;
    property Title: string read GetTitle write SetTitle;

    procedure SetGroup(const Value: string);
    function GetGroup: string;
    property Group: string read GetGroup write SetGroup;

    procedure SetGroupSection(Value: integer);
    function GetGroupSection: integer;
    property GroupSection: integer read GetGroupSection write SetGroupSection;

    function GetShortCut: string;
    procedure SetShortCut(const Value: string);
    property ShortCut: string read GetShortCut write SetShortCut;

    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
    property Image: Graphics.TBitmap read GetImage write SetImage;

    function OptionExists(const AName: string): boolean;
    function OptionValue(const AName: string): string;
  end;

  IActivityInfos = interface
    function Count: integer;
    function Item(AIndex: integer): IActivityInfo;
  end;

  TActivityBuilder = class(TObject)
  public
    function ActivityClass: string; virtual; abstract;
    procedure Build(ActivityInfo: IActivityInfo); virtual; abstract;
  end;

  IActivityService = interface
  ['{71AA0CBE-C661-4402-98F8-8544E5B3CC6E}']
    procedure RegisterActivityClass(ABuilder: TActivityBuilder);
    function RegisterActivityInfo(const URI: string): IActivityInfo;
    function ActivityInfo(const URI: string): IActivityInfo;
    function Infos: IActivityInfos;
  end;


implementation

end.
