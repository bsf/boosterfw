unit bfwReportEngineXLModuleInit;

interface
uses classes, CoreClasses, ShellIntf,
  ReportServiceIntf, xlReportFactory;

type
  TReportEngineXLModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;


implementation

{ TReportEngineXLModuleInit }

class function TReportEngineXLModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

procedure TReportEngineXLModuleInit.Load;
begin
  (WorkItem.Services[IReportService] as IReportService).
     RegisterLauncherFactory(TXLReportFactory.Create(Self));
end;

initialization
  RegisterModule(TReportEngineXLModuleInit);

end.
