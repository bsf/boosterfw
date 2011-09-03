unit EventBroker;

interface
uses Classes, CoreClasses, Contnrs, typinfo, sysutils, ManagedList, Variants;

type

  TEventTopic = class;

  TCustomSubscription = class(TComponent)
  private
    FSubscriber: TComponent;
    FHandlerMethod: TMethod;
    FWorkItem: TWorkItem;
    FThreadOption: TEventThreadOption;
    function CanFire(AWorkItem: TWorkItem): boolean;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TEventTopic; ASubscriber: TComponent;
      AHandlerMethod: TMethod; AWorkItem: TWorkItem; AThreadOption: TEventThreadOption); reintroduce;
  end;

  TSubscription = class(TCustomSubscription)
  public
    constructor Create(AOwner: TEventTopic; ASubscriber: TComponent;
      AHandlerMethod: TEventHandlerMethod; AWorkItem: TWorkItem;
      AThreadOption: TEventThreadOption); reintroduce;
    procedure Fire(EventData: Variant);
  end;

  TSubscriptionNotifyEvent = class(TCustomSubscription)
  public
    constructor Create(AOwner: TEventTopic; ASubscriber: TComponent;
      AHandlerMethod: TNotifyEvent; AWorkItem: TWorkItem;
      AThreadOption: TEventThreadOption); reintroduce;
    procedure Fire(Sender: TObject; AWorkItem: TWorkItem);
  end;

  TCustomPublication = class(TComponent)
  private
    FPublisher: TComponent;
    FEventName: string;
    FHandler: TMethod;
    FWorkItem: TWorkItem;
    procedure UnLinkHandler;
    procedure LinkHandler;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure InitHandler; virtual;
  public
    constructor Create(AOwner: TEventTopic; APublisher: TComponent;
      const AEventName: string; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

  TPublicationClass = class of TCustomPublication;

  TPublicationNotifyEvent = class(TCustomPublication)
  private
    procedure SetHandler(AEventHandler: TNotifyEvent);
    procedure EventHandler(Sender: TObject);
  protected
    procedure InitHandler; override;
  end;

  TEventTopic = class(TManagedItem, IEventTopic)
  private
    FSubscriptions: TComponentList;
    FPublications: TComponentList;
    FEnabled: boolean;
    procedure RemoveSubscription(ASubscriber: TComponent;
      const AHandlerMethod: TMethod); overload;
    procedure SetEnabled(Value: boolean);
    function GetEnabled: boolean;
    function GetPublicationClass(const AEventTypeName: ShortString): TPublicationClass;
  public
    constructor Create(AOwner: TManagedItemList; const AID: string); override;
    destructor Destroy; override;
    procedure Fire; overload; 
    procedure Fire(EventData: Variant); overload;
    procedure AddPublication(APublisher: TComponent; const AEventName: string;
      AWorkItem: TWorkItem = nil);
    procedure RemovePublication(APublisher: TComponent;
      const AEventName: string); overload;
    procedure RemovePublication(APublisher: TComponent); overload;
    procedure AddSubscription(ASubscriber: TComponent; AHandlerMethod: TNotifyEvent;
      AWorkItem: TWorkItem = nil; AThreadOption: TEventThreadOption = etoPublisher); overload;
    procedure AddSubscription(ASubscriber: TComponent; AHandlerMethod: TEventHandlerMethod;
      AWorkItem: TWorkItem = nil; AThreadOption: TEventThreadOption = etoPublisher); overload;
    procedure RemoveSubscription(ASubscriber: TComponent;
      const AHandlerMethod: TNotifyEvent); overload;
    procedure RemoveSubscription(ASubscriber: TComponent;
      const AHandlerMethod: TEventHandlerMethod); overload;
    procedure RemoveSubscription(ASubscriber: TComponent); overload;
    function GetInfo: string; override;
    property Enabled: boolean read GetEnabled write SetEnabled;
  end;

  TEventTopics = class(TManagedItemList, IEventTopics)
  private
    function GetEventTopic(const AName: string): IEventTopic;
  public
    property EventTopic[const AName: string]: IEventTopic read GetEventTopic; default;
  end;

implementation

{ TEventTopics }

function TEventTopics.GetEventTopic(const AName: string): IEventTopic;
var
  et: TEventTopic;
begin
  et := TEventTopic(GetByID(AName));

  if et = nil then
  begin
    et := TEventTopic.Create(Self, AName);
    InternalAdd(et);
  end;

  et.QueryInterface(IEventTopic, Result);
end;

{ TEventTopic }

procedure TEventTopic.AddPublication(APublisher: TComponent;
  const AEventName: string; AWorkItem: TWorkItem);
var
  EvtInfo: PPropInfo;
  PublicationClass: TPublicationClass;
begin
  EvtInfo := GetPropInfo(APublisher, AEventName, [tkMethod]);
  if EvtInfo <> nil then
  begin
    PublicationClass := GetPublicationClass(EvtInfo.PropType^.Name);
    if PublicationClass <> nil then
      FPublications.Add(PublicationClass.Create(Self, APublisher, AEventName, AWorkItem));
  end;
end;

procedure TEventTopic.AddSubscription(ASubscriber: TComponent;
  AHandlerMethod: TEventHandlerMethod; AWorkItem: TWorkItem; AThreadOption: TEventThreadOption);
begin
  FSubscriptions.Add(TSubscription.Create(Self, ASubscriber, AHandlerMethod,
    AWorkItem, AThreadOption));
end;

procedure TEventTopic.AddSubscription(ASubscriber: TComponent;
  AHandlerMethod: TNotifyEvent; AWorkItem: TWorkItem; AThreadOption: TEventThreadOption);
begin
  FSubscriptions.Add(TSubscriptionNotifyEvent.Create(Self, ASubscriber,
    AHandlerMethod, AWorkItem, AThreadOption));
end;

constructor TEventTopic.Create(AOwner: TManagedItemList;
  const AID: string);
begin
  inherited Create(AOwner, AID);
  FSubscriptions := TComponentList.Create(True);
  FPublications := TComponentList.Create(True);
  FEnabled := True;
end;

destructor TEventTopic.Destroy;
begin
  FPublications.Free;
  FSubscriptions.Free;
  inherited;
end;

procedure TEventTopic.Fire(EventData: Variant);
var
  I: integer;
begin
  if not FEnabled then Exit;
  for I := 0 to FSubscriptions.Count - 1 do
    if FSubscriptions[I] is TSubscription then
      TSubscription(FSubscriptions[I]).Fire(EventData)
    else if FSubscriptions[I] is TSubscriptionNotifyEvent then
      TSubscriptionNotifyEvent(FSubscriptions[I]).Fire(nil, nil);
end;

function TEventTopic.GetInfo: string;
begin
  Result := 'Subscriptions: ' + IntToStr(FSubscriptions.Count) + #10#13 +
    'Publications: ' + IntToStr(FPublications.Count);
end;

procedure TEventTopic.RemoveSubscription(ASubscriber: TComponent;
  const AHandlerMethod: TMethod);
var
  I: integer;
  Subscription: TCustomSubscription;
begin
  for I := FSubscriptions.Count -1 downto 0 do
  begin
    Subscription := TCustomSubscription(FSubscriptions[I]);
    if (Subscription.FSubscriber = ASubscriber) and
       (Subscription.FHandlerMethod.Code = AHandlerMethod.Code) and
       (Subscription.FHandlerMethod.Data = AHandlerMethod.Data)  then
      FSubscriptions[I].Free;
  end;
end;

procedure TEventTopic.RemovePublication(APublisher: TComponent;
  const AEventName: string);
var
  I: integer;
begin
  for I := FPublications.Count -1 downto 0 do
    if (TCustomPublication(FPublications[I]).FPublisher = APublisher) and
       SameText(TCustomPublication(FPublications[I]).FEventName, AEventName) then
       TCustomPublication(FPublications[I]).Free;
end;

procedure TEventTopic.RemovePublication(APublisher: TComponent);
var
  I: integer;
begin
  for I := FPublications.Count -1 downto 0 do
    if TCustomPublication(FPublications[I]).FPublisher = APublisher then
       TCustomPublication(FPublications[I]).Free;
end;

procedure TEventTopic.RemoveSubscription(ASubscriber: TComponent);
var
  I: integer;
begin
  for I := FSubscriptions.Count -1 downto 0 do
    if TCustomSubscription(FSubscriptions[I]).FSubscriber = ASubscriber then
      TCustomSubscription(FSubscriptions[I]).Free;
end;


procedure TEventTopic.RemoveSubscription(ASubscriber: TComponent;
  const AHandlerMethod: TNotifyEvent);
begin
  RemoveSubscription(ASubscriber, TMethod(AHandlerMethod));
end;

procedure TEventTopic.RemoveSubscription(ASubscriber: TComponent;
  const AHandlerMethod: TEventHandlerMethod);
begin
  RemoveSubscription(ASubscriber, TMethod(AHandlerMethod));
end;

procedure TEventTopic.SetEnabled(Value: boolean);
begin
  FEnabled := Value;
end;

function TEventTopic.GetPublicationClass(
  const AEventTypeName: ShortString): TPublicationClass;
begin
  Result := nil;
  if SameText(string(AEventTypeName), 'TNotifyEvent') then
    Result := TPublicationNotifyEvent;
end;

function TEventTopic.GetEnabled: boolean;
begin
  Result := FEnabled;
end;

procedure TEventTopic.Fire;
begin
  Fire(Unassigned);
end;

{ TSubscription }

constructor TSubscription.Create(AOwner: TEventTopic;
  ASubscriber: TComponent; AHandlerMethod: TEventHandlerMethod; AWorkItem: TWorkItem;
  AThreadOption: TEventThreadOption);
begin
  inherited Create(AOwner, ASubscriber, TMethod(AHandlerMethod), AWorkItem, AThreadOption);
end;


procedure TSubscription.Fire(EventData: Variant);
begin
  if CanFire(FWorkItem) then
    TEventHandlerMethod(FHandlerMethod)(EventData);
end;


{ TSubscriptionNotifyEvent }

constructor TSubscriptionNotifyEvent.Create(AOwner: TEventTopic;
  ASubscriber: TComponent; AHandlerMethod: TNotifyEvent; AWorkItem: TWorkItem;
  AThreadOption: TEventThreadOption);
begin
  inherited Create(AOwner, ASubscriber, TMethod(AHandlerMethod), AWorkItem, AThreadOption);
end;

procedure TSubscriptionNotifyEvent.Fire(Sender: TObject; AWorkItem: TWorkItem);
begin
  if CanFire(AWorkItem) then
    TNotifyEvent(FHandlerMethod)(Sender);
end;

{ TCustomSubscription }

function TCustomSubscription.CanFire(AWorkItem: TWorkItem): boolean;
begin
  Result := true;
//  if Assigned(FWorkItem) and (FWorkItem <> AWorkItem) then
  //  Result := false;
end;

constructor TCustomSubscription.Create(AOwner: TEventTopic;
  ASubscriber: TComponent; AHandlerMethod: TMethod; AWorkItem: TWorkItem;
  AThreadOption: TEventThreadOption);
begin
  inherited Create(AOwner);
  FSubscriber := ASubscriber;
  FHandlerMethod := AHandlerMethod;
  FSubscriber.FreeNotification(Self);
  FWorkItem := AWorkItem;
  FThreadOption := AThreadOption;
end;

procedure TCustomSubscription.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FSubscriber) then
    Free;
