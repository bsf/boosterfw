unit bfwReportEngineFRModuleInit;

interface
uses classes, CoreClasses, CustomModule, ShellIntf, ViewServiceIntf,
  ReportServiceIntf, frReportFactory, frReportPreviewPresenter, frReportPreviewView;

type
  TdxbReportEngineFRModuleInit = class(TCustomModule)
  protected
    //IModule
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;


implementation


{ TdxbReportEngineFRModuleInit }

procedure TdxbReportEngineFRModuleInit.OnLoaded;
begin


end;

procedure TdxbReportEngineFRModuleInit.OnLoading;
begin
  (WorkItem.Services[IViewManagerService] as IViewManagerService).
    RegisterView(VIEW_FR_PREVIEW, TfrfrReportPreviewView, TfrReportPreviewPresenter);
  InstantiateController(TFastReportFactory);
end;

initialization
  RegisterEmbededModule(TdxbReportEngineFRModuleInit, mkFoundation);

end.
