unit LicenseUtils;

interface

uses Windows, SysUtils, Registry, classes;


function GetClientID: string;
function GetDemoClientID: string;
function SignLicense(const Data, ClientID: string): string;
function CheckLicense(const Data: string): boolean;


implementation
uses IdHashMessageDigest, idHash;

function StringToHash(const Value : string) : string;
 var
   idmd5 : TIdHashMessageDigest5;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  try
    result := idmd5.HashStringAsHex(Value);;
  finally
    idmd5.Free;
  end;
end;

function GetClientID: string;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ);
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    reg.OpenKeyReadOnly('HARDWARE\DESCRIPTION\System');
    result := StringToHash(reg.GetDataAsString('SystemBiosDate'));
  finally
    reg.Free;
  end;
end;

function GetDemoClientID: string;
const
  DemoHWID = '7A98AD685E0F9C5D1B052D106B844B0E';
begin
  Result := DemoHWID;
end;

function SignLicense(const Data, ClientID: string): string;
var
  str: TStringList;
begin
  str := TStringList.Create;
  try
    str.Text := Data;
    str.Add('ClientID=' + ClientID);
    str.Add('Signature=' + StringToHash(StringToHash(str.Text) + ClientID));
    Result := str.Text;
  finally
    str.Free;
  end;

end;

function CheckLicense(const Data: string): boolean;
var
  str: TStringList;
  clientID: string;
  signature: string;
begin
  Result := false;
  str := TStringList.Create;
  try
    str.Text := Data;
    clientID := str.Values['ClientID'];
    signature := str.Values['Signature'];

    if str.Count > 0  then
      str.Delete(str.Count - 1);

    //checkSignature
    if StringToHash(StringToHash(str.Text) + clientID) = signature then
    begin
      if clientID = GetDemoClientID then
        Result := true
      else if GetClientID = clientID then
        Result := true;
    end;

  finally
    str.Free;
  end;
end;



end.
