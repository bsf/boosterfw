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

unit xlcOPack;

{$I xlcDefs.inc}

interface

uses Classes, SysUtils, xlcUtils;

type

{ Forward declaration of OptionPack classes }

  TxlOption = class;
  TxlOptionClass = class of TxlOption;
  TxlOptionMap = class;
  TxlOptionItem = class;
  TxlOptionItemList = class;
  TxlOptionPackage = class;

{ Additional OptionPack types }

  TxlObject = (xoWorkbook, xoWorksheet, xoRange, xoColumn);
  TxlObjectSet = set of TxlObject;
  TxlOptionPriority = $00..$FF;
  TxlPriorityArray = array [TxlObject] of TxlOptionPriority;
  TxlOptionNamesArray = array [TxlObject] of string;
  TxlRangeType = (rtNoRange, rtRange, rtRangeRoot, rtRangeMaster,
    rtRangeDetail, rtRangeArbitrary);
  TxlRangeTypeSet = set of TxlRangeType;

{ Code generation and passing parameters support }

  {$IFDEF XLR_BCB}
  IxlUnknown = OLEVariant;
  {$ELSE}
  IxlUnknown = IUnknown;
  {$ENDIF}

  TxlOptionArgs = OLEVariant;

{ Option class }

  TxlSpecialRowAction = (saAbsoluteDelete, saNoDelete, saDeleteIsEmpty, saCompleteDelete);
  TxlSpecialRowActions = set of TxlSpecialRowAction;

  TxlOption = class(TObject)
  private
    FMap: TxlOptionMap;
    FParent: TxlOption;
    FChild: TxlOption;
    FName: string;
    FxlObjects: TxlObjectSet;
    FRanges: TxlRangeTypeSet;
    FPriority: TxlPriorityArray;
    FLinkedOptions: TxlOptionNamesArray;
    FLibraryCode: string;
    FDeleteSpecialRow: TxlSpecialRowAction;
    FRefCount: integer;
    FPackage: TxlOptionPackage;
    function GetPriority(Index: TxlObject): TxlOptionPriority;
    function GetLinkedOptions(Index: TxlObject): string;
  protected
    procedure GetOptionInfo(var AName: string; var AxlObjects: TxlObjectSet;
      var ASupportedRanges: TxlRangeTypeSet; var APriorityArr: TxlPriorityArray;
      var ALinkedOptions: TxlOptionNamesArray; var ALibraryCode: string;
      var ADeleteSpecialRow: TxlSpecialRowAction); virtual; abstract;
    function GetModuleLevelCode: string; virtual; abstract;
    procedure InitArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); virtual; abstract;
    procedure DoItem(Item: TxlOptionItem; var Args: TxlOptionArgs); virtual; abstract;
    procedure DoneArgs(Item: TxlOptionItem; var Args: TxlOptionArgs); virtual; abstract;
    procedure DoOption(Item: TxlOptionItem; var Args: TxlOptionArgs);
  public
    constructor Create(APackage: TxlOptionPackage); virtual;
    destructor Destroy; override;
    function Visible: boolean; virtual;
    property Package: TxlOptionPackage read FPackage;
    property Map: TxlOptionMap read FMap;
    property Name: string read FName;
    property LibraryCode: string read FLibraryCode;
    property xlObjects: TxlObjectSet read FxlObjects;
    property SupportedRanges: TxlRangeTypeSet read FRanges;
    property Priority[Index: TxlObject]: TxlOptionPriority read GetPriority;
    property LinkedOptions[Index: TxlObject]: string read GetLinkedOptions;
    property SpecialRowAction: TxlSpecialRowAction read FDeleteSpecialRow
      default saDeleteIsEmpty;
  end;

{ Engine Option Map }

  TxlOptionMap = class(TStringList)
  private
    FPackages: TStrings;
    function GetLibraryCode: string;
    function GetOption(Name: string): TxlOption;
    function GetModuleLevelCode: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterOptions(Options: array of TClass); overload;
    procedure RegisterOptions(Package: TxlOptionPackage; Options: array of TClass); overload;
    procedure UnRegisterOptions(Options: array of TClass);
    function IndexOfClass(AClass: TClass): integer;
    property LibraryCode: string read GetLibraryCode;
    property ModuleLevelCode: string read GetModuleLevelCode;
    property Options[Name: string]: TxlOption read GetOption;
    property Packages: TStrings read FPackages;
  end;

