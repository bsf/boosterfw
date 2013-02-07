unit ServerContainer;

interface

uses
  SysUtils, Classes, 
  DSHTTPCommon, DSHTTP,
  DSServer, DSCommonServer, DSAuth, IndyPeerImpl;

type
  TServerContainer1 = class(TDataModule)
    DSServer1: TDSServer;
    DSHTTPService1: TDSHTTPService;
    DSServerClass1: TDSServerClass;
    procedure DSServerClass1GetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
  private
    { Private declarations }
  public
  end;

var
  ServerContainer1: TServerContainer1;

implementation

uses Windows, ServerMethods;

{$R *.dfm}

procedure TServerContainer1.DSServerClass1GetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := ServerMethods.TBoosterFrameWork;
end;

end.

