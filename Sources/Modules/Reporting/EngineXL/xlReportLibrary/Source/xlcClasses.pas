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

unit xlcClasses;

{$I xlcDefs.inc}

interface

uses Classes, SysUtils, Controls, Forms, Windows, Dialogs,
  {$IFDEF XLR_VCL6}
    Variants,
  {$ENDIF}
  {$IFDEF XLR_VCL7}
    Variants,
  {$ENDIF}
  xlcUtils, xlcOPack;

type

  TxlAbstractDataSet = class;
  TxlAbstractCell = class;
  TxlAbstractCells = class;
  TxlAbstractDataSource = class;
  TxlAbstractDataSources = class;
  TxlAbstractReport = class;
  TxlAbstractReportClass = class of TxlAbstractReport;

{ ExlReportError }

  {$IFNDEF XLR_VCL}
  ExlReportError = class(Exception)
  private
    FErrorCode: integer;
  public
    constructor CreateRes2(Ident, AErrorCode: Integer);
    constructor CreateResFmt2(Ident, AErrorCode: Integer; const Args: array of const);
    property ErrorCode: integer read FErrorCode;
  end;
  {$ELSE}
  ExlReportError = class(Exception);
  {$ENDIF}

{ TxlAbstractDataSet class - abstract datasets wrapper }

  // Supported data types
  TxlDataType = (xdNotSupported, xdInteger, xdBoolean, xdFloat, xdDateTime, xdString);

  TxlAbstractDataSet = class(TObject)
  private
    FFields: TStrings;
    FFieldsType: TList;
    FExternalDisconnect: boolean;
    FDataSource: TxlAbstractDataSource;
    function GetFieldType(Index: integer): TxlDataType;
    procedure SetFieldType(Index: integer; const Value: TxlDataType);
  public
    constructor Create(ADataSource: TxlAbstractDataSource); virtual;
    destructor Destroy; override;
    // Connect/disconnect
    procedure Connect; virtual;
    procedure Disconnect(const IsClose: boolean); virtual;
    procedure Open; virtual; abstract;
    procedure Close; virtual; abstract;
    // Get metadata
    procedure GetFields; virtual; abstract;
    procedure GetFieldsType; virtual; abstract;
    function Flags: DWORD; virtual;
    // DataSet state
    function Name: string; virtual; abstract;
    function Active: boolean; virtual; abstract;
    procedure EnableControls; virtual; abstract;
    procedure DisableControls; virtual; abstract;
    function Bof: boolean; virtual; abstract;
    function Eof: boolean; virtual; abstract;
    // Navigation
    procedure First; virtual; abstract;
    procedure Next; virtual; abstract;
    procedure SetBookmark; virtual; abstract;
    procedure GotoBookmark; virtual; abstract;
    procedure SetFilter(const FieldIndex: integer); virtual; abstract;
    // FieldAs...
    function FieldIndex(const FieldName: string): integer; virtual;
    function FieldIsEmpty(const Index: integer): boolean; virtual; abstract;
    function FieldAsText(const Index: integer): string; virtual;
    function FieldAsInteger(const Index: integer): integer; virtual; abstract;
    function FieldAsFloat(const Index: integer): extended; virtual; abstract;
    function FieldAsDateTime(const Index: integer): TDateTime; virtual; abstract;
    function FieldAsString(const Index: integer): string; virtual; abstract;
    function FieldAsBoolean(const Index: integer): boolean; virtual; abstract;
    function FieldAsOLEVariant(const Index: integer): OLEVariant; virtual; abstract;
    // Properties
    property Fields: TStrings read FFields;
    property FieldType[Index: integer]: TxlDataType read GetFieldType write SetFieldType;
    property ExternalDisconnect: boolean read FExternalDisconnect write FExternalDisconnect;
    property DataSource: TxlAbstractDataSource read FDataSource;
  end;

{ TxlAbstractCell class }

  // Supported cell types
  TxlCellType = (ctEmpty, ctSpecialRow, ctSpecialColumn, ctField, ctFormula, ctCR);

  TxlAbstractCell = class(TObject)
  private
    FDataSource: TxlAbstractDataSource;
    FRow: integer;
    FColumn: integer;
    FCellType: TxlCellType;
    FRowCaption: string;
    FFormula: string;
    FFieldIndex: integer;
    FOptionFound: boolean;
    procedure SetFormula(const Value: string);
    function GetDataType: TxlDataType;
    function GetString: string;
    function GetFloat: double;
    function GetBoolean: boolean;
    function GetIsEmpty: boolean;
    function GetVariant: OLEVariant;
  public
    constructor Create(ADataSource: TxlAbstractDataSource);
    property DataSource: TxlAbstractDataSource read FDataSource;
    property RowCaption: string read FRowCaption write FRowCaption;
    property Formula: string read FFormula write SetFormula;
    property OptionFound: boolean read FOptionFound write FOptionFound;
    property Row: integer read FRow write FRow;
    property Column: integer read FColumn write FColumn;
    property CellType: TxlCellType read FCellType;
    property FieldIndex: integer read FFieldIndex;
    property DataType: TxlDataType read GetDataType;
    property IsEmpty: boolean read GetIsEmpty;
    property AsVariant: OLEVariant read GetVariant;
    property AsString: string read GetString;
    property AsFloat: double read GetFloat;
    property AsBoolean: boolean read GetBoolean;
  end;

