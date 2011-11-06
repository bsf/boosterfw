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

unit xlReport;

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
  Excel8G2, VBIDE8G2, Office8G2, xlcUtils, xlcOPack, xlcClasses, xlEngine;

type

{ Forward declaration of XL Report classes }

  TxlDataSource = class;
  TxlDataSources = class;
  TxlReport = class;

{ Used interfaces }

  IxlApplication = xlEngine.IxlApplication;
  IxlWorkbooks = xlEngine.IxlWorkbooks;
  IxlWorkbook = xlEngine.IxlWorkbook;
  IxlWorksheets = xlEngine.IxlWorksheets;
  IxlWorksheet = xlEngine.IxlWorksheet;
  IxlNames = xlEngine.IxlNames;
  IxlName = xlEngine.IxlName;
  IxlRange = xlEngine.IxlRange;
  IxlWorksheetFunction = xlEngine.IxlWorksheetFunction;
  IxlPivotTable = xlEngine.IxlPivotTable;
  IxlPivotField = xlEngine.IxlPivotField;
  IxlShape = xlEngine.IxlShape;
  IxlVBComponent = xlEngine.IxlVBComponent;
  IxlCharacters = xlEngine.IxlCharacters;

{ Overloaded Enums }

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

{ Event handlers }

  // OnBefore/AfterBuild event handler
  TxlReportHandleEvent = procedure (Report: TxlReport) of object;

  // OnBefore/AfterDataTransfer
  TxlDataTransferHandleEvent = procedure (DataSource: TxlDataSource) of object;

  // OnMacro event handler
  TxlOnMacro = procedure (Report: TxlReport; DataSource: TxlDataSource;
    const AMacroType: TxlMacroType; const AMacroName: string;
    var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10,
    Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20,
    Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant) of object;

  // Save to selected file  event handler
  TxlOnBeforeWorkbookSave = procedure (Report: TxlReport;
    var WorkbookName, WorkbookPath: string; Save: boolean) of object;

  // Progress
  TxlOnProgress = procedure (Report: TxlReport; const Position, Max: integer) of object;
  TxlOnProgress2 = procedure (Report: TxlReport; const Position, Max: integer;
    DataSource: TxlDataSource; const RecordCount: integer) of object;

  // OnTargetBookSheetName
  TxlOnTargetBookSheetName = procedure (Report: TxlReport; ISheet: IxlWorksheet; ITargetWorkbook: IxlWorkbook;
    var WorksheetName: string) of object;

  // OnGetDataSourceInfo
  TxlGetDataSourceInfo = procedure (DataSource: TxlDataSource; var FieldCount: integer) of object;

  // OnGetFieldInfo
  TxlGetFieldInfo = procedure (DataSource: TxlDataSource; const FieldIndex: integer;
    var FieldName: string; var FieldType: TxlDataType) of object;

  // OnGetRecord
  TxlGetRecord = procedure (DataSource: TxlDataSource; const RecNo: integer;
    var Values: OLEVariant; var Eof: boolean) of object;

  // OnBreak
  TxlOnBreak = procedure (Report: TxlReport; var IsBreak: boolean) of object;

{ XL Report 4.0 classes }

{ TxlDataSource class }

  TxlDataSource = class(TxlExcelDataSource)
  private
    FDataSet: TDataSet;
    // events
    FBeforeTransfer: TxlDataTransferHandleEvent;
    FAfterTransfer: TxlDataTransferHandleEvent;
    FOnMacro: TxlOnMacro;
    FOnGetDataSourceInfo: TxlGetDataSourceInfo;
    FOnGetRecord: TxlGetRecord;
    FOnGetFieldInfo: TxlGetFieldInfo;
    function GetReport: TxlReport;
    procedure SetDataSet(const Value: TDataSet);
    function GetOptions: TxlRangeOptionsSet;
    procedure SetOptions(const Value: TxlRangeOptionsSet);
  protected
    // Create DataSet wrapper
    function CreateXLDataSet: TxlAbstractDataSet; override;
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25,
      Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant); override;
    procedure DoOnBeforeDataTransfer; override;
    procedure DoOnAfterDataTransfer; override;
  public
    property Report: TxlReport read GetReport;
    // Used interfaces
    property IXLSApp;
    property IWorkbooks;
    property IWorkbook;
    property INames;
    property IName;
    property IWorksheets;
    property IWorksheet;
    property ITempSheet;
    property IRange;
    // New in v.4.0
    property MasterSource;
    property RangeType;
    property Row;
    property Column;
    property RowCount;
    property ColCount;
  published
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property Alias;
    property Range;
    property MacroBefore;
    property MacroAfter;
    property Options: TxlRangeOptionsSet read GetOptions write SetOptions;
    property Enabled;
    property Tag;
    // New in v.4.0
    property MasterSourceName;
    // Events
    property OnBeforeDataTransfer: TxlDataTransferHandleEvent read FBeforeTransfer
      write FBeforeTransfer;
    property OnAfterDataTransfer: TxlDataTransferHandleEvent read FAfterTransfer
      write FAfterTransfer;
    property OnMacro: TxlOnMacro read FOnMacro write FOnMacro;
    // Unbound data events - new in v.4.0
    property OnGetDataSourceInfo: TxlGetDataSourceInfo read FOnGetDataSourceInfo
      write FOnGetDataSourceInfo;
    property OnGetFieldInfo: TxlGetFieldInfo read FOnGetFieldInfo write FOnGetFieldInfo;
    property OnGetRecord: TxlGetRecord read FOnGetRecord write FOnGetRecord;
  end;

