unit CoreClasses;

interface
uses SysUtils, Classes, Contnrs, Controls, Messages, ManagedList, Variants,
  typinfo, windows;

const
  etAppStarted = 'Application.Started';
  etAppStoped = 'Application.Stoped';

  EVT_MODULE_LOADED = 'events.OnModuleLoaded';

  GetModuleActivatorFunctionName = 'GetModuleActivator';


type
  EArgumentError = class(Exception);
  EArgumentTypeError = class(EArgumentError);
  EInterfaceMissingError = class(Exception);
  EServiceMissingError = class(Exception);
  EUIExtensionSiteMissingError = class(Exception);
  EWorkspaceMissingError = class(Exception);
  EViewMissingError = class(Exception);
  EDuplicateItemIDError = class(Exception);

  TGuard = class
  public
    class procedure CheckArgumentType(AClass: TClass; AInstance: TObject;
      const ArgumentName: string = '');
    class procedure CheckArgumentNotEmpty(AValue: Variant;
      const ArgumentName: string = '');
  end;                                       

  TWorkItem = class;

  TModuleKind = (mkInfrastructure, mkFoundation, mkExtension);

  IModule = interface
  ['{C29B7570-168C-4655-AC39-235A06A54D7C}']
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;
  end;


  TGetModuleActivator = function: TClass;

  IModuleEnumeratorEmbeded = interface
  ['{5E262A6E-C0FF-4441-8F76-C0A53816E6B8}']
    procedure Modules(Activators: TClassList; Kind: TModuleKind);
  end;

  IModuleEnumerator = interface
  ['{80750273-3990-4E3A-8B79-6B917BEBE3F9}']
    procedure Modules(AModules: TStrings; Kind: TModuleKind);
  end;

  TModuleLoaderInfoCallback = procedure(const AModuleName, AInfo: string; Kind: TModuleKind) of object;

  IModuleLoaderService = interface
  ['{F198EE64-F7E8-46EE-B1A6-6ADCA7E1AF9B}']
    procedure Load(AWorkItem: TWorkItem; AModules: TStrings; Kind: TModuleKind;
      AInfoCallback: TModuleLoaderInfoCallback);
    procedure LoadEmbeded(AWorkItem: TWorkItem; AActivators: TClassList;
      Kind: TModuleKind; AInfoCallback: TModuleLoaderInfoCallback);
    procedure UnLoadAll;
  end;

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

  IWorkspaces = interface(ICollection)
  ['{5E1BBC32-3807-4FDB-98BF-C245A6B689EC}']
    procedure RegisterWorkspace(const AName: string; AWorkspace: TComponent);
    procedure UnregisterWorkspace(const AName: string);
    function GetWorkspace(const AName: string): IWorkspace;
    property Workspace[const AName: string]: IWorkspace read GetWorkspace; default;
  end;

{Actions}


  IAction = interface;

  TActionHandlerMethod =  procedure(Sender: IAction) of object;
  TActionConditionMethod = function(Sender: IAction): boolean of object;

  TActionData = class(TComponent)
  private
    FOuts: TStringList;
    FNames: TStringList;
    FValues: array of variant;
    function IndexOf(const AName: string): integer;
  protected
    FActionURI: string;
    procedure Add(const AName: string);
    procedure AddOut(const AName: string);
    function IsEmbedded(const AName: string): boolean;
  public
    constructor Create(const ActionURI: string); reintroduce; virtual; 
    destructor Destroy; override;
    function ValueName(AIndex: integer): string;
    function Count: integer;
    procedure SetValue(const AName: string; AValue: Variant);
    function GetValue(const AName: string): Variant;
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure ResetValues;
    property Value[const AName: string]: Variant read GetValue write SetValue; default;
  end;

  TActionDataClass = class of TActionData;

  IAction = interface
  ['{FA986884-8701-4CDF-94E3-D601AA07FA31}']
    function Name: string;
    procedure Execute(Caller: TWorkItem);
    function CanExecute(Caller: TWorkItem): boolean;
    function VetoObject: Exception;
    procedure SetHandler(AHandler: TActionHandlerMethod);
    procedure SetDataClass(AClass: TActionDataClass);
    procedure ResetData;
    function GetData: TActionData;
    procedure RegisterCondition(ACondition: TActionConditionMethod);
    procedure RemoveCondition(ACondition: TActionConditionMethod);
    function GetCaller: TWorkItem;
    property Caller: TWorkItem read GetCaller;
    property Data: TActionData read GetData;
  end;

  IActions = interface(ICollection)
  ['{51DDF9E1-3A23-4758-B835-56370E1F3EA2}']
    procedure RegisterCondition(ACondition: TActionConditionMethod);
    procedure RemoveCondition(ACondition: TActionConditionMethod);
    function GetAction(const AName: string): IAction;
    property Action[const AName: string]: IAction read GetAction; default;
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

    procedure Init(const ACaption, AShortCut: string; AHandler: TNotifyEvent); 
    property Caption: string read GetCaption write SetCaption;
    property ShortCut: string read GetShortCut write SetShortCut;
    property Status: TCommandStatus read GetStatus write SetStatus;
    property Data[const AName: string]: Variant read GetData write SetData;
  end;

  ICommands = interface(ICollection)
  ['{5E1BBC32-3807-4FDB-98BF-C245A6B689EC}']
    procedure RemoveCommand(const AName: string);
    function GetCommand(const AName: string): ICommand;
    property Command[const AName: string]: ICommand read GetCommand; default;
  end;

