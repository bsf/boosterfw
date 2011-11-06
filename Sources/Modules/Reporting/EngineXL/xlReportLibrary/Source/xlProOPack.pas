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

unit xlProOPack;

{$I xlcDefs.inc}

interface

{ XL Report Professional Options Package
=======================================================================
OPTION          PARAMS                OBJECTS      RNG     Priority
=======================================================================
"Sum"           "\TotalOfRow=n" *     Column       rtmd    Normal
"Avg"
"Average"
"Count"
"CountNums"
"Max"
"Min"
"Product"
"StDev"
"StDevP"
"Var"
"VarP"
-----------------------------------------------------------------------
"Group"         "\Asc"                Column       rD      Higher
                "\Desc"
                "\Collapse"
                "\MergeLabels" *
                "\MergeLabels2" *
                "\PlaceToColumn=n" *
                "\WithHeader" *
                "\Disablesubtotals" *
                "\DisableOutline" *
                "\PageBreaks" *
-----------------------------------------------------------------------
"SmartGroup"                          Column       rD      Higher
                "GroupNoSort" * on as default
                "\MergeLabels" *  on as default
                "\MergeLabels2" *
                "\DisableSubTotals" *
                "\PageBreaks" *

-----------------------------------------------------------------------
"GroupNoSort"                         Workbook *   rD      Normal
                                      Worksheet *
                                      Range
-----------------------------------------------------------------------
"SummaryAbove" *                      Range        rD      Normal

"SummaryBelow" *                      Range        rD      Normal

-----------------------------------------------------------------------
"DisableGrandTotals" *                Range        rD      Normal
-----------------------------------------------------------------------
"GroupWithHeader" * "\GroupCount=n"   Range        r       Highest
-----------------------------------------------------------------------
"DeleteColumn" *                      Column       rt      CriticalLowest
-----------------------------------------------------------------------
"Outline" *     "\CollapseLevel=n"    Range        t       Lowest
-----------------------------------------------------------------------
"Chart" *       "Name=n"              Range        t       Highest - 5
=======================================================================
Note:
  * - new in ProOptionPack
  RNG:
    r - range
    t - root range
    m - master range
    d - detail range }

uses Classes, SysUtils, ComObj, ActiveX,
  {$IFDEF XLR_VCL7}
    Variants,
  {$ENDIF XLR_VCL7}
  {$IFDEF XLR_VCL6}
    Variants,
  {$ENDIF XLR_VCL6}
  {$IFDEF XLR_VCL4}
    OleCtrls,
  {$ENDIF XLR_VCL4}
  Excel8G2, Office8G2, xlcUtils, xlcOPack, xlcClasses, xlEngine, xlStdOPack,
  xlPivotOPack;

type

  { TxlProPackage }

  TxlProPackage = class(TxlOptionPackage)
  protected
    procedure GetPackageInfo(var AReportClass: TClass;
      var AName, AAuthor, AVersion: string); override;
  end;

  { Totals/Subtotals options }

  TopSumEx = class(TopSum)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopAverageEx = class(TopAverage)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopAverage2Ex = class(TopAverage2)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopCountEx = class(TopCount)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopCountNumsEx = class(TopCountNums)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopMaxEx = class(TopMax)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopMinEx = class(TopMin)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopProductEx = class(TopProduct)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopStDevEx = class(TopStDev)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopStDevPEx = class(TopStDevP)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopVarEx = class(TopVar)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopVarPEx = class(TopVarP)
  protected
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  { Grouping and subtotals }

  TopGroupNoSortEx = class(TopGroupNoSort)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopSummaryAbove = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopSummaryBelow = class(TopSummaryAbove)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopDisableGrandTotal = class(TopSummaryAbove)
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopGroupEx = class(TopGroup)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopSmartGroup = class(TopGroup)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopGroupWithHeader = class(TxlOptionV4)
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
    function GetModuleLevelCode: string; override;
  end;

  TopDeleteColumn = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopOutline = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopChart = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopPivotEx = class(TopPivot)
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;


procedure Register;

implementation

{$R xlProOPack.res}

procedure Register;
begin
  RegisterComponents('XL Report', [TxlProPackage]);
end;

{ TxlProPackage }

procedure TxlProPackage.GetPackageInfo(var AReportClass: TClass;
  var AName, AAuthor, AVersion: string);
begin
  AReportClass := TxlExcelReport;
  AName := 'ProOptionPack'#0153;
  AAuthor := 'Afalina Co., Ltd.';
  AVersion := '1.2 (build 122-' + xlrIDEVer + ')';
  AddOptionClasses([
    // Totals
    TopSumEx, TopAverageEx, TopAverage2Ex, TopCountEx, TopCountNumsEx, TopMaxEx,
    TopMinEx, TopProductEx, TopStDevEx, TopStDevPEx, TopVarEx, TopVarPEx,
    // Grouping
    TopSummaryAbove, TopSummaryBelow, TopDisableGrandTotal, TopGroupEx, TopSmartGroup,
    // Others
    TopOutline, TopDeleteColumn,
    // Charts
    TopChart,
    // Pivot tables
    TopPivotEx]);
end;

{ TopSumEx }

procedure TotalExInitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  VarArrayReDim(Args, 8);
  Args[8] := '_1';
  if Item.Params.Count > 0 then
    if Item.ParamExists('TOTALOFROW') then
      Args[8] := '_' + Item.ParamAsString('TOTALOFROW');
end;

procedure TopSumEx.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrRangeTotalsEx(Args As Variant)' + vbCR +
  '  Dim Sheet As Worksheet' + vbCR +
  '  Dim Root As Range, Dst As Range, Cnd As Range, Cell As Range' + vbCR +
  '  Dim CndStr As String, Func As String, ColNum As String' + vbCR +
  '  Dim Ranges As Variant' + vbCR +
  '  Dim Column As Long, RangesCount As Long' + vbCR +
  '  Dim Index As Long, StartRow As Long, EndRow As Long' + vbCR +
  '  Dim IsSingleRange As Boolean, i As Long' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  ColNum = Args(8)' + vbCR +
  '  CndStr = """" & Args(2) & ColNum & """"' + vbCR +
  '  Column = Args(5)' + vbCR +
  '  Call xlrGetRanges(Args, Ranges)' + vbCR +
  '  If IsArray(Ranges) Then' + vbCR +
  '  RangesCount = UBound(Ranges) \ 2' + vbCR +
  '  IsSingleRange = Args(7)' + vbCR +
  '  Func = Args(6)' + vbCR +
  '  For i = 1 To RangesCount' + vbCR +
  '    Index = (i - 1) * 2' + vbCR +
  '    StartRow = Ranges(Index + 1)' + vbCR +
  '    EndRow = Ranges(Index + 2)' + vbCR +
  '    Set Dst = Sheet.Range(Root.Cells(StartRow, Column), Root.Cells(EndRow, Column))' + vbCR +
  '    Set Cnd = Sheet.Range(Root.Cells(StartRow, 1), Root.Cells(EndRow, 1))' + vbCR +
  '    Set Cell = Root.Cells(EndRow + 1, Column)' + vbCR +
  '    If IsSingleRange = TRUE Then' + vbCR +
  '      Cell.Formula = "=" & Func & "(" & Dst.Address(ReferenceStyle:=xlR1C1) & ")"' + vbCR +
  '      ' + vbCR +
  '    Else  ' + vbCR +
  '      Cell.Value = 0' + vbCR +
  '      Cell.FormulaArray = "=" & Func & "(IF(" & _' + vbCR +
  '        Cnd.Address(ReferenceStyle:=xlR1C1) & "=" & CndStr & "," & _' + vbCR +
  '        Dst.Address(ReferenceStyle:=xlR1C1) & ",0))"' + vbCR +
  '      Cell.Value = Cell.Value' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCR +
  '  End If' + vbCR +
  'End Sub';
begin
  inherited GetOptionInfo(AName, AxlObjects, ASupportedRanges, APriorityArr,
    ALinkedOptions, ALibraryCode, ADeleteSpecialRow);
  ALibraryCode := SubText;
  ASupportedRanges := ASupportedRanges + [rtRangeArbitrary];
end;

procedure TopSumEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopSumEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopAverageEx }

procedure TopAverageEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopAverageEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopAverage2Ex }

procedure TopAverage2Ex.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopAverage2Ex.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopCountEx }

procedure TopCountEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopCountEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopCountNumsEx }

procedure TopCountNumsEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopCountNumsEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopMaxEx }

procedure TopMaxEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopMaxEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopMinEx }

procedure TopMinEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopMinEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopProductEx }

procedure TopProductEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopProductEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopStDevEx }

procedure TopStDevEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopStDevEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopStDevPEx }

procedure TopStDevPEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopStDevPEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopVarEx }

procedure TopVarEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopVarEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopVarPEx }

procedure TopVarPEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  inherited;
  TotalExInitArgs(Item, Args);
end;

procedure TopVarPEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  DoMacro(Item, 'xlrRangeTotalsEx', Args);
end;

{ TopGroupNoSortEx }

procedure TopGroupNoSortEx.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  ASupportedRanges := rtCompleteRanges;
end;

{ TopSummaryAbove }

procedure TopSummaryAbove.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'SUMMARYABOVE';
  AxlObjects := [xoRange];
  ASupportedRanges := rtCompleteRanges;
end;

{ TopSummaryBelow }

procedure TopSummaryBelow.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'SUMMARYBELOW';
  ASupportedRanges := rtCompleteRanges;
end;

{ TopDisableGrandTotal }

procedure TopDisableGrandTotal.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'DISABLEGRANDTOTALS';
end;

{ TopGroupEx }

