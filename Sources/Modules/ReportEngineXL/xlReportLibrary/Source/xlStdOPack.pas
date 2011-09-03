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

unit xlStdOPack;

{$I xlcDefs.inc}

interface

{ XL Report Standard Options Package
=======================================================================
OPTION          PARAMS                OBJECTS      RNG     Priority
=======================================================================
"OnlyValues"                          Workbook *           Lower
                                      Worksheet            Lower
                                      Range        rt      Lower
                                      Column *     rt      Lower
-----------------------------------------------------------------------
"AutoSafe"                            Workbook             CritLowest
                                      Worksheet            CritLowest
-----------------------------------------------------------------------
"ShowPivotBar"                        Workbook             Lower
-----------------------------------------------------------------------
"RowsFit"                             Workbook *           Lowest
                                      Worksheet            Lowest
                                      Range                Lowest
-----------------------------------------------------------------------
"ColsFit"                             Workbook *           Lowest      
                                      Worksheet            Lowest
                                      Range        rt      Lowest
                                      Column *     rt      Lowest
-----------------------------------------------------------------------
"SheetHide"                           Worksheet            CriticalLowest
-----------------------------------------------------------------------
"Delete"                              Worksheet            Lower       
-----------------------------------------------------------------------
"Hide"                                Worksheet            Lower
-----------------------------------------------------------------------
"AutoScale"                           Workbook *           Lowest
                                      Worksheet
-----------------------------------------------------------------------
"Sort"          "\Desc" *             Column       rt      Normal      
                "\Asc" *

"Desc"                                Column       rt      Normal

"Asc"                                 Column       rt      Normal
-----------------------------------------------------------------------
"AutoFilter"                          Range        r       Lowest
-----------------------------------------------------------------------
"Sum"                                 Column       rtmd    Normal
"Avg"
"Average" *
"Count"
"CountNums"
"Max"
"Min"
"Product"
"StDev"
"StDevP"
"Var"
"VarP"
=======================================================================
Note:
  * - new in version 4.0
  RNG:
    r - range
    t - root range
    m - master range
    d - detail range }

uses Classes, SysUtils, ComObj,
  {$IFDEF XLR_VCL4}
    OleCtrls,
  {$ENDIF}
  {$IFDEF XLR_VCL6}
    Variants,
  {$ENDIF}
  {$IFDEF XLR_VCL7}
    Variants,
  {$ENDIF}
  ActiveX,
  Excel8G2, Office8G2, xlcUtils, xlcOPack, xlcClasses;

type

  TxlStandardPackage = class(TxlOptionPackage)
  protected
    procedure GetPackageInfo(var AReportClass: TClass;
      var AName, AAuthor, AVersion: string); override;
  end;

  { TxlOptionV4 }

  TxlOptionV4 = class(TxlOption)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoneArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    function GetModuleLevelCode: string; override;
  public
    procedure DoMacro(Item: TxlOptionItem; const SubName: string; var Args: TxlOptionArgs); virtual;
  end;

  { Simple options }

  TopOnlyValues = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopAutoSafe = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopShowPivotBar = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopRowsFit = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopColumnsFit = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopSheetHide = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopSheetHide2 = class(TopSheetHide)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopAutoScale = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopAutoFilter = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  { Range sorting options }

  TopSort = class(TxlOptionV4)
  private
    FLinkedList: TList;
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoneArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopDesc = class(TopSort)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopAsc = class(TopSort)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  { Totals/Subtotals options }

  TxlTotalFunction = (tfSum, tfAverage, tfCount, tfCountNums, tfMax, tfMin,
    tfProduct, tfStDev, tfStDevP, tfVar, tfVarP);

  {$IFDEF XLR_VCL7}  // D7 bug fix
  TtfEnums = array[TxlTotalFunction] of TOldOLEEnum;
  {$ELSE}
  {$IFDEF XLR_VCL6}  // D6 bug fix
  TtfEnums = array[TxlTotalFunction] of TOldOLEEnum;
  {$ELSE}
  TtfEnums = array[TxlTotalFunction] of TOLEEnum;
  {$ENDIF XLR_VCL6}
  {$ENDIF XLR_VCL7}

  TopTotal = class(TxlOptionV4)
  private
    FTotalFunc: TxlTotalFunction;
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  public
    function Visible: boolean; override;
    property TotalFunc: TxlTotalFunction read FTotalFunc;
  end;

  TopSum = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopAverage = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopAverage2 = class(TopAverage)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopCount = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopCountNums = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopMax = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopMin = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopProduct = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopStDev = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopStDevP = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopVar = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopVarP = class(TopTotal)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  public
    function Visible: boolean; override;
  end;

  TopDeleteSheet = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

