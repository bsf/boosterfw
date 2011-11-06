unit bfwSettingManagerModuleInit;

interface
uses classes, CoreClasses, UIClasses, ShellIntf,
     SettingsPresenter, SettingsView;

type
  TSettingManagerModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation

{ TSettingManagerModuleInit }

procedure TSettingManagerModuleInit.Load;
begin
  with WorkItem.Activities[VIEW_SETTINGS] do
  begin
    Title := VIEW_SETTINGS_CAPTION;
    Group := MAIN_MENU_SERVICE_GROUP;
    UsePermission := true;
    RegisterHandler(TViewActivityHandler.Create(TSettingsPresenter, TfrSettingsView));
  end;
end;

initialization
  RegisterModule(TSettingManagerModuleInit);

end.