{ TxlAbstractCells class }

  TxlAbstractCells = class(TList)
  private
    FDataSource: TxlAbstractDataSource;
    function GetItem(Index: integer): TxlAbstractCell;
    function AddNewRow: TxlAbstractCell;
  public
    constructor Create(ADataSource: TxlAbstractDataSource);
    procedure Clear; override;
    function Add: TxlAbstractCell;
    function FirstCellOfRow(const ARow: integer): TxlAbstractCell;
    property DataSource: TxlAbstractDataSource read FDataSource;
    property Items[Index: integer]: TxlAbstractCell read GetItem; default;
  end;

{ TxlAbstractDataSource class }

  // Macro type
  TxlMacroType = (mtBefore, mtAfter);

  TxlAbstractDataSource = class(TCollectionItem)
  private
    FReport: TxlAbstractReport;
    FRange: string;
    FAlias: string;
    FTag: integer;
    FEnabled: boolean;
    FMacroBefore: string;
    FMacroAfter: string;
    FCells: TxlAbstractCells;
    FRow, FColumn: integer;
    FRowCount, FColCount: integer;
    FXLDataSet: TxlAbstractDataSet;
    FMasterSourceName: string;
    FMasterSource: TxlAbstractDataSource;
    FDetails: TList;
    FOptionFound: boolean;
    FAutoOpen: boolean;
    FAutoClose: boolean;
    procedure SetRange(const Value: string);
    function GetDataSources: TxlAbstractDataSources;
    function GetRangeType: TxlRangeType;
    procedure AddDetail(DS: TxlAbstractDataSource);
    procedure DeleteDetail(DS: TxlAbstractDataSource);
    function GetMasterSourceName: string;
    procedure SetMasterSourceName(const Value: string);
    function GetArbitraryRange: boolean;
  protected
    //
    procedure SetAlias(const Value: string); virtual;
    function GetAlias: string; virtual;
    //
    procedure SetMasterSource(const Value: TxlAbstractDataSource);
    function CreateXLDataSet: TxlAbstractDataSet; virtual; abstract;
    //
    procedure Connect; virtual; abstract;
    procedure Disconnect; virtual; abstract;
    procedure ClearOptionItems; virtual;
    procedure MacroProcessing(const MacroType: TxlMacroType;
      const MacroName: string); virtual; abstract;
    // Template parsing
    procedure GetRangeInfo(var ARow, AColumn, ARowCount, AColCount: integer;
      var Formulas, RowCaptions: OLEVariant); virtual; abstract;
    procedure Parse; virtual;
    procedure ScanParsedCells(Formulas: OLEVariant); virtual; abstract;
    // Data transfer
    procedure PutNoRange; virtual; abstract;
    procedure PutRange; virtual; abstract;
    procedure PutRoot; virtual; abstract;
    // Options processing
    procedure OptionsProcessing; virtual; abstract;
    // DataSource build
    procedure Build; virtual;
    procedure BuildRoot; virtual;
    // Event callers
    {$IFNDEF XLR_VCL}
    procedure DoRelation;
    procedure DoRelationFilter(Sender: TxlAbstractDataSource); virtual;
    {$ENDIF XLR_VCL}
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arxl, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arxl0, Arxl1, Arxl2, Arxl3, Arxl4, Arxl5,
      Arxl6, Arxl7, Arxl8, Arxl9, Arg30: OLEVariant); virtual; abstract;
    procedure DoOnBeforeDataTransfer; virtual; abstract;
    procedure DoOnAfterDataTransfer; virtual; abstract;
    // Properties
    property Report: TxlAbstractReport read FReport;
    property DataSources: TxlAbstractDataSources read GetDataSources;
    property Details: TList read FDetails;
    {$IFDEF XLR_VCL}
    property XLDataSet: TxlAbstractDataSet read FxlDataSet;
    {$ELSE}
    property XLDataSet: TxlAbstractDataSet read FxlDataSet write FxlDataSet;
    {$ENDIF}
    property OptionFound: boolean read FOptionFound write FOptionFound;
    //
    property Cells: TxlAbstractCells read FCells;
    property Range: string read FRange write SetRange;
    property MacroBefore: string read FMacroBefore write FMacroBefore;
    property MacroAfter: string read FMacroAfter write FMacroAfter;
    property Enabled: boolean read FEnabled write FEnabled default true;
    property MasterSource: TxlAbstractDataSource read FMasterSource write SetMasterSource;
    property MasterSourceName: string read GetMasterSourceName write SetMasterSourceName;
    property Tag: integer read FTag write FTag;
    property AutoOpen: boolean read FAutoOpen write FAutoOpen;
    property AutoClose: boolean read FAutoClose write FAutoClose;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    //
    property Alias: string read GetAlias write SetAlias;
    property RangeType: TxlRangeType read GetRangeType;
    property ArbitraryRange: boolean read GetArbitraryRange;
    property Row: integer read FRow;
    property Column: integer read FColumn;
    property RowCount: integer read FRowCount;
    property ColCount: integer read FColCount;
  end;

{ TxlAbstractDataSources collection class }

  TxlAbstractDataSources = class(TCollection)
  private
    FReport: TxlAbstractReport;
    function GetItem(Index: integer): TxlAbstractDataSource;
    procedure SetItem(Index: integer; const Value: TxlAbstractDataSource);
  protected
    function GetAttrCount: Integer; override;
    function GetAttr(Index: Integer): string; override;
    function GetItemAttr(Index, ItemIndex: Integer): string; override;
    function GetOwner: TPersistent; override;
  public
    constructor Create(ItemClass: TCollectionItemClass; AReport: TComponent); virtual;
    function Add: TxlAbstractDataSource;
    property Items[Index: integer]: TxlAbstractDataSource read GetItem
      write SetItem; default;
    property Report: TxlAbstractReport read FReport;
  end;

