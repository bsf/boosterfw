program BoosterLauncher;

uses
  CoreClasses,
  bfwApp,
  bfwModules,
  ConfigServiceIntf,
  classes;

{$R *.res}



type
  TBoosterApplication = class(TApp);

begin
  TBoosterApplication.AppInstance.Run;
end.
