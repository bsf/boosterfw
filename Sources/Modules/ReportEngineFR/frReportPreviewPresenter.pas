unit frReportPreviewPresenter;

interface
uses windows, sysutils, CustomPresenter, CoreClasses, frxClass, classes,
  controls, UIClasses, frxPreview, ShellIntf,
  frxExportCSV, frxExportHTML, frxExportPDF, frxExportXML, frxExportODF,
  dialogs, shellapi;

const
  VIEW_FR_PREVIEW = 'views.fastreport.preview';

  COMMAND_PRINT_DEF = 'commands.print.def';
  COMMAND_PRINT = 'commands.print';

  COMMAND_ZOOM = 'commands.zoom';
  COMMAND_ZOOMMODE = 'commans.zoommode';

  COMMAND_EXPORT_EXCEL = 'commands.export.excel';
  COMMAND_EXPORT_CSV = 'commands.export.csv';
  COMMAND_EXPORT_HTML = 'commands.export.html';
  COMMAND_EXPORT_PDF = 'commands.export.pdf';
  COMMAND_EXPORT_ODS = 'commands.export.ods';

  COMMAND_PAGE_FIRST = 'commands.page.first';
  COMMAND_PAGE_PRIOR = 'commands.page.prior';
  COMMAND_PAGE_NEXT = 'commands.page.next';
  COMMAND_PAGE_LAST = 'commands.page.last';

type
  IfrReportPreviewView = interface(ICustomView)
  ['{5C50F268-1981-49D9-BD4B-31D70E17E938}']
    function GetPreviewObject: TfrxPreview;
  end;

  TfrReportPreviewData = class(TPresenterData)
  private
    FStream: TMemoryStream;
    function GetStream: TStream;
  public
    procedure ClearReportStream;
    property ReportStream: TStream read GetStream;
  end;

  TfrReportPreviewPresenter = class(TCustomPresenter)
  private
    FReport: TfrxReport;
    FSaveDialog: TSaveDialog;
    FInitViewTitle: string;
    FfrxPDFExport: TfrxPDFExport;
    FfrxHTMLExport: TfrxHTMLExport;
    FfrxXMLExport: TfrxXMLExport;
    FfrxCSVExport: TfrxCSVExport;
    FfrxODSExport: TfrxODSExport;

    function View: IfrReportPreviewView;
    procedure CmdPrintDef(Sender: TObject);
    procedure CmdPrint(Sender: TObject);
    procedure CmdZoom(Sender: TObject);
    procedure CmdZoomMode(Sender: TObject);
    procedure CmdExportCSV(Sender: TObject);
    procedure CmdExportHTML(Sender: TObject);
    procedure CmdExportPDF(Sender: TObject);
    procedure CmdExportExcel(Sender: TObject);
    procedure CmdExportODS(Sender: TObject);
    procedure CmdPageNavigate(Sender: TObject);

    procedure frxReportClickObject(Sender: TfrxView; Button: TMouseButton;
      Shift: TShiftState; var Modified: Boolean);
  protected
    procedure OnInit(Sender: IAction); override;
    procedure OnViewReady; override;
    procedure OnViewClose; override;
  public
    class function ExecuteDataClass: TActionDataClass; override;
  end;

implementation


{ TfrReportPreviewPresenter }

procedure TfrReportPreviewPresenter.CmdExportCSV(Sender: TObject);
begin
  if not Assigned(FfrxCSVExport) then
  begin
    FfrxCSVExport := TfrxCSVExport.Create(Self);
    FfrxCSVExport.OpenAfterExport := true;
  end;
  View.GetPreviewObject.Export(FfrxCSVExport);
end;

procedure TfrReportPreviewPresenter.CmdExportHTML(Sender: TObject);
begin
  if not Assigned(FfrxHTMLExport) then
  begin
    FfrxHTMLExport := TfrxHTMLExport.Create(Self);
    FfrxHTMLExport.OpenAfterExport := true;
  end;
  View.GetPreviewObject.Export(FfrxHTMLExport);
