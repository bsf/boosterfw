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

unit xlEngine;

{$I xlcDefs.inc}
                                               
interface

uses Classes, ComObj, Controls, ActiveX, OleCtnrs, SysUtils, Windows, Forms, Dialogs,
  Clipbrd, DDEML, DDEMan,
  {$IFDEF XLR_VCL4}
    OleCtrls,
  {$ENDIF}
  {$IFDEF XLR_VCL6}
    Variants,
  {$ENDIF}
  {$IFDEF XLR_VCL7}
    Variants,
  {$ENDIF}
  {$IFDEF XLR_VCL}
    DB,
  {$ENDIF}
  {$IFDEF XLR_TRIAL}
    ShellAPI,
  {$ENDIF}
  Excel8G2, VBIDE8G2, Office8G2, xlcUtils, xlcOPack, xlcClasses, xlStdOPack;

type

{ Forward declaration of XL Report classes }

  TxlExcelReport = class;
  TxlExcelDataSource = class;
  TxlExcelDataSources = class;

  ExlReportError = xlcClasses.ExlReportError;
  ExlReportBreak = class(ExlReportError);

{ Excel interfaces }

  {$IFDEF XLR_BCB}
  IxlApplication = OLEVariant;
  IxlWorkbooks = OLEVariant;
  IxlWorkbook = OLEVariant;
  IxlWorksheets = OLEVariant;
  IxlWorksheet = OLEVariant;
  IxlNames = OLEVariant;
  IxlName = OLEVariant;
  IxlRange = OLEVariant;
  IxlWorksheetFunction = OLEVariant;
  IxlPivotTable = OLEVariant;
  IxlPivotField = OLEVariant;
  IxlShape = OLEVariant;
  IxlVBComponent = OLEVariant;
  IxlCharacters = OLEVariant;
  {$ELSE}
  IxlApplication = Excel8G2._Application;
  IxlWorkbooks = Excel8G2.Workbooks;
  IxlWorkbook = Excel8G2._Workbook;
  IxlWorksheets = Excel8G2.Sheets;
  IxlWorksheet = Excel8G2._Worksheet;
  IxlNames = Excel8G2.Names;
  IxlName = Excel8G2.Name;
  IxlRange = Excel8G2.Range;
  IxlWorksheetFunction = Excel8G2.WorksheetFunction;
  IxlPivotTable = Excel8G2.PivotTable;
  IxlPivotField = Excel8G2.PivotField;
  IxlShape = Excel8G2.Shape;
  IxlVBComponent = OLEVariant;
  IxlCharacters = Excel8G2.Characters;
  {$ENDIF XLR_BCB}

{ Additional types }

  // Report options
  TxlReportOptions = (xroOptimizeLaunch, xroNewInstance, xroDisplayAlerts, xroAddToMRU,
    xroAutoSave, xroUseTemp, xroAutoOpen, xroAutoClose, xroHideExcel, xroSaveClipboard,
    xroRefreshParams, xroCalculationManual);
  TxlReportOptionsSet = set of TxlReportOptions;

  // Range options
  TxlRangeOptions = (xrgoAutoOpen, xrgoAutoClose, xrgoPreserveRowHeight);
  TxlRangeOptionsSet = set of TxlRangeOptions;

  // Data export mode
  TxlDataExportMode = (xdmCSV, xdmVariant, xdmDDE);

{ TxlExcelDataSource class }

  TxlExcelDataSource = class(TxlAbstractDataSource)
  private
    FBuff: TObject;
    FRowOffset: integer;
    FOptions: TxlRangeOptionsSet;
    FRows: OLEVariant;
    FHeights: OLEVariant;
    FRootRanges: OLEVariant;
    FRanges: OLEVariant;
    FRangesCount: integer;
    FRecordCount: integer;
    FDeleteSpecialRow: boolean;
    FSR: integer;
    FAllowOptions: boolean;
    // used interfaces
    FIXLSApp: IxlApplication;
    FINames: IxlNames;
    FIName: IxlName;
    FIRange: IxlRange;
    FIWorkbook: IxlWorkbook;
    FIWorkbooks: IxlWorkbooks;
    FITempSheet: IxlWorksheet;
    FISheet: IxlWorksheet;
    FIWorksheets: IxlWorksheets;
    FIMergedRows, FIUnMergedRows: IxlRange;
    function GetReport: TxlExcelReport;
    function GetMasterSource: TxlExcelDataSource;
    procedure SetMasterSource(const Value: TxlExcelDataSource);
    function GetRoot: TxlExcelDataSource;
    function GetLevel: integer;
    function GetMaxLevel: integer;
    procedure SetOptions(const Value: TxlRangeOptionsSet);
    function GetDataSources: TxlExcelDataSources;
  protected
    //
    function GetAlias: string; override;
    //
    procedure Connect; override;
    procedure Disconnect; override;
    procedure MacroProcessing(const MacroType: TxlMacroType;
      const MacroName: string); override;
    // Template parsing
    procedure GetRangeInfo(var ARow, AColumn, ARowCount, AColCount: integer;
      var Formulas, RowCaptions: OLEVariant); override;
    procedure ScanParsedCells(Formulas: OLEVariant); override;
    // Data transfer
    procedure PutNoRange; override;
    procedure PutRange; override;
    procedure PutRoot; override;
    // Options processing
    procedure OptionsProcessing; override;
    // Events
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25,
      Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant); override;
    procedure DoOnBeforeDataTransfer; override;
    procedure DoOnAfterDataTransfer; override;
  public
    constructor Create(ACollection: TCollection); override;
    // Properties
    property DataSources: TxlExcelDataSources read GetDataSources;
    property Report: TxlExcelReport read GetReport;
    //
    property Range;
    property MasterSource: TxlExcelDataSource read GetMasterSource write SetMasterSource;
    property Options: TxlRangeOptionsSet read FOptions
      write SetOptions default [xrgoAutoOpen, xrgoPreserveRowHeight];
    // Used interfaces
    property IXLSApp: IxlApplication read FIXLSApp;
    property IWorkbooks: IxlWorkbooks read FIWorkbooks;
    property IWorkbook: IxlWorkbook read FIWorkbook;
    property INames: IxlNames read FINames;
    property IName: IxlName read FIName;
    property IWorksheets: IxlWorksheets read FIWorksheets;
    property IWorksheet: IxlWorksheet read FISheet;
    property ITempSheet: IxlWorksheet read FITempSheet;
    property IRange: IxlRange read FIRange;
  end;

{ TxlExcelDataSources collection class }

  TxlExcelDataSources = class(TxlAbstractDataSources)
  private
    function GetItem(Index: integer): TxlExcelDataSource;
    procedure SetItem(Index: integer; const Value: TxlExcelDataSource);
    function GetReport: TxlExcelReport;
  protected
  public
    function Add: TxlExcelDataSource;
    property Report: TxlExcelReport read GetReport;
    property Items[Index: integer]: TxlExcelDataSource read GetItem write SetItem; default;
  end;

{ TxlExcelReportParam }

  TxlExcelReportParam = class(TxlAbstractParameter)
  private
    function GetReport: TxlExcelReport;
  protected
    property Report: TxlExcelReport read GetReport;
  end;

{ TxlExcelReportParams }

  TxlExcelReportParams = class(TxlAbstractParameters)
  private
    function GetItem(Index: integer): TxlExcelReportParam;
    function GetReport: TxlExcelReport;
    procedure SetItem(Index: integer; const Value: TxlExcelReportParam);
  protected
    procedure Build; override;
  public
    function Add: TxlExcelReportParam;
    property Items[Index: integer]: TxlExcelReportParam read GetItem write SetItem; default;
    property Report: TxlExcelReport read GetReport;
  end;


{ TxlExcelReport class }

  TxlExcelReport = class(TxlAbstractReport)
  private
    FTemplateRow: integer;
    FNoRangeRow: integer;
    FActiveSheetName: string;
    FLastActiveSheetName: string;
    FTemplateFileName: string;
    FOptions: TxlReportOptionsSet;
    FTempPath: string;
    FDataMode: TxlDataExportMode;
    FOLEContainer: TOLEContainer;
    FPreview: boolean;
    FDebug: boolean;
    FMerged: boolean;
    FLastWorkbookName: string;
    FMSAlias: string;
    FMSField: string;
    FLastWindowState: TOLEEnum;
    FLastLeft, FLastTop: double;
    FMultisheetIndex: integer;
    FNewWorkbookName: string;
    FLastCalculation: TOLEEnum;
    FCanceled: boolean;
    // ReportTo2 support
    FReportTo2: boolean;
    FTargetExcelApp: OLEVariant;
    FTargetWorkbook: OLEVariant;
    // xldebug
    // FxlDebugLog: TObject;
    // used interfaces
    FIXLApp: IxlApplication;
    FIWorkbook: IxlWorkbook;
    FIWorkbooks: IxlWorkbooks;
    FINames: IxlNames;
    FIWorksheets: IxlWorksheets;
    FITempSheet: IxlWorksheet;
    FIMultiSheet: IxlWorksheet;
    FIWorksheetFunction: IxlWorksheetFunction;
    FIModule: IxlVBComponent;
    procedure SetOptions(const Value: TxlReportOptionsSet);
    procedure SetTempPath(const Value: string);
    procedure SetDataSources(const Value: TxlExcelDataSources);
    function GetDataSources: TxlExcelDataSources;
    function GetParams: TxlExcelReportParams;
    procedure SetParams(const Value: TxlExcelReportParams);
    function GetParamByName(Name: string): TxlExcelReportParam;
    procedure SetMSAlias(const Value: string);
  protected
    //
    function CreateParams: TxlAbstractParameters; override;
    //
    procedure Connect; override;
    procedure Disconnect; override;
    procedure BeforeBuild; override;
    procedure AfterBuild; override;
    procedure MacroProcessing(const MacroType: TxlMacroType; const MacroName: string); override;
    procedure Parse; override;
    procedure Show(HandleException: boolean); override;
    procedure OptionsProcessing; override;
    procedure ErrorProcessing(E: Exception; var Raised: boolean); override;
    procedure SaveInTempFile; virtual;
    procedure RefreshParams(const ClearParams: boolean); override;
    procedure CheckBreak; virtual;
    // events
    function DoOnBreak: boolean; virtual;
    procedure DoOnBeforeBuild; override;
    procedure DoOnAfterBuild; override;
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25,
      Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant); override;
    procedure DoOnProgress(const Position, Max: integer); override;
    {$IFDEF XLR_VCL}
    procedure DoOnProgress2(DataSource: TxlExcelDataSource; const RecordCount: integer); virtual;
    {$ENDIF}
    procedure DoOnBeforeWorkbookSave(var WorkbookFileName, WorkbookFilePath: string;
      Save: boolean); virtual;
    procedure DoOnTargetBookSheetName(ISourceSheet: IxlWorksheet; ITargetWorkbook: IxlWorkbook;
      var SheetName: string); virtual;
    //
    procedure MultisheetReport(const MultisheetDataSourceAlias, MultisheetFieldName: string); virtual;
    // properties
    property DataSources: TxlExcelDataSources read GetDataSources write SetDataSources;
    property ActiveSheet: string read FActiveSheetName write FActiveSheetName;
    property XLSTemplate: string read FTemplateFileName write FTemplateFileName;
    property TempPath: string read FTempPath write SetTempPath;
    property OLEContainer: TOLEContainer read FOLEContainer write FOLEContainer;
    property Preview: boolean read FPreview write FPreview;
    property MacroBefore;
    property MacroAfter;
    property Debug: boolean read FDebug write FDebug;
    property Params: TxlExcelReportParams read GetParams write SetParams;
    property ParamByName[Name: string]: TxlExcelReportParam read GetParamByName;
    property MultisheetAlias: string read FMSAlias write SetMSAlias;
    property MultisheetField: string read FMSField write FMSField;
    property Canceled: boolean read FCanceled write FCanceled;
  public
    constructor Create(AOwner: TComponent); override;
    // class methods
    class function GetOptionMap: TxlOptionMap; override;
    class procedure ReleaseExcelApplication;
    class procedure ConnectToExcelApplication(OLEObject: OLEVariant);
    //
    procedure Report; override;
    procedure ReportTo(const WorkbookName: string; const NewWorkbookName: string = ''); virtual;
    {$IFNDEF XLR_BCB}
    procedure Report(Workbook, ExcelApp: OLEVariant; const NewWorkbookName: string = ''); reintroduce; overload;
    class procedure MergeReports(Reports: array of TxlExcelReport; SheetPrefixes: array of string); virtual;
    {$ENDIF}
    property DataExportMode: TxlDataExportMode read FDataMode
      write FDataMode default xdmDDE;
    property Options: TxlReportOptionsSet read FOptions write SetOptions
      default [xroDisplayAlerts, xroAutoOpen];
    property MultySheetIndex: integer read FMultiSheetIndex;
    // used interfaces
    property IXLSApp: IxlApplication read FIXLApp;
    property IWorkbooks: IxlWorkbooks read FIWorkbooks;
    property IWorkbook: IxlWorkbook read FIWorkbook;
    property INames: IxlNames read FINames;
    property IWorksheets: IxlWorksheets read FIWorksheets;
    property ITempSheet: IxlWorksheet read FITempSheet;
    property IWorksheetFunction: IxlWorksheetFunction read FIWorksheetFunction;
    property IModule: IxlVBComponent read FIModule;
  end;

{ Global const, variables and public routines }

var
  xlrExcelVer: integer = 0;
  xlrLCID: integer = LOCALE_USER_DEFAULT;
  {$IFNDEF XLR_VCL}
  xlrTempPath: string;
  {$ENDIF}
  {$IFDEF XLR_DEBUG}
    xlrDebug: boolean = true;
  {$ELSE}
    xlrDebug: boolean = false;
  {$ENDIF XLR_DEBUG}
  xlrExcelHost: boolean = false;

{ Cells utils }

function A1(const Row, Column: integer): string;
function A1Abs(const Row, Column: integer): string;
function R1C1(const Row, Column: integer): string;
function R1C1OfRange(IRange: IxlRange): string;

{ XL Report internal consts, variables and routines }

const

{ Product platform/version }

{$IFDEF XLR_VCL}
  xlrProductName = 'XL Report.VCL';
  xlrVersionAddStr = 'build 121';
  xlrVersionBuild = 121;
  xlrHomeURL = 'www.xl-report.com';
  xlrOrderStr = 'XL Report Homepage: ';
  xlrOrderURL = 'http://www.xl-report.com';
  {$IFDEF XLR_BCB}
    {$IFDEF XLR_VCL4}
      xlrIDEVer = 'B4';
    {$ENDIF}
    {$IFDEF XLR_VCL5}
      xlrIDEVer = 'B5';
    {$ENDIF}
    {$IFDEF XLR_VCL6}
      xlrIDEVer = 'B6';
    {$ENDIF}
  {$ELSE}
    {$IFDEF XLR_VCL4}
      xlrIDEVer = 'D4';
    {$ENDIF}
    {$IFDEF XLR_VCL5}
      xlrIDEVer = 'D5';
    {$ENDIF}
    {$IFDEF XLR_VCL6}
      xlrIDEVer = 'D6';
    {$ENDIF}
    {$IFDEF XLR_VCL7}
      xlrIDEVer = 'D7';
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF XLR_AX}
  xlrProductName = 'Active XL Report';
  xlrVersionAddStr = 'build 121';
  xlrVersionBuild = 121;
  xlrHomeURL = 'www.activexlreport.com';
  xlrOrderStr = 'Active XL Report Homepage: ';
  xlrOrderURL = 'http://www.activexlreport.com';
  xlrIDEVer = 'AX';
{$ENDIF}

{$IFDEF XLR_NET}
  xlrProductName = 'XL Report.NET';
  xlrVersionAddStr = 'build 109';
  xlrVersionBuild = 109;
  xlrHomeURL = 'www.afalinasoft.com';
  xlrOrderStr = 'XL Report.NET Homepage: ';
  xlrOrderURL = 'http://www.afalinasoft.com';
  xlrIDEVer = 'NWRP';
{$ENDIF}

{$IFDEF XLR_MSP}
  xlrProductName = 'XL Report - MS Project Edition';
  xlrVersionAddStr = 'build 105';
  xlrVersionBuild = 105;
  xlrHomeURL = 'www.afalinasoft.com';
  xlrOrderStr = 'XL Report Homepage: ';
  xlrOrderURL = 'http://www.afalinasoft.com';
  xlrIDEVer = 'MSP';
{$ENDIF}

{ Product licence }

{$IFDEF XLR_TRIAL}
  xlrProductID = ', Trial';
{$ENDIF XLR_TRIAL}

{$IFDEF XLR_STD}
  xlrProductID = ', Standard';
{$ENDIF XLR_STD}

{$IFDEF XLR_PRO}
  xlrProductID = ', Professional';
{$ENDIF XLR_PRO}

{$IFDEF XLR_DEV}
  xlrProductID = ', Developer';
{$ENDIF XLR_DEV}

  xlrVersionHi = 4;
  xlrVersionLo = 2;

{ XLDataSet flags }
  xlrMultisheet: DWORD = $0001;
  xlrSetFilter: DWORD = $0002;

  xlrModuleName = 'XLR_Module';
  vbCR = #13;

{ Limits }
  xlrRangeMinRowsCount = 2;
  xlrRangeMinColumnsCount = 2;
  xlrMaxVarRowCount = 256;
  xlrMaxCSVRowCount = 32;
  xlrVarMaxStrLen = 1500;
  xlrDDEMaxStrLen = 255;
  xlrCSVMaxStrLen = 4096;

var
  xlrLocaleR: string = 'R';
  xlrLocaleC: string = 'C';

function xlrVersionStr: string;
procedure BeforeRunMacro(IXLApp: IxlApplication; const Hidden: boolean);

implementation

{$IFDEF XLR_VCL}
  uses xlReport;
{$ENDIF}

{$IFDEF XLR_AX}
  {$IFDEF XLR_TRIAL}
    uses  xlProOPack;
  {$ENDIF XLR}
  {$IFDEF XLR_PRO}
    uses  xlProOPack;
  {$ENDIF}
  {$IFDEF XLR_DEV}
    uses  xlProOPack;
  {$ENDIF}
{$ENDIF}

{$IFDEF XLR_NET}
  {$IFDEF XLR_TRIAL}
    uses  xlProOPack;
  {$ENDIF XLR}
  {$IFDEF XLR_PRO}
    uses  xlProOPack;
  {$ENDIF}
{$ENDIF XLR_VCL}

{$IFDEF XLR_MSP}
  {$IFDEF XLR_TRIAL}
    uses  xlProOPack;
  {$ENDIF XLR}
  {$IFDEF XLR_PRO}
    uses  xlProOPack;
  {$ENDIF}
{$ENDIF XLR_VCL}

{$R xlReport.res}
{$R xlReportG2.res}

