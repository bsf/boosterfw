unit WorkspacesList;

interface
uses SysUtils, Classes, ManagedList, CoreClasses, Contnrs, Typinfo;

type

  TWorkspaceItem = class(TManagedItem)
  private
    FWorkspace: TComponent;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TManagedItemList; const AID: string;
      AWorkspace: TComponent); reintroduce;
    destructor Destroy; override;
  end;

  TWorkspaces = class(TManagedItemList, IWorkspaces)
  private
    function GetWorkspace(const AName: string): IWorkspace;
  public
    procedure RegisterWorkspace(const AName: string; AWorkspace: TComponent);
    procedure UnregisterWorkspace(const AName: string);
    property Workspace[const AName: string]: IWorkspace read GetWorkspace; default;
  end;


implementation

{ TWorkspaces }

function TWorkspaces.GetWorkspace(const AName: string): IWorkspace;
var
  item: TWorkspaceItem;
begin
  item := TWorkspaceItem(GetByID(AName));

  if item = nil then
    raise EWorkspaceMissingError.Create('Workspace ' + AName + ' not found.');

  if not item.FWorkspace.GetInterface(IWorkspace, Result) then
    raise EInterfaceMissingError.Create('Interface ' + GUIDToString(IWorkspace) + ' not found.');
end;

procedure TWorkspaces.RegisterWorkspace(const AName: string;
  AWorkspace: TComponent);
begin
  InternalAdd(TWorkspaceItem.Create(Self, AName, AWorkspace));
end;

procedure TWorkspaces.UnregisterWorkspace(const AName: string);
var
  Item: TWorkspaceItem;
begin
  Item := TWorkspaceItem(GetByID(AName));
  if Assigned(Item) then
    Item.Free;
end;

{ TWorkspaceItem }

constructor TWorkspaceItem.Create(AOwner: TManagedItemList; const AID: string;
  AWorkspace: TComponent);
begin
  inherited Create(AOwner, AID);
  FWorkspace := AWorkspace;
  FWorkspace.FreeNotification(Self);
end;

destructor TWorkspaceItem.Destroy;
begin

  inherited;
end;

procedure TWorkspaceItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FWorkspace) then
    Free;
end;

end.
