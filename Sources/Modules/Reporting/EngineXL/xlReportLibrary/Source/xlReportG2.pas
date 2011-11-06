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

unit xlReportG2;

{$I xlcDefs.inc}                        

interface

uses Classes, ComObj, ActiveX, OleCtnrs, SysUtils, Windows, Forms, Dialogs,
  Clipbrd, DDEML, DDEMan,
  {$IFDEF XLR_VCL4}
    OleCtrls,
  {$ENDIF XLR_VCL4}
  {$IFDEF XLR_VCL6}
    Variants,
  {$ENDIF XLR_VCL6}
  {$IFNDEF XLR_AX}
    DB,
  {$ENDIF}
  xlcOPack, xlcClasses, xlEngine, xlReport;

type

{ Forward declaration of OLD XL Report classes }

  Tg2DataSource = class;
  Tg2DataSources = class;
  TxlReportG2 = class;

{ Additional types }

  // Report options
  Tg2ReportOptions = (roOptimizeLaunch, roNewInstance, roDisplayAlerts, roAddToMRU,
    roAutoSave, roUseTemp, roAutoSafe, roOnlyValues, roExtendOptions,
    roPivotTableSelection, roShowPivotBar, roAutoOpen, roAutoClose, roPivotMacro,
    roHideExcel);
  Tg2ReportOptionsSet = set of Tg2ReportOptions;

  // Range options
  Tg2RangeOptions = (rgoAutoFilter, rgoGroupNoSort, rgoOnlyValues, rgoRowsFit, rgoColsFit,
    rgoAutoOpen, rgoAutoClose);
  Tg2RangeOptionsSet = set of Tg2RangeOptions;

  // Data export mode
  Tg2DataExportMode = (demCSV, demVariant, demDDE);

  // Macro type
  Tg2Stage = (bsBeforeBuild, bsAfterBuild, bsMacroBefore, bsMacroAfter);

  // OnBefore/AfterBuild event handler
  Tg2ReportHandleEvent = procedure (Report: TxlReportG2) of object;

  // OnBefore/AfterDataTransfer
  Tg2DataTransferHandleEvent = procedure (DataSource: Tg2DataSource) of object;

  // OnMacro event handler
  Tg2OnMacro = procedure (Report: TxlReportG2; DataSource: Tg2DataSource;
    const AMacroType: Tg2Stage; const AMacroName: string;
    var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10,
    Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20,
    Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant) of object;

  // Save to selected file  event handler
  Tg2OnBeforeWorkbookSave = procedure (Report: TxlReportG2;
    var WorkbookName, WorkbookPath: string; Save: boolean) of object;

  // Progress
  Tg2OnProgress = procedure (Report: TxlReportG2; const Position, Max: integer) of object;

  // OnTargetBookSheetName
  Tg2OnTargetBookSheetName = procedure (Report: TxlReportG2; ISheet: IxlWorksheet; ITargetWorkbook: IxlWorkbook;
    var NewSheetName: string) of object;

{ Tg2DataSource class }

  Tg2DataSource = class(TxlDataSource)
  private
    FOptions: Tg2RangeOptionsSet;
    // events
    FBeforeTransfer: Tg2DataTransferHandleEvent;
    FAfterTransfer: Tg2DataTransferHandleEvent;
    FOnMacro: Tg2OnMacro;
    function GetReport: TxlReportG2;
    function GetOptions: Tg2RangeOptionsSet;
    procedure SetOptions(const Value: Tg2RangeOptionsSet);
  protected
    procedure ScanParsedCells(Formulas: OLEVariant); override;
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25,
      Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant); override;
    procedure DoOnBeforeDataTransfer; override;
    procedure DoOnAfterDataTransfer; override;
  public
    constructor Create(ACollection: TCollection); override;
    //
    property Report: TxlReportG2 read GetReport;
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
    // New v.4.0
    property MasterSource;
    property RangeType;
    property Row;
    property Column;
    property RowCount;
    property ColCount;
  published
    property DataSet;
    property Alias;
    property Range;
    property MacroBefore;
    property MacroAfter;
    property Options: Tg2RangeOptionsSet read GetOptions write SetOptions default [rgoAutoOpen] ;
    property Enabled;
    property Tag;
    property OnBeforeDataTransfer: Tg2DataTransferHandleEvent read FBeforeTransfer
      write FBeforeTransfer;
    property OnAfterDataTransfer: Tg2DataTransferHandleEvent read FAfterTransfer
      write FAfterTransfer;
    property OnMacro: Tg2OnMacro read FOnMacro write FOnMacro;
    // New v.4.0
    property MasterSourceName;
{                                                                                      }
{ Excluded previos version features:                                                   }
{                                                                                      }
{   property OnGetDataInfo;                                                            }
{   property OnGetFieldValue;                                                          }
{                                                                                      }
  end;

