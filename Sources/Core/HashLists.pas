unit HashLists;

interface
uses classes, Generics.Collections;

type
  THashObjectList<T: class> = class(TComponent)
  private

    type
      TItem = class(TObject)
      private
        FObj: T;
        FKey: string;
      public
        constructor Create(const AKey: string; const AObj: T);
        destructor Destroy; override;
        property Obj: T read FObj;
        property Key: string read FKey;
      end;

  private
    FItems: TObjectList<TItem>;

    function GetItem(AIndex: integer): T;
    function GetValue(const Key: string): T;
    function KeyByIndex(AIndex: integer): string;
    function IndexByKey(const Key: string): integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Count: integer;
    procedure Clear;
    function Add(const Key: string; const Value: T): integer;
    procedure Delete(AIndex: integer); overload;
    procedure Delete(const Key: string); overload;

    function IndexOf(const Key: string): integer; overload;

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

function THashObjectList<T>.Add(const Key: string; const Value: T): integer;
begin
  Result := FItems.Add(TItem.Create(Key, Value));
end;

procedure THashObjectList<T>.Clear;
begin
  FItems.Clear;
end;

function THashObjectList<T>.Count: integer;
begin
  Result := FItems.Count;
end;

constructor THashObjectList<T>.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TObjectList<TItem>.Create(true);
end;

procedure THashObjectList<T>.Delete(AIndex: integer);
begin
  FItems.Delete(AIndex);
end;

procedure THashObjectList<T>.Delete(const Key: string);
begin
  FItems.Delete(IndexByKey(Key));
end;

destructor THashObjectList<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function THashObjectList<T>.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FItems);
end;

function THashObjectList<T>.GetItem(AIndex: integer): T;
begin
  Result := FItems[AIndex].Obj;
end;


function THashObjectList<T>.GetValue(const Key: string): T;
begin
  Result := FItems[IndexByKey(Key)].Obj;
end;

function THashObjectList<T>.IndexByKey(const Key: string): integer;
var
  I: integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Result := I;
    if FItems[I].Key = Key then Exit;
  end;
  Result := -1;
end;


function THashObjectList<T>.KeyByIndex(AIndex: integer): string;
begin
  Result := FItems[AIndex].Key;
end;

function THashObjectList<T>.IndexOf(const Key: string): integer;
begin
  Result := IndexByKey(Key);
end;

{ THashObjectList<T>.TEnumerator }

constructor THashObjectList<T>.TEnumerator.Create(AList: TObjectList<TItem>);
begin
  inherited Create;
  FList := AList;
  FIndex := -1;
end;

function THashObjectList<T>.TEnumerator.DoGetCurrent: T;
begin
  Result := GetCurrent;
end;

function THashObjectList<T>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function THashObjectList<T>.TEnumerator.GetCurrent: T;
begin
  Result := FList[FIndex].Obj;
end;

function THashObjectList<T>.TEnumerator.MoveNext: Boolean;
begin
  if FIndex >= FList.Count then
    Exit(False);
  Inc(FIndex);
  Result := FIndex < FList.Count;
end;

{ THashObjectList<T>.TItem }

constructor THashObjectList<T>.TItem.Create(const AKey: string;
  const AObj: T);
begin
  FKey := AKey;
  FObj := AObj;
end;

destructor THashObjectList<T>.TItem.Destroy;
begin
  FObj.Free;
  inherited;
end;

end.
