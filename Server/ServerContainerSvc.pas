unit ServerContainerSvc;

interface

uses
  SysUtils, Classes, 
  SvcMgr, 
  DSTCPServerTransport,
  DSHTTPCommon, DSHTTP,
  DSServer, DSCommonServer, DSAuth; 

type
  TServerContainer2 = class(TService)
    DSServer1: TDSServer;
    DSTCPServerTransport1: TDSTCPServerTransport;
    DSHTTPService1: TDSHTTPService;
    DSServerClass1: TDSServerClass;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure DSServerClass1GetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
  private
    { Private declarations }
  protected
    function DoStop: Boolean; override;
    function DoPause: Boolean; override;
    function DoContinue: Boolean; override;
    procedure DoInterrogate; override;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  ServerContainer2: TServerContainer2;

implementation

uses Windows, ServerMethods;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServerContainer2.Controller(CtrlCode);
end;

function TServerContainer2.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

function TServerContainer2.DoContinue: Boolean;
begin
  Result := inherited;
  DSServer1.Start;
end;

procedure TServerContainer2.DoInterrogate;
begin
  inherited;
end;

function TServerContainer2.DoPause: Boolean;
begin
  DSServer1.Stop;
  Result := inherited;
end;

function TServerContainer2.DoStop: Boolean;
begin
  DSServer1.Stop;
  Result := inherited;
end;

procedure TServerContainer2.DSServerClass1GetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := ServerMethods.TBoosterFrameWork;
end;

procedure TServerContainer2.ServiceStart(Sender: TService; var Started: Boolean);
begin
  DSServer1.Start;
end;
end.