{ Tg2DataSources collection class }

  Tg2DataSources = class(TxlDataSources)
  private
    // properties
    function GetItem(Index: integer): Tg2DataSource;
    procedure SetItem(Index: integer; const Value: Tg2DataSource);
    function GetReport: TxlReportG2;
  protected
  public
    function Add: Tg2DataSource;
    property Report: TxlReportG2 read GetReport;
    property Items[Index: integer]: Tg2DataSource read GetItem write SetItem; default;
  end;

{ TxlReportG2 class }

  TxlReportG2 = class(TxlReport)
  private
    FOptions: Tg2ReportOptionsSet;
    // events
    FOnMacro: Tg2OnMacro;
    FOnBeforeWorkbookSave: Tg2OnBeforeWorkbookSave;
    FOnAfterBuild: Tg2ReportHandleEvent;
    FOnBeforeBuild: Tg2ReportHandleEvent;
    FOnProgress: Tg2OnProgress;
    FOnTargetBookSheetName: Tg2OnTargetBookSheetName;
    function GetDataSources: Tg2DataSources;
    procedure SetDataSources(const Value: Tg2DataSources);
    function GetOptions: Tg2ReportOptionsSet;
    procedure SetOptions(const Value: Tg2ReportOptionsSet);
    function GetDataMode: Tg2DataExportMode;
    procedure SetDataMode(const Value: Tg2DataExportMode);
    function GetLocaleID: LCID;
  protected
    function CreateDataSources: TxlAbstractDataSources; override;
    procedure Parse; override;
    procedure DoOnBeforeBuild; override;
    procedure DoOnAfterBuild; override;
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25,
      Arg26, Arg27, Arg28, Arg29, Arg30: OLEVariant); override;
    procedure DoOnProgress(const Position, Max: integer); override;
    procedure DoOnBeforeWorkbookSave(var WorkbookFileName, WorkbookFilePath: string;
      Save: boolean); override;
    procedure DoOnTargetBookSheetName(ISourceSheet: IxlWorksheet; ITargetWorkbook: IxlWorkbook;
      var SheetName: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    // Compatibility routines
    constructor CreateEx(AOwner: TComponent;
                       AXLSTemplate: string;
                       AActiveSheet: string = '';
                       AMacroBefore: string = '';
                       AMacroAfter: string = '';
                       AOptions: Tg2ReportOptionsSet = [roDisplayAlerts, roOptimizeLaunch, roAutoOpen, roPivotMacro];
                       ATempPath: string = '';
                       AOnBeforeBuild: Tg2ReportHandleEvent = nil;
                       AOnAfterBuild: Tg2ReportHandleEvent = nil); reintroduce; overload;
    procedure AddDataSet(ADataSet: TDataSet;
                         ASheet: string = '';
                         ARange: string = '';
                         AMacroBefore: string = '';
                         AMacroAfter: string = '';
                         AOptions: Tg2RangeOptionsSet = [rgoAutoOpen];
                         AOnBeforeDataTransfer: Tg2DataTransferHandleEvent = nil;
                         AOnAfterDataTransfer: Tg2DataTransferHandleEvent = nil);
    function AddDataSet2(ADataSet: TDataSet;
                         ARange: string = '';
                         AMacroBefore: string = '';
                         AMacroAfter: string = '';
                         AOptions: Tg2RangeOptionsSet = [rgoAutoOpen];
                         AOnMacro: Tg2OnMacro = nil;
                         AOnBeforeDataTransfer: Tg2DataTransferHandleEvent = nil;
                         AOnAfterDataTransfer: Tg2DataTransferHandleEvent = nil): Tg2DataSource;
    procedure Report; reintroduce; overload;
    procedure Report(const APreview: boolean); reintroduce; overload;
    procedure ReportTo(const WorkbookName: string; const NewWorkbookName: string = ''); override;
    procedure Edit;
    // class methods
    class function GetOptionMap: TxlOptionMap; override;
    class procedure ReleaseExcelApplication;
    class procedure ConnectToExcelApplication(OLEObject: OLEVariant);
    // used interfaces
    property LocaleID: LCID read GetLocaleID;
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
{                                                                                      }
{ Not supported previos version features (release later):                              }
{                                                                                      }
{   procedure AssignTo(Destination: TPersistent);                                      }
{   procedure ReportToOLEContainer(AOLEContainer: TOLEContainer);                      }
{   procedure ClearSourceList;                                                         }
{                                                                                      }
  published
    property ActiveSheet;
    property DataExportMode: Tg2DataExportMode read GetDataMode write SetDataMode default demDDE;
    property DataSources: Tg2DataSources read GetDataSources write SetDataSources;
    property TempPath;
    property MacroBefore;
    property MacroAfter;
    property Options: Tg2ReportOptionsSet read GetOptions write SetOptions default [roDisplayAlerts, roOptimizeLaunch,
      roAutoOpen, roPivotMacro];
    property XLSTemplate;
    // New v.4.0
    property Preview;
    // events
    property OnBeforeBuild: Tg2ReportHandleEvent read FOnBeforeBuild write FOnBeforeBuild;
    property OnAfterBuild: Tg2ReportHandleEvent read FOnAfterBuild write FOnAfterBuild;
    property OnMacro: Tg2OnMacro read FOnMacro write FOnMacro;
    property OnBeforeWorkbookSave: Tg2OnBeforeWorkbookSave read FOnBeforeWorkbookSave
      write FOnBeforeWorkbookSave;
    property OnProgress: Tg2OnProgress read FOnProgress write FOnProgress;
    property OnTargetBookSheetName: Tg2OnTargetBookSheetName read FOnTargetBookSheetName
      write FOnTargetBookSheetName;
{                                                                                      }
{ Excluded previos version features:                                                   }
{                                                                                      }
{   property ExtReportOptions;                                                         }
{   property ExtSheetOptions;                                                          }
{   property ExtRangeOptions;                                                          }
{   property ExtColumnOptions;                                                         }
{   property OnReportOption;                                                           }
{   property OnSheetOption;                                                            }
{   property OnRangeOption;                                                            }
{   property OnColumnOption;                                                           }
{                                                                                      }
  end;

implementation

{ Tg2DataSource }

constructor Tg2DataSource.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  inherited Options := (inherited Options) - [xrgoPreserveRowHeight];
end;

function Tg2DataSource.GetReport: TxlReportG2;
begin
  Result := (inherited Report) as TxlReportG2;
end;

function Tg2DataSource.GetOptions: Tg2RangeOptionsSet;
begin
  Result := [];
  if xrgoAutoOpen in (inherited Options) then
    Include(Result, xlReportG2.rgoAutoOpen);
  if xrgoAutoClose in (inherited Options) then
    Include(Result, xlReportG2.rgoAutoClose);
  Result := Result + FOptions;
end;

procedure Tg2DataSource.SetOptions(const Value: Tg2RangeOptionsSet);
begin
  FOptions := Value;
  if xlReportG2.rgoAutoOpen in (Value) then
    inherited Options :=  (inherited Options) + [xrgoAutoOpen];
  if xlReportG2.rgoAutoClose in (Value) then
    inherited Options :=  (inherited Options) + [xrgoAutoClose];
end;

procedure Tg2DataSource.DoOnAfterDataTransfer;
begin
  if Assigned(OnAfterDataTransfer) then
   OnAfterDataTransfer(Self);
end;

procedure Tg2DataSource.DoOnBeforeDataTransfer;
begin
  if Assigned(OnBeforeDataTransfer) then
   OnBeforeDataTransfer(Self);
end;

procedure Tg2DataSource.DoOnMacro(const MacroType: TxlMacroType;
  const MacroName: string; var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7,
  Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17,
  Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27,
  Arg28, Arg29, Arg30: OLEVariant);
var
  OldMacroType: Tg2Stage;
begin
  if MacroType = mtBefore then
    OldMacroType := bsMacroBefore
  else
    OldMacroType := bsMacroAfter;
  if Assigned(FOnMacro) then
    FOnMacro(Self.Report, Self, OldMacroType, MacroName,
      Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10,
      Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20,
      Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30);
end;

procedure Tg2DataSource.ScanParsedCells(Formulas: OLEVariant);
begin
  inherited;
  if rgoAutoFilter in Options then
    Report.OptionItems.ParseOptionsStr(Self, IRange, xoRange, 'AUTOFILTER');
  if rgoGroupNoSort in Options then
    Report.OptionItems.ParseOptionsStr(Self, IRange, xoRange, 'GROUPNOSORT');
  if rgoOnlyValues in Options then
    Report.OptionItems.ParseOptionsStr(Self, IRange, xoRange, 'ONLYVALUES');
  if rgoRowsFit in Options then
    Report.OptionItems.ParseOptionsStr(Self, IRange, xoRange, 'ROWSFIT');
  if rgoColsFit in Options then
    Report.OptionItems.ParseOptionsStr(Self, IRange, xoRange, 'COLSFIT');
end;

{ Tg2DataSources }

function Tg2DataSources.Add: Tg2DataSource;
begin
  Result := (inherited Add) as Tg2DataSource;
end;

function Tg2DataSources.GetItem(Index: integer): Tg2DataSource;
begin
  Result := (inherited Items[Index]) as Tg2DataSource;
end;

procedure Tg2DataSources.SetItem(Index: integer; const Value: Tg2DataSource);
begin
  inherited SetItem(Index, Value);
end;

function Tg2DataSources.GetReport: TxlReportG2;
begin
  Result := (inherited Report) as TxlReportG2;
end;

{ TxlReportG2 }

constructor TxlReportG2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [roOptimizeLaunch, roDisplayAlerts, roAutoOpen];
  DataExportMode := demDDE;
end;

constructor TxlReportG2.CreateEx(AOwner: TComponent; AXLSTemplate,
  AActiveSheet, AMacroBefore, AMacroAfter: string;
  AOptions: Tg2ReportOptionsSet; ATempPath: string; AOnBeforeBuild,
  AOnAfterBuild: Tg2ReportHandleEvent);
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

procedure TxlReportG2.AddDataSet(ADataSet: TDataSet; ASheet, ARange,
  AMacroBefore, AMacroAfter: string; AOptions: Tg2RangeOptionsSet;
  AOnBeforeDataTransfer, AOnAfterDataTransfer: Tg2DataTransferHandleEvent);
var
  xdsr: Tg2DataSource;
begin
  xdsr := DataSources.Add;
  xdsr.DataSet := ADataSet;
  xdsr.Options := AOptions;
  xdsr.Range := ARange;
  xdsr.MacroBefore := AMacroBefore;
  xdsr.MacroAfter := AMacroAfter;
  xdsr.OnBeforeDataTransfer := AOnBeforeDataTransfer;
  xdsr.OnAfterDataTransfer := AOnAfterDataTransfer;
end;

function TxlReportG2.AddDataSet2(ADataSet: TDataSet; ARange, AMacroBefore,
  AMacroAfter: string; AOptions: Tg2RangeOptionsSet; AOnMacro: Tg2OnMacro;
  AOnBeforeDataTransfer,
  AOnAfterDataTransfer: Tg2DataTransferHandleEvent): Tg2DataSource;
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

function TxlReportG2.CreateDataSources: TxlAbstractDataSources;
begin
  Result := Tg2DataSources.Create(Tg2DataSource, Self);
end;

function TxlReportG2.GetDataSources: Tg2DataSources;
begin
  Result := (inherited DataSources) as Tg2DataSources;
end;

procedure TxlReportG2.SetDataSources(const Value: Tg2DataSources);
begin
  inherited DataSources := Value;
end;

function TxlReportG2.GetOptions: Tg2ReportOptionsSet;
begin
  Result := FOptions;
end;

function TxlReportG2.GetLocaleID: LCID;
begin
  Result := xlrLCID;
end;

procedure TxlReportG2.SetOptions(const Value: Tg2ReportOptionsSet);
begin
  FOptions := Value;
  if roOptimizeLaunch in Value then
    inherited Options := (inherited Options) + [xroOptimizeLaunch];
  if roNewInstance in Value then
    inherited Options := (inherited Options) + [xroNewInstance];
  if roDisplayAlerts in Value then
    inherited Options := (inherited Options) + [xroDisplayAlerts];
  if roAddToMRU in Value then
    inherited Options := (inherited Options) + [xroAddToMRU];
  if roAutoSave in Value then
    inherited Options := (inherited Options) + [xroAutoSave];
  if roUseTemp in Value then
    inherited Options := (inherited Options) + [xroUseTemp];
  if roAutoOpen in Value then
    inherited Options := (inherited Options) + [xroAutoOpen];
  if roAutoClose in Value then
    inherited Options := (inherited Options) + [xroAutoClose];
  if roHideExcel in Value then
    inherited Options := (inherited Options) + [xroHideExcel];
end;

function TxlReportG2.GetDataMode: Tg2DataExportMode;
begin
  Result := demDDE;
  case inherited DataExportMode of
    xlReport.xdmVariant: Result := demVariant;
    xlReport.xdmCSV: Result := demCSV;
    xlReport.xdmDDE: Result := demDDE;
  end;
end;

procedure TxlReportG2.SetDataMode(const Value: Tg2DataExportMode);
begin
  case Value of
    demVariant: inherited DataExportMode := xdmVariant;
    demCSV: inherited DataExportMode := xdmCSV;
    demDDE: inherited DataExportMode := xdmDDE;
  end;
end;

procedure TxlReportG2.DoOnAfterBuild;
begin
  if Assigned(OnAfterBuild) then
    OnAfterBuild(Self);
end;

procedure TxlReportG2.DoOnBeforeBuild;
begin
  if Assigned(OnBeforeBuild) then
    OnBeforeBuild(Self);
end;

procedure TxlReportG2.DoOnBeforeWorkbookSave(var WorkbookFileName,
  WorkbookFilePath: string; Save: boolean);
begin
  if Assigned(OnBeforeWorkbookSave) then
    OnBeforeWorkbookSave(Self, WorkbookFileName, WorkbookFilePath, Save);
end;

procedure TxlReportG2.DoOnMacro(const MacroType: TxlMacroType;
  const MacroName: string; var Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7,
  Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17,
  Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27,
  Arg28, Arg29, Arg30: OLEVariant);
var
  OldMacroType: Tg2Stage;
begin
  if MacroType = mtBefore then
    OldMacroType := bsMacroBefore
  else
    OldMacroType := bsMacroAfter;
  if Assigned(FOnMacro) then
    FOnMacro(Self, nil, OldMacroType, MacroName,
      Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10,
      Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20,
      Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30);
end;

procedure TxlReportG2.DoOnProgress(const Position, Max: integer);
begin
  if Assigned(OnProgress) then
    OnProgress(Self, Position, Max);
end;

procedure TxlReportG2.DoOnTargetBookSheetName(ISourceSheet: IxlWorksheet;
  ITargetWorkbook: IxlWorkbook; var SheetName: string);
begin
  if Assigned(FOnTargetBookSheetName) then
    FOnTargetBookSheetName(Self as TxlReportG2, ISourceSheet, ITargetWorkbook, SheetName);
end;

procedure TxlReportG2.Parse;
begin
  inherited;
  if roOnlyValues in Options then
    OptionItems.ParseOptionsStr(Self, IWorkbook, xoWorkbook, 'ONLYVALUES');
  // roAutoSafe
  if roAutoSafe in Options then
    OptionItems.ParseOptionsStr(Self, IWorkbook, xoWorkbook, 'AUTOSAFE');
  // roShowPivotBar
  if roShowPivotBar in Options then
    OptionItems.ParseOptionsStr(Self, IWorkbook, xoWorkbook,
      'SHOWPIVOTBAR' + delAttr + xlrOn)
  else
    OptionItems.ParseOptionsStr(Self, IWorkbook, xoWorkbook,
      'SHOWPIVOTBAR' + delAttr + xlrOFF);
end;

procedure TxlReportG2.Report;
begin
  inherited Report
end;

procedure TxlReportG2.Report(const APreview: boolean);
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

procedure TxlReportG2.ReportTo(const WorkbookName: string; const NewWorkbookName: string = '');
begin
  inherited;
end;

procedure TxlReportG2.Edit;
begin
  inherited Edit;
end;

// class methods
class function TxlReportG2.GetOptionMap: TxlOptionMap;
begin
  Result := inherited GetOptionMap;
end;

class procedure TxlReportG2.ReleaseExcelApplication;
begin
  inherited ReleaseExcelApplication;
end;

class procedure TxlReportG2.ConnectToExcelApplication(OLEObject: OLEVariant);
begin
  inherited ConnectToExcelApplication(OLEObject);
end;

end.

