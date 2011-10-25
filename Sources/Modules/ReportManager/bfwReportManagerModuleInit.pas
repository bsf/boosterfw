unit bfwReportManagerModuleInit;

interface
uses classes, CoreClasses, ShellIntf, NavBarServiceIntf,
  ReportCatalogController, ReportCatalogConst, Graphics;

const
  NAVBAR_IMAGE_RES_NAME = 'REPORTS_NAVBAR_IMAGE';

type
  TReportManagerModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;

implementation
{$R Reporting.res}


{ TReportManagerModuleInit }

class function TReportManagerModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

procedure TReportManagerModuleInit.Load;
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
  WorkItem.WorkItems.Add(TReportCatalogController);
end;


initialization
  RegisterModule(TReportManagerModuleInit);

end.