const

  xlrTotalFunctionXLConsts: TtfEnums =
    {$IFDEF XLR_VCL7}  // D7 bug fix
    ( TOldOLEEnum(xlSum), TOldOLEEnum(xlAverage), TOldOLEEnum(xlCount), TOldOLEEnum(xlCountNums),
      TOldOLEEnum(xlMax), TOldOLEEnum(xlMin), TOldOLEEnum(xlProduct), TOldOLEEnum(xlStDev),
      TOldOLEEnum(xlStDevP), TOldOLEEnum(xlVar), TOldOLEEnum(xlVarP) );
    {$ELSE}
    {$IFDEF XLR_VCL6}  // D6 bug fix
    ( TOldOLEEnum(xlSum), TOldOLEEnum(xlAverage), TOldOLEEnum(xlCount), TOldOLEEnum(xlCountNums),
      TOldOLEEnum(xlMax), TOldOLEEnum(xlMin), TOldOLEEnum(xlProduct), TOldOLEEnum(xlStDev),
      TOldOLEEnum(xlStDevP), TOldOLEEnum(xlVar), TOldOLEEnum(xlVarP) );
    {$ELSE}
    ( TOLEEnum(xlSum), TOLEEnum(xlAverage), TOLEEnum(xlCount), TOLEEnum(xlCountNums),
      TOLEEnum(xlMax), TOLEEnum(xlMin), TOLEEnum(xlProduct), TOLEEnum(xlStDev),
      TOLEEnum(xlStDevP), TOLEEnum(xlVar), TOLEEnum(xlVarP) );
    {$ENDIF XLR_VCL6}
    {$ENDIF XLR_VCL7}

implementation

uses
  xlPivotOPack, xlEngine;

type

  TtfNames = array[TxlTotalFunction] of string;

const

  xlrTotalFunctionNames: TtfNames =
    ( 'SUM', 'AVERAGE', 'COUNT', 'COUNTA', 'MAX', 'MIN',
      'PRODUCT', 'STDEV', 'STDEVP', 'VAR', 'VARP' );

  xlrTotalFunctionXLConstNames: TtfNames =
    ( 'xlSum', 'xlAverage', 'xlCount', 'xlCountNums', 'xlMax', 'xlMin',
      'xlProduct', 'xlStDev', 'xlStDevP', 'xlVar', 'xlVarP' );

{ TxlStandardPackage }

procedure TxlStandardPackage.GetPackageInfo(var AReportClass: TClass;
  var AName, AAuthor, AVersion: string);
begin
  AReportClass := TxlExcelReport;
  AName := '_Standard Options';
  AAuthor := 'Afalina Co., Ltd.';
  AVersion := '4.5';
  AddOptionClasses([
    // Simple options
    TopOnlyValues,
    {$IFNDEF XLR_TRIAL}
    TopAutoSafe,
    {$ENDIF}
    TopShowPivotBar,
    TopRowsFit, TopColumnsFit,
    TopSheetHide, TopSheetHide2,
    TopDeleteSheet,
    TopAutoScale,
    TopAutoFilter,
    // Sorting
    TopSort, TopDesc, TopAsc,
    // Totals
    TopTotal,
    TopSum, TopAverage, TopAverage2, TopCount, TopCountNums, TopMax,
    TopMin, TopProduct, TopStDev, TopStDevP, TopVar, TopVarP,
    // Grouping
    TopGroupNoSort, TopGroup,
    // Pivot
    TopPage, TopRow, TopColumn, TopData, TopAutoSubTotal, TopPivot]);
end;

{ TxlOptionV4 }

procedure TxlOptionV4.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  // Kill abstract stub
end;

procedure TxlOptionV4.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  // Kill abstract stub
  Item.Enabled := false;
end;

procedure TxlOptionV4.DoneArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  UBound, i: integer;
begin
  if not _VarIsEmpty(Args) and VarIsArray(Args) then begin
    UBound := VarArrayHighBound(Args, 1);
    for i := 5 to UBound do
      Args[i] := UnAssigned;
    VarArrayReDim(Args, 4);
  end;
end;

procedure TxlOptionV4.DoMacro(Item: TxlOptionItem; const SubName: string;
  var Args: TxlOptionArgs);
var
  ItemSubName, ItemSubCode, s: string;
  Report: TxlExcelReport;
  IModule: IxlVBComponent;
  IXLApp: IxlApplication;
begin
  ItemSubName := GetTempName('op' + Self.Name + '_' + Self.ClassName + '_');
  ItemSubCode :=
    'PUBLIC SUB ' + ItemSubName + ' (Args As Variant)' + vbCR +
    '  ' + SubName + ' Args' + vbCR +
    'END SUB';
  Report := Item.List.Owner as TxlExcelReport;
  IModule := Report.IModule;
  IXLApp := Report.IXLSApp;
  IModule.CodeModule.AddFromString(ItemSubCode);
  BeforeRunMacro(IXLApp, xroHideExcel in (Item.List.Owner as TxlExcelReport).Options);
  s := '''' + Report.IWorkbook.Name + '''' + '!' + xlrModuleName + '.' + ItemSubName;
  try
    OLEVariant(IXLApp).Run(s, Args);
  except
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateResFmt2(ecMacroRuntimeError, ecMacroRuntimeError, [s]);
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecMacroRuntimeError, [s]);
    {$ENDIF}
  end;
