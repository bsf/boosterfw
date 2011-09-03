unit ItemsList;

interface
uses SysUtils, Classes, ManagedList, CoreClasses, ComObj;

type
  TItem = class(TManagedItem)
  private
    FObj: TObject;
  public
    destructor Destroy; override;
  end;

  TItems = class(TManagedItemList, IItems)
  protected
    procedure Add(const AID: string; AObj: TObject); overload;
    function Add(AObj: TObject): string; overload;
    procedure Remove(AObj: TObject);
    procedure Delete(const AID: string); overload;
    procedure Clear(AClass: TClass);
    function Get(const AID: string; AClass: TClass): TObject;
  end;

implementation

{ TItems }

procedure TItems.Add(const AID: string; AObj: TObject);
var
  item: TItem;
begin
  item := TItem(GetByID(AID));
  if item <> nil then
  begin
    if Assigned(Item.FObj) then Item.FObj.Free;
    Item.FObj := AObj;
    //raise EDuplicateItemIDError.Create('Duplicate item ID: ' + AID);
  end
  else
  begin
    item := TItem.Create(Self, AID);
    item.FObj := AObj;
    InternalAdd(item);
  end;
end;

function TItems.Add(AObj: TObject): string;
begin
  Result := CreateClassID;
  Add(Result, AObj);
end;

procedure TItems.Clear(AClass: TClass);
var
  idx: integer;
begin
  for idx := Count - 1 downto 0 do
    if TItem(inherited Get(idx)).FObj is AClass then
      inherited Delete(idx);
end;

procedure TItems.Delete(const AID: string);
var
  item: TItem;
begin
  item := TItem(GetByID(AID));
  if item <> nil then
    inherited Remove(item);
end;

function TItems.Get(const AID: string; AClass: TClass): TObject;
var
  I: integer;
  item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    item := TItem(inherited Get(I));
    if SameText(item.ID, AID) and (item.FObj is AClass) then
    begin
       Result := item.FObj;
       Exit;
    end;
  end;
end;

procedure TItems.Remove(AObj: TObject);
var
  idx: integer;
begin
  for idx := 0 to Count - 1 do
    if TItem(inherited Get(idx)).FObj = AObj then
    begin
      inherited Delete(idx);
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
