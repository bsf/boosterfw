unit frReportPreviewPresenter;

interface
uses windows, sysutils, CustomPresenter, CoreClasses, frxClass, classes,
  controls, UIClasses, frxPreview, ShellIntf,
  frxExportCSV, frxExportHTML, frxExportPDF, frxExportXML, frxExportRTF,
  dialogs, shellapi;

const
  VIEW_FR_PREVIEW = 'views.fastreport.preview';

  COMMAND_PRINT_DEF = 'commands.print.def';
  COMMAND_PRINT = 'commands.print';

  COMMAND_ZOOM = 'commands.zoom';
  COMMAND_ZOOMMODE = 'commans.zoommode';

  COMMAND_EXPORT_DEF = 'commands.export.def';
  COMMAND_EXPORT_EXCEL = 'commands.export.excel';
  COMMAND_EXPORT_CSV = 'commands.export.csv';
  COMMAND_EXPORT_HTML = 'commands.export.html';
  COMMAND_EXPORT_PDF = 'commands.export.pdf';
  COMMAND_EXPORT_RTF = 'commands.export.rtf';

  COMMAND_PAGE_FIRST = 'commands.page.first';
  COMMAND_PAGE_PRIOR = 'commands.page.prior';
  COMMAND_PAGE_NEXT = 'commands.page.next';
  COMMAND_PAGE_LAST = 'commands.page.last';

type
  IfrReportPreviewView = interface(ICustomView)
  ['{5C50F268-1981-49D9-BD4B-31D70E17E938}']
    function GetPreviewObject: TfrxPreview;
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
    FfrxRTFExport: TfrxRTFExport;
    FExportDefFlag: string;
    function View: IfrReportPreviewView;
    procedure CmdPrintDef(Sender: TObject);
    procedure CmdPrint(Sender: TObject);
    procedure CmdZoom(Sender: TObject);
    procedure CmdZoomMode(Sender: TObject);

    procedure CmdExportCSV(Sender: TObject);
    procedure CmdExportHTML(Sender: TObject);
    procedure CmdExportPDF(Sender: TObject);
    procedure CmdExportExcel(Sender: TObject);
    procedure CmdExportRTF(Sender: TObject);
    procedure CmdPageNavigate(Sender: TObject);

    procedure frxReportClickObject(Sender: TfrxView; Button: TMouseButton;
      Shift: TShiftState; var Modified: Boolean);
  protected
    procedure OnInit(Sender: IActivity); override;
    procedure OnViewReady; override;
    procedure OnViewClose; override;
  end;

implementation
uses frReportFactory;

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

procedure TfrReportPreviewPresenter.CmdExportRTF(Sender: TObject);
begin
  if not Assigned(FfrxRTFExport) then
  begin
    FfrxRTFExport := TfrxRTFExport.Create(Self);
    FfrxRTFExport.OpenAfterExport := false;
  end;
  FfrxRTFExport.ShowDialog := false;

  FSaveDialog.Filter := '���� rtf (*.rtf)|*.rtf';
  FSaveDialog.DefaultExt := '.rtf';
  FSaveDialog.FileName := View.GetPreviewObject.Report.ReportOptions.Name;

  if FSaveDialog.Execute then
  begin
    FfrxRTFExport.FileName := FSaveDialog.FileName;
    View.GetPreviewObject.Export(FfrxRTFExport);
    if FileExists(FSaveDialog.FileName) then
      ShellExecute(HInstance, nil, PWideChar(FSaveDialog.FileName), nil, nil, SW_SHOWNORMAL);
  end;

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

  FSaveDialog.Filter := '���� Excel (*.xls)|*.xls';
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
  ViewTitle := FInitViewTitle + ' [���������]';
end;

procedure TfrReportPreviewPresenter.CmdPrintDef(Sender: TObject);
begin
  FReport.PrintOptions.ShowDialog := false;
  View.GetPreviewObject.Print;
  ViewTitle := FInitViewTitle + ' [���������]';
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

procedure TfrReportPreviewPresenter.frxReportClickObject(Sender: TfrxView;
  Button: TMouseButton; Shift: TShiftState; var Modified: Boolean);
var
  actionStr: TStringList;
  action: IActivity;
  I: integer;
begin
  if Sender.TagStr = '' then Exit;

  actionStr := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(Sender.TagStr), actionStr);
    if actionStr.Count = 0 then Exit;
    action := WorkItem.Activities[actionStr[0]];
    actionStr.Delete(0);
    for I := 0 to actionStr.Count - 1 do
      action.Params[actionStr.Names[I]] := actionStr.ValueFromIndex[I];
  finally
    actionStr.Free;
  end;
  action.Execute(WorkItem);
end;

procedure TfrReportPreviewPresenter.OnInit(Sender: IActivity);
begin
  inherited;
  FReport := TfrxReport.Create(Self);
  FReport.OnClickObject := frxReportClickObject;

  TStream(integer(Sender.Params['DATA'])).Position := 0;
  FReport.PreviewPages.LoadFromStream(TStream(integer(Sender.Params['DATA'])));

  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Options := FSaveDialog.Options + [ofOverwritePrompt];

  FExportDefFlag := Sender.Params[TfrPreviewActivityParams.ExportDef];
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

  if SameText(FExportDefFlag, 'RTF') then
    WorkItem.Commands[COMMAND_EXPORT_DEF].SetHandler(CmdExportRTF)
  else
    WorkItem.Commands[COMMAND_EXPORT_DEF].SetHandler(CmdExportExcel);

  WorkItem.Commands[COMMAND_EXPORT_CSV].SetHandler(CmdExportCSV);
  WorkItem.Commands[COMMAND_EXPORT_HTML].SetHandler(CmdExportHTML);
  WorkItem.Commands[COMMAND_EXPORT_PDF].SetHandler(CmdExportPDF);
  WorkItem.Commands[COMMAND_EXPORT_EXCEL].SetHandler(CmdExportExcel);
  WorkItem.Commands[COMMAND_EXPORT_RTF].SetHandler(CmdExportRTF);

  WorkItem.Commands[COMMAND_PAGE_FIRST].SetHandler(CmdPageNavigate);
  WorkItem.Commands[COMMAND_PAGE_PRIOR].SetHandler(CmdPageNavigate);
  WorkItem.Commands[COMMAND_PAGE_NEXT].SetHandler(CmdPageNavigate);
  WorkItem.Commands[COMMAND_PAGE_LAST].SetHandler(CmdPageNavigate);
end;


function TfrReportPreviewPresenter.View: IfrReportPreviewView;
begin
  Result := GetView as IfrReportPreviewView;
end;


end.
