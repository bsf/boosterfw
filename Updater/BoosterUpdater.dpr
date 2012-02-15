program BoosterUpdater;

uses
  ShellView in 'ShellView.pas' {frMain},
  ConstUnit in 'ConstUnit.pas',
  Updater in 'Updater.pas',
  ShellViewIntf in 'ShellViewIntf.pas';

{$R *.res}

{$R uac.res}

var
  updater: TUpdater;

begin

  updater := TUpdater.Create(nil);
  try
    updater.ShellViewClass := TfrMain;
    updater.Run;
  finally
    updater.Free;
  end;

end.