{ TxlAbstractParameter }

  TxlAbstractParameter = class(TCollectionItem)
  private
    FName: string;
    FValue: Variant;
    function GetDateTime: TDateTime;
    procedure SetDateTime(const AValue: TDateTime);
    function GetInteger: Integer;
    procedure SetInteger(const AValue: Integer);
    function GetBoolean: boolean;
    function GetFloat: Double;
    function GetString: string;
    procedure SetBoolean(const AValue: boolean);
    procedure SetFloat(const AValue: Double);
    procedure SetString(const AValue: string);
    procedure SetName(const Value: string);
  public
    property AsDateTime: TDateTime read GetDateTime write SetDateTime;
    property AsInteger: Integer read GetInteger write SetInteger;
    property AsString: string read GetString write SetString;
    property AsFloat: Double read GetFloat write SetFloat;
    property AsBoolean: boolean read GetBoolean write SetBoolean;
  published
    property Name: string read FName write SetName;
    property Value: Variant read FValue write FValue;
  end;

{ TxlAbstractParameters }

  TxlAbstractParameters = class(TCollection)
  private
    FReport: TxlAbstractReport;
    function GetItem(Index: integer): TxlAbstractParameter;
    procedure SetItem(Index: integer; const Value: TxlAbstractParameter);
    function GetParamByName(Name: string): TxlAbstractParameter;
  protected
    function GetAttrCount: Integer; override;
    function GetAttr(Index: Integer): string; override;
    function GetItemAttr(Index, ItemIndex: Integer): string; override;
    function GetOwner: TPersistent; override;
    procedure Build; virtual; abstract;
  public
    constructor Create(ItemClass: TCollectionItemClass; AReport: TComponent); virtual;
    function Add: TxlAbstractParameter;
    property Items[Index: integer]: TxlAbstractParameter read GetItem
      write SetItem; default;
    property Report: TxlAbstractReport read FReport;
  end;

{ TxlAbstractReport class }

  // Report state
  TxlReportState = (rsNotactive, rsEdit, rsReport);
  // Event handlers
  TxlOnError = procedure(Sender: TObject; E: Exception; var Raised: boolean) of object;

  TxlAbstractReport = class(TComponent)
  private
    FDataSources: TxlAbstractDataSources;
    FParams: TxlAbstractParameters;
    FOptionItems: TxlOptionItemList;
    FState: TxlReportState;
    FMacroBefore: string;
    FMacroAfter: string;
    FRefreshParams: boolean;
    FOnError: TxlOnError;
    // OnProgress
    FProgressPos, FProgressMax: integer;
    // Properties Get/Set
    procedure SetDataSources(const Value: TxlAbstractDataSources);
    procedure SetParams(const Value: TxlAbstractParameters);
    function GetParamByName(Name: string): TxlAbstractParameter;
    function GetWorkbookOptionFound: boolean;
    function GetWorksheetsOptionFound: boolean;
  protected
    procedure Loaded; override;
    // Custom Datasources
    function CreateDataSources: TxlAbstractDataSources; virtual; abstract;
    // Custom Parameters
    function CreateParams: TxlAbstractParameters; virtual; abstract;
    // Events
    procedure DoOnError(E: Exception; var Raised: boolean); virtual;
    procedure DoOnBeforeBuild; virtual; abstract;
    procedure DoOnAfterBuild; virtual; abstract;
    procedure DoOnMacro(const MacroType: TxlMacroType; const MacroName: string;
      var Arg1, Arxl, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13,
      Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arxl0, Arxl1, Arxl2, Arxl3, Arxl4, Arxl5,
      Arxl6, Arxl7, Arxl8, Arxl9, Arg30: OLEVariant); virtual; abstract;
    // OnProgress upport
    procedure Progress; virtual;
    procedure DoOnProgress(const Position, Max: integer); virtual; abstract;
    //
    procedure Connect; virtual;
    procedure Disconnect; virtual;
    procedure BeforeBuild; virtual; abstract;
    procedure AfterBuild; virtual;  abstract;
    procedure MacroProcessing(const MacroType: TxlMacroType;
      const MacroName: string); virtual;  abstract;
    procedure Parse; virtual;  abstract;
    procedure Show(HandleException: boolean); virtual;  abstract;
    procedure RefreshParams(const ClearParams: boolean); virtual; abstract;
    procedure ErrorProcessing(E: Exception; var Raised: boolean); virtual;  abstract;
    procedure OptionsProcessing; virtual; abstract;
    procedure Report; overload; virtual;
    procedure Edit;
    // Properties
    property OptionItems: TxlOptionItemList read FOptionItems;
    property IsRefreshParams: boolean read FRefreshParams write FRefreshParams;
    property State: TxlReportState read FState write FState;
    property WorkbookOptionFound: boolean read GetWorkbookOptionFound;
    property WorksheetsOptionFound: boolean read GetWorksheetsOptionFound;
    property ProgressPos: integer read FProgressPos write FProgressPos;
    property ProgressMax: integer read FProgressMax write FProgressMax;
    //
    property DataSources: TxlAbstractDataSources read FDataSources write SetDataSources;
    property Params: TxlAbstractParameters read FParams write SetParams;
    property ParamByName[Name: string]: TxlAbstractParameter read GetParamByName;
    property MacroBefore: string read FMacroBefore write FMacroBefore;
    property MacroAfter: string read FMacroAfter write FMacroAfter;
    property OnError: TxlOnError read FOnError write FOnError;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    class function GetOptionMap: TxlOptionMap; virtual;
  end;

