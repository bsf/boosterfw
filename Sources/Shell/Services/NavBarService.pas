unit NavBarService;

interface

uses SysUtils, Classes, Graphics, Windows, NavBarServiceIntf, Forms,
 CoreClasses, Contnrs, ComObj;

type
  TNavBarCategory = class;
  TNavBarGroup = class;
  TNavBarItem = class;
  TNavBarItems = class;
  TNavBarService = class;
  TNavBarLayout = class;


  TNavBarLayoutItem = class(TComponent)
  end;

  TNavBarLayoutEvent = procedure(Sender: TNavBarLayoutItem) of object;

  TNavBarItemLink = class(TNavBarLayoutItem, INavBarItemLink)
  private
    FItemID: string;
    FSectionIndex: integer;
    FCaption: string;
    FImage: Graphics.TBitmap;
    FLayout: TNavBarLayout;
  protected
    function ItemID: string;
    function Caption: string;
    function Group: INavBarGroup;
    function SectionIndex: integer;
    function Image: Graphics.TBitmap;
  public
    constructor Create(AOwner: TNavBarGroup; const AItemID, ACaption: string;
      ASectionIndex: integer;  AImage: Graphics.TBitmap; ALayout: TNavBarLayout); reintroduce;
    destructor Destroy; override;
  end;

  TNavBarItemLinks = class(TComponent, INavBarItemLinks)
  private
    FList: TComponentList;
    FLayout: TNavBarLayout;
    function Find(const AItemID: string): integer;
  protected
    function Add(const AItemID, ACaption: string; AImage: Graphics.TBitmap; ASectionIndex: integer = 0): integer;
    procedure Remove(const AItemID: string);
    procedure Delete(AIndex: integer);
    function GetItem(AIndex: integer): INavBarItemLink;
    function Count: integer;
  public
    constructor Create(AOwner: TNavBarGroup; ALayout: TNavBarLayout); reintroduce;
    destructor Destroy; override;
  end;

  TNavBarGroup = class(TNavBarLayoutItem, INavBarGroup)
  private
    FCaption: string;
    FItemLinks: TNavBarItemLinks;
    FLayout: TNavBarLayout;
  protected
    function Caption: string;
    function Category: INavBarCategory;
    function ItemLinks: INavBarItemLinks;
  public
    constructor Create(AOwner: TNavBarCategory; const ACaption: string;
      ALayout: TNavBarLayout); reintroduce;
  end;

  TNavBarGroups = class(TComponent, INavBarGroups)
  private
    FList: TComponentList;
    FLayout: TNavBarLayout;
  protected
    function Add(const ACaption: string): INavBarGroup;
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarGroup;
    function FindOrCreate(const ACaption: string): INavBarGroup;
  public
    constructor Create(AOwner: TNavBarCategory; ALayout: TNavBarLayout); reintroduce;
    destructor Destroy; override;
  end;


  TNavBarCategory = class(TNavBarLayoutItem, INavBarCategory)
  private
    FCaption: string;
    FImage: Graphics.TBitmap;
    FGroups: TNavBarGroups;
    FLayout: TNavBarLayout;
  protected
    function Caption: string;
    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
    function Groups: INavBarGroups;
  public
    constructor Create(ALayout: TNavBarLayout; const ACaption: string); reintroduce;
    destructor Destroy; override;
  end;

  TNavBarCategories = class(TComponent, INavBarCategories)
  private
    FList: TComponentList;
    FLayout: TNavBarLayout;
  protected
    //INavBarCategories
    function Add(const ACaption: string): INavBarCategory;
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarCategory;
    function FindOrCreate(const ACaption: string): INavBarCategory;
    property Item[const ACaption: string]: INavBarCategory read FindOrCreate; default;
  public
    constructor Create(AOwner: TNavBarLayout); reintroduce;
    destructor Destroy; override;
  end;

  TNavBarLayout = class(TComponent, INavBarLayout)
  private
    FCaption: string;
    FCategories: TNavBarCategories;
    FOnRemoveCategory: TNavBarLayoutEvent;
    FOnRemoveItemLink: TNavBarLayoutEvent;
    FOnRemoveGroup: TNavBarLayoutEvent;
    FOnAddCategory: TNavBarLayoutEvent;
    FOnAddItemLink: TNavBarLayoutEvent;
    FOnAddGroup: TNavBarLayoutEvent;
    FOnChangeCategory: TNavBarLayoutEvent;
  protected
    function Categories: INavBarCategories;
  public
    constructor Create(AOwner: TNavBarService; const ACaption: string); reintroduce;
    destructor Destroy; override;
    function Caption: string;
    procedure RemoveItemLink(const ItemID: string);

    property OnAddCategory: TNavBarLayoutEvent read FOnAddCategory
      write FOnAddCategory;
    property OnRemoveCategory: TNavBarLayoutEvent read FOnRemoveCategory
      write FOnRemoveCategory;

    property OnChangeCategory: TNavBarLayoutEvent read FOnChangeCategory
      write FOnChangeCategory;

    property OnAddGroup: TNavBarLayoutEvent read FOnAddGroup
      write FOnAddGroup;
    property OnRemoveGroup: TNavBarLayoutEvent read FOnRemoveGroup
      write FOnRemoveGroup;

    property OnAddItemLink: TNavBarLayoutEvent read FOnAddItemLink
      write FOnAddItemLink;
    property OnRemoveItemLink: TNavBarLayoutEvent read FOnRemoveItemLink
      write FOnRemoveItemLink;
  end;

  TNavBarLayouts = class(TComponent, INavBarLayouts)
  private
    FList: TComponentList;
  protected
    function Add(const Caption: string): INavBarLayout;
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarLayout; overload;
    function GetItemObject(AIndex: integer): TNavBarLayout; overload;
  public
    constructor Create(AOwner: TNavBarService); reintroduce;
    destructor Destroy; override;

  end;

  TNavBarItem = class(TComponent, INavBarItem)
  private
    FID: string;
    FCaption: string;
    FCategory: string;
    FGroup: string;
    FSection: integer;
    FImage: Graphics.TBitmap;
    FItems: TNavBarItems;

  public
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
    constructor Create(AOwner: TComponent; const AID: string); reintroduce;
    destructor Destroy; override;
  end;

  TNavBarItems = class(TComponent, INavBarItems)
  private
    FList: TComponentList;
    function FindIndex(const ID: string): integer;
  protected
    function Add(const ID: string): INavBarItem;
    procedure Remove(const ID: string);
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): INavBarItem;
    function Find(const ID: string): INavBarItem;
    function GetByID(const ID: string): INavBarItem;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TNavBarService = class(TComponent, INavBarService)
  private
    FWorkItem: TWorkItem;
    FItems: TNavBarItems;
    FControlManager: INavBarControlManager;
    FDefaultLayout: TNavBarLayout;
    FLayouts: TNavBarLayouts;
    FCurrentLayout: TNavBarLayout;

    procedure InternalLoadLayout(ALayout: TNavBarLayout);
    procedure InitializeControlManager;
    procedure AddCategoryHandler(Sender: TNavBarLayoutItem);
    procedure RemoveCategoryHandler(Sender: TNavBarLayoutItem);
    procedure ChangeCategoryHandler(Sender: TNavBarLayoutItem);
    procedure AddGroupHandler(Sender: TNavBarLayoutItem);
    procedure RemoveGroupHandler(Sender: TNavBarLayoutItem);
    procedure AddItemLinkHandler(Sender: TNavBarLayoutItem);
    procedure RemoveItemLinkHandler(Sender: TNavBarLayoutItem);

    procedure AddItemHandler(Sender: TNavBarItem);
    procedure RemoveItemHandler(Sender: TNavBarItem);

    function ItemLinkSubItemsCallback(const AItemID: string): INavBarItems;

    procedure OnActivityLoadedHandler(EventData: variant);
  protected
    function Items: INavBarItems;
    function Layouts: INavBarLayouts;
    procedure LoadLayout(AIndex: integer);
    procedure LoadDefaultLayout;
    function DefaultLayout: INavBarLayout;
    function CurrentLayout: INavBarLayout;
    procedure AddItemLinkDefault(AItem: INavBarItem);
    procedure RemoveItemLinkDefault(const ItemID: string);
    procedure RegisterControlManager(AControlManager: INavBarControlManager);
    procedure UnRegisterControlManager;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses ActivityServiceIntf;

