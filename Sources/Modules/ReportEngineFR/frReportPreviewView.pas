unit frReportPreviewView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, Menus,
  StdCtrls, cxButtons, CommonViewIntf, frxClass, frxPreview, frReportPreviewPresenter,
  ShellIntf, coreClasses, cxLabel;

type
  TfrfrReportPreviewView = class(TfrCustomView, IfrReportPreviewView)
    pnButtons: TcxGroupBox;
    btClose: TcxButton;
    frxPreview: TfrxPreview;
    btPrint: TcxButton;
    ppmPrint: TPopupMenu;
    miPrintDef: TMenuItem;
    miPrint: TMenuItem;
    btExport: TcxButton;
    btZoom: TcxButton;
    ppmZoome: TPopupMenu;
    miZoom25: TMenuItem;
    miZoom50: TMenuItem;
    miZoom75: TMenuItem;
    miZoom100: TMenuItem;
    miZoom150: TMenuItem;
    miZoom200: TMenuItem;
    miZoomPageWidth: TMenuItem;
    miZoomWholePage: TMenuItem;
    ppmExport: TPopupMenu;
    miExportHTML: TMenuItem;
    miExportCSV: TMenuItem;
    miExportPDF: TMenuItem;
    miExportExcel: TMenuItem;
    btPagePrior: TcxButton;
    btPageNext: TcxButton;
    ppmPagePrior: TPopupMenu;
    ppmPageNext: TPopupMenu;
    miPagePrior: TMenuItem;
    miPageFirst: TMenuItem;
    miPageNext: TMenuItem;
    miPageLast: TMenuItem;
    lbPages: TcxLabel;
    miExportODS: TMenuItem;
    procedure miZoomClick(Sender: TObject);
    procedure miZoomModeClick(Sender: TObject);
    procedure frxPreviewPageChanged(Sender: TfrxPreview; PageNo: Integer);
    procedure frxPreviewClick(Sender: TObject);
  private
  protected
    //IViewOwner
    procedure OnViewMouseWheel(AView: TControl; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean); override;
    procedure OnViewShow(AView: TControl); override;

    //IfrReportPreviewView
    function GetPreviewObject: TfrxPreview;
    procedure MarkPrinted;
    //
    procedure OnInitialize; override;
  end;

implementation

{$R *.dfm}

{ TfrfrReportPreviewView }

procedure TfrfrReportPreviewView.frxPreviewClick(Sender: TObject);
begin
  frxPreview.SetFocus;
end;

procedure TfrfrReportPreviewView.frxPreviewPageChanged(Sender: TfrxPreview;
  PageNo: Integer);
begin
  if frxPreview.PageCount <> 0 then
    lbPages.Caption := 'Страница ' + IntToStr(frxPreview.PageNo) +
      ' из ' + IntToStr(frxPreview.PageCount)
  else
    lbPages.Caption := '';
end;

function TfrfrReportPreviewView.GetPreviewObject: TfrxPreview;
begin
  Result := frxPreview;
end;

procedure TfrfrReportPreviewView.MarkPrinted;
begin

end;

procedure TfrfrReportPreviewView.miZoomClick(Sender: TObject);
var
  cmd: ICommand;
begin
  cmd := WorkItem.Commands[COMMAND_ZOOM];
  cmd.Data['VALUE'] := (Sender as TComponent).Tag;
  cmd.Execute;
end;

procedure TfrfrReportPreviewView.miZoomModeClick(Sender: TObject);
var
  cmd: ICommand;
begin
  cmd := WorkItem.Commands[COMMAND_ZOOMMODE];
  cmd.Data['VALUE'] := (Sender as TComponent).Tag;
  cmd.Execute;
end;

procedure TfrfrReportPreviewView.OnInitialize;
begin
  WorkItem.Commands[COMMAND_CLOSE].AddInvoker(btClose, 'OnClick');

  WorkItem.Commands[COMMAND_PRINT_DEF].AddInvoker(btPrint, 'OnClick');
  WorkItem.Commands[COMMAND_PRINT_DEF].AddInvoker(miPrintDef, 'OnClick');
  WorkItem.Commands[COMMAND_PRINT].AddInvoker(miPrint, 'OnClick');

  WorkItem.Commands[COMMAND_EXPORT_PDF].AddInvoker(miExportPDF, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_EXCEL].AddInvoker(miExportExcel, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_ODS].AddInvoker(miExportODS, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_HTML].AddInvoker(miExportHTML, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_CSV].AddInvoker(miExportCSV, 'OnClick');

  WorkItem.Commands[COMMAND_PAGE_PRIOR].AddInvoker(btPagePrior, 'OnClick');
  WorkItem.Commands[COMMAND_PAGE_PRIOR].AddInvoker(miPagePrior, 'OnClick');
  WorkItem.Commands[COMMAND_PAGE_FIRST].AddInvoker(miPageFirst, 'OnClick');

  WorkItem.Commands[COMMAND_PAGE_NEXT].AddInvoker(btPageNext, 'OnClick');
  WorkItem.Commands[COMMAND_PAGE_NEXT].AddInvoker(miPageNext, 'OnClick');
  WorkItem.Commands[COMMAND_PAGE_LAST].AddInvoker(miPageLast, 'OnClick');

end;

procedure TfrfrReportPreviewView.OnViewMouseWheel(AView: TControl;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  frxPreview.MouseWheelScroll(WheelDelta, false, ssCtrl in Shift);
end;

procedure TfrfrReportPreviewView.OnViewShow(AView: TControl);
begin
  inherited;
  frxPreview.SetFocus;
end;


end.
