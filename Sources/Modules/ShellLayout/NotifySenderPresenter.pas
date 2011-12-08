unit NotifySenderPresenter;

interface

uses CustomDialogPresenter, UIClasses, CoreClasses, EntityServiceIntf,
  CustomPresenter, sysutils, db, ShellIntf, controls, classes, ShellLayoutStr;

const
  VIEW_NOTIFYSENDER = 'views.notifysender';
  COMMAND_SEND = 'commands.send';

  ENT_USER = 'BFW_SEC_USER';
  ENT_USER_VIEW_LIST  = 'List';
  ENT_MSG_BOX = 'BFW_INF_MSG';
  ENT_MSG_BOX_OPER_PUSH = 'PUSH';

type
  INotifySenderView = interface(IDialogView)
  ['{AF9BB33F-9644-4B13-9C08-FA40DF88F5DF}']
    procedure AddUser(const AUserID, AUserName: string);
    procedure GetSelectedUsers(AList: TStringList);
    function GetNotifyText: string;
  end;

  TNotifySenderPresenter = class(TCustomDialogPresenter)
  private
  protected
    function View: INotifySenderView;
    procedure OnViewReady; override;
    procedure CmdCancel(Sender: TObject);
    procedure CmdSend(Sender: TObject);
  end;

implementation

{ TNotifySenderPresenter }

procedure TNotifySenderPresenter.CmdCancel(Sender: TObject);
begin
  CloseView;
end;

procedure TNotifySenderPresenter.CmdSend(Sender: TObject);
var
  receivers: TStringList;
  msgText: string;
  I: integer;
begin
  receivers := TStringList.Create;
  try
    msgText := View.GetNotifyText;
    View.GetSelectedUsers(receivers);
    if (msgText <> '') and (receivers.Count > 0) then
      for I := 0 to receivers.Count - 1 do
        App.Entities[ENT_MSG_BOX].
          GetOper(ENT_MSG_BOX_OPER_PUSH, WorkItem).
            Execute([receivers[I], 'NotifyByApp', msgText]);
  finally
    receivers.Free;
  end;
  CloseView;
end;

procedure TNotifySenderPresenter.OnViewReady;
var
  dsUsers: TDataSet;
begin
  ViewTitle := GetLocaleString(@VIEW_NOTIFYSENDER_TITLE);
  FreeOnViewClose := true;

  View.CommandBar.AddCommand(COMMAND_CANCEL, 'Отмена', 'Esc', CmdCancel);
  View.CommandBar.AddCommand(COMMAND_SEND, 'Отослать', 'Enter', CmdSend);

  dsUsers := App.Entities[ENT_USER].GetView(ENT_USER_VIEW_LIST, WorkItem).Load;
  while not dsUsers.Eof do
  begin
    if dsUsers['ISROLE'] = 0 then
      View.AddUser(dsUsers['USERID'], dsUsers['NAME']);
    dsUsers.Next;
  end
end;

function TNotifySenderPresenter.View: INotifySenderView;
begin
  Result := GetView as INotifySenderView;
end;

end.
