unit EntityController;

interface
uses classes, CoreClasses, CustomUIController,  ShellIntf,
  ActivityServiceIntf,  Variants;

type
  TEntityController = class(TCustomUIController)
  private
  protected
    procedure OnInitialize; override;
  end;

implementation

{ TEntityController }

procedure TEntityController.OnInitialize;
begin

end;

end.