const
  xlrTempFileSign = ' xlrtmp ';
  xlrFileExtention = '*.xls';
  // Reserved names
  xlrTempSheetName = 'XLR_NoRangeSheet';
  xlrMultisheetCellName = 'MULTISHEETCELL';
  xlrParam = 'XLRPARAMS';
  lexXLRVersion = 'XLR_VERSION';
  lexXLRErrValueStr = 'XLR_ERRNAMESTR';
  // Common options
  lexOnlyValues = 'ONLYVALUES';
  lexAutoSafe = 'AUTOSAFE';
  lexRowsFit = 'ROWSFIT';
  lexColsFit = 'COLSFIT';
  // Report options
  lexShowPivotBar = 'SHOWPIVOTBAR';
  // Sheet options
  lexMultisheet = 'MULTISHEET';
  lexSheetHide = 'SHEETHIDE';
  lexSheetHide2 = 'HIDE';
  lexAutoScale = 'AUTOSCALE';
  // Range options
  lexGroupNoSort = 'GROUPNOSORT';
  lexAutoFilter = 'AUTOFILTER';
  lexPivot = 'PIVOT';
  lexPivotName = 'NAME';
  lexPivotDestination = 'DST';
  lexPivotDataToRows = 'DATATOROWS';
  lexPivotRowGrand = 'ROWGRAND';
  lexPivotColumnGrand = 'COLUMNGRAND';
  lexPivotNotSaveData = 'NOTSAVEDATA';
  // Column options
  lexCollapse = 'COLLAPSE';
  lexPivotHidden = 'HIDDEN';
  lexPivotPage = 'PAGE';
  lexPivotRow = 'ROW';
  lexPivotColumn = 'COLUMN';
  lexPivotData = 'DATA';
  lexGroup = 'GROUP';
  lexSort = 'SORT';
  lexDesc = 'DESC';
  lexAsc = 'ASC';
  // Subtotal functions
  lexManual = 'NOTOTALS';
  lexSum = 'SUM';
  lexAVG = 'AVG';
  lexCount = 'COUNT';
  lexCountNums = 'COUNTNUMS';
  lexMax = 'MAX';
  lexMin = 'MIN';
  lexProduct = 'PRODUCT';
  lexStDev = 'STDEV';
  lexStDevP = 'STDEVP';
  lexVar = 'VAR';
  lexVarP = 'VARP';
  lexSumIf = 'SUMIF';

  // Option cells
  xlrReportOptionsRow = 1;
  xlrReportOptionsColumn = 1;
  xlrSheetOptionsRow = 2;
  xlrSheetOptionsColumn = 1;

  // Other consts
  xlrProgID = 'Excel.Application';
  xlrParamsRow = 2;
  xlrStartNoRangeRow = 5;
  xlrTemplateRowsStart = 30000;
  xlrMaxColCount = 255;
  xlrMaxRowCount = 65000;
  xlrMaxSelectionRowCount = 2048;
  xlrWorksheetNameLength = 31;

  xlrVBAMergeWorkbooks = 'xlrMergeWorkbooks';
  xlrVBAMergeModule =
    'Public Sub xlrMergeWorkbooks(Wbks As Variant, Prefixes As Variant)' + vbCR +
    '  Dim TargetBook As Workbook, Wbk As Workbook' + vbCR +
    '  Dim Sheet As Worksheet' + vbCR +
    '  Dim WbkCount As Integer, i As Integer' + vbCR +
    '  Application.DisplayAlerts = False' + vbCR +
    '  Application.ScreenUpdating = False' + vbCR +
    '  WbkCount = UBound(Wbks)' + vbCR +
    '  Set TargetBook = Workbooks(Wbks(1))' + vbCR +
    '  For i = 1 To WbkCount' + vbCR +
    '    Set Wbk = Workbooks(Wbks(i))' + vbCR +
    '    For Each Sheet In Wbk.Worksheets' + vbCR +
    '      If Sheet.Visible = xlSheetVisible Then' + vbCR +
    '        Sheet.UsedRange.Copy' + vbCR +
    '        Sheet.UsedRange.PasteSpecial xlPasteValues, xlPasteSpecialOperationNone' + vbCR +
    '        Application.Goto Sheet.Cells(1, 1)' + vbCR +
    '        If Prefixes(i) <> "" Then' + vbCR +
    '          Sheet.Name = Prefixes(i) & " - " & Sheet.Name' + vbCR +
    '        Else' + vbCR +
    '          REM Sheet.Name = Wbk.Name & " - " & Sheet.Name' + vbCR +
    '        End If' + vbCR +
    '        If i <> 1 Then' + vbCR +
    '          Sheet.Copy TargetBook.Worksheets(TargetBook.Worksheets.Count)' + vbCR +
    '        End If' + vbCR +
    '      End If' + vbCR +
    '    Next' + vbCR +
    '  Next' + vbCR +
    '  For i = 2 To WbkCount' + vbCR +
    '    Workbooks(Wbks(i)).Close SaveChanges:=False' + vbCR +
    '  Next' + vbCR +
    '  Application.ScreenUpdating = True' + vbCR +
    '  Application.Goto TargetBook.Worksheets(1).Cells(1, 1)' + vbCR +
    'End Sub' + vbCR;

  xlrVBAReportOptionsSubName = 'xlrReportOptions';
  xlrVBAApplyFormatsSubName = 'xlrApplyFormats';
  xlrVBADeleteSpecialRowsSubName = 'xlrDeleteSpecialRows';
  xlrVBAGotoA1 = 'xlrGotoA1';
  xlrVBAModuleLevel =
    'Rem XL Report VBA Code' + vbCR +
    'OPTION BASE 1';
  xlrVBAProcs =
    'Public Function xlrRowsHeight(RangeName As Variant) as Variant' + vbCR +
    '  Dim R As Range, i As Integer' + vbCR +
    '  Dim RowsHeight() As Variant' + vbCR +
    '  Set R = Range(RangeName)' + vbCR +
    '  ReDim RowsHeight(R.Rows.Count)' + vbCR +
    '  For i = 1 To R.Rows.Count' + vbCR +
    '    RowsHeight(i) = R.Rows(i).RowHeight' + vbCR+
    '  Next' + vbCR +
    '  xlrRowsHeight = RowsHeight' + vbCR +
    'End Function' + vbCR +

    'Public Function xlrReplace(str1 As String, str2 As String, str3 As String) As String' + vbCR +
    '  Dim Result As String, Pos As Long, Length As Long' + vbCR +
    '  Result = str1' + vbCR +
    '  Pos = InStr(Result, str2)' + vbCR +
    '  If Pos > 0 Then' + vbCR +
    '    Length = Len(str2)' + vbCR +
    '    Result = Left(Result, Pos - 1)' + vbCR +
    '    Result = Result & str3' + vbCR +
    '    Result = Result & Right(str1, Len(str1) - Pos - Length + 1)' + vbCR +
    '  End If' + vbCR +
    '  xlrReplace = Result' + vbCR +
    'End Function' + vbCR +

    'Sub xlrCopyFormats(UnMerged As Range, Merged As Range, C As Range)' + vbCR +
    '  UnMerged.Copy' + vbCR +
    '  C.PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True, False' + vbCR +
    '  Merged.Copy' + vbCR +
    '  C.PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone, False, False' + vbCR +
    'End Sub' +  vbCR +

    'Public Sub xlrCopyFormats2(UnMerged As Range, Merged As Range, C As Range)' +  vbCR +
    '  Dim CurrentRange As Range' +  vbCR +
    '  Dim i As Long, j As Long, StartRow As Long, EndRow As Long' +  vbCR +
    '  Dim RowCount As Long, EstRowCount As Long, RowsOnRec As Long, MaxSelectedRows As Long' +  vbCR +
    '  i = 0' +  vbCR +
    '  j = 0' +  vbCR +
    '  RowCount = C.Rows.Count' +  vbCR +
    '  RowsOnRec = UnMerged.Rows.Count' +  vbCR +
    '  MaxSelectedRows = (1024 \ RowsOnRec) * RowsOnRec' +  vbCR +
    '  EstRowCount = RowCount' +  vbCR +
    '  While i < (EstRowCount)' +  vbCR +
    '    StartRow = j * MaxSelectedRows + 1' +  vbCR +
    '    If StartRow > (EstRowCount) Then StartRow = EstRowCount' +  vbCR +
    '    EndRow = StartRow + MaxSelectedRows - 1' +  vbCR +
    '    If EndRow > (EstRowCount) Then EndRow = EstRowCount' +  vbCR +
    '    Set CurrentRange = C.Parent.Range(C.Rows(StartRow), C.Rows(EndRow))' +  vbCR +
    '    UnMerged.Copy' +  vbCR +
    '    CurrentRange.PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True, False' +  vbCR +
    '    Merged.Copy' +  vbCR +
    '    CurrentRange.PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone, False, False' +  vbCR +
    '    j = j + 1' +  vbCR +
    '    i = EndRow' +  vbCR +
    '  Wend' +  vbCR +
    'End Sub' +  vbCR +

    'Public Sub xlrApplyFormats(MergedAddr As String, UnMergedAddr As String, DstAddr As String, Rows, Heights, SpRowDelete, PreserveHeight)' + vbCR +
    '  Dim Merged As Range, UnMerged As Range, Dst As Range, C As Range, C1 As Range, V As Variant' + vbCR +
    '  Dim DstRow As Long, CurrRow As Long' + vbCR +
    '  Dim DstRowCount As Long, RowCount As Long, i As Long' + vbCR +
    '  Set Dst = Range(DstAddr)' + vbCR +
    '  Set Merged = Range(MergedAddr)' + vbCR +
    '  Set UnMerged = Range(UnMergedAddr)' + vbCR +
    '  If IsArray(Rows) Then' + vbCR +
    '    DstRowCount = UBound(Rows)' + vbCR +
    '    If DstRowCount = 1 Then' + vbCR +
    '      V = Rows(1)' + vbCR +
    '      Set Merged = Merged.Parent.Range(Merged.Rows(1), Merged.Rows(V(3)))' + vbCR +
    '      Set UnMerged = UnMerged.Parent.Range(UnMerged.Rows(1), UnMerged.Rows(V(3)))' + vbCR +
    '      Set C = Dst.Rows(V(1))' + vbCR +
    '      Set C1 = Dst.Rows(V(2))' + vbCR +
    '      Set C = Dst.Parent.Range(C, C1)' + vbCR +
    '      Dst.Rows(1).Delete xlShiftUp' + vbCR +
    '      If SpRowDelete = True Then Dst.Rows(Dst.Rows.Count).Delete xlShiftUp' + vbCR +
    '      xlrCopyFormats2 UnMerged, Merged, C' + vbCR +
    '      If PreserveHeight = True Then' + vbCR +
    '        For i = 1 To V(2) - 1 Step V(3)' + vbCR +
    '          For DstRow = 1 to V(3)' + vbCR +
    '            C.Rows(i + DstRow - 1).RowHeight = Heights(DstRow)' + vbCR +
    '          Next' + vbCR +
    '        Next' + vbCR +
    '      End If' + vbCR +
    '    Else' + vbCR +
    '      Dst.Rows(1).Delete xlShiftUp' + vbCR +
    '      Dst.Rows(Dst.Rows.Count).Delete xlShiftUp' + vbCR +
    '      For DstRow = 1 To DstRowCount' + vbCR +
    '        V = Rows(DstRow)' + vbCR +
    '        RowCount = UBound(V) - 1' + vbCR +
    '        i = 0' + vbCR +
    '        For CurrRow = 1 To RowCount' + vbCR +
    '          If i = 0 Then' + vbCR +
    '            Set C = Dst.Rows(V(CurrRow))' + vbCR +
    '            i = i + 1' + vbCR +
    '          Else' + vbCR +
    '            Set C1 = Dst.Rows(V(CurrRow))' + vbCR +
    '            Set C = Union(C, C1)' + vbCR +
    '            i = i + 1' + vbCR +
    '          End If' + vbCR +
    '          If i >= 1024 Then' + vbCR +
    '            xlrCopyFormats UnMerged.Rows(DstRow), Merged.Rows(DstRow), C' + vbCR +
    '            If PreserveHeight = True Then C.RowHeight = Heights(DstRow)' + vbCR +
    '            i = 0' + vbCR +
    '          End If' + vbCR +
    '        Next' + vbCR +
    '        If i > 0 Then' + vbCR +
    '          xlrCopyFormats UnMerged.Rows(DstRow), Merged.Rows(DstRow), C' + vbCR +
    '          If PreserveHeight = True Then C.RowHeight = Heights(DstRow)' + vbCR +
    '        End If' + vbCR +
    '      Next' + vbCR +
    '    End If' + vbCR +
    '  End If' + vbCR +
    'End Sub' + vbCR +

    'Public Sub xlrDeleteSpecialRows(RootRangeName As String, SpecialRows As Variant)' + vbCR +
    '  Dim Root As range, SpRow As range' + vbCR +
    '  Dim i As Long, Count As Long, Offset As Long' + vbCR +
    '  Count = UBound(SpecialRows)' + vbCR +
    '  Set Root = range(RootRangeName)' + vbCR +
    '  Offset = 0' + vbCR +
    '  For i = 1 To Count' + vbCR +
    '    Set SpRow = Root.Rows(SpecialRows(i) - Offset)' + vbCR +
    '    SpRow.Delete xlShiftUp' + vbCR +
    '    Offset = Offset + 1' + vbCR +
    '  Next' + vbCR +
    'End Sub' + vbCR +

    'Public Sub xlrGetRanges(Args As Variant, ByRef Ranges As Variant)' + vbCR +
    '  Dim V As Variant, Level As Long, IndexOfLevel As Long' + vbCR +
    '  V = Args(4)' + vbCR +
    '  Level = V(1)' + vbCR +
    '  IndexOfLevel = V(2)' + vbCR +
    '  Ranges = Args(3)' + vbCR +
    '  Ranges = Ranges(Level + 1)' + vbCR +
    '  Ranges = Ranges(IndexOfLevel + 1)' + vbCR +
    'End Sub' + vbCR +

    'Public Sub xlrGotoA1()' + vbCR +
    '  Dim Sheet As Worksheet' + vbCR +
    '  On Error Resume Next' + vbCR +
    '  For Each Sheet In Worksheets' + vbCR +
    '    If Sheet.Visible = xlSheetVisible Then' + vbCR +
    '      Application.Goto Sheet.Cells(1, 1), True' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    'End Sub' + vbCR +

    'Public Function xlrPutNoRangeData(ADebug As Variant, StartRow As Variant, ABuff As Variant, AAddrs As Variant, ANames As Variant, Alias As String) As Object' + vbCR +
    '  Dim ColCount As Integer, RowCount As Integer, Col As Integer, Row As Integer, i As Integer' + vbCR +
    '  Dim Sheet As Worksheet, Ns As Names, N As Name, s As String' + vbCR +
    '  Dim LastCell As Integer' + vbCR +
    '  Set Sheet = Worksheets("' + xlrTempSheetName + '")' + vbCR +
    '  Set Ns = Sheet.Parent.Names' + vbCR +
    '  ColCount = UBound(ABuff)' + vbCR +
    '  RowCount = ColCount \ 250 + 1' + vbCR +
    '  LastCell = IIf(RowCount = 1, ColCount, 250)' + vbCr +
    '  Row = StartRow' + vbCR +
    '  For i = 1 To ColCount' + vbCR +
    '    If (i Mod 250) = 1 Then' + vbCR +
    '      If i <> 1 Then Row = Row + 1' + vbCR +
    '      Sheet.Cells(Row, 1).Value = Alias' + vbCR +
    '      if i <> 1 Then Col = 2 Else Col = 1' + vbCR +
    '    End If' + vbCR +
    '    If (ANames(i) <> "") and ((i <> 1) or (ANames(i) = "XLRPARAMS")) Then' + vbCR +
    '      Set N = Ns.Add(Name:=ANames(i), RefersTo:=AAddrs(i), Visible:=ADebug)' + vbCR +
    '      If VarType(ABuff(i)) = vbString Then' + vbCR +
    '        s = ABuff(i)' + vbCR +
    '        Sheet.Cells(Row, Col).NumberFormat = "@"' + vbCR +
    '        Sheet.Cells(Row, Col).Value = s' + vbCR +
    '      Else' + vbCR +
    '        Sheet.Cells(Row, Col).Value = ABuff(i)' + vbCR +
    '      End If' + vbCR +
    '    End If' + vbCR +
    '    Col = Col + 1' + vbCR +
    '  Next' + vbCR +
    // Comment for MS Excel interface marshaling bug
    // '  Set xlrPutNoRangeData = Sheet.Range(Sheet.Cells(StartRow, 1), Sheet.Cells(Row, 250))' + vbCR +
    'End Function' + vbCR +

    'Public Sub xlrPrepareMultisheet(Index As String, Aliases)' + vbCR +
    '  Dim s As Worksheet, r As Range, row As Integer, col As Integer' + vbCR +
    '  Dim c As Range, t As String, f As String, i As Integer' + vbCR +
    '  Set s = Worksheets(Worksheets.Count - 1)' + vbCR +
    '  Set r = s.UsedRange' + vbCR +
    '  For row = 1 To r.Rows.Count' + vbCR +
    '    For col = 1 To r.Columns.Count' + vbCR +
    '      Set c = r.Cells(row, col)' + vbCR +
    '      f = UCase(c.FormulaLocal)' + vbCR +
    '      For i = 1 To UBound(Aliases) - 1' + vbCR +
    '        If InStr(1, f, "" & UCase(Aliases(i)) & "_") > 0 Then' + vbCR +
    '          c.FormulaLocal = xlrReplace(f, "" & UCase(Aliases(i)) & "_", "" & Aliases(i) & "_" & Index & "_")' + vbCR +
    '        End If' + vbCR +
    '      Next' + vbCR +
    '      If InStr(1, f, "XLRPARAMS_") > 0 Then' + vbCR +
    '          c.FormulaLocal = xlrReplace(UCase(c.FormulaLocal), "XLRPARAMS_", "XLRPARAMS_" & Index & "_")' + vbCR +
    '      End If' + vbCR +
    '    Next' + vbCR +
    '  Next' + vbCR +
    'End Sub' + vbCR +

    'Public Sub xlrDeleteNoRangeLinks(Aliases)' + vbCR +
    '  Dim s As Worksheet, r As Range, row As Long, col As Long' + vbCR +
    '  Dim c As Range, t As String, f As String, i As Long, j As Long' + vbCR +
    '  For j = 1 To Worksheets.Count' + vbCR +
    '    Set s = Worksheets(j)' + vbCR +
    '    If s.Visible = xlSheetVisible Then' + vbCR +
    '      Set r = s.UsedRange' + vbCR +
    '      For row = 1 To r.Rows.Count' + vbCR +
    '        For col = 1 To r.Columns.Count' + vbCR +
    '          Set c = r.Cells(row, col)' + vbCR +
    '          f = c.FormulaLocal' + vbCR +
    '          If InStr(1, UCase(f), "XLRPARAMS_") > 0 Then' + vbCR +
    '            c.Formula = c.Formula' + vbCR +
    '            c.Value = c.Value' + vbCR +
    '          Else' + vbCR +
    '            For i = 1 To UBound(Aliases)' + vbCR +
    '              If InStr(1, UCase(f), UCase(Aliases(i)) + "_") > 0 Then' + vbCR +
    '                c.Formula = c.Formula' + vbCR +
    '                c.Value = c.Value' + vbCR +
    '              End If' + vbCR +
    '            Next' + vbCR +
    '          End If' + vbCR +
    '        Next' + vbCR +
    '      Next' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    'End Sub' + vbCR +

    'Public Sub xlrDeleteNames(AWS)' + vbCR +
    '  Dim i As Integer, N As Name, s as String' + vbCR +
    // ReportTo2 support
    '  If AWS = "REPORTTO2" Then' + vbCR +
    '    For i = ThisWorkbook.Names.Count to 1 step -1' + vbCR +
    '      Set N = ThisWorkbook.Names(i)' + vbCR +
    '      s = N.RefersToLocal' + vbCR +
    '      If InStr(s, "!") = 0 Then' + vbCR +
    '        If N.Visible Then N.Delete' + vbCR +
    '      End If' + vbCR +
    '    Next' + vbCR +
    '  Else' + vbCR +
    '    If AWS = "" Then' + vbCR +
    '      For i = ThisWorkbook.Names.Count to 1 step -1' + vbCR +
    '        Set N = ThisWorkbook.Names(i)' + vbCR +
    '        If N.Visible Then N.Delete' + vbCR +
    '      Next' + vbCR +
    '    Else' + vbCR +
    '      For i = ThisWorkbook.Names.Count to 1 step -1' + vbCR +
    '        Set N = ThisWorkbook.Names(i)' + vbCR +
    '        s = N.RefersToLocal' + vbCR +
    '        If InStr(s, AWS) > 0 Then' + vbCR +
    '          If N.Visible Then N.Delete' + vbCR +
    '        End If' + vbCR +
    '      Next' + vbCR +
    '    End If' + vbCR +
    '  End If' + vbCR +
    'End Sub' + vbCR +

    'Public Function xlrGetNameOfAlias(AName As Variant) as Variant' + vbCR +
    '  Dim i As Integer, N As Name' + vbCR +
    '  xlrGetNameOfAlias = ""' + vbCR +
    '  For i = Names.Count to 1 step -1' + vbCR +
    '    Set N = Names(i)' + vbCR +
    '    If UCase(N.Name) = AName Then' + vbCR +
    '      xlrGetNameOfAlias = N.RefersToRange.Value' + vbCR +
    '      N.RefersToRange.Value = ""' + vbCR +
    '      N.Delete' + vbCR +
    '      Exit For' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    'End Function' + vbCR +

    'Public Function xlrGetModuleOfName(AName As Variant) as Variant' + vbCR +
    '  Dim i As Integer, N' + vbCR +
    '  xlrGetModuleOfName = ""' + vbCR +
    '  For i = ThisWorkbook.VBProject.VBComponents.Count to 1 step -1' + vbCR +
    '    Set N = ThisWorkbook.VBProject.VBComponents(i)' + vbCR +
    '    If UCase(N.Name) = AName Then' + vbCR +
    '      xlrGetModuleOfName = AName' + vbCR +
    '      Exit For' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    'End Function';

    // ReportTo2 support: fix Sheets.Copy MS bug
    {
    'Public Sub xlrDeleteNameDuplicates(AWbk)' + vbCR +
    '  Dim i As Long, j As Long, n As Long' + vbCR +
    '  Dim WName As Name' + vbCR +
    '  Dim s As String' + vbCR +
    '  Dim Wbk As Workbook' + vbCR +
    '  Set Wbk = Workbooks(AWbk)' + vbCR +
    '  On Error Resume Next' + vbCR +
    '  For i = 1 To Wbk.Names.Count' + vbCR +
    '    Set WName = Wbk.Names(i)' + vbCR +
    '    s = WName.RefersToLocal' + vbCR +
    '    If InStr(s, "]") > 0 Then' + vbCR +
    '      WName.Name = WName.Name & "__MSBUG"' + vbCR +
    '      Rem WName.Visible = False' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    '  For i = 1 To Wbk.Names.Count' + vbCR +
    '    Set WName = Wbk.Names(i)' + vbCR +
    '    s = WName.RefersToLocal' + vbCR +
    '    If InStr(s, "]") > 0 Then' + vbCR +
    '      WName.RefersToLocal = "=" & Right(s, Len(s) - InStr(s, "]"))' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    'End Sub';
    }

var
  xlrOptionMap: TxlOptionMap;

{ Global OptionsMap }

function xlrVersionStr: string;
begin
  if xlrVersionAddStr <> '' then
    Result := IntToStr(xlrVersionHi) + '.' + IntToStr(xlrVersionLo) + xlrProductID +
      '  (' + xlrVersionAddStr + '-' + xlrIDEVer + ')'
  else
    Result := IntToStr(xlrVersionHi) + '.' + IntToStr(xlrVersionLo) + xlrProductID;
end;

{ File utils }

procedure DeleteFiles(const Path, FileMask, Specifier: string);
var
  i: integer;
  FileRec: TSearchRec;
  s: string;
begin
  s := Path;
  if trim(s) = '' then begin
    s := ExtractFilePath(ParamStr(0));
  end;
  if s[Length(s)] <> '\' then
    s := s + '\';
  i := SysUtils.FindFirst(s + FileMask, faAnyFile, FileRec);
  while i = 0 do begin
    if Trim(Specifier) <> '' then begin
      if Pos(Specifier, FileRec.Name) <> 0 then
        SysUtils.DeleteFile(PChar(s + FileRec.Name))
    end;
    i := SysUtils.FindNext(FileRec);
  end;
  SysUtils.FindClose(FileRec);
end;

function GetFullFileName(const FileName, DefaultPath: string; const Verify: boolean): string;
begin
  Result := FileName;
  if Pos('\\', Result) = 1 then
    Result := ExpandUNCFileName(Result)
  else
    if (Pos('..\', Result) = 1) or (Pos('.\', Result) = 1) or (Pos('\', Result) <> 0) then
      Result := ExpandFileName(Result)
    else
      if DefaultPath <> '' then
        if DefaultPath[Length(DefaultPath)] = '\' then
          Result := DefaultPath + FileName
        else
          Result := DefaultPath + '\' + FileName;
  if Verify then
    if not FileExists(Result) then
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecFileNotFound, ecFileNotFound, [FileName]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecFileNotFound, [FileName]);
      {$ENDIF}
end;

{ Copy to clipboard }

function WideStringToClipboard(WStr: WideString): THandle;
var
  DataPtr: Pointer;
  Size: integer;
begin
  Result := 0;
  if WStr <> '' then begin
    Size := Length(WStr) * SizeOf(WideChar);
    Result := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE + GMEM_ZEROINIT, Size + SizeOf(WideChar));
    try
      DataPtr := GlobalLock(Result);
      try
        Move(PWideChar(WStr)^, DataPtr^, Size);
      finally
        GlobalUnlock(Result);
      end;
      Clipboard.SetAsHandle(CF_UNICODETEXT, Result);
    except
      GlobalFree(Result);
    end;
  end;
end;

{ Cells utils }

function CellA1Str(ColumnModifier: string; Column: integer; RowModifier: string; Row: integer): string;
begin
  Result := '';
  if Column > 26 then Result := Char(ord('A') + (Column - 1) div 26 - 1);
  Result := ColumnModifier + Result + Char(ord('A') +(Column-1) mod 26) +
    RowModifier + IntToStr(Row);
end;

function A1(const Row, Column: integer): string;
begin
  Result := CellA1Str('', Column, '', Row);
end;

function A1Abs(const Row, Column: integer): string;
begin
  Result := CellA1Str('$', Column, '$', Row);
end;

function R1C1(const Row, Column: integer): string;
begin
  Result := xlrLocaleR + IntToStr(Row) + xlrLocaleC + IntToStr(Column);
end;

function R1C1OfRange(IRange: IxlRange): string;
begin
  Result := IRange.AddressLocal[true, true, TOLEEnum(xlR1C1), false, false];
end;

{ Range utils }

procedure ClearRangeContents(IRange: IxlRange);
var
  R: IxlRange;
begin
  if IRange.MergeCells then begin
    R := IRange.MergeArea;
    R.UnMerge;
    IRange.ClearContents;
    R.Merge(false);
    R.ClearContents;
  end
  else
    IRange.ClearContents;
end;

function InsertBlankRows(const StartRow, RowCount, ColCount: integer; IBlankSheet: IxlWorksheet; IRange: IxlRange): IxlRange;
begin
  IBlankSheet.Range[A1(xlrMaxRowCount - RowCount + 1, 1), A1(xlrMaxRowCount, ColCount) ].Copy(EmptyParam);
  IRange.Rows.Item[StartRow, EmptyParam].Insert(TOLEEnum(xlShiftDown));
  Result := IRange.Range[A1(StartRow, 1), A1(StartRow + RowCount - 1, ColCount)];
end;

function InsertBlankRows2(const StartRow, RowCount, ColCount: integer; IBlankSheet: IxlWorksheet; IRange, IUnMerged: IxlRange): IxlRange;
begin
  Result := InsertBlankRows(StartRow, RowCount, ColCount, IBlankSheet, IRange);
  IUnMerged.Copy(EmptyParam);
  Result.PasteSpecial(TOLEEnum(xlPasteFormats), TOLEEnum(xlPasteSpecialOperationNone), False, False);
end;

procedure BeforeRunMacro(IXLApp: IxlApplication; const Hidden: boolean);
begin
  if (not Hidden) and (not xlrExcelHost) then
    {$IFDEF XLR_BCB}
    IXLApp.Visible := true;
    {$ELSE}
    IXLApp.Visible[xlrLCID] := true;
    {$ENDIF}
end;

procedure VBACopyFormats(Source: TxlExcelDataSource;
  Rows, Heights, SpRowDelete, PreserveHeight: OLEVariant; Hidden: boolean);
var
  DstAddr, MergedAddr, UnMergedAddr, s: string;