{UIExtansions}
  IUIElementAdapter = interface
    function Add(AElement: TObject): TObject;
    procedure Remove(AElement: TObject);
  end;

  IUIExtensionSite = interface
  ['{B4CA1138-533A-4010-B6D5-DC986DE8E8C3}']
    function Add(AElement: TObject): TObject;
    procedure Remove(AElement: TObject);
    function Count: integer;
    function Get(Index: integer): TObject;
  end;

  IUIExtensionSites = interface
  ['{B78D07FB-9E66-4A40-8278-4CF70A397CB4}']
    procedure RegisterSite(const AName: string; AUIElementAdapter: IUIElementAdapter); overload;
    procedure UnregisterSite(const AName: string);
    function GetSite(const AName: string): IUIExtensionSite;
    property Sites[const AName: string]: IUIExtensionSite read GetSite; default;
  end;

{Event broker}
  TEventThreadOption = (etoPublisher, etoBackground);

  TEventHandlerMethod = procedure(EventData: Variant) of object;

  IEventTopic = interface
  ['{EBB1CD3E-9922-44E0-BF2C-5281C8E2EA03}']
    procedure Fire; overload;
    procedure Fire(EventData: Variant); overload;
    procedure AddSubscription(ASubscriber: TComponent; AHandlerMethod: TEventHandlerMethod;
      AWorkItem: TWorkItem = nil; AThreadOption: TEventThreadOption = etoPublisher);
    procedure RemoveSubscription(ASubscriber: TComponent;
      const AHandlerMethod: TEventHandlerMethod); overload;
    procedure RemoveSubscription(ASubscriber: TComponent); overload;
    function GetEnabled: boolean;
    procedure SetEnabled(AValue: boolean);
    property Enabled: boolean read GetEnabled write SetEnabled;
  end;

  IEventTopics = interface(ICollection)
  ['{7F28464E-51C9-4365-ABE5-7C944AB4DC5A}']
    function GetEventTopic(const AName: string): IEventTopic;
    property EventTopic[const AName: string]: IEventTopic read GetEventTopic; default;
  end;

{TItems}
  IItems = interface(ICollection)
  ['{918294AA-3730-4CE2-8610-BF8490369242}']
    procedure Add(const AID: string; AObj: TObject); overload;
    function Add(AObj: TObject): string; overload;
    procedure Remove(AObj: TObject);
    procedure Delete(const AID: string);
    procedure Clear(AClass: TClass);
    function Get(const AID: string; AClass: TClass): TObject;
    property Item[const AID: string; AClass: TClass]: TObject read Get; default;
  end;