implementation

{ ExlReportError }

{$IFNDEF XLR_VCL}
constructor ExlReportError.CreateRes2(Ident, AErrorCode: Integer);
begin
  inherited CreateRes(Ident);
  FErrorCode := AErrorCode;
end;

constructor ExlReportError.CreateResFmt2(Ident, AErrorCode: Integer; const Args: array of const);
begin
  inherited CreateResFmt(Ident, Args);
  FErrorCode := AErrorCode;
end;
{$ENDIF XLR_VCL}

{ TxlAbstractDataSet }

constructor TxlAbstractDataSet.Create(ADataSource: TxlAbstractDataSource);
begin
  inherited Create;
  FFields := TStringList.Create;
  FFieldsType := TList.Create;
  FDataSource := ADataSource;
end;

destructor TxlAbstractDataSet.Destroy;
begin
  FFieldsType.Free;
  Fields.Free;
  inherited;
end;

procedure TxlAbstractDataSet.Connect;
var
  i: integer;
begin
  if Fields.Count = 0 then begin
    Fields.Clear;
    FFieldsType.Clear;
    GetFields;
    for i := 0 to Fields.Count - 1 do
      FFieldsType.Add(Pointer(xdNotSupported));
    GetFieldsType;
  end;
end;

procedure TxlAbstractDataSet.Disconnect(const IsClose: boolean);
begin
  if not ExternalDisconnect then begin
    if IsClose then
      Close;
    Fields.Clear;
  end;
end;

function TxlAbstractDataSet.Flags: DWORD;
begin
  Result := $0000;
end;

function TxlAbstractDataSet.FieldIndex(const FieldName: string): integer;
begin
  Result := Fields.IndexOf(FieldName);
end;

function TxlAbstractDataSet.FieldAsText(const Index: integer): string;
begin
  Result := '';
  case FieldType[Index] of
    xdInteger: Result := FieldAsString(Index);
    xdBoolean: Result := FieldAsString(Index);
    xdFloat: Result := Format('%e', [FieldAsFloat(Index)]);
    xdDateTime: Result := Format('%e', [FieldAsDateTime(Index)]);
    xdString: Result := FieldAsString(Index);
  end;
end;

function TxlAbstractDataSet.GetFieldType(Index: integer): TxlDataType;
begin
  Result := TxlDataType(FFieldsType.Items[Index]);
end;

procedure TxlAbstractDataSet.SetFieldType(Index: integer; const Value: TxlDataType);
begin
  FFieldsType.Items[Index] := Pointer(Value);
end;

{ TxlAbstractCell }

constructor TxlAbstractCell.Create(ADataSource: TxlAbstractDataSource);
begin
  inherited Create;
  FDataSource := ADataSource;
  FFieldIndex := -1;
end;

{$IFDEF XLR_PE}
function IsField(S, Alias, Field: string): boolean;
begin
  Result :=
    S = (delAttrValue + UpperCase(Alias) + delFldFormula + UpperCase(Field));
  Result := Result or
    (S = ('#' + UpperCase(Alias) + delFldFormula + UpperCase(Field)));
end;
{$ENDIF}

procedure TxlAbstractCell.SetFormula(const Value: string);
var
  i: integer;
  s: string;
begin
  FFormula := Value;
  if (Row = (DataSource.RowCount)) and (Column <> 1) then
    FCellType := ctSpecialRow
  else
    if Column = 1 then
      FCellType := ctSpecialColumn
    else
      if Value = '' then
        FCellType := ctEmpty
      else begin
        s := UpperCase(Formula);
        for i := 0 to DataSource.XLDataSet.Fields.Count - 1 do
          {$IFDEF XLR_PE}
          if IsField(s, DataSource.Alias, DataSource.XLDataSet.Fields[i]) then begin
          {$ELSE}
          if s = (delAttrValue + UpperCase(DataSource.Alias) + delFldFormula +
            UpperCase(DataSource.XLDataSet.Fields[i])) then begin
          {$ENDIF}
            FCellType := ctField;
            FFieldIndex := i;
            Break;
          end;
        if CellType <> ctField then
          FCellType := ctFormula;
      end;
end;

function TxlAbstractCell.GetDataType: TxlDataType;
begin
  Result := xdNotSupported;
  if CellType = ctField then
    Result := DataSource.XLDataSet.FieldType[FieldIndex];
end;

function TxlAbstractCell.GetString: string;
begin
  Result := '';
  case CellType of
    ctSpecialColumn: Result := DataSource.Alias + delFldFormula + IntToStr(Row);
    ctField: Result := DataSource.XLDataSet.FieldAsText(FieldIndex);
    ctSpecialRow: if not DataSource.Cells[Column - 1].OptionFound then
      Result := Formula;
  end;
  if pos('=' , Result) = 1 then
    Delete(Result, 1, 1);
end;

function TxlAbstractCell.GetFloat: double;
begin
  Result := 0;
  if CellType = ctField then
    Result := DataSource.XLDataSet.FieldAsFloat(FieldIndex);
end;

function TxlAbstractCell.GetBoolean: boolean;
begin
  Result := false;
  if CellType = ctField then
    Result := DataSource.XLDataSet.FieldAsBoolean(FieldIndex);
end;

