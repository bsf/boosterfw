unit CustomDialogPresenter;

interface
uses CustomPresenter, ShellIntf, CoreClasses, CommonViewIntf;

type
  TCustomDialogPresenter = class(TCustomPresenter)
  protected
    class function GetWorkspaceDefault: string; override;
  end;

implementation

{ TCustomDialogPresenter }

class function TCustomDialogPresenter.GetWorkspaceDefault: string;
begin
  Result := WS_DIALOG;
end;

end.
