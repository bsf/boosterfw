unit SvcUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs;

type
  TService3 = class(TService)
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  Service3: TService3;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Service3.Controller(CtrlCode);
end;

function TService3.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

end.