procedure TopGroupEx.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrGroupEx(Args As Variant)' + vbCR +
  '  Rem' + vbCR +
  '  Dim Sheet As Worksheet, Root As Range, GroupRow As Range, r As Range' + vbCR +
  '  Dim SummaryAbove As Boolean' + vbCR +
  '  Dim Groups As Variant, GroupCells As Variant, MergeLabels As Variant, Outline As Variant' + vbCR +
  '  Dim i As Long, j As Long' + vbCR +
  '  If Not IsArray(Args(5)) Then Exit Sub' + vbCR +
  '  Rem' + vbCR +
  '  Application.DisplayAlerts = False' + vbCR +
  '  Rem' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Set GroupRow = Root.Rows(Root.Rows.Count)' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  Rem' + vbCR +
  '  Sheet.Rows(Root.Rows(1).Row).Insert xlShiftDown' + vbCR +
  '  Set Root = Application.Union(Root, Root.Rows(0))' + vbCR +
  '  ThisWorkbook.Names(Args(1)).Delete' + vbCR +
  '  ThisWorkbook.Names.Add Name:=Args(1), RefersTo:="=" & Chr(39) & Sheet.Name & Chr(39) & "!" & _' + vbCR +
  '    Root.Address(True, True, xlA1, False)' + vbCR +
  '  Set Root = Sheet.Range(Root.Cells(1, 1), Root.Cells(Root.Rows.Count, Root.Columns.Count))' + vbCR +
  '  Rem' + vbCR +
  '  SummaryAbove = (Args(8) = xlSummaryAbove)' + vbCR +
  '  Sheet.Outline.SummaryRow = Args(8)' + vbCR +
  '  Rem' + vbCR +
  '  Groups = Args(5)' + vbCR +
  '  GroupCells = Args(10)' + vbCR +
  '  MergeLabels = Args(11)' + vbCR +
  '  Outline = Args(12)' + vbCR +
  '  Rem' + vbCR +
  '  Call xlrGroupEx_DoGroup(Root, GroupRow, 1, 2, Groups, GroupCells, MergeLabels, SummaryAbove, Outline)' + vbCR +
  '  Rem' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Sheet.Rows(Root.Rows(1).Row).Delete xlShiftUp' + vbCR +
  '  Root.Rows(Root.Rows.Count).Delete xlShiftUp' + vbCR +
  '  Rem' + vbCR +
  '  If Args(9) > 0 Then' + vbCR +
  '    Sheet.Outline.ShowLevels (Args(9))' + vbCR +
  '  End If' + vbCR +
  '  Rem' + vbCR +
  '  Root.Rows.AutoFit' + vbCR +
  '  Root.Rows(1).AutoFit' + vbCR +
  '  Rem' + vbCR +
  '  Application.DisplayAlerts = True' + vbCR +
  'End Sub' + vbCR +
  '' + vbCR +
  'Function xlrGroupEx_DoGroup(ByRef r, ByRef GroupRow, Group, SRow, ByRef Groups, _' + vbCR +
  '  ByRef GroupCells, ByRef MergeLabels, SummaryAbove, ByRef Outline) As Long' + vbCR +
  '  Dim Column As Long, Row As Long, RowCount As Long' + vbCR +
  '  Dim cStartRow As Long, cValue As Variant, Value As Variant' + vbCR +
  '  Dim Sheet As Worksheet, Root As Range' + vbCR +
  '  Dim Allow As Boolean, InsertedRowCount As Long' + vbCR +
  '  Dim i As Long' + vbCR +
  '  Rem' + vbCR +
  '  InsertedRowCount = 0' + vbCR +
  '  If Group <= UBound(Groups) Then' + vbCR +
  '    Rem' + vbCR +
  '    Set Sheet = r.Parent' + vbCR +
  '    Column = Groups(Group)' + vbCR +
  '    cStartRow = SRow' + vbCR +
  '    cValue = r.Cells(SRow, Column).Value' + vbCR +
  '    Row = SRow + 1' + vbCR +
  '    RowCount = r.Rows.Count' + vbCR +
  '    Rem' + vbCR +
  '    While Row <= RowCount' + vbCR +
  '      Value = r.Cells(Row, Column).Value' + vbCR +
  '      Allow = (Value <> cValue) Or (Row = RowCount)' + vbCR +
  '      If Allow Then' + vbCR +
  '        Rem' + vbCR +
  '        If (MergeLabels(Group) <> 2) and (MergeLabels(Group) <> 4) Then' + vbCR +
  '          If SummaryAbove Then i = cStartRow Else i = Row' + vbCR +
  '          r.Rows(i).Insert xlShiftDown' + vbCR +
  '          r.Cells(i, GroupCells(Group)).Value = cValue' + vbCR +
  '          GroupRow.Copy' + vbCR +
  '          r.Rows(i).PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True' + vbCR +
  '          r.Rows(i).PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone' + vbCR +
  '          If (Group + 1) > UBound(Groups) Then' + vbCR +
  '            i = 0' + vbCR +
  '          Else' + vbCR +
  '            If SummaryAbove Then' + vbCR +
  '              Set Root = Sheet.Range(r.Cells(cStartRow, 1), r.Cells(Row + 1, r.Columns.Count))' + vbCR +
  '              i = xlrGroupEx_DoGroup(Root, GroupRow, Group + 1, 2, Groups, GroupCells, MergeLabels, SummaryAbove, Outline)' + vbCR +
  '            Else' + vbCR +
  '              Set Root = Sheet.Range(r.Cells(cStartRow - 1, 1), r.Cells(Row, r.Columns.Count))' + vbCR +
  '              i = xlrGroupEx_DoGroup(Root, GroupRow, Group + 1, 2, Groups, GroupCells, MergeLabels, SummaryAbove, Outline)' + vbCR +
  '            End If' + vbCR +
  '          End If' + vbCR +
  '          InsertedRowCount = InsertedRowCount + 1 + i' + vbCR +
  '          Row = Row + 1 + i' + vbCR +
  '        Rem' + vbCR +
  '        Else' + vbCR +
  '          If (Group + 1) > UBound(Groups) Then' + vbCR +
  '            i = 0' + vbCR +
  '          Else' + vbCR +
  '            Set Root = Sheet.Range(r.Cells(cStartRow - 1, 1), r.Cells(Row, r.Columns.Count))' + vbCR +
  '            i = xlrGroupEx_DoGroup(Root, GroupRow, Group + 1, 2, Groups, GroupCells, MergeLabels, SummaryAbove, Outline)' + vbCR +
  '          End If' + vbCR +
  '          InsertedRowCount = InsertedRowCount + i' + vbCR +
  '          Row = Row + i' + vbCR +
  '        End If' + vbCR +
  '        Rem' + vbCR +
  '        If MergeLabels(Group) > 0 Then' + vbCR +
  '          If (MergeLabels(Group) = 2) or (MergeLabels(Group) = 4) Then i = 0 Else i = 1' + vbCR +
  '          If SummaryAbove Then' + vbCR +
  '            Set Root = Sheet.Range(r.Cells(cStartRow + i, Column), r.Cells(Row - 1, Column))' + vbCR +
  '          Else' + vbCR +
  '            Set Root = Sheet.Range(r.Cells(cStartRow, Column), r.Cells(Row - 1 - i, Column))' + vbCR +
  '          End If' + vbCR +
  '          Root.Merge' + vbCR +
  '          If MergeLabels(Group) <> 2 Then Root.Value = ""' + vbCR +
  '        End If' + vbCR +
  '        Rem' + vbCR +
  '        If (MergeLabels(Group) <> 2) And (Outline(Group)) Then' + vbCR +
  '          If MergeLabels(Group) = 4 Then i = 1 Else i = 0' + vbCR +
  '          If SummaryAbove Then' + vbCR +
  '            Set Root = Sheet.Range(r.Rows(cStartRow + 1 + i), r.Rows(Row - 1))' + vbCR +
  '          Else' + vbCR +
  '            Set Root = Sheet.Range(r.Rows(cStartRow), r.Rows(Row - 2 - i))' + vbCR +
  '          End If' + vbCR +
  '          Root.Group' + vbCR +
  '        End If' + vbCR +
  '        Rem' + vbCR +
  '        cStartRow = Row' + vbCR +
  '        cValue = Value' + vbCR +
  '      End If' + vbCR +
  '      Row = Row + 1' + vbCR +
  '      RowCount = r.Rows.Count' + vbCR +
  '    Wend' + vbCR +
  '  End If' + vbCR +
  '  xlrGroupEx_DoGroup = InsertedRowCount' + vbCR +
  'End Function' + vbCR +

  'Public Sub xlrGroupEx2(Args As Variant)' + vbCR +
  '  Dim Sheet As Worksheet' + vbCR +
  '  Dim Root As Range, HeaderRow As Range, GroupRow As Range, r As Range' + vbCR +
  '  Dim Ranges As Variant, Groups As Variant, Funcs As Variant, FuncCols As Variant' + vbCR +
  '  Dim Disabled As Variant, PageBreaks As Variant, MergeLabels As Variant' + vbCR +
  '  Dim ColumnCount As Long, GroupCount As Long, FuncCount As Long, LevelCount As Long' + vbCR +
  '  Dim GroupIndex As Long, FuncIndex As Long, Row As Long, Level As Long, SummaryAbove As Boolean' + vbCR +
  '  Dim Processed As Boolean, LastRow As Long, r1 As Range, r2 As Range, i As Long' + vbCR +
  '  Rem' + vbCR +
  '  Call xlrGetRanges(Args, Ranges)' + vbCR +
  '  Rem' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Set HeaderRow = Root.Rows(0)' + vbCR +
  '  Set GroupRow = Root.Rows(Root.Rows.Count)' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  Groups = Args(5)' + vbCR +
  '  GroupCount = UBound(Groups)' + vbCR +
  '  Funcs = Args(6)' + vbCR +
  '  FuncCols = Args(7)' + vbCR +
  '  FuncCount = UBound(Funcs)' + vbCR +
  '  MergeLabels = Args(11)' + vbCR +
  '  Disabled = Args(14)' + vbCR +
  '  LevelCount = Args(15)' + vbCR +
  '  PageBreaks = Args(17)' + vbCR +
  '  ColumnCount = Root.Columns.Count' + vbCR +
  '  SummaryAbove = Args(8) = xlSummaryAbove' + vbCR +
  '  Rem' + vbCR +
  '  Application.DisplayAlerts = False' + vbCR +
  '  Rem' + vbCR +
  '  If Not IsArray(Ranges) Then Exit Sub' + vbCR +
  '  If (UBound(Ranges) \ 2) > 1 Then Exit Sub' + vbCR +
  '  Rem' + vbCR +
  '  Rem DoGroup' + vbCR +
  '  Level = 1' + vbCR +
  '  For GroupIndex = 1 To GroupCount' + vbCR +
  '    If Not Disabled(GroupIndex) Then' + vbCR +
  '      For FuncIndex = 1 To FuncCount' + vbCR +
  '        Set r = Sheet.Range(HeaderRow.Rows(1), Root.Rows(Root.Rows.Count - 1))' + vbCR +
  '        r.Subtotal Groups(GroupIndex), Funcs(FuncIndex), FuncCols(FuncIndex), False, PageBreaks(GroupIndex), Args(8)' + vbCR +
  '        Level = Level + 1' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCR +
  '  Rem' + vbCR +
  '  Rem DoFormat' + vbCR +
  '  If Level > 7 Then Level = 7' + vbCR +
  '  Set Root = Sheet.Range(HeaderRow.Rows(2), Root.Rows(Root.Rows.Count - 1))' + vbCR +
  '  Set r1 = Root' + vbCR +
  '  Sheet.Outline.ShowLevels Level' + vbCR +
  '  Set Root = Root.SpecialCells(xlCellTypeVisible)' + vbCR +
  // 1.01 begin
  '  Set r = GroupRow.SpecialCells(xlCellTypeVisible)' + vbCR +
  '  if r.Address = GroupRow.Address Then' + vbCR +
  '    GroupRow.Copy' + vbCR +
  '    Root.Rows.PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True, False' + vbCR +
  '    Root.Rows.PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone, False, False' + vbCR +
  // 1.01 end
  '  Else' + vbCR +
  '  LastRow = -1' + vbCR +
  '  For Each r In Root.Areas' + vbCR +
  '    GroupRow.Copy' + vbCR +
  '    If LastRow < r.Row Then' + vbCR +
  '      LastRow = r.Row' + vbCR +
  '      For i = 1 to r.Rows.Count' + vbCR +
  '        Set r2 = r1.Rows(r.Row - r1.Row + i)' + vbCR +
  '        r2.PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone, False, False' + vbCR +
  '        r2.PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True, False' + vbCR +
  '        LastRow = LastRow + 1' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCR +
  '  End If' + vbCR +
  '  Sheet.Outline.ShowLevels Level + 1' + vbCR +
  '  Set Root = Sheet.Range(Args(1))' + vbCR +
  '  Rem' + vbCR +
  '  Rem Delete GrandTotals' + vbCR +
  '  If Not SummaryAbove Then' + vbCR +
  '    Row = Root.Rows.Count - 1 - FuncCount' + vbCR +
  '    Processed = False' + vbCR +
  '    Do While Not Processed' + vbCR +
  '      Processed = Root.Rows(Row).OutlineLevel = 2' + vbCR +
  '      If Not Processed Then Root.Rows(Row).Delete xlShiftUp' + vbCR +
  '      Row = Row - 1' + vbCR +
  '    Loop' + vbCR +
  '  End If' + vbCR +
  '  Rem' + vbCR +
  '  Rem Rebuild range name' + vbCR +
  '  Set Root = Sheet.Range(HeaderRow.Rows(2).Cells(1, 1), Root.Cells(Root.Rows.Count, Root.Columns.Count))' + vbCR +
  '  ThisWorkbook.Names(Args(1)).Delete' + vbCR +
  '  ThisWorkbook.Names.Add Name:=Args(1), RefersTo:="=" & Chr(39) & Sheet.Name & Chr(39) & "!" & _' + vbCR +
  '    Root.Address(True, True, xlA1, False)' + vbCR +
  '  Rem' + vbCR +
  '  Rem Do merge labels' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Set Root = Sheet.Range(Root.Cells(1, 1), GroupRow.Rows(0))' + vbCR +
  '  Call xlrGroupEx2_DoGroup(Args(1), Root, SummaryAbove, Groups, MergeLabels, Args(10), FuncCount, GroupRow)' + vbCR +
  '  Rem' + vbCR +
  '  Rem Disable GrandTotals' + vbCR +
  '  If Args(16) Then' + vbCR +
  '    If Not SummaryAbove Then' + vbCR +
  '      Set Root = Sheet.Range(Root.Cells(Root.Rows.Count - FuncCount + 1, 1), Root.Cells(Root.Rows.Count, Root.Columns.Count))' + vbCR +
  '      Root.Delete xlShiftUp' + vbCR +
  '      Set Root = Range(Args(1))' + vbCR +
  '      Root.Rows.Ungroup' + vbCR +
  '    Else' + vbCR +
  '      Set Root = Sheet.Range(Root.Cells(1, 1), Root.Cells(FuncCount, Root.Columns.Count))' + vbCR +
  '      Root.EntireRow.Delete xlShiftUp' + vbCR +
  '      Set Root = Range(Args(1))' + vbCR +
  '      Root.Rows.Ungroup' + vbCR +
  '    End If' + vbCR +
  '  End If' + vbCR +
  '  Rem' + vbCR +
  '  GroupRow.Rows(1).Delete xlShiftUp' + vbCR +
  '  Rem' + vbCR +
  '  If Args(9) > 0 Then' + vbCR +
  '    Sheet.Outline.ShowLevels (Args(9))' + vbCR +
  '  Else' + vbCR +
  '    Sheet.Outline.ShowLevels Level + 1' + vbCR +
  '  End If' + vbCR +
  '  Rem' + vbCR +
  '  Application.DisplayAlerts = True' + vbCR +
  'End Sub' + vbCR +
  '' + vbCR +
  'Sub xlrGroupEx2_DoGroup(RootName, ByRef Root, SummaryAbove, ByRef Groups, ByRef MergeLabels, ByRef GroupCells, FuncCount, GroupRow As Range)' + vbCR +
  '  Dim Sheet As Worksheet, r As Range, iFuncCount As Long, Level As Long' + vbCR +
  '  Dim Group As Long, Row As Long, Column As Long, cStartRow As Long, cValue As Variant' + vbCR +
  '  Dim IsWithHeader As Boolean, rh As Range, rg As Range, StartWithHeaderCount As Long' + vbCR +
  '  Dim IsUngroup As Boolean, i As Long' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  Rem' + vbCR +
  '  Rem GetWithHeaderStartRow' + vbCR +
  '  StartWithHeaderCount = 0' + vbCR +
  '  For Group = 1 To UBound(Groups)' + vbCR +
  '    If MergeLabels(Group) >= 16 Then' + vbCR +
  '      StartWithHeaderCount = StartWithHeaderCount + 1' + vbCR +
  '    Else' + vbCR +
  '      Exit For' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCR +
  '  Rem' + vbCR +
  '  Rem ForEach in Groups' + vbCR +
  '  For Group = 1 To UBound(Groups)' + vbCR +
  '    Rem' + vbCR +
  '    If MergeLabels(Group) > 0 Then' + vbCR +
  '      IsWithHeader = MergeLabels(Group) >= 16' + vbCR +
  '      If IsWithHeader Then' + vbCR +
  '        If Group = 1 Then IsUngroup = True' + vbCR +
  '        MergeLabels(Group) = MergeLabels(Group) - 16' + vbCR +
  '      End If' + vbCR +
  '      Column = Groups(Group)' + vbCR +
  '      If SummaryAbove Then iFuncCount = -1 Else iFuncCount = FuncCount' + vbCR +
  '      If SummaryAbove Then cStartRow = cStartRow = FuncCount + 1 Else cStartRow = 1' + vbCR +
  '      Row = cStartRow + 1' + vbCR +
  '      cValue = Root.Cells(cStartRow, Column).Value' + vbCR +
  '      Rem' + vbCR +
  '      Do While Row <= Root.Rows.Count - iFuncCount' + vbCR +
  '        If (Root.Rows(Row).OutlineLevel <= Group * FuncCount + 1) Or (Row = Root.Rows.Count - iFuncCount) Then' + vbCR +
  '          If MergeLabels(Group) = 2 And (Not SummaryAbove) Then Row = Row + FuncCount' + vbCR +
  '          Set r = Sheet.Range(Root.Cells(cStartRow, Column), Root.Cells(Row - 1, Column))' + vbCR +
  '          Rem' + vbCR +
  '          If IsWithHeader Then' + vbCR +
  '            r.Parent.Rows(r.Row).Insert xlShiftDown' + vbCR +
  '            Set rh = Sheet.Range(Sheet.Cells(r.Row - 1, r.Column), Sheet.Cells(r.Row - 1, Root.Column + Root.Columns.Count - 1))' + vbCR +
  '            Set rg = Sheet.Range(Sheet.Cells(GroupRow.Row, rh.Column), Sheet.Cells(GroupRow.Row, Root.Column + Root.Columns.Count - 1))' + vbCR +
  '            rg.Copy' + vbCR +
  '            rh.PasteSpecial xlPasteFormats, xlPasteSpecialOperationAdd, False' + vbCR +
  '            Sheet.Cells(rh.Row, GroupCells(Group)).Value = r.Cells(1, 1).Value' + vbCR +
  '            If MergeLabels(Group) > 0 Then r.Merge' + vbCR +
  '            Rem Do previous group' + vbCR +
  '            For i = Group - 1 To 1 Step -1' + vbCR +
  '              Set rg = Sheet.Cells(rh.Row, Groups(i))' + vbCR +
  '              Set rh = Sheet.Cells(rh.Row + 1, Groups(i)).MergeArea' + vbCR +
  '              rh.Rows.Ungroup' + vbCR +
  '              rh.UnMerge' + vbCR +
  '              rh.Rows(1).Copy' + vbCR +
  '              rg.PasteSpecial xlPasteFormats' + vbCR +
  '              Set rh = Application.Union(rg, rh)' + vbCR +
  '              rh.Rows.Group' + vbCR +
  '              rh.Merge' + vbCR +
  '            Next' + vbCR +
  '          Rem' + vbCR +
  '          Else' + vbCR +
  '            r.Merge' + vbCR +
  '          End If' + vbCR +
  '          If (MergeLabels(Group) = 1) And IsWithHeader Then r.Value = ""' + vbCR +
  '          If (MergeLabels(Group) = 2) And IsWithHeader Then r.Value = ""' + vbCR +
  '          Rem' + vbCR +
  '          If MergeLabels(Group) <> 2 Then Row = Row + 1' + vbCR +
  '          Do While Root.Rows(Row).OutlineLevel <= Group * FuncCount + 1' + vbCR +
  '            Row = Row + 1' + vbCR +
  '            If Row >= Root.Rows.Count Then Exit Do' + vbCR +
  '          Loop' + vbCR +
  '          Rem' + vbCR +
  '          cStartRow = Row' + vbCR +
  '          cValue = Root.Cells(Row, Column).Value' + vbCR +
  '        Else' + vbCR +
  '          Row = Row + 1' + vbCR +
  '        End If' + vbCR +
  '      Loop' + vbCR +
  '      Rem' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCR +
  '  If IsUngroup Then' + vbCR +
  '    Root.Rows.Ungroup' + vbCR +
  '    Set Root = Sheet.Range(Sheet.Cells(Root.Row - StartWithHeaderCount, Root.Column), Root.Cells(Root.Rows.Count - 1, Root.Columns.Count))' + vbCR +
  '    Root.Rows.Group' + vbCR +
  '    Set Root = Sheet.Range(Sheet.Cells(Root.Row, Root.Column), Root.Cells(Root.Rows.Count + 1, Root.Columns.Count))' + vbCR +
  '    ThisWorkbook.Names(RootName).Delete' + vbCR +
  '    ThisWorkbook.Names.Add Name:=RootName, RefersTo:="=" & Chr(39) & Sheet.Name & Chr(39) & "!" & _' + vbCR +
  '      Root.Address(True, True, xlA1, False)' + vbCR +
  '  End If' + vbCR +
  'End Sub';

