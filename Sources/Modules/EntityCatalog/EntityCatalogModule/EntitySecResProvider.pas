unit EntitySecResProvider;

interface
uses SecurityIntf, CoreClasses, classes, ActivityServiceIntf, EntityServiceIntf,
  ShellIntf, db;

type
  TEntitySecurityResNode = class(TInterfacedObject, ISecurityResNode)
  private
    FID: string;
    FName: string;
    FDescription: string;
  protected
    function ID: string;
    function Name: string;
    function Description: string;
  end;

  TEntitySecurityResProvider = class(TComponent, ISecurityResProvider)
  private
    FWorkItem: TWorkItem;
    FID: string;
    function UIInfo: IActivityInfo;
  protected
    function ID: string;
    function GetTopRes: IInterfaceList;
    function GetChildRes(const ParentResID: string): IInterfaceList;
    function GetRes(const ID: string): ISecurityResNode;
  public
    constructor Create(AOwner: TComponent; AID: string; AWorkItem: TWorkItem); reintroduce;
  end;

implementation

{ TEntitySecurityResProvider }

constructor TEntitySecurityResProvider.Create(AOwner: TComponent;
  AID: string; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FID := AID;
  FWorkItem := AWorkItem;
end;

function TEntitySecurityResProvider.GetChildRes(
  const ParentResID: string): IInterfaceList;
var
  ds: TDataSet;
  node: TEntitySecurityResNode;
  useDescription: boolean;
begin
  Result := TInterfaceList.Create;

  if App.Entities.EntityViewExists(UIInfo.EntityName, 'ChildNodes') then
  begin
    ds := App.Entities[UIInfo.EntityName].
      GetView('ChildNodes', FWorkItem).Load([ParentResID]);
    useDescription := ds.FindField('DESCRIPTION') <> nil;
    while not ds.Eof do
    begin
      node := TEntitySecurityResNode.Create;
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
  node: TEntitySecurityResNode;
  useDescription: boolean;
begin
  ds := App.Entities[UIInfo.EntityName].GetView('Node', FWorkItem).Load([ID]);
  useDescription := ds.FindField('DESCRIPTION') <> nil;
  node := TEntitySecurityResNode.Create;
  node.FID := ds['ID'];
  node.FName := ds['NAME'];
  if useDescription then
    node.FDescription := ds['DESCRIPTION'];

  Result := node;  
end;

function TEntitySecurityResProvider.GetTopRes: IInterfaceList;
var
  ds: TDataSet;
  node: TEntitySecurityResNode;
  useDescription: boolean;
begin
  Result := TInterfaceList.Create;
  ds := App.Entities[UIInfo.EntityName].GetView('TopNodes', FWorkItem).Load;
  useDescription := ds.FindField('DESCRIPTION') <> nil;
  while not ds.Eof do
  begin
    node := TEntitySecurityResNode.Create;
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

function TEntitySecurityResProvider.UIInfo: IActivityInfo;
begin
  Result := (FWorkItem.Services[IActivityService] as IActivityService).ActivityInfo(FID);
end;

{ TEntitySecurityResNode }

function TEntitySecurityResNode.Description: string;
begin
  Result := FDescription;
end;

function TEntitySecurityResNode.ID: string;
begin
  Result := FID;
end;

function TEntitySecurityResNode.Name: string;
begin
  Result := FNAME;
end;

end.
