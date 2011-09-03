unit bfwStorageNotifierModuleInit;

interface
uses classes, CoreClasses,  ShellIntf,
  NotifyReceiver, NotifySenderPresenter, NotifySenderView;

type
  TdxbStorageNotifierModuleInit = class(TComponent, IModule)
  protected
    //IModule
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;
  end;

implementation

{ TdxbStorageNotifierModuleInit }

procedure TdxbStorageNotifierModuleInit.AddServices(AWorkItem: TWorkItem);
begin
  AWorkItem.WorkItems.Add(TNotifyReceiver.ClassName, TNotifyReceiver);

  App.Activities.Items.Add(VIEW_NOTIFYSENDER).Init(MAIN_MENU_CATEGORY,
    MAIN_MENU_SERVICE_GROUP, VIEW_NOTIFYSENDER_TITLE);
 {RegisterActivity(VIEW_NOTIFYSENDER, MAIN_MENU_CATEGORY, MAIN_MENU_SERVICE_GROUP,
    VIEW_NOTIFYSENDER_TITLE, TNotifySenderPresenter, TfrNotifySenderView);}

  App.Views.RegisterView(VIEW_NOTIFYSENDER, TfrNotifySenderView, TNotifySenderPresenter);
end;

procedure TdxbStorageNotifierModuleInit.Load;
begin

end;

procedure TdxbStorageNotifierModuleInit.UnLoad;
begin

end;

initialization
  RegisterEmbededModule(TdxbStorageNotifierModuleInit, mkExtension);


end.