begin
  DstAddr := Source.IRange.Address[true, true, TOLEEnum(xlA1), true, EmptyParam];
  MergedAddr := Source.FIMergedRows.Address[true, true, TOLEEnum(xlA1), true, EmptyParam];
  UnMergedAddr := Source.FIUnMergedRows.Address[true, true, TOLEEnum(xlA1), true, EmptyParam];
  BeforeRunMacro(Source.IXLSApp, Hidden);
  s := '''' + Source.Report.IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + xlrVBAApplyFormatsSubName;
  try
    OLEVariant(Source.IXLSApp).Run(s,
      MergedAddr, UnMergedAddr, DstAddr, Rows, Heights, SpRowDelete, PreserveHeight);
  except
    {$IFDEF XLR_AX}
    raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
    {$ENDIF}
  end;
end;

{ Excel utils }

procedure ShowExcel(IXLApp: IxlApplication; Contained, SetPos: boolean; LastWinState: TOLEEnum; Left, Top: double);
begin
  {$IFDEF XLR_BCB}
  if _Assigned(IXLApp) then begin
    IXLApp.Interactive := true;
    if not xlrExcelHost then begin
      if SetPos then begin
        if IXLApp.WindowState <> TOLEEnum(xlMaximized) then begin
          IXLApp.Left := Left;
          IXLApp.Top := Top;
        end;
        IXLApp.WindowState := LastWinState;
      end;
      if not Contained then begin
        IXLApp.Visible := true;
        if LastWinState = TOLEEnum(xlMinimized) then
          IXLApp.WindowState := TOLEEnum(xlNormal);
      end;
    end;
    IXLApp.ScreenUpdating := true;
    if not Contained then
      IXLApp.DisplayAlerts := true;
  end;
  {$ELSE}
  if _Assigned(IXLApp) then begin
    IXLApp.Interactive[xlrLCID] := true;
    if not xlrExcelHost then begin
      if SetPos then begin
        if IXLApp.WindowState[xlrLCID] <> TOLEEnum(xlMaximized) then begin
          IXLApp.Left[xlrLCID] := Left;
          IXLApp.Top[xlrLCID] := Top;
        end;
        IXLApp.WindowState[xlrLCID] := LastWinState;
      end;
      if not Contained then begin
        IXLApp.Visible[xlrLCID] := true;
        if LastWinState = TOLEEnum(xlMinimized) then
          IXLApp.WindowState[xlrLCID] := TOLEEnum(xlNormal);
      end;
    end
    else
      IXLApp.Visible[xlrLCID] := true;
    IXLApp.ScreenUpdating[xlrLCID] := true;
    if not Contained then
      IXLApp.DisplayAlerts[xlrLCID] := true;
  end;
  {$ENDIF}
end;

function ConnectToExcelApp(NewInstance: boolean): IxlApplication;
begin
  _Clear(Result);
  if not NewInstance then
    {$IFDEF XLR_BCB}
    Result := _GetActiveOLEObject(xlrProgID);
    {$ELSE}
    Result := _GetActiveOLEObject(xlrProgID) as IxlApplication;
    {$ENDIF}
  if not _Assigned(Result) then
    {$IFDEF XLR_BCB}
    Result := _CreateOLEObject(xlrProgID);
    {$ELSE}
    Result := _CreateOLEObject(xlrProgID) as IxlApplication;
    {$ENDIF}
end;

{ Localization }

procedure GetExcelLocaleSettings(IApp: IxlApplication);
var
  A1ToR1C1: string;
  s: string;
begin
  xlrLCID := LOCALE_USER_DEFAULT;
  {$IFDEF XLR_BCB}
  A1ToR1C1 := IApp.ConvertFormula('A1', TOLEEnum(xlA1), TOLEEnum(xlR1C1),
    TOLEEnum(xlAbsolute), EmptyParam);
  xlrLocaleR := copy(A1ToR1C1, 1, 1);
  xlrLocaleC := copy(A1ToR1C1, 3, 1);
  if IApp.IgnoreRemoteRequests then
    IApp.IgnoreRemoteRequests := false;
  s := IApp.Version;
  {$ELSE}
  A1ToR1C1 := IApp.ConvertFormula('A1', TOLEEnum(xlA1), TOLEEnum(xlR1C1),
    TOLEEnum(xlAbsolute), EmptyParam, xlrLCID);
  xlrLocaleR := copy(A1ToR1C1, 1, 1);
  xlrLocaleC := copy(A1ToR1C1, 3, 1);
  if IApp.IgnoreRemoteRequests[xlrLCID] then
    IApp.IgnoreRemoteRequests[xlrLCID] := false;
  s := IApp.Version[xlrLCID];
  {$ENDIF}
  s := CutSubstring('.', s);
  xlrExcelVer := StrToInt(s);
end;

{$IFDEF XLR_TRIAL}
{$I xlDoRestrict1.inc}
{$ENDIF XLR_TRIAL}

{ Excel DDE Client - Fast Table Format (xlTable) support                         }
{      DDE not supported field types:                                            }
{        ftBytes, ftVarBytes, ftBlob, ftTypedBinary, ftGraphic, ftParadoxOle,    }
{        ftDBaseOle, ftCursor, ftADT, ftArray, ftReference, ftDataSet,           }
{        ftOraBlob, ftOraClob, ftInterface, ftIDispatch, ftGuid                  }
{      length(strings) <= 255                                                    }

type

  TxlDDEClient = class(TDDEClientConv)
  private
    FStream: TMemoryStream;
  protected
    function xlPokeData(const Item: string; Data: Pointer; Size: integer): Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenBuffer(const ColumnsCount: word);
    procedure CloseBuffer;
    function CheckBufferSize: boolean;
    procedure WriteBlank;
    // procedure WriteSkip;
    procedure WriteString(const s: String); //s: ShortString;
    procedure WriteNumber(const n: double);
    procedure WriteBool(const b: boolean);
    procedure Poke(IRange: OLEVariant);
  end;

{ xlTable consts }

const
  // Fast table format name
  xddeFastTableFormatName = 'XLTABLE';
  // tdtTable
  xddetdtTable: word = $0010;
  xddetdtTableSize: word = $0004;
  xddeRowCountPos = 4;
  xddeColumnCountCount = 6;
  // tdtFloat
  xddetdtFloat: word = $0001;
  xddetdtFloatSize: word = $0008;
  // tdtString
  xddetdtString: word = $0002;
  // tdtBool
  xddetdtBool: word = $0003;
  xddetdtBoolSize: word = $0002;
  // tdtError
  // xddetdtError: word = $0004;
  // tdtBlank
  xddetdtBlank: word = $0005;
  xddetdtBlankSize: word = $0002;
  xddetdtBlankData: word = $0001;
  // tdtInt
  //  xddetdtInt: word = $0006;
  // tdtSkip
  //  xddetdtSkip: word =$0007;
  //  xddetdtSkipSize: word =$0002;
  //  xddetdtSkipData: word =$0001;
  // DDE Transaction timeout
  xddeTransactionTimeOut = 100000;
  // Win9x DDE limits
  xlrDDEBufSize = $F000;

{ TxlDDEClient }

constructor TxlDDEClient.Create(AOwner: TComponent);
begin
  inherited;
  FStream := TMemoryStream.Create;
end;

destructor TxlDDEClient.Destroy;
begin
  CloseBuffer;
  FStream.Free;
  inherited;
end;

function TxlDDEClient.xlPokeData(const Item: string; Data: Pointer; Size: Longint): Boolean;
var
  hszDat: HDDEData;
  hdata: HDDEData;
  CF_XLTABLE: word;
  hszItem: HSZ;
begin
  hdata := 0;
  Result := False;
  if (Conv = 0) or WaitStat then Exit;
  //fixed  hszItem := DdeCreateStringHandle(ddeMgr.DdeInstId, PChar(Item), CP_WINANSI);
  hszItem := DdeCreateStringHandle(ddeMgr.DdeInstId, PWideChar(Item), CP_WINUNICODE);
  if hszItem = 0 then Exit;
  try
    CF_XLTABLE := RegisterClipboardFormat(xddeFastTableFormatName);
    if CF_XLTABLE = 0 then Exit;
    hszDat := DdeCreateDataHandle(ddeMgr.DdeInstId, Data, Size, 0, hszItem, CF_XLTABLE, HDATA_APPOWNED);
    {$IFDEF XLR_VCL}
      if hszDat <> 0 then
        if IsLibrary and (xlrOS > xosWinMe) then begin
          hdata := DdeClientTransaction(Pointer(hszDat), DWORD(-1), Conv, hszItem,
            CF_XLTABLE, XTYP_POKE, TIMEOUT_ASYNC, nil);
        end
        else
          hdata := DdeClientTransaction(Pointer(hszDat), DWORD(-1), Conv, hszItem,
            CF_XLTABLE, XTYP_POKE, xddeTransactionTimeOut, nil);
    {$ELSE}
      if hszDat <> 0 then begin
        hdata := DdeClientTransaction(Pointer(hszDat), DWORD(-1), Conv, hszItem,
          CF_XLTABLE, XTYP_POKE, TIMEOUT_ASYNC, nil);
        sleep(25);
      end;
    {$ENDIF XLR_AX}
    Result := hdata <> 0;
  finally
    {$IFNDEF XLR_VCL}
    if xlrOS in [xosWin2000, xosWinXP] then // Fix for Win9x
      DdeFreeStringHandle(ddeMgr.DdeInstId, hszItem);
    {$ELSE}
    if not(IsLibrary) and (xlrOS in [xosWin2000, xosWinXP]) then
      DdeFreeStringHandle(ddeMgr.DdeInstId, hszItem);
    {$ENDIF}
  end;
end;

procedure TxlDDEClient.OpenBuffer(const ColumnsCount: word);
begin
  FStream.Clear;
  // tdtTable
  FStream.WriteBuffer( xddeTdtTable, SizeOf(xddeTdtTable) );
  FStream.WriteBuffer( xddeTdtTableSize, SizeOf(xddeTdtTableSize) );
  FStream.WriteBuffer( ColumnsCount, SizeOf(ColumnsCount) );
  FStream.WriteBuffer( ColumnsCount, SizeOf(ColumnsCount) );
end;

procedure TxlDDEClient.CloseBuffer;
begin
  FStream.Clear;
end;

function TxlDDEClient.CheckBufferSize: boolean;
begin
  Result := FStream.Position > xlrDDEBufSize;
end;

procedure TxlDDEClient.WriteBlank;
begin
  FStream.WriteBuffer(xddetdtBlank, SizeOf(xddetdtBlank));
  FStream.WriteBuffer(xddetdtBlankSize, SizeOf(xddetdtBlankSize));
  FStream.WriteBuffer(xddetdtBlankData, SizeOf(xddetdtBlankData));
end;

{
procedure TxlDDEClient.WriteSkip;
begin
  FStream.WriteBuffer(xddetdtSkip, SizeOf(xddetdtSkip));
  FStream.WriteBuffer(xddetdtSkipSize, SizeOf(xddetdtSkipSize));
  FStream.WriteBuffer(xddetdtSkipData, SizeOf(xddetdtSkipData));
end;
}

procedure TxlDDEClient.WriteString(const s: String); //s: ShortString
var w: word;
    b: byte;
    c: ShortString;
begin
  c := ShortString(StringReplace(s, #$0D, '', [rfReplaceAll, rfIgnoreCase]));
  if c <> '' then begin
    b := length(c);
    w := b + 1;
    FStream.WriteBuffer(xddetdtString, SizeOf(xddetdtString));
    FStream.WriteBuffer(w, SizeOf(w));
    FStream.WriteBuffer(b, SizeOf(b));
    FStream.WriteBuffer(c[1], b);
  end
  else WriteBlank;
end;

procedure TxlDDEClient.WriteNumber(const n: double);
begin
  FStream.WriteBuffer(xddetdtFloat, SizeOf(xddetdtFloat));
  FStream.WriteBuffer(xddetdtFloatSize, SizeOf(xddetdtFloatSize));
  FStream.WriteBuffer(n, SizeOf(n));
end;

procedure TxlDDEClient.WriteBool(const b: boolean);
var
  w: word;
begin
  FStream.WriteBuffer(xddetdtBool, SizeOf(xddetdtBool));
  FStream.WriteBuffer(xddetdtBoolSize, SizeOf(xddetdtBoolSize));
  if b then w := 1  else w := 0;
  FStream.WriteBuffer(w, SizeOf(w));
end;

procedure TxlDDEClient.Poke(IRange: OLEVariant);
var
  {$IFNDEF XLR_BCB}
  Rng: IxlRange;
  {$ENDIF}
  r: word;
  tpc, addr: string;
begin
  r := IRange.Rows.Count;
  FStream.Seek(xddeRowCountPos, soFromBeginning);
  FStream.WriteBuffer(r, SizeOf(r));
  tpc := IRange.Parent.Parent.Name;
  tpc := '[' + tpc + ']' + IRange.Parent.Name;
  if not SetLink('EXCEL', tpc) then
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateRes2(ecExcelDDENotAvailable, ecExcelDDENotAvailable);
    {$ELSE}
    raise ExlReportError.CreateRes(ecExcelDDENotAvailable);
    {$ENDIF}
  tpc := IRange.Parent.Name;
  try
    {$IFDEF XLR_BCB}
    addr := R1C1OfRange(IRange);
    {$ELSE}
    IDispatch(Rng) := IRange;
    addr := R1C1OfRange(Rng);
    {$ENDIF}
    xlPokeData(addr, FStream.Memory, FStream.Size);
  finally
    CloseLink;
  end;
end;

{ Internal data buffers }

type

  TxlBuffer = class(TObject)
  private
    FRoot: TxlExcelDataSource;
    FTotalRowCount: integer;
    FRowCount: integer;
  protected
    procedure StartBuffer; virtual;
    procedure GetRecord(Source: TxlExcelDataSource; var RowsArr: OLEVariant); virtual;
    procedure GetRow(Source: TxlExcelDataSource; const Row: integer; var RowsArr: OLEVariant); virtual;
    procedure GetData(Source: TxlExcelDataSource); virtual;
    procedure GetRowData(Source: TxlExcelDataSource; const Row: integer); virtual;
    function CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean; virtual;
    procedure ClearBuff; virtual;
  public
    constructor Create(ARoot: TxlExcelDataSource); virtual;
    destructor Destroy; override;
    property Root: TxlExcelDataSource read FRoot;
    property RowCount: integer read FRowCount;
  end;

  TxlVarBuffer = class(TxlBuffer)
  private
    FBuff: OLEVariant;
  protected
    procedure StartBuffer; override;
    procedure GetData(Source: TxlExcelDataSource); override;
    procedure GetRowData(Source: TxlExcelDataSource; const Index: integer); override;
    function CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean; override;
    procedure ClearBuff; override;
  end;

  TxlCSVBuffer = class(TxlBuffer)
  private
    FBuff: WideString;
  protected
    procedure StartBuffer; override;
    procedure GetData(Source: TxlExcelDataSource); override;
    procedure GetRowData(Source: TxlExcelDataSource; const Index: integer); override;
    function CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean; override;
    procedure ClearBuff; override;
  end;

  TxlDDEBuffer = class(TxlBuffer)
  private
    FxlDDE: TxlDDEClient;
  protected
    procedure StartBuffer; override;
    procedure GetData(Source: TxlExcelDataSource); override;
    procedure GetRowData(Source: TxlExcelDataSource; const Index: integer); override;
    function CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean; override;
    procedure AddCellValue(Cell: TxlAbstractCell);
  public
    constructor Create(ARoot: TxlExcelDataSource); override;
    destructor Destroy; override;
  end;

{ TxlBuffer }

constructor TxlBuffer.Create(ARoot: TxlExcelDataSource);
begin
  inherited Create;
  FRoot := ARoot;
end;

destructor TxlBuffer.Destroy;
begin
  CheckLimits(not FRoot.Report.FCanceled, NIL);
  if FRoot.Report.FCanceled then
    ClearBuff;
  inherited;
end;

function TxlBuffer.CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean;
begin
  Result := false;
end;

procedure TxlBuffer.GetRecord;
var
  i, HighBound: integer;
  V: OLEVariant;
begin
  Inc(FRowCount, Source.RowCount);
  Inc(FTotalRowCount, Source.RowCount);
  GetData(Source);
  if not _VarIsEmpty(RowsArr) then begin
    for i := 1 to Source.RowCount do begin
      V := RowsArr[Source.FRowOffset + i];
      HighBound := VarArrayHighBound(V, 1);
      V[HighBound] := FTotalRowCount - Source.RowCount + i;
      VarArrayReDim(V, HighBound + 1);
      RowsArr[Source.FRowOffset + i] := V;
    end;
  end;
  if CheckLimits(false, Source) then
    FRowCount := 0;
end;

procedure TxlBuffer.GetRow(Source: TxlExcelDataSource; const Row: integer; var RowsArr: OLEVariant);
var
  i, j, Index, HighBound: integer;
  V: OLEVAriant;
begin
  j := 0;
  Index := -1;
  for i := 0 to Source.Cells.Count - 1 do
    if j = (Row - 1) then begin
      Index := i;
      Break;
    end
    else
      if Source.Cells[i].CellType = ctCR then
        Inc(j);
  if Index <> -1 then begin
    Inc(FRowCount);
    Inc(FTotalRowCount);
    if not _VarIsEmpty(RowsArr) then begin
      V := RowsArr[Source.FRowOffset + Row];
      HighBound := VarArrayHighBound(V, 1);
      V[HighBound] := FTotalRowCount;
      VarArrayReDim(V, HighBound + 1);
      RowsArr[Source.FRowOffset + Row] := V;
    end;
    GetRowData(Source, Index);
  end;
  if CheckLimits(false, Source) then
    FRowCount := 0;
end;

procedure TxlBuffer.StartBuffer;
begin
  // Delphi hiht stub
end;

procedure TxlBuffer.GetData(Source: TxlExcelDataSource);
begin
  // Delphi hint stub
end;

procedure TxlBuffer.GetRowData(Source: TxlExcelDataSource; const Row: integer);
begin
  // Delphi hint stub
end;

procedure TxlBuffer.ClearBuff;
begin
end;

{ TxlVarBuffer }

function TxlVarBuffer.CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean;
var
  IRange: IxlRange;
  Formulas: OLEVariant;
  i, j: integer;
begin
  Result := (RowCount >= xlrMaxVarRowCount) or Immediately;
  if Result and (RowCount > 0) and (not _VarIsEmpty(FBuff)) then begin
    if Source.RangeType <> rtRange then
      IRange := InsertBlankRows(Root.IRange.Rows.Count,
        RowCount, Root.ColCount, Root.ITempSheet, Root.IRange)
    else
      IRange := InsertBlankRows2(Root.IRange.Rows.Count,
        RowCount, Root.ColCount, Root.ITempSheet, Root.IRange, Source.FIUnMergedRows);
    Formulas := VarArrayCreate([1, RowCount, 1, Root.ColCount], varVariant);
    for i := 1 to RowCount do
      for j := 1 to Root.ColCount do
        Formulas[i, j] := FBuff[j, i];
    IRange.Value := Formulas; // replace IRange.Formula := Formulas (rc1)
    Formulas := UnAssigned;
    FBuff := UnAssigned;
    if not Immediately then
      StartBuffer;
  end;
end;

procedure TxlVarBuffer.StartBuffer;
begin
  FBuff := VarArrayCreate([1, Root.ColCount, 1, 1], varVariant)
end;

procedure TxlVarBuffer.GetData;
var
  i, Row, Column: integer;
begin
  VarArrayRedim(FBuff, RowCount);
  Row := -Source.RowCount + 1;
  Column := 1;
  for i := 0 to Source.Cells.Count - 1 do
    if Source.Cells[i].CellType = ctCR then begin
      Inc(Row);
      Column := 1;
      if Row = 1 then
        Break;
    end
    else begin
      FBuff[Column, RowCount + Row] := Source.Cells[i].AsVariant;
      Inc(Column);
    end;
end;

procedure TxlVarBuffer.GetRowData(Source: TxlExcelDataSource; const Index: integer);
var
  i, Column: integer;
begin
  VarArrayRedim(FBuff, RowCount);
  Column := 1;
  for i := Index to Source.Cells.Count - 1 do
    if Source.Cells[i].CellType = ctCR then
      Break
    else begin
      FBuff[Column, RowCount] := Source.Cells[i].AsVariant;
      Inc(Column);
    end;
end;

procedure TxlVarBuffer.ClearBuff;
begin
  FBuff := UnAssigned;
end;

{ TxlCSVBuffer }

procedure AddWithDelimiter(var Buffer: WideString; const AStr, Delimiter: WideString);
begin
  if Buffer <> '' then
    if Buffer[Length(Buffer)] = #$0A then
      Buffer := Buffer + AStr
    else
      Buffer := Buffer + Delimiter + AStr
  else
    Buffer := AStr;
end;

function TxlCSVBuffer.CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean;
var
  IRange: IxlRange;
  Data: THandle;
begin
  Result := (RowCount >= xlrMaxCSVRowCount) or Immediately;
  if Result and (RowCount > 0) and (FBuff <> '') then begin
    if Source.RangeType <> rtRange then
      IRange := InsertBlankRows(Root.IRange.Rows.Count,
        RowCount, Root.ColCount, Root.ITempSheet, Root.IRange)
    else
      IRange := InsertBlankRows2(Root.IRange.Rows.Count,
        RowCount, Root.ColCount, Root.ITempSheet, Root.IRange, Source.FIUnMergedRows);
    Data := WideStringToClipboard(FBuff);
    if Data <> 0 then
      try
        OLEVariant(IRange).PasteSpecial;
      finally
        FBuff := '';
        GlobalFree(Data);
      end;
  end;
end;

procedure TxlCSVBuffer.StartBuffer;
begin
  FBuff := '';
end;

procedure TxlCSVBuffer.GetData;
var
  i, Row: integer;
  s: string;
begin
  Row := 0;
  for i := 0 to Source.Cells.Count - 1 do
    if Source.Cells[i].CellType = ctCR then begin
      FBuff := FBuff + #$0A;
      Inc(Row);
      if Row = Source.RowCount then
        Break;
    end
    else
      if Source.Cells[i].CellType in [ctSpecialColumn, ctSpecialRow, ctField] then
        if Source.Cells[i].IsEmpty then
          FBuff := FBuff + #$09
        else begin
          s := Source.Cells[i].AsString;
          if (FRoot.Report as TxlExcelReport).DataExportMode = xdmCSV then
            s := '"' + s + '"';
          AddWithDelimiter(FBuff, s, #09)
        end
      else
        FBuff := FBuff + #$09;
end;

procedure TxlCSVBuffer.GetRowData(Source: TxlExcelDataSource; const Index: integer);
var
  i: integer;
  s: string;
begin
  for i := Index to Source.Cells.Count - 1 do
    if Source.Cells[i].CellType = ctCR then begin
      Break;
    end
    else
      if Source.Cells[i].CellType in [ctSpecialColumn, ctSpecialRow, ctField] then
        if Source.Cells[i].IsEmpty then
          FBuff := FBuff + #$09
        else begin
          s := Source.Cells[i].AsString;
          if (FRoot.Report as TxlExcelReport).DataExportMode = xdmCSV then
            s := '"' + s + '"';
          AddWithDelimiter(FBuff, s, #09)
        end
      else
        FBuff := FBuff + #$09;
  FBuff := FBuff + #$0A;
end;

procedure TxlCSVBuffer.ClearBuff;
begin
  FBuff := '';
end;

{ TxlDDEBuffer }

constructor TxlDDEBuffer.Create(ARoot: TxlExcelDataSource);
begin
  inherited Create(ARoot);
  FxlDDE := TxlDDEClient.Create(nil);
end;

destructor TxlDDEBuffer.Destroy;
begin
  FxlDDE.Free;
  FxlDDE := nil;
  inherited;
end;

function TxlDDEBuffer.CheckLimits(Immediately: boolean; Source: TxlExcelDataSource): boolean;
var
  IRange: IxlRange;
begin
  Result := true;
  if not Assigned(FxlDDE) then
    Exit;
  Result := FxlDDE.CheckBufferSize or Immediately;
  if Result and (RowCount > 0) then begin
    IRange := InsertBlankRows(Root.IRange.Rows.Count,
      RowCount, Root.ColCount, Root.ITempSheet, Root.IRange);
    FxlDDE.Poke(IRange);
    FxlDDE.CloseBuffer;
    if not Immediately then
      StartBuffer;
  end;
end;

procedure TxlDDEBuffer.StartBuffer;
begin
  FxlDDE.OpenBuffer(Root.ColCount);
end;

procedure TxlDDEBuffer.GetData;
var
  i, Row: integer;
begin
  Row := 0;
  for i := 0 to Source.Cells.Count - 1 do
    if Source.Cells[i].CellType = ctCR then begin
      Inc(Row);
      if Row = Source.RowCount then
        Break;
    end
    else
      AddCellValue(Source.Cells[i]);
end;

procedure TxlDDEBuffer.GetRowData(Source: TxlExcelDataSource; const Index: integer);
var
  i: integer;
begin
  for i := Index to Source.Cells.Count - 1 do
    if Source.Cells[i].CellType = ctCR then
      Break
    else
      AddCellValue(Source.Cells[i]);
end;

procedure TxlDDEBuffer.AddCellValue(Cell: TxlAbstractCell);
begin
  if Cell.IsEmpty then
    FxlDDE.WriteBlank
  else
  case Cell.CellType of
    ctSpecialColumn, ctSpecialRow:
      FxlDDE.WriteString(Cell.AsString);
    ctField:
      if Cell.IsEmpty then
        FxlDDE.WriteBlank
      else
        case Cell.DataType of
          xdInteger, xdFloat, xdDateTime: FxlDDE.WriteNumber(Cell.AsFloat);
          xdBoolean: FxlDDE.WriteBool(Cell.AsBoolean);
          xdString: FxlDDE.WriteString(Cell.AsString);
          else FxlDDE.WriteBlank;
        end;
    else
      FxlDDE.WriteBlank;
  end;
end;

{$IFDEF XLR_VCL}

{ Internal Excel Event Sink }

type

  IxlAppEvents = interface(IDispatch)
    ['{00024413-0000-0000-C000-000000000046}']
  end;

  TxlEventsSink = class(TInterfacedObject, IDispatch, IxlAppEvents)
  private
    FOLEContainer: TOLEContainer;
    FDesignTime: boolean;
    FExcelAuto: boolean;
    FTemps: TStrings;
    FConnected: boolean;
    FOptions: TxlReportOptionsSet;
    // used interfaces
    FIXLApp: IxlApplication;
    FIDispatch: IDispatch;
    FIConnPoint: IConnectionPoint;
    FCookieXL: LongInt;
  protected
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
    { EventsSink }
    function GetEventsSink: IxlAppEvents;
    { properties }
    function GetCanClose: boolean;
    function GetCanDisconnect: boolean;
    function CanShow: boolean;
  public
    constructor Create(XLSApp: IxlApplication; AExcelAuto: boolean);
    destructor Destroy; override;
    procedure DisconnectXL;
    procedure AddReport(Report: TxlExcelReport; OLEContainer: TOLEContainer);
    procedure DoShow;
    property IXLApp: IxlApplication read FIXLApp;
    property Connected: boolean read FConnected;
    property CanDisconnect: boolean read GetCanDisconnect;
    property CanClose: boolean read GetCanClose;
  end;

var
  XLEvents: TxlEventsSink;

const
  xlrWorkbookBeforeCloseEventID = 1570;


{ TxlEventsSink }

constructor TxlEventsSink.Create(XLSApp: IxlApplication; AExcelAuto: boolean);
var
  CPC: IConnectionPointContainer;
begin
  inherited Create;
  FConnected := false;
  FIXLApp := XLSApp;
  FTemps := TStringList.Create;
  try
    if _Assigned(FIXLApp) then begin
      FIDispatch := FIXLApp;
      if SUCCEEDED(FIDispatch.QueryInterface(IConnectionPointContainer, CPC)) then
        if SUCCEEDED(CPC.FindConnectionPoint(DIID_AppEvents, FIConnPoint)) then begin
          FIConnPoint.Advise( GetEventsSink as IUnknown, FCookieXL);
          FConnected := Assigned(FIConnPoint) and (FCookieXL <> 0);
        end;
     end;
     FExcelAuto := AExcelAuto;
  finally
    CPC := nil;
  end;
  if not Connected then
    raise ExlReportError.CreateRes(ecExcelConnectionPointError);
end;

destructor TxlEventsSink.Destroy;
var
  i: integer;
  b: boolean;
begin
  DisconnectXL;
  // Release excel
  if Assigned(FIDispatch) then begin
    FIConnPoint := nil;
    FCookieXL := 0;
    b := Assigned(Application);
    if b then
      b := not (csDestroying in Application.ComponentState);
    if b or FDesignTime then
      if CanClose then FIXLApp.Quit
      else DoShow;
    _Clear(FIXLApp);
    FIDispatch := nil;
  end;
  // Delete all temporary files
  for i := 0 to FTemps.Count - 1 do
    try
      DeleteFiles(FTemps.Strings[i], xlrFileExtention, xlrTempFileSign);
    except
    end;
  FTemps.Free;
  inherited;
  XLEvents := nil;
end;

function TxlEventsSink.GetCanClose: boolean;
begin
  Result := _Assigned(FIXLApp);
  if Result then
    Result := (FIXLApp.Workbooks.Count = 0) and FExcelAuto;
end;

function TxlEventsSink.GetCanDisconnect: boolean;
begin
  Result := (not (xroOptimizeLaunch in FOptions) ) or FDesignTime or IsLibrary;
end;

function TxlEventsSink.CanShow: boolean;
begin
  Result := not( (xroHideExcel in FOptions) and FExcelAuto );
end;

procedure TxlEventsSink.AddReport(Report: TxlExcelReport; OLEContainer: TOLEContainer);
var
  i: integer;
begin
  if Assigned(Report) then begin
    FOLEContainer := OLEContainer;
    FDesignTime := FDesignTime or (csDesigning in Report.ComponentState);
    FOptions := FOptions + Report.Options;
    i := FTemps.IndexOf(Report.TempPath);
    if i = -1 then FTemps.Add(Report.TempPath);
  end;
end;

procedure TxlEventsSink.DisconnectXL;
begin
  if FConnected then begin
    FConnected := false;
    FIConnPoint.Unadvise(FCookieXL);
  end;
end;

function TxlEventsSink.GetEventsSink: IxlAppEvents;
begin
  if not GetInterface(DIID_AppEvents, Result) then Result := nil;
end;

function TxlEventsSink.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := S_OK;
  if Connected then
    Result := FIDispatch.GetIDsOfNames(IID, Names, NameCount, LocaleID, DispIDs);
end;

function TxlEventsSink.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Result := S_OK;
  if Connected then
    Result := FIDispatch.GetTypeInfo(Index, LocaleID, TypeInfo);
end;

function TxlEventsSink.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Result := S_OK;
  if Connected then
    Result := FIXLApp.GetTypeInfoCount(Count);
end;

function TxlEventsSink.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
begin
  Result := S_OK;
  if Connected and (DispID = xlrWorkbookBeforeCloseEventID) then
    if CanDisconnect then
      DisconnectXL;
end;

procedure TxlEventsSink.DoShow;
begin
  if CanShow and Assigned(FIDispatch) then
    ShowExcel(FIXLApp, Assigned(FOLEContainer), false, TOLEEnum(xlNormal), -1, -1);
end;

{$ENDIF XLR_VCL}

// xldebug
//{$I xlDebug.inc}

{ TxlExcelDataSource }

constructor TxlExcelDataSource.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FOptions := [xrgoAutoOpen, xrgoPreserveRowHeight];
end;

function TxlExcelDataSource.GetReport: TxlExcelReport;
begin
  Result := (inherited Report) as TxlExcelReport;
end;

function TxlExcelDataSource.GetMasterSource: TxlExcelDataSource;
begin
  Result := (inherited MasterSource) as TxlExcelDataSource;
end;

procedure TxlExcelDataSource.SetMasterSource(const Value: TxlExcelDataSource);
begin
  inherited SetMasterSource(TxlAbstractDataSource(Value));
end;

procedure TxlExcelDataSource.SetOptions(const Value: TxlRangeOptionsSet);
begin
  FOptions := Value;
  AutoOpen := xrgoAutoOpen in Options;
  AutoClose := xrgoAutoClose in Options;
end;

function TxlExcelDataSource.GetRoot: TxlExcelDataSource;
begin
  Result := Self;
  while Assigned(Result.MasterSource) do
    Result := Result.MasterSource;
end;

function TxlExcelDataSource.GetLevel: integer;
var Source: TxlExcelDataSource;
begin
  Result := 1;
  Source := Self;
  while Assigned(Source.MasterSource) do begin
    Inc(Result);
    Source := Source.MasterSource;
  end;
end;

function TxlExcelDataSource.GetMaxLevel: integer;
var
  Root: TxlExcelDataSource;
  Level, i: integer;
begin
  Result := 1;
  Root := GetRoot;
  for i := 0 to Report.DataSources.Count - 1 do
    if Report.DataSources[i].GetRoot = Root then begin
      Level := Report.DataSources[i].GetLevel;
      if Result < Level then
        Result := Level;
    end;
end;

function TxlExcelDataSource.GetDataSources: TxlExcelDataSources;
begin
  Result := (inherited DataSources) as TxlExcelDataSources;
end;

function TxlExcelDataSource.GetAlias: string;
begin
  Result := inherited GetAlias;
  if (RangeType = rtNoRange) and (Report.FMultisheetIndex > 0) then
    Result := Result + '_' + IntToStr(Report.FMultisheetIndex);
end;

// Events
procedure TxlExcelDataSource.DoOnAfterDataTransfer;
begin
end;

procedure TxlExcelDataSource.DoOnBeforeDataTransfer;
begin
end;

procedure TxlExcelDataSource.DoOnMacro(const MacroType: TxlMacroType;
  const MacroName: string; var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7,
  Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17,
  Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27,
  Arg28, Arg29, Arg30: OLEVariant);
begin
end;

procedure TxlExcelDataSource.Connect;
begin
  // Field initialization
  if xlrExcelHost then
    Options := Options - [xrgoPreserveRowHeight];
  FRecordCount := 0;
  FRowOffset := 0;
  FRows := UnAssigned;
  FRanges := UnAssigned;
  FRangesCount := 0;
  FDeleteSpecialRow := true;
  if RangeType in rtRoots then begin
    case Report.DataExportMode of
      xdmCSV: FBuff := TxlCSVBuffer.Create(Self);
      xdmDDE: FBuff := TxlDDEBuffer.Create(Self);
      else FBuff := TxlVarBuffer.Create(Self);
    end;
  end;
  // Connect to range
  FIXLSApp := Report.IXLSApp;
  FIWorkbooks := Report.IWorkbooks;
  FIWorkbook := Report.IWorkbook;
  FIWorksheets := FIWorkbook.Worksheets;
  FINames := Report.INames;
  FITempSheet := Report.ITempSheet;
  // NoRange
  if RangeType = rtNoRange then begin
    {$IFDEF XLR_BCB}
    FIRange := ITempSheet.Cells.Item[Report.FNoRangeRow, 1];
    {$ELSE}
    IDispatch(FIRange) := ITempSheet.Cells.Item[Report.FNoRangeRow, 1];
    {$ENDIF}
    FISheet := ITempSheet;
  end
  // Range
  else begin
    try
      FIName := IWorkbook.Names.Item(EmptyParam, Range, EmptyParam);
      FIRange := IName.RefersToRange;
      {$IFDEF XLR_BCB}
      FISheet := IRange.Parent;
      {$ELSE}
      FISheet := IRange.Parent as IxlWorksheet;
      {$ENDIF}
      // xldebug
      // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDatasourceConnect, Self, Null);
      if IRange.Rows.Count = 1 then
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecIncorrectRangeFormat, ecIncorrectRangeFormat, [Range]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecIncorrectRangeFormat, [Range]);
        {$ENDIF}
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecRangeNotFound, ecRangeNotFound, [Range] );
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecRangeNotFound, [Range] );
      {$ENDIF}
    end;
  end;
end;

procedure TxlExcelDataSource.Disconnect;
begin
  // xldebug
  // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDatasourceDisonnect, Self, Null);
  if (RangeType in rtRoots) and (_Assigned(IRange)) then begin
    if _Assigned(FIMergedRows) then
      FIMergedRows.Delete(TOLEEnum(xlShiftUp));
    if _Assigned(FIUnMergedRows) then
      FIUnMergedRows.Delete(TOLEEnum(xlShiftUp));
  end;
  _Clear(FIMergedRows);
  _Clear(FIUnMergedRows);
  _Clear(FIRange);
  _Clear(FISheet);
  _Clear(FITempSheet);
  _Clear(FIName);
  _Clear(FINames);
  _Clear(FIWorksheets);
  _Clear(FIWorkbook);
  _Clear(FIWorkbooks);
  _Clear(FIXLSApp);
  if RangeType = rtNoRange then
    Inc(Report.FNoRangeRow)
  else
    if RangeType in rtRoots then
      FBuff.Free;
  FHeights := UnAssigned;
  FRows := UnAssigned;
  FRangesCount := 0;
  FRecordCount := 0;
  FRanges := UnAssigned;
  FRootRanges := UnAssigned;
  FBuff := nil;
end;

procedure TxlExcelDataSource.MacroProcessing(const MacroType: TxlMacroType; const MacroName: string);
var
  vArg1, vArg2, vArg3, vArg4, vArg5, vArg6, vArg7, vArg8, vArg9, vArg10,
  vArg11, vArg12, vArg13, vArg14, vArg15, vArg16, vArg17, vArg18, vArg19, vArg20,
  vArg21, vArg22, vArg23, vArg24, vArg25, vArg26, vArg27, vArg28, vArg29, vArg30: OLEVariant;
var
  s: string;
begin
  Report.CheckBreak;
  if MacroName <> '' then
  try
    try
      vArg1:= EmptyParam; vArg2:= EmptyParam; vArg3:= EmptyParam; vArg4:= EmptyParam;
      vArg5:= EmptyParam; vArg6:= EmptyParam; vArg7:= EmptyParam; vArg8:= EmptyParam;
      vArg9:= EmptyParam; vArg10:= EmptyParam; vArg11:= EmptyParam; vArg12:= EmptyParam;
      vArg13:= EmptyParam; vArg14:= EmptyParam; vArg15:= EmptyParam; vArg16:= EmptyParam;
      vArg17:= EmptyParam; vArg18:= EmptyParam; vArg19:= EmptyParam; vArg20:= EmptyParam;
      vArg21:= EmptyParam; vArg22:= EmptyParam; vArg23:= EmptyParam; vArg24:= EmptyParam;
      vArg25:= EmptyParam; vArg26:= EmptyParam; vArg27:= EmptyParam; vArg28:= EmptyParam;
      vArg29:= EmptyParam; vArg30:= EmptyParam;
      DoOnMacro(MacroType, MacroName,
        vArg1, vArg2, vArg3, vArg4, vArg5, vArg6, vArg7, vArg8, vArg9, vArg10,
        vArg11, vArg12, vArg13, vArg14, vArg15, vArg16, vArg17, vArg18, vArg19, vArg20,
        vArg21, vArg22, vArg23, vArg24, vArg25, vArg26, vArg27, vArg28, vArg29, vArg30);
      BeforeRunMacro(IXLSApp, xroHideExcel in Report.Options);
      s := '''' + Report.IWorkbook.Name + '''' + '!' + MacroName;
      IXLSApp.Run(s,
        vArg1, vArg2, vArg3, vArg4, vArg5, vArg6, vArg7, vArg8, vArg9, vArg10,
        vArg11, vArg12, vArg13, vArg14, vArg15, vArg16, vArg17, vArg18, vArg19, vArg20,
        vArg21, vArg22, vArg23, vArg24, vArg25, vArg26, vArg27, vArg28, vArg29, vArg30);
      // xldebug
      // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourceMacroProcessing, Self, VarArrayOf([MacroType, MacroName]));
    finally
      vArg1 := UnAssigned; vArg2 := UnAssigned; vArg3 := UnAssigned; vArg4 := UnAssigned;
      vArg5 := UnAssigned; vArg6 := UnAssigned; vArg7 := UnAssigned; vArg8 := UnAssigned;
      vArg9 := UnAssigned; vArg10 := UnAssigned; vArg11 := UnAssigned; vArg12 := UnAssigned;
      vArg13 := UnAssigned; vArg14 := UnAssigned; vArg15 := UnAssigned; vArg16 := UnAssigned;
      vArg17 := UnAssigned; vArg18 := UnAssigned; vArg19 := UnAssigned; vArg20 := UnAssigned;
      vArg21 := UnAssigned; vArg22 := UnAssigned; vArg23 := UnAssigned; vArg24 := UnAssigned;
      vArg25 := UnAssigned; vArg26 := UnAssigned; vArg27 := UnAssigned; vArg28 := UnAssigned;
      vArg29 := UnAssigned; vArg30 := UnAssigned;
    end;
  except
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [MacroName] );
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [MacroName] );
    {$ENDIF}
  end;
end;

// Template parsing
procedure TxlExcelDataSource.GetRangeInfo(var ARow, AColumn, ARowCount, AColCount: integer; var Formulas, RowCaptions: OLEVariant);
var
  i: integer;
  s, FieldName: string;
  IR: IxlRange;
begin
  // Range
  if RangeType <> rtNoRange then begin
    // Get formulas
    ARow := IRange.Row;
    AColumn := IRange.Column;
    ARowCount := IRange.Rows.Count;
    AColCount := IRange.Columns.Count;
    if RangeType in rtRoots then
      IR := IRange.Range[A1(1, 1), A1(ARowCount, AColCount)]
    else
      IR := IRange;
    Formulas := IR.FormulaLocal;
    if Assigned(MasterSource) then
      FRowOffset := ARow - GetRoot.Row;
    if RangeType in rtRoots then begin
      FIMergedRows := ITempSheet.Range[A1(Report.FTemplateRow + 1, 1),
        A1(Report.FTemplateRow + ARowCount, AColCount)];
      IR.Copy(FIMergedRows);
      IR.UnMerge;
      Inc(Report.FTemplateRow, ARowCount + 2);
      FIUnMergedRows := ITempSheet.Range[A1(Report.FTemplateRow + 1, 1),
        A1(Report.FTemplateRow + ARowCount, AColCount)];
      IR.Copy(FIUnMergedRows);
      FIUnMergedRows.UnMerge;
      FIMergedRows.Copy(IR);
      Inc(Report.FTemplateRow, ARowCount + 2);
      _Clear(IR);
    end
    else begin
      FIMergedRows := GetRoot.FIMergedRows.Range[A1(FRowOffset + 1, 1), A1(FRowOffset + ARowCount, AColCount)];
      FIUnMergedRows := GetRoot.FIUnMergedRows.Range[A1(FRowOffset + 1, 1), A1(FRowOffset + ARowCount, AColCount)];
    end;
    // Get captions
    if ARow > 1 then begin
      IR := IWorksheet.Range[A1(ARow - 1, AColumn), A1(ARow - 1, AColumn + AColCount - 1)];
      RowCaptions := IR.Value;
      _Clear(IR);
    end;
  end
  // NoRange
  else begin
    // Get customized fields
    s := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrGetNameOfAlias';
    try
      s := OLEVariant(IXLSApp).Run(s, UpperCase(Alias));
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
      {$ENDIF}
    end;
    if s <> '' then begin
      AColCount := 2;
      while CutSubString2(delOption, FieldName, s) do
        if FieldName <> '' then begin
          if AColCount = 2 then
            Formulas := VarArrayCreate([1, 2, 1, 2], varVariant)
          else
            VarArrayRedim(Formulas, AColCount + 1);
          Formulas[1, AColCount] := '=' + Alias + delFldFormula + FieldName;
          Inc(AColCount);
        end;
    end;
    // Range emulation
    if _VarIsEmpty(Formulas) then begin
      AColCount := 2;
      for i := 0 to XLDataSet.Fields.Count - 1 do
        if (XLDataSet.FieldType[i] <> xdNotSupported) then begin
          if AColCount = 2 then
            Formulas := VarArrayCreate([1, 2, 1, 2], varVariant)
          else
            VarArrayRedim(Formulas, AColCount + 1);
          Formulas[1, AColCount] := '=' + Alias + delFldFormula + XLDataSet.Fields[i];
          Formulas[2, AColCount] := '';
          Inc(AColCount);
        end;
    end;
    Dec(AColCount);
    ARow := IRange.Row;
    AColumn := 1;
    ARowCount := 2;
  end;
  // xldebug
  // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourceParse, Self, NULL);
end;

procedure TxlExcelDataSource.ScanParsedCells(Formulas: OLEVariant);
var
  i: integer;
  a: TxlSpecialRowAction;
  b: TxlSpecialRowActions;
  IsDelete: boolean;
  UnMergedFormulas, MergedFormulas: OLEVariant;
  OptStr, f: string;
begin
  IsDelete := true;
  // Scan cells
  if RangeType <> rtNoRange then begin
    b := [saDeleteIsEmpty];
    UnMergedFormulas := FIUnMergedRows.FormulaLocal;
    MergedFormulas := FIMergedRows.FormulaLocal;
    for i := 0 to Cells.Count - 1 do begin
      if Cells[i].CellType = ctField then begin
        Formulas[Cells[i].Row, Cells[i].Column] := NULL;
        MergedFormulas[Cells[i].Row, Cells[i].Column] := NULL;
        UnMergedFormulas[Cells[i].Row, Cells[i].Column] := NULL;
      end;
      if Cells[i].CellType in [ctField, ctEmpty, ctFormula] then begin
        // Parse column options
        OptStr := Formulas[RowCount + 1, Cells[i].Column];
        f := '';
        {$IFDEF XLR_BCB}
        Cells[i].OptionFound := Report.OptionItems.ParseOptionsStr2(Cells[i], UnAssigned, xoColumn, OptStr, a, f);
        {$ELSE}
        Cells[i].OptionFound := Report.OptionItems.ParseOptionsStr2(Cells[i], nil, xoColumn, OptStr, a, f);
        {$ENDIF}
        Include(b, a);
        if Cells[i].OptionFound then
          Formulas[RowCount + 1, Cells[i].Column] := f;
        IsDelete := IsDelete and
          ( ( (not Cells[i].OptionFound) and (Formulas[RowCount + 1, Cells[i].Column] = '') ) or
           ( (Cells[i].OptionFound) and (a = saDeleteIsEmpty) ) );
      end;
    end;
    {$IFDEF XLR_BCB}
    Self.OptionFound := Report.OptionItems.ParseOptionsStr2(Self, UnAssigned, xoRange, Formulas[RowCount + 1, 1], a, f);
    {$ELSE}
    Self.OptionFound := Report.OptionItems.ParseOptionsStr2(Self, nil, xoRange, Formulas[RowCount + 1, 1], a, f);
    {$ENDIF}
    Include(b, a);
    FDeleteSpecialRow := IsDelete or (saAbsoluteDelete in b);
    if saCompleteDelete in b then
      FDeleteSpecialRow := false;
    if Self.OptionFound then
      Formulas[RowCount + 1, 1] := NULL;
    IRange.FormulaLocal := Formulas;
    FIMergedRows.FormulaLocal := Formulas;
    FIUnMergedRows.FormulaLocal := Formulas;
    IRange.Copy(EmptyParam);
    FIMergedRows.PasteSpecial(TOLEEnum(xlPasteFormulas),
      TOLEEnum(xlPasteSpecialOperationNone), true, false);
    FIUnMergedRows.PasteSpecial(TOLEEnum(xlPasteFormulas),
      TOLEEnum(xlPasteSpecialOperationNone), true, false);
  end;
  // xldebug
  // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourceScan, Self, NULL);
end;

// Data transfer
procedure TxlExcelDataSource.PutNoRange;
var
  Buff, Addrs, Names: OLEVariant;
  r, c, i: integer;
  s: string;
begin
  FRecordCount := 0;
  _Clear(FIRange);
  Buff := VarArrayCreate([1, ColCount], varVariant);
  Addrs := VarArrayCreate([1, ColCount], varVariant);
  Names := VarArrayCreate([1, ColCount], varVariant);
  try
    Names[1] := '';
    Addrs[1] := '';
    r := Row;
    c := 2;
    for i := 2 to ColCount do begin
      if i mod 250 = 1 then begin
        Inc(r);
        c := 2;
      end;
      Buff[i] := Cells[i - 1].AsVariant;
      Addrs[i] := '=' + xlrTempSheetName + '!' + A1Abs(r, c);
      Names[i] := copy(Cells[i-1].Formula, 2, Length(Cells[i-1].Formula) - 1);
      Inc(c);
    end;
    BeforeRunMacro(IXLSApp, xroHideExcel in Report.Options);
    s := '''' + Report.IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrPutNoRangeData';
    try
      {$IFDEF XLR_BCB}
      FIRange := OLEVariant(IXLSApp).Run(s, xlrDebug, Report.FNoRangeRow, Buff, Addrs, Names, Alias);
      {$ELSE}
      IDispatch(FIRange) := OLEVariant(IXLSApp).Run(s, xlrDebug, Report.FNoRangeRow, Buff, Addrs, Names, Alias);
      {$ENDIF}
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
      {$ENDIF}
    end;
    FAllowOptions := false;
    Report.FNoRangeRow := Report.FNoRangeRow + ColCount div 250;
    FRecordCount := 1;
    {$IFDEF XLR_VCL}
    (Report as TxlReport).DoOnProgress2(Self as TxlDataSource, FRecordCount);
    {$ENDIF}
    // xldebug
    // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourcePutNoRange, Self, NULL);
  finally
    Buff := UnAssigned;
    Addrs := UnAssigned;
    Names := UnAssigned;
  end;