begin
  inherited;
  ALibraryCode := SubText;
  ASupportedRanges := rtCompleteRanges;
  ADeleteSpecialrow := saCompleteDelete;
end;

procedure TopGroupEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  LG, LT: TList;
  GroupCols, GroupCells, MergeLabels, Funcs, FuncCols,
  Outline, V, Disabled, PageBreaks: OLEVariant;
  i, j, GroupCount, FuncCount, Index, LevelCount: integer;
  Itm: TxlOptionItem;
  OutLineLevel: integer;
  IsWithHeader: boolean;
begin
  IsWithHeader := false;
  GroupCols := UnAssigned;
  FuncCols := UnAssigned;
  Funcs := UnAssigned;
  FuncCount := 0;
  OutLineLevel := 10;
  // Grouping
  LG := TList.Create;
  LT := TList.Create;
  try
    // GroupCols
    Item.List.LinkedItemsOfNames(Item, 'GROUP', [xoColumn], false, LG);
    // Presorting
    PreSorting(Item, Args);
    GroupCols := VarArrayCreate([1, 1], varVariant);
    GroupCols[1] := (Item.Obj as TxlAbstractCell).Column;
    GroupCount := 1;
    GroupCells := VarArrayCreate([1, 1], varVariant);
    GroupCells[1] := (Item.Obj as TxlAbstractCell).Column;
    MergeLabels := VarArrayCreate([1, 1], varVariant);
    MergeLabels[1] := 0;
    Disabled := VarArrayCreate([1, 1], varVariant);
    Disabled[1] := 0;
    if Item.ParamExists('DISABLESUBTOTALS') then
      Disabled[1] := 1;
    PageBreaks := VarArrayCreate([1, 1], varVariant);
    PageBreaks[1] := 0;
    if Item.ParamExists('PAGEBREAKS') then
      PageBreaks[1] := 1;
    Outline := VarArrayCreate([1, 1], varVariant);
    OutLine[1] := not Item.ParamExists('DISABLEOUTLINE');
    if Item.ParamExists('MERGELABELS3') then
      MergeLabels[1] := 4
    else
      if Item.ParamExists('MERGELABELS2') then
        MergeLabels[1] := 2
      else
        if Item.ParamExists('MERGELABELS') then
          MergeLabels[1] := 1;
    if Item.ParamExists('WITHHEADER') then begin
      if MergeLabels[1] = 0 then
        MergeLabels[1] := 1;
      MergeLabels[1] := MergeLabels[1] + 16;
      IsWithHeader := true;
    end;
    if Item.ParamExists('PLACETOCOLUMN') then
      GroupCells[1] := Item.ParamAsInteger('PLACETOCOLUMN') + 1;
    if Item.ParamExists('COLLAPSE') then
      OutLineLevel := 0;
    for i := 0 to LG.Count - 1 do begin
      Itm := TxlOptionItem(LG[i]);
      if Itm.Option is TopGroup then begin
        Inc(GroupCount);
        VarArrayReDim(GroupCols, GroupCount);
        GroupCols[GroupCount] := (Itm.Obj as TxlAbstractCell).Column;
        VarArrayReDim(GroupCells, GroupCount);
        GroupCells[GroupCount] := (Itm.Obj as TxlAbstractCell).Column;
        if Itm.ParamExists('PLACETOCOLUMN') then
          GroupCells[GroupCount] := Itm.ParamAsInteger('PLACETOCOLUMN') + 1;
        VarArrayReDim(MergeLabels, GroupCount);
        MergeLabels[GroupCount] := 0;
        if Itm.ParamExists('MERGELABELS3') then
          MergeLabels[GroupCount] := 4
        else
          if Itm.ParamExists('MERGELABELS2') then
            MergeLabels[GroupCount] := 2
          else
            if Itm.ParamExists('MERGELABELS') then
              MergeLabels[GroupCount] := 1;
        if Itm.ParamExists('WITHHEADER') then begin
          if MergeLabels[GroupCount] = 0 then
            MergeLabels[GroupCount] := 1;
          MergeLabels[GroupCount] := MergeLabels[GroupCount] + 16;
          IsWithHeader := true;
        end;
        VarArrayReDim(Outline, GroupCount);
        OutLine[GroupCount] := not Itm.ParamExists('DISABLEOUTLINE');
        if (Itm.ParamExists('COLLAPSE')) and (OutLineLevel = 10) then
          OutLineLevel := i + 1;
        VarArrayReDim(Disabled, GroupCount);
        Disabled[GroupCount] := Itm.ParamExists('DISABLESUBTOTALS');
        VarArrayReDim(PageBreaks, GroupCount);
        PageBreaks[GroupCount] := Itm.ParamExists('PAGEBREAKS');
      end
    end;
    if IsWithHeader then
      for i := 1 to GroupCount do
        if MergeLabels[i] >= 16 then
          Break
        else begin
          if MergeLabels[i] = 0 then
            MergeLabels[i] := 1;
          MergeLabels[i] := MergeLabels[i] + 16;
        end;
    // TotalCols
    Item.List.LinkedItemsOfNames(Item,
      'SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP',
      [xoColumn], false, LT);
    for i := 0 to LT.Count - 1 do begin
      Itm := TxlOptionItem(LT[i]);
      if FuncCount = 0 then begin
        FuncCount := 1;
        Funcs := VarArrayCreate([1, 1], varVariant);
        Funcs[1] := xlrTotalFunctionXLConsts[(Itm.Option as TopTotal).TotalFunc];
        FuncCols := VarArrayCreate([1, 1], varVariant);
        V := VarArrayCreate([1, 1], varVariant);
        V[1] := (Itm.Obj as TxlAbstractCell).Column;
        FuncCols[1] := V;
      end
      else begin
        Index := 0;
        for j := 1 to FuncCount do
          if Funcs[j] = xlrTotalFunctionXLConsts[(Itm.Option as TopTotal).TotalFunc] then begin
            Index := j;
            Break;
          end;
        if Index = 0 then begin
          Inc(FuncCount);
          VarArrayReDim(Funcs, FuncCount);
          Funcs[FuncCount] := xlrTotalFunctionXLConsts[(Itm.Option as TopTotal).TotalFunc];
          VarArrayReDim(FuncCols, FuncCount);
          V := VarArrayCreate([1, 1], varVariant);
          V[1] := (Itm.Obj as TxlAbstractCell).Column;
          FuncCols[FuncCount] := V;
        end
        else begin
          V := FuncCols[Index];
          VarArrayReDim(V, VarArrayHighBound(V, 1) + 1);
          V[VarArrayHighBound(V, 1)] := (Itm.Obj as TxlAbstractCell).Column;
          FuncCols[Index] := V;
        end;
      end;
    end;
    // Args rebuild
    VarArrayReDim(Args, 17);
    Args[5] := GroupCols;
    Args[6] := Funcs;
    Args[7] := FuncCols;
    Args[8] := Variant(xlSummaryBelow);
    if not IsWithHeader then
      if Item.List.ExistsOfObj((Item.Obj as TxlAbstractCell).DataSource, xoRange,
        [TopSummaryAbove]) then
        Args[8] := Variant(xlSummaryAbove);
    if OutlineLevel <> 10 then
      OutlineLevel := OutlineLevel + 2;
    Args[10] := GroupCells;
    Args[11] := MergeLabels;
    Args[12] := Outline;
    Args[13] := LT.Count > 0;
    Args[14] := Disabled;
    LevelCount := 1;
    for i := GroupCount downto 1 do begin
      if not Disabled[i] then
        Inc(LevelCount);
    end;
    Args[15] := LevelCount;
    Args[16] := Item.List.ExistsOfObj((Item.Obj as TxlAbstractCell).DataSource, xoRange,
      [TopDisableGrandTotal]);
    Args[17] := PageBreaks;
    if OutlineLevel = 10 then
      OutlineLevel := 0
    else
      if Args[16] then
        OutLineLevel := OutLineLevel - FuncCount;
    Args[9] := OutLineLevel;
    // Do macro
    if (FuncCount > 0) and (LevelCount > 1) then
      DoMacro(Item, 'xlrGroupEx2', Args)
    else
      DoMacro(Item, 'xlrGroupEx', Args);
  finally
    { ALTER: Disable all GROUP from RangeRoot }
    for i := 0 to LG.Count - 1 do
      TxlOptionItem(LG[i]).Enabled := false;
    LG.Free;
    for i := 0 to LT.Count - 1 do
      TxlOptionItem(LT[i]).Enabled := false;
    LT.Free;
  end;
end;

{ TopGroupWithHeader }

procedure TopGroupWithHeader.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
    'Function xlrGWHGroupRange(ARange As Range, GroupIndex As Long) As Long' + vbCR +
    '  Dim R As Range, SubRange As Range, TotalColumn As Range' + vbCR +
    '  Dim CurrentValue As Variant, CurrentRow As Long' + vbCR +
    '  Dim SubRangeStartRow As Range, SubRangeEndRow As Range' + vbCR +
    '  Dim i As Long, RowStep As Long, V As Variant' + vbCR +
    '  Dim InsertedRowCount As Long' + vbCR +
    '  InsertedRowCount = 0' + vbCR +
    '  RowStep = gwhRowCount - GroupIndex + 1' + vbCR +
    '  CurrentRow = 1' + vbCR +
    '  CurrentValue = ARange.Rows(CurrentRow)' + vbCR +
    '  CurrentRow = CurrentRow + RowStep' + vbCR +
    '  Set SubRangeStartRow = ARange.Rows(2)' + vbCR +
    '  While CurrentRow <= (ARange.Rows.Count + 1)' + vbCR +
    '    Set R = ARange.Rows(CurrentRow)' + vbCR +
    '    If xlrValuesEqual(CurrentValue, R.Value) And (CurrentRow <> (ARange.Rows.Count + 1)) Then' + vbCR +
    '      Rem Delete row' + vbCR +
    '      ARange.Rows(CurrentRow).Delete xlShiftUp' + vbCR +
    '      CurrentRow = CurrentRow - 1' + vbCR +
    '      InsertedRowCount = InsertedRowCount - 1' + vbCR +
    '    Else' + vbCR +
    '      CurrentValue = R.Value' + vbCR +
    '      Rem Do nested group' + vbCR +
    '      Set SubRangeEndRow = ARange.Rows(CurrentRow - GroupIndex)' + vbCR +
    '      Set SubRange = gwhSheet.Range(SubRangeStartRow, SubRangeEndRow)' + vbCR +
    '      If (GroupIndex < gwhGroupCount) And (gwhRowCount > gwhGroupCount) Then' + vbCR +
    '        CurrentRow = CurrentRow + xlrGWHGroupRange(SubRange, GroupIndex + 1)' + vbCR +
    '      End If' + vbCR +
    '      Rem Do totals' + vbCR +
    '      Set SubRangeEndRow = ARange.Rows(CurrentRow - 1)' + vbCR +
    '      Set R = gwhSheet.Range(SubRangeStartRow, SubRangeEndRow)' + vbCR +
    '      If gwhFuncCount > 0 Then' + vbCR +
    '        gwhTotalsRange.Copy' + vbCR +
    '        ARange.Rows(CurrentRow).Insert xlShiftDown' + vbCR +
    '        ARange.Rows(CurrentRow).PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True' + vbCR +
    '        For i = 1 To gwhFuncCount' + vbCR +
    '          V = gwhFuncs(i)' + vbCR +
    '          Set TotalColumn = R.Columns(V(1))' + vbCR +
    '          ARange.Rows(CurrentRow).Cells(1, V(1)).Formula = "=SubTotal(" & V(2) & ", " & _' + vbCR +
    '            TotalColumn.Address(False, False) & ")"' + vbCR +
    '        Next' + vbCR +
    '        InsertedRowCount = InsertedRowCount + 1' + vbCR +
    '        CurrentRow = CurrentRow + 1' + vbCR +
    '      End If' + vbCR +
    '      Set SubRangeStartRow = ARange.Rows(CurrentRow + 1)' + vbCR +
    '    End If' + vbCR +
    '    CurrentRow = CurrentRow + RowStep' + vbCR +
    '  Wend' + vbCR +
    '  Rem get result' + vbCR +
    '  xlrGWHGroupRange = InsertedRowCount' + vbCR +
    'End Function' + vbCR +

    'Public Sub xlrRangeGroupWithHeader(Args As Variant)' + vbCR +
    '  Set gwhRoot = Range(Args(1))' + vbCR +
    '  Set gwhSheet = gwhRoot.Parent' + vbCR +
    '  Set gwhTotalsRange = gwhRoot.Rows(gwhRoot.Rows.Count)' + vbCR +
    '  gwhColumnCount = gwhRoot.Columns.Count' + vbCR +
    '  gwhFuncs = Args(5)' + vbCR +
    '  gwhFuncCount = Args(6)' + vbCR +
    '  gwhRowCount = Args(7)' + vbCR +
    '  gwhGroupCount = Args(8)' + vbCR +
    '  If (gwhRoot.Rows.Count > gwhRowCount + 1) And (gwhGroupCount > 0) Then' + vbCR +
    '    xlrGWHGroupRange gwhRoot, 1' + vbCR +
    '    gwhRoot.Rows(gwhRoot.Rows.Count).Delete xlShiftUp' + vbCR +
    '  End If' + vbCR +
    'End Sub' + vbCR +

    'Function xlrValuesEqual(Values As Variant, RangeValues As Variant) As Boolean' + vbCR +
    '  Dim c As Long, i As Long, Res As Boolean' + vbCR +
    '  Res = True' + vbCR +
    '  c = UBound(Values, 2)' + vbCR +
    '  For i = 2 To c' + vbCR +
    '    If Values(1, i) <> RangeValues(1, i) Then' + vbCR +
    '      Res = False' + vbCR +
    '      Exit For' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    '  xlrValuesEqual = Res' + vbCR +
    'End Function';
