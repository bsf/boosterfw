unit CustomUIController;

interface
uses Classes, CoreClasses, ShellIntf, Controls, CustomPresenter, Variants,
   ActivityServiceIntf, sysutils;

type
  TCustomUIController = class(TAbstractController)
  protected
    procedure OnInitialize; virtual;
  public
    constructor Create(AOwner: TWorkItem); override;
  end;

implementation

{ TCustomUIController }



constructor TCustomUIController.Create(AOwner: TWorkItem);
begin
  inherited Create(AOwner);
  OnInitialize;
end;


procedure TCustomUIController.OnInitialize;
begin

end;



end.
