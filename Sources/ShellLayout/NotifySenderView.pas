unit NotifySenderView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomDialogView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  cxCheckListBox, NotifySenderPresenter, cxTextEdit, cxMemo;

type
  TfrNotifySenderView = class(TfrCustomDialogView, INotifySenderView)
    cxGroupBox1: TcxGroupBox;
    lbUsers: TcxCheckListBox;
    cxGroupBox2: TcxGroupBox;
    mmText: TcxMemo;
  private
    FUsersID: TStringList;
  protected
    //INotifySenderView
    procedure AddUser(const AUserID, AUserName: string);
    procedure GetSelectedUsers(AList: TStringList);
    function GetNotifyText: string;

    procedure Initialize; override;
  public
    destructor Destroy; override;
  end;

var
  frNotifySenderView: TfrNotifySenderView;

implementation

{$R *.dfm}

{ TfrNotifySenderView }

procedure TfrNotifySenderView.AddUser(const AUserID, AUserName: string);
var
  item: TcxCheckListBoxItem;
begin
  item := lbUsers.Items.Add;
  item.Text := AUserName;
  item.Tag := FUsersID.Add(AUserID);
end;

destructor TfrNotifySenderView.Destroy;
begin
  FUsersID.Free;
  inherited;
end;

function TfrNotifySenderView.GetNotifyText: string;
begin
  Result := Trim(mmText.Lines.Text);
end;

procedure TfrNotifySenderView.GetSelectedUsers(AList: TStringList);
var
  I: integer;
begin
  for I := 0 to lbUsers.Items.Count - 1 do
    if lbUsers.Items[I].Checked then
      AList.Add(FUsersID[lbUsers.Items[I].Tag]);
end;

procedure TfrNotifySenderView.Initialize;
begin
  FUsersID := TStringList.Create;
end;

end.
