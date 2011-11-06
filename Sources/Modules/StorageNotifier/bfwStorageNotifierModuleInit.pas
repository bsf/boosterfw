unit bfwStorageNotifierModuleInit;

interface
uses classes, CoreClasses,  ShellIntf, UIClasses,
  NotifyReceiver, NotifySenderPresenter, NotifySenderView;

type
  TStorageNotifierModuleInit = class(TModule)
  public
    procedure Load; override;
  end;

implementation

{ TStorageNotifierModuleInit }
procedure TStorageNotifierModuleInit.Load;
begin
  WorkItem.Root.WorkItems.Add(TNotifyReceiver, TNotifyReceiver.ClassName);

  with WorkItem.Activities[VIEW_NOTIFYSENDER] do
  begin
    Title := VIEW_NOTIFYSENDER_TITLE;
    Group := MAIN_MENU_SERVICE_GROUP;
  end;
  WorkItem.Activities.RegisterHandler(VIEW_NOTIFYSENDER,
    TViewActivityHandler.Create(TNotifySenderPresenter, TfrNotifySenderView));

end;


initialization
  RegisterModule(TStorageNotifierModuleInit);


end.
