unit CoreClasses;

interface
uses SysUtils, Classes, Contnrs, Controls, Messages, Variants,
  typinfo, windows, graphics, StrUtils, ComObj;

const
  etAppStarted = 'Application.Started';
  etAppStoped = 'Application.Stoped';

  EVT_MODULE_LOAD = 'events.OnModuleLoad';

type
  TWorkItem = class;

  TModuleKind = (mkInfrastructure, mkFoundation, mkExtension);

  TModule = class(TComponent)
  private
    FWorkItem: TWorkItem;
  public
    constructor Create(AWorkItem: TWorkItem); reintroduce;
    class function Kind: TModuleKind; virtual;
    procedure Load; virtual;
    procedure UnLoad; virtual;
    property WorkItem: TWorkItem read FWorkItem;
  end;

  TModuleClass = class of TModule;

  IAuthenticationService = interface
  ['{220B21AC-CD11-48DF-ADCB-BE6F577EC416}']
    procedure Authenticate;
  end;

{Services}

  IServices = interface
  ['{05AC1915-C257-4FB8-BDED-DDC26A8BB3A2}']
    procedure Add(const AService: IInterface);
    procedure Remove(const AService: IInterface);
    function Query(const AService: TGUID; var Obj): boolean;
    function Get(const AService: TGUID): IInterface;
    property GetItem[const AService: TGUID]: IInterface read Get; default;
  end;