end;

procedure TxlExcelDataSource.PutRange;

  procedure MakeRootRanges;
  var V: OLEVariant;
  begin
    FRootRanges := VarArrayCreate([1, 2], varVariant);
    FRootRanges[1] := 1;
    // Root
    V := VarArrayCreate([1, 2], varVariant);
    V[1] := 1;
    V[2] := FRanges;
    FRootRanges[2] := V;
  end;

var
  s: string;
  V: OLEVariant;
begin
  FRows := UnAssigned;
  if xrgoPreserveRowHeight in Options then begin
    BeforeRunMacro(IXLSApp, xroHideExcel in Report.Options);
    s := '''' + Report.IWorkbook.Name + '''' + '!' + xlrModuleName + '.xlrRowsHeight';
    try
      FHeights := OLEVariant(IXLSApp).Run(s, Range)
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
      {$ENDIF}
    end;
  end
  else
    FHeights := UnAssigned;
  // Add empty row
  IRange.Rows.Item[1, EmptyParam].Insert(TOLEEnum(xlShiftDown));
  s := '=' + '''' + IWorksheet.Name + '''' + '!' +
    R1C1(IRange.Row - 1, IRange.Column) + ':' +
    R1C1(IRange.Row + IRange.Rows.Count - 1, IRange.Column + IRange.Columns.Count - 1);
  _Clear(FIRange);
  // Reconnect IName
  IName.Delete;
  _Clear(FIName);
  {$IFDEF XLR_BCB}
  FIName := OLEVariant(INames).Add(Name := Range, RefersToR1C1 := s);
  {$ELSE}
  IDispatch(FIName) := OLEVariant(INames).Add(Name := Range, RefersToR1C1 := s);
  {$ENDIF}
  // Reconnect IRange
  FIRange := IWorksheet.Range[Range, EmptyParam];
  // Delete template rows
  IRange.Range[A1(IRange.Rows.Count - RowCount, 1), A1(IRange.Rows.Count - 1, ColCount)].Delete(TOLEEnum(xlShiftUp));
  // Put data
  XLDataSet.First;
  (FBuff as TxlBuffer).StartBuffer;
  FAllowOptions := not XLDataSet.Eof;
  while not XLDataSet.Eof do begin
    (FBuff as TxlBuffer).GetRecord(Self, FRows);
    Inc(FRecordCount);
    {$IFDEF XLR_VCL}
    (Report as TxlReport).DoOnProgress2(Self as TxlDataSource, FRecordCount);
    {$ENDIF}
    {$IFDEF XLR_TRIAL}
    if FRecordCount = 64 then
      Break;
    {$ENDIF}
    XLDataSet.Next;
    Report.CheckBreak;
  end;
  // DEBUG_1 FRecordCount
  (FBuff as TxlBuffer).CheckLimits(true, Self);
  // Copy cells format
  if IRange.Rows.Count > (RowCount + 1) then begin
    FRows := varArrayCreate([1, 1], varVariant);
    V := VarArrayCreate([1, 3], varVariant);
    V[1] := 2;
    V[2] := (FBuff as TxlBuffer).FTotalRowCount + 1;
    V[3] := RowCount;
    FRows[1] := V;
    VBACopyFormats(Self, FRows, FHeights, FDeleteSpecialRow,
      xrgoPreserveRowHeight in Options, xroHideExcel in Report.Options);
  end
  else begin
    IRange.Rows.Item[1, EmptyParam].Delete(xlShiftUp);
  end;
  // FRanges emulation
  FRanges := VarArrayCreate([1, 2], varVariant);
  FRangesCount := 0;
  FRanges[1] := 1;
  if FDeleteSpecialRow then
    FRanges[2] := FIRange.Rows.Count
  else
    FRanges[2] := FIRange.Rows.Count - 1;
  MakeRootRanges;
  // xldebug
  // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourcePutRange, Self, NULL);