function TxlAbstractCell.GetIsEmpty: boolean;
begin
  Result := false;
  if CellType = ctField then
    Result := DataSource.XLDataSet.FieldIsEmpty(FieldIndex);
end;

function TxlAbstractCell.GetVariant: OLEVariant;
begin
  Result := NULL;
  if CellType = ctField then
    if (DataSource.XLDataSet.FieldIsEmpty(FieldIndex)) and
      (DataSource.XLDataSet.FieldType[FieldIndex] = xdString) then
      Result := ''
    else
      Result := DataSource.XLDataSet.FieldAsOLEVariant(FieldIndex)
  else
    Result := Self.AsString;
end;

{ TxlAbstractCells }

constructor TxlAbstractCells.Create(ADataSource: TxlAbstractDataSource);
begin
  inherited Create;
  FDataSource := ADataSource;
end;

function TxlAbstractCells.GetItem(Index: integer): TxlAbstractCell;
begin
  Result := TxlAbstractCell(inherited Items[Index]);
end;

function TxlAbstractCells.Add: TxlAbstractCell;
begin
  Result := TxlAbstractCell.Create(DataSource);
  inherited Add(Result);
end;

function TxlAbstractCells.AddNewRow: TxlAbstractCell;
begin
  Result := Add;
  Result.FCellType := ctCR;
end;

procedure TxlAbstractCells.Clear;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Free;
  inherited;
end;

function TxlAbstractCells.FirstCellOfRow(const ARow: integer): TxlAbstractCell;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if Items[i].Row = ARow then begin
      Result := Items[i];
      Break;
    end;
end;

{ TxlAbstractParameter }

function TxlAbstractParameter.GetBoolean: boolean;
begin
  Result := Value;
end;

function TxlAbstractParameter.GetDateTime: TDateTime;
begin
  Result := Value;
end;

function TxlAbstractParameter.GetFloat: Double;
begin
  Result := Value;
end;

function TxlAbstractParameter.GetInteger: Integer;
begin
  Result := Value;
end;

function TxlAbstractParameter.GetString: string;
begin
  Result := Value;
end;

procedure TxlAbstractParameter.SetBoolean(const AValue: boolean);
begin
  Value := AValue;
end;

procedure TxlAbstractParameter.SetDateTime(const AValue: TDateTime);
begin
  Value := AValue;
end;

procedure TxlAbstractParameter.SetFloat(const AValue: Double);
begin
  Value := AValue;
end;

procedure TxlAbstractParameter.SetInteger(const AValue: Integer);
begin
  Value := AValue;
end;

procedure TxlAbstractParameter.SetString(const AValue: string);
begin
  Value := AValue;
end;

procedure TxlAbstractParameter.SetName(const Value: string);
var
  i: integer;
  p: TxlAbstractParameter;
begin
  if Trim(Value) <> '' then
    for i := 0 to Collection.Count - 1 do begin
      p := Collection.Items[i] as TxlAbstractParameter;
      if (p <> Self) and (UpperCase(p.Name) = UpperCase(Trim(Value))) then
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecParameterAlreadyExist, ecParameterAlreadyExist, [Value]);
        {$ELSE}
        raise ExlReportError.CreateResFmt(ecParameterAlreadyExist, [Value]);
        {$ENDIF XLR_VCL}
    end;
  FName := Trim(Value);
end;

{ TxlAbstractParameters }

constructor TxlAbstractParameters.Create(ItemClass: TCollectionItemClass;
  AReport: TComponent);
begin
  inherited Create(ItemClass);
  FReport := AReport as TxlAbstractReport;
end;

function TxlAbstractParameters.GetOwner: TPersistent;
begin
  Result := Report;
end;

function TxlAbstractParameters.GetAttr(Index: Integer): string;
begin
  if Index = 0 then
    Result := 'Parameter';
end;

function TxlAbstractParameters.GetAttrCount: Integer;
begin
  Result := 1;
end;

function TxlAbstractParameters.GetItemAttr(Index, ItemIndex: Integer): string;
begin
  case Index of
    0: Result := Items[ItemIndex].Name;
  end;
end;

function TxlAbstractParameters.Add: TxlAbstractParameter;
begin
  Result := TxlAbstractParameter(inherited Add);
end;

function TxlAbstractParameters.GetItem(Index: integer): TxlAbstractParameter;
begin
  Result := TxlAbstractParameter(inherited GetItem(Index));
end;

procedure TxlAbstractParameters.SetItem(Index: integer; const Value: TxlAbstractParameter);
begin
  inherited SetItem(Index, Value);
end;

function TxlAbstractParameters.GetParamByName(Name: string): TxlAbstractParameter;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if UpperCase(Items[i].Name) = UpperCase(Name) then
      Result := Items[i];
end;

{ TxlAbstractDataSource }

constructor TxlAbstractDataSource.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FReport := (ACollection as TxlAbstractDataSources).Report;
  FEnabled := true;
  FCells := TxlAbstractCells.Create(Self);
  FDetails := TList.Create;
  FAutoOpen := true;
end;

destructor TxlAbstractDataSource.Destroy;
var
  i: integer;
begin
  if Assigned(MasterSource) then
    MasterSource.DeleteDetail(Self);
  for i := 0 to Details.Count - 1 do
    TxlAbstractDataSource(Details.Items[i]).MasterSource := nil;
  Details.Free;
  Cells.Free;
  inherited;
end;

procedure TxlAbstractDataSource.ClearOptionItems;
var
  i, j: integer;
  DeleteList: TList;