{ Instance option item }

  TxlOptionItem = class(TObject)
  private
    FList: TxlOptionItemList;
    FOption: TxlOption;
    FParams: TStrings;
    FxlObject: TxlObject;
    FObj: TObject;
    FIUnk: IxlUnknown;
    FEnabled: boolean;
    procedure DoOption(var Args: TxlOptionArgs);
    procedure SetEnabled(const Value: boolean);
  public
    constructor Create(AList: TxlOptionItemList; AOption: TxlOption;
      const AxlObject: TxlObject); virtual;
    destructor Destroy; override;
    function ParamExists(const ParamName: string): boolean;
    function ParamAsInteger(const ParamName: string): integer;
    function ParamAsString(const ParamName: string): string;
    property List: TxlOptionItemList read FList;
    property Option: TxlOption read FOption;
    property Params: TStrings read FParams;
    property xlObject: TxlObject read FxlObject;
    property Obj: TObject read FObj write FObj;
    property IUnk: IxlUnknown read FIUnk write FIUnk;
    property Enabled: boolean read FEnabled write SetEnabled default true;
  end;

{ Instance option item list }

  TxlOptionItemList = class(TList)
  private
    FOwner: TObject;
    FMap: TxlOptionMap;
    function GetItems(AObj: TObject; AIUnk: IUnknown; AOption: TxlOption;
      AxlObject: TxlObject): TxlOptionItem;
    function GetItem(Index: integer): TxlOptionItem;
  public
    constructor Create(AOwner: TObject; AMap: TxlOptionMap); virtual;
    procedure Clear; override;
    //
    procedure DoOptions(AObj: TObject; AxlObjects: TxlObjectSet; var Args: TxlOptionArgs);
    //
    function AddItem(AObj: TObject; AIUnk: IxlUnknown; const AOptionStr: string;
      const AxlObject: TxlObject): TxlOptionItem;
    //
    function ParseOptionsStr(AObj: TObject; AIUnk: IxlUnknown; AxlObject: TxlObject;
      const OptionsStr: string): boolean;
    function ParseOptionsStr2(AObj: TObject; AIUnk: IxlUnknown; AxlObject: TxlObject;
      const OptionsStr: string; var DeleteSpecialRow: TxlSpecialRowAction;
      var OnlyFormula: string): boolean;
    //
    procedure LinkedItemsOfObj(Item: TxlOptionItem; List: TList);
    procedure LinkedItemsOfNames(Item: TxlOptionItem; const ANames: string;
      const AxlObjects: TxlObjectSet; IncludeSameColumn: boolean; List: TList);
    //
    function ExistsOfxlObj(AxlObjects: TxlObjectSet;
      OptionClasses: array of TClass): boolean;
    function ExistsOfObj(Obj: TObject; AxlObject: TxlObject;
      OptionClasses: array of TClass): boolean;
    function ExistsOfIUnk(IUnk: IxlUnknown; AxlObject: TxlObject;
      OptionClasses: array of TClass): boolean;
    //
    property Owner: TObject read FOwner;
    property Map: TxlOptionMap read FMap;
    property Items[Index: integer]: TxlOptionItem read GetItem; default;
    property ItemsOf[Obj: TObject; IUnk: IUnknown; Option: TxlOption; AxlObject:
      TxlObject]: TxlOptionItem read GetItems;
  end;

{ XL Report Option Package class }

  TxlOptionPackage = class(TComponent)
  private
    FReportClass: TClass;
    FOptionClasses: TList;
    FAuthor: string;
    FVersion: string;
    FName: string;
    function GetAbout: string;
    procedure SetAbout(const Value: string);
  protected
    procedure GetPackageInfo(var AReportClass: TClass;
      var AName, AAuthor, AVersion: string); virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddOptionClasses(Arr: array of TClass);
    property ReportClass: TClass read FReportClass;
    property OptionClasses: TList read FOptionClasses;
    property PackageAuthor: string read FAuthor;
    property PackageVersion: string read FVersion;
    property PackageName: string read FName;
  published
    property About: string read GetAbout write SetAbout;
  end;

const

{ Range type predefined sets }

  rtAllRanges: TxlRangeTypeSet = [rtRange, rtRangeRoot, rtRangeMaster, rtRangeDetail];
  rtRoots: TxlRangeTypeSet = [rtRange, rtRangeRoot];
  rtCompleteRanges: TxlRangeTypeSet = [rtRange, rtRangeDetail];
  rtMasters: TxlRangeTypeSet = [rtRangeRoot, rtRangeMaster];

