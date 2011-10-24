unit bfwReportEngineXLModuleInit;

interface
uses classes, CoreClasses, CustomModule, ShellIntf,
  ReportServiceIntf, xlReportFactory;

type
  TdxbReportEngineXLModuleInit = class(TCustomModule)
  public
    class function Kind: TModuleKind; override;
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;


implementation

{ TdxbReportEngineXLModuleInit }

class function TdxbReportEngineXLModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

procedure TdxbReportEngineXLModuleInit.OnLoaded;
begin


end;

procedure TdxbReportEngineXLModuleInit.OnLoading;
begin
  (WorkItem.Services[IReportService] as IReportService).
     RegisterLauncherFactory(TXLReportFactory.Create(Self));
end;

initialization
  RegisterModule(TdxbReportEngineXLModuleInit);

end.
