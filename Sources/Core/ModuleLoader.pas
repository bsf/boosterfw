unit ModuleLoader;

interface
uses Classes, CoreClasses, SysUtils, Contnrs, Windows;

const
  cnstGetModuleActivatorClassFunc = 'GetModuleActivatorClass';

type
  TGetModuleActivatorClassFunc = function: TClass;

  TModuleInfo = class(TObject)
  private
    FActivator: TObject;
    FWorkItem: TWorkItem;
    FName: string;
    FHandle: THandle;
    FFileName: string;
    FKind: TModuleKind;
    procedure AddServices;
    procedure Init;
    procedure UnLoad;
  public
    constructor Create(ActivatorClass: TClass);
    destructor Destroy; override;
    property Name: string read FName;
    property Handle: THandle read FHandle;
    property FileName: string read FFileName;
  end;

  TModuleLoaderService = class(TInterfacedObject, IModuleLoaderService)
  private
    FModuleInfoList: TObjectList;
    function LoadModulePackage(const AFileName: string): THandle;
    procedure UnLoadModulePackage(HModule: THandle);
    function AddModuleInfo(AWorkItem: TWorkItem; ActivatorClass: TClass;
      AModuleHandle: THandle; AKind: TModuleKind): TModuleInfo;
  protected
    procedure Load(AWorkItem: TWorkItem; AModules: TStrings; Kind: TModuleKind;
       AInfoCallback: TModuleLoaderInfoCallback);
    procedure LoadEmbeded(AWorkItem: TWorkItem; Activators: TClassList;
      Kind: TModuleKind;  AInfoCallback: TModuleLoaderInfoCallback);
    procedure UnLoadAll;
  public
    constructor Create;
    destructor Destroy; override;
  end;



implementation

{ TModuleLoaderService }

constructor TModuleLoaderService.Create;
begin
  FModuleInfoList := TObjectList.Create(True);
end;

destructor TModuleLoaderService.Destroy;
begin
  FModuleInfoList.Free;
  inherited;
end;

procedure TModuleLoaderService.Load(AWorkItem: TWorkItem;
  AModules: TStrings; Kind: TModuleKind; AInfoCallback: TModuleLoaderInfoCallback);
var
  List: TObjectList;
  I: integer;
  activator: TClass;
  hModule: THandle;
  FuncPointer: TGetModuleActivatorClassFunc;
begin
  List := TObjectList.Create(False);
  try
    for I := 0 to AModules.Count - 1 do
    begin
      hModule := LoadModulePackage(AModules[I]);
      if hModule > 0 then
      begin
        FuncPointer := GetProcAddress(hModule, cnstGetModuleActivatorClassFunc);
        if @FuncPointer <> nil then
        begin
          activator := TGetModuleActivatorClassFunc(FuncPointer);
          List.Add(AddModuleInfo(AWorkItem, activator, hModule, Kind));
        end
        else
          UnLoadModulePackage(hModule);
      end;
    end;

    for I := 0 to List.Count - 1 do
      TModuleInfo(List[I]).AddServices;

    for I := 0 to List.Count - 1 do
      TModuleInfo(List[I]).Init;
  finally
    List.Free;
  end;

end;


function TModuleLoaderService.LoadModulePackage(const AFileName: string): THandle;
begin
  Result := LoadPackage(AFileName);
  //AddModuleInfo(AWorkItem, Activators[I], HInstance, Kind)
end;


procedure TModuleLoaderService.LoadEmbeded(AWorkItem: TWorkItem;
  Activators: TClassList; Kind: TModuleKind;  AInfoCallback: TModuleLoaderInfoCallback);
var
  List: TObjectList;
  I: integer;
begin
  List := TObjectList.Create(False);
  try
    for I := 0 to Activators.Count - 1 do
      List.Add(AddModuleInfo(AWorkItem, Activators[I], HInstance, Kind));

    for I := 0 to List.Count - 1 do
    begin
      AInfoCallback(List[I].ClassName, 'AddServices', Kind);
      TModuleInfo(List[I]).AddServices;
    end;

    for I := 0 to List.Count - 1 do
    begin
      AInfoCallback(List[I].ClassName, 'Init', Kind);    
      TModuleInfo(List[I]).Init;
    end;
  finally
    List.Free;
  end;

end;

function TModuleLoaderService.AddModuleInfo(AWorkItem: TWorkItem;
  ActivatorClass: TClass; AModuleHandle: THandle; AKind: TModuleKind): TModuleInfo;
begin
  Result := TModuleInfo.Create(ActivatorClass);
  with Result do
  begin
    FHandle := AModuleHandle;
    FFileName := GetModuleName(Result.FHandle);
    FName := ChangeFileExt(ExtractFileName(Result.FileName), '');
    FWorkItem := AWorkItem;
    FKind := AKind;
  end;

  FModuleInfoList.Add(Result);

end;

procedure TModuleLoaderService.UnLoadAll;
var
  I: integer;
begin
  //buseness
  for I := FModuleInfoList.Count - 1 downto 0 do
    if TModuleInfo(FModuleInfoList[I]).FKind = mkExtension then
      FModuleInfoList.Delete(I);

  for I := FModuleInfoList.Count - 1 downto 0 do
    if TModuleInfo(FModuleInfoList[I]).FKind = mkFoundation then
      FModuleInfoList.Delete(I);

  for I := FModuleInfoList.Count - 1 downto 0 do
    if TModuleInfo(FModuleInfoList[I]).FKind = mkInfrastructure then
      FModuleInfoList.Delete(I);
end;

procedure TModuleLoaderService.UnLoadModulePackage(HModule: THandle);
begin
  UnLoadPackage(HModule);
end;

{ TModuleInfo }

procedure TModuleInfo.AddServices;
var
  Intf: IModule;
begin
  if FActivator.GetInterface(IModule, Intf) then
    Intf.AddServices(FWorkItem);
end;

constructor TModuleInfo.Create(ActivatorClass: TClass);
begin
  FActivator := ActivatorClass.NewInstance;
end;

destructor TModuleInfo.Destroy;
begin
  UnLoad;
  if FActivator is TInterfacedObject then
    FActivator := nil
  else
    FreeAndNil(FActivator);
end;

procedure TModuleInfo.Init;
var
  Intf: IModule;
begin
  if FActivator.GetInterface(IModule, Intf) then
    Intf.Load;
end;



procedure TModuleInfo.UnLoad;
var
  Intf: IModule;
begin
  if FActivator.GetInterface(IModule, Intf) then
    Intf.UnLoad;
end;

end.
