unit EntityWebView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, OleCtrls,
  SHDocVw, EntityWebPresenter, WBCtrl;

type
  TfrEntityWebView = class(TfrCustomContentView, IEntityWebView)
  private
    FWebBrowser: TWebBrowserCtrl;
  protected
    procedure Initialize; override;
    //IEntityWebView
    function WebBrowser: TWebBrowserCtrl;
  end;

var
  frEntityWebView: TfrEntityWebView;

implementation

{$R *.dfm}

{ TfrEntityWebView }

procedure TfrEntityWebView.Initialize;
begin
  inherited;
  FWebBrowser := TWebBrowserCtrl.Create(Self, WorkItem);
  TControl(FWebBrowser).Parent := ViewControl;
  FWebBrowser.Align := alClient;
end;

function TfrEntityWebView.WebBrowser: TWebBrowserCtrl;
begin
  Result := FWebBrowser;
end;


end.
