unit bfwSettingManagerModuleInit;

interface
uses classes, CoreClasses, ActivityServiceIntf, UIClasses, ShellIntf,
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
  with WorkItem.Services[IActivityService] as IActivityService do
  begin
    with RegisterActivityInfo(VIEW_SETTINGS) do
    begin
      Title := VIEW_SETTINGS_CAPTION;
      Group := MAIN_MENU_SERVICE_GROUP;
    end;
    RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
      VIEW_SETTINGS, TSettingsPresenter, TfrSettingsView));
  end;
end;

initialization
  RegisterModule(TSettingManagerModuleInit);

end.
