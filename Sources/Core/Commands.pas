unit Commands;

interface

uses SysUtils, Classes, CoreClasses, Contnrs, Typinfo, Variants,
  menus, actnlist;

type

  TConditionHandler = class(TObject)
    Condition: TCommandConditionMethod;
  end;

  TConditionList = class(TObject)
  private
    FList: TObjectList;
    function Find(ACondition: TCommandConditionMethod): integer;
  public
    function Count: integer;
    procedure Add(ACondition: TCommandConditionMethod);
    procedure Remove(ACondition: TCommandConditionMethod);
    function GetItem(AIndex: integer): TCommandConditionMethod;
    constructor Create;
    destructor Destroy; override;
  end;


  TCommand = class;

  TCommandInvoker = class(TComponent)
  private
    FEventName: string;
    FInvoker: TComponent;
    FOnExecute: TNotifyEvent;
    procedure ExecuteHandler(Sender: TObject);
    procedure BindEvent;
    procedure UnbindEvent;
    procedure SetInvokerStatus(AStatus: TCommandStatus);
    procedure SetInvokerCaption(const ACaption: string);
    procedure SetInvokerShortCuts(const AValues: TStrings);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TCommand; AInvoker: TComponent;
      const AEventName: string); reintroduce;
    destructor Destroy; override;
  end;

  TCommand = class(TComponent, ICommand)
  private
    FID: string;
    FCaption: string;
    FGroup: string;
    FShortCut: string;
    FShortCuts: TStringList;
    FInvokers: TComponentList;
    FStatus: TCommandStatus;
    FHandler: TNotifyEvent;
    FConditions: TConditionList;
    FVetoObject: Exception;
    FDataValues: array of variant;
    FDataNames: TStringList;
    function GetStatus: TCommandStatus;
    procedure SetStatus(AStatus: TCommandStatus);
    function GetCaption: string;
    procedure SetCaption(const AValue: string);
    function GetGroup: string;
    procedure SetGroup(const AValue: string);
    function GetShortCut: string;
    procedure SetShortCut(const AValue: string);
    function GetCommandName: string;
    function ICommand.Name = GetCommandName;
    function InternalCanExecute: boolean;
  public
    constructor Create(AOwner: TComponent; const AID: string); reintroduce;
    destructor Destroy; override;
    procedure Execute;
    procedure AddInvoker(AInvoker: TComponent; const AEventName: string);
    procedure RemoveInvoker(AInvoker: TComponent; const AEventName: string); overload;
    procedure RemoveInvoker(AInvoker: TComponent); overload;
    procedure SetHandler(AHandler: TNotifyEvent);
    function GetData(const AName: string): Variant;
    procedure SetData(const AName: string; AValue: Variant);

    function CanExecute: boolean;
    function VetoObject: Exception;
    procedure RegisterCondition(ACondition: TCommandConditionMethod);
    procedure RemoveCondition(ACondition: TCommandConditionMethod);

    property Status: TCommandStatus read GetStatus write SetStatus;
  end;

  TCommands = class(TComponent, ICommands)
  private
    FItems: TComponentList;
  protected
    function Count: integer;
    function GetItem(AIndex: integer): ICommand;
    function IndexOf(const AName: string): integer;
    procedure Remove(const AName: string);
    function FindOrCreate(const AName: string): ICommand;
  public
    property Command[const AName: string]: ICommand read FindOrCreate; default;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{ TCommand }

procedure TCommand.AddInvoker(AInvoker: TComponent;
  const AEventName: string);
var
  Idx: integer;
begin
  Idx := FInvokers.Add(TCommandInvoker.Create(Self, AInvoker, AEventName));
  TCommandInvoker(FInvokers[Idx]).SetInvokerStatus(FStatus);
  TCommandInvoker(FInvokers[Idx]).SetInvokerCaption(FCaption);
  TCommandInvoker(FInvokers[Idx]).SetInvokerShortCuts(FShortCuts);
end;

constructor TCommand.Create(AOwner: TComponent; const AID: string);
begin
  inherited Create(AOwner);
  FID := AID;
  FInvokers := TComponentList.Create(True);
  FStatus := csEnabled;
  FConditions := TConditionList.Create;
  FDataNames := TStringList.Create;
  FShortCuts := TStringList.Create;
end;

destructor TCommand.Destroy;
begin
  FInvokers.Free;
  FConditions.Free;
  FDataNames.Free;
  FShortCuts.Free;
  inherited;
end;

procedure TCommand.Execute;
begin
  if (FStatus <> csEnabled) or (not Assigned(FHandler)) then Exit;

  if InternalCanExecute then
    FHandler(Self);
end;

function TCommand.GetCommandName: string;
begin
  Result := FID;
