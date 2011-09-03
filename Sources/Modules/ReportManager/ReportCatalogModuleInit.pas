unit ReportCatalogModuleInit;

interface
uses classes, CoreClasses, CustomModule, ShellIntf, NavBarServiceIntf,
  ReportCatalogController, ReportCatalogConst, Graphics;

const
  NAVBAR_IMAGE_RES_NAME = 'REPORTS_NAVBAR_IMAGE';

type
  TReportCatalogModule = class(TCustomModule)
  protected
    //IModule
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;

implementation
{$R Reporting.res}

function GetModuleActivatorClass: TClass;
begin
  Result := TReportCatalogModule;
end;

function GetModuleKind: TModuleKind;
begin
  Result := mkFoundation;
end;

exports
  GetModuleActivatorClass, GetModuleKind;

{ TReportingModule }

procedure TReportCatalogModule.OnLoaded;
begin
  InstantiateController(TReportCatalogController);
end;

procedure TReportCatalogModule.OnLoading;
var
  Image: TBitMap;
  ImgRes: TResourceStream;
  Svc: INavBarService;
begin
  Image := TBitMap.Create;
  try
    ImgRes := TResourceStream.Create(HInstance, NAVBAR_IMAGE_RES_NAME, 'file');
    try
      Image.LoadFromStream(ImgRes);
    finally
      ImgRes.Free;
    end;

    Svc := WorkItem.Services[INavBarService] as INavBarService;
    Svc.DefaultLayout.Categories[ACT_CTG_REPORTS].SetImage(Image);
  finally
    Image.Free;
  end;



end;

initialization
  RegisterEmbededModule(GetModuleActivatorClass, GetModuleKind);

end.