{TWorkItem}
  TWorkItemStatus = (wisActive, wisInactive, wisTerminated);

  TAbstractController = class(TComponent)
  private
    function GetWorkItem: TWorkItem;
  protected
    function OnGetWorkItemState(const AName: string): Variant; virtual;
    procedure OnSetWorkItemState(const AName: string; const Value: Variant); virtual;
    procedure Terminate; virtual;
    procedure Run; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure Instantiate; virtual;
  public
    constructor Create(AOwner: TWorkItem); reintroduce; virtual;
    property WorkItem: TWorkItem read GetWorkItem;
  end;

  TControllerClass = class of TAbstractController;

  IWorkItems = interface(ICollection)
  ['{09683504-8734-4CA6-83B9-A2BD006A2CC3}']
    function Add(const AID: string = ''; AControllerClass: TControllerClass = nil): TWorkItem;
    function Find(const AID: string): TWorkItem;
    function Get(Index: integer): TWorkItem;
    property WorkItem[Index: integer]: TWorkItem read Get; default;
  end;

  TWorkItem = class(TManagedItem)
  private
    FParent: TWorkItem;
    FStatus: TWorkItemStatus;
    FControllerClass: TControllerClass;
    FController: TAbstractController;
    FEventTopics: TComponent;
    FServices: TComponent;
    FWorkItems: TComponent;
    FCommands: TComponent;
    FActions: TComponent;
    FWorkspaces: TComponent;
    FItems: TComponent;
    FStateValues: array of variant;
    FStateNames: TStringList;
    FContext: string;
    procedure ChangeStatus(NewStatus: TWorkItemStatus);
    function GetRoot: TWorkItem;
    function GetServices: IServices;
    function GetEventTopics: IEventTopics;
    function GetWorkItems: IWorkItems;
    function GetCommands: ICommands;
    function GetActions: IActions;
    function GetWorkspaces: IWorkspaces;
    function GetItems: IItems;
    function GetState(const AName: string): Variant;
    procedure SetState(const AName: string; const Value: Variant);
     //отключено за ненадобностью
    //function GetApplication: IInterface;
  protected
     //¬ корневом WorkItem перегрузить
    //function OnGetApplication: IInterface; virtual;


    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    procedure DebugInfo(const AInfoText: string);

    constructor Create(AOwner: TManagedItemList; AParent: TWorkItem;
      const AID: string; AControllerClass: TControllerClass); reintroduce;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Run;
    procedure Activate;
    procedure Deactivate;
    property Root: TWorkItem read GetRoot;
    property Services: IServices read GetServices;
    property WorkItems: IWorkItems read GetWorkItems;
    property EventTopics: IEventTopics read GetEventTopics;
    property Commands: ICommands read GetCommands;
    property Actions: IActions read GetActions;
    property Workspaces: IWorkspaces read GetWorkspaces;
    property Items: IItems read GetItems;
    property State[const AName: string]: Variant read GetState write SetState;
    property Controller: TAbstractController read FController;
    property Status: TWorkItemStatus read FStatus;
    property Parent: TWorkItem read FParent;
    //можно использовать как хочешь
    property Context: string read FContext write FContext;
    //ћожно использовать дл€ получени€ специализированного прикладного интерфейса
    //property Application: IInterface read GetApplication;
  end;

  TWorkItemClass = class of TWorkItem;

procedure RegisterEmbededModule(ActivatorClass: TClass; Kind: TModuleKind);

function FindWorkItem(const AID: string; AParent: TWorkItem): TWorkItem;

implementation

uses ModuleEnumeratorEmbeded, EventBroker, ServicesList, CommandsList,
  WorkspacesList, ItemsList, ActionsList;

var
  DebugInfoProc: procedure(const AInfo: string);

procedure RegisterEmbededModule(ActivatorClass: TClass; Kind: TModuleKind);
begin
  if HInstance = MainInstance then
    ModuleEnumeratorEmbeded.RegisterActivator(ActivatorClass, Kind);
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

type
  TWorkItems = class(TManagedItemList, IWorkItems)
  public
    function Add(const AID: string = ''; AControllerClass: TControllerClass = nil): TWorkItem;
    function Find(const AID: string): TWorkItem;
    function Get(Index: integer): TWorkItem;
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

constructor TWorkItem.Create(AOwner: TManagedItemList; AParent: TWorkItem;
  const AID: string; AControllerClass: TControllerClass);
var
  ParentList: TManagedItemList;