{ TNavBarService }

procedure TNavBarService.AddCategoryHandler(Sender: TNavBarLayoutItem);
begin
  if Assigned(FControlManager) then
    FControlManager.AddCategory(TNavBarCategory(Sender));
end;

procedure TNavBarService.AddGroupHandler(Sender: TNavBarLayoutItem);
begin
  if Assigned(FControlManager) then
    FControlManager.AddGroup(TNavBarGroup(Sender));
end;

procedure TNavBarService.AddItemHandler(Sender: TNavBarItem);
begin

end;

procedure TNavBarService.AddItemLinkDefault(AItem: INavBarItem);
begin
  FDefaultLayout.Categories[AItem.Category].
    Groups[AItem.Group].ItemLinks.Add(AItem.ID, AItem.Caption, AItem.Image, AItem.Section);
end;

procedure TNavBarService.AddItemLinkHandler(Sender: TNavBarLayoutItem);
begin
  if Assigned(FControlManager) then
    FControlManager.AddItemLink(TNavBarItemLink(Sender));
end;

procedure TNavBarService.ChangeCategoryHandler(Sender: TNavBarLayoutItem);
begin
  if Assigned(FControlManager) then
    FControlManager.ChangeCategory(TNavBarCategory(Sender));
end;

constructor TNavBarService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
//  FControlManager := AControlManager;
//  FControlManager.SetItemLinkSubItemsCallback(ItemLinkSubItemsCallback);
  FWorkItem := AWorkItem;
  FItems := TNavBarItems.Create(Self);
  FDefaultLayout := TNavBarLayout.Create(Self, 'Default');
  FLayouts := TNavBarLayouts.Create(Self);
  InternalLoadLayout(FDefaultLayout);

  FWorkItem.EventTopics[EVT_ACTIVITY_LOADED].AddSubscription(Self, OnActivityLoadedHandler);