end;

function TxlOptionV4.GetModuleLevelCode: string;
begin
  Result := '';
end;

{ TopOnlyValues }

procedure TopOnlyValues.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray; var ALinkedOptions: TxlOptionNamesArray;
  var ALibraryCode: string; var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'ONLYVALUES';
  AxlObjects := [xoWorkbook, xoWorksheet, xoRange, xoColumn];
  APriorityArr[xoWorkbook] := opLower;
  APriorityArr[xoWorksheet] := opLower;
  APriorityArr[xoRange] := opLower;
  APriorityArr[xoColumn] := opLower;
  ASupportedRanges := rtRoots + [rtRangeArbitrary];
end;

procedure TopOnlyValues.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);

  procedure SetOnlyValues(IRange: IxlRange);
  begin
    IRange.Copy(EmptyParam);
    IRange.PasteSpecial(TOLEEnum(xlPasteValues), TOLEEnum(xlPasteSpecialOperationNone),
      false, false);
    {$IFDEF XLR_BCB}
    OLEVariant(IRange.Application).CutCopyMode := false;
    {$ELSE}
    OLEVariant(IRange.Application_).CutCopyMode := false;
    {$ENDIF}
  end;

var
  i, iCount: integer;
  Dsr: TxlExcelDataSource;
  IWorksheets: IxlWorksheets;
  ISheet: IxlWorksheet;
  IRange: IxlRange;
begin
  case Item.xlObject of
    // Column
    xoColumn:
      begin
        Dsr := (Item.Obj as TxlAbstractCell).DataSource as TxlExcelDataSource;
        {$IFDEF XLR_BCB}
        IRange := Dsr.IWorksheet.Range[Dsr.Range, EmptyParam];
        IRange.Columns.Item[(Item.Obj as TxlAbstractCell).Column, EmptyParam];
        {$ELSE}
        IRange := Dsr.IWorksheet.Range[Dsr.Range, EmptyParam] as IxlRange;
        IDispatch(IRange) := IRange.Columns.Item[(Item.Obj as TxlAbstractCell).Column, EmptyParam];
        {$ENDIF}
        if not Item.List.ExistsOfIUnk(IRange.Worksheet, xoWorksheet, [TopOnlyValues]) then
          SetOnlyValues(IRange);
      end;
    // Range
    xoRange:
      if (Item.Obj as TxlExcelDataSource).RangeType in [rtRange, rtRangeRoot] then begin
        {$IFDEF XLR_BCB}
        IRange := Item.IUnk;
        {$ELSE}
        IRange := Item.IUnk as IxlRange;
        {$ENDIF}
        if not Item.List.ExistsOfIUnk(IRange.Worksheet, xoWorksheet, [TopOnlyValues]) then
          SetOnlyValues(IRange);
      end;
    // Worksheet
    xoWorksheet:
      begin
        {$IFDEF XLR_BCB}
        ISheet := Item.IUnk;
        if not Item.List.ExistsOfIUnk(ISheet.Parent, xoWorkbook, [TopOnlyValues]) then
          SetOnlyValues(ISheet.UsedRange);
        {$ELSE}
        ISheet := Item.IUnk as IxlWorksheet;
        if not Item.List.ExistsOfIUnk(ISheet.Parent as IxlWorkbook, xoWorkbook,
          [TopOnlyValues]) then
          SetOnlyValues(ISheet.UsedRange[xlrLCID] as IxlRange);
        {$ENDIF}
      end;
    // Report
    xoWorkbook:
      begin
        IWorksheets := (Item.Obj as TxlExcelReport).IWorksheets;
        iCount := IWorksheets.Count;
        for i := 1 to iCount do begin
          {$IFDEF XLR_BCB}
          ISheet := IWorksheets.Item[i];
          SetOnlyValues(ISheet.UsedRange);
          {$ELSE}
          ISheet := IWorksheets.Item[i] as IxlWorksheet;
          SetOnlyValues(ISheet.UsedRange[xlrLCID] as IxlRange);
          {$ENDIF}
        end;
      end;
  end; // case
end;

{ TopAutoSafe }

procedure TopAutoSafe.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'AUTOSAFE';
  AxlObjects := [xoWorkbook, xoWorksheet];
  APriorityArr[xoWorkbook] := opCriticalLowest;
  APriorityArr[xoWorksheet] := opCriticalLowest;
end;

procedure TopAutoSafe.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  i, iCount: integer;
  IWorksheets: IxlWorksheets;
  ISheet: IxlWorksheet;