{ Option priority }

  opReservedHighest: TxlOptionPriority = $00;
  opCriticalHighest: TxlOptionPriority = $10;
  opHighest: TxlOptionPriority = $20;
  opHigher: TxlOptionPriority = $40;
  opNormal: TxlOptionPriority = $80;
  opLower: TxlOptionPriority = $A0;
  opLowest: TxlOptionPriority = $D0;
  opCriticalLowest: TxlOptionPriority = $F0;
  opReservedLowest: TxlOptionPriority = $FF;

{ Service Option prefix }

  opSvc = 'xlr_';

{ Delimiters }

  delOption = ';';
  delAttr = '\';
  delAttrValue = '=';
  delFldFormula = '_';

{ Predefined parameter values }

  xlrTrue = 'TRUE';
  xlrFalse = 'FALSE';
  xlrOn = 'ON';
  xlrOff = 'OFF';

{$I xlcMsg.inc}

implementation

{$R xlcMsg.res}

uses xlcClasses;

{ TxlOption }

constructor TxlOption.Create(APackage: TxlOptionPackage);
var
  i: TxlObject;
begin
  inherited Create;
  FPackage := APackage;
  for i := low(TxlObject) to high(TxlObject) do begin
    FPriority[i] := opNormal;
    FLinkedOptions[i] := '';
  end;
  FDeleteSpecialRow := saDeleteIsEmpty;
  GetOptionInfo(FName, FxlObjects, FRanges, FPriority, FLinkedOptions, FLibraryCode,
    FDeleteSpecialRow);
  if FxlObjects * [xoRange, xoColumn] = [] then
    FRanges := [];
  FName := UpperCase(FName);
  for i := low(TxlObject) to high(TxlObject) do begin
    FLinkedOptions[i] := delOption + Trim(UpperCase(FLinkedOptions[i]));
    if FLinkedOptions[i] <> '' then
      if FLinkedOptions[i][Length(FLinkedOptions[i])] <> delOption then
        FLinkedOptions[i] := FLinkedOptions[i] + delOption;
  end;
end;

destructor TxlOption.Destroy;
begin
  if Assigned(FChild) then
    FChild.FParent := FParent;
  if Assigned(FParent) then
    FParent.FChild := FChild;
  inherited;
end;

procedure TxlOption.DoOption(Item: TxlOptionItem; var Args: TxlOptionArgs);
begin
  InitArgs(Item, Args);
  try
    DoItem(Item, Args);
  finally
    DoneArgs(Item, Args);
    Item.Enabled := false;
  end;
end;

{ TxlOptionsMap }

constructor TxlOptionMap.Create;
begin
  inherited;
  FPackages := TStringList.Create;
end;

destructor TxlOptionMap.Destroy;
begin
  FPackages.Free;
  inherited;
end;

function TxlOptionMap.GetLibraryCode: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    if (Objects[i] as txlOption).LibraryCode <> '' then
      if Result <> '' then
        Result := Result + #13#13 + (Objects[i] as txlOption).LibraryCode
      else
        Result := (Objects[i] as txlOption).LibraryCode;
end;

function TxlOptionMap.GetModuleLevelCode: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    if (Objects[i] as txlOption).GetModuleLevelCode <> '' then
      if Result <> '' then
        Result := Result + #13#13 + (Objects[i] as txlOption).GetModuleLevelCode
      else
        Result := (Objects[i] as txlOption).GetModuleLevelCode;
end;

function TxlOptionMap.GetOption(Name: string): TxlOption;
var
  Indx: integer;
begin
  Result := nil;
  Indx := IndexOf(Name);
  if Indx <> - 1 then
    Result := Objects[Indx] as TxlOption;
end;

function TxlOptionMap.IndexOfClass(AClass: TClass): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if Objects[i].ClassType = AClass then begin
      Result := i;
      Break;
    end;
end;

procedure TxlOptionMap.RegisterOptions(Package: TxlOptionPackage; Options: array of TClass);
var
  Option: TxlOption;
  i, Indx: integer;
  Allow: boolean;
