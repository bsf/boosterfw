unit Activities;

interface
uses classes, CoreClasses, graphics, sysutils, variants, menus, strUtils,
  Generics.Collections, Contnrs;

type
  TActivityData = class(TComponent, IActivityData)
  private
    FNames: TStringList;
    FValues: array of variant;
    procedure ResetValues;
    function FindOrAdd(const AName: string): integer;
  public
    //IActivityData

    function Count: integer;
    function ValueName(AIndex: integer): string;
    function IndexOf(const AName: string): integer;
    procedure Assign(Source: TWorkItem; ABindingRule: string = ''); reintroduce;
    procedure AssignTo(Target: TWorkItem); reintroduce;
    procedure SetValue(const AName: string; AValue: Variant);
    function GetValue(const AName: string): Variant;
    //
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TActivity = class(TComponent, IActivity)
  private
    FURI: string;
    FActivityClass: string;
    FTitle: string;
    FGroup: string;
    FMenuIndex: integer;
    FShortCut: string;
    FShortCutI: TShortCut;
    FImage: Graphics.TBitmap;
    FUsePermission: boolean;
    FOptions: TStringList;
    FParams: TActivityData;
    FOuts: TActivityData;
    FCallMode: TActivityCallMode;
  protected
    //IActivity
    function URI: string;

    procedure SetActivityClass(const Value: string);
    function GetActivityClass: string;

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
    function HavePermission: boolean;

    function Options: TStrings;
    function OptionExists(const AName: string): boolean;
    function OptionValue(const AName: string): string;

    function Params: IActivityData;
    function Outs: IActivityData;

    function GetCallMode: TActivityCallMode;
    procedure SetCallMode(AValue: TActivityCallMode);

    procedure RegisterHandler(AHandler: TActivityHandler);

    procedure Execute(Sender: TWorkItem);
  public
    constructor Create(AOwner: TComponent; const AURI: string); reintroduce;
    destructor Destroy; override;
  end;


  TActivities = class(TComponent, IActivities)
  private
    FPermissionHandler: IActivityPermissionHandler;
    FHandlers: TObjectDictionary<string, TActivityHandler>;
    FItems: TComponentList;
  protected
    procedure ExecuteActivity(Sender: TWorkItem; Activity: TActivity);
    function CheckPermission(Activity: TActivity): boolean;
    //IActivities
    procedure RegisterHandler(const ActivityClass: string; AHandler: TActivityHandler);
    procedure RegisterPermissionHandler(AHandler: IActivityPermissionHandler);
    function Count: integer;
    function GetItem(AIndex: integer): IActivity;
    function IndexOf(const URI: string): integer;
    procedure Remove(const URI: string);
    function FindOrCreate(const URI: string): IActivity;
    function IsShortCut(AWorkItem: TWorkItem; AShortCut: TShortCut): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{ TActivities }


function TActivities.CheckPermission(Activity: TActivity): boolean;
begin
  Result := true;
  if Activity.FUsePermission and Assigned(FPermissionHandler) then
    Result := FPermissionHandler.CheckPermission(Activity);
end;

function TActivities.Count: integer;
begin
  Result := FItems.Count;
end;

constructor TActivities.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TComponentList.Create(true);
  FHandlers := TObjectDictionary<string, TActivityHandler>.Create([doOwnsValues]);
end;

destructor TActivities.Destroy;
begin
  FItems.Free;
  FHandlers.Free;
  inherited;
end;

procedure TActivities.ExecuteActivity(Sender: TWorkItem; Activity: TActivity);
var
  handler: TActivityHandler;
begin
  FHandlers.TryGetValue(Activity.GetActivityClass, handler);
  if handler <> nil then
  begin
    if Activity.FUsePermission and Assigned(FPermissionHandler) then
      FPermissionHandler.DemandPermission(Activity);

    handler.Execute(Sender, Activity);
  end;
end;

function TActivities.FindOrCreate(const URI: string): IActivity;
var
  idx: integer;
begin
  idx := IndexOf(URI);
  if idx = -1 then
    idx := FItems.Add(TActivity.Create(Self, URI));

  Result := GetItem(idx);
end;

function TActivities.GetItem(AIndex: integer): IActivity;
begin
  Result := FItems.Items[AIndex] as IActivity;
end;

function TActivities.IndexOf(const URI: string): integer;
var
  I: integer;
begin
  Result := -1;
  for I := 0 to FItems.Count - 1 do
    if SameText(URI, (FItems[I] as TActivity).URI) then
      Exit(I);
end;

function TActivities.IsShortCut(AWorkItem: TWorkItem; AShortCut: TShortCut): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AShortCut = scNone then Exit;

  for I := 0 to FItems.Count - 1 do
    if (FItems.Items[I] as TActivity).FShortCutI = AShortCut then
    begin
       Result := true;
       (FItems.Items[I] as TActivity).Execute(AWorkItem);
       Exit;
    end;

end;

procedure TActivities.RegisterHandler(const ActivityClass: string;
  AHandler: TActivityHandler);
begin
  FHandlers.AddOrSetValue(ActivityClass, AHandler);
end;

procedure TActivities.RegisterPermissionHandler(
  AHandler: IActivityPermissionHandler);
begin
  FPermissionHandler := AHandler;
end;

procedure TActivities.Remove(const URI: string);
var
  idx: integer;
begin
  idx := IndexOf(URI);
  if idx <> -1 then
    FItems.Delete(idx);
end;

{ TActivityInfo }

