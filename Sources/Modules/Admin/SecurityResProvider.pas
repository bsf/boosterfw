unit SecurityResProvider;

interface
uses SecurityIntf, CoreClasses, classes,  EntityServiceIntf,
  ShellIntf, db;

type
  TSecurityResNode = class(TInterfacedObject, ISecurityResNode)
  private
    FID: string;
    FName: string;
    FDescription: string;
  protected
    function ID: string;
    function Name: string;
    function Description: string;
  end;

  TActivitySecurityResProvider = class(TComponent, ISecurityResProvider)
  const
    SECURITY_RES_PROVIDER_ID = 'security.resprovider.app.activities';
  private
    FWorkItem: TWorkItem;
  protected
    function ID: string;
    function GetTopRes: IInterfaceList;
    function GetChildRes(const ParentResID: string): IInterfaceList;
    function GetRes(const ID: string): ISecurityResNode;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
  end;

  TEntitySecurityResProvider = class(TComponent, ISecurityResProvider)
  private
    FWorkItem: TWorkItem;
    FID: string;
    FEntityName: string;
  protected
    function ID: string;
    function GetTopRes: IInterfaceList;
    function GetChildRes(const ParentResID: string): IInterfaceList;
    function GetRes(const ID: string): ISecurityResNode;
  public
    constructor Create(AOwner: TComponent; AID, AEntityName: string; AWorkItem: TWorkItem); reintroduce;
  end;

implementation

{ TEntitySecurityResProvider }

constructor TEntitySecurityResProvider.Create(AOwner: TComponent;
  AID, AEntityName: string; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FID := AID;
  FEntityName := AEntityName;
  FWorkItem := AWorkItem;
end;

function TEntitySecurityResProvider.GetChildRes(
  const ParentResID: string): IInterfaceList;
var
  ds: TDataSet;
  node: TSecurityResNode;
  useDescription: boolean;
begin
  Result := TInterfaceList.Create;
  if App.Entities.EntityViewExists(FEntityName, 'ChildNodes') then
  begin
    ds := App.Entities[FEntityName].
      GetView('ChildNodes', FWorkItem).Load([ParentResID]);
    useDescription := ds.FindField('DESCRIPTION') <> nil;
    while not ds.Eof do
    begin
      node := TSecurityResNode.Create;
      node.FID := ds['ID'];
      node.FName := ds['NAME'];
      if useDescription then
        node.FDescription := ds['DESCRIPTION'];
      Result.Add(node as ISecurityResNode);
      ds.Next;
    end;
  end;
end;

function TEntitySecurityResProvider.GetRes(
  const ID: string): ISecurityResNode;
var
  ds: TDataSet;
  node: TSecurityResNode;
  useDescription: boolean;
begin
  ds := App.Entities[FEntityName].GetView('Node', FWorkItem).Load([ID]);
  useDescription := ds.FindField('DESCRIPTION') <> nil;
  node := TSecurityResNode.Create;
  node.FID := ds['ID'];
  node.FName := ds['NAME'];
  if useDescription then
    node.FDescription := ds['DESCRIPTION'];

  Result := node;
end;

function TEntitySecurityResProvider.GetTopRes: IInterfaceList;
var
  ds: TDataSet;
  node: TSecurityResNode;
  useDescription: boolean;
begin
  Result := TInterfaceList.Create;
  ds := App.Entities[FEntityName].GetView('TopNodes', FWorkItem).Load;
  useDescription := ds.FindField('DESCRIPTION') <> nil;
  while not ds.Eof do
  begin
    node := TSecurityResNode.Create;
    node.FID := ds['ID'];
    node.FName := ds['NAME'];
    if useDescription then
      node.FDescription := ds['DESCRIPTION'];
    Result.Add(node as ISecurityResNode);
    ds.Next;
  end
end;

function TEntitySecurityResProvider.ID: string;
begin
  Result := FID;
end;

{ TEntitySecurityResNode }

function TSecurityResNode.Description: string;
begin
  Result := FDescription;
end;

function TSecurityResNode.ID: string;
begin
  Result := FID;
end;

function TSecurityResNode.Name: string;
begin
  Result := FNAME;
end;
{ TActivitySecurityResProvider }

constructor TActivitySecurityResProvider.Create(AOwner: TComponent;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
end;

function TActivitySecurityResProvider.GetChildRes(
  const ParentResID: string): IInterfaceList;
begin
  Result := TInterfaceList.Create;
end;

function TActivitySecurityResProvider.GetRes(
  const ID: string): ISecurityResNode;
var
  activity: IActivity;
  node: TSecurityResNode;
begin
  activity := FWorkItem.Activities[ID];

  node := TSecurityResNode.Create;
  node.FID := activity.URI;
  node.FName := activity.Title;
  node.FDescription := activity.Group;
  Result := node as ISecurityResNode;
end;

function TActivitySecurityResProvider.GetTopRes: IInterfaceList;
var
  I: integer;
  node: TSecurityResNode;
begin
  Result := TInterfaceList.Create;
  for I := 0 to FWorkItem.Activities.Count - 1 do
    if FWorkItem.Activities.GetItem(I).UsePermission  then
    begin
      node := TSecurityResNode.Create;
      node.FID := FWorkItem.Activities.GetItem(I).URI;
      node.FName := FWorkItem.Activities.GetItem(I).Title;
      node.FDescription := FWorkItem.Activities.GetItem(I).Group;
      Result.Add(node as ISecurityResNode);
    end;

end;

function TActivitySecurityResProvider.ID: string;
begin
  Result := SECURITY_RES_PROVIDER_ID;
end;

end.
