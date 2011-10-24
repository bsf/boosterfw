unit ModuleEnumeratorEmbeded;

interface
uses SysUtils, classes, CoreClasses, Contnrs;

type
  TModuleEnumeratorEmbeded = class(TInterfacedObject, IModuleEnumeratorEmbeded)
    procedure Modules(AModules: TClassList; Kind: TModuleKind);
  end;

procedure RegisterActivator(ActivatorClass: TClass; Kind: TModuleKind);

implementation

type
  TActivatorInfo = class(TObject)
    FClass: TClass;
    FKind: TModuleKind;
  end;

var
  ActivatorInfoList: TObjectList;

procedure RegisterActivator(ActivatorClass: TClass; Kind: TModuleKind);
var
  ActivatorInfo: TActivatorInfo;
begin
  ActivatorInfo := TActivatorInfo.Create;
  with ActivatorInfo do
  begin
    FClass := ActivatorClass;
    FKind := Kind;
  end;

  ActivatorInfoList.Add(ActivatorInfo);
end;

{ TModuleEnumeratorEmbeded }

procedure TModuleEnumeratorEmbeded.Modules(AModules: TClassList; Kind: TModuleKind);
var
  I: integer;
begin
  if ParamStr(0) <> GetModuleName(HInstance) then Exit; //�������� �� ������ � bpl

  for I := 0 to ActivatorInfoList.Count - 1 do
    if (TActivatorInfo(ActivatorInfoList[I]).FKind = Kind)  then
      AModules.Add(TActivatorInfo(ActivatorInfoList[I]).FClass);
end;

initialization
  ActivatorInfoList := TObjectList.Create(True);

finalization
  if Assigned(ActivatorInfoList) then
    FreeAndNil(ActivatorInfoList);

end.
