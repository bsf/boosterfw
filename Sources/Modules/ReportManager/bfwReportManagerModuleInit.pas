unit bfwReportManagerModuleInit;

interface
uses classes, CoreClasses, CustomModule, ShellIntf, NavBarServiceIntf,
  ReportCatalogController, ReportCatalogConst, Graphics;

const
  NAVBAR_IMAGE_RES_NAME = 'REPORTS_NAVBAR_IMAGE';

type
  TdxbReportManagerModuleInit = class(TCustomModule)
  protected
    //IModule
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;

implementation
{$R Reporting.res}


{ TdxbReportManagerModuleInit }

procedure TdxbReportManagerModuleInit.OnLoaded;
begin
  InstantiateController(TReportCatalogController);
end;

procedure TdxbReportManagerModuleInit.OnLoading;
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
  RegisterEmbededModule(TdxbReportManagerModuleInit, mkFoundation);

end.
