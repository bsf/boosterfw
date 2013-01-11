unit HashList;

interface
uses classes, sysutils, Generics.Collections, typInfo;

type

  THashList<T: class> = class(TObject)
  private

    type
      TItem = class(TObject)
      private
        FOwnsObject: boolean;
        FVal: T;
        FKey: string;
      public
        constructor Create(const AKey: string; const AVal: T; AOwnsObject: boolean);
        destructor Destroy; override;
        property Obj: T read FVal;
        property Key: string read FKey;
      end;

  private
    FOwnsObjects: boolean;
    FItems: TObjectList<TItem>;
    function GetItem(AIndex: integer): T;
    function GetValue(const Key: string): T;

  public
    constructor Create(AOwnsObjects: boolean = true);
    destructor Destroy; override;

    function Count: integer;
    procedure Clear;
    function Add(const Key: string; const Value: T): integer;
    procedure Delete(AIndex: integer); overload;
    procedure Delete(const Key: string); overload;

    function IndexOf(const Key: string): integer;

    property Items[AIndex: integer]: T read GetItem;
    property Values[const Key: string]: T read GetValue; default;


    type
      TEnumerator = class(TEnumerator<T>)
      private
        FList: TObjectList<TItem>;
        FIndex: Integer;
        function GetCurrent: T;
      protected
        function DoGetCurrent: T; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(AList: TObjectList<TItem>);
        property Current: T read GetCurrent;
        function MoveNext: Boolean;
      end;

    function GetEnumerator: TEnumerator;
  end;



implementation

{ THashObjectList<T> }

function THashList<T>.Add(const Key: string; const Value: T): integer;
begin
  Result := FItems.Add(TItem.Create(Key, Value, FOwnsObjects));
end;

procedure THashList<T>.Clear;
begin
  FItems.Clear;
end;

function THashList<T>.Count: integer;
begin
  Result := FItems.Count;
end;

constructor THashList<T>.Create(AOwnsObjects: boolean);
begin
  FItems := TObjectList<TItem>.Create(true);
  FOwnsObjects := AOwnsObjects;
end;

procedure THashList<T>.Delete(AIndex: integer);
begin
  FItems.Delete(AIndex);
end;

procedure THashList<T>.Delete(const Key: string);
var
  idx: integer;
begin
  idx := IndexOf(Key);
  if idx = -1 then
    raise Exception.CreateFmt('Value by key %s not found', [Key]);

  FItems.Delete(idx);
end;

destructor THashList<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function THashList<T>.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FItems);
end;

function THashList<T>.GetItem(AIndex: integer): T;
begin
  Result := FItems[AIndex].Obj;
end;


function THashList<T>.GetValue(const Key: string): T;
var
  idx: integer;
begin
  idx := IndexOf(Key);
  if idx = -1 then
    raise Exception.CreateFmt('Value by key %s not found', [Key]);

  Result := FItems[idx].Obj;
end;


function THashList<T>.IndexOf(const Key: string): integer;
var
  I: integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Result := I;
    if SameText(FItems[I].Key, Key) then Exit;
  end;
  Result := -1;
end;

{ THashObjectList<T>.TEnumerator }

constructor THashList<T>.TEnumerator.Create(AList: TObjectList<TItem>);
begin
  inherited Create;
  FList := AList;
  FIndex := -1;
end;

function THashList<T>.TEnumerator.DoGetCurrent: T;
begin
  Result := GetCurrent;
end;

function THashList<T>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function THashList<T>.TEnumerator.GetCurrent: T;
begin
  Result := FList[FIndex].Obj;
end;

function THashList<T>.TEnumerator.MoveNext: Boolean;
begin
  if FIndex >= FList.Count then
    Exit(False);
  Inc(FIndex);
  Result := FIndex < FList.Count;
end;

{ THashObjectList<T>.TItem }

constructor THashList<T>.TItem.Create(const AKey: string;
  const AVal: T; AOwnsObject: boolean);
begin
  FKey := AKey;
  FVal := AVal;
  FOwnsObject := AOwnsObject;
end;

destructor THashList<T>.TItem.Destroy;
begin
  if FOwnsObject then
    FVal.Free;
  inherited;
end;

end.
