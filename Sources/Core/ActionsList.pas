unit ActionsList;

interface
uses SysUtils, Classes, ManagedList, CoreClasses, Contnrs, Variants, TypInfo;

type
  TDataBindType = (tkInteger, tkChar, tkFloat, tkString, tkWChar, tkLString, tkWString,
          tkVariant, tkInt64);

  TDataBindTypes = set of TDataBindType;

  TConditionHandler = class(TObject)
    Condition: TActionConditionMethod;
  end;

  TConditionList = class(TObject)
  private
    FList: TObjectList;
    function Find(ACondition: TActionConditionMethod): integer;
  public
    function Count: integer;
    procedure Add(ACondition: TActionConditionMethod);
    procedure Remove(ACondition: TActionConditionMethod);
    function GetItem(AIndex: integer): TActionConditionMethod;
    constructor Create;
    destructor Destroy; override;
  end;

  TAction = class(TManagedItem, IAction)
  private
    FCaller: TWorkItem;
    FDataClass: TActionDataClass;
    FData: TActionData;
    FVetoObject: Exception;
    FConditions: TConditionList;
    FHandler: TActionHandlerMethod;
    function GetActionName: string;
    function InternalCanExecute: boolean;
  protected
    //IAction
    function IAction.Name = GetActionName;
    procedure Execute(Caller: TWorkItem);
    function CanExecute(Caller: TWorkItem): boolean;
    function VetoObject: Exception;
    procedure SetHandler(AHandler: TActionHandlerMethod);
    procedure SetDataClass(AClass: TActionDataClass);
    function GetData: TActionData;
    procedure ResetData;
    procedure RegisterCondition(ACondition: TActionConditionMethod);
    procedure RemoveCondition(ACondition: TActionConditionMethod);
    function GetCaller: TWorkItem;
  public
    constructor Create(AOwner: TManagedItemList; const AID: string); override;
    destructor Destroy; override;
  end;

  TActions = class(TManagedItemList, IActions)
  private
    FConditions: TConditionList;
  protected
    function CanExecute(Sender: TAction): boolean;
    //IActions
    procedure RegisterCondition(ACondition: TActionConditionMethod);
    procedure RemoveCondition(ACondition: TActionConditionMethod);
    function GetAction(const AName: string): IAction;
  public
    constructor Create(AOwner: TComponent; ASearchMode: TManagedListSearchMode;
      AParentList: TManagedItemList); override;
    destructor Destroy; override;

    property Action[const AName: string]: IAction read GetAction; default;
  end;

implementation

{ TAction }

function TAction.CanExecute(Caller: TWorkItem): boolean;
begin
  FCaller := Caller;

  if not Assigned(FCaller) then
    raise Exception.CreateFmt('Context WorkItem for %s not setting', [GetActionName]);

  if Assigned(FVetoObject) then
    FVetoObject.Free;
  try
    Result := InternalCanExecute;
  except
    FVetoObject := AcquireExceptionObject;
    Result := false;
  end;

end;

constructor TAction.Create(AOwner: TManagedItemList; const AID: string);
begin
  inherited Create(AOwner, AID);
  FConditions := TConditionList.Create;
end;

destructor TAction.Destroy;
begin
  FConditions.Free;
  if Assigned(FVetoObject) then
    FVetoObject.Free;

  inherited;
end;

procedure TAction.Execute(Caller: TWorkItem);
var
  intf: IAction;
begin
  FCaller := Caller;

  if not Assigned(FCaller) then
    raise Exception.CreateFmt('Context WorkItem for %s not setting', [GetActionName]);

  if not Assigned(FHandler) then Exit;

  Self.GetInterface(IAction, intf);

  if InternalCanExecute then FHandler(intf);

  GetData.ResetValues;
  
  intf := nil;
end;

function TAction.GetActionName: string;
begin
  Result := ID;
end;

function TAction.GetCaller: TWorkItem;
begin
  Result := FCaller;
end;


function TAction.InternalCanExecute: boolean;
var
  I: integer;
begin
  Result := TActions(Owner).CanExecute(Self);
  if not Result then Exit;

  for I := 0 to FConditions.Count -  1 do
  begin
    Result := FConditions.GetItem(I)(Self);
    if not Result then Exit;
  end;

  Result := true;
end;

procedure TAction.RegisterCondition(ACondition: TActionConditionMethod);
begin
  FConditions.Add(ACondition);
end;

procedure TAction.RemoveCondition(ACondition: TActionConditionMethod);
begin
  FConditions.Remove(ACondition);
end;

procedure TAction.SetHandler(AHandler: TActionHandlerMethod);
begin
  FHandler := AHandler;
end;

function TAction.VetoObject: Exception;
begin
  Result := FVetoObject;
end;

function TAction.GetData: TActionData;
begin
  if not Assigned(FDataClass) then
    FDataClass := TActionData;

  if not Assigned(FData) then
    FData := FDataClass.Create(GetActionName);

  Result := FData;
end;

procedure TAction.SetDataClass(AClass: TActionDataClass);
begin
  FDataClass := AClass;
end;


procedure TAction.ResetData;
begin
  if not Assigned(FDataClass) then
    FDataClass := TActionData;

  if Assigned(FData) then
    FreeAndNil(FData);
end;

{ TActions }

function TActions.CanExecute(Sender: TAction): boolean;
var
  I: integer;
begin
  for I := 0 to FConditions.Count -  1 do
  begin
    Result := FConditions.GetItem(I)(Sender);
    if not Result then Exit;
  end;
  Result := true;
end;

constructor TActions.Create(AOwner: TComponent;
  ASearchMode: TManagedListSearchMode; AParentList: TManagedItemList);
begin
  inherited Create(AOwner, ASearchMode, AParentList);
  FConditions := TConditionList.Create;
end;

destructor TActions.Destroy;
begin
  FConditions.Free;
  inherited;
end;

function TActions.GetAction(const AName: string): IAction;
var
  Action: TAction;
begin
  Action := TAction(GetByID(AName));

  if Action = nil then
  begin
    Action := TAction.Create(Self, AName);
    InternalAdd(Action);
  end;

  Action.QueryInterface(IAction, Result);

end;

procedure TActions.RegisterCondition(ACondition: TActionConditionMethod);
begin
  FConditions.Add(ACondition);
end;

procedure TActions.RemoveCondition(ACondition: TActionConditionMethod);
begin
  FConditions.Remove(ACondition);
end;

{ TConditionList }

procedure TConditionList.Add(ACondition: TActionConditionMethod);
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

function TConditionList.Find(ACondition: TActionConditionMethod): integer;
begin
  for Result := 0 to FList.Count - 1 do
    if @TConditionHandler(FList[Result]).Condition = @ACondition then Exit;
  Result := -1;
end;

function TConditionList.GetItem(AIndex: integer): TActionConditionMethod;
begin
  Result := TActionConditionMethod(TConditionHandler(FList[AIndex]).Condition);
end;

procedure TConditionList.Remove(ACondition: TActionConditionMethod);
var
  Idx: integer;
begin
  Idx := Find(ACondition);
  if Idx <> -1 then
    FList.Delete(Idx);
end;

end.
