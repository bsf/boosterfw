unit bfwShellLayoutModuleInit;

interface
uses classes, CoreClasses, SysUtils, ShellIntf, ShellForm, ActivityServiceIntf, Graphics,
  NavBarServiceIntf;


type
  TShellUIModule = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;

implementation
{$R Shell.res}


{ TShellUIModule }


class function TShellUIModule.Kind: TModuleKind;
begin
  Result := mkInfrastructure;
end;

procedure TShellUIModule.Load;
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

    Svc := WorkItem.Services[INavBarService] as INavBarService;
    Svc.DefaultLayout.Categories[MAIN_MENU_CATEGORY].SetImage(Image);
  finally
    Image.Free;
  end;


end;


initialization
  RegisterModule(TShellUIModule);
end.
