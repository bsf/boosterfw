program BoosterLauncher;

uses
  CoreClasses, bfwApp, bfwModules, ConfigServiceIntf, classes;

{$R *.res}



type
  TBoosterApplication = class(TApp);

begin
  //Application.Initialize;
 // Application.MainFormOnTaskbar := True;
  //Application.Run;
  ConfigServiceIntf.LOCAL_APP_DATA_KEY := 'Booster\BoosterLauncher';
  TBoosterApplication.ShellInstantiate;
end.
