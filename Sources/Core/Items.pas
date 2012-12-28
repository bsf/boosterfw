unit Items;

interface
uses SysUtils, Classes, ManagedList, CoreClasses, ComObj, Generics.Collections;

type
  TItem = class(TObject)
  private
    FObj: TObject;
  public
    destructor Destroy; override;
  end;

  TItems = class(TComponent, IItems)
  private
    FItems: TObjectDictionary<string, TItem>;
  protected
    procedure Add(const AID: string; AObj: TObject); overload;
    function Add(AObj: TObject): string; overload;
    procedure Remove(AObj: TObject);
    procedure Delete(const AID: string); overload;
    function Get(const AID: string; AClass: TClass): TObject;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; overload;
  end;

implementation

{ TItems }

procedure TItems.Add(const AID: string; AObj: TObject);
var
  item: TItem;
begin
  if FItems.TryGetValue(AID, item) then
  begin
    if Assigned(item.FObj) then item.FObj.Free;
    item.FObj := AObj;
  end
  else
  begin
    item := TItem.Create;
    item.FObj := AObj;
    FItems.Add(AID, item);
  end;
end;

function TItems.Add(AObj: TObject): string;
begin
  Result := CreateClassID;
  Add(Result, AObj);
end;

procedure TItems.Clear;
begin
  FItems.Clear;
end;

constructor TItems.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TObjectDictionary<string, TItem>.Create([doOwnsValues]);
end;

procedure TItems.Delete(const AID: string);
begin
  FItems.Remove(AID);
end;

destructor TItems.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TItems.Get(const AID: string; AClass: TClass): TObject;
var
  key: string;
begin
  Result := nil;
  for key in FItems.Keys do
    if SameText(key, AID) and (FItems[key].FObj is AClass) then
    begin
      Result := FItems[key].FObj;
      Exit;
    end;
end;

procedure TItems.Remove(AObj: TObject);
var
  key: string;
begin
  for key in FItems.Keys do
    if FItems[key].FObj = AObj then
    begin
      FItems.Remove(key);
      Exit;
    end;
end;

{ TItem }

destructor TItem.Destroy;
begin
  if Assigned(FObj) then FObj.Free;
  inherited;
end;

end.