begin
  case Item.xlObject of
    // Worksheet
    xoWorksheet:
      begin
        {$IFDEF XLR_BCB}
        ISheet := Item.IUnk;
        if not Item.List.ExistsOfIUnk(ISheet.Parent, xoWorkbook, [TopAutoSafe]) then
          // ISheet.Protect(CreateClassID, true, true, true, EmptyParam, xlrLCID);
          Args := Args + vbCR + 'Worksheets(' + IntToStr(ISheet.Index) +
            ').Protect "' + GetTempName('') + '", TRUE, TRUE, TRUE';
        {$ELSE}
        ISheet := Item.IUnk as IxlWorksheet;
        if not Item.List.ExistsOfIUnk(ISheet.Parent as IxlWorkbook, xoWorkbook,
          [TopAutoSafe]) then
          // ISheet.Protect(CreateClassID, true, true, true, EmptyParam, xlrLCID);
          Args := Args + vbCR + 'Worksheets(' + IntToStr(ISheet.Index[xlrLCID]) +
            ').Protect "' + GetTempName('') + '", TRUE, TRUE, TRUE';
        {$ENDIF}
      end;
    // Report
    xoWorkbook:
      begin
        IWorksheets := (Item.Obj as TxlExcelReport).IWorksheets;
        iCount := IWorksheets.Count;
        for i := 1 to iCount do begin
          {$IFDEF XLR_BCB}
          ISheet := IWorksheets.Item[i];
          {$ELSE}
          ISheet := IWorksheets.Item[i] as IxlWorksheet;
          {$ENDIF}
          if not _EqualIntf(ISheet, (Item.List.Owner as TxlExcelReport).ITempSheet) then
          // ISheet.Protect(CreateClassID, true, true, true, EmptyParam, xlrLCID);
            Args := Args + vbCR + '  Worksheets(' + IntToStr(i) +
              ').Protect "' + GetTempName('') + '", TRUE, TRUE, TRUE';
        end;
        // (Item.List.Owner as TxlExcelReport).IWorkbook.Protect(CreateClassID, true, EmptyParam);
        Args := Args + vbCR + '  ActiveWorkbook.Protect "' + GetTempName('') + '", TRUE';
      end;
  end; // case
end;

{ TopShowPivotBar }

procedure TopShowPivotBar.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray; var ALinkedOptions: TxlOptionNamesArray;
  var ALibraryCode: string; var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'SHOWPIVOTBAR';
  AxlObjects := [xoWorkbook];
  APriorityArr[xoWorkbook] := opLower;
end;

procedure TopShowPivotBar.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  Show: boolean;
begin
  Show := Item.Params.Count = 0;
  if not Show then
    Show := Item.Params.Strings[0] <> xlrOff;
  (Item.Obj as TxlExcelReport).IXLSApp.CommandBars.Item['PivotTable'].Visible := Show;
end;

{ TopRowsFit }

procedure TopRowsFit.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'ROWSFIT';
  AxlObjects := [xoWorkbook, xoWorksheet, xoRange];
  APriorityArr[xoWorkbook] := opLowest;
  APriorityArr[xoWorksheet] := opLowest;
  APriorityArr[xoRange] := opLowest;
  ASupportedRanges := rtRoots + [rtRangeArbitrary];
end;

procedure TopRowsFit.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  i, iCount: integer;
  IWorksheets: IxlWorksheets;
  ISheet: IxlWorksheet;
  IRange: IxlRange;
begin
  case Item.xlObject of
    // Range
    xoRange:
      begin
        {$IFDEF XLR_BCB}
        IRange := Item.IUnk;
        {$ELSE}
        IRange := Item.IUnk as IxlRange;
        {$ENDIF}
        if not Item.List.ExistsOfIUnk(IRange.Worksheet, xoWorksheet, [TopRowsFit]) then
          IRange.EntireRow.AutoFit;
      end;
    // Worksheet
    xoWorksheet:
      begin
        {$IFDEF XLR_BCB}
        ISheet := Item.IUnk;
        if not Item.List.ExistsOfIUnk(ISheet.Parent, xoWorkbook, [TopRowsFit]) then
          ISheet.UsedRange.EntireRow.AutoFit;
        {$ELSE}
        ISheet := Item.IUnk as IxlWorksheet;
        if not Item.List.ExistsOfIUnk(ISheet.Parent as IxlWorkbook, xoWorkbook,
          [TopRowsFit]) then
          (ISheet.UsedRange[xlrLCID] as IxlRange).EntireRow.AutoFit;
        {$ENDIF}
      end;
    // Report
    xoWorkbook:
      begin
        IWorksheets := (Item.Obj as TxlExcelReport).IWorksheets;
        iCount := IWorksheets.Count;
        for i := 1 to iCount do begin
          {$IFDEF XLR_BCB}
          ISheet := IWorksheets.Item[i];
          ISheet.UsedRange.EntireRow.AutoFit;
          {$ELSE}
          ISheet := IWorksheets.Item[i] as IxlWorksheet;
          (ISheet.UsedRange[xlrLCID] as IxlRange).EntireRow.AutoFit;
          {$ENDIF}
        end;
      end;
  end; // case