begin
  AName := 'GROUPWITHHEADER';
  AxlObjects := [xoRange];
  APriorityArr[xoRange] := opHighest;
  ALinkedOptions[xoRange] :=
    'GROUP;SORT;ASC;DESC;SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP';
  ALibraryCode := SubText;
  ADeleteSpecialRow := saCompleteDelete;
  ASupportedRanges := [rtRange] + [rtRangeArbitrary];
end;

procedure TopGroupWithHeader.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  FuncCols, V: OLEVariant;
  i, FuncCount: integer;
  Itm: TxlOptionItem;
begin
  if (Item.Obj as TxlExcelDataSource).RowCount > 1 then begin
    FLinkedList := TList.Create;
    FuncCols := UnAssigned;
    FuncCount := 0;
    // Get linked option items
    Item.List.LinkedItemsOfNames(Item,
      'SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP',
      [xoColumn], false, FLinkedList);
    for i := 0 to FLinkedList.Count - 1 do begin
      Itm := TxlOptionItem(FLinkedList[i]);
      if FuncCount = 0 then begin
        FuncCount := 1;
        FuncCols := VarArrayCreate([1, 1], varVariant);
      end
      else begin
        Inc(FuncCount);
        VarArrayReDim(FuncCols, FuncCount);
      end;
      V := VarArrayCreate([1, 2], varVariant);
      V[1] := (Itm.Obj as TxlAbstractCell).Column;
      V[2] := xlrSubTotalFunctionIndex[(Itm.Option as TopTotal).TotalFunc];
      FuncCols[FuncCount] := V;
    end;
    // Add args
    VarArrayReDim(Args, 8);
    Args[5] := FuncCols;
    Args[6] := FuncCount;
    Args[7] := (Item.Obj as TxlExcelDataSource).RowCount;
    Args[8] := 1;
    if Item.ParamExists('GROUPCOUNT') then
      Args[8] := Item.ParamAsInteger('GROUPCOUNT');
    // Add GROUP for disable
    Item.List.LinkedItemsOfNames(Item,
      'GROUP;SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP',
      [xoColumn], false, FLinkedList);
  end;
end;

procedure TopGroupWithHeader.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  if (Item.Obj as TxlExcelDataSource).RowCount > 1 then
    DoMacro(Item, xlrModuleName + '.xlrRangeGroupWithHeader', Args);
end;

procedure TopGroupWithHeader.DoneArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  i: integer;
begin
  if (Item.Obj as TxlExcelDataSource).RowCount > 1 then begin
    for i := 0 to FLinkedList.Count - 1 do
      TxlOptionItem(FLinkedList[i]).Enabled := false;
    FLinkedList.Free;
  end;
end;

function TopGroupWithHeader.GetModuleLevelCode: string;
const
  DeclareText =
    'Rem GroupWithHeader public variables' + vbCR +
    'Dim gwhGroupCount As Long, gwhRowCount As Long' + vbCR +
    'Dim gwhSheet As Worksheet' + vbCR +
    'Dim gwhRoot As Range, gwhTotalsRange As Range, gwhColumnCount As Long' + vbCR +
    'Dim gwhFuncs As Variant, gwhFuncCount As Long';
begin
  Result := DeclareText;
end;

{ TopDeleteColumn }

procedure TopDeleteColumn.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'DELETECOLUMN';
  AxlObjects := [xoColumn];
  APriorityArr[xoColumn] := opCriticalLowest;
  ASupportedRanges := rtRoots + [rtRangeArbitrary];
end;

procedure TopDeleteColumn.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  Dsr: TxlExcelDataSource;
  IXLApp: IxlApplication;
  ISheet: IxlWorksheet;
  IRange: IxlRange;
begin
  Dsr := (Item.Obj as TxlAbstractCell).DataSource as TxlExcelDataSource;
  IXLApp := (Item.List.Owner as TxlExcelReport).IXLSApp;
  {$IFNDEF XLR_BCB}
  IRange := Dsr.IWorksheet.Range[Dsr.Range, EmptyParam] as IxlRange;
  ISheet := IRange.Parent as IxlWorksheet;
  {$ELSE}
  IRange := Dsr.IWorksheet.Range[Dsr.Range, EmptyParam];
  ISheet := IRange.Parent;
  {$ENDIF}
  IRange := ISheet.Range[IRange.Cells.Item[IRange.Row + IRange.Rows.Count - 1, (Item.Obj as TxlAbstractCell).Column],
    ISheet.Cells.Item[IRange.Row - 1, (Item.Obj as TxlAbstractCell).Column]];
  IRange.Delete(TOLEEnum(xlShiftToLeft));
end;

{ TopOutline }

procedure TopOutline.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrRangeOutline (Args As Variant)' + vbCR +
  '  Dim Sheet As Worksheet, Root As Range, Ranges As Variant, Rows As Variant, Dst As Range' + vbCR +
  '  Dim MaxLevel As Long, Level As Variant' + vbCR +
  '  Dim DSCount As Long, i As Long, j As Long, r As Long, RangeCount As Long' + vbCR +
  '  Dim Indx As Long, StartRow As Long, EndRow As Long, ColumnCount As Long' + vbCR +
  '' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  Sheet.UsedRange.ClearOutline' + vbCR +
  '  Sheet.Outline.SummaryRow = Args(5)' + vbCR +
  '  ColumnCount = Root.Columns.Count' + vbCR +
  '  Ranges = Args(3)' + vbCR +
  '  MaxLevel = Ranges(1)' + vbCR +
  '  For i = 3 To MaxLevel + 1' + vbCR +
  '    Level = Ranges(i)' + vbCR +
  '    DSCount = Level(1)' + vbCR +
  '    For j = 2 To DSCount + 1' + vbCR +
  '      Rows = Level(j)' + vbCR +
  '      RangeCount = UBound(Rows) \ 2' + vbCR +
  '      For r = 1 To RangeCount' + vbCR +
  '        Indx = r * 2' + vbCR +
  '        StartRow = Rows(Indx - 1)' + vbCR +
  '        EndRow = Rows(Indx)' + vbCR +
  '        Set Dst = Sheet.Range(Root.Cells(StartRow, 1), Root.Cells(EndRow, ColumnCount))' + vbCR +
  '        Dst.Rows.Group' + vbCR +
  '      Next' + vbCR +
  '    Next' + vbCR +
  '  Next' + vbCR +
  '  If Args(6) <> 0 Then' + vbCR +
  '    Sheet.Outline.ShowLevels(Args(6))' + vbCR +
  '  End If' + vbCR +
  'End Sub';
begin
  AName := 'OUTLINE';
  AxlObjects := [xoRange];
  APriorityArr[xoColumn] := opLowest;
  ASupportedRanges := [rtRangeRoot] + [rtRangeArbitrary];
  ALibraryCode := SubText;
end;

procedure TopOutline.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  VarArrayReDim(Args, 6);
  Args[5] := Variant(xlSummaryBelow);
  Args[6] := 0;
  if Item.List.ExistsOfObj(Item.Obj, xoRange, [TopSummaryAbove]) then
    Args[5] := Variant(xlSummaryAbove);
  if Item.Params.Count > 0 then
    if Item.Params.IndexOfName('COLLAPSELEVEL') <> -1 then
      Args[6] := StrToInt(Item.Params.Values['COLLAPSELEVEL']);
end;

procedure TopOutline.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  if not Item.List.ExistsOfObj(Item.Obj, xoColumn, [TopGroup, TopGroupEx, TopGroupWithHeader]) then
    DoMacro(Item, 'xlrRangeOutline', Args);
end;

{ TopChart }

procedure TopChart.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);