begin
  DeleteList := TList.Create;
  try
    for i := Report.OptionItems.Count - 1 downto 0 do
      if Report.OptionItems.Items[i].Obj = Self then
        DeleteList.Add(Pointer(i));
    for i := 0 to DeleteList.Count - 1 do begin
      Report.OptionItems[Integer(DeleteList.Items[i])].Free;
      Report.OptionItems.Delete(Integer(DeleteList.Items[i]));
    end;
    DeleteList.Clear;
    for i := Report.OptionItems.Count - 1 downto 0 do
      for j := 0 to Cells.Count - 1 do
      if Report.OptionItems.Items[i].Obj = Cells[j] then
        DeleteList.Add(Pointer(i));
    for i := 0 to DeleteList.Count - 1 do begin
      Report.OptionItems[Integer(DeleteList.Items[i])].Free;
      Report.OptionItems.Delete(Integer(DeleteList.Items[i]));
    end;
  finally
    DeleteList.Free;
  end;
end;

procedure TxlAbstractDataSource.SetMasterSource(const Value: TxlAbstractDataSource);
begin
  if Assigned(MasterSource) then
    MasterSource.DeleteDetail(Self);
  FMasterSource := Value;
  if Assigned(Value) then
    Value.AddDetail(Self);
end;

function TxlAbstractDataSource.GetMasterSourceName: string;
begin
  Result := '';
  if Assigned(MasterSource) then
    Result := MasterSource.Alias;
end;

procedure TxlAbstractDataSource.SetMasterSourceName(const Value: string);
var
  i: integer;
  DS: TxlAbstractDataSource;
begin
  if not(csLoading in Report.ComponentState) then begin
    DS := nil;
    if Value <> '' then
      for i := 0 to Report.DataSources.Count - 1 do
        if (Report.DataSources[i] <> Self) and
          (UpperCase(Value) = UpperCase(Report.DataSources[i].Alias)) and
          (Report.DataSources[i].RangeType <> rtNoRange) then begin
            DS := Report.DataSources[i];
            Break;
          end;
    MasterSource := DS
  end
  else begin
    FMasterSourceName := Value;
  end;
end;

function TxlAbstractDataSource.GetAlias: string;
begin
  Result := FAlias;
end;

procedure TxlAbstractDataSource.SetAlias(const Value: string);
var
  i: integer;
begin
  if not IsValidName(Value) then
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateResFmt2(ecNameNotValid, ecNameNotValid, [Value]);
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecNameNotValid, [Value]);
    {$ENDIF XLR_VCL}
  if Value <> '' then
    for i := 0 to Report.DataSources.Count - 1 do
      if (UpperCase(Report.DataSources[i].Alias) = UpperCase(Trim(Value))) and
        (Report.DataSources[i].Index <> Index) then begin
        {$IFNDEF XLR_VCL}
        raise ExlReportError.CreateResFmt2(ecAliasAlreadyExists, ecAliasAlreadyExists, [Value]);
        {$ELSE}
        if csDesigning in Report.ComponentState then begin
          if Alias = '' then
            FAlias := 'Alias' + IntToStr(Index);
          MessageDlg(Format(LoadStr(ecAliasAlreadyExists), [Value]), mtError, [mbOk], 0);
          Exit;
        end
        else
          raise ExlReportError.CreateResFmt(ecAliasAlreadyExists, [Value]);
        {$ENDIF XLR_VCL}
    end;
  FAlias := Trim(Value);
end;

procedure TxlAbstractDataSource.SetRange(const Value: string);
var
  Allow: boolean;
  MsgStr: string;
begin
  Allow := true;
  MsgStr := LoadStr(msgConfirmRangePropertyChange);
  if (Range<>'') and (Value='') and Assigned(MasterSource) or (Details.Count > 0) then
    Allow := MessageDlg(MsgStr, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
  if Allow then
    FRange := Trim(Value);
end;

function TxlAbstractDataSource.GetDataSources: TxlAbstractDataSources;
begin
  Result := Collection as TxlAbstractDataSources;
end;

function TxlAbstractDataSource.GetRangeType: TxlRangeType;
begin
  if Range = '' then
    Result := rtNoRange
  else
    if not Assigned(MasterSource) then
      if Details.Count = 0 then
        Result := rtRange
      else
        Result := rtRangeRoot
    else
      if Details.Count = 0 then
        Result := rtRangeDetail
      else
        Result := rtRangeMaster;
end;

function TxlAbstractDataSource.GetArbitraryRange: boolean;
begin
  Result := RowCount > 1;
end;

procedure TxlAbstractDataSource.AddDetail(DS: TxlAbstractDataSource);
begin
  if Details.IndexOf(DS) = -1 then
    Details.Add(DS);
end;

procedure TxlAbstractDataSource.DeleteDetail(DS: TxlAbstractDataSource);
var Indx: integer;
begin
  Indx := Details.IndexOf(DS);
  if Indx <> -1 then
    Details.Delete(Indx);
end;

// Template parsing
procedure TxlAbstractDataSource.Parse;
var
  iRow, iColumn: integer;
  Cell: TxlAbstractCell;
  Formulas, Captions: OLEVariant;
begin
  Formulas := UnAssigned;
  Captions := Unassigned;
  Cells.Clear;
  // Get cells formulas
  GetRangeInfo(FRow, FColumn, FRowCount, FColCount, Formulas, Captions);
  // Check MasterRange bounds
  if Assigned(MasterSource) then
    if (Row < MasterSource.Row) or
       ((Row + RowCount) >= (MasterSource.Row + MasterSource.RowCount + 1)) or
       (Column < MasterSource.Column) or
       ((Column + ColCount) > (MasterSource.Column + MasterSource.ColCount)) then
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecIncorrectRangeFormat, ecIncorrectRangeFormat, [Range]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecIncorrectRangeFormat, [Range]);
      {$ENDIF XLR_VCL}
  // Parse formulas
  for iRow := 1 to RowCount do begin
    for iColumn := 1 to ColCount do begin
      Cell := Cells.Add;
      Cell.Row := iRow;
      Cell.Column := iColumn;
      if (not _VarIsEmpty(Captions)) and (VarArrayHighBound(Captions, 2) = ColCount) then
        if not(VarType(Captions[1, iColumn]) in [varEmpty, varNull, varError]) then
          Cell.RowCaption := Captions[1, iColumn];
      Cell.Formula := Formulas[iRow, iColumn];
    end;
    if iRow <> RowCount then
      Cells.AddNewRow;
  end;
  // Exclude special row
  if RowCount > 1 then
    Dec(FRowCount);
  //
  ScanParsedCells(Formulas);