end;

function TCommand.GetStatus: TCommandStatus;
begin
  Result := FStatus;
end;

procedure TCommand.RemoveInvoker(AInvoker: TComponent;
  const AEventName: string);
var
  I: integer;
begin
  for I := FInvokers.Count -1 downto 0 do
    if (TCommandInvoker(FInvokers[I]).FInvoker = AInvoker) and
       SameText(TCommandInvoker(FInvokers[I]).FEventName, AEventName) then
       FInvokers[I].Free;
end;

function TCommand.InternalCanExecute: boolean;
var
  I: integer;
begin
//  Result := TActions(Owner).CanExecute(GetActionName, Sender, ActionArg);
//  if not Result then Exit;

  for I := 0 to FConditions.Count -  1 do
  begin
    Result := FConditions.GetItem(I)(GetCommandName, Self);
    if not Result then Exit;
  end;

  Result := true;
end;

procedure TCommand.RemoveInvoker(AInvoker: TComponent);
var
  I: integer;
begin
  for I := FInvokers.Count -1 downto 0 do
    if TCommandInvoker(FInvokers[I]).FInvoker = AInvoker then
      FInvokers[I].Free;
end;

procedure TCommand.SetHandler(AHandler: TNotifyEvent);
begin
  FHandler := AHandler;
end;

procedure TCommand.SetStatus(AStatus: TCommandStatus);
var
  I: integer;
begin
  if FStatus <> AStatus then
  begin
    FStatus := AStatus;
    for I := 0 to FInvokers.Count - 1 do
      TCommandInvoker(FInvokers[I]).SetInvokerStatus(FStatus);
  end;
end;

function TCommand.CanExecute: boolean;
begin
  if Assigned(FVetoObject) then
    FVetoObject.Free;
  try
    Result := InternalCanExecute;
  except
    FVetoObject := AcquireExceptionObject;
    Result := false;
  end;
end;

procedure TCommand.RegisterCondition(ACondition: TCommandConditionMethod);
begin
  FConditions.Add(ACondition);
end;

procedure TCommand.RemoveCondition(ACondition: TCommandConditionMethod);
begin
  FConditions.Remove(ACondition);
end;

function TCommand.VetoObject: Exception;
begin
  Result := FVetoObject;
end;

function TCommand.GetData(const AName: string): Variant;
var
  Idx: integer;
begin
  Result := Unassigned;
  Idx := FDataNames.IndexOf(AName);
  if Idx <> - 1 then
    Result := FDataValues[Idx];
end;

function TCommand.GetGroup: string;
begin
  Result := FGroup;
end;

procedure TCommand.SetData(const AName: string; AValue: Variant);
var
  Idx: integer;
begin
  Idx := FDataNames.IndexOf(AName);
  if Idx = - 1 then
  begin
    Idx := FDataNames.Add(AName);
    SetLength(FDataValues, Idx + 1);
  end;

  FDataValues[Idx] := AValue;

end;

procedure TCommand.SetGroup(const AValue: string);
begin
  FGroup := AValue;
end;

function TCommand.GetCaption: string;
begin
  Result := FCaption;
end;

procedure TCommand.SetCaption(const AValue: string);
var
  I: integer;
begin
  if FCaption <> AValue then
  begin
    FCaption := AValue;
    for I := 0 to FInvokers.Count - 1 do
      TCommandInvoker(FInvokers[I]).SetInvokerCaption(FCaption);
  end;

end;

function TCommand.GetShortCut: string;
begin
  Result := FShortCut;
end;

procedure TCommand.SetShortCut(const AValue: string);
var
  I: integer;
begin
  if AValue <> FShortCut then
  begin
    FShortCut := AValue;
    FShortCuts.Clear;
    ExtractStrings([';',','], [], PChar(AValue), FShortCuts);
    for I := 0 to FInvokers.Count - 1 do
      TCommandInvoker(FInvokers[I]).SetInvokerShortCuts(FShortCuts);
  end;
end;

{ TCommands }

function TCommands.Count: integer;
begin
  Result := FItems.Count;
end;

constructor TCommands.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TComponentList.Create(true);
end;

destructor TCommands.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCommands.FindOrCreate(const AName: string): ICommand;
var
  idx: integer;
begin
  idx := IndexOf(AName);
  if idx = -1 then
    idx := FItems.Add(TCommand.Create(Self, AName));

  Result := GetItem(idx);
end;

function TCommands.GetItem(AIndex: integer): ICommand;
begin
  Result := FItems[AIndex] as ICommand;
end;

function TCommands.IndexOf(const AName: string): integer;
var
  I: integer;
begin
  Result := -1;
  for I := 0 to FItems.Count - 1 do
    if SameText(AName, (FItems[I] as TCommand).FID) then
      Exit(I);