end;

function TNavBarService.CurrentLayout: INavBarLayout;
begin
  Result := FCurrentLayout;
end;

function TNavBarService.DefaultLayout: INavBarLayout;
begin
  FDefaultLayout.GetInterface(INavBarLayout, Result);
end;

destructor TNavBarService.Destroy;
begin
  if Assigned(FCurrentLayout) then
  begin
    with FCurrentLayout do
    begin
      FOnAddCategory := nil;
      FOnRemoveCategory := nil;
      FOnChangeCategory := nil;
      FOnAddGroup := nil;
      FOnRemoveGroup := nil;
      FOnAddItemLink := nil;
      FOnRemoveItemLink := nil;
    end;
    FControlManager.RemoveAllItems;
  end;

  FDefaultLayout.Free;
  FLayouts.Free;
  inherited;
end;


procedure TNavBarService.InternalLoadLayout(ALayout: TNavBarLayout);
begin
  if Assigned(FCurrentLayout) then
  begin
    with FCurrentLayout do
    begin
      FOnAddCategory := nil;
      FOnRemoveCategory := nil;
      FOnChangeCategory := nil;
      FOnAddGroup := nil;
      FOnRemoveGroup := nil;
      FOnAddItemLink := nil;
      FOnRemoveItemLink := nil;
    end;
  end;

  FCurrentLayout := ALayout;

  with FCurrentLayout do
  begin
    FOnAddCategory := AddCategoryHandler;
    FOnRemoveCategory := RemoveCategoryHandler;
    FOnChangeCategory := ChangeCategoryHandler;
    FOnAddGroup := AddGroupHandler;
    FOnRemoveGroup := RemoveGroupHandler;
    FOnAddItemLink := AddItemLinkHandler;
    FOnRemoveItemLink := RemoveItemLinkHandler;
  end;

  if Assigned(FControlManager) then
    InitializeControlManager;
end;

function TNavBarService.ItemLinkSubItemsCallback(const AItemID: string): INavBarItems;
var
  Item: INavBarItem;
begin
  Item := FItems.Find(AItemID);
  if Item <> nil then
    Result := Item.Items
  else
    Result := nil;
end;

function TNavBarService.Items: INavBarItems;
begin
  FItems.GetInterface(INavBarItems, Result);
end;

function TNavBarService.Layouts: INavBarLayouts;
begin
  FLayouts.GetInterface(INavBarLayouts, Result);
end;

procedure TNavBarService.InitializeControlManager;
var
  I, Y, Z: integer;
  Group: INavBarGroup;
