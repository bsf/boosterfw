unit ManagedList;

interface

uses Classes, Contnrs, sysutils, ComObj;

type
{ICollection}
  ICollectionItem = interface
  ['{1AF595BD-3E80-4689-A5C7-F826F224E6C3}']
    function GetID: string;
    function GetInfo: string;
    property ID: string read GetID;
  end;

  ICollection = interface
  ['{F9623FA3-87A3-4A96-BA03-6A4B623AD84E}']
    function GetItem(Index: integer): ICollectionItem;
    function Count: integer;
  end;

{TManageItem}
  TManagedListSearchMode = (lsmNone, lsmUp, lsmLocal);

  TManagedItem = class;

  TManagedItemList = class(TComponent, ICollection)
  private
    FSearchMode: TManagedListSearchMode;
    FParentList: TManagedItemList;
    FItems: TComponentList;
  protected
    function GetByID(const ID: string;
      ASearchMode: TManagedListSearchMode = lsmNone): TManagedItem;
    function InternalAdd(AItem: TManagedItem): integer;
    //ICollection
    function GetItem(Index: integer): ICollectionItem;
    function Count: integer;
  public
    constructor Create(AOwner: TComponent; ASearchMode: TManagedListSearchMode;
      AParentList: TManagedItemList); reintroduce; virtual;
    destructor Destroy; override;
    function Get(Index: integer): TManagedItem;
    procedure Delete(Index: integer);
    procedure Remove(AItem: TManagedItem);
    procedure Clear;
    property SearchMode: TManagedListSearchMode read FSearchMode;
  end;

  TManagedItem = class(TComponent, ICollectionItem)
  private
    FID: string;
    procedure SetID(const Value: string);
    function GetID: string;
  public
    constructor Create(AOwner: TManagedItemList; const AID: string); reintroduce; virtual;
    destructor Destroy; override;
    function GetInfo: string; virtual;
    property ID: string read GetID write SetID;
  end;

implementation

{ TManagedItem }

constructor TManagedItem.Create(AOwner: TManagedItemList; const AID: string);
begin
  inherited Create(AOwner);
  FID := AID;
end;

destructor TManagedItem.Destroy;
begin

  inherited;
end;

function TManagedItem.GetID: string;
begin
  if FID = '' then
    FID := CreateClassID;
  Result := FID;
end;

function TManagedItem.GetInfo: string;
begin

end;

procedure TManagedItem.SetID(const Value: string);
begin
  FID := Value;
end;

{ TManagedItemList }

procedure TManagedItemList.Clear;
begin
  FItems.Clear;
end;

function TManagedItemList.Count: integer;
begin
  Result := FItems.Count;
end;

constructor TManagedItemList.Create(AOwner: TComponent;
  ASearchMode: TManagedListSearchMode; AParentList: TManagedItemList);
begin
  inherited Create(AOwner);
  FItems := TComponentList.Create(True);
  FSearchMode := ASearchMode;
  FParentList := AParentList;
end;

destructor TManagedItemList.Destroy;
begin
  FItems.Free;
  inherited;
end;


function TManagedItemList.GetByID(const ID: string;
  ASearchMode: TManagedListSearchMode = lsmNone): TManagedItem;
var
  I: integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if SameText(TManagedItem(FItems[I]).ID, ID) then
    begin
       Result := TManagedItem(FItems[I]);
       Exit;
    end;

  if (FSearchMode = lsmUp) and (FParentList <> nil) then
    Result := FParentList.GetByID(ID);
end;

function TManagedItemList.InternalAdd(AItem: TManagedItem): integer;
begin
  Result := FItems.Add(AItem);
end;


function TManagedItemList.Get(Index: integer): TManagedItem;
begin
  Result := TManagedItem(FItems[Index]);
end;

procedure TManagedItemList.Delete(Index: integer);
begin
  FItems.Delete(Index);
end;

procedure TManagedItemList.Remove(AItem: TManagedItem);
begin
  FItems.Remove(AItem);
end;

function TManagedItemList.GetItem(Index: integer): ICollectionItem;
begin
  Result := TManagedItem(FItems[Index]);  
end;

end.


