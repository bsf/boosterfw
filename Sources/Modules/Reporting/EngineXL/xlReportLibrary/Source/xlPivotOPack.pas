{*******************************************************************}
{                                                                   }
{       AfalinaSoft Visual Component Library                        }
{       XL Report 4.0 with XLOptionPack Technology                  }
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

unit xlPivotOPack;

{$I xlcDefs.inc}

interface

{ XL Report PivotTable Options Package
=======================================================================
OPTION          PARAMS                OBJECTS      RNG     Priority
=======================================================================
"Group"         "\Asc" *              Column       r       Higher
                "\Desc" *
                "\Collapse" *

"GroupNoSort"                         Workbook *   r       Normal
                                      Worksheet *
                                      Range
-----------------------------------------------------------------------
"Pivot"          "\Name="             Range        r       Highest
                 "\Dst="
                 "\DataToRows"
                 "\RowGrand"
                 "\ColumnGrand"
                 "\NoPreserveFormatting" *
                 "\MergeLabels" *
                 "\Refresh=PivotTable1,PivotTableN" *
                 "\RefreshChart=PivotChart1,PivotChartN" *

"Data"                                Column       r       Normal
"Row"                                 Column       r       Normal
"Column"                              Column       r       Normal
"Page"                                Column       r       Normal
=======================================================================
Note:
  * - new in version 4.0
  RNG:
    r - range
    t - root range
    m - master range
    d - detail range }

uses Classes, SysUtils, ComObj, ActiveX,
  {$IFDEF XLR_VCL6}
    Variants,
  {$ENDIF}
  {$IFDEF XLR_VCL7}
    Variants,
  {$ENDIF}
  Excel8G2, Office8G2, xlcUtils, xlcOPack, xlcClasses, xlEngine, xlStdOPack;

type

  { Grouping and subtotals }

  TopGroupNoSort = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopGroup = class(TopSort)
  protected
    procedure PreSorting(Item: TxlOptionItem; var Args: TxlOptionArgs);
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

  TopPivotField = class(TxlOptionV4)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopPage = class(TopPivotField)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopRow = class(TopPivotField)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopColumn = class(TopPivotField)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopData = class(TopPivotField)
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopAutoSubTotal = class(TxlOptionV4)
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
  end;

  TopPivot = class(TxlOptionV4)
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); override;
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); override;
  end;

type

  TftFuncNums = array[TxltotalFunction] of integer;

const
  { PivotField.SubTotals(Index)
      1 Automatic
      2 Sum
      3 Count
      4 Average
      5 Max
      6 Min
      7 Product
      8 Count Nums
      9 StdDev
      10 StdDevp
      11 Var
      12 Varp }
  xlrPivotSubTotalFunctionIndex: TftFuncNums = (2, 4, 3, 8, 5, 6, 7, 9, 10, 11, 12);

  { Subtotal worksheet function index
      1 AVERAGE
      2 COUNT
      3 COUNTA
      4 MAX
      5 MIN
      6 PRODUCT
      7 STDEV
      8 STDEVP
      9 SUM
      10 VAR
      11 VARP }
  xlrSubTotalFunctionIndex: TftFuncNums = (9, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11);

implementation

type
  TtfNames = array[TxlTotalFunction] of string;

const
  xlrTotalFunctionSelectNames: TtfNames =
    ( 'Sum', 'Average', 'Count', 'Count Nums', 'Max', 'Min',
      'Product', 'StDev', 'StDevP', 'Var', 'VarP' );

{ TopGroupNoSort }

procedure TopGroupNoSort.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'GROUPNOSORT';
  AxlObjects := [xoWorkbook, xoWorksheet, xoRange];
  ASupportedRanges := [rtRange];
end;

procedure TopGroupNoSort.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  Item.Enabled := false;
end;

{ TopGroup }