begin
  FControlManager.RemoveAllItems;
  FControlManager.SetItemLinkSubItemsCallback(ItemLinkSubItemsCallback);
  if not Assigned(FCurrentLayout) then Exit;
  
  for I := 0 to FCurrentLayout.Categories.Count - 1 do
  begin
    FControlManager.AddCategory(FCurrentLayout.Categories.GetItem(I));

    for  Y := 0 to FCurrentLayout.Categories.GetItem(I).Groups.Count - 1 do
    begin
      Group := FCurrentLayout.Categories.GetItem(I).Groups.GetItem(Y);
      FControlManager.AddGroup(Group);

       for Z := 0 to Group.ItemLinks.Count - 1 do
         FControlManager.AddItemLink(Group.ItemLinks.GetItem(Z));
    end;
  end;


end;

procedure TNavBarService.LoadDefaultLayout;
begin
  InternalLoadLayout(FDefaultLayout);
end;

procedure TNavBarService.LoadLayout(AIndex: integer);
begin
  InternalLoadLayout(FLayouts.GetItemObject(AIndex));
end;

procedure TNavBarService.OnActivityLoadedHandler(EventData: variant);
var
  svc: IActivityService;
  navItem: INavBarItem;
  I: integer;
  activityInfo: IActivityInfo;
begin
  svc := FWorkItem.Services[IActivityService] as IActivityService;
  for I := 0 to svc.Infos.Count - 1 do
  begin
    activityInfo := svc.Infos.Item(I);

    if (activityInfo.Group <> '') and (activityInfo.MenuIndex > -1) then
    begin
      navItem := Items.Add(activityInfo.URI);
      navItem.Caption := activityInfo.Title;
      navItem.Group := activityInfo.Group;
      navItem.Category := 'Главное меню';

       if activityInfo.OptionExists('BeginSection') then
        navItem.Section := 1
      else
        navItem.Section := 0;

      navItem.Image := activityInfo.Image;
      AddItemLinkDefault(navItem);
    end;
 end;
end;

procedure TNavBarService.RegisterControlManager(
  AControlManager: INavBarControlManager);
begin
  UnregisterControlManager;
  FControlManager := AControlManager;
  InitializeControlManager;
end;

procedure TNavBarService.RemoveCategoryHandler(Sender: TNavBarLayoutItem);
begin
  if Assigned(FControlManager) then
    FControlManager.RemoveCategory(TNavBarCategory(Sender));
end;

procedure TNavBarService.RemoveGroupHandler(Sender: TNavBarLayoutItem);
begin
  if Assigned(FControlManager) then
    FControlManager.RemoveGroup(TNavBarGroup(Sender));
end;


procedure TNavBarService.RemoveItemHandler(Sender: TNavBarItem);
begin
end;

procedure TNavBarService.RemoveItemLinkDefault(const ItemID: string);
begin
  FDefaultLayout.RemoveItemLink(ItemID);
end;

procedure TNavBarService.RemoveItemLinkHandler(Sender: TNavBarLayoutItem);
begin
  if Assigned(FControlManager) then
    FControlManager.RemoveItemLink(TNavBarItemLink(Sender));
end;

procedure TNavBarService.UnRegisterControlManager;
begin
  FControlManager := nil;
end;

{ TNavBarItems }

function TNavBarItems.Add(const ID: string): INavBarItem;
var
  Item: TNavBarItem;
begin
  Item := TNavBarItem.Create(nil, ID);
  try
    if Owner is TNavBarService then
      TNavBarService(Owner).AddItemHandler(Item);
    FList.Add(Item);
    Item.GetInterface(INavBarItem, Result);
  except
    Item.Free;
    raise;
  end;
end;

function TNavBarItems.Count: integer;
begin
  Result := FList.Count;
end;

constructor TNavBarItems.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FList := TComponentList.Create(True);
end;

procedure TNavBarItems.Delete(AIndex: integer);
begin
  if Owner is TNavBarService then
    TNavBarService(Owner).RemoveItemHandler(TNavBarItem(FList[AIndex]));
  FList.Delete(AIndex);
end;

destructor TNavBarItems.Destroy;
var
  I: integer;
begin
  for I := FList.Count - 1 downto 0 do
    Delete(I);

  FList.Free;
  inherited;
end;

function TNavBarItems.FindIndex(const ID: string): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if SameText(TNavBarItem(FList[Result]).FID, ID) then Exit;

  Result := -1;
end;