end;

{ TopColumnsFit }

procedure TopColumnsFit.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'COLSFIT';
  AxlObjects := [xoWorkbook, xoWorksheet, xoRange, xoColumn];
  APriorityArr[xoWorkbook] := opLowest;
  APriorityArr[xoWorksheet] := opLowest;
  APriorityArr[xoRange] := opCriticalLowest;
  APriorityArr[xoColumn] := opCriticalLowest;
  ASupportedRanges := rtRoots + [rtRangeArbitrary];
end;

procedure TopColumnsFit.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  i, iCount: integer;
  IWorksheets: IxlWorksheets;
  ISheet: IxlWorksheet;
  IRange: IxlRange;
begin
  case Item.xlObject of
    // Range
    xoRange, xoColumn:
      begin
        {$IFDEF XLR_BCB}
        IRange := Item.IUnk;
        {$ELSE}
        IRange := Item.IUnk as IxlRange;
        {$ENDIF}
        if Item.xlObject = xoRange then
          if (Item.Obj as TxlExcelDataSource).RangeType in [rtRange, rtRangeRoot] then
            IRange.Columns.Item[1, EmptyParam].Value := '';
        if not Item.List.ExistsOfIUnk(IRange.Worksheet, xoWorksheet, [TopColumnsFit]) then
          IRange.EntireColumn.AutoFit;
      end;
    // Worksheet
    xoWorksheet:
      begin
        {$IFDEF XLR_BCB}
        ISheet := Item.IUnk;
        if not Item.List.ExistsOfIUnk(ISheet.Parent, xoWorkbook, [TopColumnsFit]) then
          ISheet.UsedRange.EntireColumn.AutoFit;
        {$ELSE}
        ISheet := Item.IUnk as IxlWorksheet;
        if not Item.List.ExistsOfIUnk(ISheet.Parent as IxlWorkbook, xoWorkbook,
          [TopColumnsFit]) then
          (ISheet.UsedRange[xlrLCID] as IxlRange).EntireColumn.AutoFit;
        {$ENDIF}
      end;
    // Report
    xoWorkbook:
      begin
        IWorksheets := (Item.Obj as TxlExcelReport).IWorksheets;
        iCount := IWorksheets.Count;
        for i := 1 to iCount do begin
          {$IFDEF XLR_BCB}
          ISheet := IWorksheets.Item[i];
          ISheet.UsedRange.EntireColumn.AutoFit;
          {$ELSE}
          ISheet := IWorksheets.Item[i] as IxlWorksheet;
          (ISheet.UsedRange[xlrLCID] as IxlRange).EntireColumn.AutoFit;
          {$ENDIF}
        end;
      end;
  end; // case
end;

{ TopSheetHide }

procedure TopSheetHide.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'SHEETHIDE';
  AxlObjects := [xoWorksheet];
  APriorityArr[xoWorksheet] := opLower;
end;

procedure TopSheetHide.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  {$IFDEF XLR_BCB}
  if xlrDebug then
    Item.IUnk.Visible := TOLEEnum(xlSheetHidden)
  else
    Item.IUnk.Visible := TOLEEnum(xlSheetVeryHidden);
  {$ELSE}
  if xlrDebug then
    (Item.IUnk as IxlWorksheet).Visible[xlrLCID] := TOLEEnum(xlSheetHidden)
  else
    (Item.IUnk as IxlWorksheet).Visible[xlrLCID] := TOLEEnum(xlSheetHidden);
  {$ENDIF}
end;

{ TopSheetHide2 }

procedure TopSheetHide2.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'HIDE';
end;

{ TopAutoScale }

procedure TopAutoScale.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'AUTOSCALE';
  AxlObjects := [xoWorkbook, xoWorksheet];
  APriorityArr[xoWorkbook] := opLowest;
  APriorityArr[xoWorksheet] := opLowest;
end;

procedure TopAutoScale.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);

  procedure AutoScale(ISheet: IxlWorksheet);
  begin
    ISheet.PageSetup.Zoom := false;
    ISheet.PageSetup.FitToPagesTall := false;
    ISheet.PageSetup.FitToPagesWide := 1;
  end;

var
  i, iCount: integer;
  IWorksheets: IxlWorksheets;
  ISheet: IxlWorksheet;