begin
  for i := low(Options) to high(Options) do begin
    Indx := IndexOfClass(Options[i]);
    if Indx = -1 then begin
      Option := TxlOptionClass(Options[i]).Create(Package);
      if Option.Name <> '' then begin
        Allow := false;
        Indx := IndexOf(Option.Name);
        if Indx = -1 then
          Allow := true
        else
          if Option.ClassParent = Objects[Indx].ClassType then begin
            Option.FParent := Objects[Indx] as TxlOption;
            (Objects[Indx] as TxlOption).FChild := Option;
            Delete(Indx);
            Allow := true;
          end;
        if Allow then begin
          AddObject(Option.Name, Option);
          Option.FRefCount := 1;
          Option.FMap := Self;
        end;
      end
      else
        Option.Free;
    end
    else begin
      Inc((Objects[Indx] as TxlOption).FRefCount);
      (Objects[Indx] as TxlOption).FPackage := Package;
    end;
  end;
end;

procedure TxlOptionMap.RegisterOptions(Options: array of TClass);
begin
  RegisterOptions(Packages.Objects[0] as TxlOptionPackage, Options);
end;

procedure TxlOptionMap.UnRegisterOptions(Options: array of TClass);
var
  Opt: TxlOption;
  i, Indx: integer;
begin
  for i := low(Options) to high(Options) do begin
    Indx := IndexOfClass(Options[i]);
    if Indx <> -1 then begin
      Opt := Objects[Indx] as TxlOption;
      Dec(Opt.FRefCount);
      if Opt.FRefCount = 0 then begin
        Delete(Indx);
        if Assigned(Opt.FParent) then begin
          AddObject(Opt.FParent.Name, Opt.FParent);
          Opt.FParent.FChild := nil;
          Opt.FParent := nil;
        end;
        Opt.Free;
      end;
    end;
  end;
end;

function TxlOption.GetLinkedOptions(Index: TxlObject): string;
begin
  Result := FLinkedOptions[Index]; 
end;

function TxlOption.GetPriority(Index: TxlObject): TxlOptionPriority;
begin
  Result := FPriority[Index];
end;

function TxlOption.Visible: boolean;
begin
  Result := true;
end;

{ TxlOptionItem }

constructor TxlOptionItem.Create(AList: TxlOptionItemList; AOption: TxlOption;
  const AxlObject: TxlObject);
begin
  inherited Create;
  FList := AList;
  FOption := AOption;
  FxlObject := AxlObject;
  FParams := TStringList.Create;
  FEnabled := true;
end;

destructor TxlOptionItem.Destroy;
begin
  _Clear(FIUnk);
  FParams.Free;
  inherited;
end;

procedure TxlOptionItem.DoOption(var Args: TxlOptionArgs);
begin
  Option.DoOption(Self, Args);
  Enabled := false;
end;

function TxlOptionItem.ParamAsInteger(const ParamName: string): integer;
var
  p: string;
begin
  p := UpperCase(Trim(ParamName));
  if not ParamExists(p) then
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateResFmt2(ecOptionParameterNotFound, ecOptionParameterNotFound, [ParamName]);
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecOptionParameterNotFound, [ParamName]);
    {$ENDIF}
  try
    Result := StrToInt(Params.Values[p]);
  except
    on E: Exception do
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecOptionParameterValueIncorrectType, ecOptionParameterValueIncorrectType, [ParamName]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecOptionParameterValueIncorrectType, [ParamName]);
      {$ENDIF}
  end;
end;

function TxlOptionItem.ParamAsString(const ParamName: string): string;
var
  p: string;
begin
  Result := '';
  p := UpperCase(Trim(ParamName));
  if not ParamExists(p) then
    {$IFNDEF XLR_VCL}
    raise ExlReportError.CreateResFmt2(ecOptionParameterNotFound, ecOptionParameterNotFound, [ParamName]);
    {$ELSE}
    raise ExlReportError.CreateResFmt(ecOptionParameterNotFound, [ParamName]);
    {$ENDIF}
  try
    Result := Params.Values[p];
  except
    on E: Exception do
      {$IFNDEF XLR_VCL}
      raise ExlReportError.CreateResFmt2(ecOptionParameterValueIncorrectType, ecOptionParameterValueIncorrectType, [ParamName]);
      {$ELSE}
      raise ExlReportError.CreateResFmt(ecOptionParameterValueIncorrectType, [ParamName]);
      {$ENDIF}
  end;
end;

function TxlOptionItem.ParamExists(const ParamName: string): boolean;
var
  i: integer;
  p, s: string;
