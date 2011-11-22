unit Activities;

interface
uses classes, CoreClasses, HashList, graphics, sysutils, variants;

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
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
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
    FImage: Graphics.TBitmap;
    FUsePermission: boolean;
    FOptions: TStringList;
    FParams: TActivityData;
    FOuts: TActivityData;
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

    procedure RegisterHandler(AHandler: TActivityHandler);

    procedure Execute(Sender: TWorkItem);
  public
    constructor Create(AOwner: TComponent; const AURI: string); reintroduce;
    destructor Destroy; override;
  end;


  TActivities = class(TComponent, IActivities)
  private
    FPermissionHandler: IActivityPermissionHandler;
    FHandlers: THashList<TActivityHandler>;
    FItems: THashList<TActivity>;
  protected
    procedure ExecuteActivity(Sender: TWorkItem; Activity: TActivity);
    function CheckPermission(Activity: TActivity): boolean;
    //IActivities
    procedure RegisterHandler(const ActivityClass: string; AHandler: TActivityHandler);
    procedure RegisterPermissionHandler(AHandler: IActivityPermissionHandler);
    function Count: integer;
    function GetItem(AIndex: integer): IActivity;
    function IndexOf(const URI: string): integer;
    function FindOrCreate(const URI: string): IActivity;
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
  FItems := THashList<TActivity>.Create;
  FHandlers := THashList<TActivityHandler>.Create;
end;

destructor TActivities.Destroy;
begin
  FItems.Free;
  FHandlers.Free;
  inherited;
end;

procedure TActivities.ExecuteActivity(Sender: TWorkItem; Activity: TActivity);
var
  idx: integer;
begin
  idx := FHandlers.IndexOf(Activity.GetActivityClass);
  if idx <> -1 then
  begin
    if Activity.FUsePermission and Assigned(FPermissionHandler) then
      FPermissionHandler.DemandPermission(Activity);

    FHandlers.Items[idx].Execute(Sender, Activity);
  end;
end;

function TActivities.FindOrCreate(const URI: string): IActivity;
var
  idx: integer;
begin
  idx := FItems.IndexOf(URI);
  if idx = -1 then
    idx := FItems.Add(URI, TActivity.Create(Self, URI));
  Result := FItems.Items[idx];
end;

function TActivities.GetItem(AIndex: integer): IActivity;
begin
  Result := FItems.Items[AIndex];
end;

function TActivities.IndexOf(const URI: string): integer;
begin
  Result := FItems.IndexOf(URI);
end;

procedure TActivities.RegisterHandler(const ActivityClass: string;
  AHandler: TActivityHandler);
begin
  FHandlers.Add(ActivityClass, AHandler);
end;

procedure TActivities.RegisterPermissionHandler(
  AHandler: IActivityPermissionHandler);
begin
  FPermissionHandler := AHandler;
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
  end;
end;

function TActivity.GetActivityClass: string;
begin
  Result := FActivityClass;
  if Result = '' then
    Result := FURI;
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

procedure TActivityData.Assign(Source: TPersistent);
var
  I: integer;
begin
  ResetValues;

  if Source is TWorkItem then
    for I := 0 to FNames.Count - 1 do
      SetValue(FNames[I], (Source as TWorkItem).State[FNames[I]]);

  if (Source is TActivityData) then
    for I := 0 to FNames.Count - 1 do
      if (Source as TActivityData).FNames.IndexOf(FNames[I]) <> -1 then
        SetValue(FNames[I], (Source as TActivityData).GetValue(FNames[I]));
end;

procedure TActivityData.AssignTo(Dest: TPersistent);
var
  I: integer;
begin
  if Dest is TWorkItem then
    for I := 0 to FNames.Count - 1 do
      (Dest as TWorkItem).State[FNames[I]] := GetValue(FNames[I]);

  if (Dest is TActivityData) then
    for I := 0 to FNames.Count - 1 do
      if (Dest as TActivityData).FNames.IndexOf(FNames[I]) <> -1 then
        (Dest as TActivityData).SetValue(FNames[I], GetValue(FNames[I]));

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