const
  SubText =
  'Public Sub xlrDoChart(Args As Variant)' + vbCR +
  '  Dim Root As Range, Sheet As Worksheet, Ch As Chart' + vbCR +
  '  Dim sr As Series, i As Long' + vbCR +
  '  Dim s As String, Addr As String, R As Range, IsValid As Boolean' + vbCR +
  '  Rem Get chart' + vbCR +
  '  s = Trim(Args(5))' + vbCR +
  '  If InStr(s, "!") > 0 Then' + vbCR +
  '    Set Sheet = Worksheets(Mid(s, 1, InStr(s, "!") - 1))' + vbCR +
  '    Set Ch = Sheet.ChartObjects(Mid(s, InStr(s, "!") + 1, Len(s) - InStr(s, "!"))).Chart' + vbCR +
  '  Else' + vbCR +
  '    Set Ch = ThisWorkbook.Charts(s)' + vbCR +
  '  End If' + vbCR +
  '  Rem' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  Rem' + vbCR +
  '  For i = 1 To Ch.SeriesCollection.Count' + vbCR +
  '    Set sr = Ch.SeriesCollection(i)' + vbCR +
  '    Rem Series.Name' + vbCR +
  '    If xlrSERIESFormulaElementType(Ch, i, 1) = "Range" Then' + vbCR +
  '      Set R = Range(xlrSERIESFormulaElement(Ch, i, 1))' + vbCR +
  '      IsValid = False' + vbCR +
  '      Set R = xlrDoChart_ValidAddr(Root, R.Address(True, True, xlR1C1, True), IsValid)' + vbCR +
  '      If IsValid Then' + vbCR +
  '        sr.Name = "=" & R.Address(True, True, xlR1C1, True)' + vbCR +
  '      End If' + vbCR +
  '    End If' + vbCR +
  '    Rem Series.XValues' + vbCR +
  '    If xlrSERIESFormulaElementType(Ch, i, 2) = "Range" Then' + vbCR +
  '      Set R = Range(xlrSERIESFormulaElement(Ch, i, 2))' + vbCR +
  '      IsValid = False' + vbCR +
  '      Set R = xlrDoChart_ValidAddr(Root, R.Address(True, True, xlR1C1, True), IsValid)' + vbCR +
  '      If IsValid Then' + vbCR +
  '        sr.XValues = "=" & R.Address(True, True, xlR1C1, True)' + vbCR +
  '      End If' + vbCR +
  '    End If' + vbCR +
  '    Rem Series.Values' + vbCR +
  '    If xlrSERIESFormulaElementType(Ch, i, 3) = "Range" Then' + vbCR +
  '      Set R = Range(xlrSERIESFormulaElement(Ch, i, 3))' + vbCR +
  '      IsValid = False' + vbCR +
  '      Set R = xlrDoChart_ValidAddr(Root, R.Address(True, True, xlR1C1, True), IsValid)' + vbCR +
  '      If IsValid Then' + vbCR +
  '        sr.Values = "=" & R.Address(True, True, xlR1C1, True)' + vbCR +
  '      End If' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCR +
  '  If Args(6) Then Root.Rows(Root.Rows.Count).Delete xlShiftUp' + vbCR +
  'End Sub' + vbCR +
  '' + vbCR +
  'Function xlrDoChart_ValidAddr(Root As Range, Addr As String, ByRef IsValid As Boolean) As Range' + vbCR +
  '  Dim Column As Long' + vbCR +
  '  Set xlrDoChart_ValidAddr = Nothing' + vbCR +
  '  IsValid = False' + vbCR +
  '  On Error Resume Next' + vbCR +
  '  Application.Goto (Addr)' + vbCR +
  '  If (Root.Parent.Name = Selection.Parent.Name) And ((Root.Row + Root.Rows.Count - 1) = Selection.Row) Then' + vbCR +
  '    Column = Selection.Column - Root.Column + 1' + vbCR +
  '    Set xlrDoChart_ValidAddr = Root.Parent.Range(Root.Cells(1, Column), Root.Cells(Root.Rows.Count - 1, Column))' + vbCR +
  '    IsValid = True' + vbCR +
  '  End If' + vbCR +
  'End Function' + vbCR +
  '' + vbCR +
  'Private Function xlrSERIESFormulaElementType(ChartObj, SeriesNum, Element) As String' + vbCR +
  '    Rem Returns a string that describes the element of a charts SERIES formula' + vbCR +
  '    Rem This function essentially parses and analyzes a SERIES formula' + vbCR +
  '' + vbCR +
  '    Rem Element 1: Series Name. Returns "Range" , "Empty", or "String"' + vbCR +
  '    Rem Element 2: XValues. Returns "Range", "Empty", or "Array"' + vbCR +
  '    Rem Element 3: Values. Returns "Range" or "Array"' + vbCR +
  '    Rem Element 4: PlotOrder. Always returns "Integer"' + vbCR +
  '' + vbCR +
  '    Dim SeriesFormula As String' + vbCR +
  '    Dim FirstComma As Integer, SecondComma As Integer, LastComma As Integer' + vbCR +
  '    Dim FirstParen As Integer, SecondParen As Integer' + vbCR +
  '    Dim FirstBracket As Integer, SecondBracket As Integer' + vbCR +
  '    Dim StartY As Integer' + vbCR +
  '    Dim SeriesName, XValues, Values, PlotOrder As Integer' + vbCR +
  '' + vbCR +
  '    Rem Exit if Surface chart (surface chrarts do not have SERIES formulas)' + vbCR +
  '    If ChartObj.ChartType >= 83 And ChartObj.ChartType <= 86 Then' + vbCR +
  '        xlrSERIESFormulaElementType = "ERROR - SURFACE CHART"' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Exit if nonexistent series is specified' + vbCR +
  '    If SeriesNum > ChartObj.SeriesCollection.Count Or SeriesNum < 1 Then' + vbCR +
  '        xlrSERIESFormulaElementType = "ERROR - BAD SERIES NUMBER"' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Exit if element is > 4' + vbCR +
  '    If Element > 4 Or Element < 1 Then' + vbCR +
  '        xlrSERIESFormulaElementType = "ERROR - BAD ELEMENT NUMBER"' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the SERIES formula' + vbCR +
  '    SeriesFormula = ChartObj.SeriesCollection(SeriesNum).Formula' + vbCR +
  '' + vbCR +
  '    Rem Get the First Element (Series Name)' + vbCR +
  '    FirstParen = InStr(1, SeriesFormula, "(")' + vbCR +
  '    FirstComma = InStr(1, SeriesFormula, ",")' + vbCR +
  '    SeriesName = Mid(SeriesFormula, FirstParen + 1, FirstComma - FirstParen - 1)' + vbCR +
  '    If Element = 1 Then' + vbCR +
  '        If xlrIsRange(SeriesName) Then' + vbCR +
  '            xlrSERIESFormulaElementType = "Range"' + vbCR +
  '        Else' + vbCR +
  '            If SeriesName = "" Then' + vbCR +
  '                xlrSERIESFormulaElementType = "Empty"' + vbCR +
  '            Else' + vbCR +
  '                If TypeName(SeriesName) = "String" Then' + vbCR +
  '                    xlrSERIESFormulaElementType = "String"' + vbCR +
  '                End If' + vbCR +
  '            End If' + vbCR +
  '        End If' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the Second Element (X Range)' + vbCR +
  '    If Mid(SeriesFormula, FirstComma + 1, 1) = "(" Then' + vbCR +
  '    Rem     Multiple ranges' + vbCR +
  '        FirstParen = FirstComma + 2' + vbCR +
  '        SecondParen = InStr(FirstParen, SeriesFormula, ")")' + vbCR +
  '        XValues = Mid(SeriesFormula, FirstParen, SecondParen - FirstParen)' + vbCR +
  '        StartY = SecondParen + 1' + vbCR +
  '    Else' + vbCR +
  '        If Mid(SeriesFormula, FirstComma + 1, 1) = "{" Then' + vbCR +
  '    Rem         Literal Array' + vbCR +
  '            FirstBracket = FirstComma + 1' + vbCR +
  '            SecondBracket = InStr(FirstBracket, SeriesFormula, "}")' + vbCR +
  '            XValues = Mid(SeriesFormula, FirstBracket, SecondBracket - FirstBracket + 1)' + vbCR +
  '            StartY = SecondBracket + 1' + vbCR +
  '        Else' + vbCR +
  '    Rem        A single range' + vbCR +
  '            SecondComma = InStr(FirstComma + 1, SeriesFormula, ",")' + vbCR +
  '            XValues = Mid(SeriesFormula, FirstComma + 1, SecondComma - FirstComma - 1)' + vbCR +
  '            StartY = SecondComma' + vbCR +
  '        End If' + vbCR +
  '    End If' + vbCR +
  '    If Element = 2 Then' + vbCR +
  '        If xlrIsRange(XValues) Then' + vbCR +
  '            xlrSERIESFormulaElementType = "Range"' + vbCR +
  '        Else' + vbCR +
  '            If XValues = "" Then' + vbCR +
  '                xlrSERIESFormulaElementType = "Empty"' + vbCR +
  '            Else' + vbCR +
  '                xlrSERIESFormulaElementType = "Array"' + vbCR +
  '            End If' + vbCR +
  '        End If' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the Third Element (Y Range)' + vbCR +
  '    If Mid(SeriesFormula, StartY + 1, 1) = "(" Then' + vbCR +
  '    Rem     Multiple ranges' + vbCR +
  '        FirstParen = StartY + 1' + vbCR +
  '        SecondParen = InStr(FirstParen, SeriesFormula, ")")' + vbCR +
  '        Values = Mid(SeriesFormula, FirstParen + 1, SecondParen - FirstParen - 1)' + vbCR +
  '        LastComma = SecondParen + 1' + vbCR +
  '    Else' + vbCR +
  '        If Mid(SeriesFormula, StartY + 1, 1) = "{" Then' + vbCR +
  '    Rem         Literal Array' + vbCR +
  '            FirstBracket = StartY + 1' + vbCR +
  '            SecondBracket = InStr(FirstBracket, SeriesFormula, "}")' + vbCR +
  '            Values = Mid(SeriesFormula, FirstBracket, SecondBracket - FirstBracket + 1)' + vbCR +
  '            LastComma = SecondBracket + 1' + vbCR +
  '        Else' + vbCR +
  '    Rem        A single range' + vbCR +
  '            FirstComma = StartY' + vbCR +
  '            SecondComma = InStr(FirstComma + 1, SeriesFormula, ",")' + vbCR +
  '            Values = Mid(SeriesFormula, FirstComma + 1, SecondComma - FirstComma - 1)' + vbCR +
  '            LastComma = SecondComma' + vbCR +
  '        End If' + vbCR +
  '    End If' + vbCR +
  '    If Element = 3 Then' + vbCR +
  '        If xlrIsRange(Values) Then' + vbCR +
  '            xlrSERIESFormulaElementType = "Range"' + vbCR +
  '        Else' + vbCR +
  '            xlrSERIESFormulaElementType = "Array"' + vbCR +
  '        End If' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the Fourth Element (Plot Order)' + vbCR +
  '    PlotOrder = Mid(SeriesFormula, LastComma + 1, Len(SeriesFormula) - LastComma - 1)' + vbCR +
  '    If Element = 4 Then' + vbCR +
  '        xlrSERIESFormulaElementType = "Integer"' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  'End Function' + vbCR +
  '' + vbCR +
  '' + vbCR +
  'Private Function xlrSERIESFormulaElement(ChartObj, SeriesNum, Element) As String' + vbCR +
  '    Rem Returns one of four elements in a charts SERIES formula (as a string)' + vbCR +
  '    Rem This function essentially parses and analyzes a SERIES formula' + vbCR +
  '' + vbCR +
  '    Rem Element 1: Series Name. Can be a range reference, a literal value, or nothing' + vbCR +
  '    Rem Element 2: XValues. Can be a range reference (including a non-contiguous range), a literal array, or nothing' + vbCR +
  '    Rem Element 3: Values. Can be a range reference (including a non-contiguous range), or a literal array' + vbCR +
  '    Rem Element 4: PlotOrder. Must be an integer' + vbCR +
  '' + vbCR +
  '    Dim SeriesFormula As String' + vbCR +
  '    Dim FirstComma As Integer, SecondComma As Integer, LastComma As Integer' + vbCR +
  '    Dim FirstParen As Integer, SecondParen As Integer' + vbCR +
  '    Dim FirstBracket As Integer, SecondBracket As Integer' + vbCR +
  '    Dim StartY As Integer' + vbCR +
  '    Dim SeriesName, XValues, Values, PlotOrder As Integer' + vbCR +
  '' + vbCR +
  '    Rem Exit if Surface chart (surface chrarts do not have SERIES formulas)' + vbCR +
  '    If ChartObj.ChartType >= 83 And ChartObj.ChartType <= 86 Then' + vbCR +
  '        xlrSERIESFormulaElement = "ERROR - SURFACE CHART"' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Exit if nonexistent series is specified' + vbCR +
  '    If SeriesNum > ChartObj.SeriesCollection.Count Or SeriesNum < 1 Then' + vbCR +
  '        xlrSERIESFormulaElement = "ERROR - BAD SERIES NUMBER"' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Exit if element is > 4' + vbCR +
  '    If Element > 4 Then' + vbCR +
  '        xlrSERIESFormulaElement = "ERROR - BAD ELEMENT NUMBER"' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the SERIES formula' + vbCR +
  '    SeriesFormula = ChartObj.SeriesCollection(SeriesNum).Formula' + vbCR +
  '' + vbCR +
  '    Rem Get the First Element (Series Name)' + vbCR +
  '    FirstParen = InStr(1, SeriesFormula, "(")' + vbCR +
  '    FirstComma = InStr(1, SeriesFormula, ",")' + vbCR +
  '    SeriesName = Mid(SeriesFormula, FirstParen + 1, FirstComma - FirstParen - 1)' + vbCR +
  '    If Element = 1 Then' + vbCR +
  '        xlrSERIESFormulaElement = SeriesName' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the Second Element (X Range)' + vbCR +
  '    If Mid(SeriesFormula, FirstComma + 1, 1) = "(" Then' + vbCR +
  '    Rem     Multiple ranges' + vbCR +
  '        FirstParen = FirstComma + 2' + vbCR +
  '        SecondParen = InStr(FirstParen, SeriesFormula, ")")' + vbCR +
  '        XValues = Mid(SeriesFormula, FirstParen, SecondParen - FirstParen)' + vbCR +
  '        StartY = SecondParen + 1' + vbCR +
  '    Else' + vbCR +
  '        If Mid(SeriesFormula, FirstComma + 1, 1) = "{" Then' + vbCR +
  '    Rem         Literal Array' + vbCR +
  '            FirstBracket = FirstComma + 1' + vbCR +
  '            SecondBracket = InStr(FirstBracket, SeriesFormula, "}")' + vbCR +
  '            XValues = Mid(SeriesFormula, FirstBracket, SecondBracket - FirstBracket + 1)' + vbCR +
  '            StartY = SecondBracket + 1' + vbCR +
  '        Else' + vbCR +
  '    Rem        A single range' + vbCR +
  '            SecondComma = InStr(FirstComma + 1, SeriesFormula, ",")' + vbCR +
  '            XValues = Mid(SeriesFormula, FirstComma + 1, SecondComma - FirstComma - 1)' + vbCR +
  '            StartY = SecondComma' + vbCR +
  '        End If' + vbCR +
  '    End If' + vbCR +
  '    If Element = 2 Then' + vbCR +
  '        xlrSERIESFormulaElement = XValues' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the Third Element (Y Range)' + vbCR +
  '    If Mid(SeriesFormula, StartY + 1, 1) = "(" Then' + vbCR +
  '    Rem     Multiple ranges' + vbCR +
  '        FirstParen = StartY + 1' + vbCR +
  '        SecondParen = InStr(FirstParen, SeriesFormula, ")")' + vbCR +
  '        Values = Mid(SeriesFormula, FirstParen + 1, SecondParen - FirstParen - 1)' + vbCR +
  '        LastComma = SecondParen + 1' + vbCR +
  '    Else' + vbCR +
  '        If Mid(SeriesFormula, StartY + 1, 1) = "{" Then' + vbCR +
  '    Rem         Literal Array' + vbCR +
  '            FirstBracket = StartY + 1' + vbCR +
  '            SecondBracket = InStr(FirstBracket, SeriesFormula, "}")' + vbCR +
  '            Values = Mid(SeriesFormula, FirstBracket, SecondBracket - FirstBracket + 1)' + vbCR +
  '            LastComma = SecondBracket + 1' + vbCR +
  '        Else' + vbCR +
  '    Rem        A single range' + vbCR +
  '            FirstComma = StartY' + vbCR +
  '            SecondComma = InStr(FirstComma + 1, SeriesFormula, ",")' + vbCR +
  '            Values = Mid(SeriesFormula, FirstComma + 1, SecondComma - FirstComma - 1)' + vbCR +
  '            LastComma = SecondComma' + vbCR +
  '        End If' + vbCR +
  '    End If' + vbCR +
  '    If Element = 3 Then' + vbCR +
  '        xlrSERIESFormulaElement = Values' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Get the Fourth Element (Plot Order)' + vbCR +
  '    PlotOrder = Mid(SeriesFormula, LastComma + 1, Len(SeriesFormula) - LastComma - 1)' + vbCR +
  '    If Element = 4 Then' + vbCR +
  '        xlrSERIESFormulaElement = PlotOrder' + vbCR +
  '        Exit Function' + vbCR +
  '    End If' + vbCR +
  'End Function' + vbCR +
  '' + vbCR +
  'Private Function xlrIsRange(ref) As Boolean' + vbCR +
  '    Rem Returns True if ref is a Range' + vbCR +
  '    Dim x As Range' + vbCR +
  '    On Error Resume Next' + vbCR +
  '    Set x = Range(ref)' + vbCR +
  '    If Err = 0 Then xlrIsRange = True Else xlrIsRange = False' + vbCR +
  'End Function' + vbCR;
begin
  AName := 'CHART';
  AxlObjects := [xoRange];
  APriorityArr[xoRange] := opHighest - 5;
  ALinkedOptions[xoColumn] := '';
  ASupportedRanges := [rtRange];
  ADeleteSpecialRow := saCompleteDelete;
  ALibraryCode := SubText;
end;

procedure TopChart.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  LT: TList;
begin
  // Args list:
  //    5 - ChartName                    string
  //    6 - Is delete special row        boolean
  //
  if Item.ParamExists('NAME') then begin
    VarArrayReDim(Args, 6);
    Args[5] := Item.ParamAsString('NAME');
    LT := TList.Create;
    try
      Item.List.LinkedItemsOfNames(Item,
        'PIVOT;GROUP;SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP',
        [xoColumn], false, LT);
      Args[6] := LT.Count = 0;
      DoMacro(Item, 'xlrDoChart', Args);
    finally
      LT.Free;
    end;
  end;
end;

{ TopSmartGroup }

