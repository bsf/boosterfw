unit ModuleEnumerator;

interface

uses Classes, CoreClasses, SysUtils, Contnrs, Windows;

type
  TModuleEnumerator = class(TInterfacedObject, IModuleEnumerator)
    procedure Modules(AModules: TStrings; Kind: TModuleKind; RunMode: TAppRunMode);
  end;

implementation

{ TModuleEnumerator }

procedure TModuleEnumerator.Modules(AModules: TStrings; Kind: TModuleKind;
  RunMode: TAppRunMode);
begin

  if ParamStr(0) = GetModuleName(HInstance) then Exit;

  if Kind = mkInfrastructure then
  begin
    AModules.Add('InfrastructureModule.bpl');
    AModules.Add('ShellUI.bpl');
  end
  else if Kind = mkFoundation then
  begin
    AModules.Add('ReportCatalogModule.bpl');
  end
  else if Kind = mkExtension then
  begin

    AModules.Add('CRMModule.bpl');
  end;
end;

end.