begin
  Result := false;
  p := UpperCase(Trim(ParamName));
  if (Trim(Params.Text) <> '') and (p <> '') then
    for i := 0 to Params.Count - 1 do begin
      s := Trim(Params[i]);
      Result := Pos(p + ' ', s) = 1;
      Result := Result or (Pos(p + delAttr, s) = 1);
      Result := Result or (Pos(p + delAttrValue, s) = 1);
      Result := Result or (Pos(p + delOption, s) = 1);
      Result := Result or ((Pos(p, s) = 1) and (p = s));
      if Result then
        Break;
    end;
end;

procedure TxlOptionItem.SetEnabled(const Value: boolean);
begin
  FEnabled := Value;
end;

{ TxlOptionItemList }

constructor TxlOptionItemList.Create(AOwner: TObject; AMap: TxlOptionMap);
begin
  inherited Create;
  FOwner := AOwner;
  FMap := AMap;
end;

procedure TxlOptionItemList.Clear;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    TxlOptionItem(Items[i]).Free;
  inherited;
end;

procedure TxlOptionItemList.DoOptions(AObj: TObject; AxlObjects: TxlObjectSet;
  var Args: TxlOptionArgs);
var
  i: integer;
  Item: TxlOptionItem;
  Allow: boolean;
  Source: TxlAbstractDataSource;
begin
  // according to priority
  for i := 0 to Count - 1 do begin
    Item := TxlOptionItem(inherited Items[i]);
    Allow := (Item.Obj = AObj) and (Item.xlObject in AxlObjects);
    if Item.xlObject = xoColumn then
      Allow := (TxlAbstractCell(Item.Obj).DataSource = AObj) and
        (Item.xlObject in AxlObjects);
    if Allow and Item.Enabled then
      // Check range type
      if Item.xlObject in [xoRange, xoColumn] then begin
        if Item.xlObject = xoRange then
          Source := Item.Obj as TxlAbstractDataSource
        else
          Source := (Item.Obj as TxlAbstractCell).DataSource;
        Allow := Source.RangeType in Item.Option.SupportedRanges;
        if Source.ArbitraryRange then
          Allow := Allow and (rtRangeArbitrary in Item.Option.SupportedRanges);
        if Allow then
          Item.DoOption(Args)
        else
          Item.Enabled := false;
      end
      else
        Item.DoOption(Args);
  end;
end;

function TxlOptionItemList.GetItems(AObj: TObject; AIUnk: IUnknown; AOption: TxlOption;
  AxlObject: TxlObject): TxlOptionItem;
var
  i: integer;
  Item: TxlOptionItem;
begin
  Result := nil;
  for i := 0 to Count -1 do begin
    Item := TxlOptionItem(inherited Items[i]);
    if (Item.Obj = AObj) and (Item.xlObject = AxlObject) and _EqualIntf(Item.IUnk, AIUnk) and
      (Item.Option = AOption) then begin
        Result := Item;
        break;
    end;
  end;
end;

function TxlOptionItemList.GetItem(Index: integer): TxlOptionItem;
begin
  Result := TxlOptionItem(inherited Items[Index]);
end;

function TxlOptionItemList.AddItem(AObj: TObject; AIUnk: IxlUnknown;
  const AOptionStr: string; const AxlObject: TxlObject): TxlOptionItem;
var
  Item: TxlOptionItem;
  i, InsertIndex: integer;
  APriority: TxlOptionPriority;
  OptionName, OptionParams, Param, ParamName, ParamValue: string;
  Option: TxlOption;