end;

// DataSource Build
procedure TxlAbstractDataSource.Build;
begin
  if Enabled and Assigned(XLDataSet) then
    try
      Connect;
      DoOnBeforeDataTransfer;
      MacroProcessing(mtBefore, MacroBefore);
      if (AutoOpen) and (not XLDataSet.Active) then
        XLDataSet.Open;
      XLDataSet.Connect;
      if Details.Count = 0 then
        XLDataSet.DisableControls;
      if not Assigned(MasterSource) then
        XLDataSet.SetBookmark;
      Parse;
      // NoRange
      if RangeType = rtNoRange then
        PutNoRange
      // Range
      else begin
        PutRange;
      end;
      MacroProcessing(mtAfter, MacroAfter);
      DoOnAfterDataTransfer;
      OptionsProcessing;
    finally
      if not Assigned(MasterSource) then
        XLDataSet.GotoBookmark;
      if Details.Count = 0 then
        XLDataSet.EnableControls;
      XLDataSet.Disconnect(AutoClose);
      Disconnect;
      ClearOptionItems;
    end;
end;

// RootDataSource Build
procedure SortDetails(Source: TxlAbstractDataSource);
var i, j: integer;
    TmpDetails: TList;
    Src: TxlAbstractDataSource;
begin
  TmpDetails := TList.Create;
  for i := 0 to Source.Details.Count - 1 do begin
    Src := Source.Details[i];
    for j := i + 1 to Source.Details.Count - 1 do
      if Src.Row > TxlAbstractDataSource(Source.Details[j]).Row then
        Src := Source.Details[j];
    TmpDetails.Add(Src)
  end;
  Source.FDetails.Free;
  Source.FDetails := TmpDetails;
end;

procedure ConnectAndBeforeDataTransferRoot(Source: TxlAbstractDataSource);
var
  i: integer;
begin
  Source.Connect;
  Source.DoOnBeforeDataTransfer;
  Source.MacroProcessing(mtBefore, Source.MacroBefore);
  if (Source.AutoOpen) and (not Source.XLDataSet.Active) then
    Source.XLDataSet.Open;
  Source.XLDataSet.Connect;
  if Source.Details.Count = 0 then
    Source.XLDataSet.DisableControls;
  if not Assigned(Source.MasterSource) then
    Source.XLDataSet.SetBookmark;
  Source.Parse;
  for i := 0 to Source.Details.Count - 1 do begin
    {$IFNDEF XLR_VCL}
    if not Source.XLDataSet.Eof then
      TxlAbstractDataSource(Source.Details[i]).DoRelationFilter(Source);
    {$ENDIF XLR_VCL}
    ConnectAndBeforeDataTransferRoot(Source.Details[i]);
  end;
  SortDetails(Source);
end;

procedure AfterDataTransferRoot(Source: TxlAbstractDataSource);
var
  i: integer;
begin
  for i := 0 to Source.Details.Count - 1 do
    AfterDataTransferRoot(Source.Details[i]);
  Source.MacroProcessing(mtAfter, Source.MacroAfter);
  Source.DoOnAfterDataTransfer;
end;

procedure OptionsProcessingRoot(Source: TxlAbstractDataSource);
var
  i: integer;
begin
  for i := 0 to Source.Details.Count - 1 do
    OptionsProcessingRoot(Source.Details[i]);
  Source.OptionsProcessing;
end;

procedure DisconnectRoot(Source: TxlAbstractDataSource);
var
  i: integer;
begin
  for i := 0 to Source.Details.Count - 1 do
    DisconnectRoot(Source.Details[i]);
  if not Assigned(Source.MasterSource) then
    Source.XLDataSet.GotoBookmark;
  if Source.Details.Count = 0 then
    Source.XLDataSet.EnableControls;
  Source.XLDataSet.Disconnect(Source.AutoClose);
  Source.Disconnect;
  Source.ClearOptionItems;
end;

procedure TxlAbstractDataSource.BuildRoot;
begin
  if Enabled and Assigned(XLDataSet) then
    try
      ConnectAndBeforeDataTransferRoot(Self);
      PutRoot;
      AfterDataTransferRoot(Self);
      OptionsProcessingRoot(Self);
    finally
      DisconnectRoot(Self);
    end;
end;

{$IFNDEF XLR_VCL}
procedure TxlAbstractDataSource.DoRelation;
var
  i: integer;
