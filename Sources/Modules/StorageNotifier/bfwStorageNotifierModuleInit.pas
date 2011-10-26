unit bfwStorageNotifierModuleInit;

interface
uses classes, CoreClasses,  ShellIntf,
  NotifyReceiver, NotifySenderPresenter, NotifySenderView;

type
  TdxbStorageNotifierModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation

{ TdxbStorageNotifierModuleInit }
procedure TdxbStorageNotifierModuleInit.Load;
begin
  WorkItem.Root.WorkItems.Add(TNotifyReceiver, TNotifyReceiver.ClassName);

  App.Activities.Items.Add(VIEW_NOTIFYSENDER).Init(MAIN_MENU_CATEGORY,
    MAIN_MENU_SERVICE_GROUP, VIEW_NOTIFYSENDER_TITLE);


  App.Views.RegisterView(VIEW_NOTIFYSENDER, TfrNotifySenderView, TNotifySenderPresenter);

end;


initialization
  RegisterModule(TdxbStorageNotifierModuleInit);


end.
