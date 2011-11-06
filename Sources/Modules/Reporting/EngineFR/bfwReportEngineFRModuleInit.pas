unit bfwReportEngineFRModuleInit;

interface
uses classes, CoreClasses, frReportFactory;

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
  WorkItem.WorkItems.Add(TFastReportFactory);
end;

initialization
  RegisterModule(TReportEngineFRModuleInit);

end.