end;

procedure TCommands.Remove(const AName: string);
var
  idx: integer;
begin
  idx := IndexOf(AName);
  if idx <> -1 then
    FItems.Delete(idx);
end;

{ TCommandInvoker }

procedure TCommandInvoker.BindEvent;
var
  EvtInfo: PPropInfo;
  TypeMethodName: ShortString;
begin
  EvtInfo := GetPropInfo(FInvoker, FEventName, [tkMethod]);
  if EvtInfo <> nil then
  begin
    TypeMethodName := EvtInfo.PropType^.Name;
    if SameText(string(TypeMethodName), 'TNotifyEvent') then
      SetMethodProp(FInvoker, FEventName, TMethod(FOnExecute));
  end;
end;

constructor TCommandInvoker.Create(AOwner: TCommand; AInvoker: TComponent;
  const AEventName: string);
begin
  inherited Create(AOwner);
  FOnExecute := ExecuteHandler;
  FInvoker := AInvoker;
  FEventName := AEventName;
  FInvoker.FreeNotification(Self);
  SetInvokerStatus(AOwner.FStatus);
  BindEvent;
end;

destructor TCommandInvoker.Destroy;
begin
  UnbindEvent;
  inherited;
end;

procedure TCommandInvoker.ExecuteHandler(Sender: TObject);
begin
  TCommand(Owner).Execute;
end;

procedure TCommandInvoker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FInvoker) then
    Free;
end;

procedure TCommandInvoker.SetInvokerCaption(const ACaption: string);
begin
  if (ACaption <> '') and IsPublishedProp(FInvoker, 'Caption') then
      SetPropValue(FInvoker, 'Caption', ACaption);
end;

procedure TCommandInvoker.SetInvokerShortCuts(const AValues: TStrings);
var
  ShortCutFirst: string;
  I: integer;
  obj: TObject;
begin
  if AValues.Count > 0 then
    ShortCutFirst := AValues[0]
  else
    ShortCutFirst := '';

  if IsPublishedProp(FInvoker, 'ShortCut') then
      SetPropValue(FInvoker, 'ShortCut', TextToShortCut(ShortCutFirst));
                                                        
  if (AValues.Count > 1) and IsPublishedProp(FInvoker, 'SecondaryShortCuts') then
  begin
    obj := GetObjectProp(FInvoker, 'SecondaryShortCuts');
    for I := 1 to AValues.Count - 1 do
      TShortCutList(obj).Add(AValues[I]); //use only Add method
  end
end;

procedure TCommandInvoker.SetInvokerStatus(AStatus: TCommandStatus);
  procedure SetPropVal(const APropName: string; AValue: boolean);
  begin
    if IsPublishedProp(FInvoker, APropName) then
      SetPropValue(FInvoker, APropName, AValue);
  end;
begin
  case AStatus of

    csEnabled: begin
      SetPropVal('Enabled', True);
      SetPropVal('Visible', True);
    end;

    csDisabled: begin
      SetPropVal('Enabled', False);
      SetPropVal('Visible', True);
    end;

    csUnavailable: begin
      SetPropVal('Enabled', False);
      SetPropVal('Visible', False);
    end;

  end;
end;

procedure TCommandInvoker.UnbindEvent;
const
  NilMethod: TMethod = (Code: nil; Data: nil);
var
  _Method: TMethod;
begin
  _Method := GetMethodProp(FInvoker, FEventName);
  if _Method.Code = TMethod(FOnExecute).Code then
    SetMethodProp(FInvoker, FEventName, NilMethod);
end;

{ TConditionList }

procedure TConditionList.Add(ACondition: TCommandConditionMethod);
var
  Idx: integer;
begin
  Idx := Find(ACondition);
  if Idx = -1 then
  begin
    Idx := FList.Add(TConditionHandler.Create);
    TConditionHandler(FList[Idx]).Condition := ACondition;
  end;
end;

function TConditionList.Count: integer;
begin
  Result := FList.Count;
end;

constructor TConditionList.Create;
begin
  FList := TObjectList.Create(true);
end;

destructor TConditionList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TConditionList.Find(ACondition: TCommandConditionMethod): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if @TConditionHandler(FList[Result]).Condition = @ACondition then Exit;
  Result := -1;
end;

function TConditionList.GetItem(AIndex: integer): TCommandConditionMethod;
begin
  Result := TCommandConditionMethod(TConditionHandler(FList[AIndex]).Condition);
end;

procedure TConditionList.Remove(ACondition: TCommandConditionMethod);
var
  Idx: integer;
begin
  Idx := Find(ACondition);
  if Idx <> -1 then
    FList.Delete(Idx);
end;

end.
