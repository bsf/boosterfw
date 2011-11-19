unit ShellIntf;

interface

uses  windows, graphics, forms, jpeg, CoreClasses, ConfigServiceIntf,
  EntityServiceIntf, ReportServiceIntf, SecurityIntf, UIServiceIntf;

const
  strAboutText: string = 'HELLO !!!';

  RES_ID_APP_LOGO = 'APP_LOGO';

//Shell workspaces
  WS_CONTENT = '{46DD7E8B-48EE-4FEE-9A4F-D1A7EF5E0DA9}';
  WS_DIALOG = '{6478659E-7B5C-4D29-95F3-5BC4AF9DDE16}';
  WS_CONSOLE = '{65D51821-B33B-4F8B-AC8C-29F623B892C5}';

//Shell def commands
  COMMAND_SELECT_LAYOUT = '{EDC39FA8-213A-47F7-9305-9E884EF5F75A}';
  COMMAND_FUNCTION_PANEL = '{383EDA8B-BE6E-42D4-A645-BA35DEB54816}';
  COMMAND_LOCK_APP = '{606295E3-FAB3-4272-8A55-463096A66BE7}';


//Profile structure
  PROFILE_VIEW_PREFERENCE_STORAGE = 'ViewPreference';

  // Top categories
  MAIN_MENU_CATEGORY = 'Главное меню';
  MAIN_MENU_FILE_GROUP = 'Файл';
  MAIN_MENU_SERVICE_GROUP = 'Сервис';

type
  TCustomShellForm = class(TForm)
  public
    procedure Initialize(AWorkItem: TWorkItem); virtual; abstract;
  end;

  TShellFormClass = class of TCustomShellForm;

  IApp = interface
  ['{D24C773A-376C-41BA-A955-6FFE5CE62ECE}']
    function Version: string;
    function WorkItem: TWorkItem;
    function Settings: ISettings;
    function UserProfile: IProfile;
    function HostProfile: IProfile;
    function UI: IUIService;
    function Entities: IEntityManagerService;
    function Reports: IReportService;
    function Security: ISecurityService;
  end;

var
  GetIApp: function: IApp = nil;
  ShellFormClass: TShellFormClass;

function App: IApp;


implementation

function App: IApp;
begin
  Result := nil;
  if @GetIApp <> nil then
    Result := GetIApp;
end;




end.