begin
  Result := nil;
  OptionParams := AOptionStr;
  OptionName := UpperCase( CutSubString(delAttr, OptionParams) ) ;
  Option := Map.Options[OptionName];
  if Assigned(Option) and (AxlObject in Option.xlObjects) then begin
    Item := ItemsOf[AObj, AIUnk, Option, AxlObject];
    if not Assigned(Item) then
    begin
      APriority := Option.Priority[AxlObject];
      InsertIndex := -1;
      for i := 0 to Self.Count - 1 do begin
        Item := TxlOptionItem(inherited Items[i]);
        if (Item.Obj = AObj) and (Item.xlObject = AxlObject) then
          if APriority < Item.Option.Priority[AxlObject] then begin
            InsertIndex := i;
            break;
          end;
        if (Item.xlObject = xoColumn) and (AxlObject = xoRange) then
          if (APriority < Item.Option.Priority[xoColumn]) then begin
            InsertIndex := i;
            break;
          end;
        if (Item.xlObject = xoColumn) and (AxlObject = xoColumn) then
          if (APriority < Item.Option.Priority[xoColumn]) then begin
            InsertIndex := i;
            break;
          end;
      end;
      Item := TxlOptionItem.Create(Self, Option, AxlObject);
      Item.Obj := AObj;
      Item.IUnk := AIUnk;
      Param := CutSubString(delAttr, OptionParams);
      while (Param <> '') or (OptionParams <> '') do begin
        if Param <> '' then begin
          ParamName := UpperCase( CutSubString(delAttrValue, Param) );
          ParamValue := Param;
          Param := IIF(ParamValue = '', ParamName, ParamName + delAttrValue + ParamValue);
          Item.Params.Add(Param);
          Param := CutSubString(delAttr, OptionParams);
        end;
      end;
      if InsertIndex = -1 then
        Self.Add(Item)
      else
        Self.Insert(InsertIndex, Item);
      Result := Item;
    end;
  end;
end;

function TxlOptionItemList.ExistsOfxlObj(AxlObjects: TxlObjectSet;
  OptionClasses: array of TClass): boolean;
var
  Item: TxlOptionItem;
  i, j, ExistsCount: integer;
begin
  ExistsCount := Low(OptionClasses);
  for j := Low(OptionClasses) to High(OptionClasses) do begin
    for i := 0 to Count - 1 do begin
      Item := TxlOptionItem(inherited Items[i]);
      if (Item.xlObject in AxlObjects) and
        (OptionClasses[j] = Item.Option.ClassType) then begin
        Inc(ExistsCount);
        Break;
      end;
    end;
  end;
  Result := High(OptionClasses) = (ExistsCount - 1);
end;

function TxlOptionItemList.ExistsOfObj(Obj: TObject; AxlObject: TxlObject;
  OptionClasses: array of TClass): boolean;
var
  Item: TxlOptionItem;
  i, j, ExistsCount: integer;
begin
  ExistsCount := Low(OptionClasses);
  for j := Low(OptionClasses) to High(OptionClasses) do begin
    for i := 0 to Count - 1 do begin
      Item := TxlOptionItem(inherited Items[i]);
      if (Obj = Item.Obj) and (Item.xlObject = AxlObject) and
        (OptionClasses[j] = Item.Option.ClassType) then begin
        Inc(ExistsCount);
        Break;
      end;
    end;
  end;
  Result := High(OptionClasses) = (ExistsCount - 1);
end;

function TxlOptionItemList.ExistsOfIUnk(IUnk: IxlUnknown; AxlObject: TxlObject;
  OptionClasses: array of TClass): boolean;
var
  Item: TxlOptionItem;
  i, j, ExistsCount: integer;
begin
  ExistsCount := Low(OptionClasses);
  for j := Low(OptionClasses) to High(OptionClasses) do begin
    for i := 0 to Count - 1 do begin
      Item := TxlOptionItem(inherited Items[i]);
      if _EqualIntf(IUnk, Item.IUnk) and (Item.xlObject = AxlObject) and
        (OptionClasses[j] = Item.Option.ClassType) then begin
        Inc(ExistsCount);
        Break;
      end;
    end;
  end;
  Result := High(OptionClasses) = (ExistsCount - 1);
end;

function TxlOptionItemList.ParseOptionsStr(AObj: TObject; AIUnk: IxlUnknown;
  AxlObject: TxlObject; const OptionsStr: string): boolean;
var
  s, Opt: string;
begin
  Result := false;
  s := Trim(OptionsStr);
  Opt := CutSubString(';', s);
  while (Opt <> '') or (s <> '') do begin
    if Opt <> '' then
      Result := Assigned( AddItem(AObj, AIUnk, Opt, AxlObject) ) or Result;
    Opt := CutSubString(';', s);
  end;
end;                                    

function TxlOptionItemList.ParseOptionsStr2(AObj: TObject; AIUnk: IxlUnknown;
  AxlObject: TxlObject; const OptionsStr: string;
  var DeleteSpecialRow: TxlSpecialRowAction; var OnlyFormula: string): boolean;
var
  s, Opt: string;
  Item: TxlOptionItem;
  Actions: TxlSpecialRowActions;