end;

{ TCustomPublication }

constructor TCustomPublication.Create(AOwner: TEventTopic;
  APublisher: TComponent; const AEventName: string; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FPublisher := APublisher;
  FEventName := AEventName;
  FPublisher.FreeNotification(Self);
  FWorkItem := AWorkItem;
  LinkHandler;
end;

destructor TCustomPublication.Destroy;
begin
  UnLinkHandler;
  inherited;
end;

procedure TCustomPublication.InitHandler;
begin

end;

procedure TCustomPublication.LinkHandler;
begin
  InitHandler;
  SetMethodProp(FPublisher, FEventName, FHandler);
end;

procedure TCustomPublication.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPublisher) then
    Free;
end;

procedure TCustomPublication.UnLinkHandler;
const
  NilMethod: TMethod = (Code: nil; Data: nil);
var
  _Method: TMethod;
begin
  _Method := GetMethodProp(FPublisher, FEventName);
  if _Method.Code = FHandler.Code then
    SetMethodProp(FPublisher, FEventName, NilMethod);
end;


{ TPublicationNotifyEvent }

procedure TPublicationNotifyEvent.SetHandler(AEventHandler: TNotifyEvent);
begin
  FHandler := TMethod(AEventHandler);
end;

procedure TPublicationNotifyEvent.EventHandler(Sender: TObject);
begin
  TEventTopic(Owner).Fire(Unassigned);
end;

procedure TPublicationNotifyEvent.InitHandler;
begin
  SetHandler(EventHandler);
end;

end.
