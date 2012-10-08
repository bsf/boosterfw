program BoosterKeyGen;

{$APPTYPE CONSOLE}

uses
  SysUtils, classes,
  LicenseUtils in '..\..\Sources\Shell\Services\LicenseUtils.pas';

const
  LICENSE_FILE_NAME = 'license.dat';

var
  sourceLicense: string;
  license: TStringList;
  licenseHash: string;
  licenseSignature: string;
  clientID: string;
  savePath: string;

begin
  FindCmdLineSwitch('s', sourceLicense);
  if sourceLicense = '' then
  begin
    WriteLn('Error: source file not defined. Use switch "s"');
    Halt(1);
  end;

  if not FileExists(sourceLicense) then
  begin
    WriteLn('Error: ' + sourceLicense + ' not found.');
    Halt(1);
  end;

  FindCmdLineSwitch('c', clientID);
  if clientID = '' then
  begin
    WriteLn('Error: Client ID not defined. Use switch "c"');
    Halt(1);
  end;

  FindCmdLineSwitch('o', savePath);
  if savePath = '' then
    savePath := ExtractFilePath(ParamStr(0));

  license := TStringList.Create;

  license.LoadFromFile(sourceLicense);

  license.Text := SignLicense(license.Text, clientID);

  license.SaveToFile(savePath + '\' + LICENSE_FILE_NAME);

end.
