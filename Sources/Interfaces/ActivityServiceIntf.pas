unit ActivityServiceIntf;

interface
uses classes, CoreClasses, Graphics, SecurityIntf;

const
  EVT_ACTIVITY_LOADING = 'events.OnActivityLoading';
  EVT_ACTIVITY_LOADED = 'events.OnActivityLoaded';

type
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

    procedure SetMenuIndex(Value: integer);
    function GetMenuIndex: integer;
    property MenuIndex: integer read GetMenuIndex write SetMenuIndex;

    function GetShortCut: string;
    procedure SetShortCut(const Value: string);
    property ShortCut: string read GetShortCut write SetShortCut;

    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
    property Image: Graphics.TBitmap read GetImage write SetImage;

    procedure SetUsePermission(Value: boolean);
    function GetUsePermission: boolean;
    property UsePermission: boolean read GetUsePermission write SetUsePermission;

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
