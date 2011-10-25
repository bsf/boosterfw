unit bfwReportEngineFRModuleInit;

interface
uses classes, CoreClasses, ShellIntf, ViewServiceIntf,
  ReportServiceIntf, frReportFactory, frReportPreviewPresenter, frReportPreviewView;

type
  TReportEngineFRModuleInit = class(TModule)
  public
    class function Kind: TModuleKind; override;
    procedure Load; override;
  end;


implementation


{ TReportEngineFRModuleInit }

class function TReportEngineFRModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

procedure TReportEngineFRModuleInit.Load;
begin
  (WorkItem.Services[IViewManagerService] as IViewManagerService).
    RegisterView(VIEW_FR_PREVIEW, TfrfrReportPreviewView, TfrReportPreviewPresenter);
  WorkItem.WorkItems.Add(TFastReportFactory);
end;

initialization
  RegisterModule(TReportEngineFRModuleInit);

end.
