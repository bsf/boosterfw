program BoosterConfigTool;

uses
  Forms,
  MainForm in 'MainForm.pas' {Form2},
  DAL_DSE_ClientProxy in '..\..\Sources\DAL\DAL_DSE_ClientProxy.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
