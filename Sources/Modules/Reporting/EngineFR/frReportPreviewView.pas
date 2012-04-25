unit frReportPreviewView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, Menus,
  StdCtrls, cxButtons, UIClasses, frxClass, frxPreview, frReportPreviewPresenter,
  ShellIntf, coreClasses, cxLabel, ReportCatalogConst;

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
    lbPages: TcxLabel;
    btPageFirst: TcxButton;
    btPageLast: TcxButton;
    miExportRTF: TMenuItem;
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
    lbPages.Caption := format(GetLocaleString(@strPagesLabelFmt), [IntToStr(frxPreview.PageNo), IntToStr(frxPreview.PageCount)])
      {'Страница ' + IntToStr(frxPreview.PageNo) +
      ' из ' + IntToStr(frxPreview.PageCount)}
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
  miZoomPageWidth.Caption := GetLocaleString(@strZoomPageWidth);
  miZoomWholePage.Caption := GetLocaleString(@strZoomWholePage);

  btZoom.Caption := GetLocaleString(@COMMAND_ZOOM_CAPTION);
  btPrint.Caption := GetLocaleString(@COMMAND_PRINT_DEF_CAPTION);
  miPrintDef.Caption := GetLocaleString(@COMMAND_PRINT_DEF_CAPTION);
  miPrint.Caption := GetLocaleString(@COMMAND_PRINT_CAPTION);

  btExport.Caption := GetLocaleString(@COMMAND_EXPORT_DEF_CAPTION);
  miExportExcel.Caption := GetLocaleString(@COMMAND_EXPORT_EXCEL_CAPTION);
  miExportPDF.Caption := GetLocaleString(@COMMAND_EXPORT_PDF_CAPTION);
  miExportHTML.Caption := GetLocaleString(@COMMAND_EXPORT_HTML_CAPTION);
  miExportRTF.Caption := GetLocaleString(@COMMAND_EXPORT_RTF_CAPTION);
  miExportCSV.Caption := GetLocaleString(@COMMAND_EXPORT_CSV_CAPTION);

  WorkItem.Commands[COMMAND_CLOSE].AddInvoker(btClose, 'OnClick');

  WorkItem.Commands[COMMAND_PRINT_DEF].AddInvoker(btPrint, 'OnClick');
  WorkItem.Commands[COMMAND_PRINT_DEF].AddInvoker(miPrintDef, 'OnClick');
  WorkItem.Commands[COMMAND_PRINT].AddInvoker(miPrint, 'OnClick');

  WorkItem.Commands[COMMAND_EXPORT_DEF].AddInvoker(btExport, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_EXCEL].AddInvoker(miExportExcel, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_PDF].AddInvoker(miExportPDF, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_HTML].AddInvoker(miExportHTML, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_RTF].AddInvoker(miExportRTF, 'OnClick');
  WorkItem.Commands[COMMAND_EXPORT_CSV].AddInvoker(miExportCSV, 'OnClick');

  WorkItem.Commands[COMMAND_PAGE_PRIOR].AddInvoker(btPagePrior, 'OnClick');
  WorkItem.Commands[COMMAND_PAGE_FIRST].AddInvoker(btPageFirst, 'OnClick');

  WorkItem.Commands[COMMAND_PAGE_NEXT].AddInvoker(btPageNext, 'OnClick');
  WorkItem.Commands[COMMAND_PAGE_LAST].AddInvoker(btPageLast, 'OnClick');

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
