unit bfwSettingManagerModuleInit;

interface
uses classes, CoreClasses,  ShellIntf, SettingsPresenter, SettingsView;

type
  TdxbSecurityManagerModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation

{ TdxbSecurityManagerModuleInit }

procedure TdxbSecurityManagerModuleInit.Load;
begin
  App.Activities.Items.Add(VIEW_SETTINGS).Init(MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_SETTINGS_CAPTION);
  App.Views.RegisterView(VIEW_SETTINGS, TfrSettingsView, TSettingsPresenter);
end;

initialization
  RegisterModule(TdxbSecurityManagerModuleInit);

end.