function TNavBarItems.Find(const ID: string): INavBarItem;
var
  Idx: integer;
begin
  Idx := FindIndex(ID);
  if Idx <> -1 then
    Result := GetItem(Idx)
  else
    Result := nil;
end;

function TNavBarItems.GetByID(const ID: string): INavBarItem;
var
 Idx: integer;
begin
  Idx := FindIndex(ID);
  if Idx <> -1 then
    Result := GetItem(Idx)
  else
    raise Exception.CreateFmt('NavBar Item %s not found', [ID]);
end;


function TNavBarItems.GetItem(AIndex: integer): INavBarItem;
begin
  FList[AIndex].GetInterface(INavBarItem, Result);
end;

procedure TNavBarItems.Remove(const ID: string);
var
  Idx: integer;
begin
  Idx := FindIndex(ID);
  if Idx <> -1 then
    Delete(Idx);
end;

{ TNavBarItem }

constructor TNavBarItem.Create(AOwner: TComponent; const AID: string);
begin
  inherited Create(AOwner);
  FID := AID;
  FItems := TNavBarItems.Create(Self);
  FImage := Graphics.TBitmap.Create;
end;

destructor TNavBarItem.Destroy;
begin
  FItems.Free;
  FImage.Free;
  inherited;
end;

function TNavBarItem.GetCaption: string;
begin
  Result := FCaption;
end;

function TNavBarItem.GetCategory: string;
begin
  Result := FCategory;
end;

function TNavBarItem.GetGroup: string;
begin
  Result := FGroup;
end;

function TNavBarItem.GetImage: Graphics.TBitmap;
begin
  Result := FImage;
end;

function TNavBarItem.GetSection: integer;
begin
  Result := FSection;
end;

function TNavBarItem.ID: string;
begin
  if FID = '' then
    FID := CreateClassID;
  Result := FID;
end;

function TNavBarItem.Items: INavBarItems;
begin
  FItems.GetInterface(INavBarItems, Result);
end;

procedure TNavBarItem.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TNavBarItem.SetCategory(const Value: string);
begin
  FCategory := Value;
end;

procedure TNavBarItem.SetGroup(const Value: string);
begin
  FGroup := Value;
end;

procedure TNavBarItem.SetImage(Value: Graphics.TBitmap);
begin
  FImage.Assign(Value);
end;

procedure TNavBarItem.SetSection(Value: integer);
begin
  FSection := Value;
end;

{ TNavBarItemLinks }

function TNavBarItemLinks.Add(const AItemID, ACaption: string;
   AImage: Graphics.TBitmap; ASectionIndex: integer): integer;
var
  LinkItem: TNavBarItemLink;
begin
  LinkItem := TNavBarItemLink.Create(TNavBarGroup(Owner), AItemID, ACaption,
    ASectionIndex, AImage, FLayout);
  try
    if Assigned(FLayout.FOnAddItemLink) then FLayout.FOnAddItemLink(LinkItem);
    Result := FList.Add(LinkItem);
  except
    LinkItem.Free;
    raise;
  end;
end;

function TNavBarItemLinks.Count: integer;
begin
  Result := FList.Count;
end;

constructor TNavBarItemLinks.Create(AOwner: TNavBarGroup; ALayout: TNavBarLayout);
begin
  inherited Create(AOwner);
  FList := TComponentList.Create(True);
  FLayout := ALayout;
end;

procedure TNavBarItemLinks.Delete(AIndex: integer);
begin
  if Assigned(FLayout.FOnRemoveItemLink) then
    FLayout.FOnRemoveItemLink(TNavBarGroup(FList[AIndex]));
  FList.Delete(AIndex);
end;

destructor TNavBarItemLinks.Destroy;
var
  I: integer;
begin
  for I := FList.Count - 1 downto 0 do
    Delete(I);

  FList.Free;
  inherited;
end;

function TNavBarItemLinks.Find(const AItemID: string): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if SameText(TNavBarItemLink(FList[Result]).ItemID, AItemID) then Exit;
  Result := -1;
end;

function TNavBarItemLinks.GetItem(AIndex: integer): INavBarItemLink;
begin
  FList[AIndex].GetInterface(INavBarItemLink, Result);  
end;

procedure TNavBarItemLinks.Remove(const AItemID: string);
var
  Idx: integer;
