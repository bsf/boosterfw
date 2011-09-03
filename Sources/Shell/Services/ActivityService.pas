unit ActivityService;

interface
uses Classes, CoreClasses, Graphics, ActivityServiceIntf, Contnrs, Sysutils,
  NavBarServiceIntf, SecurityIntf, ShellIntf, inifiles;

const
  //SecurityClass
  SECURITY_RES_PROVIDER_ID = 'security.resprovider.app.activities';

  SECURITY_PROVIDER_ACTIVITIES = 'Security.Policy.App.Activities';
  SECURITY_CLASS_ACTIVITY = SECURITY_PROVIDER_ACTIVITIES;
  SECURITY_CLASS_ACTIVITY_ITEM = '{A84F4D00-F3FA-4FFB-8B71-D14CF6795E52}';
  SECURITY_PERMISSION_ACTIVITY_EXECUTE = 'app.activity.execute';

type
  TActivities = class;

  TActivity = class(TComponent, IActivity, ISecurityResNode)
  private
    FID: string;
    FWorkItem: TWorkItem;
    FParent: TActivity;
    //
    FCaption: string;
    FCategory: string;
    FGroup: string;
    FSection: integer;
    FImage: Graphics.TBitmap;
    FShortCut: string;
    //
    FActivities: TActivities;
    FNavBarLinked: boolean;
    //
    FUseActivityPermission: boolean;
    FInheritPermission: boolean;

    FCustomPermissionResourceID: string;
    FCustomPermission: string;
    function PermissionExecuteCondition(const CommandName: string;
      Sender: TObject): boolean;
    procedure HandlerDefault(Sender: TObject);
  protected
    //IActivity
    function ID: string;
    procedure Init(const ACategory, AGroup, ACaption: string; AHandler: TNotifyEvent = nil;
      ASection: integer = 0; AShortCut: string = '');

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

    procedure AddNavBarLink;
    procedure RemoveNavBarLink;

    function UsePermission: boolean;
    function UseActivityPermission: boolean;
    function HavePermission: boolean;
    function InheritPermission: boolean;
    procedure SetCustomPermissionOptions(const AResID, APermID: string);

    //ISecurityResNode
    function GetSecurityResNodeID: string;
    function ISecurityResNode.ID = GetSecurityResNodeID;
    function GetSecurityResNodeName: string;
    function ISecurityResNode.Name = GetSecurityResNodeName;
    function GetSecurityResNodeDescription: string;
    function ISecurityResNode.Description = GetSecurityResNodeDescription;
  public
    constructor Create(const AID: string; AWorkItem: TWorkItem;
      AParent: TActivity;
      AUseActivityPermission, InheritPermission: boolean); reintroduce;
    destructor Destroy; override;
  end;

  TActivities = class(TComponent, IActivities)
  private
    FList: TComponentList;
    FWorkItem: TWorkItem;
    FParent: TActivity;
    function FindIndex(const ID: string): integer;
  protected
    //IActivities
    function Add(const ID: string;
      UseActivityPermission: boolean = true; InheritPermission: boolean = true): IActivity;
    procedure Remove(const ID: string);
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivity;
    function Find(const ID: string): IActivity;
    function GetByID(const ID: string): IActivity;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem;
      AParent: TActivity); reintroduce; virtual;
    destructor Destroy; override;
  end;