begin
  case Item.xlObject of
    // Worksheet
    xoWorksheet:
      begin
        {$IFDEF XLR_BCB}
        ISheet := Item.IUnk;
        if not Item.List.ExistsOfIUnk(ISheet.Parent, xoWorkbook, [TopAutoScale]) then
          AutoScale(ISheet);
        {$ELSE}
        ISheet := Item.IUnk as IxlWorksheet;
        if not Item.List.ExistsOfIUnk(ISheet.Parent as IxlWorkbook, xoWorkbook,
          [TopAutoScale]) then
          AutoScale(ISheet);
        {$ENDIF}
      end;
    // Report
    xoWorkbook:
      begin
        IWorksheets := (Item.Obj as TxlExcelReport).IWorksheets;
        iCount := IWorksheets.Count;
        for i := 1 to iCount do begin
          {$IFDEF XLR_BCB}
          ISheet := IWorksheets.Item[i];
          {$ELSE}
          ISheet := IWorksheets.Item[i] as IxlWorksheet;
          {$ENDIF}
          AutoScale(ISheet);
        end;
      end;
  end; // case
end;

{ TopAutoFilter }

procedure TopAutoFilter.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'AUTOFILTER';
  AxlObjects := [xoRange];
  APriorityArr[xoRange] := opLower;
  ASupportedRanges := rtRoots + [rtRangeArbitrary];
end;

procedure TopAutoFilter.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  IRange: IxlRange;
  DS: TxlExcelDataSource;
begin
  DS := Item.Obj as TxlExcelDataSource;
//  if (DS.RangeType in rtRoots) and (DS.RowCount = 1) then begin
  if DS.RangeType in rtRoots then begin // altered for "delicate setting"
    {$IFDEF XLR_BCB}
    IRange := Item.IUnk;
    if not DS.IWorksheet.AutoFilterMode then
    {$ELSE}
    IRange := Item.IUnk as IxlRange;
    if not DS.IWorksheet.AutoFilterMode[xlrLCID] then
    {$ENDIF}
      OLEVariant(DS.IWorksheet.Range[ A1(IRange.Row - 1, IRange.Column + 1),
        A1(IRange.Row + IRange.Rows.Count,
          IRange.Column + IRange.Columns.Count - 1)]).AutoFilter;
  end;
end;

{ TopSort }

procedure TopSort.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrSortRange(Args As Variant)' + vbCR +
  '  Dim Sheet As Worksheet' + vbCR +
  '  Dim Root As Range, R As Range' + vbCR +
  '  Dim Ranges As Variant' + vbCR +
  '  Dim RangesCount As Long, i As Long, Index As Long' + vbCR +
  '  Dim StartRow As Long, EndRow As Long, ColumnCount As Long' + vbCR +
  '  Dim Columns As Variant, Orders As Variant' + vbCR +
  '  Dim SortCount As Long' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  Call xlrGetRanges(Args, Ranges)' + vbCR +
  '  If IsArray(Ranges) Then' + vbCR +
  '  RangesCount = UBound(Ranges) \ 2' + vbCR +
  '  Columns = Args(5)' + vbCR +
  '  Orders = Args(6)' + vbCR +
  '  SortCount = UBound(Columns)' + vbCR +
  '  ColumnCount = Root.Columns.Count' + vbCR +
  '  For i = 1 To RangesCount' + vbCR +
  '    Index = (i - 1) * 2' + vbCR +
  '    StartRow = Ranges(Index + 1)' + vbCR +
  '    EndRow = Ranges(Index + 2)' + vbCR +
  '    Set R = Sheet.Range(Root.Cells(StartRow, 1), Root.Cells(EndRow, ColumnCount))' + vbCR +
  '    If SortCount = 1 Then' + vbCR +
  '      R.Sort _' + vbCR +
  '        Key1:=R.Cells(1, Columns(1)), Order1:=Orders(1), _' + vbCR +
  '        Header:=xlNo, OrderCustom:=1, Orientation:=xlTopToBottom' + vbCR +
  '    ElseIf SortCount = 2 Then' + vbCR +
  '      R.Sort _' + vbCR +
  '        Key1:=R.Cells(1, Columns(1)), Order1:=Orders(1), _' + vbCR +
  '        Key2:=R.Cells(1, Columns(2)), Order2:=Orders(2), _' + vbCR +
  '        Header:=xlNo, OrderCustom:=1, Orientation:=xlTopToBottom' + vbCR +
  '    ElseIf SortCount = 3 Then' + vbCR +
  '      R.Sort _' + vbCR +
  '        Key1:=R.Cells(1, Columns(1)), Order1:=Orders(1), _' + vbCR +
  '        Key2:=R.Cells(1, Columns(2)), Order2:=Orders(2), _' + vbCR +
  '        Key3:=R.Cells(1, Columns(3)), Order3:=Orders(3), _' + vbCR +
  '        Header:=xlNo, OrderCustom:=1, Orientation:=xlTopToBottom' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCR +
  '  End If' + vbCr +
  'End Sub';
begin
  AName := 'SORT';
  AxlObjects := [xoColumn];
  APriorityArr[xoColumn] := opNormal;
  ALinkedOptions[xoColumn] := 'SORT;ASC;DESC';
  ALibraryCode := SubText;
  ASupportedRanges := rtCompleteRanges;