end;

procedure TxlExcelDataSource.PutRoot;

  procedure SetAllowOptions(Source: TxlExcelDataSource; Value: boolean);
  var
    i: integer;
  begin
    Source.FAllowOptions := Value;
    for i := 0 to Source.Details.Count - 1 do
      if TxlExcelDataSource(Source.Details[i]).RangeType = rtRangeDetail then
        TxlExcelDataSource(Source.Details[i]).FAllowOptions := Value
      else
        SetAllowOptions(TxlExcelDataSource(Source.Details[i]), Value);
  end;

  function SourceOfRow(RootRow: integer): TxlExcelDataSource;
  var
    i: integer;
  begin
    Result := Self;
    for i := 0 to Details.Count - 1 do
      if (RootRow >= (TxlExcelDataSource(Details[i]).FRowOffset + 1)) and
         (RootRow <= (TxlExcelDataSource(Details[i]).FRowOffset + 1 + TxlExcelDataSource(Details[i]).RowCount)) then begin
        Result := TxlExcelDataSource(Details[i]);
        Break;
      end;
  end;

  procedure AddRowToRanges(Source: TxlExcelDataSource; const AStartRow, AEndRow: integer);
  begin
    if _VarIsEmpty(Source.FRanges) then begin
      Source.FRanges := VarArrayCreate([1, 2], varVariant);
      Source.FRangesCount := 1;
    end
    else begin
      Inc(Source.FRangesCount);
      VarArrayReDim(Source.FRanges, Source.FRangesCount * 2);
    end;
    Source.FRanges[Source.FRangesCount * 2 - 1] := AStartRow;
    Source.FRanges[Source.FRangesCount * 2] := AEndRow;
  end;

  procedure MakeRootRanges;
  var V: OLEVariant;
      i, j, CountRanges: integer;
  begin
    FRootRanges := VarArrayCreate([1, GetMaxLevel + 1], varVariant);
    FRootRanges[1] := GetMaxLevel;
    for i := 2 to GetMaxLevel + 1 do begin
      V := VarArrayCreate([1, 1], varVariant);
      V[1] := 0;
      FRootRanges[i] := V;
    end;
    // Root
    V := VarArrayCreate([1, 2], varVariant);
    V[1] := 1;
    V[2] := FRanges;
    FRootRanges[2] := V;
    // Levels
    for i := 2 to GetMaxLevel do begin
      V := FRootRanges[i + 1];
      for j := 0 to Report.DataSources.Count - 1 do
        if (Self = Report.DataSources[j].GetRoot) and (i = Report.DataSources[j].GetLevel) then begin
          CountRanges := V[1];
          Inc(CountRanges);
          VarArrayRedim(V, CountRanges + 1);
          V[CountRanges + 1] := Report.DataSources[j].FRanges;
          V[1] := CountRanges;
        end;
      FRootRanges[i+1] := V;
    end;
  end;

var
  i, MasterRecCount, DetailRecCount: integer;
  Source: TxlExcelDataSource;
  s: string;
  V: OLEVariant;
begin
  // Get format rows
  if RangeType = rtRangeRoot then begin
    FRows := varArrayCreate([1, RowCount + 1], varVariant);
    for i := 1 to RowCount + 1 do begin
      V := VarArrayCreate([1, 1], varVariant);
      FRows[i] := V;
      V := UnAssigned;
    end;
    SetAllowOptions(Self, true);
    if xrgoPreserveRowHeight in Options then begin
      BeforeRunMacro(IXLSApp, xroHideExcel in Report.Options);
      s := '''' + Report.IWorkbook.Name + '''' + '!' + xlrModuleName + '.xlrRowsHeight';
      try
        FHeights := OLEVariant(IXLSApp).Run(s, Range)
      except
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
        {$ENDIF}
      end;
    end
    else
      FHeights := UnAssigned;
  end
  else begin
    FRows := MasterSource.FRows;
  end;
  try
    // Init RootSource
    if RangeType = rtRangeRoot then begin
      // Start Buffer
      (GetRoot.FBuff as TxlBuffer).StartBuffer;
      // Add first empty row
      IRange.Rows.Item[1, EmptyParam].Insert(TOLEEnum(xlShiftDown));
      s := '=' + '''' + IWorksheet.Name + '''' + '!' +
        R1C1(IRange.Row - 1, IRange.Column) + ':' +
        R1C1(IRange.Row + IRange.Rows.Count - 1, IRange.Column + IRange.Columns.Count - 1);
      _Clear(FIRange);
      // Reconnect IName
      IName.Delete;
      _Clear(FIName);
      {$IFDEF XLR_BCB}
      FIName := OLEVariant(INames).Add(Name := Range, RefersToR1C1 := s);
      {$ELSE}
      IDispatch(FIName) := OLEVariant(INames).Add(Name := Range, RefersToR1C1 := s);
      {$ENDIF}
      // Reconnect IRange
      FIRange := IWorksheet.Range[Range, EmptyParam];
      // Delete template rows
      IRange.Range[A1(2, 1), A1(IRange.Rows.Count - 1, ColCount)].Delete(TOLEEnum(xlShiftUp));
    end;

    // Data transfer
    XLDataSet.First;
    {$IFNDEF XLR_VCL}
    if RangeType <> rtRangeRoot then
      DoRelation;
    {$ENDIF}
    MasterRecCount := 0;
    FSR := 0;
    if not XLDataSet.Eof then
      FSR := (Self.GetRoot.FBuff as TxlBuffer).FTotalRowCount + 1;
    if (RangeType = rtRangeRoot) and XLDataSet.Eof then
      SetAllowOptions(Self, false);
    FRecordCount := 0;
    while not XLDataSet.Eof do begin
      i := FRowOffset + 1;
      while i <= FRowOffset + RowCount do begin
        Source := SourceOfRow(i);
        if Source = Self then begin
          (Source.GetRoot.FBuff as TxlBuffer).GetRow(Self, i - FRowOffset, FRows);
          Inc(i);
        end
        else
          if Source.RangeType = rtRangeDetail then begin
            Source.XLDataSet.First;
            DetailRecCount := 0;
            // AddStartRow
            Source.FSR := 0;
            if not Source.XLDataSet.Eof then
              Source.FSR := (Source.GetRoot.FBuff as TxlBuffer).FTotalRowCount + 1;
            Source.FRecordCount := 0;
            while not Source.XLDataSet.Eof do begin
              (Source.GetRoot.FBuff as TxlBuffer).GetRecord(Source, FRows);
              Inc(Source.FRecordCount);
              {$IFDEF XLR_VCL}
              (Report as TxlReport).DoOnProgress2(Source as TxlDataSource, Source.FRecordCount);
              {$ENDIF}
              Source.XLDataSet.Next;
              Inc(DetailRecCount);
              {$IFDEF XLR_TRIAL}
              if Source.FRecordCount = 64 then
                Break;
              {$ENDIF}
              Report.CheckBreak;
            end;
            // AddEndRow
            if (Source.FSR > 0) and (DetailRecCount > 0) then
              AddRowToRanges(Source, Source.FSR, (Source.GetRoot.FBuff as TxlBuffer).FTotalRowCount);
            if not Source.FDeleteSpecialRow then
              (Source.GetRoot.FBuff as TxlBuffer).GetRow(Source, Source.RowCount + 1, FRows);
            Inc(i, Source.RowCount + 1);
          end
          else begin
            Source.PutRoot;
            Inc(i, Source.RowCount + 1);
          end;
      end;
      Inc(FRecordCount);
      {$IFDEF XLR_VCL}
      (Report as TxlReport).DoOnProgress2(Self as TxlDataSource, FRecordCount);
      {$ENDIF}
      XLDataSet.Next;
      {$IFNDEF XLR_VCL}
      if not XLDataSet.Eof then
        DoRelation;
      {$ENDIF XLR_VCL}
      Inc(MasterRecCount);
      {$IFDEF XLR_TRIAL}
      if FRecordCount = 64 then
        Break;
      {$ENDIF}
      Report.CheckBreak;
    end;
    // Add EndRow
    if (FSR > 0) and (MasterRecCount > 0) then
      AddRowToRanges(Self, Self.FSR, (Self.GetRoot.FBuff as TxlBuffer).FTotalRowCount);
    if RangeType in rtMasters then
      if not FDeleteSpecialRow then
        (GetRoot.FBuff as TxlBuffer).GetRow(Self, RowCount + 1, FRows);

    // RootSource
    if RangeType = rtRangeRoot then begin
      // Send buffer
      (GetRoot.FBuff as TxlBuffer).CheckLimits(true, GetRoot);
      // Copy all formats
      VBACopyFormats(Self, FRows, FHeights, False, xrgoPreserveRowHeight in Options,
        xroHideExcel in Report.Options);
      // Make root ranges
      MakeRootRanges;
    end;
    // xldebug
    // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourcePutRoot, Self, NULL);
  finally
    if RangeType = rtRangeRoot then begin
      for i := 1 to RowCount + 1 do
        FRows[i] := UnAssigned;
      FRows := UnAssigned;
    end
    else begin
      MasterSource.FRows := Self.FRows;
      for i := 1 to RowCount + 1 do
        FRows[i] := UnAssigned;
      FRows := UnAssigned;
    end;
  end;
end;

// Options processing
procedure TxlExcelDataSource.OptionsProcessing;

  function GetIndexOfLevel(Level: integer): integer;
  var
    i: integer;
    Root: TxlExcelDataSource;
  begin
    Result := 1;
    Root := GetRoot;
    for i := 0 to Report.DataSources.Count - 1 do
      if (Root = Report.DataSources[i].GetRoot) and (Level = Report.DataSources[i].GetLevel) then begin
        if Self = Report.DataSources[i] then
          Break
        else
          Inc(Result);
      end;
  end;

var
  Args: TxlOptionArgs;
  i, Indx: integer;
  IColumn: IxlRange;
  V: OLEVariant;
begin
    { Args = Params passing to Optopn.DoOption:
        varString       - for NoRange-DataSets
        VarArray[1, 4]  - for Range-DataSets
           [1] = Root.Range
           [2] = DataSource.Alias
           [3] = Ranges
           [4] = RangesXY
        RangeXY =VarArray[1..2] of varVariant
           [1] = Level
           [2] = IndexOfLevel
        Ranges = VarArray[1..MaxLevel + 1] of varVariant
           [1] = MaxLevel
           [2..MaxLevel + 1] = RangesOfLevel
        RangesOfLevel = VarArray[1..DataSourceCountPerLevel + 1] of varVariant
           [1] = DataSourceCountPerlevel
           [2..DataSourceCountPerLevel + 1] = DataSource.FRows

        i.e. Params[2][Level + 1][IndexOfLevel + 1] = DataSource.FRows }

  if FAllowOptions then begin
    Args := VarArrayCreate([1, 4], varVariant);
    Args[1] := GetRoot.Range;
    Args[2] := Self.Alias;
    Args[3] := GetRoot.FRootRanges;
    V := VarArrayCreate([1, 2], varVariant);
    V[1] := GetLevel;
    V[2] := GetIndexOfLevel(V[1]);
    Args[4] := V;
    try
      // Link to ranges
      for i := 0 to Report.OptionItems.Count - 1 do
        if (Report.OptionItems.Items[i].xlObject = xoRange) and (Report.OptionItems.Items[i].Obj = Self) then
          Report.OptionItems.Items[i].IUnk := IRange
        else
          if Report.OptionItems.Items[i].xlObject = xoColumn then begin
            Indx := Cells.IndexOf(Report.OptionItems[i].Obj);
            if (Indx <> -1) and (RangeType = rtRange) and (Cells[Indx].CellType in [ctFormula, ctField]) then begin
              {$IFDEF XLR_BCB}
              IColumn := FIRange.Columns.Item[Cells[Indx].Column, EmptyParam];
              {$ELSE}
              IDispatch(IColumn) := FIRange.Columns.Item[Cells[Indx].Column, EmptyParam];
              {$ENDIF}
              Report.OptionItems.Items[i].IUnk := IColumn;
            end;
          end;
      // Report.CheckBreak;
      Report.OptionItems.DoOptions(Self, [xoRange, xoColumn], Args);
      // xldebug
      // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourceOptionsProcessing, Self, NULL);
    finally
      Args := UnAssigned;
    end;
  end;
  // Clear special column
  if (RangeType in rtRoots) and ((FBuff as TxlBuffer).FTotalRowCount > 0) then
    FIRange.Columns.Item[1, EmptyParam].Value := '';
end;

{ TxlExcelDataSources }

function TxlExcelDataSources.GetItem(Index: integer): TxlExcelDataSource;
begin
  Result := TxlExcelDataSource( inherited GetItem(Index) );
end;

procedure TxlExcelDataSources.SetItem(Index: integer; const Value: TxlExcelDataSource);
begin
  inherited Setitem(Index, Value);
end;

function TxlExcelDataSources.Add: TxlExcelDataSource;
begin
  Result := TxlExcelDataSource( inherited Add );
end;

function TxlExcelDataSources.GetReport: TxlExcelReport;
begin
  Result := (inherited Report) as TxlExcelReport;
end;

{ TxlExcelReportParam }

function TxlExcelReportParam.GetReport: TxlExcelReport;
begin
  Result := TxlExcelReportParams(Collection).Report as TxlExcelReport;
end;

{ TxlExcelReportParams }

function TxlExcelReportParams.Add: TxlExcelReportParam;
begin
  Result := TxlExcelReportParam(inherited Add);
end;

function TxlExcelReportParams.GetReport: TxlExcelReport;
begin
  Result := TxlExcelReport(inherited Report);
end;

function TxlExcelReportParams.GetItem(Index: integer): TxlExcelReportParam;
begin
  Result := TxlExcelReportParam(inherited Items[Index]);
end;

procedure TxlExcelReportParams.SetItem(Index: integer; const Value: TxlExcelReportParam);
begin
  inherited SetItem(Index, Value);
end;

procedure TxlExcelReportParams.Build;
var
  Rng, Names, Buff, Addrs: OLEVariant;
  r, c, i: integer;
  s: string;