begin
  if not XLDataSet.Eof then
    for i := 0 to Details.Count - 1 do
      TxlAbstractDataSource(Details[i]).DoRelationFilter(Self);
end;

procedure TxlAbstractDataSource.DoRelationFilter;
begin
// abstract stub
end;
{$ENDIF XLR_VCL}

{ TxlAbstractDataSources }

constructor TxlAbstractDataSources.Create(ItemClass: TCollectionItemClass;
  AReport: TComponent);
begin
  inherited Create(ItemClass);
  FReport := AReport as TxlAbstractReport;
end;

function TxlAbstractDataSources.GetItem(Index: integer): TxlAbstractDataSource;
begin
  Result := TxlAbstractDataSource(inherited GetItem(Index));
end;

procedure TxlAbstractDataSources.SetItem(Index: integer;
  const Value: TxlAbstractDataSource);
begin
  inherited SetItem(Index, Value);
end;

function TxlAbstractDataSources.GetOwner: TPersistent;
begin
  Result := Report;
end;

function TxlAbstractDataSources.GetAttrCount: Integer;
begin
  Result := 3;
end;

function TxlAbstractDataSources.GetAttr(Index: Integer): string;
begin
  case Index of
    0: Result := 'Alias';
    1: Result := 'Range';
    2: Result := 'MasterSource';
  end;
end;

function TxlAbstractDataSources.GetItemAttr(Index, ItemIndex: Integer): string;
begin
  case Index of
    0: Result := Items[ItemIndex].Alias;
    1: Result := Items[ItemIndex].Range;
    2: Result := Items[ItemIndex].MasterSourceName;
  end;
end;

function TxlAbstractDataSources.Add: TxlAbstractDataSource;
begin
  Result := TxlAbstractDataSource(inherited Add);
end;

{ TxlAbstractReport }

constructor TxlAbstractReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataSources := CreateDataSources;
  FParams := CreateParams;
  FOptionItems := TxlOptionItemList.Create(Self, GetOptionMap);
end;

destructor TxlAbstractReport.Destroy;
begin
  OptionItems.Free;
  FParams.Free;
  DataSources.Free;
  inherited Destroy;
end;

procedure TxlAbstractReport.Loaded;
var
  i: integer;
begin
  inherited;
  for i := 0 to DataSources.Count - 1 do
    DataSources[i].MasterSourceName := DataSources[i].FMasterSourceName;
end;

procedure TxlAbstractReport.SetDataSources(const Value: TxlAbstractDataSources);
begin
  DataSources.Assign(Value);
end;

procedure TxlAbstractReport.SetParams(const Value: TxlAbstractParameters);
begin
  FParams.Assign(Value);
end;

function TxlAbstractReport.GetParamByName(Name: string): TxlAbstractParameter;
begin
  Result := Params.GetParamByName(Name);
end;

function TxlAbstractReport.GetWorkbookOptionFound: boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to OptionItems.Count - 1 do
    if OptionItems.Items[i].xlObject = xoWorkbook then begin
      Result := true;
      Break;
    end;
end;

function TxlAbstractReport.GetWorksheetsOptionFound: boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to OptionItems.Count - 1 do
    if OptionItems.Items[i].xlObject = xoWorksheet then begin
      Result := true;
      Break;
    end;
end;

// Events
procedure TxlAbstractReport.DoOnError(E: Exception; var Raised: boolean);
begin
  if Assigned(OnError) then
    OnError(Self, E, Raised);
end;

procedure TxlAbstractReport.Progress;
begin
  Inc(FProgressPos);
  DoOnProgress(FProgressPos, FProgressMax);
end;

procedure TxlAbstractReport.Connect;
var
  i: integer;
begin
  OptionItems.Clear;
  for i := 0 to DataSources.Count - 1 do
    DataSources[i].FXLDataSet := DataSources[i].CreateXLDataSet;
end;

procedure TxlAbstractReport.Disconnect;
var
  i: integer;
begin
  for i := 0 to DataSources.Count - 1 do begin
    if Assigned(DataSources[i].XLDataSet) then
      DataSources[i].XLDataSet.Free;
    DataSources[i].FXLDataSet := nil;
  end;
  OptionItems.Clear;
end;

class function TxlAbstractReport.GetOptionMap: TxlOptionMap;
begin
  Result := nil;
end;

procedure TxlAbstractReport.Edit;
var
  Raised: boolean;
begin
  Raised := true;
  FState := rsEdit;
  try
    try
      Connect;
      if (csDesigning in ComponentState) and IsRefreshParams then
        RefreshParams(True);
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
    Disconnect;
    FState := rsNotActive;
  end;
end;

procedure TxlAbstractReport.Report;
var
  Raised: boolean;
  i: integer;
begin
  {$IFNDEF XLR_VCL}
  if State <> rsNotActive then
    Exit;
  {$ENDIF XLR_VCL}
  Raised := true;
  FState := rsReport;
  try
    try
      FProgressPos := -1;
      FProgressMax := 0;
      for i := 0 to DataSources.Count - 1 do
        if DataSources[i].RangeType in [rtNoRange, rtRange, rtRangeRoot] then
          Inc(FProgressMax);
      Inc(FProgressMax, 13);
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
      MacroProcessing(mtAfter, MacroAfter);
      Progress;
      DoOnAfterBuild;
      Progress;
      OptionsProcessing;
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
    Disconnect;
    DoOnProgress(0, 0);
    FState := rsNotActive;
  end;
end;

end.

