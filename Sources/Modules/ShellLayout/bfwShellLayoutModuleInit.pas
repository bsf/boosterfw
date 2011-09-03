unit bfwShellLayoutModuleInit;

interface
uses classes, CoreClasses, SysUtils, ShellIntf, ShellForm, ActivityServiceIntf, Graphics,
  NavBarServiceIntf;


type
  TShellUIModule = class(TComponent, IModule)
  protected
    //IModule
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;
  end;

implementation
{$R Shell.res}

function GetModuleActivatorClass: TClass;
begin
  Result := TShellUIModule;
end;

function GetModuleKind: TModuleKind;
begin
  Result := mkInfrastructure
end;

function GetModuleRunModes: TAppRunModes;
begin
  Result := [Low(TAppRunMode)..High(TAppRunMode)];
end;

exports
  GetModuleActivatorClass, GetModuleKind, GetModuleRunModes;

{ TShellUIModule }

procedure TShellUIModule.AddServices(AWorkItem: TWorkItem);
const
  NAVBAR_IMAGE_RES_NAME = 'SHELL_NAVBAR_IMAGE';

var
  Image: TBitMap;
  ImgRes: TResourceStream;
  Svc: INavBarService;
begin
  FormatSettings.ThousandSeparator := ' ';
  ShellIntf.ShellFormClass := TfrMain;

  Image := TBitMap.Create;
  try
    ImgRes := TResourceStream.Create(HInstance, NAVBAR_IMAGE_RES_NAME, 'file');
    try
      Image.LoadFromStream(ImgRes);
    finally
      ImgRes.Free;
    end;

    Svc := AWorkItem.Services[INavBarService] as INavBarService;
    Svc.DefaultLayout.Categories[MAIN_MENU_CATEGORY].SetImage(Image);
  finally
    Image.Free;
  end;
end;

procedure TShellUIModule.Load;
begin

end;

procedure TShellUIModule.UnLoad;
begin

end;

initialization
  RegisterEmbededModule(GetModuleActivatorClass, GetModuleKind,
    [Low(TAppRunMode)..High(TAppRunMode)]);
end.
