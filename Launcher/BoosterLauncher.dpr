program BoosterLauncher;

uses
  CoreClasses, bfwShellApp, ConfigServiceIntf, classes,

  // dxBooster modules

  //Admin addons
  bfwSettingManagerModuleInit,
  bfwSecurityManagerModuleInit,

  //
  bfwStorageNotifierModuleInit,
  bfwReportManagerModuleInit,
  bfwReportEngineXLModuleInit,
  bfwReportEngineFRModuleInit,
  bfwEntityCatalogModuleInit,
  bfwGadgetCatalogModuleInit,

  //Infrastructure addons
  bfwStorageConnIBXModuleInit,
  bfwSecurityBaseControllerModuleInit,
  bfwShellLayoutModuleInit;

{$R *.res}



type
  TBoosterApplication = class(TApp)
  protected
    procedure AddServices; override;
  end;

{ TBoosterApplication }

procedure TBoosterApplication.AddServices;
begin
  ConfigServiceIntf.LOCAL_APP_DATA_KEY := 'Booster\BoosterLauncher';
  inherited;
end;

begin
  //Application.Initialize;
 // Application.MainFormOnTaskbar := True;
  //Application.Run;
  TBoosterApplication.ShellInstantiate;
end.
