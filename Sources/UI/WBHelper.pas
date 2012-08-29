unit WBHelper;

interface
uses WBCtrl, classes, coreClasses, variants, EntityServiceIntf, sysutils;

type
  TScriptFunction = function (Params: array of OleVariant): OleVariant of object;

  TWorkItemProxy = class(TComponent, IScriptHelper)
  private
    FFunctions: TStringList;
    FWorkItem: TWorkItem;
    procedure RegisterFunction(const AName: string; AFunc: TScriptFunction);
    procedure RegisterFunctions;
    //
    function Script_getState(Params: array of OleVariant): OleVariant;
    function Script_setState(Params: array of OleVariant): OleVariant;
    function Script_execCommand(Params: array of OleVariant): OleVariant;
    function Script_execActivity(Params: array of OleVariant): OleVariant;

    function Script_loadData(Params: array of OleVariant): OleVariant;
    function Script_insertData(Params: array of OleVariant): OleVariant;
    function Script_updateData(Params: array of OleVariant): OleVariant;
    function Script_deleteData(Params: array of OleVariant): OleVariant;
    function Script_execData(Params: array of OleVariant): OleVariant;
  protected
    //IScriptHelper
    function GetFunctionIndex(const AName: WideString): integer;
    function InvokeFunction(const AFunctionIndex: integer; Params: array of OleVariant): OleVariant;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

implementation

type
  TScriptFuncObj = class
    Func: TScriptFunction;
  end;

{ TWorkItemProxy }

constructor TWorkItemProxy.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FFunctions := TStringList.Create(true);
  RegisterFunctions;
end;

destructor TWorkItemProxy.Destroy;
begin
  inherited;
end;

function TWorkItemProxy.GetFunctionIndex(const AName: WideString): integer;
begin
  Result := FFunctions.IndexOf(AName) + 1;
end;

function TWorkItemProxy.InvokeFunction(const AFunctionIndex: integer;
  Params: array of OleVariant): OleVariant;
begin
  Result := TScriptFuncObj(FFunctions.Objects[AFunctionIndex - 1]).Func(Params);
end;

procedure TWorkItemProxy.RegisterFunction(const AName: string;
  AFunc: TScriptFunction);
var
  item: TScriptFuncObj;
begin
  item := TScriptFuncObj.Create;
  item.Func := AFunc;
  FFunctions.AddObject(AName, item);
end;

procedure TWorkItemProxy.RegisterFunctions;
begin
  RegisterFunction('getState', Script_getState);
  RegisterFunction('setState', Script_setState);
  RegisterFunction('execCommand', Script_execCommand);
  RegisterFunction('loadData', Script_loadData);
  RegisterFunction('insertData', Script_insertData);
  RegisterFunction('updateData', Script_updateData);
  RegisterFunction('deleteData', Script_deleteData);
end;

function TWorkItemProxy.Script_deleteData(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
end;

function TWorkItemProxy.Script_execActivity(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;

end;

function TWorkItemProxy.Script_execCommand(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
  if Length(Params) = 0 then Exit;
  FWorkItem.Commands[Params[0]].Execute;
end;

function TWorkItemProxy.Script_execData(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
end;

function TWorkItemProxy.Script_loadData(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
  if Length(Params) < 2 then Exit;
  Result := (FWorkItem.Services[IEntityService] as IEntityService).
    Entity[Params[0]].GetView(Params[1], FWorkItem).JSONLoad;
end;

function TWorkItemProxy.Script_getState(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
  if Length(Params) = 0 then Exit;
  Result := FWorkItem.State[Params[0]];
end;

function TWorkItemProxy.Script_insertData(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
end;

function TWorkItemProxy.Script_setState(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
  if Length(Params) = 0 then Exit;

end;

function TWorkItemProxy.Script_updateData(
  Params: array of OleVariant): OleVariant;
begin
  Result := Unassigned;
  if Length(Params) < 3 then Exit;
  (FWorkItem.Services[IEntityService] as IEntityService).
    Entity[Params[0]].GetView(Params[1], FWorkItem).JSONUpdate(Params[2]);
end;

end.