begin
  Idx := Find(AItemID);
  if Idx <> -1 then
    Delete(Idx);
end;

{ TNavBarItemLink }

constructor TNavBarItemLink.Create(AOwner: TNavBarGroup; const AItemID, ACaption: string;
  ASectionIndex: integer; AImage: Graphics.TBitmap; ALayout: TNavBarLayout);
begin
  inherited Create(AOwner);
  FItemID := AItemID;
  FCaption := ACaption;
  FSectionIndex := ASectionIndex;
  FLayout := ALayout;
  FImage := Graphics.TBitmap.Create;
  FImage.Assign(AImage);
end;

destructor TNavBarItemLink.Destroy;
begin
  FImage.Free;
  inherited;
end;

function TNavBarItemLink.Caption: string;
begin
  Result := FCaption;
end;

function TNavBarItemLink.Group: INavBarGroup;
begin
  Owner.GetInterface(INavBarGroup, Result);
end;

function TNavBarItemLink.Image: Graphics.TBitmap;
begin
  Result := FImage;
end;

function TNavBarItemLink.ItemID: string;
begin
  Result := FItemID;
end;

function TNavBarItemLink.SectionIndex: integer;
begin
  Result := FSectionIndex;
end;

{ TNavBarCategories }

function TNavBarCategories.Add(const ACaption: string): INavBarCategory;
var
  Item: TNavBarCategory;
begin
  Item := TNavBarCategory.Create(FLayout, ACaption);
  try
    if Assigned(FLayout.FOnAddCategory) then FLayout.FOnAddCategory(Item);
    FList.Add(Item);
    Item.GetInterface(INavBarCategory, Result);
  except
    Item.Free;
    raise;
  end;
end;

function TNavBarCategories.Count: integer;
begin
  Result := FList.Count;
end;

constructor TNavBarCategories.Create(AOwner: TNavBarLayout);
begin
  inherited Create(AOwner);
  FList := TComponentList.Create(True);
  FLayout := AOwner;
end;

procedure TNavBarCategories.Delete(AIndex: integer);
begin
  if Assigned(FLayout.FOnRemoveCategory) then
    FLayout.FOnRemoveCategory(TNavBarCategory(FList[AIndex]));
  FList.Delete(AIndex);
end;

destructor TNavBarCategories.Destroy;
var
  I: integer;
begin
  for I := FList.Count - 1 downto 0 do
    Delete(I);

  FList.Free;
  inherited;
end;

function TNavBarCategories.FindOrCreate(const ACaption: string): INavBarCategory;
var
  I, Idx: integer;
begin
  Idx := -1;
  for I := 0 to FList.Count - 1 do
    if SameText(TNavBarCategory(FList[I]).Caption, ACaption) then
    begin
      Idx := I;
      Break;
    end;

  if Idx = -1 then
    Result := Add(ACaption)
  else
    Result := GetItem(Idx);
end;

function TNavBarCategories.GetItem(AIndex: integer): INavBarCategory;
begin
  FList[AIndex].GetInterface(INavBarCategory, Result);
end;

{ TNavBarCategory }

function TNavBarCategory.Caption: string;
begin
  Result := FCaption;
end;

constructor TNavBarCategory.Create(ALayout: TNavBarLayout; const ACaption: string);
begin
  inherited Create(nil);
  FCaption := ACaption;
  FImage := Graphics.TBitmap.Create;
  FLayout := ALayout;
  FGroups := TNavBarGroups.Create(Self, FLayout);
end;

destructor TNavBarCategory.Destroy;
begin
  FImage.Free;
  FGroups.Free;
  inherited;
end;

function TNavBarCategory.Groups: INavBarGroups;
begin
  FGroups.GetInterface(INavBarGroups, Result);
end;

function TNavBarCategory.GetImage: Graphics.TBitmap;
begin
  Result := FImage;
end;

procedure TNavBarCategory.SetImage(Value: Graphics.TBitmap);
begin
  FImage.Assign(Value);
  if Assigned(FLayout.FOnChangeCategory) then
    FLayout.FOnChangeCategory(Self);
end;

{ TNavBarGroups }

function TNavBarGroups.Add(const ACaption: string): INavBarGroup;
var
  Item: TNavBarGroup;
