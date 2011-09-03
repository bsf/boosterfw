unit bfwReportEngineXLModuleInit;

interface
uses classes, CoreClasses, CustomModule, ShellIntf,
  ReportServiceIntf, xlReportFactory;

type
  TdxbReportEngineXLModuleInit = class(TCustomModule)
  protected
    //IModule
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;


implementation

{ TdxbReportEngineXLModuleInit }

procedure TdxbReportEngineXLModuleInit.OnLoaded;
begin


end;

procedure TdxbReportEngineXLModuleInit.OnLoading;
begin
  (WorkItem.Services[IReportService] as IReportService).
     RegisterLauncherFactory(TXLReportFactory.Create(Self));
end;

initialization
  RegisterEmbededModule(TdxbReportEngineXLModuleInit, mkFoundation);

end.
