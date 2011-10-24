unit bfwReportEngineFRModuleInit;

interface
uses classes, CoreClasses, CustomModule, ShellIntf, ViewServiceIntf,
  ReportServiceIntf, frReportFactory, frReportPreviewPresenter, frReportPreviewView;

type
  TdxbReportEngineFRModuleInit = class(TCustomModule)
  public
    class function Kind: TModuleKind; override;
    procedure OnLoading; override;
    procedure OnLoaded; override;
  end;


implementation


{ TdxbReportEngineFRModuleInit }

class function TdxbReportEngineFRModuleInit.Kind: TModuleKind;
begin
  Result := mkFoundation;
end;

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
  RegisterModule(TdxbReportEngineFRModuleInit);

end.
