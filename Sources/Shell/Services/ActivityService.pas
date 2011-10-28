unit ActivityService;

interface
uses Classes, CoreClasses, Graphics, ActivityServiceIntf, Contnrs, Sysutils,
 SecurityIntf, ShellIntf, inifiles, HashList, db, variants;

type
  TActivityInfo = class(TComponent, IActivityInfo, ISecurityResNode)
  private
    FURI: string;
    FActivityClass: string;
    FEntityName: string;
    FEntityViewName: string;
    FTitle: string;
    FGroup: string;
    FMenuIndex: integer;
    FShortCut: string;
    FImage: Graphics.TBitmap;
    FUsePermission: boolean;
    FOptions: TStringList;
    FParams: TStringList;
    FOuts: TStringList;
  protected
    function URI: string;

    procedure SetActivityClass(const Value: string);
    function GetActivityClass: string;

    function EntityName: string;
    function EntityViewName: string;
    function Params: TStrings;
    function Outs: TStrings;

    procedure SetTitle(const Value: string);
    function GetTitle: string;
    procedure SetGroup(const Value: string);
    function GetGroup: string;
    procedure SetMenuIndex(Value: integer);
    function GetMenuIndex: integer;

    function GetShortCut: string;
    procedure SetShortCut(const Value: string);
    function GetImage: Graphics.TBitmap;
    procedure SetImage(Value: Graphics.TBitmap);
    procedure SetUsePermission(Value: boolean);
    function GetUsePermission: boolean;

    function OptionExists(const AName: string): boolean;
    function OptionValue(const AName: string): string;

    //ISecurityResNode
    function GetSecurityResNodeID: string;
    function ISecurityResNode.ID = GetSecurityResNodeID;
    function GetSecurityResNodeName: string;
    function ISecurityResNode.Name = GetSecurityResNodeName;
    function GetSecurityResNodeDescription: string;
    function ISecurityResNode.Description = GetSecurityResNodeDescription;
  public
    constructor Create(const AURI: string); reintroduce;
    destructor Destroy; override;

    property ActivityClass: string read GetActivityClass write SetActivityClass;
    property Title: string read GetTitle write SetTitle;
    property Group: string read GetGroup write SetGroup;
    property MenuIndex: integer read GetMenuIndex write SetMenuIndex;
    property ShortCut: string read GetShortCut write SetShortCut;
    property Image: Graphics.TBitmap read GetImage write SetImage;
    property UsePermission: boolean read GetUsePermission write SetUsePermission;
  end;

  TActivityService = class(TComponent, IActivityService, IActivityInfos, ISecurityResProvider)
  const
    ENTC_UI = 'ENTC_UI';
    ENTC_UI_VIEW_LIST = 'List2';
    ENTC_UI_VIEW_CMD = 'Commands';

    //SecurityClass
    SECURITY_RES_PROVIDER_ID = 'security.resprovider.app.activities';
    SECURITY_PROVIDER_ACTIVITIES = 'Security.Policy.App.Activities';
    SECURITY_CLASS_ACTIVITY = SECURITY_PROVIDER_ACTIVITIES;
    SECURITY_CLASS_ACTIVITY_ITEM = '{A84F4D00-F3FA-4FFB-8B71-D14CF6795E52}';
    SECURITY_PERMISSION_ACTIVITY_EXECUTE = 'app.activity.execute';

  private
    FWorkItem: TWorkItem;
    FBuilders: THashList<TActivityBuilder>;
    FInfos: THashList<TActivityInfo>;
    procedure BuildActivities;
    procedure OnAppStartedHandler(EventData: Variant);
  protected
    //IActivityService
    procedure RegisterActivityClass(ABuilder: TActivityBuilder);
    function RegisterActivityInfo(const URI: string): IActivityInfo;
    function ActivityInfo(const URI: string): IActivityInfo;
    function Infos: IActivityInfos;
    //IActivityInfos
    function ActivityInfosCount: integer;
    function ActivityInfoByIndex(AIndex: integer): IActivityInfo;
    function IActivityInfos.Count = ActivityInfosCount;
    function IActivityInfos.Item = ActivityInfoByIndex;
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
  end;
