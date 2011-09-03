unit ShellLoginParamForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrShellLoginParam = class(TForm)
    pnButtons: TPanel;
    btCancel: TButton;
    Panel1: TPanel;
    Bevel1: TBevel;
    UserNameLabel: TLabel;
    UserNameEdit: TEdit;
    Panel2: TPanel;
    CustomCombo: TComboBox;
    Button1: TButton;
    Button2: TButton;
    Bevel2: TBevel;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function CreateShellLoginParamDialog: TfrShellLoginParam;

implementation

{$R *.dfm}

function CreateShellLoginParamDialog: TfrShellLoginParam;
begin
  Result := TfrShellLoginParam.Create(nil);
end;

end.
