program BoosterServerWin;

uses
  Forms,
  MainForm in 'MainForm.pas' {Form3},
  ServerContainer in 'ServerContainer.pas' {ServerContainer1: TDataModule},
  ServerMethods in 'ServerMethods.pas' {BoosterFrameWork: TDSServerModule},
  DAL in '..\Sources\DAL\DAL.pas',
  DAL_IBE in '..\Sources\DAL\DAL_IBE.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TServerContainer1, ServerContainer1);
  Application.Run;
end.