procedure TopSmartGroup.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText: string =
    'Public Sub xlrGroupEx3(Args As Variant)' + vbCR +
    '  Dim Sheet As Worksheet' + vbCR +
    '  Dim Ranges As Variant, Root As Range, HeaderRow As Range, GroupRow As Range, r As Range, r1 As Range, r2 As Range' + vbCR +
    '  Dim GroupsCount As Long' + vbCR +
    '  Dim Groups As Variant, Labels As Variant' + vbCR +
    '  Dim TotalsCount As Long' + vbCR +
    '  Dim TotalList As Variant, TotalColumns As Variant' + vbCR +
    '  Dim OutlineLevel As Long, PostProcessing As Boolean' + vbCR +
    '  Dim i As Long, j As Long, l As Long' + vbCR +
    '  Dim Group As Variant, GroupBy As Long' + vbCR +
    '  Dim CurrentValue As Variant, StartRows, b As Boolean, LastRow as Long' + vbCR +
    '  Rem' + vbCR +
    '  Application.DisplayAlerts = False' + vbCR +
    '  Rem InitRanges' + vbCR +
    '  Call xlrGetRanges(Args, Ranges)' + vbCR +
    '  Set Root = Range(Args(1))' + vbCR +
    '  Set HeaderRow = Root.Rows(0)' + vbCR +
    '  Set GroupRow = Root.Rows(Root.Rows.Count)' + vbCR +
    '  Set Sheet = Root.Parent' + vbCR +
    '  Rem InitArgs' + vbCR +
    '  Groups = Args(5)' + vbCR +
    '  GroupsCount = UBound(Groups)' + vbCR +
    '  Labels = Args(6)' + vbCR +
    '  OutlineLevel = Args(7)' + vbCR +
    '  PostProcessing = Args(8)' + vbCR +
    '  Rem DoGroups' + vbCR +
    '  l = 1' + vbCR +
    '  For i = 1 To GroupsCount' + vbCR +
    '    Group = Groups(i)' + vbCR +
    '    GroupBy = Group(1)' + vbCR +
    '    TotalsCount = Group(2)' + vbCR +
    '    TotalList = Group(3)' + vbCR +
    '    TotalColumns = Group(4)' + vbCR +
    '    For j = 1 To TotalsCount' + vbCR +
    '      Set r = Sheet.Range(HeaderRow.Rows(1), Root.Rows(Root.Rows.Count - 1))' + vbCR +
    '      r.Subtotal GroupBy, TotalList(j), TotalColumns(j), False, (Groups(i)(6) And 64) = 64, xlSummaryBelow' + vbCR +
    '      l = l + 1' + vbCR +
    '    Next' + vbCR +
    '  Next' + vbCR +
    '  Rem DoFormat' + vbCR +
    '  If l > 7 Then l = 7' + vbCR +
    '  Set Root = Sheet.Range(HeaderRow.Rows(2), Root.Rows(Root.Rows.Count - 1))' + vbCR +
    '  Sheet.Outline.ShowLevels l' + vbCR +
    '  Set Root = Root.SpecialCells(xlCellTypeVisible)' + vbCR +
    // 1.01 begin
    '  Set r = GroupRow.SpecialCells(xlCellTypeVisible)' + vbCR +
    '  if r.Address = GroupRow.Address Then' + vbCR +
    '    GroupRow.Copy' + vbCR +
    '    Root.Rows.PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True, False' + vbCR +
    '    Root.Rows.PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone, False, False' + vbCR +
    // 1.01 end
    '  Else' + vbCR +
    '  LastRow = -1' + vbCR +
    '  For Each r In Root.Areas' + vbCR +
    '    GroupRow.Copy' + vbCR +
    '    If LastRow < r.Row Then' + vbCR +
    '      LastRow = r.Row' + vbCR +
    '      For i = 1 to r.Rows.Count' + vbCR +
    '        Set r2 = r1.Rows(r.Row - r1.Row + i)' + vbCR +
    '        r2.PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone, False, False' + vbCR +
    '        r2.PasteSpecial xlPasteFormulas, xlPasteSpecialOperationNone, True, False' + vbCR +
    '        LastRow = LastRow + 1' + vbCR +
    '      Next' + vbCR +
    '    End If' + vbCR +
    '  Next' + vbCR +
    '  End If' + vbCR +
    //
    '  If l < 7 Then l = l + 1' + vbCR +
    '  Sheet.Outline.ShowLevels l' + vbCR +
    '  Set Root = Sheet.Range(Args(1))' + vbCR +
    '  Rem Do Parameters' + vbCR +
    '  If PostProcessing Then' + vbCR +
    '    ReDim StartRows(GroupsCount)' + vbCR +
    '    For i = 1 To GroupsCount' + vbCR +
    '      StartRows(i) = 1' + vbCR +
    '    Next' + vbCR +
    '    For i = 1 To Root.Rows.Count - 1' + vbCR +
    '      For j = GroupsCount To 1 Step -1' + vbCR +
    '        Group = Groups(j)' + vbCR +
    '        TotalsCount = Group(2)' + vbCR +
    '        If StartRows(j) = -1 Then' + vbCR +
    '          If Root.Rows(i).OutlineLevel > Group(5) Then StartRows(j) = i' + vbCR +
    '        Else' + vbCR +
    '          If Root.Rows(i).Summary Then' + vbCR +
    '            Rem MergeLabels' + vbCR +
    '            b = False' + vbCR +
    '            If ((Group(6) And 1) = 1) Then' + vbCR +
    '                If Root.Rows(i).OutlineLevel = Group(5) Then' + vbCR +
    '                  Set r = Sheet.Range(Root.Cells(StartRows(j), Group(1)), Root.Cells(i - 1, Group(1)))' + vbCR +
    '                  b = True' + vbCR +
    '                End If' + vbCR +
    '            Rem MergeLabels2' + vbCR +
    '            ElseIf ((Group(6) And 2) = 2) Then' + vbCR +
    '                If Root.Rows(i).OutlineLevel = Group(5) - TotalsCount + 1 Then' + vbCR +
    '                  Set r = Sheet.Range(Root.Cells(StartRows(j), Group(1)), Root.Cells(i, Group(1)))' + vbCR +
    '                  b = True' + vbCR +
    '                End If' + vbCR +
    '            End If' + vbCR +
    '            If b Then' + vbCR +
    '                CurrentValue = r.Cells(1, 1).Value' + vbCR +
    '                r.Merge' + vbCR +
    '                r.Value = CurrentValue' + vbCR +
    '                Rem Disable Outline' + vbCR +
    '                Rem If (Group(6) And 8) = 8 Then r.Rows.Ungroup' + vbCR +
    '                Rem' + vbCR +
    '                Rem Begin DisableSubtotals' + vbCR +
    '                If (Group(6) And 16) = 16 Then' + vbCR +
    '                    Rem' + vbCR +
    '                    r.Rows.Ungroup' + vbCR +
    '                    Sheet.Rows(Root.Rows(i).Row).Delete xlShiftUp' + vbCR +
    '                    i = i - 1' + vbCR +
    '                End If' + vbCR +
    '                StartRows(j) = -1' + vbCR +
    '            End If' + vbCR +
    '          End If' + vbCR +
    '        End If' + vbCR +
    '      Next j' + vbCR +
    '    Next i' + vbCR +
    '    Rem' + vbCR +
    '    Rem Do Grandtotals' + vbCR +
    '    l = 1' + vbCR +
    '    For i = 1 To GroupsCount' + vbCR +
    '      Group = Groups(i)' + vbCR +
    '      If (Group(6) And 16) = 16 Then' + vbCR +
    '        If i = 1 Then Sheet.Range(Root.Rows(1), Root.Rows(Root.Rows.Count - l)).Rows.Ungroup' + vbCR +
    '        Root.Rows(Root.Rows.Count - l).Delete xlShiftUp' + vbCR +
    '      Else' + vbCR +
    '        l = l + Group(2)' + vbCR +
    '      End If' + vbCR +
    '    Next' + vbCR +
    '  End If' + vbCR +
    '  Rem' + vbCR +
    '  Rem DoDeleteSpecialRow' + vbCR +
    '  Root.Rows(Root.Rows.Count).Delete xlShiftUp' + vbCR +
    'End Sub' + vbCR;
begin
  inherited;
  ALibraryCode := SubText;
  ASupportedRanges := [rtRange];
  ADeleteSpecialrow := saCompleteDelete;
  AName := 'SMARTGROUP';
end;

procedure TopSmartGroup.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);

  function IsParamExists(Itm: TxlOptionItem; ParamName: string; ValueTrue, ValueFalse: OLEVariant): OLEVariant;
  begin
    Result := ValueFalse;
    if Itm.ParamExists(ParamName) then
      Result := ValueTrue;
  end;

const
  opMergeLabels = 1;
  opMergeLabels2 = 2;
  opWithHeader = 4;            // reserved
  opDisableOutline = 8;        // reserved
  opDisableSubTotals = 16;
  opDisableGrandTotals = 32;   // reserved
  opPageBreaks = 64;

  function GetGroupOptions(Itm: TxlOptionItem): OLEVariant;
  var
    r: word;
  begin
    r := IsParamExists(Itm, 'MERGELABELS2', opMergeLabels2, 0);
    if r = 0 then
      r := opMergeLabels;
    r := r + IsParamExists(Itm, 'WITHHEADER', opWithHeader, 0);
    r := r + IsParamExists(Itm, 'DISABLESUBTOTALS', opDisableSubTotals, 0);
    r := r + IsParamExists(Itm, 'DISABLEGRANDTOTALS', opDisableGrandTotals, 0);
    r := r + IsParamExists(Itm, 'DISABLEOUTLINE', opDisableOutline, 0);
    r := r + IsParamExists(Itm, 'PAGEBREAKS', opPageBreaks, 0);
    Result := r;
  end;

var
  i, j, p, Level: integer;
  GroupsList, TotalsList: TList;
  Groups, Labels, TotalList, TotalColumns, DSTotalList, DSTotalColumns, V: OLEVariant;
  GroupsCount, OutlineLevel, TotalsCount: integer;
  Itm: TxlOptionItem;
  PostProcessing: boolean;
  {
  Report: TxlExcelReport;
  IXLApp: IxlApplication;
  s: string;
  }
begin
  { Args list:
      5 - Groups                       array [1..GroupsCount] of TGroup
      6 - Labels                       array [1..GroupsCount] of integer
      7 - OutlineLevel                 integer
      8 - PostProcessing               boolean

     TGroup array [1..3] of variant
       TGroup[1] - Group By
       TGroup[2] - TotalsCount
       TGroup[3] - TotalList
       TGroup[4] - TotalColumns
       TGroup[5] - GroupLevel
       TGroup[6] - TGroupOptions

     TGroupOptions (bit mask)
       0 - unmerged,
       1 - mergelabels,
       2 - mergerlabels2
       4 - with header (reserved)
       8 - disable outline (reserved)
       16 - disable subtotals
       32 - disable grandtotals (reserved)
       64 - page breaks }

  // Prepare data
  GroupsList := TList.Create;
  TotalsList := TList.Create;
  GroupsCount := 1;
  TotalsCount := 0;
  Level := 1;
  PostProcessing := false;
  try
    // Presorting off
    // PreSorting(Item, Args);
    // Get subtotals
    Item.List.LinkedItemsOfNames(Item,
      'SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP',
      [xoColumn], false, TotalsList);
    for i := 0 to TotalsList.Count - 1 do begin
      Itm := TxlOptionItem(TotalsList[i]);
      if TotalsCount = 0 then begin
        Inc(TotalsCount);
        TotalList := VarArrayCreate([1, TotalsCount], varVariant);
        TotalList[TotalsCount] := xlrTotalFunctionXLConsts[(Itm.Option as TopTotal).TotalFunc];
        TotalColumns := VarArrayCreate([1, TotalsCount], varVariant);
        V := VarArrayCreate([1, 1], varVariant);
        V[1] := (Itm.Obj as TxlAbstractCell).Column;
        TotalColumns[TotalsCount] := V;
      end
      else begin
        p := 0;
        for j := 1 to TotalsCount do
          if TotalList[j] = xlrTotalFunctionXLConsts[(Itm.Option as TopTotal).TotalFunc] then begin
            p := j;
            Break;
          end;
        if p = 0 then begin
          Inc(TotalsCount);
          VarArrayReDim(TotalList, TotalsCount);
          TotalList[TotalsCount] := xlrTotalFunctionXLConsts[(Itm.Option as TopTotal).TotalFunc];
          VarArrayReDim(TotalColumns, TotalsCount);
          V := VarArrayCreate([1, 1], varVariant);
          V[1] := (Itm.Obj as TxlAbstractCell).Column;
          TotalColumns[TotalsCount] := V;
        end
        else begin
          V := TotalColumns[p];
          VarArrayReDim(V, VarArrayHighBound(V, 1) + 1);
          V[VarArrayHighBound(V, 1)] := (Itm.Obj as TxlAbstractCell).Column;
          TotalColumns[p] := V;
        end;
      end;
    end;
    DSTotalList := VarArrayCreate([1, 1], varVariant);
    DSTotalList[1] := xlrTotalFunctionXLConsts[tfCount];
    DSTotalColumns := TotalColumns;
    // Create First Group
    Groups := VarArrayCreate([1, GroupsCount], varVariant);
    Labels := VarArrayCreate([1, GroupsCount], varVariant);
    // Get group info
    Labels[GroupsCount] := (Item.Obj as TxlAbstractCell).Column;
    if Item.ParamExists('PLACETOCOLUMN') then
      Labels[GroupsCount] := Item.ParamAsInteger('PLACETOCOLUMN') + 1;
    OutLineLevel := IsParamExists(Item, 'COLLAPSE', 0, -1);
    V := VarArrayCreate([1, 6], varVariant);
    V[1] := (Item.Obj as TxlAbstractCell).Column;
    V[6] := GetGroupOptions(Item);
    PostProcessing := PostProcessing or ((V[6] <> 0) and (V[6] <> 64));
    if (V[6] and opDisableSubTotals) = 16 then begin
      V[2] := 1;
      V[3] := DSTotalList;
      V[4] := DSTotalColumns;
      V[5] := Level + 1;
      Inc(Level, 1);
    end
    else begin
      V[2] := TotalsCount;
      V[3] := TotalList;
      V[4] := TotalColumns;
      V[5] := Level + TotalsCount;
      Inc(Level, TotalsCount);
    end;
    Groups[GroupsCount] := V;
    // Get other groups
    Item.List.LinkedItemsOfNames(Item, 'SMARTGROUP', [xoColumn], false, GroupsList);
    for i := 0 to GroupsList.Count - 1 do begin
      Itm := TxlOptionItem(GroupsList[i]);
      if Itm.Option is TopSmartGroup then begin
        Inc(GroupsCount);
        //
        VarArrayReDim(Groups, GroupsCount);
        VarArrayReDim(Labels, GroupsCount);
        //
        Labels[GroupsCount] := (Itm.Obj as TxlAbstractCell).Column;
        if Itm.ParamExists('PLACETOCOLUMN') then
          Labels[GroupsCount] := Itm.ParamAsInteger('PLACETOCOLUMN') + 1;
        if OutlineLevel = - 1 then
          OutLineLevel := IsParamExists(Itm, 'COLLAPSE', Level, -1);
        V := VarArrayCreate([1, 6], varVariant);
        V[1] := (Itm.Obj as TxlAbstractCell).Column;
        V[6] := GetGroupOptions(Itm);
       PostProcessing := PostProcessing or ((V[6] <> 0) and (V[6] <> 64));
       if (V[6] and opDisableSubTotals) = 16 then begin
         V[2] := 1;
         V[3] := DSTotalList;
         V[4] := DSTotalColumns;
         V[5] := Level + 1;
         Inc(Level, 1);
       end
       else begin
         V[2] := TotalsCount;
         V[3] := TotalList;
         V[4] := TotalColumns;
         V[5] := Level + TotalsCount;
         Inc(Level, TotalsCount);
       end;
       Groups[GroupsCount] := V;
      end;
    end;
    // Get other Args
    if OutlineLevel <> 10 then
      OutlineLevel := OutlineLevel + 2;
    // Fill Args
    VarArrayReDim(Args, 8);
    Args[5] := Groups;
    Args[6] := Labels;
    Args[7] := OutlineLevel;
    Args[8] := PostProcessing;
    // Do macro
    DoMacro(Item, 'xlrGroupEx3', Args);
    {
    Report := Item.List.Owner as TxlExcelReport;
    IXLApp := Report.IXLSApp;
    s := '''' + Report.IWorkbook.Name + '''' + '!Module1.xlrGroupEx3';
    OLEVariant(IXLApp).Run(s, Args);
    }
  finally
    for i := 0 to TotalsList.Count - 1 do
      TxlOptionItem(TotalsList[i]).Enabled := false;
    TotalsList.Free;
    for i := 0 to GroupsList.Count - 1 do
      TxlOptionItem(GroupsList[i]).Enabled := false;
    GroupsList.Free;
  end;