//------------------------- Layouts --------------------------------------------

  TActivityLayoutGroup = class;
  TActivityLayoutCategory = class;

  TActivityLayoutItemLink = class(TComponent, IActivityLayoutItemLink)
  private
    FItemID: string;
    FGroup: TActivityLayoutGroup;
  protected
    function ItemID: string;
    function Group: IActivityLayoutGroup;
  public
    constructor Create(AGroup: TActivityLayoutGroup; const AItemID: string); reintroduce;
  end;

  TActivityLayoutItemLinks = class(TComponent, IActivityLayoutItemLinks)
  private
    FGroup: TActivityLayoutGroup;
    FList: TComponentList;
  protected
    function Add(const AItemID: string): IActivityLayoutItemLink;
    procedure Remove(const ItemID: string);
    procedure Delete(AIndex: integer);
    function GetItem(AIndex: integer): IActivityLayoutItemLink;
    function Count: integer;
  public
    constructor Create(AGroup: TActivityLayoutGroup); reintroduce;
    destructor Destroy; override;
  end;

  TActivityLayoutGroup = class(TComponent, IActivityLayoutGroup)
  private
    FCaption: string;
    FItemLinks: TActivityLayoutItemLinks;
    FCategory: TActivityLayoutCategory;
  protected
    function Caption: string;
    function ItemLinks: IActivityLayoutItemLinks;
    function Category: IActivityLayoutCategory;
  public
    constructor Create(ACategory: TActivityLayoutCategory; const ACaption: string); reintroduce;
    destructor Destroy; override;
  end;

  TActivityLayoutGroups = class(TComponent, IActivityLayoutGroups)
  private
    FList: TComponentList;
    function Add(const ACaption: string): IActivityLayoutGroup;
  protected
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivityLayoutGroup;
    function FindOrCreate(const ACaption: string): IActivityLayoutGroup;
  public
    constructor Create(AOwner: TActivityLayoutCategory); reintroduce;
    destructor Destroy; override;
  end;

  TActivityLayoutCategory = class(TComponent, IActivityLayoutCategory)
  private
    FCaption: string;
    FImage: Graphics.TBitmap;
    FGroups: TActivityLayoutGroups;
  protected
    function Caption: string;
    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
    function Groups: IActivityLayoutGroups;
  public
    constructor Create(const ACaption: string); reintroduce;
    destructor Destroy; override;
  end;

  TActivityLayoutCategories = class(TComponent, IActivityLayoutCategories)
  private
    FList: TComponentList;
    function Add(const ACaption: string): IActivityLayoutCategory;
  protected
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivityLayoutCategory;
    function FindOrCreate(const ACaption: string): IActivityLayoutCategory;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TActivityManagerService = class;

  TActivityLayout = class(TComponent, IActivityLayout)
  private
    FManager: TActivityManagerService;
    FCaption: string;
    FCategories: TActivityLayoutCategories;
  protected
    procedure Load;
    procedure UnLoad;
    function Caption: string;
    function Categories: IActivityLayoutCategories;
  public
    constructor Create(AManager: TActivityManagerService; const ACaption: string); reintroduce;
    destructor Destroy; override;
  end;

  TActivityLayouts = class(TComponent, IActivityLayouts)
  private
    FList: TComponentList;
    FActive: integer;
  protected
    function Add(const Caption: string): IActivityLayout;
    procedure Delete(AIndex: integer);
    function Count: integer;
    function GetItem(AIndex: integer): IActivityLayout;
    function Find(const ACaption: string): integer;
    function GetActive: integer;
    procedure SetActive(AIndex: integer);

  public
    constructor Create(AOwner: TActivityManagerService); reintroduce;
    destructor Destroy; override;
  end;


//------------------------ Manager ---------------------------------------------
  TActivityManagerService = class(TComponent, IActivityManagerService, ISecurityResProvider)
  private

    FWorkItem: TWorkItem;
    FActivities: TActivities;
    FLayouts: TActivityLayouts;

    function GlobalFindItem(const ID: string; AList: IActivities): IActivity;

    //
    procedure InitDefaultLayout;
    procedure EventAppStartedHandler(EventData: Variant);
    procedure EventAppStopedHandler(EventData: Variant);

  protected
    //IActivityManagerService
    function Items: IActivities;
    function Layouts: IActivityLayouts;


    //ISecurityResProvider
    function GetSecurityResProviderID: string;
    function ISecurityResProvider.ID = GetSecurityResProviderID;
    function GetSecurityTopRes: IInterfaceList;
    function ISecurityResProvider.GetTopRes = GetSecurityTopRes;
    function GetSecurityChildRes(const AParentResID: string): IInterfaceList;
    function ISecurityResProvider.GetChildRes = GetSecurityChildRes;
    function GetSecurityGetRes(const ID: string): ISecurityResNode;
    function ISecurityResProvider.GetRes = GetSecurityGetRes;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    property WorkItem: TWorkItem read FWorkItem;
  end;

implementation


{ TActivities }

function TActivities.Add(const ID: string;
  UseActivityPermission, InheritPermission: boolean): IActivity;
var
  Item: TActivity;
begin
  Item := TActivity.Create(ID, FWorkItem, FParent, 
    UseActivityPermission, InheritPermission);
  FList.Add(Item);
  Item.GetInterface(IActivity, Result);
end;

function TActivities.Count: integer;
begin
  Result := FList.Count;
end;

