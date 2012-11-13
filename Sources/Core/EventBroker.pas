unit EventBroker;

interface
uses Classes, CoreClasses, Contnrs, typinfo, sysutils, ManagedList, Variants;

type
  TSubscription = class(TComponent)
  private
    FSubscriber: TComponent;
    FHandlerMethod: TEventHandlerMethod;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent; ASubscriber: TComponent;
      AHandlerMethod: TEventHandlerMethod); reintroduce;
    procedure Fire(Context: TWorkItem; EventData: Variant);
  end;

  TEventTopic = class(TManagedItem, IEventTopic)
  private
    FSubscriptions: TComponentList;
    FEnabled: boolean;
    function GetEnabled: boolean;
    procedure SetEnabled(Value: boolean);
  public
    constructor Create(AOwner: TManagedItemList; const AID: string); override;
    destructor Destroy; override;
    procedure Fire(Context: TWorkItem; EventData: Variant);
    procedure AddSubscription(ASubscriber: TComponent; AHandlerMethod: TEventHandlerMethod); overload;
    procedure RemoveSubscription(ASubscriber: TComponent;
      const AHandlerMethod: TEventHandlerMethod); overload;
    procedure RemoveSubscription(ASubscriber: TComponent); overload;
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

procedure TEventTopic.AddSubscription(ASubscriber: TComponent;
  AHandlerMethod: TEventHandlerMethod);
begin
  FSubscriptions.Add(TSubscription.Create(Self, ASubscriber, AHandlerMethod));
end;

constructor TEventTopic.Create(AOwner: TManagedItemList;
  const AID: string);
begin
  inherited Create(AOwner, AID);
  FSubscriptions := TComponentList.Create(True);
  FEnabled := True;
end;

destructor TEventTopic.Destroy;
begin
  FSubscriptions.Free;
  inherited;
end;

procedure TEventTopic.Fire(Context: TWorkItem; EventData: Variant);
var
  I: integer;
begin
  if not FEnabled then Exit;
  for I := 0 to FSubscriptions.Count - 1 do
    if FSubscriptions[I] is TSubscription then
      TSubscription(FSubscriptions[I]).Fire(Context, EventData);
end;

function TEventTopic.GetEnabled: boolean;
begin
  Result := FEnabled;
end;

procedure TEventTopic.RemoveSubscription(ASubscriber: TComponent);
var
  I: integer;
begin
  for I := FSubscriptions.Count -1 downto 0 do
    if TSubscription(FSubscriptions[I]).FSubscriber = ASubscriber then
      TSubscription(FSubscriptions[I]).Free;
end;


procedure TEventTopic.RemoveSubscription(ASubscriber: TComponent;
  const AHandlerMethod: TEventHandlerMethod);
var
  I: integer;
  Subscription: TSubscription;
begin
  for I := FSubscriptions.Count -1 downto 0 do
  begin
    Subscription := TSubscription(FSubscriptions[I]);
    if (Subscription.FSubscriber = ASubscriber) and
       (Addr(Subscription.FHandlerMethod) = Addr(AHandlerMethod))  then
      FSubscriptions[I].Free;
  end;
end;

procedure TEventTopic.SetEnabled(Value: boolean);
begin
  FEnabled := Value;
end;

{ TSubscription }

constructor TSubscription.Create(AOwner: TComponent;
  ASubscriber: TComponent; AHandlerMethod: TEventHandlerMethod);
begin
  inherited Create(AOwner);
  FSubscriber := ASubscriber;
  FHandlerMethod := AHandlerMethod;
  FSubscriber.FreeNotification(Self);
end;


procedure TSubscription.Fire(Context: TWorkItem; EventData: Variant);
begin
  TEventHandlerMethod(FHandlerMethod)(Context, EventData);
end;


procedure TSubscription.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FSubscriber) then
    Free;
end;


end.