end;

procedure TopSort.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);

  function SortOrder(Itm: TxlOptionItem): OLEVariant;
  begin
    Result := Variant(xlAscending);
    // Sort
    if (Itm.Option.Name = 'SORT') or (Itm.Option.Name = 'GROUP') then begin
      if Itm.Params.Count > 0 then
        if pos('DESC', Item.Params.Text) > 0 then
          Result := Variant(xlDescending);
    end
    else
      // Desc
      if Itm.Option.Name = 'DESC' then
        Result := Variant(xlDescending);
  end;

var
  i, SortCount, CurrentCol, j: integer;
  Added: boolean;
  Columns, SortOrders: OLEVariant;
begin
  inherited;
  FLinkedList := TList.Create;
  // Item
  Columns := VarArrayCreate([1, 1], varVariant);
  SortOrders := VarArrayCreate([1, 1], varVariant);
  Columns[1] := (Item.Obj as TxlAbstractCell).Column;
  SortOrders[1] := SortOrder(Item);
  SortCount := 1;
  // Linked items
  Item.List.LinkedItemsOfNames(Item, 'SORT;DESC;ASC;GROUP', [xoColumn], true, FLinkedList);
  for i := 0 to FLinkedList.Count - 1 do begin
    if TxlOptionItem(FLinkedList[i]).Obj <> Item.Obj then begin
      Added := false;
      CurrentCol := 1;
      for j := 1 to SortCount do begin
        CurrentCol := j;
        Added := Columns[j] = (TxlOptionItem(FLinkedList[i]).Obj as TxlAbstractCell).Column;
        if Added then
          Break;
      end;
      if not Added then begin
        VarArrayReDim(Columns, i + 2);
        Columns[i + 2] := (TxlOptionItem(FLinkedList[i]).Obj as TxlAbstractCell).Column;
        VarArrayReDim(SortOrders, i + 2);
        SortOrders[i + 2] := SortOrder(TxlOptionItem(FLinkedList[i]));
        Inc(SortCount);
      end
      else
        SortOrders[CurrentCol] := SortOrder(TxlOptionItem(FLinkedList[i]));
    end
    else begin
      if TxlOptionItem(FLinkedList[i]).Option.Name = 'DESC' then
        SortOrders[1] := Variant(xlDescending);
    end;
  end;
  VarArrayReDim(Args, 6);
  Args[5] := Columns;
  Args[6] := SortOrders;
end;

procedure TopSort.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  if (Item.Obj as TxlAbstractCell).DataSource.RowCount > 1 then
    Exit;
  // Do sort
  DoMacro(Item, 'xlrSortRange', Args);
end;

procedure TopSort.DoneArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  i: integer;
begin
  for i := 0 to FLinkedList.Count - 1 do
    TxlOptionItem(FLinkedList[i]).Enabled := false;
  FLinkedList.Free;
  inherited;
end;

{ TopDesc }

procedure TopDesc.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'DESC';
  ALibraryCode := '';
end;

{ TopAsc }

procedure TopAsc.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'ASC';
  ALibraryCode := '';
end;

{ TopTotal }

procedure TopTotal.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrRangeTotals(Args As Variant)' + vbCR +
  '  Dim Sheet As Worksheet' + vbCR +
  '  Dim Root As Range, Dst As Range, Cnd As Range, Cell As Range' + vbCR +
  '  Dim CndStr As String, Func As String, ColNum As String' + vbCR +
  '  Dim Ranges As Variant' + vbCR +
  '  Dim Column As Long, RangesCount As Long' + vbCR +
  '  Dim Index As Long, StartRow As Long, EndRow As Long' + vbCR +
  '  Dim IsSingleRange As Boolean, i As Long' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  ColNum = "_1"' + vbCR +
  '  CndStr = """" & Args(2) & ColNum & """"' + vbCR +
  '  Column = Args(5)' + vbCR +
  '  Call xlrGetRanges(Args, Ranges)' + vbCR +
  '  If IsArray(Ranges) Then' + vbCR +
  '    RangesCount = UBound(Ranges) \ 2' + vbCR +
  '    IsSingleRange = Args(7)' + vbCR +
  '    Func = Args(6)' + vbCR +
  '    For i = 1 To RangesCount' + vbCR +
  '      Index = (i - 1) * 2' + vbCR +
  '      StartRow = Ranges(Index + 1)' + vbCR +
  '      EndRow = Ranges(Index + 2)' + vbCR +
  '      Set Dst = Sheet.Range(Root.Cells(StartRow, Column), Root.Cells(EndRow, Column))' + vbCR +
  '      Set Cnd = Sheet.Range(Root.Cells(StartRow, 1), Root.Cells(EndRow, 1))' + vbCR +
  '      Set Cell = Root.Cells(EndRow + 1, Column)' + vbCR +
  '      If IsSingleRange = TRUE Then' + vbCR +
  '        Cell.Formula = "=" & Func & "(" & Dst.Address(ReferenceStyle:=xlR1C1) & ")"' + vbCR +
  '        ' + vbCR +
  '      Else  ' + vbCR +
  '        Cell.Value = 0' + vbCR +
  '        Cell.FormulaArray = "=" & Func & "(IF(" & _' + vbCR +
  '        Cnd.Address(ReferenceStyle:=xlR1C1) & "=" & CndStr & "," & _' + vbCR +
  '        Dst.Address(ReferenceStyle:=xlR1C1) & ",0))"' + vbCR +
  '        Cell.Value = Cell.Value' + vbCR +
  '      End If' + vbCR +
  '    Next' + vbCR +
  '  End If' + vbCR +
  'End Sub';