begin
  if Count = 0 then
    Exit;
  Buff := VarArrayCreate([1, Count + 1], varVariant);
  Names := VarArrayCreate([1, Count + 1], varVariant);
  Addrs := VarArrayCreate([1, Count + 1], varVariant);
  Buff[1] := 'XLRPARAMS';
  Names[1] := '';
  try
    r := Report.FNoRangeRow;
    c := 2;
    for i := 0 to Count - 1 do begin
      if (i + 2) mod 250 = 1 then begin
        Inc(r);
        c := 2;
      end;
      Buff[i + 2] := Items[i].Value;
      if Report.FMultisheetIndex > 0 then
        Names[i + 2] := xlrParam + '_' + IntToStr(Report.FMultisheetIndex) + '_' + Items[i].Name
      else
        Names[i + 2] := xlrParam + '_' + Items[i].Name;
      Addrs[i + 2] := '=' + xlrTempSheetName + '!' + A1Abs(r, c);
      Inc(c);
    end;
    BeforeRunMacro(Report.IXLSApp, xroHideExcel in Report.Options);
    s := '''' + Report.IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrPutNoRangeData';
    try
      Rng := OLEVariant(Report.IXLSApp).Run(s, xlrDebug, Report.FNoRangeRow, Buff, Addrs, Names, 'xlrParams');
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
      {$ENDIF}
    end;
    // xldebug
    // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeReportParams, Self, Rng);
  finally
    Report.FNoRangeRow := Report.FNoRangeRow + Count div 250 + 1;
    Names := UnAssigned;
    Buff := UnAssigned;
    Rng := UnAssigned;
  end;
end;

{ TxlExcelReport }

constructor TxlExcelReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [xroDisplayAlerts, xroAutoOpen];
  FDataMode := xdmDDE;
  {$IFNDEF XLR_VCL}
  FTempPath := xlrTempPath;
  {$ENDIF XLR_VCL}
end;

function TxlExcelReport.CreateParams: TxlAbstractParameters;
begin
  Result := TxlExcelReportParams.Create(TxlExcelReportParam, Self);
end;

// Properties

procedure TxlExcelReport.SetOptions(const Value: TxlReportOptionsSet);
var
  i: integer;
begin
  if FOptions <> Value then begin
    if (xroAutoOpen in (FOptions - Value) ) or (xroAutoOpen in (Value - FOptions)) then
      for i := 0 to DataSources.Count - 1 do
        if xroAutoOpen in Value then
          DataSources[i].Options := DataSources[i].Options + [xrgoAutoOpen]
        else
          DataSources[i].Options := DataSources[i].Options - [xrgoAutoOpen];
    if (xroAutoClose in (FOptions - Value) ) or (xroAutoClose in (Value - FOptions)) then
      for i := 0 to DataSources.Count - 1 do
        if xroAutoClose in Value then
          DataSources[i].Options := DataSources[i].Options + [xrgoAutoClose]
        else
          DataSources[i].Options := DataSources[i].Options - [xrgoAutoClose];
    FOptions := Value;
    IsRefreshParams := xroRefreshParams in Options;
  end;
end;

procedure TxlExcelReport.SetTempPath(const Value: string);
begin
{$IFDEF XLR_VCL}
  if FTempPath <> Value then begin
    DeleteFiles(FTempPath, xlrFileExtention, xlrTempFileSign);
    FTempPath := Value;
    DeleteFiles(FTempPath, xlrFileExtention, xlrTempFileSign);
  end;
{$ELSE}
  FTempPath := Value;
{$ENDIF}
end;

procedure TxlExcelReport.SetDataSources(const Value: TxlExcelDataSources);
begin
  inherited DataSources := Value;
end;

function TxlExcelReport.GetDataSources: TxlExcelDataSources;
begin
  Result := (inherited DataSources) as TxlExcelDataSources;
end;

procedure TxlExcelReport.SetParams(const Value: TxlExcelReportParams);
begin
  inherited Params := Value;
end;

function TxlExcelReport.GetParams: TxlExcelReportParams;
begin
  Result := TxlExcelReportParams(inherited Params);
end;

function TxlExcelReport.GetParamByName(Name: string): TxlExcelReportParam;
begin
  Result := TxlExcelReportParam(inherited ParamByName[Name]);
end;

procedure TxlExcelReport.SetMSAlias(const Value: string);
var
  DS: TxlExcelDataSource;
  i: integer;
begin
  if not(csLoading in ComponentState) then begin
    DS := nil;
    if Trim(Value) <> '' then begin
      for i := 0 to DataSources.Count - 1 do
        if UpperCase(Value) = UpperCase(DataSources[i].Alias) then begin
          DS := DataSources[i];
          Break;
        end;
      if Assigned(DS) then
        if (DS.Report = Self) and
          not(DS.RangeType in [rtNoRange, rtRange]) then
          {$IFNDEF XLR_VCL}
          raise ExlReportError.CreateResFmt2(ecCannotUsMSDataSource, ecCannotUsMSDataSource, [Value]);
          {$ELSE}
          raise ExlReportError.CreateResFmt(ecCannotUsMSDataSource, [Value]);
          {$ENDIF}
    end;
  end;
  FMSAlias := Trim(Value);
end;

// Events
procedure TxlExcelReport.DoOnAfterBuild;
begin
  // abstract stub
end;

procedure TxlExcelReport.DoOnBeforeBuild;
begin
  // abstract stub
end;

function TxlExcelReport.DoOnBreak: boolean;
begin
  Result := false;
end;

procedure TxlExcelReport.DoOnBeforeWorkbookSave(var WorkbookFileName,
  WorkbookFilePath: string; Save: boolean);
begin
  // abstract stub
end;

procedure TxlExcelReport.DoOnProgress(const Position, Max: integer);
begin
  // abstract stub
end;

{$IFDEF XLR_VCL}
procedure TxlExcelReport.DoOnProgress2(DataSource: TxlExcelDataSource; const RecordCount: integer);
begin
  // abstract stub
end;
{$ENDIF}

procedure TxlExcelReport.DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
  var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
  Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25,
  Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant);
begin
  // abstract stub
end;

procedure TxlExcelReport.DoOnTargetBookSheetName(
  ISourceSheet: IxlWorksheet; ITargetWorkbook: IxlWorkbook;
  var SheetName: string);
begin
  // abstract stub
end;

procedure TxlExcelReport.CheckBreak;
begin
  if DoOnBreak then
    raise ExlReportBreak.Create('Report canceled.');
end;

procedure TxlExcelReport.Connect;
var
  Ctnr: boolean;
  ExcelAuto: boolean;
  IUnk: IUnknown;
  FullFileName, ShortFileName: string;
  i, iCount: integer;
begin
  inherited;
  // xldebug
  //  FxlDebugLog := TxlDebugLog.Create(Self);
  if (DataExportMode <> xdmCSV) and (xroSaveClipboard in Options) then
    Clipboard.Open;
  FullFileName := GetFullFileName(XLSTemplate, ExtractFilePath(ParamStr(0)), false);
  ShortFileName := ExtractFileName(XLStemplate);
  FNewWorkbookName := '';
  FCanceled := false;
  if (State = rsReport) then begin
    if (FullFileName = '') or (not FileExists(FullFileName)) then
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecTemplateNotFound, ecTemplateNotFound, [FullFileName])
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecTemplateNotFound, [FullFileName])
      {$ENDIF}
  end
  else
    if State in [rsEdit] then
      if not(FileExists(FullFileName)) and (Trim(XLSTemplate)<>'') then
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecTemplateNotFound, ecTemplateNotFound, [FullFileName]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecTemplateNotFound, [FullFileName]);
        {$ENDIF}
  IUnk := nil;
  Ctnr := Assigned(OLEContainer);
  // ReportTo2 support: connect to TargetExcelApp or TargetWorkbook.Application
  if not _VarIsEmpty(FTargetExcelApp) then begin
    {$IFDEF XLR_BCB}
    FIXLApp := FTargetExcelApp;
    {$ELSE}
    IUnk := FTargetExcelApp;
    OLECheck(IUnk.QueryInterface(IxlApplication, FIXLApp));
    {$ENDIF}
  end
  else
    if VarType(FTargetWorkbook) = varDispatch then begin
      {$IFDEF XLR_BCB}
      FIXLApp := FTargetWorkbook.Application;
      {$ELSE}
      IUnk := FTargetWorkbook.Application;
      OLECheck(IUnk.QueryInterface(IxlApplication, FIXLApp));
      {$ENDIF}
    end
    else
      try
        {$IFDEF XLR_BCB}
        FIXLApp := _GetActiveOLEObject(xlrProgID);
        {$ELSE}
        FIXLApp := _GetActiveOLEObject(xlrProgID) as IxlApplication;
        {$ENDIF}
      except
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateRes2(ecExcelNotInstalled, ecExcelNotInstalled);
        {$ELSE}
        raise ExlReportError.CreateRes(ecExcelNotInstalled);
        {$ENDIF}
      end;
  //
  ExcelAuto := (xroNewInstance in Options) or (not _Assigned(FIXLApp));
  if Ctnr then
    // To OLEContainer
    try
      if (OLEContainer.State = osEmpty) then
        OLEContainer.CreateObjectFromFile(FullFileName, false);
      if OLEContainer.State <> osInplaceActive then
        OLEContainer.DoVerb(ovInPlaceActivate);
      IUnk := OLEContainer.OLEObjectInterface;
      OleCheck(IUnk.QueryInterface(IID__Workbook, FIWorkbook));
      FIXLApp := IWorkbook.Application_;
      {$IFDEF XLR_VCL}
        if not Assigned(XLEvents) then begin
          XLEvents := TxlEventsSink.Create(IXLSApp, ExcelAuto);
        end;
      {$ENDIF XLR_VCL}
      GetExcelLocaleSettings(IXLSApp);
      {$IFDEF XLR_BCB}
      IXLSApp.ScreenUpdating := false;
      {$ELSE}
      IXLSApp.ScreenUpdating[xlrLCID] := false;
      {$ENDIF}
      FIWorkbooks := IXLSApp.Workbooks;
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateRes2(ecOLEContainerError, ecOLEContainerError);
      {$ELSE}
      raise ExlReportError.CreateRes(ecOLEContainerError);
      {$ENDIF}
    end
  else begin
    // To separate Excel process
    {$IFDEF XLR_VCL}
      if not Assigned(XLEvents) then begin
        if ExcelAuto then
          {$IFDEF XLR_BCB}
          FIXLApp := _CreateOLEObject(xlrProgID);
          {$ELSE}
          FIXLApp := _CreateOLEObject(xlrProgID) as IxlApplication;
          {$ENDIF}
        XLEvents := TxlEventsSink.Create(IXLSApp, ExcelAuto);
      end
      else FIXLApp := XLEvents.IXLApp;
    {$ELSE}
      if ExcelAuto then
        FIXLApp := _CreateOLEObject(xlrProgID) as IxlApplication;
    {$ENDIF XLR_VCL}
    GetExcelLocaleSettings(IXLSApp);
    // Comment for version 4.1
    // if xlrDebug then
    //  ShowExcel(FIXLApp, Assigned(FOLEContainer), false, FLastWindowState, FLastLeft, FLastTop)
    // else
    {$IFDEF XLR_BCB}
    if (State = rsReport) and not(xroHideExcel in Options) then begin
      FLastWindowState := IXLSApp.WindowState;
      FLastLeft := IXLSApp.Left;
      FLastTop := IXLSApp.Top;
      if not xlrExcelHost then begin
        if IXLSApp.Visible then
          IXLSApp.Visible := false;
        IXLSApp.WindowState := TOLEEnum(xlMinimized);
        if IXLSApp.WindowState <> TOLEEnum(xlMaximized) then begin
          IXLSApp.Left := 10000;
          IXLSApp.Top := 10000;
        end;
        IXLSApp.Visible := true;
      end;
      IXLSApp.ScreenUpdating := true;
    end;
    {$ELSE}
    if (State = rsReport) and not(xroHideExcel in Options) then begin
      FLastWindowState := IXLSApp.WindowState[xlrLCID];
      FLastLeft := IXLSApp.Left[xlrLCID];
      FLastTop := IXLSApp.Top[xlrLCID];
      if not xlrExcelHost then begin
        if IXLSApp.Visible[xlrLCID] then
          IXLSApp.Visible[xlrLCID] := false;
        IXLSApp.WindowState[xlrLCID] := TOLEEnum(xlMinimized);
        if IXLSApp.WindowState[xlrLCID] <> TOLEEnum(xlMaximized) then begin
          IXLSApp.Left[xlrLCID] := 10000;
          IXLSApp.Top[xlrLCID] := 10000;
        end;
        IXLSApp.Visible[xlrLCID] := true;
      end;
      IXLSApp.ScreenUpdating[xlrLCID] := True;
    end;
    {$ENDIF}
    //
    {$IFDEF XLR_BCB}
    IXLSApp.Interactive := false;
    IXLSApp.ScreenUpdating := false;
    IXLSApp.DisplayAlerts := xroDisplayAlerts in FOptions;
    {$ELSE}
    IXLSApp.Interactive[xlrLCID] := false;
    IXLSApp.ScreenUpdating[xlrLCID] := false;
    IXLSApp.DisplayAlerts[xlrLCID] := xroDisplayAlerts in FOptions;
    {$ENDIF}
    FIWorkbooks := IXLSApp.Workbooks;
    iCount := IWorkbooks.Count;
    for i := 1 to iCount do
      if UpperCase(IWorkbooks.Item[i].Name) = UpperCase(ShortFileName) then
        if State = rsReport then
          {$IFNDEF XLR_VCL}
          raise ExlReportError.CreateResFmt2(ecTemplateAlreadyOpen, ecTemplateAlreadyOpen, [ShortFileName])
          {$ELSE}
          raise ExlReportError.CreateResFmt(ecTemplateAlreadyOpen, [ShortFileName])
          {$ENDIF}
        else begin
          FIWorkbook := IWorkbooks.Item[i];
          MessageDlg(Format(LoadStr(ecTemplateAlreadyOpen), [ShortFileName]), mtInformation, [mbOk], 0);
        end;
    case State of
      {$IFDEF XLR_BCB}
      rsReport: FIWorkbook := IWorkbooks.Add(FullFileName);
      rsEdit: if not _Assigned(IWorkbook) then
                if XLSTemplate = '' then
                  FIWorkbook := IWorkbooks.Add(EmptyParam)
                else
                  FIWorkbook := IWorkbooks.Open(FullFileName, EmptyParam, EmptyParam,
                    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
                    EmptyParam, EmptyParam, EmptyParam, (xroAddToMRU in FOptions));
      {$ELSE}
      rsReport: FIWorkbook := IWorkbooks.Add(FullFileName, xlrLCID);
      rsEdit: if not _Assigned(IWorkbook) then
                if XLSTemplate = '' then
                  FIWorkbook := IWorkbooks.Add(EmptyParam, xlrLCID)
                else
                  FIWorkbook := IWorkbooks.Open(FullFileName, EmptyParam, EmptyParam,
                    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
                    EmptyParam, EmptyParam, EmptyParam, (xroAddToMRU in FOptions), xlrLCID);
      {$ENDIF}
    end;
  end;
  // Add report to global ExcelEventSink
  {$IFDEF XLR_VCL}
  if Assigned(XLEvents) then
    XLEvents.AddReport(Self, OLEContainer);
  {$ENDIF XLR_VCL}
  FNoRangeRow := xlrStartNoRangeRow;
  FTemplateRow := xlrTemplateRowsStart;
  // xldebug
  //  TxlDebugLog(FxlDebugLog).AddToLog(xdeReportConnect, Self, ExcelAuto);
end;

procedure TxlExcelReport.Disconnect;
begin
  // xldebug
  // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportDisconnect, Self, '');
  // TxlDebugLog(FxlDebugLog).PutToExcel;
  // FxlDebugLog.Free;
  // ReportTo2 support: release used interfaces
  FTargetExcelApp := UnAssigned;
  FTargetWorkbook := UnAssigned;
  // Clear VB-Module
  if (not _VarIsEmpty(IModule)) and (not xlrDebug) then begin
    IModule.CodeModule.DeleteLines(1, IModule.CodeModule.CountOfLines);
    FIModule.Collection.Remove(FIModule);
  end;
  // Calculate
  if (State = rsReport) and (xroCalculationManual in Options) then begin
    {$IFDEF XLR_BCB}
    IXLSApp.Calculation := FLastCalculation;
    IXLSApp.Calculate;
    {$ELSE}
    IXLSApp.Calculation[xlrLCID] := FLastCalculation;
    IXLSApp.Calculate(xlrLCID);
    {$ENDIF}
  end;                     
  // Release used interfaces
  FIModule := UnAssigned;
  _Clear(FIWorksheetFunction);
  _Clear(FINames);
  _Clear(FIMultiSheet);
  _Clear(FITempSheet);
  _Clear(FIWorksheets);
  if Trim(FNewWorkbookName) <> '' then begin
    // Delete file if xroHideExcel set on and file exists
    if (xroHideExcel in Options) and not(xroDisplayAlerts in Options) then
      if FileExists(FNewWorkbookName) then
        DeleteFile(PChar(FNewWorkbookName));
    {$IFDEF XLR_BCB}
    IWorkbook.SaveAs(FNewWorkbookName, EmptyParam, EmptyParam, EmptyParam, false,
      EmptyParam, xlExclusive, xlLocalSessionChanges, false, EmptyParam, EmptyParam);
    {$ELSE}
    IWorkbook.SaveAs(FNewWorkbookName, EmptyParam, EmptyParam, EmptyParam, false,
      EmptyParam, xlExclusive, xlLocalSessionChanges, false, EmptyParam, EmptyParam, xlrLCID);
    {$ENDIF}
  end
  else
    if (State = rsReport)  and (xroAutoSave in Options) then
      SaveInTempFile;
  // For merge report support
  if _Assigned(IWorkbook) then begin
    FLastWorkbookName := IWorkbook.Name;
    if ((xroHideExcel in Options) and (not FMerged) and (State <> rsEdit)) or (FCanceled) then
      {$IFDEF XLR_BCB}
      IWorkbook.Close(false, EmptyParam, EmptyParam);
      {$ELSE}
      IWorkbook.Close(false, EmptyParam, EmptyParam, xlrLCID);
      {$ENDIF}
    _Clear(FIWorkbook);
  end;  
  _Clear(FIWorkbooks);
  if (xroHideExcel in Options) and (not FMerged) and (State <> rsEdit) then begin
    FIXLApp.Quit;
  end;
  _Clear(FIXLApp);
  {$IFDEF XLR_VCL}
  if Assigned(XLEvents) then
    if Assigned(OLEContainer) or XLEvents.CanDisconnect then
      XLEvents.DisconnectXL;
  {$ENDIF XLR_VCL}
  if (DataExportMode <> xdmCSV) and (xroSaveClipboard in Options) then;
    Clipboard.Close;
  FCanceled := false;
  inherited Disconnect;
end;

procedure TxlExcelReport.BeforeBuild;
var
  TempSheetNotFound: boolean;
  i, iCount: integer;
  IR: IxlRange;
  IActiveSheet: OLEVariant;
  {$IFNDEF XLR_BCB}
  IUnk: IUnknown;
  {$ENDIF}
  IWbk: IxlWorkbook;
  V: OLEVariant;
begin
  // Get used interfaces
  {$IFDEF XLR_BCB}
  FIWorksheets := IWorkbook.Worksheets;
  if xroCalculationManual in Options then begin
    FLastCalculation := IXLSApp.Calculation;
    IXLSApp.Calculation := TOLEEnum(xlCalculationManual);
  end;
  {$ELSE}
  FIWorksheets := IWorkbook.Worksheets as IxlWorksheets;
  if xroCalculationManual in Options then begin
    FLastCalculation := IXLSApp.Calculation[xlrLCID];
    IXLSApp.Calculation[xlrLCID] := TOLEEnum(xlCalculationManual);
  end;  
  {$ENDIF}
  V := FIWorkbook.ActiveChart;
  if _VarIsEmpty(V) then
    IActiveSheet := IWorkbook.ActiveSheet
  else begin
    IActiveSheet := V;
    {$IFDEF XLR_BCB}
    IWbk := IActiveSheet.Parent;
    {$ELSE}
    IUnk := IActiveSheet.Parent;
    IUnk.QueryInterface(IxlWorkbook, IWbk);
    {$ENDIF}
    if not _Assigned(IWbk) then
      IActiveSheet := V.Parent.Parent;
  end;
  if FReportTo2 then
    FLastActiveSheetName := ''
  else
    FLastActiveSheetName := IActiveSheet.Name;
  FIWorksheetFunction := IXLSApp.WorksheetFunction;
  FINames := IWorkbook.Names;
  if not _Assigned(IWorkbook) then
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateRes2(ecWorkbookNotFound, ecWorkbookNotFound);
    {$ELSE}
    raise ExlReportError.CreateRes(ecWorkbookNotFound);
    {$ENDIF}
  if State = rsReport then begin
    // Init environment
    { NotSupported
    IXLSApp.PivotTableSelection := roPivotTableSelection in FOptions;
    }
    {$IFDEF XLR_BCB}
    if IXLSApp.IgnoreRemoteRequests then
      IXLSApp.IgnoreRemoteRequests := false;
    {$ELSE}
    if IXLSApp.IgnoreRemoteRequests[xlrLCID] then
      IXLSApp.IgnoreRemoteRequests[xlrLCID] := false;
    {$ENDIF}
    // Create XLRModule
    iCount := OLEVariant(IWorkbook).VBProject.VBComponents.Count;
    for i := iCount downto 1 do
      if OLEVariant(IWorkbook).VBProject.VBComponents.Item(i).Name = xlrModuleName then begin
        FIModule := OLEVariant(IWorkbook).VBProject.VBComponents.Item(i);
        Break;
      end;
    if _VarIsEmpty(IModule) then begin
      FIModule := OLEVariant(IWorkbook).VBProject.VBComponents.Add(TOLEEnum(vbext_ct_StdModule));
      IModule.Name := xlrModuleName;
      IModule.CodeModule.AddFromString(xlrVBAModuleLevel);
      if GetOptionMap.ModuleLevelCode <> '' then
        IModule.CodeModule.AddFromString(GetOptionMap.ModuleLevelCode);
      IModule.CodeModule.AddFromString(xlrVBAProcs);
      if GetOptionMap.LibraryCode <> '' then
        IModule.CodeModule.AddFromString(GetOptionMap.LibraryCode);
    end;
    // Create temporary sheet
    TempSheetNotFound := true;
    iCount := IWorksheets.Count;
    for i := 1 to iCount do begin
      {$IFDEF XLR_BCB}
      FITempSheet := IWorksheets.Item[i];
      {$ELSE}
      FITempSheet := IWorksheets.Item[i] as IxlWorksheet;
      {$ENDIF}
      if UpperCase(ITempSheet.Name) = UpperCase(xlrTempSheetName) then begin
        TempSheetNotFound := false;
        {$IFDEF XLR_BCB}
        ITempSheet.UsedRange.Rows.Delete(TOLEEnum(xlShiftUp));
        {$ELSE}
        ITempSheet.UsedRange[xlrLCID].Rows.Delete(TOLEEnum(xlShiftUp));
        {$ENDIF}
        Break;
      end;
    end;
    if TempSheetNotFound then begin
      _Clear(FITempSheet);
      {$IFDEF XLR_BCB}
      FITempSheet := IWorksheets.Add(EmptyParam,
        IWorksheets.Item[IWorksheets.Count], EmptyParam, EmptyParam);
      ITempSheet.Name := xlrTempSheetName;
      ITempSheet.Visible := IIF(xlrDebug, TOLEEnum(xlSheetVisible), TOLEEnum(xlSheetVeryHidden));
      {$ELSE}
      FITempSheet := IWorksheets.Add(EmptyParam,
        IWorksheets.Item[IWorksheets.Count], EmptyParam, EmptyParam, xlrLCID) as IxlWorkSheet;
      ITempSheet.Name := xlrTempSheetName;
      ITempSheet.Visible[xlrLCID] := IIF(xlrDebug, TOLEEnum(xlSheetVisible), TOLEEnum(xlSheetVeryHidden));
      {$ENDIF}
      IActiveSheet.Parent.Activate;
      IActiveSheet.Activate;
    end;
  end; // if State = rsReport
  { Create add info }
  // XLR_VERSION
  {$IFDEF XLR_BCB}
  IR := ITempSheet.Cells.Item[FNoRangeRow, 1];
  {$ELSE}
  IDispatch(IR) := ITempSheet.Cells.Item[FNoRangeRow, 1];
  {$ENDIF}
  IR.Value := '''' + xlrVersionStr;
  INames.Add( lexXLRVersion, '=' + xlrTempSheetName + '!' + A1Abs(FNoRangeRow, 1),
    false, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam );
  INames.Add( lexXLRErrValueStr, '=' + xlrTempSheetName + '!' + A1Abs(FNoRangeRow, 2),
    false, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam );
  IR := IR.Offset[0, 1];
  IR.Formula := '=XLR_ERRNAME';
  Inc(FNoRangeRow);
  // xldebug
  // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportBeforeBuild, Self, NULL);
end;

procedure TxlExcelReport.AfterBuild;
{$IFDEF XLR_TRIAL}
{$I xlDoRestrict2.inc}
{$ENDIF XLR_TRIAL}
begin
  {$IFDEF XLR_TRIAL}
  DoRestrict2(true);
  {$ENDIF XLR_TRIAL}
  // Clear TempSheet
  if (not xlrDebug) and (not FReportTo2) then
    ITempSheet.Range[A1(xlrTemplateRowsStart, 1),
      A1(Self.FTemplateRow + 1, xlrMaxColCount)].Delete(TOLEEnum(xlShiftUp));
  // xldebug
  // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportAfterBuild, Self, NULL);
end;

procedure TxlExcelReport.SaveInTempFile;
var
  p: integer;
  Save: boolean;
  WorkbookFileName, WorkbookFilePath, timestamp: string;
  OldWorkbookFileName, OldWorkbookFilePath: string;
begin
  Save := true;
  WorkbookFileName := ExtractFileName(IWorkbook.Name);
  OldWorkbookFileName := WorkbookFileName;
  if TempPath <> '' then
    if TempPath[Length(TempPath)] <> '\' then
      WorkbookFilePath := TempPath + '\'
    else
      WorkbookFilePath := TempPath
  else
    WorkbookFilePath := ExtractFilePath(ParamStr(0));
  {$IFDEF XLR_BCB}
  OldWorkbookFilePath := IWorkbook.Path;
  {$ELSE}
  OldWorkbookFilePath := IWorkbook.Path[xlrLCID];
  {$ENDIF}
  try
    // UseTemp
    if xroUseTemp in Options then begin
      timestamp := DatetimeToStr(now);
      DeleteChars('.', timestamp);
      DeleteChars(':', timestamp);
      p := pos('.', WorkbookFileName);
      if p <> 0 then
        WorkbookFileName := copy(WorkbookFileName, 1, p-1);
      WorkbookFileName := WorkbookFileName + '          ' + timestamp + ' ' + xlrTempFileSign;
    end;
    // DoEvent
    DoOnBeforeWorkbookSave(WorkbookFileName, WorkbookFilePath, Save);
    if Save then begin
      // Check file path
      if (WorkbookFilePath[Length(WorkbookFilePath)] <> '\') and
        (WorkbookFileName[1] <> '\') then
        if WorkbookFilePath <> '' then
          WorkbookFilePath := WorkbookFilePath + '\';
      // Check changes
      if (UpperCase(OldWorkbookFileName) = UpperCase(WorkbookFileName)) and
         (UpperCase(OldWorkbookFilePath) = UpperCase(WorkbookFilePath)) then
        {$IFDEF XLR_BCB}
        IWorkbook.Save
        {$ELSE}
        IWorkbook.Save(xlrLCID)
        {$ENDIF}
      else begin
        // Delete file if xroHideExcel set on and file exists
        if (xroHideExcel in Options) and not(xroDisplayAlerts in Options) then
          if FileExists(WorkbookFilePath + WorkbookFileName) then
            DeleteFile(PChar(WorkbookFilePath + WorkbookFileName));
        {$IFDEF XLR_BCB}
        IWorkbook.SaveAs(WorkbookFilePath + WorkbookFileName,
          EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, xlExclusive,
          EmptyParam, false, EmptyParam, EmptyParam);
        {$ELSE}
        IWorkbook.SaveAs(WorkbookFilePath + WorkbookFileName,
          EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, xlExclusive,
          EmptyParam, false, EmptyParam, EmptyParam, xlrLCID);
        {$ENDIF}
      end;
    end;
    // xldebug
    // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportSaveTemp, Self, WorkbookFilePath + WorkbookFileName);
  except
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateRes2(ecSaveInTempError, ecSaveInTempError);
    {$ELSE}
    raise ExlReportError.CreateRes(ecSaveInTempError);
    {$ENDIF}
  end;
end;

procedure TxlExcelReport.MacroProcessing(const MacroType: TxlMacroType; const MacroName: string);
var
  vArg1, vArg2, vArg3, vArg4, vArg5, vArg6, vArg7, vArg8, vArg9, vArg10,
  vArg11, vArg12, vArg13, vArg14, vArg15, vArg16, vArg17, vArg18, vArg19, vArg20,
  vArg21, vArg22, vArg23, vArg24, vArg25, vArg26, vArg27, vArg28, vArg29, vArg30: OLEVariant;
var
  s: string;
begin
  if MacroName <> '' then
  try
    try
      vArg1:= EmptyParam; vArg2:= EmptyParam; vArg3:= EmptyParam; vArg4:= EmptyParam;
      vArg5:= EmptyParam; vArg6:= EmptyParam; vArg7:= EmptyParam; vArg8:= EmptyParam;
      vArg9:= EmptyParam; vArg10:= EmptyParam; vArg11:= EmptyParam; vArg12:= EmptyParam;
      vArg13:= EmptyParam; vArg14:= EmptyParam; vArg15:= EmptyParam; vArg16:= EmptyParam;
      vArg17:= EmptyParam; vArg18:= EmptyParam; vArg19:= EmptyParam; vArg20:= EmptyParam;
      vArg21:= EmptyParam; vArg22:= EmptyParam; vArg23:= EmptyParam; vArg24:= EmptyParam;
      vArg25:= EmptyParam; vArg26:= EmptyParam; vArg27:= EmptyParam; vArg28:= EmptyParam;
      vArg29:= EmptyParam; vArg30:= EmptyParam;
      DoOnMacro(MacroType, MacroName,
        vArg1, vArg2, vArg3, vArg4, vArg5, vArg6, vArg7, vArg8, vArg9, vArg10,
        vArg11, vArg12, vArg13, vArg14, vArg15, vArg16, vArg17, vArg18, vArg19, vArg20,
        vArg21, vArg22, vArg23, vArg24, vArg25, vArg26, vArg27, vArg28, vArg29, vArg30);
      BeforeRunMacro(IXLSApp, xroHideExcel in Options);
      s := '''' + IWorkbook.Name + '''' + '!' + MacroName;
      IXLSApp.Run(s,
        vArg1, vArg2, vArg3, vArg4, vArg5, vArg6, vArg7, vArg8, vArg9, vArg10,
        vArg11, vArg12, vArg13, vArg14, vArg15, vArg16, vArg17, vArg18, vArg19, vArg20,
        vArg21, vArg22, vArg23, vArg24, vArg25, vArg26, vArg27, vArg28, vArg29, vArg30);
      // xldebug
      // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportMacroProcessing, Self, VarArrayOf([MacroType, MacroName]));
    finally
      vArg1 := UnAssigned; vArg2 := UnAssigned; vArg3 := UnAssigned; vArg4 := UnAssigned;
      vArg5 := UnAssigned; vArg6 := UnAssigned; vArg7 := UnAssigned; vArg8 := UnAssigned;
      vArg9 := UnAssigned; vArg10 := UnAssigned; vArg11 := UnAssigned; vArg12 := UnAssigned;
      vArg13 := UnAssigned; vArg14 := UnAssigned; vArg15 := UnAssigned; vArg16 := UnAssigned;
      vArg17 := UnAssigned; vArg18 := UnAssigned; vArg19 := UnAssigned; vArg20 := UnAssigned;
      vArg21 := UnAssigned; vArg22 := UnAssigned; vArg23 := UnAssigned; vArg24 := UnAssigned;
      vArg25 := UnAssigned; vArg26 := UnAssigned; vArg27 := UnAssigned; vArg28 := UnAssigned;
      vArg29 := UnAssigned; vArg30 := UnAssigned;
    end;
  except
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [MacroName] );
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [MacroName] );
    {$ENDIF}
  end;