begin
  Result := false;
  s := Trim(OptionsStr);
  OnlyFormula := '';
  Opt := CutSubString(';', s);
  Actions := [saDeleteIsEmpty];
  while (Opt <> '') or (s <> '') do begin
    if Opt <> '' then begin
      Item := AddItem(AObj, AIUnk, Opt, AxlObject);
      if Assigned(Item) then begin
        Actions := Actions + [Item.Option.SpecialRowAction];
        Result := true;
      end
      else
        OnlyFormula := OnlyFormula + Opt;
    end;
    Opt := CutSubString(';', s);
  end;
  if saAbsoluteDelete in Actions then
    DeleteSpecialRow := saAbsoluteDelete
  else
    if saNoDelete in Actions then
      DeleteSpecialRow := saNoDelete
    else
      DeleteSpecialRow := saDeleteIsEmpty;
  if saCompleteDelete in Actions then
    DeleteSpecialRow := saCompleteDelete;
end;

procedure TxlOptionItemList.LinkedItemsOfObj(Item: TxlOptionItem; List: TList);
var
  i: integer;
begin
  if Assigned(List) then
    for i := 0 to Count - 1 do
      if (Item <> Items[i]) and (Item.Obj = Items[i].Obj) and Items[i].Enabled then
        List.Add(Items[i]);
end;

procedure TxlOptionItemList.LinkedItemsOfNames(Item: TxlOptionItem; const ANames: string;
  const AxlObjects: TxlObjectSet; IncludeSameColumn: boolean; List: TList);
var
  i: integer;
  Allow: boolean;
begin
  if Assigned(List) and (ANames<>'') then
    for i := 0 to Count - 1 do
      if (Item <> Items[i]) and Items[i].Enabled and
        ( ([Items[i].xlObject] * AxlObjects <> [])) and
        (pos(delOption + Items[i].Option.Name + delOption,
        delOption + ANames + delOption) > 0) then
      begin
        Allow := false;
        case Item.xlObject of
          xoWorkbook, xoWorksheet:
            Allow := Item.Obj = Items[i].Obj;
          xoRange:
            begin
              if xoColumn in AxlObjects then
                Allow := (Items[i].xlObject = xoColumn) and
                  ((Items[i].Obj as TxlAbstractCell).DataSource = Item.Obj)
              else
                Allow := Item.Obj = Items[i].Obj;
            end;
          xoColumn:
            begin
              Allow := (Items[i].Obj = Item.Obj) and IncludeSameColumn;
              if not Allow then
                Allow := (Items[i].xlObject = xoColumn) and
                  ((Items[i].Obj as TxlAbstractCell).DataSource =
                  (Item.Obj as TxlAbstractCell).DataSource);
              if not Allow then
                Allow := (xoRange in AxlObjects) and
                  (Items[i].Obj = (Item.Obj as TxlAbstractCell).DataSource);
            end;
        end;
        if Allow then
          List.Add(Items[i]);
      end;
end;

{ TxlOptionPackage }

constructor TxlOptionPackage.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited;
  FOptionClasses := TList.Create;
  GetPackageInfo(FReportClass, FName, FAuthor, FVersion);
  for i := 0 to FOptionClasses.Count - 1 do
    TxlAbstractReportClass(FReportClass).GetOptionMap.
      RegisterOptions(Self, [TxlOptionClass(FOptionClasses.Items[i])]);
  TxlAbstractReportClass(FReportClass).GetOptionMap.Packages.AddObject(PackageName, Self);
end;

destructor TxlOptionPackage.Destroy;
var
  i: integer;
begin
  for i := 0 to FOptionClasses.Count - 1 do
    TxlAbstractReportClass(FReportClass).GetOptionMap.
      UnRegisterOptions([TxlOptionClass(FOptionClasses.Items[i])]);
  FOptionClasses.Free;
  i := TxlAbstractReportClass(FReportClass).GetOptionMap.Packages.IndexOfObject(Self);
  if i <> -1 then
    TxlAbstractReportClass(FReportClass).GetOptionMap.Packages.Delete(i);
  inherited;
end;

function TxlOptionPackage.GetAbout: string;
begin
  Result := PackageName + ' ' + PackageVersion + '   - Copyright © ' + PackageAuthor;
end;

procedure TxlOptionPackage.AddOptionClasses(Arr: array of TClass);
var
  i: integer;
begin
  for i := Low(Arr) to High(Arr) do
    OptionClasses.Add(Arr[i]);
end;

procedure TxlOptionPackage.SetAbout(const Value: string);
begin
// property set stub
end;

end.