end;

{ TopPivotEx }

procedure TopPivotEx.GetOptionInfo(var AName: string;
  var AxlObjects: TxlObjectSet; var ASupportedRanges: TxlRangeTypeSet;
  var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrPivotTableEx(Args As Variant)' + vbCR +
  '  Dim DstSheet As Worksheet, DstRange As Range' + vbCR +
  '  Dim SrcSheet As Worksheet, SrcRange As Range, FmtRange As Range, CaptionRange As Range' + vbCR +
  '  Dim PT As PivotTable, PF As PivotField' + vbCR +
  '  Dim DstStr As String' + vbCR +
  '  Dim PageFieldsCount As Long, RowFieldsCount As Long, ColumnFieldsCount As Long, DataFieldsCount As Long' + vbCR +
  '  Dim PageArr() As String, RowArr() As String, ColumnArr() As String' + vbCR +
  '  Dim Pages As Variant, Rows As Variant, Columns As Variant, Datas As Variant' + vbCR +
  '  Dim V As Variant, Funcs As Variant' + vbCR +
  '  Dim LocaleR As String, LocaleC As String, DstPT as String' + vbCR +
  '  Dim i As Long, j As Long, ErrValueStr As String, Ch as ChartObject' + vbCR +
  '' + vbCR +
  '  Rem Init variables' + vbCR +
  '  LocaleC = Application.ConvertFormula("A1", xlA1, xlR1C1, xlAbsolute)' + vbCR +
  '  LocaleR = Mid(LocaleC, 1, 1)' + vbCR +
  '  LocaleC = Mid(LocaleC, 3, 1)' + vbCR +
  '  ErrValueStr = Range("XLR_ERRNAMESTR").Text' + vbCR +
  '  DstStr = Args(6)' + vbCR +
  '  PageFieldsCount = 0' + vbCR +
  '  RowFieldsCount = 0' + vbCR +
  '  ColumnFieldsCount = 0' + vbCR +
  '  DataFieldsCount = 0' + vbCR +
  '  Pages = Args(10)' + vbCR +
  '  Rows = Args(11)' + vbCR +
  '  Columns = Args(12)' + vbCR +
  '  Datas = Args(13)' + vbCR +
  '  DstPT = Args(18)' + vbCR +
  '  If Not IsEmpty(Pages) Then PageFieldsCount = UBound(Pages, 1)' + vbCR +
  '  If Not IsEmpty(Rows) Then RowFieldsCount = UBound(Rows, 1)' + vbCR +
  '  If Not IsEmpty(Columns) Then ColumnFieldsCount = UBound(Columns, 1)' + vbCR +
  '  If Not IsEmpty(Datas) Then DataFieldsCount = UBound(Datas, 1)' + vbCR +
  '' + vbCR +
  '  Rem Connect' + vbCR +
  '  Set SrcRange = Range(Args(1))' + vbCR +
  '  Set SrcSheet = SrcRange.Parent' + vbCR +
  '  Set SrcRange = SrcSheet.Range(SrcSheet.Cells(SrcRange.Row - 1, SrcRange.Column + 1), _' + vbCR +
  '    SrcSheet.Cells(SrcRange.Row + SrcRange.Rows.Count - 2, SrcRange.Column + SrcRange.Columns.Count - 1))' + vbCR +
  '  If DstPT = "" Then' + vbCR +
  '    If DstStr <> "" Then' + vbCR +
  '      Set DstSheet = Worksheets(Mid(DstStr, 1, InStr(DstStr, "!") - 1))' + vbCR +
  '      DstStr = Mid(DstStr, InStr(DstStr, "!") + 1, Len(DstStr) - InStr(DstStr, "!"))' + vbCR +
  '      If Len(DstStr) > 5 Then DstStr = Application.WorksheetFunction.Substitute(DstStr, "R", LocaleR)' + vbCR +
  '      If Len(DstStr) > 5 Then DstStr = Application.WorksheetFunction.Substitute(DstStr, "C", LocaleC)' + vbCR +
  '      DstStr = DstStr & ":" & DstStr' + vbCR +
  '      If (InStr(DstStr, LocaleR) = 1) And (InStr(DstStr, LocaleC) > 0) Then' + vbCR +
  '        DstStr = Application.ConvertFormula(DstStr, xlR1C1, xlA1, xlAbsolute)' + vbCR +
  '      End If' + vbCR +
  '      Set DstRange = DstSheet.Range(DstStr)' + vbCR +
  '    Else' + vbCR +
  '      Set DstSheet = Worksheets.Add' + vbCR +
  '      DstSheet.Name = Args(5)' + vbCR +
  '      Set DstRange = DstSheet.Cells(PageFieldsCount + 4, 2)' + vbCR +
  '    End If' + vbCR +
  '    DstStr = DstSheet.Name + "!" + DstRange.Address(True, True, xlR1C1)' + vbCR +
  '  End If' + vbCR +
  '  If DstPT <> "" Then' + vbCR +
  '    For i = 1 to UBound(Args(19)) - 1' + vbCR +
  '      Set PT = Worksheets(Left(Args(19)(i), InStr(1, Args(19)(i), "!") - 1)).PivotTables(Right(Args(19)(i), Len(Args(19)(i)) - InStr(1, Args(19)(i), "!")))' + vbCR +
  '      If Args(22) > 0 Then' +vbCR +
  '        PT.Name = PT.Name & Args(22)' + vbCR +
  '      End If' + vbCR +
  '      call PT.PivotTableWizard(SourceType:=xlDatabase, SourceData:= SrcRange.AddressLocal(true, true, xlR1C1, true))' + vbCR +
  '      On Error Resume Next' + vbCR +
  '      For Each PF in PT.PivotFields' + vbCR +
  '        rem If UCase(PF.Name) <> "DATA" Then' + vbCR +
  '          If (PF.Orientation <> xlHidden) and (not PF.IsCalculated) Then' + vbCR +
  '            If PF.AutoSortOrder = xlManual then' + vbCR +
  '              If PF.PivotItems.Count > 0 Then PF.PivotItems(1).Delete' + vbCR +
  '            Else' + vbCR +
  '              For j = 1 to PF.PivotItems.Count' + vbCR +
  '                if PF.PivotItems(j).Value = ErrValueStr Then' + vbCR +
  '                  PF.PivotItems(j).Delete' + vbCR +
  '                  Exit For' + vbCR +
  '                End If' + vbCR +
  '              Next' + vbCR +
  '            EndIf' + vbCR +
  '          End If' + vbCR +
  '        rem End If' + vbCR +
  '      Next' + vbCR +
//  '      Stop' + vbCR +
  '      If Args(20) <> "" Then' + vbCR +
  '        If UBound(Args(21)) >= i Then' + vbCR +
  '          If Args(21)(i) <> "" Then' + vbCR +
  '            Set Ch = Worksheets(Left(Args(21)(i), InStr(1, Args(21)(i), "!") - 1)).ChartObjects(Right(Args(21)(i), Len(Args(21)(i)) - InStr(1, Args(21)(i), "!")))' + vbCR +
  '            Ch.Chart.SetSourceData Source := PT.TableRange2' + vbCR +
  '          End If' + vbCR +
  '        End If' + vbCR +
  '      End If' + vbCR +
  '    Next' + vbCR +
  '  Else' + vbCR +
  '    Set PT = DstSheet.PivotTableWizard(SourceType:=xlDatabase, SourceData:=SrcRange, _' + vbCR +
  '      TableDestination:=DstRange, TableName:=Args(5), _' + vbCR +
  '      RowGrand:=Args(8), ColumnGrand:=Args(9), SaveData:=True, HasAutoFormat:=False, _' + vbCR +
  '      OptimizeCache:=True, PageFieldOrder:=xlDownThenOver, ReadData:=True)' + vbCR +
  '    PT.PreserveFormatting = True' + vbCR +
  '    PT.MergeLabels = Args(16)' + vbCR +
  '    If PageFieldsCount > 0 Then' + vbCR +
  '      ReDim PageArr(PageFieldsCount)' + vbCR +
  '      For i = 1 To PageFieldsCount' + vbCR +
  '        V = Pages(i)' + vbCR +
  '        PageArr(i) = V(2)' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '    If RowFieldsCount > 0 Then' + vbCR +
  '      ReDim RowArr(RowFieldsCount)' + vbCR +
  '      For i = 1 To RowFieldsCount' + vbCR +
  '        V = Rows(i)' + vbCR +
  '        RowArr(i) = V(2)' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '    If ColumnFieldsCount > 0 Then' + vbCR +
  '      ReDim ColumnArr(ColumnFieldsCount)' + vbCR +
  '      For i = 1 To ColumnFieldsCount' + vbCR +
  '        V = Columns(i)' + vbCR +
  '        ColumnArr(i) = V(2)' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '    If Args(7) = True Then' + vbCR +
  '      ReDim Preserve RowArr(RowFieldsCount + 1)' + vbCR +
  '      RowArr(RowFieldsCount + 1) = "Data"' + vbCR +
  '    Else' + vbCR +
  '      ReDim Preserve ColumnArr(ColumnFieldsCount + 1)' + vbCR +
  '      ColumnArr(ColumnFieldsCount + 1) = "Data"' + vbCR +
  '    End If' + vbCR +
  '    If (RowFieldsCount > 0) or (Args(7) = True) Then PT.AddFields RowFields:=RowArr, AddToTable:=True' + vbCR +
  '    If (ColumnFieldsCount > 0) or (Args(7) = False) Then PT.AddFields ColumnFields:=ColumnArr, AddToTable:=True' + vbCR +
  '    If PageFieldsCount > 0 Then PT.AddFields PageFields:=PageArr, AddToTable:=True' + vbCR +
  '' + vbCR +
  '    Rem Build data fields (datarange)' + vbCR +
  '    PT.ManualUpdate = True' + vbCR +
  '    For i = 1 To DataFieldsCount' + vbCR +
  '      V = Datas(i)' + vbCR +
  '      Set PF = PT.PivotFields(V(2))' + vbCR +
  '      PF.Orientation = xlDataField' + vbCR +
  '      PF.Position = i' + vbCR +
  '      Funcs = V(3)' + vbCR +
  '      If V(4) = True Then' + vbCR +
  '          For j = 1 To 12' + vbCR +
  '            If Funcs(j) = True Then' + vbCR +
  '              Select Case j' + vbCR +
  '                Case 3' + vbCR +
  '                  PF.Function = xlCount' + vbCR +
  '                Case 4' + vbCR +
  '                  PF.Function = xlAverage' + vbCR +
  '                Case 5' + vbCR +
  '                  PF.Function = xlMax' + vbCR +
  '                Case 6' + vbCR +
  '                  PF.Function = xlMin' + vbCR +
  '                Case 7' + vbCR +
  '                  PF.Function = xlProduct' + vbCR +
  '                Case 8' + vbCR +
  '                  PF.Function = xlCountNums' + vbCR +
  '                Case 9' + vbCR +
  '                  PF.Function = xlStDev' + vbCR +
  '                Case 10' + vbCR +
  '                  PF.Function = xlStDevP' + vbCR +
  '                Case 11' + vbCR +
  '                  PF.Function = xlVar' + vbCR +
  '                Case 12' + vbCR +
  '                  PF.Function = xlVarP' + vbCR +
  '                Case Else' + vbCR +
  '                  PF.Function = xlSum' + vbCR +
  '              End Select' + vbCR +
  '              Exit For' + vbCR +
  '            End If' + vbCR +
  '          Next' + vbCR +
  '      End If' + vbCR +
  '      PF.Name = V(2) & " "' + vbCR +
  '    Next' + vbCR +
  '    PT.ManualUpdate = False' + vbCR +
  '' + vbCR +
  '    Rem Build formatting data fields' + vbCR +
  '    If (Args(14) = True) And (Args(17) = True) Then' + vbCR +
  '      On Error Resume Next' + vbCR +
  '      For i = 1 To DataFieldsCount' + vbCR +
  '        V = Datas(i)' + vbCR +
  '        Set PF = PT.DataFields(i)' + vbCR + // V(2) & " ")' + vbCR +
  '        Set FmtRange = SrcRange.Cells(2, V(1) - 1)' + vbCR +
  '        If PF.DataType <> xlText Then' + vbCR +
  '          PF.NumberFormat = FmtRange.NumberFormat' + vbCR +
  '        End If' + vbCR +
  '        PF.DataRange.Interior.ColorIndex = FmtRange.Interior.ColorIndex' + vbCR +
  '        PF.DataRange.Font.Name = FmtRange.Font.Name' + vbCR +
  '        PF.DataRange.Font.Color = FmtRange.Font.Color' + vbCR +
  '        PF.DataRange.Font.Size = FmtRange.Font.Size' + vbCR +
  '        PF.DataRange.Font.FontStyle = FmtRange.Font.FontStyle' + vbCR +
  '        PF.DataRange.HorizontalAlignment = FmtRange.HorizontalAlignment' + vbCR +
  '        PF.DataRange.VerticalAlignment = FmtRange.VerticalAlignment' + vbCR +
  '        If Args(17) = True Then' + vbCR +
  '          Set CaptionRange = SrcRange.Cells(1, V(1) - 1)' + vbCR +
  '          PF.LabelRange.Interior.ColorIndex = CaptionRange.Interior.ColorIndex' + vbCR +
  '          PF.LabelRange.Font.Name = CaptionRange.Font.Name' + vbCR +
  '          PF.LabelRange.Font.Color = CaptionRange.Font.Color' + vbCR +
  '          PF.LabelRange.Font.Size = CaptionRange.Font.Size' + vbCR +
  '          PF.LabelRange.Font.FontStyle = CaptionRange.Font.FontStyle' + vbCR +
  '          PF.LabelRange.HorizontalAlignment = CaptionRange.HorizontalAlignment' + vbCR +
  '          PF.LabelRange.VerticalAlignment = CaptionRange.VerticalAlignment' + vbCR +
  '        End If' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
//  '  PT.ManualUpdate = True' + vbCR +
  '    Rem Build page fields' + vbCR +
  '    For i = 1 To PageFieldsCount' + vbCR +
  '      V = Pages(i)' + vbCR +
  '      Set PF = PT.PivotFields(V(2))' + vbCR +
  '      PF.Subtotals = V(3)' + vbCR +
  '      If Args(14) = True Then' + vbCR +
  '          Set FmtRange = SrcRange.Cells(2, V(1) - 1)' + vbCR +
  '          If (PF.DataType = xlDate) Or (PF.DataType = xlNumber) Then' + vbCR +
  '            PF.NumberFormat = FmtRange.NumberFormat' + vbCR +
  '          End If' + vbCR +
  '          PF.DataRange.Interior.ColorIndex = FmtRange.Interior.ColorIndex' + vbCR +
  '          PF.DataRange.Font.Name = FmtRange.Font.Name' + vbCR +
  '          PF.DataRange.Font.Color = FmtRange.Font.Color' + vbCR +
  '          PF.DataRange.Font.Size = FmtRange.Font.Size' + vbCR +
  '          PF.DataRange.Font.FontStyle = FmtRange.Font.FontStyle' + vbCR +
  '          PF.DataRange.HorizontalAlignment = FmtRange.HorizontalAlignment' + vbCR +
  '          PF.DataRange.VerticalAlignment = FmtRange.VerticalAlignment' + vbCR +
  '      End If' + vbCR +
  '    Next' + vbCR +
  '' + vbCR +
  '    Rem Build row fields' + vbCR +
  '    For i = 1 To RowFieldsCount' + vbCR +
  '      V = Rows(i)' + vbCR +
  '      Set PF = PT.PivotFields(V(2))' + vbCR +
  '      PF.Subtotals = V(3)' + vbCR +
  '      If Args(14) = True Then' + vbCR +
  '          Set FmtRange = SrcRange.Cells(2, V(1) - 1)' + vbCR +
  '          If (PF.DataType = xlDate) Or (PF.DataType = xlNumber) Then' + vbCR +
  '            PF.NumberFormat = FmtRange.NumberFormat' + vbCR +
  '          End If' + vbCR +
  '          PF.DataRange.Interior.ColorIndex = FmtRange.Interior.ColorIndex' + vbCR +
  '          PF.DataRange.Font.Name = FmtRange.Font.Name' + vbCR +
  '          PF.DataRange.Font.Color = FmtRange.Font.Color' + vbCR +
  '          PF.DataRange.Font.Size = FmtRange.Font.Size' + vbCR +
  '          PF.DataRange.Font.FontStyle = FmtRange.Font.FontStyle' + vbCR +
  '          PF.DataRange.HorizontalAlignment = FmtRange.HorizontalAlignment' + vbCR +
  '          PF.DataRange.VerticalAlignment = FmtRange.VerticalAlignment' + vbCR +
//  '        If Args(17) = True Then' + vbCR +
//  '            Set CaptionRange = SrcRange.Cells(1, V(1) - 1)' + vbCR +
//  '            PF.LabelRange.Interior.ColorIndex = CaptionRange.Interior.ColorIndex' + vbCR +
//  '            PF.LabelRange.Font.Name = CaptionRange.Font.Name' + vbCR +
//  '            PF.LabelRange.Font.Color = CaptionRange.Font.Color' + vbCR +
//  '            PF.LabelRange.Font.Size = CaptionRange.Font.Size' + vbCR +
//  '            PF.LabelRange.Font.FontStyle = CaptionRange.Font.FontStyle' + vbCR +
//  '            PF.LabelRange.HorizontalAlignment = CaptionRange.HorizontalAlignment' + vbCR +
//  '            PF.LabelRange.VerticalAlignment = CaptionRange.VerticalAlignment' + vbCR +
//  '        End If' + vbCR +
  '      End If' + vbCR +
  '    Next' + vbCR +
  '' + vbCR +
  '    Rem Build column fields' + vbCR +
  '    For i = 1 To ColumnFieldsCount' + vbCR +
  '      V = Columns(i)' + vbCR +
  '      Set PF = PT.PivotFields(V(2))' + vbCR +
  '      PF.Subtotals = V(3)' + vbCR +
  '      If Args(14) = True Then' + vbCR +
  '        Set FmtRange = SrcRange.Cells(2, V(1) - 1)' + vbCR +
  '        If (PF.DataType = xlDate) Or (PF.DataType = xlNumber) Then' + vbCR +
  '          PF.NumberFormat = FmtRange.NumberFormat' + vbCR +
  '        End If' + vbCR +
  '        PF.DataRange.Interior.ColorIndex = FmtRange.Interior.ColorIndex' + vbCR +
  '        PF.DataRange.Font.Name = FmtRange.Font.Name' + vbCR +
  '        PF.DataRange.Font.Color = FmtRange.Font.Color' + vbCR +
  '        PF.DataRange.Font.Size = FmtRange.Font.Size' + vbCR +
  '        PF.DataRange.Font.FontStyle = FmtRange.Font.FontStyle' + vbCR +
  '        PF.DataRange.HorizontalAlignment = FmtRange.HorizontalAlignment' + vbCR +
  '        PF.DataRange.VerticalAlignment = FmtRange.VerticalAlignment' + vbCR +
//  '      If Args(17) = True Then' + vbCR +
//  '          Set CaptionRange = SrcRange.Cells(1, V(1) - 1)' + vbCR +
//  '          PF.LabelRange.Interior.ColorIndex = CaptionRange.Interior.ColorIndex' + vbCR +
//  '          PF.LabelRange.Font.Name = CaptionRange.Font.Name' + vbCR +
//  '          PF.LabelRange.Font.Color = CaptionRange.Font.Color' + vbCR +
//  '          PF.LabelRange.Font.Size = CaptionRange.Font.Size' + vbCR +
//  '          PF.LabelRange.Font.FontStyle = CaptionRange.Font.FontStyle' + vbCR +
//  '          PF.LabelRange.HorizontalAlignment = CaptionRange.HorizontalAlignment' + vbCR +
//  '          PF.LabelRange.VerticalAlignment = CaptionRange.VerticalAlignment' + vbCR +
//  '      End If' + vbCR +
  '      End If' + vbCR +
  '    Next' + vbCR +
  '' + vbCR +
  '    Rem Build column sub totals' + vbCR +
  '    If Args(14) = True Then' + vbCR +
  '      For i = 1 To ColumnFieldsCount' + vbCR +
  '        V = Columns(i)' + vbCR +
  '        If V(4) = True Then' + vbCR +
  '          Set FmtRange = SrcSheet.Cells(SrcRange.Row + SrcRange.Rows.Count, SrcRange.Column + V(1) - 2)' + vbCR +
  '          PT.PivotSelect V(5), xlDataAndLabel' + vbCR +
  '          Selection.Interior.ColorIndex = FmtRange.Interior.ColorIndex' + vbCR +
  '          Selection.Font.Name = FmtRange.Font.Name' + vbCR +
  '          Selection.Font.Color = FmtRange.Font.Color' + vbCR +
  '          Selection.Font.Size = FmtRange.Font.Size' + vbCR +
  '          Selection.Font.FontStyle = FmtRange.Font.FontStyle' + vbCR +
  '          Selection.HorizontalAlignment = FmtRange.HorizontalAlignment' + vbCR +
  '          Selection.VerticalAlignment = FmtRange.VerticalAlignment' + vbCR +
  '        End If' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '' + vbCR +
  '    Rem Build row sub totals' + vbCR +
  '    If Args(14) = True Then' + vbCR +
  '      For i = 1 To RowFieldsCount' + vbCR +
  '        V = Rows(i)' + vbCR +
  '        If V(4) = True Then' + vbCR +
  '          Set FmtRange = SrcSheet.Cells(SrcRange.Row + SrcRange.Rows.Count, SrcRange.Column + V(1) - 2)' + vbCR +
  '          PT.PivotSelect V(5), xlDataAndLabel' + vbCR +
  '          Selection.Interior.ColorIndex = FmtRange.Interior.ColorIndex' + vbCR +
  '          Selection.Font.Name = FmtRange.Font.Name' + vbCR +
  '          Selection.Font.Color = FmtRange.Font.Color' + vbCR +
  '          Selection.Font.Size = FmtRange.Font.Size' + vbCR +
  '          Selection.Font.FontStyle = FmtRange.Font.FontStyle' + vbCR +
  '          Selection.HorizontalAlignment = FmtRange.HorizontalAlignment' + vbCR +
  '          Selection.VerticalAlignment = FmtRange.VerticalAlignment' + vbCR +
  '        End If' + vbCR +
  '      Next' + vbCR +
  '    End If' + vbCR +
  '    PT.ManualUpdate = False' + vbCR +
  '  End If' + vbCR +
  // b109: comment path Excel PivotTable bug
  //  '  PT.PreserveFormatting = True' + vbCR +
  '' + vbCR +
  '  Rem independent delete special row' + vbCR +
  '  Set SrcRange = Range(Args(1))' + vbCR +
  '  SrcRange.Rows(SrcRange.Rows.Count).Delete xlShiftUp' + vbCR +
  '  Set SrcRange = SrcSheet.Cells(1, 1)' + vbCR +
  'End Sub';
begin
  inherited;
  ALibraryCode := ALibraryCode + vbCR + SubText;
end;

procedure TopPivotEx.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  ChartList: OLEVariant;
  RefreshChart: boolean;
  i: integer;
  s: string;
begin
  { Args list:
      5 - PivotTable.Name              string
      6 - PivotTable.Destination       string
      7 - PivotTable.DataToRows        boolean
      8 - PivotTable.RowGrand          boolean
      9 - PivotTable.ColumnGrand       boolean
     10 - PivotTable.PageFields        PivotFieldArray
     11 - PivotTable.RowFields         PivotFieldArray
     12 - PivotTable.ColumnFields      PivotFieldArray
     13 - PivotTable.DataFields        PivotFieldArray
     14 - NoPreserveFormatting         boolean
     15 - Debug                        boolean
     16 - MergeLables                  boolean
     17 - CaptionNoFormatting          boolean
     18 - Refresh                      boolean
     19 - PivotNames                   array of string
     20 - RefreshChart                 boolean
     21 - PivotChartNames              array of string
     22 - Multisheet index             integer

     PivotArray = VarArray[1..FiledCount] of PivotField;
     Field = VarArray[1..3] of Variant,
       Field[1] - Cell.Column (integer)
       Field[2] - Cell.Caption (string)
       Field[3] - PivotField.SubTotals (VarArray[1..12] of boolean)
       Field[4] - CreateSubTotals (booelan)
       Field[5] - SubTotalFieldSelectStr }
  if (Item.xlObject = xoRange) and ((Item.Obj as TxlExcelDataSource).RangeType = rtRange) then begin
    inherited InitArgs(Item, Args);
    {$IFDEF XLR_BCB}
    if (Item.List.Owner as TxlExcelReport).IXLSApp.Version > '9' then begin
    {$ELSE}
    if (Item.List.Owner as TxlExcelReport).IXLSApp.Version[xlrLCID] > '9' then begin
    {$ENDIF}
      VarArrayReDim(Args, 22);
      RefreshChart := Item.ParamExists('WITHCHART');
      if RefreshChart then
        if Trim(Item.Params.Values['WITHCHART']) <> '' then
          Args[20] := Item.Params.Values['WITHCHART'];
      // Charts for refresh
      ChartList := UnAssigned;
      if RefreshChart then begin
        i := 1;
        ChartList := VarArrayCreate([1, 1], varVariant);
        s := Args[20];
        repeat
          ChartList[i] := CutSubString(',', s);
          Inc(i);
          VarArrayReDim(ChartList, i);
        until Trim(s) = '';
      end;
      Args[21] := ChartList;
      Args[22] := (Item.List.Owner as TxlExcelReport).MultySheetIndex;
    end;
  end;
end;

procedure TopPivotEx.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  if (Item.xlObject = xoRange) and ((Item.Obj as TxlExcelDataSource).RangeType = rtRange) then
    {$IFDEF XLR_BCB}
    if (Item.List.Owner as TxlExcelReport).IXLSApp.Version > '9' then
    {$ELSE}
    if (Item.List.Owner as TxlExcelReport).IXLSApp.Version[xlrLCID] > '9' then
    {$ENDIF}
      DoMacro(Item, 'xlrPivotTableEx', Args)
    else
      inherited;
end;

end.