procedure TopGroup.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrRangeSubTotals(Args As Variant)' + vbCR +
  '  Dim Sheet As Worksheet' + vbCR +
  '  Dim Root As Range, R As Range' + vbCR +
  '  Dim Ranges As Variant, GroupCols As Variant, Funcs As Variant, FuncCols As Variant' + vbCR +
  '  Dim RangesCount As Long, ColumnCount As Long, GroupCount As Long, FuncCount As Long' + vbCR +
  '  Dim StartRow As Long, EndRow As Long' + vbCR +
  '  Dim GroupIndex As Long, FuncIndex As Long, i As Long, Index As Long' + vbCR +
  '  Set Root = Range(Args(1))' + vbCR +
  '  ColumnCount = Root.Columns.Count' + vbCR +
  '  Set Sheet = Root.Parent' + vbCR +
  '  Call xlrGetRanges(Args, Ranges)' + vbCR +
  '  If IsArray(Ranges) Then' + vbCR +
  '  RangesCount = UBound(Ranges) \ 2' + vbCR +
  '  GroupCols = Args(5)' + vbCR +
  '  GroupCount = UBound(GroupCols)' + vbCR +
  '  Funcs = Args(6)' + vbCR +
  '  FuncCols = Args(7)' + vbCR +
  '  FuncCount = UBound(Funcs)' + vbCR +
  '  StartRow = Ranges(1) - 1' + vbCR +
  '  EndRow = Ranges(2)' + vbCR +
  '  For GroupIndex = GroupCount To 1 Step -1' + vbCR +
  '    For FuncIndex = 1 To FuncCount' + vbCR +
  '      Set R = Sheet.Range(Sheet.Cells(Root.Row - 1, Root.Column), Sheet.Cells(Root.Row + Root.Rows.Count - 2, Root.Column + ColumnCount - 1))' + vbCR +
  '      R.Subtotal GroupCols(GroupIndex), Funcs(FuncIndex), FuncCols(FuncIndex), False, False, xlSummaryBelow' + vbCR +
  '    Next' + vbCR +
  '  Next' + vbCR +
  '  Root.Rows(Root.Rows.Count).Copy' + vbCR +
  '  For i = 1 To Root.Rows.Count + 10' + vbCr +
  '    If Root.Rows(i).Summary = True Then' + vbCr +
  '      Root.Rows(i).PasteSpecial xlPasteFormats, xlPasteSpecialOperationNone, False, False' + vbCR +
  '    End If' + vbCR +
  '  Next' + vbCr +
  '  Root.Rows(Root.Rows.Count).Delete xlShiftUp' + vbCR +
  '  If Args(8) > 0 Then' + vbCR +
  '    Sheet.Outline.ShowLevels(Args(8))' + vbCR +
  '  End If' + vbCR +
  '  End If' + vbCR +
  'End Sub';
begin
  AName := 'GROUP';
  AxlObjects := [xoColumn];
  APriorityArr[xoColumn] := opHigher;
  ALinkedOptions[xoColumn] :=
    'GROUP;SORT;ASC;DESC;SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP';
  ALibraryCode := SubText;
  ADeleteSpecialRow := saCompleteDelete;
  ASupportedRanges := [rtRange];
end;

procedure TopGroup.PreSorting(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  if (not Item.List.ExistsOfObj(TxlAbstractCell(Item.Obj).DataSource, xoRange, [TopGroupNoSort])) and
     (not Item.List.ExistsOfxlObj([xoWorkbook, xoWorksheet], [TopGroupNoSort])) then
    inherited DoItem(Item, Args);
end;

procedure TopGroup.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
var
  LG, LT: TList;
  T, GroupCols, Funcs, FuncCols, V: OLEVariant;
  i, j, GroupCount, FuncCount, Index: integer;
  Itm: TxlOptionItem;
  OutLineLevel: integer;
begin
  if (Item.Obj as TxlAbstractCell).DataSource.RowCount > 1 then
    Exit;
  if (Item.Obj as TxlAbstractCell).DataSource.RangeType in [rtRange] then begin
    GroupCols := UnAssigned;
    FuncCols := UnAssigned;
    Funcs := UnAssigned;
    FuncCount := 0;
    OutLineLevel := 0;
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
      if Trim(Item.Params.Text) = 'COLLAPSE' then
        OutLineLevel := 2;
      for i := 0 to LG.Count - 1 do begin
        Itm := TxlOptionItem(LG[i]);
        if Itm.Option is TopGroup then begin
          Inc(GroupCount);
          VarArrayReDim(GroupCols, GroupCount);
          GroupCols[GroupCount] := (Itm.Obj as TxlAbstractCell).Column;
          if Trim(Itm.Params.Text) = 'COLLAPSE' then
            Inc(OutLineLevel);
        end
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
      // VBA call
      VarArrayReDim(Args, 8);
      Args[5] := GroupCols;
      Args[6] := Funcs;
      Args[7] := FuncCols;
      Args[8] := OutLineLevel;
      // SubTotals
      if FuncCount > 0 then begin
        if GroupCount > 0 then begin
          T := VarArrayCreate([1, GroupCount], varVariant);
          for i := GroupCount downto 1 do begin
            T[GroupCount - i + 1] := GroupCols[i];
          end;
          GroupCols := T;
          Args[5] := GroupCols;
        end;
        DoMacro(Item, 'xlrRangeSubTotals', Args);
      end;
    finally
      for i := 0 to LG.Count - 1 do
        TxlOptionItem(LG[i]).Enabled := false;
      LG.Free;
      for i := 0 to LT.Count - 1 do
        TxlOptionItem(LT[i]).Enabled := false;
      LT.Free;
    end;
  end;
end;

{ TopPivotField }

procedure TopPivotField.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := '';
  AxlObjects := [xoColumn];
  ALinkedOptions[xoColumn] :=
    'SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP';
  ASupportedRanges := [rtRange];
end;

{ TopPage }

procedure TopPage.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'PAGE';
end;

{ TopRow }

procedure TopRow.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'ROW';
end;

{ TopColumn }

procedure TopColumn.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'COLUMN';
end;

{ TopData }

procedure TopData.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  inherited;
  AName := 'DATA';
end;

{ TopAutoSubTotal }

procedure TopAutoSubTotal.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
begin
  AName := 'AUTO';
  AxlObjects := [xoColumn];
  ASupportedRanges := [rtRange];
end;

{ TopPivot }

procedure TopPivot.GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
  var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
  var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
  var ADeleteSpecialRow: TxlSpecialRowAction);