end;

procedure TxlExcelReport.Show;
var
  LastActiveSheet, Sheet: OLEVariant;
  {$IFNDEF XLR_BCB}
  IUnk: IUnknown;
  ISh: IxlWorksheet;
  {$ENDIF}
  i: integer;
begin
  if not(xroHideExcel in Options) or (State = rsEdit) then begin
    if State = rsReport then begin
      if not FMerged then
        if xlrDebug then
          ShowExcel(FIXLApp, Assigned(FOLEContainer), true, FLastWindowState, FLastLeft, FLastTop)
        else
          ShowExcel(FIXLApp, Assigned(FOLEContainer), State in [rsReport], FLastWindowState, FLastLeft, FLastTop);
      // Select active object
      if (ActiveSheet <> '') and (not FReportTo2) then
        try
          Sheet := FIWorkbook.Sheets.Item[ActiveSheet];
          Sheet.Activate;
          {$IFNDEF XLR_BCB}
          IUnk := Sheet;
          IUnk.QueryInterface(IxlWorksheet, ISh);
          if _Assigned(ISh) then
            IXLSApp.Range[ 'A1', 'A1'].Select;
          {$ENDIF}
        except
          on E: Exception do
            {$IFNDEF XLR_VCL}
            raise ExlReportError.CreateResFmt2(ecSheetNotFound, ecSheetNotFound, [ActiveSheet]);
            {$ELSE}
            raise ExlReportError.CreateResFmt(ecSheetNotFound, [ActiveSheet]);
            {$ENDIF}
        end
      else begin
        if not HandleException then
          for i := 1 to IWorksheets.Count do begin
             Sheet := IWorksheets.Item[i];
             if Sheet.Name = FLastActiveSheetName then
               LastActiveSheet := Sheet;
          end;
        if not _VarIsEmpty(LastActiveSheet) then begin
          Sheet := FIWorkbook.ActiveChart;
          if _VarIsEmpty(Sheet) and (LastActiveSheet.Visible = TOLEEnum(xlSheetVisible)) then begin
            LastActiveSheet.Activate;
            {$IFDEF XLR_BCB}
            IXLSApp.Goto(xlrLocaleR +'1' + xlrLocaleC + '1', true);
            {$ELSE}
            IXLSApp.Goto_(xlrLocaleR +'1' + xlrLocaleC + '1', true, xlrLCID);
            {$ENDIF}
          end;
        end;
      end;
      if FPreview then
        {$IFDEF XLR_BCB}
        IWorkbook.PrintPreview(false);
        {$ELSE}
        IWorkbook.PrintPreview(false, xlrLCID);
        {$ENDIF}
    end
    else
      {$IFDEF XLR_BCB}
      if State = rsEdit then begin
        if _Assigned(IXLSApp) then begin
          IXLSApp.Interactive := true;
          if IXLSApp.WindowState = TOLEEnum(xlMinimized) then
            IXLSApp.WindowState := TOLEEnum(xlNormal);
          IXLSApp.Visible := true;
          if IXLSApp.WindowState = TOLEEnum(xlMinimized) then
            IXLSApp.WindowState := TOLEEnum(xlNormal);
          IXLSApp.ScreenUpdating := true;
          IXLSApp.DisplayAlerts := true;
        end;
      end;
      {$ELSE}
      if State = rsEdit then begin
        if _Assigned(IXLSApp) then begin
          IXLSApp.Interactive[xlrLCID] := true;
          if IXLSApp.WindowState[xlrLCID] = TOLEEnum(xlMinimized) then
            IXLSApp.WindowState[xlrLCID] := TOLEEnum(xlNormal);
          IXLSApp.Visible[xlrLCID] := true;
          if IXLSApp.WindowState[xlrLCID] = TOLEEnum(xlMinimized) then
            IXLSApp.WindowState[xlrLCID] := TOLEEnum(xlNormal);
          IXLSApp.ScreenUpdating[xlrLCID] := true;
          IXLSApp.DisplayAlerts[xlrLCID] := true;
        end;
      end;
      {$ENDIF}
  end;
  // xldebug
  //  TxlDebugLog(FxlDebugLog).AddToLog(xdeReportShow, Self, NULL);
end;

procedure TxlExcelReport.ErrorProcessing(E: Exception; var Raised: boolean);
{$IFDEF XLR_TRIAL}
{$I xlDoRestrict2.inc}
{$ENDIF XLR_TRIAL}
begin
  // xldebug
  // TxlDebugLog(FxlDebugLog).AddToLog(xdeErrorProcessing, Self, E.Message );
  if E is ExlReportBreak then
    Raised := false;
  if Raised then begin
    if _Assigned(FIXLApp) then begin
      {$IFDEF XLR_TRIAL}
      if (not _VarIsEmpty(IModule)) and (not xlrDebug) then begin
        FIModule.Collection.Remove(FIModule);
        FIModule := UnAssigned;
      end;
      if _Assigned(FIWorkbook) then
        DoRestrict2(true);
      {$ENDIF XLR_TRIAL}
      Show(true);
    end;
    if Application <> nil then
      if not(csDestroying in Application.ComponentState) then
        Application.BringToFront;
  end
  else begin
    if Application <> nil then
      if not(csDestroying in Application.ComponentState) then
        Application.BringToFront;
    if not(E is ExlReportBreak) then
      MessageDlg(E.Message, mtError, [mbCancel], 0);
    if _Assigned(FIXLApp) then begin
    {$IFDEF XLR_TRIAL}
    if _Assigned(FIWorkbook) then
      DoRestrict2(true);
    {$ENDIF XLR_TRIAL}
      Show(true);
    end;
  end;
end;

procedure TxlExcelReport.Parse;
var
  ReportOptions, SheetOptions: string;
  ISheet: IxlWorksheet;
  ISheetOptionCell, IReportOptionCell: IxlRange;
  i, iCount: integer;
begin
  { Scan worksheet/report options }
  iCount := IWorksheets.Count;
  for i := 1 to iCount do begin
    {$IFDEF XLR_BCB}
    ISheet := IWorksheets.Item[i];
    {$ELSE}
    ISheet := IWorksheets.Item[i] as IxlWorksheet;
    {$ENDIF}
    if ISheet.Name = ITempSheet.Name then
      Continue;
    // sheet options
    {$IFDEF XLR_BCB}
    ISheetOptionCell :=
      ISheet.Cells.Item[xlrSheetOptionsRow, xlrSheetOptionsColumn];
    {$ELSE}
    IDispatch(ISheetOptionCell) :=
      ISheet.Cells.Item[xlrSheetOptionsRow, xlrSheetOptionsColumn];
    {$ENDIF}
    SheetOptions := ISheetOptionCell.FormulaLocal;
    if OptionItems.ParseOptionsStr(Self, ISheet, xoWorksheet, SheetOptions) then
     ClearRangeContents(ISheetOptionCell);
    // report options
    {$IFDEF XLR_BCB}
    IReportOptionCell :=
      ISheet.Cells.Item[xlrReportOptionsRow, xlrReportOptionsColumn];
    {$ELSE}
    IDispatch(IReportOptionCell) :=
      ISheet.Cells.Item[xlrReportOptionsRow, xlrReportOptionsColumn];
    {$ENDIF}
    ReportOptions := IReportOptionCell.FormulaLocal;
    if OptionItems.ParseOptionsStr(Self, IWorkbook, xoWorkbook, ReportOptions) then
     ClearRangeContents(IReportOptionCell);
  end;
  // xldebug
  // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportParse, Self, NULL);
end;

procedure TxlExcelReport.OptionsProcessing;
var
  Args: OLEvariant;
  ProcName: string;
begin
  // Options processing
  Args := '';
  try
    ProcName := GetTempName(xlrVBAReportOptionsSubName);
    OptionItems.DoOptions(Self, [xoWorksheet], Args);
    OptionItems.DoOptions(Self, [xoWorkbook], Args);
    if Trim(Args) <> '' then begin
      Args :=
        'SUB ' + ProcName + ' ()' + vbCR +
          Args + vbCR +
        'END SUB';
      IModule.CodeModule.AddFromString(Args);
      BeforeRunMacro(IXLSApp, xroHideExcel in Options);
      ProcName := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + ProcName;
      try
        OLEVariant(IXLSApp).Run(ProcName);
      except
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [ProcName]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [ProcName]);
        {$ENDIF}
      end;
    end;
    BeforeRunMacro(IXLSApp, xroHideExcel in Options);
    ProcName := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + xlrVBAGotoA1;
    try
      OLEVariant(IXLSApp).Run(ProcName);
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [ProcName]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [ProcName]);
      {$ENDIF}
    end;
  finally
    Args := UnAssigned;
  end;
  // xldebug
  // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportOptionsProcessing, Self, NULL);
end;

procedure TxlExcelReport.RefreshParams(const ClearParams: boolean);

  procedure UpdateParams(const Formula: string);
  var
    CurPos, i: integer;
    s, p: string;
    Param: TxlExcelReportParam;
    AlreadyExists: boolean;
  begin
    s := Formula;
    CurPos := pos(xlrParam + delFldFormula, UpperCase(s));
    while CurPos > 0 do begin
      i := CurPos + Length(xlrParam + delFldFormula);
      while CharInSet(s[i], ['A'..'Z', 'a'..'z', '0'..'9', '.', '_']) do begin
        Inc(i);
        if i > Length(s) then
          Break;
      end;
      p := Copy(s, CurPos, i - CurPos);
      Delete(p, 1, Length(xlrParam + delFldFormula));
      Delete(s, CurPos, Length(xlrParam + delFldFormula));
      AlreadyExists := false;
      for i := 0 to Params.Count - 1 do begin
        AlreadyExists := UpperCase(Params[i].Name) = UpperCase(p);
        if AlreadyExists then
          Break;
      end;
      if not AlreadyExists then begin
        Param := Params.Add;
        Param.Name := p;
      end;
      CurPos := pos(xlrParam + delFldFormula, UpperCase(s));
    end;
  end;

var
  i, row, col, RowCount, ColCount: integer;
  ISh: IxlWorksheet;
  IR: IxlRange;
  V: OLEVariant;
begin
  if ClearParams then
    Params.Clear;
  for i := 1 to FIWorkbook.Worksheets.Count do begin
    {$IFDEF XLR_BCB}
    ISh := FIWorkbook.Worksheets.Item[i];
    if ISh.Visible = TOLEEnum(xlSheetVisible) then begin
      IR := ISh.UsedRange;
    {$ELSE}
    ISh := FIWorkbook.Worksheets.Item[i] as IxlWorksheet;
    if ISh.Visible[xlrLCID] = TOLEEnum(xlSheetVisible) then begin
      IR := ISh.UsedRange[xlrLCID];
    {$ENDIF}
      RowCount := IR.Rows.Count;
      ColCount := IR.Columns.Count;
      V := IR.Formula;
      for row := 1 to RowCount do
        for col := 1 to ColCount do begin
          if pos(xlrParam + delFldFormula, UpperCase(V[row, col])) > 0 then
            UpdateParams(V[row, col]);
        end;
    end;
  end;
end;

// class methods
class function TxlExcelReport.GetOptionMap: TxlOptionMap;
begin
  Result := xlrOptionMap;
end;

class procedure TxlExcelReport.ReleaseExcelApplication;
begin
  {$IFDEF XLR_VCL}
    if Assigned(XLEvents) then
      if _Assigned(XLEvents.IXLApp) then
        XLEvents.DisconnectXL;
  {$ENDIF XLR_VCL}
end;

class procedure TxlExcelReport.ConnectToExcelApplication(OLEObject: OLEVariant);
var
  IDsp: IDispatch;
  IXLS: IxlApplication;
begin
  ReleaseExcelApplication;
  if not _VarIsEmpty(OLEObject) then begin
    IDsp := OLEObject;
    {$IFDEF XLR_BCB}
    OleCheck(IDsp.QueryInterface(Excel8G2.IID__Application, IXLS));
    {$ELSE}
    OleCheck(IDsp.QueryInterface(IxlApplication, IXLS));
    {$ENDIF}
    {$IFDEF XLR_VCL}
    if not Assigned(XLEvents) then
      XLEvents := TxlEventsSink.Create(IXLS, false);
    {$ENDIF XLR_VCL}
  end;
end;

procedure TxlExcelReport.Report;
var
  OLDDebug: boolean;
begin
  {$IFNDEF XLR_VCL}
  if State <> rsNotActive then
    Exit;
  {$ENDIF}
  if (MultisheetAlias <> '') and (MultisheetField <> '') then
    MultisheetReport(MultisheetAlias, MultisheetField)
  else begin
    OLDDebug := xlrDebug;
    {$IFNDEF XLR_TRIAL}
    xlrDebug := Self.Debug or xlrDebug;
    {$ENDIF}
    try
      inherited Report;
    finally
      xlrDebug := OLDDebug;
    end;
  end;
end;

procedure TxlExcelReport.ReportTo(const WorkbookName: string; const NewWorkbookName: string = '');
{$IFDEF XLR_TRIAL}
  {$I xlDoRestrict2.inc}
{$ENDIF XLR_TRIAL}
  procedure AddToWorkbook(const WokbookName: string; const NewWorkbookName: string);
  var
    ITmpWorkbook, ITargetWorkbook: IxlWorkbook;
    ISourceSheet, INewSheet: IxlWorksheet;
    AlreadyOpen: boolean;
    i: integer;
    s, NewSheetName: string;
  begin
    if WorkbookName <> '' then begin
      NewSheetName := '';
      // Open workbook
      AlreadyOpen := false;
      s := ExtractFileName(WorkbookName);
      for i := 1 to IWorkbooks.Count do begin
        AlreadyOpen := Uppercase(IWorkbooks.Item[i].Name) = UpperCase(s);
        if AlreadyOpen then begin
          ITargetWorkbook := IWorkbooks.Item[i];
          Break;
        end;
      end;
      if not AlreadyOpen then begin
        s := GetFullFileName(WorkbookName, ExtractFilePath(ParamStr(0)), false);
        {$IFDEF XLR_BCB}
        ITargetWorkbook := IWorkbooks.Open(s, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam, false);
        {$ELSE}
        ITargetWorkbook := IWorkbooks.Open(s, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam, false, xlrLCID);
        {$ENDIF}
      end;
      // Copy worksheets
      for i := 1 to IWorksheets.Count do begin
        {$IFDEF XLR_BCB}
        ISourceSheet := IWorksheets.Item[i];
        {$ELSE}
        ISourceSheet := IWorksheets.Item[i] as IxlWorksheet;
        {$ENDIF}
        {$IFDEF XLR_BCB}
        if (ISourceSheet.Name <> xlrTempSheetName) and
          (ISourceSheet.Visible = xlSheetVisible) then begin
          ISourceSheet.UsedRange.Copy(EmptyParam);
          ISourceSheet.UsedRange.PasteSpecial(TOLEEnum(xlPasteValues),
            TOLEEnum(xlPasteSpecialOperationNone), false, false);
          ISourceSheet.Copy(EmptyParam,
            ITargetWorkbook.Worksheets.Item[ITargetWorkbook.Worksheets.Count]);
          INewSheet := ITargetWorkbook.Worksheets.
            Item[ITargetWorkbook.Worksheets.Count];
          {$ELSE}
        if (ISourceSheet.Name <> xlrTempSheetName) and
          (ISourceSheet.Visible[xlrLCID] = TOLEEnum(xlSheetVisible)) then begin
          ISourceSheet.UsedRange[xlrLCID].Copy(EmptyParam);
          ISourceSheet.UsedRange[xlrLCID].PasteSpecial(TOLEEnum(xlPasteValues),
            TOLEEnum(xlPasteSpecialOperationNone), false, false);
          ISourceSheet.Copy(EmptyParam,
            ITargetWorkbook.Worksheets.Item[ITargetWorkbook.Worksheets.Count], xlrLCID);
          INewSheet := ITargetWorkbook.Worksheets.
            Item[ITargetWorkbook.Worksheets.Count] as IxlWorksheet;
          {$ENDIF}
          NewSheetName := INewSheet.Name;
          DoOnTargetBookSheetName(ISourceSheet, ITargetWorkbook, NewSheetName);
          if NewSheetName <> '' then
            INewSheet.Name := NewSheetName;
        end;
      end;
      // Switch to TargetWorkbook
      FIModule := UnAssigned;
      _Clear(FIWorksheetFunction);
      _Clear(FINames);
      _Clear(FIMultiSheet);
      _Clear(FITempSheet);
      _Clear(FIWorksheets);
      {$IFDEF XLR_BCB}
      IWorkbook.Close(false, EmptyParam, EmptyParam);
      {$ELSE}
      IWorkbook.Close(false, EmptyParam, EmptyParam, xlrLCID);
      {$ENDIF}
      _Clear(FIWorkbook);
      _Clear(FIWorkbooks);
      _Clear(ITmpWorkbook);
      FIWorkbook := ITargetWorkbook;
      FLastActiveSheetName := INewSheet.Name;
      FIWorksheets := IWorkbook.Worksheets;
      OLEVariant(IXLSApp).CutCopyMode := false;
      {$IFDEF XLR_BCB}
      INewSheet.Activate;
      {$ELSE}
      INewSheet.Activate(xlrLCID);
      {$ENDIF}
    end;
    _Clear(ITargetWorkbook);
  end;

  // ReportTo2 support
  procedure AddToWorkbook2;
  var
    ProcName: string;
    SheetCount, i, j: integer;
    Aliases: OLEvariant;
    SrcSheet: IxlWorksheet;
    {$IFNDEF XLR_BCB}
    IUnk: IUnknown;
    {$ENDIF}
  begin
    // Get all NoRange aliases
    Aliases := VarArrayCreate([1, 1], varVariant);
    j := 1;
    for i := 0 to DataSources.Count - 1 do begin
      if DataSources[i].RangeType = rtNoRange then begin
        Aliases[j] := DataSources[i].Alias;
        Inc(j);
        VarArrayReDim(Aliases, j);
      end;
    end;
    // Replace all NoRange formulas
    ProcName := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrDeleteNoRangeLinks';
    try
      OLEVariant(IXLSApp).Run(ProcName, Aliases);
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [ProcName]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [ProcName]);
      {$ENDIF}
    end;
    // Delete all names
    ProcName := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrDeleteNames';
    try
      OLEVariant(IXLSApp).Run(ProcName, 'REPORTTO2');
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [ProcName]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [ProcName]);
      {$ENDIF}
    end;
    // Open TargetWorkbook
    if not _VarIsEmpty(FTargetWorkbook) then
      if not (VarType(FTargetWorkbook) = varDispatch) then
        FTargetWorkbook := OLEVariant(FIXLApp).Workbooks.Open(FTargetWorkbook);
    // Copy all worksheets
    SheetCount := FIWorkbook.Worksheets.Count;
    for i := SheetCount downto 1 do begin
      {$IFDEF XLR_BCB}
      SrcSheet := FIWorkbook.Worksheets.Item[i];
      if SrcSheet.Visible = TOLEEnum(xlSheetVisible) then begin
        SrcSheet.Copy(EmptyParam, FTargetWorkbook.Worksheets.Item[FTargetWorkbook.Worksheets.Count]);
      {$ELSE}
      SrcSheet := FIWorkbook.Worksheets.Item[i] as IxlWorksheet;
      if SrcSheet.Visible[xlrLCID] = TOLEEnum(xlSheetVisible) then begin
        SrcSheet.Copy(EmptyParam, FTargetWorkbook.Worksheets.Item[FTargetWorkbook.Worksheets.Count], xlrLCID);
      {$ENDIF}
      end;
    end;
    // Switch to TargetWorkbook
    FIModule := UnAssigned;
    _Clear(FIWorksheetFunction);
    _Clear(FINames);
    _Clear(FIMultiSheet);
    _Clear(FITempSheet);
    _Clear(FIWorksheets);
    {$IFDEF XLR_BCB}
    IWorkbook.Close(false, EmptyParam, EmptyParam);
    {$ELSE}
    IWorkbook.Close(false, EmptyParam, EmptyParam, xlrLCID);
    {$ENDIF}
    _Clear(FIWorkbook);
    _Clear(FIWorkbooks);
    {$IFNDEF XLR_BCB}
    IUnk := FTargetWorkbook;
    IUnk.QueryInterface(IxlWorkbook, FIWorkbook);
    {$ELSE}
    FIWorkbook := FTargetWorkbook;
    {$ENDIF}
    FIWorksheets := IWorkbook.Worksheets;
    OLEVariant(IXLSApp).CutCopyMode := false;
  end;

var
  OLDDebug: boolean;
  Raised: boolean;
  i: integer;
  FullWorkbookName: string;
begin
  {$IFNDEF XLR_VCL}
  if State <> rsNotActive then
    Exit;
  {$ENDIF}
  Raised := true;
  State := rsReport;
  FMerged := true;
  OLDDebug := xlrDebug;
  {$IFNDEF XLR_TRIAL}
  xlrDebug := Self.Debug or xlrDebug;
  {$ENDIF}
  try
    try
      ProgressPos := -1;
      ProgressMax := 0;
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType in [rtNoRange, rtRange, rtRangeRoot] then
          ProgressMax := ProgressMax + 1;
      ProgressMax := ProgressMax + 14; // Add WorkbookTo step
      if _VarIsEmpty(FTargetWorkbook) then
        FullWorkbookName := GetFullFileName(WorkbookName, ExtractFilePath(ParamStr(0)), (WorkbookName <> ''));
      Progress;
      Connect;
      if IsRefreshParams then
        RefreshParams(True);
      Progress;
      BeforeBuild;
      Progress;
      DoOnBeforeBuild;
      Progress;
      MacroProcessing(mtBefore, MacroBefore);
      Progress;
      Parse;
      Progress;
      Params.Build;
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType = rtNoRange then begin
          DataSources[i].Build;
          Progress;
        end;
      Progress;
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType = rtRange then begin
          DataSources[i].Build;
          Progress;
        end;
      Progress;
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType = rtRangeRoot then begin
          DataSources[i].BuildRoot;
          Progress;
        end;
      Progress;
      OptionsProcessing;
      Progress;
      MacroProcessing(mtAfter, MacroAfter);
      Progress;
      DoOnAfterBuild;
      Progress;
      AfterBuild;
      Progress;
      // ReportTo2 support
      if FReportTo2 then begin
        if not _VarIsEmpty(FTargetWorkbook) then
          AddToWorkbook2
      end
      else
        AddToWorkbook(FullWorkbookName, NewWorkbookName);
      Progress;
      FNewWorkbookName := NewWorkbookName;
      FMerged := false;
      {$IFDEF XLR_TRIAL}
      DoRestrict2(true);
      {$ENDIF XLR_TRIAL}
      FMerged := false;
      Show(false);
    except
      on E: Exception do begin
        DoOnError(E, Raised);
        ErrorProcessing(E, Raised);
        if Raised then
          raise;
      end;
    end;
  finally
    FMerged := false;
    Disconnect;
    xlrDebug := OLDDebug;
    DoOnProgress(0, 0);
    State := rsNotActive;
  end;
end;

// ReportTo2 support
{$IFNDEF XLR_BCB}
procedure TxlExcelReport.Report(Workbook, ExcelApp: OLEVariant; const NewWorkbookName: string = '');
var
  s: string;
  {$IFNDEF XLR_BCB}
  IUnk: IUnknown;
  {$ENDIF}