constructor TActivities.Create(AOwner: TComponent; AWorkItem: TWorkItem;
  AParent: TActivity);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FList := TComponentList.Create(True);
  FParent := AParent;
end;

procedure TActivities.Delete(AIndex: integer);
begin
  FList.Delete(AIndex);
end;

destructor TActivities.Destroy;
begin
  FList.Free;
  inherited;
end;

function TActivities.Find(const ID: string): IActivity;
var
  Idx: integer;
begin
  Idx := FindIndex(ID);
  if Idx <> -1 then
    Result := GetItem(Idx)
  else
    Result := nil;
end;

function TActivities.FindIndex(const ID: string): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if TActivity(FList[Result]).FID = ID then Exit;
  Result := -1;
end;

function TActivities.GetByID(const ID: string): IActivity;
var
 Idx: integer;
begin
  Idx := FindIndex(ID);
  if Idx <> -1 then
    Result := GetItem(Idx)
  else
    raise Exception.CreateFmt('Activity Item %s not found', [ID]);
end;

function TActivities.GetItem(AIndex: integer): IActivity;
begin
  FList[AIndex].GetInterface(IActivity, Result);
end;

procedure TActivities.Remove(const ID: string);
var
  Idx: integer;
begin
  Idx := FindIndex(ID);
  if Idx <> -1 then
    Delete(Idx);
end;

{ TActivity }

function TActivity.Items: IActivities;
begin
  FActivities.GetInterface(IActivities, Result);
end;

procedure TActivity.AddNavBarLink;
var
  navItem: INavBarItem;
  navItemSub: INavBarItem;
  I: integer;
  svcNavBar: INavBarService;
  activitySub: IActivity;
begin


  if not HavePermission then Exit;

  svcNavBar := FWorkItem.Services[INavBarService] as INavBarService;

  FNavBarLinked := true;
  navItem := svcNavBar.Items.Add(FID);
  navItem.Caption := FCaption;

  navItem.Category := GetCategory;//FCategories.GetTopParent(FCategoryID).Caption;
  navItem.Group := GetGroup; //FCategories[FCategoryID].Caption;
  svcNavBar.AddItemLinkDefault(navItem);


  {Subitems}
  for I := 0 to FActivities.Count - 1 do
  begin
    activitySub := FActivities.GetItem(I);
    navItemSub := navItem.Items.Add(activitySub.ID);
    navItemSub.Caption := activitySub.Caption;
    navItemSub.Section := activitySub.Section;
  end;


end;

constructor TActivity.Create(const AID: string; AWorkItem: TWorkItem;
  AParent: TActivity;
  AUseActivityPermission, InheritPermission: boolean);
begin
  inherited Create(nil);
  FID := AID;
  FWorkItem := AWorkItem;
  FActivities := TActivities.Create(nil, AWorkItem, Self);
  FImage := Graphics.TBitmap.Create;
  FParent := AParent;
  FUseActivityPermission := AUseActivityPermission;
  FInheritPermission := InheritPermission;
  FWorkItem.Commands[FID].RegisterCondition(PermissionExecuteCondition);
  FWorkItem.Commands[FID].SetHandler(HandlerDefault);
end;

destructor TActivity.Destroy;
begin
  if FNavBarLinked then
    RemoveNavBarLink;

  FActivities.Free;
  FImage.Free;

  FWorkItem.Commands.RemoveCommand(FID);

  inherited;
end;

function TActivity.GetCaption: string;
begin
  Result := FCaption;
end;

function TActivity.GetImage: Graphics.TBitmap;
begin
  Result := FImage;
end;

function TActivity.GetShortCut: string;
begin
  Result := FShortCut;
end;

function TActivity.ID: string;
begin
  Result := FID;
end;

procedure TActivity.RemoveNavBarLink;
var
  svcNavBar: INavBarService;
begin

  if not FNavBarLinked then Exit;

  svcNavBar := INavBarService(FWorkItem.Services[INavBarService]);
  svcNavBar.RemoveItemLinkDefault(FID);
  svcNavBar.Items.Remove(FID);
  FNavBarLinked := false;

end;

procedure TActivity.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TActivity.SetImage(Value: TBitmap);
begin
  FImage.Assign(Value);
end;

procedure TActivity.SetSection(Value: integer);
begin
  FSection := Value;
end;

procedure TActivity.SetShortCut(const Value: string);
begin
  FShortCut := Value;
end;

procedure TActivity.HandlerDefault(Sender: TObject);
var
  _commandName: string;
  intf: ICommand;
