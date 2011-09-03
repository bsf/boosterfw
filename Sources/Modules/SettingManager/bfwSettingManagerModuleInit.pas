unit bfwSettingManagerModuleInit;

interface
uses classes, CoreClasses,  ShellIntf, SettingsPresenter, SettingsView;

type
  TdxbSecurityManagerModuleInit = class(TComponent, IModule)
  protected
    //IModule
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;
  end;

implementation

{ TdxbSecurityManagerModuleInit }

procedure TdxbSecurityManagerModuleInit.AddServices(AWorkItem: TWorkItem);
begin
{RegisterActivity(VIEW_SETTINGS, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_SETTINGS_CAPTION, TSettingsPresenter, TfrSettingsView);}
  App.Activities.Items.Add(VIEW_SETTINGS).Init(MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_SETTINGS_CAPTION);
  App.Views.RegisterView(VIEW_SETTINGS, TfrSettingsView, TSettingsPresenter);
 // AWorkItem.WorkItems.Add(TAdminController);
end;

procedure TdxbSecurityManagerModuleInit.Load;
begin

end;

procedure TdxbSecurityManagerModuleInit.UnLoad;
begin

end;

initialization
  RegisterEmbededModule(TdxbSecurityManagerModuleInit, mkExtension);

end.
