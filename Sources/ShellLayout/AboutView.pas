unit AboutView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  AboutPresenter, StdCtrls, ExtCtrls, ShellIntf, CustomDialogView,
  CustomContentView, Menus, cxButtons, UIClasses, UIServiceIntf, cxLabel,
  cxTextEdit, cxMemo, jpeg, dxBevel, cxImage;

type
  TfrAboutView = class(TfrCustomView, IAboutView)
    cxGroupBox2: TcxGroupBox;
    cxGroupBox1: TcxGroupBox;
    imgLogo: TImage;
    lbVer: TLabel;
    LogoLabel: TLabel;
    btClose: TcxButton;
    cxGroupBox3: TcxGroupBox;
    cxLabel1: TcxLabel;
    cxLabel3: TcxLabel;
    edClientID: TcxTextEdit;
    cxGroupBox4: TcxGroupBox;
    Image1: TImage;
    cxLabel4: TcxLabel;
    lbLicenseType: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel6: TcxLabel;
    lbLicenseDescription: TcxLabel;
    cxGroupBox5: TcxGroupBox;
    cxLabel9: TcxLabel;
    mmContacts: TcxMemo;
    cxLabel2: TcxLabel;
    lbLicenseExpires: TcxLabel;
    procedure btCloseClick(Sender: TObject);
  private
  protected
    procedure SetLicenseInfo(const AType, AExpires, ADescription: string);
    procedure SetContactInfo(const AValue: TStrings);
    procedure SetClientID(const Value: string);
    //
    procedure Initialize; override;
  public
    { Public declarations }
  end;

var
  frAboutView: TfrAboutView;

implementation

{$R *.dfm}

{ TfrAboutView }

procedure TfrAboutView.btCloseClick(Sender: TObject);
begin
  WorkItem.Commands[COMMAND_CLOSE].Execute;
end;

procedure TfrAboutView.Initialize;
begin
  if App.UI.Locale = 'ru-RU' then
  begin
    LogoLabel.Caption := 'Информационная Система';
  end;

  lbVer.Caption := App.Version;

  imgLogo.Picture.Bitmap.Assign(App.Logo);
  btClose.Visible := App.UI.ShellLayoutKind <> slTabbed;
end;

procedure TfrAboutView.SetClientID(const Value: string);
begin
  edClientID.Text := Value;
end;

procedure TfrAboutView.SetContactInfo(const AValue: TStrings);
begin
  mmContacts.Lines.AddStrings(AValue);
end;

procedure TfrAboutView.SetLicenseInfo(const AType, AExpires, ADescription: string);
begin
  lbLicenseType.Caption := AType;
  lbLicenseExpires.Caption := AExpires;
  lbLicenseDescription.Caption := ADescription;
end;

end.
