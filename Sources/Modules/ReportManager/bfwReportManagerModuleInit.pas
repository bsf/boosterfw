unit bfwReportManagerModuleInit;

interface
uses classes, CoreClasses, ShellIntf,
  ReportCatalogController, ReportCatalogConst;

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
begin
  WorkItem.WorkItems.Add(TReportCatalogController);
end;


initialization
  RegisterModule(TReportManagerModuleInit);

end.