begin
  inherited Create(AOwner, '');

  if AID <> '' then Self.ID := AID;

  DebugInfo('Create WorkItem: ' + Self.ID);

  FStatus := wisInactive;
  FParent := AParent;
  FStateNames := TStringList.Create;

  //Collections
  ParentList := nil;
  if FParent <> nil then
    ParentList := TEventTopics(FParent.FEventTopics);
  FEventTopics := TEventTopics.Create(Self, lsmUp, ParentList);

  ParentList := nil;
  if FParent <> nil then
    ParentList := TManagedItemList(FParent.FCommands);
  FCommands := TCommands.Create(Self, lsmLocal{lsmUp}, ParentList);

  ParentList := nil;
  if FParent <> nil then
    ParentList := TManagedItemList(FParent.FActions);
  FActions := TActions.Create(Self, lsmUp, ParentList);

  ParentList := nil;
  if FParent <> nil then
    ParentList := TManagedItemList(FParent.FWorkspaces);
  FWorkspaces := TWorkspaces.Create(Self, lsmUp, ParentList);

  FServices := TServices.Create(Self);

  FWorkItems := TWorkItems.Create(Self, lsmLocal, nil);

  FItems := TItems.Create(Self, lsmLocal, nil);

  FControllerClass := AControllerClass;
  if Assigned(FControllerClass) then
  begin
    FController := FControllerClass.Create(Self);
    FController.FreeNotification(Self);
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
  DebugInfoProc(AInfoText);
end;

destructor TWorkItem.Destroy;
begin
  FStatus := wisTerminated;

  try
    if Assigned(FController) then FController.Terminate;

    TWorkItems(FWorkItems).Clear;
    TItems(FItems).Clear;
    TCommands(FCommands).Clear;
    TActions(FActions).Clear;
    TEventTopics(FEventTopics).Clear;
    TWorkspaces(FWorkspaces).Clear;
    TServices(FServices).Clear;

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


function TWorkItem.GetActions: IActions;
begin
  FActions.GetInterface(IActions, Result);
end;

{function TWorkItem.GetApplication: IInterface;
begin
  Result := Root.OnGetApplication;
end;}

function TWorkItem.GetCommands: ICommands;
begin
  FCommands.GetInterface(ICommands, Result);
end;

function TWorkItem.GetEventTopics: IEventTopics;
begin
  FEventTopics.GetInterface(IEventTopics, Result);
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
  FServices.GetInterface(IServices, Result);
end;

function TWorkItem.GetState(const AName: string): Variant;
var
  Idx: integer;
begin
  Result := Unassigned;
  if Assigned(FController) then
    Result := FController.OnGetWorkItemState(AName);

  if VarIsEmpty(Result) then
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
  FWorkspaces.GetInterface(IWorkspaces, Result);
end;

procedure TWorkItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

{function TWorkItem.OnGetApplication: IInterface;
begin
  Result := nil;
end;}


procedure TWorkItem.Run;
begin
  if Assigned(FController) then
    FController.Run;
end;



{ AbstractTController }

procedure TAbstractController.Activate;
begin

end;

constructor TAbstractController.Create(AOwner: TWorkItem);
begin
  inherited Create(AOwner);
  Instantiate;
end;

procedure TAbstractController.Deactivate;
begin

end;

function TAbstractController.GetWorkItem: TWorkItem;
begin
  Result := TWorkItem(Owner);
end;

procedure TAbstractController.Instantiate;
begin

end;

function TAbstractController.OnGetWorkItemState(
  const AName: string): Variant;
begin

end;

procedure TAbstractController.OnSetWorkItemState(const AName: string;
  const Value: Variant);
begin

end;

procedure TAbstractController.Run;
begin

end;

procedure TAbstractController.Terminate;
begin

end;

procedure TWorkItem.SetState(const AName: string; const Value: Variant);
var
  Idx: integer;
begin
  Idx := FStateNames.IndexOf(AName);
  if Idx = - 1 then
  begin
    Idx := FStateNames.Add(AName);
    SetLength(FStateValues, Idx + 1);
  end;

  FStateValues[Idx] := Value;

  if Assigned(FController) then
    FController.OnSetWorkItemState(AName, Value);
end;

{ TWorkItems }

function TWorkItems.Add(const AID: string; AControllerClass: TControllerClass): TWorkItem;
begin
  Result := TWorkItem.Create(Self, TWorkItem(Self.Owner), AID, AControllerClass);
  InternalAdd(Result);
end;

function TWorkItems.Find(const AID: string): TWorkItem;
begin
  Result := TWorkItem(GetByID(AID));
end;


function TWorkItems.Get(Index: integer): TWorkItem;
begin
  Result := TWorkItem(inherited Get(Index));
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

{ TGuard }

class procedure TGuard.CheckArgumentNotEmpty(AValue: Variant;
  const ArgumentName: string = '');
begin
  if VarIsEmpty(AValue) then
    raise EArgumentError.CreateFmt('Argument %s is Empty', [ArgumentName]);
end;

class procedure TGuard.CheckArgumentType(AClass: TClass; AInstance: TObject;
  const ArgumentName: string = '');