{ TxlDataSources collection class }

  TxlDataSources = class(TxlExcelDataSources)
  private
    // properties
    function GetItem(Index: integer): TxlDataSource;
    procedure SetItem(Index: integer; const Value: TxlDataSource);
    function GetReport: TxlReport;
  protected
  public
    function Add: TxlDataSource;
    property Report: TxlReport read GetReport;
    property Items[Index: integer]: TxlDataSource read GetItem write SetItem; default;
  end;

{ TxlReportParam }

  TxlReportParam = class(TxlExcelReportParam)
  private
    function GetReport: TxlReport;
  public
    property Report: TxlReport read GetReport;
  published
    property Name;
    property Value;
  end;

{ TxlReportParams }

  TxlReportParams = class(TxlExcelReportParams)
  private
    function GetItem(Index: integer): TxlReportParam;
    function GetReport: TxlReport;
    procedure SetItem(Index: integer; const Value: TxlReportParam);
  public
    function Add: TxlReportParam;
    property Items[Index: integer]: TxlReportParam read GetItem write SetItem; default;
    property Report: TxlReport read GetReport;
  end;

{ TxlReport class }

  TxlReport = class(TxlExcelReport)
  private
    FProgressPos: integer;
    FProgressMax: integer;
    // events
    FOnMacro: TxlOnMacro;
    FOnBeforeWorkbookSave: TxlOnBeforeWorkbookSave;
    FOnAfterBuild: TxlReportHandleEvent;
    FOnBeforeBuild: TxlReportHandleEvent;
    FOnProgress: TxlOnProgress;
    FOnProgress2: TxlOnProgress2;
    FOnTargetBookSheetName: TxlOnTargetBookSheetName;
    FOnBreak: TxlOnBreak;
    function GetDataSources: TxlDataSources;
    procedure SetDataSources(const Value: TxlDataSources);
    function GetParams: TxlReportParams;
    procedure SetParams(const Value: TxlReportParams);
    function GetParamByName(Name: string): TxlReportParam;
    function GetOptions: TxlReportOptionsSet;
    procedure SetOptions(const Value: TxlReportOptionsSet);
    function GetDataMode: TxlDataExportMode;
    procedure SetDataMode(const Value: TxlDataExportMode);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function CreateDataSources: TxlAbstractDataSources; override;
    function CreateParams: TxlAbstractParameters; override;
    function DoOnBreak: boolean; override;
    procedure DoOnBeforeBuild; override;
    procedure DoOnAfterBuild; override;
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25,
      Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant); override;
    procedure DoOnProgress(const Position, Max: integer); override;
    procedure DoOnProgress2(DataSource: TxlExcelDataSource; const RecordCount: integer); override;
    procedure DoOnBeforeWorkbookSave(var WorkbookFileName, WorkbookFilePath: string;
      Save: boolean); override;
    procedure DoOnTargetBookSheetName(ISourceSheet: IxlWorksheet; ITargetWorkbook: IxlWorkbook;
      var SheetName: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    // compatibility methods
    constructor CreateEx(AOwner: TComponent;
                       AXLSTemplate: string;
                       AActiveSheet: string = '';
                       AMacroBefore: string = '';
                       AMacroAfter: string = '';
                       AOptions: TxlReportOptionsSet = [xroDisplayAlerts, xroAutoOpen];
                       ATempPath: string = '';
                       AOnBeforeBuild: TxlReportHandleEvent = nil;
                       AOnAfterBuild: TxlReportHandleEvent = nil); virtual;
    function AddDataSet(ADataSet: TDataSet;
                       ARange: string = '';
                       AMacroBefore: string = '';
                       AMacroAfter: string = '';
                       AOptions: TxlRangeOptionsSet = [xrgoAutoOpen, xrgoPreserveRowHeight];
                       AOnMacro: TxlOnMacro = nil;
                       AOnBeforeDataTransfer: TxlDataTransferHandleEvent = nil;
                       AOnAfterDataTransfer: TxlDataTransferHandleEvent = nil): TxlDataSource;
    // main methods
    procedure Report; reintroduce; override;
    procedure Report(const APreview: boolean); reintroduce; overload;
    procedure ReportTo(const WorkbookName: string; const NewWorkbookName: string = ''); override;
    procedure Edit;
    // class methods
    class function GetOptionMap: TxlOptionMap; override;
    class procedure ReleaseExcelApplication;
    class procedure ConnectToExcelApplication(OLEObject: OLEVariant);
    {$IFNDEF XLR_BCB}
    class procedure MergeReports(Reports: array of TxlExcelReport; SheetPrefixes: array of string); override;
    {$ENDIF}
    // used interfaces
    property IXLSApp;
    property IWorkbooks;
    property IWorkbook;
    property INames;
    property IWorksheets;
    property ITempSheet;
    property IWorksheetFunction;
    property IModule;
    // New v.4.0
    property Debug;
    property ParamByName[Name: string]: TxlReportParam read GetParamByName;
  published
    property ActiveSheet;
    property DataExportMode: TxlDataExportMode read GetDataMode write SetDataMode;
    property TempPath;
    property MacroBefore;
    property MacroAfter;
    property Options: TxlReportOptionsSet read GetOptions write SetOptions;
    property XLSTemplate;
    property DataSources: TxlDataSources read GetDataSources write SetDataSources;
    // New v.4.0
    property Preview;
    property MultisheetAlias;
    property MultisheetField;
    property Params: TxlReportParams read GetParams write SetParams;
    // Events
    property OnBeforeBuild: TxlReportHandleEvent read FOnBeforeBuild write FOnBeforeBuild;
    property OnAfterBuild: TxlReportHandleEvent read FOnAfterBuild write FOnAfterBuild;
    property OnMacro: TxlOnMacro read FOnMacro write FOnMacro;
    property OnBeforeWorkbookSave: TxlOnBeforeWorkbookSave read FOnBeforeWorkbookSave
      write FOnBeforeWorkbookSave;
    property OnProgress: TxlOnProgress read FOnProgress write FOnProgress;
    property OnProgress2: TxlOnProgress2 read FOnProgress2 write FOnProgress2;
    property OnTargetBookSheetName: TxlOnTargetBookSheetName read FOnTargetBookSheetName
      write FOnTargetBookSheetName;
    property OnError;
    property OnBreak: TxlOnBreak read FOnBreak write FOnBreak;
  end;

const
  xlrLCID: integer = LOCALE_USER_DEFAULT;
  xlrProductName = xlEngine.xlrProductName;
  xlrVersionAddStr = xlEngine.xlrVersionAddStr;
  xlrVersionBuild = xlEngine.xlrVersionBuild;
  xlrHomeURL = xlEngine.xlrHomeURL;
  xlrOrderStr = xlEngine.xlrOrderStr;
  xlrOrderURL = xlEngine.xlrOrderURL;
  xlrIDEVer = xlEngine.xlrIDEVer;
  xlrProductID = xlEngine.xlrProductID;

function xlrVersionStr: string;
procedure BeforeRunMacro(IXLApp: IxlApplication; const Hidden: boolean);
function xlrDebug: boolean;

implementation

function xlrVersionStr: string;
begin
  Result := xlEngine.xlrVersionStr;
end;

procedure BeforeRunMacro(IXLApp: IxlApplication; const Hidden: boolean);
begin
  xlEngine.BeforeRunMacro(IXLApp, Hidden);
end;

function xlrDebug: boolean;
begin
  Result := xlEngine.xlrDebug;
end;


{ VCL TDataSet wrapper class }

type

  TxlVCLDataSet = class(TxlAbstractDataSet)
  private
    FDataSet: TDataSet;
    FBookmark: TBookmark;
    FFilterField: string;
    FFilterValue: Variant;
  public
    // Connect/disconnect to DataSet
    procedure Open; override;
    procedure Close; override;
    procedure GetFields; override;
    procedure GetFieldsType; override;
    function Flags: DWORD; override;
    // DataSet state
    function Name: string; override;
    function Active: boolean;  override;
    procedure EnableControls; override;
    procedure DisableControls; override;
    function Bof: boolean; override;
    function Eof: boolean; override;
    // DataSet navigate
    procedure First; override;
    procedure Next; override;
    procedure SetBookmark; override;
    procedure GotoBookmark; override;
    procedure SetFilter(const FieldIndex: integer); override;
    // DataSet fields
    function FieldIsEmpty(const Index: integer): boolean; override;
    function FieldAsInteger(const Index: integer): integer; override;
    function FieldAsFloat(const Index: integer): extended; override;
    function FieldAsDateTime(const Index: integer): TDateTime; override;
    function FieldAsString(const Index: integer): string; override;
    function FieldAsBoolean(const Index: integer): boolean; override;
    function FieldAsOLEVariant(const Index: integer): OLEVariant; override;
    // Properties
    property Fields;
    property DataSet: TDataSet read FDataSet write FDataSet;
  end;

{ TxlVCLDataSet }

// Connect/disconnect to DataSet
procedure TxlVCLDataSet.Open;
begin
  if Assigned(FDataSet) then
    DataSet.Open;
end;

procedure TxlVCLDataSet.Close;
begin
  if Active then
    DataSet.Close;
end;

procedure TxlVCLDataSet.GetFields;
var i: integer;
begin
  if Active then
    for i := 0 to DataSet.Fields.Count - 1 do
      Fields.Add(UpperCase(DataSet.Fields[i].FieldName));
end;

// DataSet state
function TxlVCLDataSet.Name: string;
begin
  Result := '';
  if Assigned(DataSet) then
    Result := DataSet.Name;
end;

function TxlVCLDataSet.Active: boolean;
begin
  Result := false;
  if Assigned(DataSet) then
    Result := DataSet.Active;
end;

procedure TxlVCLDataSet.EnableControls;
begin
  if Active then
    DataSet.EnableControls;
end;

procedure TxlVCLDataSet.DisableControls;
begin
  if Active then
    DataSet.DisableControls;
end;

function TxlVCLDataSet.Bof: boolean;
begin
  Result := true;
  if Active then
    Result := DataSet.Bof;
end;

function TxlVCLDataSet.Eof: boolean;
begin
  Result := true;
  if Active then
    Result := DataSet.Eof;
end;

// DataSet navigate
procedure TxlVCLDataSet.First;
begin
  if Assigned(DataSet) then
    DataSet.First;
end;

procedure TxlVCLDataSet.Next;
begin
  if Assigned(DataSet) then
    DataSet.Next;
end;

procedure TxlVCLDataSet.SetBookmark;
begin
  if Active and (not DataSet.Filtered) then
    FBookmark := DataSet.Bookmark;
end;

procedure TxlVCLDataSet.GotoBookmark;
begin
  if Active and (not DataSet.Filtered) then
    DataSet.Bookmark := FBookmark;
end;

procedure TxlVCLDataSet.SetFilter(const FieldIndex: integer);

  function CheckFilterStr(const AStr: string): string;
  var
    i: integer;
  begin
    Result := '';
    for i := 1 to Length(AStr) do
      if AStr[i] = '''' then
        Result := Result + AStr[i] + ''''
      else
        Result := Result + AStr[i];
  end;

var
  s: string;
begin
  if FieldIndex < 0 then begin
    if EOF then
      DataSet.Prior;
    DataSet.Filter := '';
    DataSet.Filtered := false;
    if (FFilterField <> '') and (not _VarIsEmpty(FFilterValue)) then
      DataSet.Locate(FFilterField, FFilterValue,[]);
    FFilterField := '';
    FFilterValue := UnAssigned;
  end
  else begin
    FFilterField := Fields[FieldIndex];
    FFilterValue := FieldAsOLEVariant(FieldIndex);
    s := Fields[FieldIndex] + '=';
    if FieldType[FieldIndex] in [xdInteger, xdFloat, xdBoolean] then
      s := s + FieldAsString(FieldIndex)
    else
      s := s + '''' + CheckFilterStr(FieldAsString(FieldIndex)) + '''';
    DataSet.Filter := s;
    DataSet.Filtered := true;
  end;
end;

// DataSet fields
procedure TxlVCLDataSet.GetFieldsType;
var
  i: integer;
begin
  for i := 0 to Fields.Count - 1 do begin
    FieldType[i] := xdNotSupported;
    if Active and IsValidFieldName(DataSet.Fields[i].FieldName) then begin
      if Assigned(DataSet.Fields[i].OnGetText) then
        FieldType[i] := xdString
      else
        case DataSet.Fields[i].DataType of
          // strings
          ftString, ftFixedChar, ftWideString, ftMemo, ftFmtMemo:  FieldType[i] := xdString;
          // integer
          ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc: FieldType[i] := xdInteger;
          // float
          ftFloat, ftCurrency, ftBCD: FieldType[i] := xdFloat;
          // boolean
          ftBoolean: FieldType[i] := xdBoolean;
          // date and time
          ftDate, ftTime, ftDateTime: FieldType[i] := xdDateTime;
        end;
    end;
  end;
end;

function TxlVCLDataSet.Flags: DWORD;
begin
  Result := xlrMultisheet or xlrSetFilter;
end;

function TxlVCLDataSet.FieldIsEmpty(const Index: integer): boolean;
begin
  Result := true;
  if Active then
    Result := DataSet.Fields[Index].IsNull;
end;

function TxlVCLDataSet.FieldAsInteger(const Index: integer): integer;
begin
  Result := 0;
  if Active then
    Result := DataSet.Fields[Index].AsInteger;
end;

function TxlVCLDataSet.FieldAsFloat(const Index: integer): extended;
begin
  Result := 0;
  if Active then
    Result := DataSet.Fields[Index].AsFloat;
end;

function TxlVCLDataSet.FieldAsDateTime(const Index: integer): TDateTime;
begin
  Result := 0;
  if Active then
    Result := DataSet.Fields[Index].AsDateTime;
end;

function TxlVCLDataSet.FieldAsString(const Index: integer): string;
var
  MaxStrLen: integer;
begin
  MaxStrLen := xlrDDEMaxStrlen;
  Result := '';
  if Active then
    if Assigned(DataSet.Fields[Index].OnGetText) then
      Result := DataSet.Fields[Index].DisplayText
    else
      Result := DataSet.Fields[Index].AsString;
  Result := TrimRight(Result);
  if Result <> '' then begin
    DeleteChars(#$0D, Result);
    if TxlExcelDataSource(DataSource).Report.DataExportMode = xlEngine.xdmCSV then
      ReplaceChars('"', '''', Result);
    case TxlExcelDataSource(DataSource).Report.DataExportMode of
      xlEngine.xdmCSV: MaxStrLen := xlrCSVMaxStrLen;
      xlEngine.xdmVariant: MaxStrLen := xlrVarMaxStrLen;
    end;
    if Length(Result) > MaxStrLen then
      Result := Copy(Result, 1, MaxStrLen);
  end;
end;

function TxlVCLDataSet.FieldAsBoolean(const Index: integer): boolean;
begin
  Result := false;
  if Active then
    Result := DataSet.Fields[Index].AsBoolean;
end;

function TxlVCLDataSet.FieldAsOLEVariant(const Index: integer): OLEVariant;
var
  s: string;
begin
  Result := NULL;
  if Active and (not FieldIsEmpty(Index)) then
    case FieldType[Index] of
      xdInteger: Result := DataSet.Fields[Index].AsInteger;
      xdBoolean: Result := DataSet.Fields[Index].AsBoolean;
      xdFloat: Result := DataSet.Fields[Index].AsFloat;
      xdDateTime: Result := DataSet.Fields[Index].AsDateTime;
      xdString: begin
        s := DataSet.Fields[Index].AsString;
        DeleteChars(#$0D, s);
        Result := s;
      end;
    end;
  if VarType(Result) = varOLEStr then
    if Length(Result) > xlrVarMaxStrLen then
      Result := Copy(Result, 1, xlrVarMaxStrLen);
end;

{ Unbound Dataset wrapper class }

type

  TxlUnboundDataSet = class(TxlAbstractDataSet)
  private
    FFldTypes: TList;
    FBuff: OLEVariant;
    FRecNo: integer;
    FEOF: boolean;
  public
    // Connect/disconnect to DataSet
    procedure Open; override;
    procedure Close; override;
    procedure GetFields; override;
    procedure GetFieldsType; override;
    // DataSet state
    function Name: string; override;
    function Active: boolean;  override;
    procedure EnableControls; override;
    procedure DisableControls; override;
    function Bof: boolean; override;
    function Eof: boolean; override;
    // DataSet navigate
    procedure First; override;
    procedure Next; override;
    procedure SetBookmark; override;
    procedure GotoBookmark; override;
    procedure SetFilter(const FieldIndex: integer); override;
    // DataSet fields
    function FieldIsEmpty(const Index: integer): boolean; override;
    function FieldAsInteger(const Index: integer): integer; override;
    function FieldAsFloat(const Index: integer): extended; override;
    function FieldAsDateTime(const Index: integer): TDateTime; override;
    function FieldAsString(const Index: integer): string; override;
    function FieldAsBoolean(const Index: integer): boolean; override;
    function FieldAsOLEVariant(const Index: integer): OLEVariant; override;
    // Properties
    property Fields;
  end;

{ TxlUnboundDataSet }

procedure TxlUnboundDataSet.Open;
begin
  FBuff := UnAssigned;
  FEOF := false;
  FRecNo := 0;
  FFldTypes := TList.Create;
end;

procedure TxlUnboundDataSet.Close;
begin
  FFldTypes.Free;
  FRecNo := 0;
  FEOF := false;
  FBuff := UnAssigned;
end;

procedure TxlUnboundDataSet.GetFields;
var
  i, FldCount: integer;
  FldName: string;
  FldType: TxlDataType;
begin
  (DataSource as TxlDataSource).FOnGetDataSourceInfo(DataSource as TxlDataSource, FldCount);
  for i := 0 to FldCount - 1 do begin
    (DataSource as TxlDataSource).FOnGetFieldInfo(DataSource as TxlDataSource, i,
      FldName, FldType);
    Fields.Add(FldName);
    FFldTypes.Add(Pointer(FldType));
  end;
  if Fields.Count > 0 then
    FBuff := VarArrayCreate([0, Fields.Count - 1], varVariant);
end;

procedure TxlUnboundDataSet.GetFieldsType;
var
  i: integer;
begin
  for i := 0 to Fields.Count - 1 do
    FieldType[i] := TxlDataType(FFldTypes[i]);
  if DataSource.RangeType = rtNoRange then begin
    for i := 0 to Fields.Count - 1 do
      FBuff[i] := UnAssigned;
    (DataSource as TxlDataSource).FOnGetRecord(DataSource as TxlDataSource, FRecNo, FBuff, FEOF);
    if FEOF then
      for i := 0 to Fields.Count - 1 do
        FBuff[i] := UnAssigned;
  end;
end;

function TxlUnboundDataSet.Name: string;
begin
  // not supported
end;

function TxlUnboundDataSet.Active: boolean;
begin
  Result := (Fields.Count > 0) and (not _VarIsEmpty(FBuff));
end;

procedure TxlUnboundDataSet.EnableControls;
begin
  // not supported
end;

procedure TxlUnboundDataSet.DisableControls;
begin
  // not supported
end;

function TxlUnboundDataSet.Bof: boolean;
begin
  Result := FRecNo = 0;
end;

function TxlUnboundDataSet.Eof: boolean;
begin
  Result := FEOF;
end;

procedure TxlUnboundDataSet.First;
begin
  Inc(FRecNo);
  (DataSource as TxlDataSource).FOnGetRecord(DataSource as TxlDataSource, FRecNo, FBuff, FEOF);
  if Eof then
    FRecNo := 0;
end;

procedure TxlUnboundDataSet.Next;
var
  i: integer;
begin
  Inc(FRecNo);
  for i := 0 to Fields.Count - 1 do
    FBuff[i] := UnAssigned;
  (DataSource as TxlDataSource).FOnGetRecord(DataSource as TxlDataSource, FRecNo, FBuff, FEOF);
  if FEOF then
    for i := 0 to Fields.Count - 1 do
      FBuff[i] := UnAssigned;
end;

procedure TxlUnboundDataSet.SetBookmark;
begin
  // not supported
end;

procedure TxlUnboundDataSet.GotoBookmark;
begin
  // not supported
end;

procedure TxlUnboundDataSet.SetFilter(const FieldIndex: integer);
begin
  // not supported
end;

function TxlUnboundDataSet.FieldIsEmpty(const Index: integer): boolean;
begin
  Result := _VarIsEmpty(FBuff[Index]);
end;

function TxlUnboundDataSet.FieldAsInteger(const Index: integer): integer;
begin
  Result := FBuff[Index];
end;

function TxlUnboundDataSet.FieldAsFloat(const Index: integer): extended;
begin
  Result := FBuff[Index];
end;

function TxlUnboundDataSet.FieldAsDateTime(const Index: integer): TDateTime;
begin
  Result := FBuff[Index];
end;

function TxlUnboundDataSet.FieldAsString(const Index: integer): string;
var
  MaxStrLen: integer;
begin
  MaxStrLen := xlrDDEMaxStrLen;
  Result := FBuff[Index];
  Result := TrimRight(Result);
  if Result <> '' then begin
    DeleteChars(#$0D, Result);
    if TxlExcelDataSource(DataSource).Report.DataExportMode = xlEngine.xdmCSV then
      ReplaceChars('"', '''', Result);
    case TxlExcelDataSource(DataSource).Report.DataExportMode of
      xlEngine.xdmCSV: MaxStrLen := xlrCSVMaxStrLen;
      xlEngine.xdmVariant: MaxStrLen := xlrVarMaxStrLen;
    end;
    if Length(Result) > MaxStrLen then
      Result := Copy(Result, 1, MaxStrLen);
  end;
end;

function TxlUnboundDataSet.FieldAsBoolean(const Index: integer): boolean;
begin
  Result := FBuff[Index];
end;

function TxlUnboundDataSet.FieldAsOLEVariant(const Index: integer): OLEVariant;
begin
  Result := FBuff[Index];
  if VarType(Result) = varOLEStr then
    if Length(Result) > xlrVarMaxStrLen then
      Result := Copy(Result, 1, xlrVarMaxStrLen);
end;

{ TxlDataSource }

function TxlDataSource.GetReport: TxlReport;
begin
  Result := (inherited Report) as TxlReport;
end;

procedure TxlDataSource.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
  if Assigned(Value) then
    if Alias = '' then
      Alias := Value.Name;
end;

// Create DataSet wrapper
function TxlDataSource.CreateXLDataSet: TxlAbstractDataSet;
begin
  Result := nil;
  if Assigned(DataSet) then begin
    Result := TxlVCLDataSet.Create(Self);
    (Result as TxlVCLDataSet).DataSet := DataSet;
  end
  else
    if Assigned(FOnGetDataSourceInfo) and Assigned(FOnGetFieldInfo) and
      Assigned(FOnGetRecord) then begin
      Result := TxlUnboundDataSet.Create(Self);
    end;
end;

procedure TxlDataSource.DoOnAfterDataTransfer;
begin
  if Assigned(OnAfterDataTransfer) then
  begin
   OnAfterDataTransfer(Self);
    // xldebug
    // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDatasourceOnAfterDataTransfer, Self, Null);
  end;
end;

procedure TxlDataSource.DoOnBeforeDataTransfer;
begin
  if Assigned(OnBeforeDataTransfer) then
  begin
   OnBeforeDataTransfer(Self);
    // xldebug
    // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDatasourceOnBeforeDataTransfer, Self, Null);
  end;
end;

procedure TxlDataSource.DoOnMacro(const MacroType: TxlMacroType;
  const MacroName: string; var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7,
  Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17,
  Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27,
  Arg28, Arg29, Arg30: OLEVariant);
begin
  if Assigned(FOnMacro) then
  begin
    FOnMacro(Self.Report, Self, MacroType, MacroName,
      Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10,
      Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20,
      Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30);
    // xldebug
    // TxlDebugLog(Report.FxlDebugLog).AddToLog(xdeDataSourceMacroParameters, Self, VarArrayOf([[MacroType, MacroName]]));
  end;
end;

function TxlDataSource.GetOptions: TxlRangeOptionsSet;
begin
  Result := TxlRangeOptionsSet(inherited Options);
end;

procedure TxlDataSource.SetOptions(const Value: TxlRangeOptionsSet);
begin
  inherited Options := xlEngine.TxlRangeOptionsSet(Value);
end;

{ TxlDataSources }

function TxlDataSources.Add: TxlDataSource;
begin
  Result := (inherited Add) as TxlDataSource;
end;

function TxlDataSources.GetItem(Index: integer): TxlDataSource;
begin
  Result := (inherited Items[Index]) as TxlDataSource;
end;

procedure TxlDataSources.SetItem(Index: integer; const Value: TxlDataSource);
begin
  inherited SetItem(Index, Value);
end;

function TxlDataSources.GetReport: TxlReport;
begin
  Result := (inherited Report) as TxlReport;
end;

{ TxlReportParam }

function TxlReportParam.GetReport: TxlReport;
begin
  Result := (inherited Report) as TxlReport;
end;

{ TxlReportParams }

function TxlReportParams.Add: TxlReportParam;
begin
  Result := TxlReportParam(inherited Add);
end;

function TxlReportParams.GetItem(Index: integer): TxlReportParam;
begin
  Result := TxlReportParam(inherited Items[Index]);
end;

function TxlReportParams.GetReport: TxlReport;
begin
  Result := TxlReport(inherited Report);
end;

procedure TxlReportParams.SetItem(Index: integer; const Value: TxlReportParam);
begin
  inherited SetItem(Index, Value);
end;

{ TxlReport }

constructor TxlReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

constructor TxlReport.CreateEx(AOwner: TComponent; AXLSTemplate,
  AActiveSheet, AMacroBefore, AMacroAfter: string;
  AOptions: TxlReportOptionsSet; ATempPath: string; AOnBeforeBuild,
  AOnAfterBuild: TxlReportHandleEvent);
begin
  Create(AOwner);
  Options := AOptions;
  XLSTemplate := AXLSTemplate;
  ActiveSheet := AActiveSheet;
  MacroBefore := AMacroBefore;
  MacroAfter := AMacroAfter;
  TempPath := ATempPath;
  OnBeforeBuild := AOnBeforeBuild;
  OnAfterBuild := AOnAfterBuild;
end;

function TxlReport.AddDataSet(ADataSet: TDataSet; ARange, AMacroBefore,
  AMacroAfter: string; AOptions: TxlRangeOptionsSet; AOnMacro: TxlOnMacro;
  AOnBeforeDataTransfer,
  AOnAfterDataTransfer: TxlDataTransferHandleEvent): TxlDataSource;
begin
  Result := DataSources.Add;
  Result.DataSet := ADataSet;
  Result.Options := AOptions;
  Result.Range := ARange;
  Result.MacroBefore := AMacroBefore;
  Result.MacroAfter := AMacroAfter;
  Result.OnBeforeDataTransfer := AOnBeforeDataTransfer;
  Result.OnAfterDataTransfer := AOnAfterDataTransfer;
  Result.OnMacro := AOnMacro;
end;

function TxlReport.CreateDataSources: TxlAbstractDataSources;
begin
  Result := TxlDataSources.Create(TxlDataSource, Self);
end;

function TxlReport.GetDataSources: TxlDataSources;
begin
  Result := (inherited DataSources) as TxlDataSources;
end;

procedure TxlReport.SetDataSources(const Value: TxlDataSources);
begin
  inherited DataSources := Value;
end;

function TxlReport.CreateParams: TxlAbstractParameters;
begin
  Result := TxlReportParams.Create(TxlReportParam, Self);
end;

function TxlReport.GetParams: TxlReportParams;
begin
  Result := (inherited Params) as TxlReportParams;
end;

procedure TxlReport.SetParams(const Value: TxlReportParams);
begin
  inherited Params := Value;
end;

function TxlReport.GetParamByName(Name: string): TxlReportParam;
begin
  Result := TxlReportParam(inherited ParamByName[Name]);
end;

procedure TxlReport.Notification(AComponent: TComponent; Operation: TOperation);
var
  i: integer;
begin
  if Operation = opRemove then begin
    if AComponent is TDataSet then
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].DataSet = AComponent then
          DataSources[i].DataSet := nil;
  end;
  inherited;
end;

function TxlReport.DoOnBreak: boolean;
begin
  Result := inherited DoOnBreak;
  {$IFNDEF XLR_TRIAL}
  if Assigned(FOnBreak) then
    FOnBreak(Self, Result);
  {$ENDIF}
  Canceled := Result;
end;

procedure TxlReport.DoOnAfterBuild;
begin
  if Assigned(OnAfterBuild) then
  begin
    OnAfterBuild(Self);
    // xldebug
    // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportOnAfterBuild, Self, Null);
  end;
end;

procedure TxlReport.DoOnBeforeBuild;
begin
  if Assigned(OnBeforeBuild) then
  begin
    OnBeforeBuild(Self);
    // xldebug
    // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportOnBeforeBuild, Self, Null);
  end;
end;

procedure TxlReport.DoOnBeforeWorkbookSave(var WorkbookFileName,
  WorkbookFilePath: string; Save: boolean);
begin
  if Assigned(OnBeforeWorkbookSave) then
    OnBeforeWorkbookSave(Self, WorkbookFileName, WorkbookFilePath, Save);
end;

procedure TxlReport.DoOnMacro(const MacroType: TxlMacroType;
  const MacroName: string; var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7,
  Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17,
  Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27,
  Arg28, Arg29, Arg30: OLEVariant);
begin
  if Assigned(FOnMacro) then
  begin
    FOnMacro(Self, nil, MacroType, MacroName,
      Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10,
      Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20,
      Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30);
    // xldebug
    // TxlDebugLog(FxlDebugLog).AddToLog(xdeReportMacroParameters, Self, VarArrayOf([[MacroType, MacroName]]));
  end;
end;

procedure TxlReport.DoOnProgress(const Position, Max: integer);
begin
  FProgressPos := Position;
  FProgressMax := Max;
  if Assigned(OnProgress2) then
    OnProgress2(Self, Position, Max, nil, -1);
  if Assigned(OnProgress) then
    OnProgress(Self, Position, Max);
end;

procedure TxlReport.DoOnTargetBookSheetName(ISourceSheet: IxlWorksheet;
  ITargetWorkbook: IxlWorkbook; var SheetName: string);
begin
  if Assigned(FOnTargetBookSheetName) then
    FOnTargetBookSheetName(Self as TxlReport, ISourceSheet, ITargetWorkbook, SheetName);
end;

procedure TxlReport.DoOnProgress2(DataSource: TxlExcelDataSource; const RecordCount: integer);
begin
  if Assigned(FOnProgress2) then
    OnProgress2(Self, FProgressPos, FProgressMax, DataSource as TxlDataSource, RecordCount);
end;

procedure TxlReport.Report;
begin
  inherited Report
end;

procedure TxlReport.Report(const APreview: boolean);
var
  OLDPreview: boolean;
begin
  OLDPreview := Preview;
  Preview := APreview;
  try
    Report;
  finally
    Preview := OLDPreview;
  end;
end;

procedure TxlReport.ReportTo(const WorkbookName: string; const NewWorkbookName: string = '');
begin
  inherited;
end;

procedure TxlReport.Edit;
begin
  inherited Edit;
end;

// class methods
class function TxlReport.GetOptionMap: TxlOptionMap;
begin
  Result := inherited GetOptionMap;
end;

class procedure TxlReport.ReleaseExcelApplication;
begin
  inherited ReleaseExcelApplication;
end;

class procedure TxlReport.ConnectToExcelApplication(OLEObject: OLEVariant);
begin
  inherited ConnectToExcelApplication(OLEObject);
end;

{$IFNDEF XLR_BCB}
class procedure TxlReport.MergeReports(Reports: array of TxlExcelReport;
  SheetPrefixes: array of string);
begin
  inherited;
end;
{$ENDIF}

function TxlReport.GetOptions: TxlReportOptionsSet;
begin
  Result := TxlReportOptionsSet(inherited Options);
end;

procedure TxlReport.SetOptions(const Value: TxlReportOptionsSet);
begin
  inherited Options := xlEngine.TxlReportOptionsSet(Value);
end;

function TxlReport.GetDataMode: TxlDataExportMode;
begin
  Result := TxlDataExportMode(inherited DataExportMode);
end;

procedure TxlReport.SetDataMode(const Value: TxlDataExportMode);
begin
  inherited DataExportMode := xlEngine.TxlDataExportMode(Value);
end;

end.

