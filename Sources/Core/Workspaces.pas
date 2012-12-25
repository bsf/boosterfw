unit Workspaces;

interface
uses SysUtils, Classes, CoreClasses, Generics.Collections;

type

  TWorkspaceItem = class(TComponent)
  private
    FWorkspace: TComponent;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(const AID: string;
      AWorkspace: TComponent); reintroduce;
    destructor Destroy; override;
  end;

  TWorkspaces = class(TComponent, IWorkspaces)
  private
    FItems: TObjectDictionary<string, TWorkspaceItem>;
    function GetWorkspace(const AName: string): IWorkspace;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RegisterWorkspace(const AName: string; AWorkspace: TComponent);
    procedure UnregisterWorkspace(const AName: string);
    property Workspace[const AName: string]: IWorkspace read GetWorkspace; default;
  end;


implementation

{ TWorkspaces }

constructor TWorkspaces.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TObjectDictionary<string, TWorkspaceItem>.Create([doOwnsValues]);
end;

destructor TWorkspaces.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TWorkspaces.GetWorkspace(const AName: string): IWorkspace;
var
  item: TWorkspaceItem;
begin
  if not FItems.TryGetValue(AName, item) then
    raise EWorkspaceMissingError.Create('Workspace ' + AName + ' not found.');

  Result := item.FWorkspace as IWorkspace;
end;

procedure TWorkspaces.RegisterWorkspace(const AName: string;
  AWorkspace: TComponent);
var
  chk: IWorkspace;
begin
  if not AWorkspace.GetInterface(IWorkspace, chk) then
    raise EInterfaceMissingError.Create('Interface ' + GUIDToString(IWorkspace) + ' not found.');

  FItems.Add(AName, TWorkspaceItem.Create(AName, AWorkspace));
end;

procedure TWorkspaces.UnregisterWorkspace(const AName: string);
var
  Item: TWorkspaceItem;
begin
  FItems.Remove(AName);
end;

{ TWorkspaceItem }

constructor TWorkspaceItem.Create(const AID: string;
  AWorkspace: TComponent);
begin
  inherited Create(nil);
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