const
  SubText =
  'Public Sub xlrPivotTable(Args As Variant)' + vbCR +
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
  AName := 'PIVOT';
  AxlObjects := [xoRange];
  APriorityArr[xoRange] := opHighest;
  ADeleteSpecialRow := saCompleteDelete;
  ALinkedOptions[xoColumn] :=
    'PAGE;ROW;COLUMN;DATA;SUM;AVG;AVERAGE;COUNT;COUNTNUMS;MAX;MIN;PRODUCT;STDEV;STDEVP;VAR;VARP';
  ASupportedRanges := [rtRange];
  ALibraryCode := SubText;
end;

procedure TopPivot.InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs);
  procedure AddTo(var Arr: OLEVariant; Itm: TxlOptionItem);
  var
    Field, V: OLEVariant;
    L: TList;
    HighBound, i: integer;
    SubTotalItem: TxlOptionItem;
    s: string;
  begin
    L := TList.Create;
    try
      // Add column
      if _VarIsEmpty(Arr) then begin
        Arr := VarArrayCreate([1, 1], varVariant);
        HighBound := 1;
      end
      else begin
        HighBound := VarArrayHighBound(Arr, 1);
        Inc(HighBound);
        VarArrayReDim(Arr, HighBound);
      end;
      Field := VarArrayCreate([1, 5], varVariant);
      Field[1] := (Itm.Obj as TxlAbstractCell).Column;
      Field[2] := (Itm.Obj as TxlAbstractCell).RowCaption;
      Field[4] := false;
      Field[5] := '';
      s := '';
      V := VarArrayCreate([1, 12], varVariant);
      for i := 1 to 12 do
        V[i] := false;
      Itm.List.LinkedItemsOfObj(Itm, L);
      for i := 0 to L.Count - 1 do begin
        SubTotalItem := TxlOptionItem(L[i]);
        if SubTotalItem.Option is TopAutoSubTotal then begin
          V[1] := true;
          Field[4] := true;
          TxlOptionItem(L[i]).Enabled := false; // 4.119
        end
        else
          if SubTotalItem.Option is TopTotal then begin
            V[xlrPivotSubTotalFunctionIndex[(SubTotalItem.Option as TopTotal).TotalFunc]] := true;
            if s = '' then
              s := xlrTotalFunctionSelectNames[(SubTotalItem.Option as TopTotal).TotalFunc]
            else
              s := s + ';' + xlrTotalFunctionSelectNames[(SubTotalItem.Option as TopTotal).TotalFunc];
            Field[4] := true;
          TxlOptionItem(L[i]).Enabled := false; // 4.119
          end
      end;
      if (L.Count = 0) and (Itm.Option is TopData) then begin
        Field[4] := true;
        if (Itm.Obj as TxlAbstractCell).DataType in [xdInteger, xdFloat] then begin
          V[xlrPivotSubTotalFunctionIndex[tfSum]] := true;
          s := xlrTotalFunctionSelectNames[tfSum];
        end
        else begin
          V[xlrPivotSubTotalFunctionIndex[tfCount]] := true;
          s := xlrTotalFunctionSelectNames[tfCount];
        end;
      end;
      Field[3] := V;
      if s <> '' then
        Field[5] := (Itm.Obj as TxlAbstractCell).RowCaption + '[All;' + s + ']';;
      Arr[HighBound] := Field;
    finally
