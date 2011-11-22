unit ShellLogin;

interface

uses
  SysUtils, Classes, Messages, forms, Controls, ShellIntf,
  graphics, windows,  SecurityIntf, CoreClasses, ShellLoginForm;

type
  TLoginCheckProc = procedure(const AUserID, APassword, ADBItem: string) of
    object;

  TShellLogin = class(TComponent)
  private
    FAliases: TStringList;
    FUserID: string;
    FPassword: string;
    FAlias: string;
    FCheckProc: TLoginCheckProc;

    procedure FOnOKLoginClick(Sender: TObject);
  public
    constructor Create(AOnwer: TComponent); override;
    destructor Destroy; override;
    function DoLogin: boolean;
    procedure InitLoginData(const AUserID, AAlias: string; Aliases: TStrings);
    procedure SetCheckProc(const ACheckProc: TLoginCheckProc);

  end;

  TLoginUserData = class(TComponent, ILoginUserData)
  private
    FUserID: string;
    FPassword: string;
    FOptions: TStringList;
    function UserID: string;
  protected
    function ILoginUserData.ID = UserID;
    function Password: string;
    function Options: TStrings;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TLoginUserSelectorService = class(TComponent, ILoginUserSelectorService)
  private
    FWorkItem: TWorkItem;
    FAuthFunc: TLoginAuthenticateFunc;
    FLogin: TShellLogin;
    FUserData: TLoginUserData;
    procedure LoginCheck(const AUserID, APassword, AAlias: string);
  protected
    //ILoginUserSelectorService
    procedure SelectUser(AuthenticateFunc: TLoginAuthenticateFunc);
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
  end;


implementation


{ TShellLogin }

constructor TShellLogin.Create(AOnwer: TComponent);
begin
  inherited;
  FAliases := TStringList.Create;
end;

destructor TShellLogin.Destroy;
begin
  FAliases.Free;
  inherited;
end;

function TShellLogin.DoLogin: boolean;
var
  lForm: TfmShellLogin;
begin
  try
    lForm := CreateShellLoginDialog(FOnOkLoginClick);
    try
      lForm.lbVer.Caption := App.Version;
      lForm.UserNameEdit.Text := FUserID;
      lForm.CustomCombo.Items.AddStrings(FAliases);
      if lForm.CustomCombo.Items.IndexOf(FAlias) > -1 then
        lForm.CustomCombo.ItemIndex := lForm.CustomCombo.Items.IndexOf(FAlias)
      else if FAliases.Count > 0 then lForm.CustomCombo.ItemIndex := 0;
      Result := (lForm.ShowModal = mrOK);
      if Result then
      begin
        FUserID := lForm.UserNameEdit.Text;
        FPassword := lForm.PasswordEdit.Text;
        FAlias := lForm.CustomCombo.Text;
      end;
    finally
      lForm.Free;
    end;
  except
    Application.HandleException(Self);
    Result := False;
  end;

end;
procedure TShellLogin.FOnOKLoginClick(Sender: TObject);
var lForm: TfmShellLogin;
begin
  lForm := TfmShellLogin(Sender);

  if Assigned(FCheckProc) then
    FCheckProc(lForm.UserNameEdit.Text, lForm.PasswordEdit.Text,
      lForm.CustomCombo.Text);


  lForm.ModalResult := mrOk;


end;


procedure TShellLogin.SetCheckProc(
  const ACheckProc: TLoginCheckProc);
begin
  FCheckProc := ACheckProc;
end;



procedure TShellLogin.InitLoginData(const AUserID, AAlias: string;
  Aliases: TStrings);
begin
  FUserID := AUserID;
  FAlias := AAlias;
  FAliases.AddStrings(Aliases);
end;



{ TLoginUserSelectorService }

constructor TLoginUserSelectorService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FLogin := TShellLogin.Create(Self);
  FUserData := TLoginUserData.Create(Self);
end;

procedure TLoginUserSelectorService.LoginCheck(const AUserID, APassword,
  AAlias: string);
begin
  if AAlias = '' then
    raise Exception.Create('Не выбрана информационная база!');

  FUserData.FUserID := AUserID;
  FUserData.FPassword := APassword;
  FUserData.Options.Values['ALIAS'] := AAlias;
  FAuthFunc(FUserData);
end;

procedure TLoginUserSelectorService.SelectUser(
  AuthenticateFunc: TLoginAuthenticateFunc);
begin
  FAuthFunc := AuthenticateFunc;
  FLogin.SetCheckProc(LoginCheck);

  FLogin.InitLoginData(App.UserProfile.GetValue('Login.LastUserID'), App.UserProfile.GetValue('Login.LastAlias'),
    App.Settings.Aliases);

  if FLogin.DoLogin then
  begin
    App.UserProfile.SetValue('Login.LastUserID', App.Settings.UserID);
    App.UserProfile.SetValue('Login.LastAlias', App.Settings.CurrentAlias);
  end;
end;

{ TLoginUserData }

constructor TLoginUserData.Create(AOwner: TComponent);
begin
  inherited;
  FOptions := TStringList.Create;
end;

destructor TLoginUserData.Destroy;
begin
  FOptions.Free;
  inherited;
end;

function TLoginUserData.Options: TStrings;
begin
  Result := FOptions;
end;

function TLoginUserData.Password: string;
begin
  Result := FPassword;
end;

function TLoginUserData.UserID: string;
begin
  Result := FUserID;
end;

end.
