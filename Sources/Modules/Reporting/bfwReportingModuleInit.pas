unit bfwReportingModuleInit;

interface
uses classes, CoreClasses, ReportingController, frReportFactory, xlReportFactory,
  ReportServiceIntf;

type
  TReportingModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;

implementation
{$R Reporting.res}


{ TReportingModuleInit }

class function TReportingModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

procedure TReportingModuleInit.Load;
begin
  WorkItem.WorkItems.Add(TReportingController);
  WorkItem.WorkItems.Add(TFastReportFactory);
  (WorkItem.Services[IReportService] as IReportService).
     RegisterLauncherFactory(TXLReportFactory.Create(Self));
end;


initialization
  RegisterModule(TReportingModuleInit);

end.
