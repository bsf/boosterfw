unit AboutPresenter;

interface
uses coreClasses, CustomPresenter, UIClasses,
  ShellLayoutStr, UIStr, LicenseServiceIntf, sysutils, classes;

const
  VIEW_ABOUT = 'views.shell.about';

type
  IAboutView = interface(ICustomView)
  ['{C62864EB-90E6-409F-AB8D-41333513D073}']
    procedure SetLicenseInfo(const AType, AExpires, ADescription: string);
    procedure SetClientID(const Value: string);
    procedure SetContactInfo(const AValue: TStrings);
  end;

  TAboutPresenter = class(TCustomPresenter)
  const
    CONTACT_FILE_NAME = 'Contacts.txt';
  private
    function View: IAboutView;
  protected
    procedure OnViewReady; override;
  end;

implementation

{ TAboutPresenter }

procedure TAboutPresenter.OnViewReady;
var
  licenseTypeName: string;
  contactInfo: TStringList;
  contactFileName: string;
  licenseSvc: ILicenseService;
begin
  ViewTitle := GetLocaleString(@VIEW_ABOUT_TITLE);

  licenseSvc := WorkItem.Services[ILicenseService] as ILicenseService;
  licenseTypeName := LicenseTypeStr[Ord(licenseSvc.GetType)];
  if licenseSvc.GetStatus = lsExpired then
    licenseTypeName := licenseTypeName + ' (Expired)';
  View.SetLicenseInfo(licenseTypeName, licenseSvc.GetExpires, licenseSvc.GetDescription);
  View.SetClientID(licenseSvc.GetClientID);

  contactFileName := ExtractFilePath(ParamStr(0)) + CONTACT_FILE_NAME;
  if FileExists(contactFileName) then
  begin
    contactInfo := TStringList.Create;
    try
      contactInfo.LoadFromFile(contactFileName);
      View.SetContactInfo(contactInfo);
    finally
      contactInfo.Free;
    end;
  end;

end;

function TAboutPresenter.View: IAboutView;
begin
  Result := GetView as IAboutView;
end;

end.
