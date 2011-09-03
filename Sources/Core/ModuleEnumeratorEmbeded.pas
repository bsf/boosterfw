unit ModuleEnumeratorEmbeded;

interface
uses SysUtils, classes, CoreClasses, Contnrs;

type
  TModuleEnumeratorEmbeded = class(TInterfacedObject, IModuleEnumeratorEmbeded)
    procedure Modules(AModules: TClassList; Kind: TModuleKind;
      RunMode: TAppRunMode);
  end;

procedure RegisterActivator(ActivatorClass: TClass; Kind: TModuleKind;
  RunModes: TAppRunModes);

implementation

type
  TActivatorInfo = class(TObject)
    FClass: TClass;
    FKind: TModuleKind;
    FRunModes: TAppRunModes;
  end;

var
  ActivatorInfoList: TObjectList;

procedure RegisterActivator(ActivatorClass: TClass; Kind: TModuleKind;
  RunModes: TAppRunModes);
var
  ActivatorInfo: TActivatorInfo;
begin
  ActivatorInfo := TActivatorInfo.Create;
  with ActivatorInfo do
  begin
    FClass := ActivatorClass;
    FKind := Kind;
    FRunModes := RunModes;
  end;

  ActivatorInfoList.Add(ActivatorInfo);
end;

{ TModuleEnumeratorEmbeded }

procedure TModuleEnumeratorEmbeded.Modules(AModules: TClassList;
  Kind: TModuleKind; RunMode: TAppRunMode);
var
  I: integer;
begin
  if ParamStr(0) <> GetModuleName(HInstance) then Exit; //проверка на сборку с bpl

  for I := 0 to ActivatorInfoList.Count - 1 do
    if (TActivatorInfo(ActivatorInfoList[I]).FKind = Kind) and
       (RunMode in TActivatorInfo(ActivatorInfoList[I]).FRunModes)  then
      AModules.Add(TActivatorInfo(ActivatorInfoList[I]).FClass);
end;

initialization
  ActivatorInfoList := TObjectList.Create(True);

finalization
  if Assigned(ActivatorInfoList) then
    FreeAndNil(ActivatorInfoList);

end.