//      for i := 0 to L.Count - 1 do
//        TxlOptionItem(L[i]).Enabled := false;
      L.Free;
    end;
  end;

var
  PivotList, PageFields, RowFields, ColumnFields, DataFields: OLEVariant;
  FieldList: TList;
  i: integer;
  Itm: TxlOptionItem;
  RefreshPivot: boolean;
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

     PivotArray = VarArray[1..FiledCount] of PivotField;
     Field = VarArray[1..3] of Variant,
       Field[1] - Cell.Column (integer)
       Field[2] - Cell.Caption (string)
       Field[3] - PivotField.SubTotals (VarArray[1..12] of boolean)
       Field[4] - CreateSubTotals (booelan)
       Field[5] - SubTotalFieldSelectStr }

  if (Item.xlObject = xoRange) and ((Item.Obj as TxlExcelDataSource).RangeType = rtRange) then begin
    // Get args
    FieldList := TList.Create;
    try
      // Get linked options
      Item.List.LinkedItemsOfNames(Item, 'PAGE;ROW;COLUMN;DATA', [xoColumn], false, FieldList);
      RefreshPivot := false;
      for i := 0 to Item.Params.Count - 1 do begin
        RefreshPivot := Item.Params.Names[i] = 'REFRESH';
        if RefreshPivot then
          Break;
      end;
      if (FieldList.Count > 0) or (RefreshPivot) then begin
        VarArrayReDim(Args, 20);
        Args[5] := '';
        Args[6] := '';
        Args[7] := false;
        Args[8] := false;
        Args[9] := false;
        Args[14] := true;
        Args[15] := xlrDebug;
        Args[16] := false;
        Args[17] := true;
        Args[18] := '';
        // Privot params
        for i := 0 to Item.Params.Count - 1 do
          if Item.Params.Names[i] = 'NAME' then
            Args[5] := Item.Params.Values['NAME']
          else
            if Item.Params.Names[i] = 'DST' then
              Args[6] := Item.Params.Values['DST']
            else
              if Trim(Item.Params[i]) = 'DATATOROWS' then
                Args[7] := true
              else
                if Trim(Item.Params[i]) = 'ROWGRAND' then
                  Args[8] := true
                else
                  if Trim(Item.Params[i]) = 'COLUMNGRAND' then
                    Args[9] := true
                  else
                    if Trim(Item.Params[i]) = 'NOPRESERVEFORMATTING' then
                      Args[14] := false
                    else
                      if Trim(Item.Params[i]) = 'MERGELABELS' then
                        Args[16] := true
                      else
                        if Trim(Item.Params[i]) = 'NOCAPTIONFORMATTING' then
                          Args[17] := false
                        else
                          if Item.Params.Names[i] = 'REFRESH' then begin
                            if Trim(Item.Params.Values['REFRESH']) <> '' then
                              Args[18] := Item.Params.Values['REFRESH']
                          end    
                          else
                            if Item.Params.Names[i] = 'REFRESHCHART' then begin
                          end;
        // Pivot fields
        PageFields := UnAssigned;
        RowFields := UnAssigned;
        ColumnFields := UnAssigned;
        DataFields := UnAssigned;
        for i := 0 to FieldList.Count - 1 do begin
          Itm := TxlOptionItem(FieldList[i]);
          if Itm.Option is TopPage then
            AddTo(PageFields, Itm)
          else
            if Itm.Option is TopRow then
              AddTo(RowFields, Itm)
            else
              if Itm.Option is TopColumn then
                AddTo(ColumnFields, Itm)
              else
                if Itm.Option is TopData then
                  AddTo(DataFields, Itm);
        end;
        Args[10] := PageFields;
        Args[11] := RowFields;
        Args[12] := ColumnFields;
        Args[13] := DataFields;
        // Pivot tables for refresh
        PivotList := UnAssigned;
        if RefreshPivot then begin
          i := 1;
          PivotList := VarArrayCreate([1, 1], varVariant);
          s := Args[18];
          repeat
            PivotList[i] := CutSubString(',', s);
            Inc(i);
            VarArrayReDim(PivotList, i);
          until Trim(s) = '';
        end;
        Args[19] := PivotList;
      end;
    finally
      for i := 0 to FieldList.Count - 1 do
        TxlOptionItem(FieldList[i]).Enabled := false;
      FieldList.Free;
    end;
  end;
end;

procedure TopPivot.DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  if (Item.xlObject = xoRange) and ((Item.Obj as TxlExcelDataSource).RangeType = rtRange) then
    DoMacro(Item, 'xlrPivotTable', Args);
end;

end.