end;

procedure TfrReportPreviewPresenter.CmdExportODS(Sender: TObject);
begin
  if not Assigned(FfrxODSExport) then
  begin
    FfrxODSExport := TfrxODSExport.Create(Self);
    FfrxODSExport.Wysiwyg := false;
    FfrxODSExport.Background := false;
    FfrxODSExport.ExportPageBreaks := false;
    FfrxODSExport.OpenAfterExport := true;
  end;
  View.GetPreviewObject.Export(FfrxODSExport);

end;

procedure TfrReportPreviewPresenter.CmdExportPDF(Sender: TObject);
begin
  if not Assigned(FfrxPDFExport) then
  begin
    FfrxPDFExport := TfrxPDFExport.Create(Self);
    FfrxPDFExport.OpenAfterExport := true;
  end;
  View.GetPreviewObject.Export(FfrxPDFExport);

end;

procedure TfrReportPreviewPresenter.CmdExportExcel(Sender: TObject);
begin
  if not Assigned(FfrxXMLExport) then
  begin
    FfrxXMLExport := TfrxXMLExport.Create(Self);
    FfrxXMLExport.Wysiwyg := false;
    FfrxXMLExport.Background := false;
    FfrxXMLExport.ExportPageBreaks := false;
    FfrxXMLExport.SuppressPageHeadersFooters := true;
    FfrxXMLExport.OpenExcelAfterExport := false;
  end;

  FfrxXMLExport.ShowDialog := false;

  FSaveDialog.Filter := '‘‡ÈÎ Excel (*.xls)|*.xls';
  FSaveDialog.DefaultExt := '.xls';
  FSaveDialog.FileName := View.GetPreviewObject.Report.ReportOptions.Name;

  if FSaveDialog.Execute then
  begin
    FfrxXMLExport.FileName := FSaveDialog.FileName;
    View.GetPreviewObject.Export(FfrxXMLExport);
    if FileExists(FSaveDialog.FileName) then
      ShellExecute(HInstance, nil, PWideChar(FSaveDialog.FileName), nil, nil, SW_SHOWNORMAL);
  end;

end;

procedure TfrReportPreviewPresenter.CmdPageNavigate(Sender: TObject);
var
  intf: ICommand;
begin
  Sender.GetInterface(ICommand, intf);
  if intf.Name = COMMAND_PAGE_FIRST then
    View.GetPreviewObject.First
  else if intf.Name = COMMAND_PAGE_PRIOR then
    View.GetPreviewObject.Prior
  else if intf.Name = COMMAND_PAGE_NEXT then
    View.GetPreviewObject.Next
  else if intf.Name = COMMAND_PAGE_LAST then
    View.GetPreviewObject.Last;

end;

procedure TfrReportPreviewPresenter.CmdPrint(Sender: TObject);
begin
  FReport.PrintOptions.ShowDialog := true;
  View.GetPreviewObject.Print;
  ViewTitle := FInitViewTitle + ' [Õ¿œ≈◊¿“¿Õ]';
end;

procedure TfrReportPreviewPresenter.CmdPrintDef(Sender: TObject);
begin
  FReport.PrintOptions.ShowDialog := false;
  View.GetPreviewObject.Print;
  ViewTitle := FInitViewTitle + ' [Õ¿œ≈◊¿“¿Õ]';
end;

procedure TfrReportPreviewPresenter.CmdZoom(Sender: TObject);
var
  intf: ICommand;
  zoom: integer;
begin
  Sender.GetInterface(ICommand, intf);
  zoom := intf.Data['VALUE'];
  View.GetPreviewObject.Zoom := zoom / 100;
end;

procedure TfrReportPreviewPresenter.CmdZoomMode(Sender: TObject);
var
  intf: ICommand;
  zoomMode: integer;