begin
  Item := TNavBarGroup.Create(TNavBarCategory(Owner), ACaption, FLayout);
  try
    if Assigned(FLayout.FOnAddGroup) then FLayout.FOnAddGroup(Item);
    FList.Add(Item);
    Item.GetInterface(INavBarGroup, Result);
  except
    Item.Free;
    raise;
  end;
end;

function TNavBarGroups.Count: integer;
begin
  Result := FList.Count;
end;

constructor TNavBarGroups.Create(AOwner: TNavBarCategory; ALayout: TNavBarLayout);
begin
  inherited Create(AOwner);
  FList := TComponentList.Create(True);
  FLayout := ALayout;
end;

procedure TNavBarGroups.Delete(AIndex: integer);
begin
  if Assigned(FLayout.FOnRemoveGroup) then
    FLayout.FOnRemoveGroup(TNavBarGroup(FList[AIndex]));
  FList.Delete(AIndex);
end;

destructor TNavBarGroups.Destroy;
var
  I: integer;
begin
  for I := FList.Count - 1 downto 0 do
    Delete(I);

  FList.Free;
  inherited;
end;

function TNavBarGroups.FindOrCreate(const ACaption: string): INavBarGroup;
var
  I, Idx: integer;
begin
  Idx := -1;
  for I := 0 to FList.Count - 1 do
    if SameText(TNavBarGroup(FList[I]).FCaption, ACaption) then
    begin
      Idx := I;
      Break;
    end;

  if Idx = -1 then
    Result := Add(ACaption)
  else
    Result := GetItem(Idx);
end;

function TNavBarGroups.GetItem(AIndex: integer): INavBarGroup;
begin
  FList[AIndex].GetInterface(INavBarGroup, Result);
end;

{ TNavBarGroup }

function TNavBarGroup.Caption: string;
begin
  Result := FCaption;
end;

function TNavBarGroup.Category: INavBarCategory;
begin
  Owner.GetInterface(INavBarCategory, Result);
end;


constructor TNavBarGroup.Create(AOwner: TNavBarCategory; const ACaption: string;
  ALayout: TNavBarLayout);
begin
  inherited Create(AOwner);
  FCaption := ACaption;
  FLayout := ALayout;
  FItemLinks := TNavBarItemLinks.Create(Self, FLayout);
end;

function TNavBarGroup.ItemLinks: INavBarItemLinks;
begin
  Result := FItemLinks;
end;


{ TNavBarLayouts }

function TNavBarLayouts.Add(const Caption: string): INavBarLayout;
var
  Item: TNavBarLayout;
begin
  Item := TNavBarLayout.Create(TNavBarService(Owner), Caption);
  FList.Add(Item);
  Item.GetInterface(INavBarLayout, Result);
end;

function TNavBarLayouts.Count: integer;
begin
  Result := FList.Count;
end;

constructor TNavBarLayouts.Create(AOwner: TNavBarService);
begin
  inherited Create(AOwner);
  FList := TComponentList.Create(True);
end;

procedure TNavBarLayouts.Delete(AIndex: integer);
begin
  FList.Delete(AIndex);
end;

destructor TNavBarLayouts.Destroy;
begin
  FList.Free;
  inherited;
end;

function TNavBarLayouts.GetItem(AIndex: integer): INavBarLayout;
begin
  FList[AIndex].GetInterface(INavBarLayout, Result);
end;

function TNavBarLayouts.GetItemObject(AIndex: integer): TNavBarLayout;
begin
  Result := TNavBarLayout(FList[AIndex]);
end;

{ TNavBarLayout }

function TNavBarLayout.Caption: string;
begin
  Result := FCaption;
end;

function TNavBarLayout.Categories: INavBarCategories;
begin
  FCategories.GetInterface(INavBarCategories, Result);
end;

constructor TNavBarLayout.Create(AOwner: TNavBarService; const ACaption: string);
begin
  inherited Create(AOwner);
  FCaption := ACaption;
  FCategories := TNavBarCategories.Create(Self);
end;

destructor TNavBarLayout.Destroy;
begin
  FCategories.Free;
  inherited;
end;

procedure TNavBarLayout.RemoveItemLink(const ItemID: string);
var
  I, Y: integer;
begin
  for I := 0 to FCategories.Count - 1 do
    for Y := 0 to FCategories.GetItem(I).Groups.Count - 1 do
      FCategories.GetItem(I).Groups.GetItem(Y).ItemLinks.Remove(ItemID);
end;

end.