begin
  Sender.GetInterface(ICommand, intf);
  if Assigned(intf) then
  begin
    _commandName := intf.Name;
    intf := nil;

    FWorkItem.Actions[_commandName].Execute(FWorkItem);
  end;
end;

function TActivity.HavePermission: boolean;
var
  SecuritySvc: ISecurityService;
begin
  if UsePermission then
  begin
    Result := false;
    SecuritySvc := ISecurityService(FWorkItem.Services[ISecurityService]);

    if FUseActivityPermission then
      Result := SecuritySvc.CheckPermission(SECURITY_PERMISSION_ACTIVITY_EXECUTE, FID)
    else if FCustomPermission <> '' then
      Result := SecuritySvc.CheckPermission(FCustomPermission, FCustomPermissionResourceID);
  end
  else
    Result := True;
end;


function TActivity.Parent: IActivity;
begin
  if Assigned(FParent) then
    FParent.GetInterface(IActivity, Result)
  else
    Result := nil;  
end;

function TActivity.UsePermission: boolean;
begin
  Result := (FUseActivityPermission or (FCustomPermission <> ''))
             and (App.RunMode <> rmConfiguration);
end;

function TActivity.InheritPermission: boolean;
begin
  Result := FInheritPermission;
end;


function TActivity.PermissionExecuteCondition(const CommandName: string;
  Sender: TObject): boolean;
begin
  Result := true;
  if UsePermission and (not HavePermission) then
    raise Exception.Create('Отказано в доступе к ресурсу');
end;

function TActivity.UseActivityPermission: boolean;
begin
  Result := FUseActivityPermission;
end;

procedure TActivity.SetCustomPermissionOptions(const AResID, APermID: string);
begin
  FCustomPermissionResourceID := AResID;
  FCustomPermission := APermID;
end;


procedure TActivity.SetHandler(AHandler: TNotifyEvent);
begin
  FWorkItem.Commands[FID].SetHandler(AHandler);
end;

function TActivity.GetSection: integer;
begin
  Result := FSection;
end;

function TActivity.GetData(const AName: string): Variant;
begin
  Result := FWorkItem.Commands[FID].GetData(AName);
end;

procedure TActivity.SetData(const AName: string; AValue: Variant);
begin
  FWorkItem.Commands[FID].SetData(AName, AValue);
end;

function TActivity.GetCategory: string;
begin
  Result := FCategory;
end;

function TActivity.GetGroup: string;
begin
  Result := FGroup;
end;

procedure TActivity.SetCategory(const Value: string);
begin
  FCategory := Value;
end;

procedure TActivity.SetGroup(const Value: string);
begin
  FGroup := Value;
end;

procedure TActivity.Init(const ACategory, AGroup, ACaption: string;
  AHandler: TNotifyEvent; ASection: integer; AShortCut: string);
begin
  SetCategory(ACategory);
  SetGroup(AGroup);
  SetCaption(ACaption);
  if Assigned(AHandler) then
    SetHandler(AHandler);
  SetSection(ASection);
  SetShortCut(AShortCut);
end;

function TActivity.GetSecurityResNodeID: string;
begin
  Result := ID;
end;

function TActivity.GetSecurityResNodeName: string;
begin
  Result := GetCaption;
end;

function TActivity.GetSecurityResNodeDescription: string;
begin
  Result := GetGroup;
end;

{ TActivityManagerService }

