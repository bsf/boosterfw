unit bfwStorageNotifierModuleInit;

interface
uses classes, CoreClasses,  ShellIntf, ActivityServiceIntf, UIClasses,
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

  with WorkItem.Services[IActivityService] as IActivityService do
  begin
    with RegisterActivityInfo(VIEW_NOTIFYSENDER) do
    begin
      Title := VIEW_NOTIFYSENDER_TITLE;
      Group := MAIN_MENU_SERVICE_GROUP;
    end;
    RegisterActivityClass(TViewActivityBuilder.Create(WorkItem,
      VIEW_NOTIFYSENDER, TNotifySenderPresenter, TfrNotifySenderView));
  end;

end;


initialization
  RegisterModule(TStorageNotifierModuleInit);


end.
