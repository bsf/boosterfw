unit NavBarServiceIntf;

interface
uses classes, Graphics;

type
  INavBarCategory = interface;
  INavBarGroup = interface;
  INavBarItems = interface;


  INavBarItem = interface
  ['{6E2320D8-E753-4AC0-8307-2A89DB94B522}']
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


    function Items: INavBarItems;

    property Caption: string read GetCaption write SetCaption;
    property Category: string read GetCategory write SetCategory;
    property Group: string read GetGroup write SetGroup;
    property Section: integer read GetSection write SetSection;
    property Image: Graphics.TBitmap read GetImage write SetImage;
  end;

  INavBarItems = interface
  ['{36A006DB-8737-4731-B29C-D017DA99C3F3}']
    function Add(const ID: string): INavBarItem;
    procedure Remove(const ID: string);
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarItem;
    function Find(const ID: string): INavBarItem;
    function GetByID(const ID: string): INavBarItem;
    property Item[const ID: string]: INavBarItem read GetByID; default;
  end;

  INavBarItemLink = interface
  ['{CD287DC9-4CAD-4CD9-A7CE-BA8C16782BC0}']
    function ItemID: string;
    function Caption: string;
    function Group: INavBarGroup;
    function SectionIndex: integer;
    function Image: Graphics.TBitmap;
  end;

  INavBarItemLinks = interface
  ['{81E25BA5-1148-4124-BC87-00A86D0F22DB}']
    function Add(const AItemID, ACaption: string; AImage: Graphics.TBitmap;
       ASectionIndex: integer = 0): integer;
    procedure Remove(const AItemID: string);
    procedure Delete(AIndex: integer);
    function GetItem(AIndex: integer): INavBarItemLink;
    function Count: integer;
  end;

  INavBarGroup = interface
  ['{15B04684-04B0-4585-9D7B-905E7937957A}']
    function Caption: string;
    function Category: INavBarCategory;
    function ItemLinks: INavBarItemLinks;
  end;

  INavBarGroups = interface
  ['{2153B2C4-C7F7-474B-90F9-87244E6CBF8D}']
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarGroup;
    function FindOrCreate(const ACaption: string): INavBarGroup;
    property Item[const ACaption: string]: INavBarGroup read FindOrCreate; default;
  end;

  INavBarCategory = interface
  ['{04A62124-4275-425B-A177-FFAD3DA2F242}']
    function Groups: INavBarGroups;
    function Caption: string;
    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
  end;

  INavBarCategories = interface
  ['{161CD7D2-E2D3-4CA2-87C0-68D5C10898B8}']
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarCategory;
    function FindOrCreate(const ACaption: string): INavBarCategory;
    property Item[const ACaption: string]: INavBarCategory read FindOrCreate; default;
  end;

  INavBarLayout = interface
  ['{EB6139A0-10A6-4424-9634-78D67BF9251A}']
    function Caption: string;
    function Categories: INavBarCategories;
    //procedure Clear;
  end;

  INavBarLayouts = interface
  ['{118FA542-CD77-4D99-B6BF-C7E8C07C080C}']
    function Add(const Caption: string): INavBarLayout;
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarLayout;
    property Item[AIndex: integer]: INavBarLayout read GetItem; default;
  end;

  TNavBarItemLinkSubItemsCallback = function(const AItemID: string): INavBarItems of object;

  INavBarControlManager = interface
    procedure AddCategory(ACategory: INavBarCategory);
    procedure RemoveCategory(ACategory: INavBarCategory);
    procedure ChangeCategory(ACategory: INavBarCategory);
    procedure AddGroup(AGroup: INavBarGroup);
    procedure RemoveGroup(AGroup: INavBarGroup);
    procedure AddItemLink(AItemLink: INavBarItemLink);
    procedure RemoveItemLink(AItemLink: INavBarItemLink);
    procedure RemoveAllItems;
    procedure SetItemLinkSubItemsCallback(Value: TNavBarItemLinkSubItemsCallback);
  end;

  INavBarService = interface
  ['{D511F463-0988-40FD-934E-4D4DA5074C6E}']
    function Items: INavBarItems;
    function Layouts: INavBarLayouts;
    procedure LoadLayout(AIndex: integer);
    procedure LoadDefaultLayout;
    function DefaultLayout: INavBarLayout;
    procedure AddItemLinkDefault(AItem: INavBarItem);
    procedure RemoveItemLinkDefault(const ItemID: string);
    procedure RegisterControlManager(AControlManager: INavBarControlManager);
    procedure UnRegisterControlManager;
  end;

implementation

end.
