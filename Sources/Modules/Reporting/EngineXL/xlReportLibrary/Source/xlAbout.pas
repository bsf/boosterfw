{*******************************************************************}
{                                                                   }
{       AfalinaSoft Visual Component Library                        }
{       XL Report 4.0 with XLOptionPack  Technology                 }
{                                                                   }
{       Copyright (C) 1998, 2002 Afalina Co., Ltd.                  }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF AFALINA CO.,LTD. THE REGISTERED DEVELOPER IS         }
{   LICENSED TO DISTRIBUTE THE XL REPORT AND ALL ACCOMPANYING VCL   }
{   COMPONENTS AS PART OF AN EXECUTABLE PROGRAM ONLY.               }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT WRITTEN CONSENT          }
{   AND PERMISSION FROM AFALINA CO., LTD.                           }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit xlAbout;

{$I xlcDefs.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfxlAbout = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Panel2: TPanel;
    Image1: TImage;
    Panel3: TPanel;
    lblVersion: TLabel;
    Panel4: TPanel;
    Label8: TLabel;
    lblReg: TLabel;
    lblRegLink: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label11Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses ShellAPI, xlEngine;

procedure TfxlAbout.FormCreate(Sender: TObject);
begin
  lblVersion.Caption := 'Version ' + xlrVersionStr;
{$IFNDEF XLR_Trial}
  lblReg.Caption := 'Registered version';
  lblRegLink.Visible := false;
{$ENDIF XLR_TRIAL}
{$IFDEF XLR_AX}
  Label3.Hint := 'www.activexlreport.com'
{$ENDIF}
{$IFDEF XLR_VCL}
  Label3.Hint := 'www.xl-report.com'
{$ENDIF}
end;

procedure TfxlAbout.Label11Click(Sender: TObject);
begin
  ShellExecute(Application.Handle , 'open' , PChar(TLabel(Sender).Hint),
    nil , nil , SW_RESTORE);
end;

end.