constructor TActivity.Create(AOwner: TComponent; const AURI: string);
begin
  inherited Create(AOwner);
  FURI := AURI;
  FOptions := TStringList.Create;
  FParams := TActivityData.Create(Self);
  FOuts := TActivityData.Create(Self);
  FImage := TBitmap.Create;
end;

destructor TActivity.Destroy;
begin
  FOptions.Free;
  FParams.Free;
  FOuts.Free;
  FImage.Free;
  inherited;
end;

procedure TActivity.Execute(Sender: TWorkItem);
begin
  FOuts.ResetValues;
  try

    (Owner as TActivities).ExecuteActivity(Sender, Self);

  finally
    FParams.ResetValues;
    FCallMode := acmSingle;
  end;
end;

function TActivity.GetActivityClass: string;
begin
  Result := FActivityClass;
  if Result = '' then
    Result := FURI;
end;

function TActivity.GetCallMode: TActivityCallMode;
begin
  Result := FCallMode;
end;

function TActivity.GetGroup: string;
begin
  Result := FGroup;
end;

function TActivity.GetImage: Graphics.TBitmap;
begin
  Result := FImage;
end;

function TActivity.GetMenuIndex: integer;
begin
  Result := FMenuIndex;
end;

function TActivity.GetShortCut: string;
begin
  Result := FShortCut;
end;

function TActivity.GetTitle: string;
begin
  Result := FTitle;
end;

function TActivity.GetUsePermission: boolean;
begin
  Result := FUsePermission;
end;

function TActivity.HavePermission: boolean;
begin
  Result := (Owner as TActivities).CheckPermission(Self);
end;

function TActivity.OptionExists(const AName: string): boolean;
begin
  Result := (FOptions.IndexOfName(AName) <> -1) or (FOptions.IndexOf(AName) <> -1);
end;

function TActivity.Options: TStrings;
begin
  Result := FOptions;
end;

function TActivity.OptionValue(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

function TActivity.Outs: IActivityData;
begin
  Result := FOuts;
end;

function TActivity.Params: IActivityData;
begin
  Result := FParams;
end;

procedure TActivity.RegisterHandler(AHandler: TActivityHandler);
begin
  (Owner as TActivities).RegisterHandler(FURI, AHandler);
end;

procedure TActivity.SetActivityClass(const Value: string);
begin
  FActivityClass := Value;
end;

procedure TActivity.SetCallMode(AValue: TActivityCallMode);
begin
  FCallMode := AValue;
end;

procedure TActivity.SetGroup(const Value: string);
begin
  FGroup := Value;
end;

procedure TActivity.SetImage(Value: Graphics.TBitmap);
begin
  FImage.Assign(Value);
end;

procedure TActivity.SetMenuIndex(Value: integer);
begin
  FMenuIndex := Value;
end;

procedure TActivity.SetShortCut(const Value: string);
begin
  FShortCut := Value;
  FShortCutI := TextToShortCut(FShortCut);
end;

procedure TActivity.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TActivity.SetUsePermission(Value: boolean);
begin
  FUsePermission := Value;
end;

function TActivity.URI: string;
begin
  Result := FURI;
end;

{ TActivityData }

function TActivityData.ValueName(AIndex: integer): string;
begin

  Result := FNames[AIndex];
end;

procedure TActivityData.Assign(Source: TWorkItem; ABindingRule: string);

  function DecodeSourceValue(const AName: string): variant;
  var
    val: string;
  begin
    if StartsText('[', AName) and EndsText(']', AName) then
    begin
      val := AName;
      Delete(val, 1, 1);
      Delete(val, Length(val), 1);
      Result := val;
    end
    else
      Result := Source.State[AName];
  end;

var
  I: integer;
  bindingList: TStringList;
begin
  ResetValues;

  if ABindingRule <> '' then
  begin
    bindingList := TStringList.Create;
    try
      ExtractStrings([';'], [], PWideChar(ABindingRule), bindingList);
      for I := 0 to bindingList.Count - 1 do
        SetValue(bindingList.Names[I], DecodeSourceValue(bindingList.Values[bindingList.Names[I]]));
    finally
      bindingList.Free;
    end;
  end
  else
    for I := 0 to FNames.Count - 1 do
      SetValue(FNames[I], Source.State[FNames[I]]);

end;

procedure TActivityData.AssignTo(Target: TWorkItem);
var
  I: integer;
begin
  for I := 0 to FNames.Count - 1 do
    Target.State[FNames[I]] := GetValue(FNames[I]);
end;

function TActivityData.Count: integer;
begin
  Result := FNames.Count;
end;

constructor TActivityData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNames := TStringList.Create;
end;

destructor TActivityData.Destroy;
begin
  FNames.Free;
  inherited;
end;

function TActivityData.FindOrAdd(const AName: string): integer;
begin
  Result := FNames.IndexOf(AName);
  if Result = -1 then
  begin
    Result := FNames.Add(AName);
    SetLength(FValues, Result + 1);
  end;
end;

function TActivityData.GetValue(const AName: string): Variant;
begin
  Result := FValues[FindOrAdd(AName)];
end;

function TActivityData.IndexOf(const AName: string): integer;
begin
  Result := FNames.IndexOf(AName);
end;


procedure TActivityData.ResetValues;
var
  I: integer;
begin
  for I := 0 to High(FValues) do
    FValues[I] := Unassigned;
end;

procedure TActivityData.SetValue(const AName: string; AValue: Variant);
begin
  FValues[FindOrAdd(AName)] := AValue;
end;

end.