implementation




{ TActivityService }

function TActivityService.ActivityInfo(const URI: string): IActivityInfo;
begin
  Result := FInfos[URI] as IActivityInfo;
end;

function TActivityService.ActivityInfoByIndex(AIndex: integer): IActivityInfo;
begin
  Result := FInfos.Items[AIndex] as IActivityInfo;
end;

function TActivityService.ActivityInfosCount: integer;
begin
  Result := FInfos.Count;
end;

procedure TActivityService.BuildActivities;
var
  I: integer;
  list: TDataSet;
  info: TActivityInfo;
  builder: TActivityBuilder;
  securitySvc: ISecurityService;
begin

  list := App.Entities[ENTC_UI].GetView(ENTC_UI_VIEW_LIST, FWorkItem).Load([]);
  while not list.Eof do
  begin
    builder := nil;
    if FBuilders.IndexOf(list['UIClass']) <> -1 then
      builder :=  FBuilders[list['UIClass']];
    if builder = nil then
    begin
      list.Next;
      Continue;
    end;

    info := TActivityInfo.Create(list['URI']);
    FInfos.Add(list['URI'], info);
    with info do
    begin
      FActivityClass := list['UIClass'];
      FEntityName := VarToStr(list['ENTITYNAME']);
      FEntityViewName := VarToStr(list['VIEWNAME']);
      Title := list['Title'];
      Group := VarToStr(list['GRP']);
      MenuIndex := list['MENUIDX'];
      UsePermission := list['USEPERM'] = 1;
      ExtractStrings([';'], [], PWideChar(VarToStr(list['OPTIONS'])), FOptions);
      ExtractStrings([',',';'], [], PWideChar(VarToStr(list['PARAMS'])), FParams);
      ExtractStrings([',',';'], [], PWideChar(VarToStr(list['OUTS'])), FOuts);
    end;

    list.Next;
  end;

  FWorkItem.EventTopics[EVT_ACTIVITY_LOADING].Fire;

  // Remove items when hav't permission
  securitySvc := FWorkItem.Services[ISecurityService] as ISecurityService;
  for I := FInfos.Count - 1 downto 0 do
  begin
    if FInfos.Items[I].UsePermission and
       (not SecuritySvc.
             CheckPermission(SECURITY_PERMISSION_ACTIVITY_EXECUTE, FInfos.Items[I].URI)) then
       FInfos.Delete(I);
  end;


  for info in FInfos do
    if FBuilders.IndexOf(info.FActivityClass) <> -1  then
      FBuilders[info.ActivityClass].Build(info);

  FWorkItem.EventTopics[EVT_ACTIVITY_LOADED].Fire;
end;

constructor TActivityService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FWorkItem := AWorkItem;
  FBuilders := THashList<TActivityBuilder>.Create;
  FInfos := THashList<TActivityInfo>.Create;
  FWorkItem.EventTopics[etAppStarted].AddSubscription(Self, OnAppStartedHandler);
  (FWorkItem.Services[ISecurityService] as ISecurityService).RegisterResProvider(Self);
end;

destructor TActivityService.Destroy;
begin
  FBuilders.Free;
  FInfos.Free;
  inherited;
end;

function TActivityService.GetSecurityChildRes(
  const AParentResID: string): IInterfaceList;
begin
  Result := TInterfaceList.Create;
end;

function TActivityService.GetSecurityGetRes(const ID: string): ISecurityResNode;
begin
  Result := FInfos.Values[ID] as ISecurityResNode;
end;

function TActivityService.GetSecurityResProviderID: string;
begin
  Result := SECURITY_RES_PROVIDER_ID;
