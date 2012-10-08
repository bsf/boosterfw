program BoosterKeyGen;

{$APPTYPE CONSOLE}

uses
  SysUtils, classes,
  LicenseUtils in '..\..\Sources\Shell\Services\LicenseUtils.pas';

const
  LICENSE_FILE_NAME = 'license.dat';
  HELP_MESSAGE = 'BoosterKeyGen -c <client ID> [-s <filename>] [-o <filename>] [-e <value>] [-lt <value>]' + #10#13 + #10#13 +
                 '-c      client ID or DEMO' + #10#13 +
                 '-s      license source' + #10#13 +
                 '-o      output filename (default: license.dat)' + #10#13 +
                 '-e      expires date (format: yyyy-mm-dd)' + #10#13 +
                 '-lt     license type (default: 1))';

var
  sourceFile: string;
  resultFile: string;
  license: TStringList;
  licenseHash: string;
  licenseSignature: string;
  clientID: string;
  savePath: string;
  swVal: string;
begin
  if (ParamCount = 0) or (ParamStr(1) = '?')  then
  begin
    Writeln(HELP_MESSAGE);
    Exit;
  end;

  FindCmdLineSwitch('c', clientID);
  if clientID = '' then
  begin
    WriteLn('Error: Client ID not defined. Use switch "c"');
    Halt(1);
  end;

  sourceFile := '';
  if FindCmdLineSwitch('s', sourceFile) and (not FileExists(sourceFile)) then
  begin
    WriteLn('Error: ' + sourceFile + ' not found.');
    Halt(1);
  end;

  if not FindCmdLineSwitch('o', resultFile) then
    resultFile := ExtractFilePath(ParamStr(0)) + '\' + LICENSE_FILE_NAME;

  license := TStringList.Create;

  if sourceFile <> '' then
    license.LoadFromFile(sourceFile);

  if FindCmdLineSwitch('lt', swVal) then
    license.Values['LT'] := swVal;

  if FindCmdLineSwitch('e', swVal) then
    license.Values['Expires'] := swVal;

  if clientID = 'DEMO' then
    clientID := GetDemoClientID;

  license.Text := SignLicense(license.Text, clientID);

  license.SaveToFile(resultFile);

end.
