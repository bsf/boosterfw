//
// Created by the DataSnap proxy generator.
// 07.12.2011 15:07:25
// 

unit DAL_DSE_ClientProxy;

interface

uses DBXCommon, DBXClient, DBXJSON, DSProxy, Classes, SysUtils, DB, SqlExpr, DBXDBReaders, DBXJSONReflect;

type
  TBoosterFrameWorkClient = class(TDSAdminClient)
  private
    FConnectCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    procedure Connect(AUserName: string; APassword: string);
  end;

implementation

procedure TBoosterFrameWorkClient.Connect(AUserName: string; APassword: string);
begin
  if FConnectCommand = nil then
  begin
    FConnectCommand := FDBXConnection.CreateCommand;
    FConnectCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FConnectCommand.Text := 'TBoosterFrameWork.Connect';
    FConnectCommand.Prepare;
  end;
  FConnectCommand.Parameters[0].Value.SetWideString(AUserName);
  FConnectCommand.Parameters[1].Value.SetWideString(APassword);
  FConnectCommand.ExecuteUpdate;
end;


constructor TBoosterFrameWorkClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;


constructor TBoosterFrameWorkClient.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;


destructor TBoosterFrameWorkClient.Destroy;
begin
  FreeAndNil(FConnectCommand);
  inherited;
end;

end.
