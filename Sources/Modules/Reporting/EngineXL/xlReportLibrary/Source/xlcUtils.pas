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

unit xlcUtils;

{$I xlcDefs.inc}

interface

uses Classes, SysUtils, Windows, Clipbrd, ComObj,
  {$IFDEF XLR_VCL4}
    OleCtrls,
  {$ENDIF}
  {$IFDEF XLR_VCL6}
    Variants,
  {$ENDIF}
  {$IFDEF XLR_VCL7}
    Variants,
  {$ENDIF}
  ActiveX;

{ Compatibility }

{$IFDEF XLR_BCB}
  function _Assigned(Intf: OLEvariant): boolean;
  procedure _Clear(var Intf: OLEVariant);
{$ELSE}
  function _Assigned(Intf: IUnknown): boolean;
  procedure _Clear(var Intf);
{$ENDIF XLR_BCB}

function _EqualIntf(Intf1, Intf2: IUnknown): boolean;

{ Delphi 6 wrappers }

function _VarIsEmpty(const V: Variant): Boolean;
function _VarIsEmptyParam(const V: Variant): Boolean;
function _VarIsNothing(const V: Variant): Boolean;
function _VarIsDispatch(const V: Variant): Boolean;
function _GetActiveOleObject(const ClassName: string): IDispatch;
function _CreateOleObject(const ClassName: string): IDispatch;
function _GetActiveIDispatch(V: OLEVariant): IDispatch;

{ Strings }

function CutSubstring(const Delimiter: char; var AStr: string): string;
function CutSubString2(const Delimiter: char; var SubStr, AStr: string): boolean;
procedure DeleteChars(const Ch: char; var AStr: string);
procedure ReplaceChars(const Ch1, Ch2: char; var AStr: string);
function GetTempName(const AName: string): string;
function IsValidName(const AName: string): boolean;
function IsValidFieldName(const AName: string): boolean;

{ Others utilities }

function IntMin(V1, V2: integer): integer;
function IIF(Condition: boolean; TrueValue, FalseValue: TOLEEnum): TOLEEnum; overload;
function IIF(Condition: boolean; TrueValue, FalseValue: string): string; overload;

type
  TxlrOS = (xosUnknown, xosWin95, xosWin98, xosWin98SE, xosWinME, xosWinNT, xosWin2000, xosWinXP);

var
  xlrOS: TxlrOS = xosUnknown;

implementation

function GetOS : TxlrOS;
var
  osVerInfo: TOSVersionInfo;
  majorVer, minorVer: Integer;
begin
  Result := xosUnknown;
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then begin
    majorVer := osVerInfo.dwMajorVersion;
    minorVer := osVerInfo.dwMinorVersion;
    case osVerInfo.dwPlatformId of
      { NT platform }
      VER_PLATFORM_WIN32_NT :
        if majorVer <= 4 then Result := xosWinNT
        else
          if (majorVer = 5) and (minorVer= 0) then Result := xosWin2000
          else
            if (majorVer = 5) and (minorVer = 1) then Result := xosWinXP;
      { 9x platform }
      VER_PLATFORM_WIN32_WINDOWS :
        if (majorVer = 4) AND (minorVer = 0) then Result := xosWin95
        else
          if (majorVer = 4) AND (minorVer = 10) then
            begin
              if osVerInfo.szCSDVersion[1] = 'A' then Result := xosWin98SE
              else Result := xosWin98;
            end
          else
            if (majorVer = 4) AND (minorVer = 90) then Result := xosWinME;
    end;
  end;
end;

{ Compatibility }

{$IFDEF XLR_BCB}
  function _Assigned(Intf: OLEVariant): boolean;
  begin
    Result := not _VarIsEmpty(Intf);
  end;
{$ELSE}
  function _Assigned(Intf: IUnknown): boolean;
  begin
    Result := Assigned(Intf);
  end;
{$ENDIF XLR_BCB}

{$IFDEF XLR_BCB}
  procedure _Clear(var Intf: OLEVariant);
  begin
    Intf := UnAssigned;
  end;
{$ELSE}
  procedure _Clear(var Intf);
  begin
    IUnknown(Intf) := nil;
  end;
{$ENDIF XLR_BCB}

function _EqualIntf(Intf1, Intf2: IUnknown): boolean;
begin
  Result := Intf1 = Intf2;
end;

{$IFDEF XLR_VCL7}
function _VarIsEmpty(const V: Variant): Boolean;
begin
  with TVarData(V) do
    Result := (VType = varEmpty) or ((VType = varDispatch) or
      (VType = varUnknown)) and (VDispatch = nil);
end;
{$ELSE}
{$IFDEF XLR_VCL6}
function _VarIsEmpty(const V: Variant): Boolean;
begin
  with TVarData(V) do
    Result := (VType = varEmpty) or ((VType = varDispatch) or
      (VType = varUnknown)) and (VDispatch = nil);
