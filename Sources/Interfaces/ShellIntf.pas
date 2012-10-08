unit ShellIntf;

interface

uses  windows, graphics, forms, jpeg, CoreClasses, ConfigServiceIntf, CustomApp,
  EntityServiceIntf, SecurityIntf, UIServiceIntf, LicenseServiceIntf;

const
  RES_ID_APP_LOGO = 'APP_LOGO';

//Shell workspaces
  WS_CONTENT = '{46DD7E8B-48EE-4FEE-9A4F-D1A7EF5E0DA9}';
  WS_DIALOG = '{6478659E-7B5C-4D29-95F3-5BC4AF9DDE16}';
  WS_CONSOLE = '{65D51821-B33B-4F8B-AC8C-29F623B892C5}';

//events
  ET_LOAD_CONFIGURATION = '{B7AE0540-39E9-4307-A6AB-8547BC1CCC16}';
  ET_RELOAD_CONFIGURATION = '{3EEF0751-FCB0-4A84-96B5-2E4910C403A8}';

resourcestring
  //Main menu groups
  MENU_GROUP_FILE = 'File';//'Файл';
  MENU_GROUP_SERVICE = 'Service'; //'Сервис';

type
  IApp = interface
  ['{D24C773A-376C-41BA-A955-6FFE5CE62ECE}']
    function Version: string;
    function Logo: Graphics.TBitmap;
    function License: ILicenseService;
    function WorkItem: TWorkItem;
    function Settings: ISettings;
    function UserProfile: IProfile;
    function HostProfile: IProfile;
    function UI: IUIService;
    function Entities: IEntityService;
    function Security: ISecurityService;
  end;


function App: IApp;


implementation

function App: IApp;
begin
  Result := CustomApp.TCustomApplication.AppInstance as IApp
end;




end.
