unit bfwShellLayoutModuleInit;

interface
uses classes, CoreClasses, SysUtils, ShellIntf, ShellForm, CustomApp;


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
begin
  FormatSettings.ThousandSeparator := ' ';
  CustomApp.TCustomApplication.ShellFormClass := TfrMain;
end;


initialization
  RegisterModule(TShellUIModule);
end.