{WorkSpaces&View}

  IViewOwner = interface
  ['{A6D98F87-BEEB-4B55-9572-48F99FE026DC}']
    procedure OnViewActivate(AView: TControl);
    procedure OnViewDeactivate(AView: TControl);
    procedure OnViewShow(AView: TControl);
    procedure OnViewShortCut(AView: TControl; var Msg: TWMKey; var Handled: Boolean);
    procedure OnViewCloseQuery(AView: TControl; var CanClose: boolean);
    procedure OnViewClose(AView: TControl);
    procedure OnViewSiteChange(AView: TControl);
    procedure OnViewKeyPress(AView: TControl; var Key: Char);
    procedure OnViewMouseWheel(AView: TControl; Shift: TShiftState;
                   WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

  end;

  TViewSiteInfo = class(TComponent)
  private
    FTitle: string;
    function GetTitle: string;
  protected
    procedure SetTitle(const AValue: string); virtual;
  public
    property Title: string read GetTitle write SetTitle;
  end;

  TViewSiteInfoClass = class of TViewSiteInfo;

  IWorkspace = interface
  ['{423813DA-6320-4842-BB47-FCCBD7456DBA}']
    function ViewCount: integer;
    function GetView(Index: integer): TControl;
    property View[Index: integer]: TControl read GetView;
    function ViewExists(AView: TControl): boolean;

    procedure Show(AView: TControl; const ATitle: string);
    function Close(AView: TControl): boolean;
    function GetViewSiteInfo(AView: TControl): TViewSiteInfo;
    //events
    procedure SetOnViewSiteChange(AEvent: TNotifyEvent);
    function GetOnViewSiteChange: TNotifyEvent;

    procedure SetOnViewShow(AEvent: TNotifyEvent);
    function GetOnViewShow: TNotifyEvent;
    procedure SetOnViewClose(AEvent: TNotifyEvent);
    function GetOnViewClose: TNotifyEvent;

    property OnViewSiteChange: TNotifyEvent read GetOnViewSiteChange write SetOnViewSiteChange;
    property OnViewShow: TNotifyEvent read GetOnViewShow write SetOnViewShow;
    property OnViewClose: TNotifyEvent read GetOnViewClose write SetOnViewClose;
  end;

  IWorkspaces = interface
  ['{5E1BBC32-3807-4FDB-98BF-C245A6B689EC}']
    procedure RegisterWorkspace(const AName: string; AWorkspace: TComponent);
    procedure UnregisterWorkspace(const AName: string);
    function GetWorkspace(const AName: string): IWorkspace;
    property Workspace[const AName: string]: IWorkspace read GetWorkspace; default;
  end;

{Activities}
  IActivity = interface;

  TActivityCallMode = (acmSingle, acmBatchFirst, acmBatchNext, acmBatchLast);

  TActivityHandler = class(TObject)
  public
    procedure Execute(Sender: TWorkItem; Activity: IActivity); virtual; abstract;
  end;

  IActivityData = interface
  ['{3890884F-D4DB-4E57-AECB-D432BA6CA6A8}']
    function Count: integer;
    function ValueName(AIndex: integer): string;
    function IndexOf(const AName: string): integer;
    procedure Assign(Source: TWorkItem; ABindingRule: string = '');
    procedure AssignTo(Target: TWorkItem);
    procedure SetValue(const AName: string; AValue: Variant);
    function GetValue(const AName: string): Variant;
    property Value[const AName: string]: Variant read GetValue write SetValue; default;
  end;

  IActivityVisual = interface

  end;

  IActivity = interface
  ['{D9404645-31DF-4505-8972-BD29B4D5F85F}']
    function URI: string;

    procedure SetActivityClass(const Value: string);
    function GetActivityClass: string;
    property ActivityClass: string read GetActivityClass write SetActivityClass;

    //function Visual: IActivityVisual;

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
    function HavePermission: boolean;

    function Options: TStrings;
    function OptionExists(const AName: string): boolean;
    function OptionValue(const AName: string): string;


    function Params: IActivityData;
    function Outs: IActivityData;

    function GetCallMode: TActivityCallMode;
    procedure SetCallMode(AValue: TActivityCallMode);
    property CallMode: TActivityCallMode read GetCallMode write SetCallMode;

    procedure RegisterHandler(AHandler: TActivityHandler);

    procedure Execute(Sender: TWorkItem);

  end;

  IActivityPermissionHandler = interface
  ['{87BFE264-2CB4-4DA1-BA4F-A90FE230BF2F}']
    function CheckPermission(Activity: IActivity): boolean;
    procedure DemandPermission(Activity: IActivity);
  end;

  IActivities = interface
  ['{135F7738-1BD9-4562-B9F3-EBA335B3CC3A}']
    procedure RegisterHandler(const ActivityClass: string; AHandler: TActivityHandler);
    procedure RegisterPermissionHandler(AHandler: IActivityPermissionHandler);
    function Count: integer;
    function GetItem(AIndex: integer): IActivity;
    function IndexOf(const URI: string): integer;
    procedure Remove(const URI: string);
    function FindOrCreate(const URI: string): IActivity;
    function IsShortCut(AWorkItem: TWorkItem; AShortCut: TShortCut): Boolean;
    property Activity[const URI: string]: IActivity read FindOrCreate; default;
  end;

{Commands}
  TCommandConditionMethod = function(const CommandName: string;
    Sender: TObject): boolean of object;

  TCommandStatus = (csEnabled, csDisabled, csUnavailable);

  ICommand = interface
  ['{00B99346-BC6F-4272-AFAB-FE0C653A68A2}']
    function Name: string;
    procedure Execute;
    procedure AddInvoker(AInvoker: TComponent; const AEventName: string = 'OnExecute');
    procedure SetHandler(AHandler: TNotifyEvent);
    function GetCaption: string;
    procedure SetCaption(const AValue: string);
    function GetGroup: string;
    procedure SetGroup(const AValue: string);
    function GetShortCut: string;
    procedure SetShortCut(const AValue: string);
    function GetStatus: TCommandStatus;
    procedure SetStatus(AStatus: TCommandStatus);
    function GetData(const AName: string): Variant;
    procedure SetData(const AName: string; AValue: Variant);

    function CanExecute: boolean;
    function VetoObject: Exception;
    procedure RegisterCondition(ACondition: TCommandConditionMethod);
    procedure RemoveCondition(ACondition: TCommandConditionMethod);

    property Caption: string read GetCaption write SetCaption;
    property Group: string read GetGroup write SetGroup;
    property ShortCut: string read GetShortCut write SetShortCut;
    property Status: TCommandStatus read GetStatus write SetStatus;
    property Data[const AName: string]: Variant read GetData write SetData;
  end;

  ICommands = interface
  ['{5E1BBC32-3807-4FDB-98BF-C245A6B689EC}']
    function Count: integer;
    function GetItem(AIndex: integer): ICommand;
    function IndexOf(const AName: string): integer;

    procedure Remove(const AName: string);
    function FindOrCreate(const AName: string): ICommand;
    property Command[const AName: string]: ICommand read FindOrCreate; default;
  end;


{Event broker}
  TEventHandlerMethod = procedure(Context: TWorkItem; EventData: Variant) of object;

  IEventTopic = interface
  ['{EBB1CD3E-9922-44E0-BF2C-5281C8E2EA03}']
    procedure Fire(Context: TWorkItem; EventData: Variant);
    procedure AddSubscription(ASubscriber: TComponent; AHandlerMethod: TEventHandlerMethod);
    procedure RemoveSubscription(ASubscriber: TComponent;
      const AHandlerMethod: TEventHandlerMethod); overload;
    procedure RemoveSubscription(ASubscriber: TComponent); overload;
    function GetEnabled: boolean;
    procedure SetEnabled(AValue: boolean);
    property Enabled: boolean read GetEnabled write SetEnabled;
  end;

  IEventTopics = interface
  ['{7F28464E-51C9-4365-ABE5-7C944AB4DC5A}']
    function GetEventTopic(const AName: string): IEventTopic;
    property EventTopic[const AName: string]: IEventTopic read GetEventTopic; default;
  end;

{TItems}
  IItems = interface
  ['{918294AA-3730-4CE2-8610-BF8490369242}']
    procedure Add(const AID: string; AObj: TObject); overload;
    function Add(AObj: TObject): string; overload;
    procedure Remove(AObj: TObject);
    procedure Delete(const AID: string);
    function Get(const AID: string; AClass: TClass): TObject;
    property Item[const AID: string; AClass: TClass]: TObject read Get; default;
  end;

{TWorkItem}
  TWorkItemStatus = (wisActive, wisInactive, wisTerminated);

  TWorkItemController = class(TComponent)
  private
    function GetWorkItem: TWorkItem;
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; virtual;
    procedure OnSetWorkItemState(const AName: string; const Value: Variant; var Done: boolean); virtual;
    procedure Terminate; virtual;
    procedure Run; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure Initialize; virtual;
  public
    constructor Create(AOwner: TWorkItem); reintroduce; virtual;
    property WorkItem: TWorkItem read GetWorkItem;
  end;

  TControllerClass = class of TWorkItemController;

  IWorkItems = interface
  ['{09683504-8734-4CA6-83B9-A2BD006A2CC3}']
    function Count: integer;
    function Add(AControllerClass: TControllerClass = nil; const AID: string = ''): TWorkItem;
    function Find(const AID: string): TWorkItem;
    function Get(Index: integer): TWorkItem;
    property WorkItem[Index: integer]: TWorkItem read Get; default;
  end;

  TWorkItem = class(TComponent)
  private
    FID: string;
    FParent: TWorkItem;
    FStatus: TWorkItemStatus;
    FControllerClass: TControllerClass;
    FController: TWorkItemController;
    FEventTopics: TComponent;
    FServices: TComponent;
    FWorkItems: TComponent;
    FCommands: TComponent;
    FActivities: TComponent;
    FWorkspaces: TComponent;
    FItems: TComponent;
    FStateValues: array of variant;
    FStateNames: TStringList;
    FContext: string;
    FCallStack: TStringList;
    FDebugMode: boolean;
    procedure ChangeStatus(NewStatus: TWorkItemStatus);
    function GetRoot: TWorkItem;
    function GetServices: IServices;
    function GetEventTopics: IEventTopics;
    function GetWorkItems: IWorkItems;
    function GetCommands: ICommands;
    function GetActivities: IActivities;
    function GetWorkspaces: IWorkspaces;
    function GetItems: IItems;
    function GetState(const AName: string): Variant;
    procedure SetState(const AName: string; const Value: Variant);
    function GetCallStack: TStringList;
  public
    procedure DebugInfo(const AInfoText: string);

    constructor Create(AParent: TWorkItem;
      const AID: string; AControllerClass: TControllerClass); reintroduce;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Run;
    procedure Activate;
    procedure Deactivate;
    property ID: string read FID;
    property Root: TWorkItem read GetRoot;
    property Services: IServices read GetServices;
    property WorkItems: IWorkItems read GetWorkItems;
    property EventTopics: IEventTopics read GetEventTopics;
    property Commands: ICommands read GetCommands;
    property Activities: IActivities read GetActivities;
    property Workspaces: IWorkspaces read GetWorkspaces;
    property Items: IItems read GetItems;
    property State[const AName: string]: Variant read GetState write SetState;
    property Controller: TWorkItemController read FController;
    property Status: TWorkItemStatus read FStatus;
    property Parent: TWorkItem read FParent;
    property CallStack: TStringList read GetCallStack;
    //можно использовать как хочешь
    property Context: string read FContext write FContext;
  end;

procedure RegisterModule(ModuleClass: TModuleClass);
function ModuleClasses: TClassList;

function FindWorkItem(const AID: string; AParent: TWorkItem): TWorkItem;

function GetLocaleString(AResStr: Pointer): string;
procedure SetLocaleString(AResStr: Pointer; const Value: string);

implementation

uses  EventBroker, Services, Commands, Activities, Workspaces, Items;

var
  ModuleClassesList: TClassList;

function ModuleClasses: TClassList;
begin
  if not Assigned(ModuleClassesList) then
    ModuleClassesList := TClassList.Create;

  Result := ModuleClassesList;
end;

procedure RegisterModule(ModuleClass: TModuleClass);
begin
  ModuleClasses.Add(ModuleClass);
end;

function FindWorkItem(const AID: string; AParent: TWorkItem): TWorkItem;
var
  I: integer;
begin
  Result := nil;

  if AParent.ID = AID then
  begin
    Result := AParent;
    Exit;
  end;

  for I := 0 to AParent.WorkItems.Count - 1 do
  begin
    Result := FindWorkItem(AID, AParent.WorkItems[I]);
    if Assigned(Result) then Exit;
  end;
end;

var
  LocaleStrings: TStringList;

function GetLocaleStrings: TStringList;
begin
  if LocaleStrings = nil then
    LocaleStrings := TStringList.Create;
  Result := LocaleStrings;
end;

function GetLocaleString(AResStr: Pointer): string;
var
  idx: integer;
begin
  idx := GetLocaleStrings.IndexOfObject(AResStr);
  if idx <> -1 then
    Result := GetLocaleStrings[idx]
  else
    Result := LoadResString(AResStr);
end;

procedure SetLocaleString(AResStr: Pointer; const Value: string);
var
  idx: Integer;
begin
  idx := GetLocaleStrings.IndexOfObject(AResStr);
  if idx <> -1 then
    GetLocaleStrings[idx] := Value
  else
  begin
    GetLocaleStrings.AddObject(Value, TObject(AResStr));
  end;
end;

type
  TWorkItems = class(TComponent, IWorkItems)
  private
    FItems: TComponentList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Count: integer;
    function Add(AControllerClass: TControllerClass = nil; const AID: string = ''): TWorkItem;
    function Find(const AID: string): TWorkItem;
    function Get(Index: integer): TWorkItem;
    procedure Clear;
  end;

{ TWorkItem }

procedure TWorkItem.Activate;
begin
  ChangeStatus(wisActive);
  if Assigned(FController) then
    FController.Activate;

end;

procedure TWorkItem.Assign(Source: TPersistent);
var
  I, Count: integer;
  TempList: PPropList;
  PropInfo: PPropInfo;
begin

  if Source = nil then
    raise Exception.Create('Source object is nil.');

  Count := GetPropList(Self, TempList);
  for I := 0 to Count - 1 do
  begin
    PropInfo := TempList^[I];
    State[string(PropInfo^.Name)] := GetPropValue(Source, string(PropInfo^.Name));
  end

end;

procedure TWorkItem.ChangeStatus(NewStatus: TWorkItemStatus);
begin
  if FStatus <> NewStatus then
  begin
    FStatus := NewStatus;
  end;
end;

constructor TWorkItem.Create(AParent: TWorkItem;
  const AID: string; AControllerClass: TControllerClass);
begin
  inherited Create(nil);

  FID := AID;
  if AID = '' then
    FID := CreateClassID;

  FStatus := wisInactive;
  FParent := AParent;
  FStateNames := TStringList.Create;

  //Root only
  if FParent = nil then
  begin
    if FindCmdLineSwitch('debug') then
    begin
      AllocConsole();
      FDebugMode := true;
      WriteLn(format('Start debug %s', [ParamStr(0)]));
    end;

    FEventTopics := TEventTopics.Create(Self);
    FActivities := TActivities.Create(Self);
    FWorkspaces := TWorkspaces.Create(Self);
    FServices := TServices.Create(Self);
  end;

  DebugInfo('Create WorkItem: ' + Self.ID);

  FCommands := TCommands.Create(Self);
  FWorkItems := TWorkItems.Create(Self);
  FItems := TItems.Create(Self);

  FControllerClass := AControllerClass;
  if Assigned(FControllerClass) then
  begin
    FController := FControllerClass.Create(Self);
    FController.FreeNotification(Self);
    FController.Initialize;
  end;

end;

procedure TWorkItem.Deactivate;
begin
  ChangeStatus(wisInactive);
  if Assigned(FController) then
    FController.Deactivate;
end;

procedure TWorkItem.DebugInfo(const AInfoText: string);
begin
  if GetRoot.FDebugMode then
    WriteLn(AInfoText);
end;

destructor TWorkItem.Destroy;
begin
  FStatus := wisTerminated;

  try
    if Assigned(FController) then FController.Terminate;

    TWorkItems(FWorkItems).Clear;
    TItems(FItems).Clear;

    if Assigned(FServices) then TServices(FServices).Clear;

    if Assigned(FController) then FController.Free;

    FStateNames.Free;

    inherited;

    DebugInfo('Destroy WorkItem: ' + Self.ID);

  except
    on E: Exception do
      SysUtils.ShowException(E, ExceptAddr);
      //raise Exception.CreateFmt('Exception on workitem %s destroy. %s', [Self.ID, E.Message]);
  end;
end;

function TWorkItem.GetActivities: IActivities;
begin
  Result := Root.FActivities as IActivities;
end;

function TWorkItem.GetCallStack: TStringList;
begin
  if not Assigned(FCallStack) then
    FCallStack := TStringList.Create;
  Result := FCallStack;
end;

function TWorkItem.GetCommands: ICommands;
begin
  FCommands.GetInterface(ICommands, Result);
end;

function TWorkItem.GetEventTopics: IEventTopics;
begin
  Result := Root.FEventTopics as IEventTopics;
end;

function TWorkItem.GetItems: IItems;
begin
  FItems.GetInterface(IItems, Result);
end;

function TWorkItem.GetRoot: TWorkItem;
begin
  Result := Self;
  while Assigned(Result.Parent) do
    Result := Result.Parent;
end;

function TWorkItem.GetServices: IServices;
begin
  Result := Root.FServices as IServices;
end;

function TWorkItem.GetState(const AName: string): Variant;
var
  Idx: integer;
  Done: boolean;
begin
  Result := Unassigned;
  Done := false;

  if Assigned(FController) then
    Result := FController.OnGetWorkItemState(AName, Done);

  if not Done then
  begin
    Idx := FStateNames.IndexOf(AName);
    if Idx <> - 1 then
      Result := FStateValues[Idx];
  end;
end;

function TWorkItem.GetWorkItems: IWorkItems;
begin
  FWorkItems.GetInterface(IWorkItems, Result);
end;

function TWorkItem.GetWorkspaces: IWorkspaces;
begin
  Result := Root.FWorkspaces as IWorkspaces;
end;

procedure TWorkItem.Run;
begin
  if Assigned(FController) then
    FController.Run;
end;

{ AbstractTController }

procedure TWorkItemController.Activate;
begin

end;

constructor TWorkItemController.Create(AOwner: TWorkItem);
begin
  inherited Create(AOwner);
end;

procedure TWorkItemController.Deactivate;
begin

end;

function TWorkItemController.GetWorkItem: TWorkItem;
begin
  Result := TWorkItem(Owner);
end;

procedure TWorkItemController.Initialize;
begin

end;

function TWorkItemController.OnGetWorkItemState(
  const AName: string; var Done: boolean): Variant;
begin

end;

procedure TWorkItemController.OnSetWorkItemState(const AName: string;
  const Value: Variant; var Done: boolean);
begin
  Done := false;
end;

procedure TWorkItemController.Run;
begin

end;

procedure TWorkItemController.Terminate;
begin

end;

procedure TWorkItem.SetState(const AName: string; const Value: Variant);
var
  Idx: integer;
  Done: boolean;
begin
  Done := false;

  if Assigned(FController) then
    FController.OnSetWorkItemState(AName, Value, Done);

  if not Done then
  begin
    Idx := FStateNames.IndexOf(AName);
    if Idx = - 1 then
    begin
      Idx := FStateNames.Add(AName);
      SetLength(FStateValues, Idx + 1);
    end;

    FStateValues[Idx] := Value;
  end;
end;

{ TWorkItems }

function TWorkItems.Add(AControllerClass: TControllerClass; const AID: string): TWorkItem;
begin
  Result := TWorkItem.Create(TWorkItem(Self.Owner), AID, AControllerClass);
  FItems.Add(Result);
end;

procedure TWorkItems.Clear;
begin
  FItems.Clear;
end;

function TWorkItems.Count: integer;
begin
  Result := FItems.Count;
end;

constructor TWorkItems.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TComponentList.Create(true);
end;

destructor TWorkItems.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TWorkItems.Find(const AID: string): TWorkItem;
var
  I: integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if SameText(AID, (FItems[I] as TWorkItem).ID) then
      Exit(FItems[I] as TWorkItem);
end;


function TWorkItems.Get(Index: integer): TWorkItem;
begin
  Result := FItems[Index] as TWorkItem;
end;

{ TViewSiteInfo }

function TViewSiteInfo.GetTitle: string;
begin
  Result := FTitle;
end;

procedure TViewSiteInfo.SetTitle(const AValue: string);
begin
  if AValue <> FTitle then
    FTitle := AValue;
end;

{ TModule }

constructor TModule.Create(AWorkItem: TWorkItem);
begin
  inherited Create(nil);
  FWorkItem := AWorkItem.WorkItems.Add(nil, Self.ClassName);
end;

class function TModule.Kind: TModuleKind;
begin
  Result := mkExtension;
end;

procedure TModule.Load;
begin

end;

procedure TModule.UnLoad;
begin

end;

initialization


end.