begin
  AName := opSvc + 'ServiceTotal';
  FTotalFunc := tfSum;
  AxlObjects := [xoColumn];
  APriorityArr[xoColumn] := opNormal;
  ALibraryCode := SubText;
  ADeleteSpecialRow := saNoDelete;
  ASupportedRanges := rtAllRanges + [rtRangeArbitrary];
end;

procedure TopTotal.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  VarArrayReDim(Args, 7);
  Args[5] := TxlAbstractCell(Item.Obj).Column;
  Args[6] := xlrTotalFunctionNames[TotalFunc];
  Args[7] := (Item.Obj as TxlAbstractCell).DataSource.RangeType = rtRange;
end;

procedure TopTotal.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotals', Args);
end;

function TopTotal.Visible: boolean;
begin
  Result := false;
end;

{ TopSum }

procedure TopSum.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfSum;
  AName := 'SUM';
end;

function TopSum.Visible: boolean;
begin
  Result := true;
end;

{ TopAverage }

procedure TopAverage.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfAverage;
  AName := 'AVG';
end;

function TopAverage.Visible: boolean;
begin
  Result := true;
end;

{ TopAverage2 }

procedure TopAverage2.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'AVERAGE';
end;

function TopAverage2.Visible: boolean;
begin
  Result := true;
end;

{ TopCount }

procedure TopCount.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfCount;
  AName := 'COUNT';
end;

function TopCount.Visible: boolean;
begin
  Result := true;
end;

{ TopCountNums }

procedure TopCountNums.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfCountNums;
  AName := 'COUNTNUMS';
end;

function TopCountNums.Visible: boolean;
begin
  Result := true;
end;

{ TopMax }

procedure TopMax.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfMax;
  AName := 'MAX';
end;

function TopMax.Visible: boolean;
begin
  Result := true;
end;

{ TopMin }

procedure TopMin.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfMin;
  AName := 'MIN';
end;

function TopMin.Visible: boolean;
begin
  Result := true;
end;

{ TopProduct }

procedure TopProduct.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfProduct;
  AName := 'PRODUCT';
end;

function TopProduct.Visible: boolean;
begin
  Result := true;
end;

{ TopStDev }

procedure TopStDev.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfStDev;
  AName := 'STDEV';
end;

function TopStDev.Visible: boolean;
begin
  Result := true;
end;

{ TopStDevP }

procedure TopStDevP.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfStDevP;
  AName := 'STDEVP';
end;

function TopStDevP.Visible: boolean;
begin
  Result := true;
end;

{ TopVar }

procedure TopVar.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfVar;
  AName := 'VAR';
end;

function TopVar.Visible: boolean;
begin
  Result := true;
end;

{ TopVarP }

procedure TopVarP.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ALibraryCode := '';
  FTotalFunc := tfVarP;
  AName := 'VARP';
end;

function TopVarP.Visible: boolean;
begin
  Result := true;
end;

{ TopDeleteSheet }

procedure TopDeleteSheet.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'DELETE';
  AxlObjects := [xoWorksheet];
  APriorityArr[xoWorksheet] := opCriticalLowest;
end;

procedure TopDeleteSheet.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  IXLApp: IxlApplication;
  ISheet: IxlWorksheet;
  OldDA: boolean;
begin
  {$IFDEF XLR_BCB}
  ISheet := Item.IUnk;
  IXLApp := ISheet.Application;
  OldDA := IXLApp.DisplayAlerts;
  IXLApp.DisplayAlerts := false;
  ISheet.Delete;
  IXLApp.DisplayAlerts := OldDA;
  {$ELSE}
  ISheet := Item.IUnk as IxlWorksheet;
  IXLApp := ISheet.Application_;
  OldDA := IXLApp.DisplayAlerts[xlrLCID];
  IXLApp.DisplayAlerts[xlrLCID] := false;
  ISheet.Delete(xlrLCID);
  IXLApp.DisplayAlerts[xlrLCID] := OldDA;
  {$ENDIF}
end;

end.