begin
  Sender.GetInterface(ICommand, intf);
  zoomMode := intf.Data['VALUE'];
  View.GetPreviewObject.ZoomMode := TfrxZoomMode(zoomMode);
end;

class function TfrReportPreviewPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TfrReportPreviewData;
end;

procedure TfrReportPreviewPresenter.frxReportClickObject(Sender: TfrxView;
  Button: TMouseButton; Shift: TShiftState; var Modified: Boolean);
var
  actionStr: TStringList;
  action: IAction;
  I: integer;
begin
  if Sender.TagStr = '' then Exit;

  actionStr := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(Sender.TagStr), actionStr);
    if actionStr.Count = 0 then Exit;
    action := WorkItem.Actions[actionStr[0]];
    actionStr.Delete(0);
    for I := 0 to actionStr.Count - 1 do
      action.Data.Value[actionStr.Names[I]] := actionStr.ValueFromIndex[I];
  finally
    actionStr.Free;
  end;
  action.Execute(WorkItem);
end;

procedure TfrReportPreviewPresenter.OnInit(Sender: IAction);
begin
  inherited;
  FReport := TfrxReport.Create(Self);
  FReport.OnClickObject := frxReportClickObject;
  (Sender.Data as TfrReportPreviewData).ReportStream.Position := 0;
  FReport.PreviewPages.LoadFromStream((Sender.Data as TfrReportPreviewData).ReportStream);

  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Options := FSaveDialog.Options + [ofOverwritePrompt];

  FInitViewTitle := ViewTitle;
end;


procedure TfrReportPreviewPresenter.OnViewClose;
begin
  View.PreferenceValue['Zoom'] := IntToStr(Trunc(View.GetPreviewObject.Zoom * 100));
end;

procedure TfrReportPreviewPresenter.OnViewReady;
begin
  FReport.Preview := View.GetPreviewObject;
  FReport.ShowPreparedReport;

  View.GetPreviewObject.Zoom :=
    StrToIntDef(View.PreferenceValue['Zoom'], 100) / 100;


  WorkItem.Commands[COMMAND_PRINT_DEF].SetHandler(CmdPrintDef);
  WorkItem.Commands[COMMAND_PRINT].SetHandler(CmdPrint);
  WorkItem.Commands[COMMAND_ZOOM].SetHandler(CmdZoom);
  WorkItem.Commands[COMMAND_ZOOMMODE].SetHandler(CmdZoomMode);

  WorkItem.Commands[COMMAND_EXPORT_CSV].SetHandler(CmdExportCSV);
  WorkItem.Commands[COMMAND_EXPORT_HTML].SetHandler(CmdExportHTML);
  WorkItem.Commands[COMMAND_EXPORT_PDF].SetHandler(CmdExportPDF);
  WorkItem.Commands[COMMAND_EXPORT_EXCEL].SetHandler(CmdExportExcel);
  WorkItem.Commands[COMMAND_EXPORT_ODS].SetHandler(CmdExportODS);

  WorkItem.Commands[COMMAND_PAGE_FIRST].SetHandler(CmdPageNavigate);
  WorkItem.Commands[COMMAND_PAGE_PRIOR].SetHandler(CmdPageNavigate);
  WorkItem.Commands[COMMAND_PAGE_NEXT].SetHandler(CmdPageNavigate);
  WorkItem.Commands[COMMAND_PAGE_LAST].SetHandler(CmdPageNavigate);
end;


function TfrReportPreviewPresenter.View: IfrReportPreviewView;
begin
  Result := GetView as IfrReportPreviewView;
end;


{ TfrReportPreviewData }

procedure TfrReportPreviewData.ClearReportStream;
begin
  (ReportStream as TMemoryStream).Clear;
end;

function TfrReportPreviewData.GetStream: TStream;
begin
  if FStream = nil then
    FStream := TMemoryStream.Create;

  Result := FStream;
end;

end.