end;

function TActivityService.GetSecurityTopRes: IInterfaceList;
var
  I: integer;
begin
  Result := TInterfaceList.Create;
  for I := 0 to FInfos.Count - 1 do
    if FInfos.Items[I].UsePermission then
      Result.Add(FInfos.Items[I] as ISecurityResNode);
end;

function TActivityService.Infos: IActivityInfos;
begin
  Result := Self;
end;

procedure TActivityService.OnAppStartedHandler(EventData: Variant);
begin
  BuildActivities;
end;

procedure TActivityService.RegisterActivityClass(ABuilder: TActivityBuilder);
begin
  FBuilders.Add(ABuilder.ActivityClass, ABuilder);
end;

function TActivityService.RegisterActivityInfo(
  const URI: string): IActivityInfo;
var
  info: TActivityInfo;  
begin
  info := TActivityInfo.Create(URI);
  FInfos.Add(URI, info);
  Result := info;
end;

{ TActivityInfo }

function TActivityInfo.GetActivityClass: string;
begin
  Result := FActivityClass;
end;

constructor TActivityInfo.Create(const AURI: string);
begin
  inherited Create(nil);
  FURI := AURI;
  FActivityClass := AURI;
  FOptions := TStringList.Create;
  FParams := TStringList.Create;
  FOuts := TStringList.Create;
  FImage := Graphics.TBitmap.Create;
  FUsePermission := false;
  FMenuIndex := 0;
end;

destructor TActivityInfo.Destroy;
begin
  FOptions.Free;
  FParams.Free;
  FOuts.Free;
  FImage.Free;
  inherited;
end;

function TActivityInfo.EntityName: string;
begin
  Result := FEntityName;
end;

function TActivityInfo.EntityViewName: string;
begin
  Result := FEntityViewName;
end;

function TActivityInfo.GetGroup: string;
begin
  Result := FGroup;
end;

function TActivityInfo.GetMenuIndex: integer;
begin
  Result := FMenuIndex;
end;

function TActivityInfo.GetImage: Graphics.TBitmap;
begin
  Result := FImage;
end;

function TActivityInfo.GetSecurityResNodeDescription: string;
begin
  Result := FGroup;
end;

function TActivityInfo.GetSecurityResNodeID: string;
begin
  Result := FURI;
end;

function TActivityInfo.GetSecurityResNodeName: string;
begin
  Result := FTitle;
end;

function TActivityInfo.GetShortCut: string;
begin
  Result := FShortCut;
end;

function TActivityInfo.OptionExists(const AName: string): boolean;
begin
  Result := (FOptions.IndexOfName(AName) <> -1) or (FOptions.IndexOf(AName) <> -1);
end;

function TActivityInfo.OptionValue(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

function TActivityInfo.Outs: TStrings;
begin
  Result := FOuts;
end;

function TActivityInfo.Params: TStrings;
begin
  Result := FParams;
end;

procedure TActivityInfo.SetActivityClass(const Value: string);
begin
  FActivityClass := Value;
end;

procedure TActivityInfo.SetGroup(const Value: string);
begin
  FGroup := Value;
end;

procedure TActivityInfo.SetMenuIndex(Value: integer);
begin
  FMenuIndex := Value;
end;

procedure TActivityInfo.SetImage(Value: Graphics.TBitmap);
begin
  FImage.Assign(Value);
end;

procedure TActivityInfo.SetShortCut(const Value: string);
begin
  FShortCut := Value;
end;

procedure TActivityInfo.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TActivityInfo.SetUsePermission(Value: boolean);
begin
  FUsePermission := Value;
end;

function TActivityInfo.GetTitle: string;
begin
  Result := FTitle;
end;

function TActivityInfo.GetUsePermission: boolean;
begin
  Result := FUsePermission;
end;

function TActivityInfo.URI: string;
begin
  Result := FURI;
end;

end.