begin
  FTargetWorkbook := Workbook;
  // Get TargetExcelApp
  if _VarIsDispatch(ExcelApp) and (not _VarIsDispatch(Workbook)) then begin
    FTargetExcelApp := ExcelApp;
    {$IFNDEF XLR_BCB}
    IUnk := FTargetExcelApp;
    IUnk.QueryInterface(IxlApplication, FIXLApp);
    {$ELSE}
    FIXLApp := FTargetExcelApp;
    {$ENDIF}
    if not _Assigned(FIXLApp) then
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateRes2(ecIncorrectExcelApp, ecIncorrectExcelApp);
      {$ELSE}
      raise ExlReportError.CreateRes(ecIncorrectExcelApp);
      {$ENDIF}
  end;
  // Get TargetWorkbook
  if _VarIsDispatch(Workbook) then
    try
      s := Workbook.Path + '\' + Workbook.Name;
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateRes2(ecIncorrectWbk, ecIncorrectWbk);
      {$ELSE}
      raise ExlReportError.CreateRes(ecIncorrectWbk);
      {$ENDIF}
    end
  else begin
    s := '';
    if VarType(Workbook) <> varError then
      if not _VarIsEmpty(Workbook) then
        s := Workbook;
    if s = '' then
      FTargetWorkbook := UnAssigned;
  end;
  // Release prev ExcelApp (for xroOptimizeLaunch)
  if _VarIsDispatch(ExcelApp) or _VarIsDispatch(Workbook) then
    ReleaseExcelApplication;
  FReportTo2 := true;
  try
    ReportTo(s, NewWorkbookName);
  finally
    FReportTo2 := false;
  end;
end;
{$ENDIF}

procedure TxlExcelReport.MultisheetReport(const MultisheetDataSourceAlias, MultisheetFieldName: string);

  function DataSourceOfAlias(const Alias: string): TxlExcelDataSource;
  var
    i: integer;
  begin
    Result := nil;
    for i := 0 to DataSources.Count - 1 do
      if UpperCase(DataSources[i].Alias) = UpperCase(Alias) then begin
        Result := DataSources[i];
        Break;
      end;
  end;

var
  OLDDebug: boolean;
  MSDataSource: TxlExcelDataSource;
  MSDataSet: TxlAbstractDataSet;
  MSFieldIndex: integer;
  Raised: boolean;
  NameCount: integer;
  MSName, s: string;
  AddedNames: TStrings;
  MSFieldValues: TStrings;


  function SheetName(const NameIndex: integer; const Name: string): string;
  var
    i: integer;
  begin
    Result := Name;
    if NameIndex > 1 then
      Result := Result + ' (' + IntToStr(NameIndex) + ')';
    if AddedNames.IndexOf(Result) <> - 1 then
      Result := SheetName(NameIndex + 1, Name);
    for i := Length(Result) to 1 do
      if CharInSet(Result[i], ['\','/','[',']','?','*']) then
        Delete(Result, i, 1);
    if Length(Result) > xlrWorksheetNameLength then
      Result := Copy(Result, 1, xlrWorksheetNameLength);
    Result := Trim(Result);
  end;

  {$IFNDEF XLR_VCL}
  procedure MSDataSourceDoRelation;
  var
    i: integer;
  begin
    for i := 0 to DataSources.Count - 1 do
      if MSDataSource <> DataSources[i] then
        if DataSources[i].RangeType in rtRoots then begin
          DataSources[i].DoRelationFilter(MSDataSource);
        end;
  end;
  {$ENDIF XLR_VCL}

  procedure DoNoRangeMultisheet;
  var
    i, j: integer;
    ProgressInc: integer;
    // used interfaces
    ITmpWorkbook: IxlWorkbook;
    ITmpSheet: IxlWorksheet;
    s: string;
    Aliases: OLEVariant;
  begin
    // Prepare tempworkbook
    {$IFDEF XLR_BCB}
    FIMultiSheet := IWorkbook.Worksheets.Item[1];
    {$ELSE}
    FIMultiSheet := IWorkbook.Worksheets.Item[1] as IxlWorksheet;
    {$ENDIF}
    MSName := FIMultiSheet.Name;
    {$IFDEF XLR_BCB}
    ITmpWorkbook := IXLSApp.Workbooks.Add(EmptyParam);
    ITmpWorkbook.Worksheets.Add(EmptyParam, EmptyParam, 1, EmptyParam);
    FIMultiSheet.Copy(EmptyParam, ITmpWorkbook.Worksheets.Item[1]);
    IWorkbook.Activate;
    ITmpSheet := ITmpWorkbook.Worksheets.Item[2];
    {$ELSE}
    ITmpWorkbook := IXLSApp.Workbooks.Add(EmptyParam, xlrLCID);
    ITmpWorkbook.Worksheets.Add(EmptyParam, EmptyParam, 1, EmptyParam, xlrLCID);
    FIMultiSheet.Copy(EmptyParam, ITmpWorkbook.Worksheets.Item[1], xlrLCID);
    IWorkbook.Activate(xlrLCID);
    ITmpSheet := ITmpWorkbook.Worksheets.Item[2] as IxlWorksheet;
    {$ENDIF}
    ProgressInc := 0;
    Aliases := VarArrayCreate([1, 1], varVariant);
    j := 1;
    for i := 0 to DataSources.Count - 1 do begin
      if DataSources[i].RangeType = rtNoRange then begin
        Aliases[j] := DataSources[i].Alias;
        Inc(j);
        VarArrayReDim(Aliases, j);
      end;
      if DataSources[i].RangeType in [rtNoRange, rtRange, rtRangeRoot] then
        Inc(ProgressInc);
    end;
    FMultisheetIndex := 1;
    while not MSDataSet.Eof do begin
      s := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrPrepareMultisheet';
      try
        OLEVariant(IXLSApp).Run(s, IntToStr(FMultisheetIndex), Aliases);
      except
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
        {$ENDIF}
      end;
      ProgressMax := ProgressMax + ProgressInc + 1;
      //
      Params.Build;
      // Build all datasources
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType = rtNoRange then begin
          DataSources[i].Build;
          Progress;
        end;
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType = rtRange then begin
          DataSources[i].Build;
          Progress;
        end;
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType = rtRangeRoot then begin
          DataSources[i].BuildRoot;
          Progress;
        end;
      // Multisheet without OnlyValues
      // OnlyValues
      // {$IFDEF XLR_BCB}
      // IRange := FIMultiSheet.UsedRange;
      // {$ELSE}
      // IRange := FIMultiSheet.UsedRange[xlrLCID] as IxlRange;
      // {$ENDIF}
      // IRange.Copy(EmptyParam);
      // IRange.PasteSpecial(TOLEEnum(xlPasteValues),
      //   TOLEEnum(xlPasteSpecialOperationNone), false, false);
      // _Clear(IRange);
      // Delete NoRange names and multisheet names
      s := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrDeleteNames';
      try
        OLEVariant(IXLSApp).Run(s, MSName);
      except
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
        {$ENDIF}
      end;
      // Set sheet name
      s := SheetName(1, MSDataSet.FieldAsString(MSFieldIndex));
      if s <> '' then begin
        FIMultisheet.Name := s;
        AddedNames.Add(s);
      end
      else
        AddedNames.Add(FIMultisheet.Name);
      // Add new sheet
      {$IFDEF XLR_BCB}
      ITmpSheet.Copy(EmptyParam, FIMultisheet);
      i := FIMultisheet.Index + 1;
      {$ELSE}
      ITmpSheet.Copy(EmptyParam, FIMultisheet, xlrLCID);
      i := FIMultisheet.Index[xlrLCID] + 1;
      {$ENDIF}
      _Clear(FIMultisheet);
      {$IFDEF XLR_BCB}
      FIMultisheet := IWorksheets.Item[i];
      {$ELSE}
      FIMultisheet := IWorksheets.Item[i] as IxlWorksheet;
      {$ENDIF}
      FIMultisheet.Name := MSName;
      // Next MSDataSource record
      MSDataSet.Next;
      Inc(FMultisheetIndex);
      {$IFNDEF XLR_VCL}
      if not MSDataSet.Eof then
        MSDataSourceDoRelation;
      {$ENDIF XLR_VCL}
      Progress;
    end; // while not EOF
    if AddedNames.Count > 0 then
      FLastActiveSheetName := AddedNames.Strings[0];
    { Close temporary workbook }
    _Clear(ITmpSheet);
    {$IFDEF XLR_BCB}
    IWorkbook.Worksheets.Item[1].Activate;
    IXLSApp.DisplayAlerts := false;
    FIMultiSheet.Delete;
    IXLSApp.DisplayAlerts := xroDisplayAlerts in Options;
    if _Assigned(ITmpWorkbook) then
      ITmpWorkbook.Close(false, EmptyParam, EmptyParam);
    {$ELSE}
    (IWorkbook.Worksheets.Item[1] as IxlWorksheet).Activate(xlrLCID);
    IXLSApp.DisplayAlerts[xlrLCID] := false;
    FIMultiSheet.Delete(xlrLCID);
    IXLSApp.DisplayAlerts[xlrLCID] := xroDisplayAlerts in Options;
    if _Assigned(ITmpWorkbook) then
      ITmpWorkbook.Close(false, EmptyParam, EmptyParam, xlrLCID);
    {$ENDIF}
    _Clear(ITmpWorkbook);
  end;

  procedure DoRangeMultisheet;
  var
    i, j: integer;
    ProgressInc: integer;
    // used interfaces
    ITmpWorkbook: IxlWorkbook;
    ITmpSheet: IxlWorksheet;
    IRange: IxlRange;
    IName: IxlName;
    Aliases: OLEVariant;
  begin
    // Prepare tempworkbook
    {$IFDEF XLR_BCB}
    FIMultiSheet := IWorkbook.Worksheets.Item[1];
    {$ELSE}
    FIMultiSheet := IWorkbook.Worksheets.Item[1] as IxlWorksheet;
    {$ENDIF}
    MSName := FIMultiSheet.Name;
    {$IFDEF XLR_BCB}
    ITmpWorkbook := IXLSApp.Workbooks.Add(EmptyParam);
    ITmpWorkbook.Worksheets.Add(EmptyParam, EmptyParam, 1, EmptyParam);
    FIMultiSheet.Copy(EmptyParam, ITmpWorkbook.Worksheets.Item[1]);
    IWorkbook.Activate;
    ITmpSheet := ITmpWorkbook.Worksheets.Item[2];
    {$ELSE}
    ITmpWorkbook := IXLSApp.Workbooks.Add(EmptyParam, xlrLCID);
    ITmpWorkbook.Worksheets.Add(EmptyParam, EmptyParam, 1, EmptyParam, xlrLCID);
    FIMultiSheet.Copy(EmptyParam, ITmpWorkbook.Worksheets.Item[1], xlrLCID);
    IWorkbook.Activate(xlrLCID);
    ITmpSheet := ITmpWorkbook.Worksheets.Item[2] as IxlWorksheet;
    {$ENDIF}
    ProgressInc := 0;
    for i := 0 to DataSources.Count - 1 do
      if DataSources[i].RangeType in [rtNoRange, rtRange, rtRangeRoot] then
        Inc(ProgressInc);
    Aliases := VarArrayCreate([1, 1], varVariant);
    j := 1;
    for i := 0 to DataSources.Count - 1 do begin
      if DataSources[i].RangeType = rtNoRange then begin
        Aliases[j] := DataSources[i].Alias;
        Inc(j);
        VarArrayReDim(Aliases, j);
      end;
      if DataSources[i].RangeType in [rtNoRange, rtRange, rtRangeRoot] then
        Inc(ProgressInc);
    end;
    FMultisheetIndex := 1;
    while not MSDataSet.Eof do begin
      s := '''' + IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + 'xlrPrepareMultisheet';
      try
        OLEVariant(IXLSApp).Run(s, IntToStr(FMultisheetIndex), Aliases);
      except
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
        {$ENDIF}
      end;
      Params.Build;
      ProgressMax := ProgressMax + ProgressInc + 1;
      // Build all datasources
      if MSFieldValues.IndexOf(MSDataSet.FieldAsString(MSFieldIndex)) = -1 then begin
        MSFieldValues.Add(MSDataSet.FieldAsString(MSFieldIndex));
        MSDataSet.SetFilter(MSFieldIndex);
        for i := 0 to DataSources.Count - 1 do
          if DataSources[i].RangeType = rtNoRange then begin
            DataSources[i].Build;
            Progress;
          end;
        for i := 0 to DataSources.Count - 1 do
          if DataSources[i].RangeType = rtRange then begin
            DataSources[i].Build;
            Progress;
          end;
        for i := 0 to DataSources.Count - 1 do
          if DataSources[i].RangeType = rtRangeRoot then begin
            DataSources[i].BuildRoot;
            Progress;
          end;
        // OnlyValues
        {$IFDEF XLR_BCB}
        IRange := FIMultisheet.UsedRange;
        {$ELSE}
        IRange := FIMultisheet.UsedRange[xlrLCID] as IxlRange;
        {$ENDIF}
        IRange.Copy(EmptyParam);
        IRange.PasteSpecial(TOLEEnum(xlPasteValues),
          TOLEEnum(xlPasteSpecialOperationNone), false, false);
        _Clear(IRange);
        // Delete NoRange names and multisheet names
        NameCount := INames.Count;
        for i := NameCount downto 1 do begin
          {$IFDEF XLR_BCB}
          IName := INames.Item(i, EmptyParam, EmptyParam);
          {$ELSE}
          IName := INames.Item(i, EmptyParam, EmptyParam) as IxlName;
          {$ENDIF}
          s := IName.Value;
          if UpperCase(IName.Name) = xlrMultisheetCellName then
            IName.RefersToRange.Value := MSDataSet.FieldAsOLEVariant(MSFieldIndex);
          if (pos('''' + xlrTempSheetName + '''' + '!', s) <> 0) or
            (pos(xlrTempSheetName + '!', s) <> 0) then
            IName.Delete;
          if (pos('''' + MSName + '''' + '!', s) <> 0) or
            (pos(MSName + '!', s) <> 0) then
            IName.Delete;
          _Clear(IName);
        end;
        // Set sheet name
        s := SheetName(1, MSDataSet.FieldAsString(MSFieldIndex));
        if s <> '' then begin
          FIMultisheet.Name := s;
          AddedNames.Add(s);
        end
        else
          AddedNames.Add(FIMultisheet.Name);
        // Add new sheet
        {$IFDEF XLR_BCB}
        ITmpSheet.Copy(EmptyParam, FIMultisheet);
        i := FIMultisheet.Index + 1;
        {$ELSE}
        ITmpSheet.Copy(EmptyParam, FIMultisheet, xlrLCID);
        i := FIMultisheet.Index[xlrLCID] + 1;
        {$ENDIF}
        _Clear(FIMultisheet);
        {$IFDEF XLR_BCB}
        FIMultisheet := IWorksheets.Item[i];
        {$ELSE}
        FIMultisheet := IWorksheets.Item[i] as IxlWorksheet;
        {$ENDIF}
        FIMultisheet.Name := MSName;
        MSDataSet.SetFilter(-1);
        // Get next MSDataSource field value
        while (not MSDataSet.Eof) and
          (MSFieldValues.IndexOf(MSDataSet.FieldAsString(MSFieldIndex)) <> - 1) do
          MSDataSet.Next;
        Progress;
      end; // if IndexOf
      Inc(FMultisheetIndex);
    end; // while not EOF
    if AddedNames.Count > 0 then
      FLastActiveSheetName := AddedNames.Strings[0];
    { Close temporary workbook }
    _Clear(ITmpSheet);
    {$IFDEF XLR_BCB}
    IWorkbook.Worksheets.Item[1].Activate;
    IXLSApp.DisplayAlerts := false;
    FIMultiSheet.Delete;
    IXLSApp.DisplayAlerts := xroDisplayAlerts in Options;
    if _Assigned(ITmpWorkbook) then
      ITmpWorkbook.Close(false, EmptyParam, EmptyParam);
    {$ELSE}
    (IWorkbook.Worksheets.Item[1] as IxlWorksheet).Activate(xlrLCID);
    IXLSApp.DisplayAlerts[xlrLCID] := false;
    FIMultiSheet.Delete(xlrLCID);
    IXLSApp.DisplayAlerts[xlrLCID] := xroDisplayAlerts in Options;
    if _Assigned(ITmpWorkbook) then
      ITmpWorkbook.Close(false, EmptyParam, EmptyParam, xlrLCID);
    {$ENDIF}
    _Clear(ITmpWorkbook);
  end;

begin
  {$IFNDEF XLR_VCL}
  if State <> rsNotActive then
    Exit;
  {$ENDIF}
  MSDataSource := DataSourceOfAlias(MultisheetDataSourceAlias);
  if Assigned(MSDataSource) and (MSDataSource.RangeType in [rtNoRange, rtRange, rtRangeRoot]) then begin
    Raised := true;
    State := rsReport;
    AddedNames := TStringList.Create;
    MSFieldValues := TStringList.Create;
    OLDDebug := xlrDebug;
    {$IFNDEF XLR_TRIAL}
    xlrDebug := Self.Debug or xlrDebug;
    {$ENDIF}
    try
      try
        ProgressPos := -1;
        ProgressMax := 13;
        Progress;
        Connect;
        if IsRefreshParams then
          RefreshParams(True);
        Progress;
        BeforeBuild;
        Progress;
        DoOnBeforeBuild;
        Progress;
        MacroProcessing(mtBefore, MacroBefore);
        Progress;
        Parse;
        Progress;
        MSDataSet := MSDataSource.XLDataSet;
        if (MSDataSet.Flags and xlrMultisheet) <> xlrMultisheet then
          {$IFNDEF XLR_VCL}
          raise ExlReportError.CreateRes2(ecMultisheetNotAvailable, ecMultisheetNotAvailable);
          {$ELSE}
          raise ExlReportError.CreateRes(ecMultisheetNotAvailable);
          {$ENDIF}
        MSDataSet.ExternalDisconnect := true;
        if (MSDataSource.AutoOpen) and (not MSDataSet.Active) then
          MSDataSet.Open;
        Progress;
        MSDataSet.Connect;
        MSFieldIndex := MSDataSet.Fields.IndexOf(MultisheetFieldName);
        if MSFieldIndex = -1 then
          {$IFNDEF XLR_VCL}
          raise ExlReportError.CreateResFmt2(ecMultisheetFieldNotFound, ecMultisheetFieldNotFound, [MultisheetFieldName]);
          {$ELSE}
          raise ExlReportError.CreateResFmt(ecMultisheetFieldNotFound, [MultisheetFieldName]);
          {$ENDIF}
        MSDataSet.First;
        {$IFNDEF XLR_VCL}
        if MSDataSource.RangeType = rtNoRange then
          if not MSDataSet.Eof then
            MSDataSourceDoRelation;
        {$ENDIF XLR_VCL}
        try
          Progress;
          if MSDataSource.RangeType = rtNoRange then
            DoNoRangeMultisheet
          else
            DoRangeMultisheet;
        finally
          if MSDataSource.AutoClose then
            MSDataSet.Close;
          if MSDataSource.RangeType in [rtRange, rtRangeRoot] then
            MSDataSet.SetFilter(-1);
          MSDataSet.Disconnect(MSDataSource.AutoClose);
        end;
        Progress;
        Progress;
        OptionsProcessing;
        Progress;
        MacroProcessing(mtAfter, MacroAfter);
        Progress;
        DoOnAfterBuild;
        Progress;
        AfterBuild;
        Progress;
        Show(false);
      except
        on E: Exception do begin
          DoOnError(E, Raised);
          ErrorProcessing(E, Raised);
          if Raised then
            raise;
        end;
      end;
    finally
      FMultisheetIndex := -1;
      MSFieldValues.Free;
      AddedNames.Free;
      Disconnect;
      DoOnProgress(0, 0);
      State := rsNotActive;
      xlrDebug := OLDDebug;
    end;
  end
  else
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateResFmt2(ecMultisheetDataSourceNotFound, ecMultisheetDataSourceNotFound, [MultisheetDataSourceAlias]);
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecMultisheetDataSourceNotFound, [MultisheetDataSourceAlias]);
    {$ENDIF}
end;

{$IFNDEF XLR_BCB}
class procedure TxlExcelReport.MergeReports(Reports: array of TxlExcelReport; SheetPrefixes: array of string);
var
  TmpOptions: TxlReportOptionsSet;
  i, hi, lo: integer;
  Workbooks, Prefixes: OLEVariant;
  IXL: IxlApplication;
  IWbk: IxlWorkbook;
  IMdl: IxlVBComponent;
{$IFDEF XLR_TRIAL}
  {$I xlDoRestrict3.inc}
{$ENDIF XLR_TRIAL}
begin
  IXL := ConnectToExcelApp(false);
  try
    lo := Low(Reports);
    hi := High(Reports);
    if hi >= lo then begin
      Workbooks := VarArrayCreate([1, hi - lo + 1], varVariant);
      Prefixes := VarArrayCreate([1, hi - lo + 1], varVariant);
    end;
    for i := lo to hi do begin
      TmpOptions := Reports[i].Options;
      Reports[i].Options := Reports[i].Options + [xroHideExcel];
      try
        Reports[i].FMerged := true;
        Reports[i].Report;
        Workbooks[i - lo + 1] := Reports[i].FLastWorkbookName;
        Prefixes[i - lo + 1] := SheetPrefixes[i];
      finally
        Reports[i].FMerged := false;
        Reports[i].Options := TmpOptions;
      end;
    end;
    IWbk := IXL.Workbooks.Item[Workbooks[1]];
    IMdl := OLEVariant(IWbk).VBProject.VBComponents.Add( TOLEEnum(vbext_ct_StdModule) );
    IMdl.Name := 'XLR_MergeWbkModule';
    IMdl.CodeModule.AddFromString(xlrVBAMergeModule);
    {$IFDEF XLR_BCB}
    IWbk.Activate;
    {$ELSE}
    IWbk.Activate(xlrLCID);
    {$ENDIF}
    BeforeRunMacro(IXL, true);
    try
      OLEVariant(IXL).Run('XLR_MergeWbkModule.' + xlrVBAMergeWorkbooks, Workbooks, Prefixes);
    except
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, ['XLR_MergeWbkModule.' + xlrVBAMergeWorkbooks]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecMacroRuntimeError, ['XLR_MergeWbkModule.' + xlrVBAMergeWorkbooks]);
      {$ENDIF}
    end;
    {$IFDEF XLR_TRIAL}
    DoRestrict3;
    {$ENDIF XLR_TRIAL}
  finally
    if (not _VarIsEmpty(IMdl)) and (not xlrDebug) then begin
      IMdl.CodeModule.DeleteLines(1, IMdl.CodeModule.CountOfLines);
      IMdl.Collection.Remove(IMdl);
    end;
    _Clear(IWbk);
    ShowExcel(IXL, false, false, TOLEEnum(xlNormal), -1, -1);
    _Clear(IXL);
  end;
end;
{$ENDIF}

var
  xlrStandardPackage: TxlStandardPackage;
  {$IFNDEF XLR_VCL}
  Buff: PChar;
  {$IFDEF XLR_TRIAL}
  xlrProPackage: TxlProPackage;
  {$ENDIF}
  {$IFDEF XLR_PRO}
  xlrProPackage: TxlProPackage;
  {$ENDIF}
  {$ENDIF XLR_VCL}

initialization

  // Create Engine Option Map
  xlrOptionMap := TxlOptionMap.Create;
  xlrStandardPackage := TxlStandardPackage.Create(nil);
  {$IFDEF XLR_VCL}
    {$IFDEF XLR_TRIAL}
      TotalEx_Service;
    {$ENDIF XLR_TRIAL}
  {$ELSE}
    GetMem(Buff, 255);
    GetTempPath(255, Buff);
    xlrTempPath := Buff;
    DeleteFiles(xlrTempPath, xlrFileExtention, xlrTempFileSign);
    FreeMem(Buff);
    {$IFDEF XLR_PRO}
      xlrProPackage := TxlProPackage.Create(nil);
    {$ENDIF}
    {$IFDEF XLR_TRIAL}
      xlrProPackage := TxlProPackage.Create(nil);
    {$ENDIF}
    {$IFDEF XLR_DEV}
      xlrProPackage := TxlProPackage.Create(nil);
    {$ENDIF}
  {$ENDIF XLR_VCL}

finalization

  {$IFNDEF XLR_VCL}
    DeleteFiles(xlrTempPath, xlrFileExtention, xlrTempFileSign);
    {$IFDEF XLR_PRO}
    xlrProPackage.Free;
    {$ENDIF XLR_PRO}
    {$IFDEF XLR_DEV}
    xlrProPackage.Free;
    {$ENDIF XLR_PRO}
    {$IFDEF XLR_TRIAL}
    xlrProPackage.Free;
    {$ENDIF}
  {$ENDIF XLR_VCL}
  xlrStandardPackage.Free;
  xlrOptionMap.Free;

end.