begin
  if (not Assigned(AInstance)) or ( not (AInstance is AClass)) then
    raise EArgumentTypeError.CreateFmt('Type of argument %s error', [ArgumentName]);
end;


{ TActionData }

procedure TActionData.Add(const AName: string);
begin
  if FNames.IndexOf(AName) = -1 then
    SetLength(FValues, FNames.Add(AName) + 1);
end;

procedure TActionData.Assign(Source: TPersistent);
var
  I: integer;
begin
  ResetValues;

  for I := 0 to Count - 1 do
  begin
    if (ValueName(I) = 'Name') or (ValueName(I) = 'Tag') then Continue;
    if Source is TWorkItem then
      SetValue(ValueName(I), (Source as TWorkItem).State[ValueName(I)])
    else if (Source is TActionData) and ((Source as TActionData).IndexOf(ValueName(I)) <> -1) then
      SetValue(ValueName(I), (Source as TActionData).GetValue(ValueName(I)))
    else if IsPublishedProp(Source, ValueName(I)) then
      SetValue(ValueName(I), GetPropValue(Source, ValueName(I)));
  end
end;

procedure TActionData.AssignTo(Dest: TPersistent);
var
  I: integer;
begin

  for I := 0 to Count - 1 do
  begin
    if Dest is TWorkItem then
      (Dest as TWorkItem).State[ValueName(I)] := GetValue(ValueName(I))
    else if (Dest is TActionData) and ((Dest as TActionData).IndexOf(ValueName(I)) <> -1) then
      (Dest as TActionData).SetValue(ValueName(I), GetValue(ValueName(I)))
    else if IsPublishedProp(Dest, ValueName(I)) then
      SetPropValue(Dest, ValueName(I), GetValue(ValueName(I)));
  end;

end;

constructor TActionData.Create(const ActionURI: string);
var
  Count, I: Integer;
  TempList: PPropList;
begin
  inherited Create(nil);
  FActionURI := ActionURI;
  FNames := TStringList.Create;
  FOuts := TStringList.Create;

  Count := GetPropList(Self, TempList);
  if Count > 0 then
    try
      for I := 0 to Count - 1 do
        Add(string(TempList^[I].Name));
    finally
      FreeMem(TempList);
  end;
end;

destructor TActionData.Destroy;
begin
  FNames.Free;
  FOuts.Free;
  inherited;
end;

function TActionData.GetValue(const AName: string): Variant;
begin
  if IsEmbedded(AName) then
    Result := GetPropValue(Self, AName)
  else if IndexOf(AName) <> -1 then
    Result := FValues[IndexOf(AName)]
  else
    raise Exception.CreateFmt('Param %s for action %s not found', [AName, FActionURI]);
end;

function TActionData.IsEmbedded(const AName: string): boolean;
begin
  Result := IsPublishedProp(Self, AName);
end;

procedure TActionData.SetValue(const AName: string; AValue: Variant);
begin
  if IsEmbedded(AName) then
  begin
    if GetPropInfo(Self, AName).SetProc <> nil then
      SetPropValue(Self, AName, AValue)
  end
  else if IndexOf(AName) <> -1 then
    FValues[IndexOf(AName)] := AValue
  else
    raise Exception.CreateFmt('Action param %s not found', [AName]);
end;

function TActionData.Count: integer;
begin
  Result := FNames.Count;
end;

function TActionData.ValueName(AIndex: integer): string;
begin
  Result := FNames[AIndex];
end;

function TActionData.IndexOf(const AName: string): integer;
begin
  Result := FNames.IndexOf(AName);
end;

procedure TActionData.ResetValues;
var
  I: integer;
begin
  for I := 0 to Count - 1 do
    if FOuts.IndexOf(ValueName(I)) = -1 then
      SetValue(ValueName(I), Unassigned);
end;


procedure TActionData.AddOut(const AName: string);
begin
  if FOuts.IndexOf(AName) = -1 then
    FOuts.Add(AName);
end;


procedure DebugInfoProcConsole(const AInfo: string);
begin
  WriteLn(AInfo);
end;

procedure DebugInfoProcStub(const AInfo: string);
begin

end;

initialization

  if FindCmdLineSwitch('debug') then
  begin
    AllocConsole();
    DebugInfoProc := DebugInfoProcConsole;
  end
  else
    DebugInfoProc := DebugInfoProcStub;

  DebugInfoProc(format('Start debug %s', [ParamStr(0)]));
end.