constructor TActivityManagerService.Create(AOwner: TComponent;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FActivities := TActivities.Create(Self, FWorkItem, nil);

  FLayouts := TActivityLayouts.Create(Self);

  (FWorkItem.Services[ISecurityService] as ISecurityService).RegisterResProvider(Self);

  FWorkItem.EventTopics[etAppStarted].AddSubscription(Self, EventAppStartedHandler);
  FWorkItem.EventTopics[etAppStoped].AddSubscription(Self, EventAppStopedHandler);

end;

destructor TActivityManagerService.Destroy;
begin
  inherited;
end;


function TActivityManagerService.GlobalFindItem(
  const ID: string; AList: IActivities): IActivity;
var
  I: integer;
begin
  Result := AList.Find(ID);
  if not Assigned(Result) then
    for I := 0 to AList.Count - 1 do
    begin
      Result := GlobalFindItem(ID, AList.GetItem(I).Items);
      if Assigned(Result) then Exit;
    end;
end;

function TActivityManagerService.Items: IActivities;
begin
  Result := FActivities as IActivities;  
end;

procedure TActivityManagerService.EventAppStartedHandler(EventData: Variant);
var
  layoutCaption: string;
  layoutIndex: integer;
begin
  InitDefaultLayout;

  layoutCaption := '';
  layoutIndex := -1;

  if (FLayouts.Count > 1) and (FLayouts.GetActive <> 0) then
    layoutCaption := App.Settings['Activities.Layouts.Last'];

  if layoutCaption <> '' then
    layoutIndex := FLayouts.Find(layoutCaption);

  if layoutIndex = -1 then layoutIndex := 0;

  FLayouts.SetActive(layoutIndex);
end;

procedure TActivityManagerService.EventAppStopedHandler(EventData: Variant);
begin

end;

function TActivityManagerService.Layouts: IActivityLayouts;
begin
  Result := FLayouts;
end;

procedure TActivityManagerService.InitDefaultLayout;
var
  I: integer;
  categoryCaption: string;
  groupCaption: string;
  layouts: IActivityLayouts;
  layout: IActivityLayout;
  _categories: IActivityLayoutCategories;
  category: IActivityLayoutCategory;
  groups: IActivityLayoutGroups;
  group: IActivityLayoutGroup;
begin
  for I := 0 to FActivities.Count - 1 do
  begin
    categoryCaption := Items.GetItem(I).Category;
      //FCategories.GetTopParent(FActivities.GetItem(I).CategoryID).Caption;
    groupCaption := Items.GetItem(I).Group;
      //FCategories.GetByID(FActivities.GetItem(I).CategoryID).Caption;

    layouts := Self.Layouts;
    layout := layouts[0];
    _categories := layout.Categories;
    category := _categories.FindOrCreate(categoryCaption);
    groups := category.Groups;
    group := groups.FindOrCreate(groupCaption);
    group.ItemLinks.Add(FActivities.GetItem(I).ID);
  end;
end;

function TActivityManagerService.GetSecurityChildRes(
  const AParentResID: string): IInterfaceList;
begin
  Result := TInterfaceList.Create;
end;

function TActivityManagerService.GetSecurityResProviderID: string;
begin
  Result := SECURITY_RES_PROVIDER_ID;
end;

function TActivityManagerService.GetSecurityTopRes: IInterfaceList;
var
  I: integer;
begin
  Result := TInterfaceList.Create;
  for I := 0 to FActivities.Count - 1 do
    if FActivities.GetItem(I).UseActivityPermission then
      Result.Add(FActivities.GetItem(I) as ISecurityResNode);

end;


function TActivityManagerService.GetSecurityGetRes(
  const ID: string): ISecurityResNode;
begin
  Result := FActivities.Find(ID) as ISecurityResNode;
end;

{ TActivityLayouts }

function TActivityLayouts.Add(const Caption: string): IActivityLayout;
begin
//  FList.Add(TActivityLayout.Create(AOwner, '', ''));
end;

function TActivityLayouts.Count: integer;
begin
  Result := FList.Count;
end;

constructor TActivityLayouts.Create(AOwner: TActivityManagerService);
begin
  inherited Create(AOwner);
  FActive := -1;
  FList := TComponentList.Create(True);
  FList.Add(TActivityLayout.Create(AOwner, ''));
end;

procedure TActivityLayouts.Delete(AIndex: integer);
begin

end;

destructor TActivityLayouts.Destroy;
begin
  FList.Free;
  inherited;
end;

function TActivityLayouts.Find(const ACaption: string): integer;
var
  I: integer;
begin
  for I := 1 to FList.Count - 1 do
  begin
    Result := I;
    if SameText(ACaption, GetItem(Result).Caption) then Exit;
  end;
  Result := -1;
end;

function TActivityLayouts.GetActive: integer;
begin
  Result := FActive;
end;

function TActivityLayouts.GetItem(AIndex: integer): IActivityLayout;
begin
  FList[AIndex].GetInterface(IActivityLayout, Result);
end;


procedure TActivityLayouts.SetActive(AIndex: integer);
begin
  if FActive <> -1 then
    TActivityLayout(FList[FActive]).UnLoad;

  FActive := AIndex;
  TActivityLayout(FList[FActive]).Load;
end;

{ TActivityLayout }

function TActivityLayout.Caption: string;
begin
  Result := FCaption;
end;

constructor TActivityLayout.Create(AManager: TActivityManagerService;
  const ACaption: string);
begin
  inherited Create(nil);
  FManager := AManager;
  FCaption := ACaption;
  FCategories := TActivityLayoutCategories.Create(Self);
end;

destructor TActivityLayout.Destroy;
begin
  FCategories.Free;
  inherited;
end;


function TActivityLayout.Categories: IActivityLayoutCategories;
begin
  Result := FCategories as IActivityLayoutCategories;
end;

procedure TActivityLayout.Load;

  procedure LoadItemLink(NavBarSvc: INavBarService; AItemLink: IActivityLayoutItemLink);
  var
    item: IActivity;
    navItem: INavBarItem;
    navItemSub: INavBarItem;
    I: integer;
    activitySub: IActivity;
  begin
    item := FManager.Items.Find(AItemLink.ItemID);
    if not Assigned(item) then Exit;

    if not Item.HavePermission then Exit;

    navItem := NavBarSvc.Items.Add(Item.ID);
    navItem.Caption := Item.Caption;

    navItem.Category := AItemLink.Group.Category.Caption;
    navItem.Group := AItemLink.Group.Caption;
    navItem.Section := item.Section;

    NavBarSvc.AddItemLinkDefault(navItem);

    for I := 0 to item.items.Count - 1 do
    begin
      activitySub := item.items.GetItem(I);
      navItemSub := navItem.Items.Add(activitySub.ID);
      navItemSub.Caption := activitySub.Caption;
      navItemSub.Section := activitySub.Section;
    end;

  end;

var
  svc: INavBarService;
  I, Y, Z: integer;
begin
  svc := FManager.WorkItem.Services[INavBarService] as INavBarService;

  for I := 0 to Categories.Count - 1 do
    for Y := 0 to Categories.GetItem(I).Groups.Count - 1 do
      for Z := 0 to Categories.GetItem(I).Groups.GetItem(Y).ItemLinks.Count - 1 do
        LoadItemLink(svc, Categories.GetItem(I).Groups.GetItem(Y).ItemLinks.GetItem(Z));
end;

procedure TActivityLayout.UnLoad;
  procedure GroupUnLoad(AGroup: TActivityLayoutGroup);
  var
    I: integer;
    svcNavBar: INavBarService;
  begin
    svcNavBar := FManager.WorkItem.Services[INavBarService] as INavBarService;

    for I := 0 to AGroup.ItemLinks.Count - 1 do
    begin

    end;

  end;



begin

end;

{ TActivityLayoutGroups }

function TActivityLayoutGroups.Add(const ACaption: string): IActivityLayoutGroup;
var
  Item: TActivityLayoutGroup;
begin
  Item := TActivityLayoutGroup.Create(TActivityLayoutCategory(Owner), ACaption);
  FList.Add(Item);
  Item.GetInterface(IActivityLayoutGroup, Result);
end;

function TActivityLayoutGroups.Count: integer;
begin
  Result := FList.Count;
end;

constructor TActivityLayoutGroups.Create(AOwner: TActivityLayoutCategory);
begin
  inherited Create(AOwner);
  FList := TComponentList.Create(True);
end;

procedure TActivityLayoutGroups.Delete(AIndex: integer);
begin

end;

destructor TActivityLayoutGroups.Destroy;
begin
  FList.Free;
  inherited;
end;

function TActivityLayoutGroups.FindOrCreate(
  const ACaption: string): IActivityLayoutGroup;
var
  I, Idx: integer;
begin
  Idx := -1;
  for I := 0 to FList.Count - 1 do
    if SameText(TActivityLayoutGroup(FList[I]).Caption, ACaption) then
    begin
      Idx := I;
      Break;
    end;

  if Idx = -1 then
    Result := Add(ACaption)
  else
    Result := GetItem(Idx);

end;

function TActivityLayoutGroups.GetItem(
  AIndex: integer): IActivityLayoutGroup;
begin
  FList[AIndex].GetInterface(IActivityLayoutGroup, Result);
end;

{ TActivityLayoutGroup }

function TActivityLayoutGroup.Caption: string;
begin
  Result := FCaption;
end;

function TActivityLayoutGroup.Category: IActivityLayoutCategory;
begin
  Result := FCategory as IActivityLayoutCategory;
end;

constructor TActivityLayoutGroup.Create(ACategory: TActivityLayoutCategory;
  const ACaption: string);
begin
  inherited Create(nil);
  FCaption := ACaption;
  FCategory := ACategory;
  FItemLinks := TActivityLayoutItemLinks.Create(Self);
end;

destructor TActivityLayoutGroup.Destroy;
begin
  FItemLinks.Free;
  inherited;
end;


function TActivityLayoutGroup.ItemLinks: IActivityLayoutItemLinks;
begin
  Result := FItemLinks;
end;

{ TActivityLayoutItemLinks }

function TActivityLayoutItemLinks.Add(
  const AItemID: string): IActivityLayoutItemLink;
var
  LinkItem: TActivityLayoutItemLink;
begin
  LinkItem := TActivityLayoutItemLink.Create(FGroup, AItemID);
  FList.Add(LinkItem);
  Result := LinkItem as IActivityLayoutItemLink;
end;

function TActivityLayoutItemLinks.Count: integer;
begin
  Result := FList.Count;
end;

constructor TActivityLayoutItemLinks.Create(AGroup: TActivityLayoutGroup);
begin
  inherited Create(AGroup);
  FGroup := AGroup;
  FList := TComponentList.Create(true);
end;

procedure TActivityLayoutItemLinks.Delete(AIndex: integer);
begin

end;

destructor TActivityLayoutItemLinks.Destroy;
begin
  FList.Free;
  inherited;
end;

function TActivityLayoutItemLinks.GetItem(
  AIndex: integer): IActivityLayoutItemLink;
begin
  FList[AIndex].GetInterface(IActivityLayoutItemLink, Result);
end;

procedure TActivityLayoutItemLinks.Remove(const ItemID: string);
begin

end;

{ TActivityLayoutItemLink }

constructor TActivityLayoutItemLink.Create(AGroup: TActivityLayoutGroup;
  const AItemID: string);
begin
  inherited Create(nil);
  FItemID := AItemID;
  FGroup := AGroup;
end;

function TActivityLayoutItemLink.Group: IActivityLayoutGroup;
begin
  Result := FGroup as IActivityLayoutGroup;
end;

function TActivityLayoutItemLink.ItemID: string;
begin
  Result := FItemID;
end;

{ TActivityLayoutCategories }

function TActivityLayoutCategories.Add(
  const ACaption: string): IActivityLayoutCategory;
var
  Item: TActivityLayoutCategory;
begin
  Item := TActivityLayoutCategory.Create(ACaption);
  FList.Add(Item);
  Item.GetInterface(IActivityLayoutCategory, Result);
end;

function TActivityLayoutCategories.Count: integer;
begin
  Result := FList.Count;
end;

constructor TActivityLayoutCategories.Create(AOwner: TComponent);
begin
  inherited;
  FList := TComponentList.Create(true);
end;

procedure TActivityLayoutCategories.Delete(AIndex: integer);
begin

end;

destructor TActivityLayoutCategories.Destroy;
begin
  FList.Free;
  inherited;
end;

function TActivityLayoutCategories.FindOrCreate(
  const ACaption: string): IActivityLayoutCategory;
var
  I, Idx: integer;
begin
  Idx := -1;
  for I := 0 to FList.Count - 1 do
    if SameText(TActivityLayoutCategory(FList[I]).Caption, ACaption) then
    begin
      Idx := I;
      Break;
    end;

  if Idx = -1 then
    Result := Add(ACaption)
  else
    Result := GetItem(Idx);

end;

function TActivityLayoutCategories.GetItem(
  AIndex: integer): IActivityLayoutCategory;
begin
  FList[AIndex].GetInterface(IActivityLayoutCategory, Result);
end;

{ TActivityLayoutCategory }

function TActivityLayoutCategory.Caption: string;
begin
  Result := FCaption;
end;

constructor TActivityLayoutCategory.Create(const ACaption: string);
begin
  inherited Create(nil);
  FCaption := ACaption;
  FImage := Graphics.TBitmap.Create;  
  FGroups := TActivityLayoutGroups.Create(self);
end;

destructor TActivityLayoutCategory.Destroy;
begin
  FGroups.Free;
  inherited;
end;

function TActivityLayoutCategory.GetImage: Graphics.TBitmap;
begin
  Result := FImage;
end;

function TActivityLayoutCategory.Groups: IActivityLayoutGroups;
begin
  Result := FGroups as IActivityLayoutGroups;
end;

procedure TActivityLayoutCategory.SetImage(Value: TBitmap);
begin
  FImage.Assign(Value);
end;

end.