end;
{$ELSE}
function _VarIsEmpty(const V: Variant): Boolean;
begin
  Result := VarIsEmpty(V);
end;
{$ENDIF XLR_VCL6}
{$ENDIF XLR_VCL7}

function _VarIsNothing(const V: Variant): Boolean;
begin
  Result := false;
  case VarType(V) of
    varUnknown: Result := not Assigned(TVarData(V).VUnknown);
    varDispatch: Result := not Assigned(TVarData(V).VDispatch);
  end;
end;

function _VarIsDispatch(const V: Variant): Boolean;
begin
  Result := VarType(V) = varDispatch;
  if Result then
    Result := not _VarIsNothing(V);
end;

function _VarIsEmptyParam(const V: Variant): Boolean;
begin
  Result := TVarData(V).VType = varError;
end;

function _GetActiveOleObject(const ClassName: string): IDispatch;
var
  ClassID: TCLSID;
  IUnk: IUnknown;
begin
  Result := nil;
  ClassID := ProgIDToClassID(ClassName);
  GetActiveObject(ClassID, nil, IUnk);
  if Assigned(IUnk) then
    IUnk.QueryInterface(IDispatch, Result);
end;

function _GetActiveIDispatch(V: OLEVariant): IDispatch;
var
  IUnk: IUnknown;
begin
  Result := nil;
  IUnk := V;
  IUnk.QueryInterface(IDispatch, Result);
end;

function _CreateOleObject(const ClassName: string): IDispatch;
var
  ClassID: TCLSID;
begin
  ClassID := ProgIDToClassID(ClassName);
  CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or
    CLSCTX_LOCAL_SERVER, IDispatch, Result);
end;

{ Strings }

function CutSubstring(const Delimiter: char; var AStr: string): string;
var
  DelimiterPos: integer;
begin
  Result := Trim(AStr);
  if Result <> '' then begin
    DelimiterPos := Pos(Delimiter, Result);
    if DelimiterPos > 0 then begin
      Result := Trim(Copy(AStr, 1, DelimiterPos - 1));
      Delete(AStr, 1, DelimiterPos);
    end
    else AStr := '';
  end;
end;

function CutSubString2(const Delimiter: char; var SubStr, AStr: string): boolean;
var
  DelimiterPos: integer;
begin
  SubStr := '';
  AStr := Trim(AStr);
  Result := AStr <> '';
  if Result then begin
    DelimiterPos := Pos(Delimiter, AStr);
    if DelimiterPos > 0 then begin
      SubStr := Trim(Copy(AStr, 1, DelimiterPos - 1));
      Delete(AStr, 1, DelimiterPos);
    end
    else begin
      SubStr := AStr;
      AStr := '';
    end;
  end;
  Result := (SubStr <> '') or (AStr <> '');
end;

procedure DeleteChars(const Ch: char; var AStr: string);
begin
  AStr := StringReplace(AStr, Ch, '', [rfReplaceAll, rfIgnoreCase]);
end;

procedure ReplaceChars(const Ch1, Ch2: char; var AStr: string);
begin
  AStr := StringReplace(AStr, Ch1, Ch2, [rfReplaceAll, rfIgnoreCase]);
end;

function OnlyDigits(const AStr: string): string;
var
  i, l: integer;
begin
  Result := '';
  l := Length(AStr);
  for i := 1 to l do
    if CharInSet(AStr[i], ['0'..'9']) then
      Result := Result + AStr[i];
end;

var LastTempID: string;

function GetTempName(const AName: string): string;
var
  s: string;
begin
  repeat
    s := Copy(CreateClassID, 2, 8) + '_' + OnlyDigits(DateTimeToStr(now));
  until s <> LastTempID;
  LastTempID := s;
  Result := AName + '_' + s;
end;

function IsValidFieldName(const AName: string): boolean;
var
  i: integer;
begin
  Result := true;
  for i := 1 to Length(AName) do
    if CharInSet(AName[i], [' '..'-', '/', ':'..'@', '['..'^', '''', '{'..#127]) then begin
      Result := false;
      Break;
    end;
end;

function IsValidName(const AName: string): boolean;
var
  i: integer;
begin
  Result := true;
  for i := 1 to Length(AName) do
    if not CharInSet(AName[i], ['A'..'Z', 'a'..'z', '0'..'9', '_', '.']) then begin
      Result := false;
      Break;
    end;
end;

{ Others utilities }

function IntMin(V1, V2: integer): integer;
begin
  if V1 > V2 then
    Result := V2
  else
    Result := V1;
end;

function IIF(Condition: boolean; TrueValue, FalseValue: TOLEEnum): TOLEEnum;
begin
  if Condition then
    Result := TrueValue
  else
    Result := FalseValue;
end;

function IIF(Condition: boolean; TrueValue, FalseValue: string): string;
begin
  if Condition then
    Result := TrueValue
  else
    Result := FalseValue;
end;

initialization

  xlrOS := GetOS;

end.

