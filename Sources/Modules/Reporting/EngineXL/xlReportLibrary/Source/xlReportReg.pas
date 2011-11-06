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

unit xlReportReg;

{$I xlcDefs.inc}
                                  
interface

uses Classes, Forms, SysUtils, FileCtrl, Dialogs,
  DesignIntf, DesignEditors, ToolsAPI,
  ExptIntf, xlcOPack, xlcClasses, xlReport, xlReportG2, xlAbout;

type

{ TxlrEditor }

  TxlrEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

{ TxlrFileNameEditor }

  TxlrFileNameEditor = class(TPropertyEditor)
  public
    function GetValue:String;override;
    procedure SetValue(const Value: string); override;
    procedure Edit;override;
    function GetAttributes: TPropertyAttributes;override;
  end;

{ TxlrFilePathEditor }

  TxlrFilePathEditor = class(TPropertyEditor)
  public
    function GetValue:String;override;
    procedure SetValue(const Value: string); override;
    procedure Edit;override;
    function GetAttributes: TPropertyAttributes;override;
  end;

{ TxlrDataSourceEditor }

  TxlrDataSourceEditor = class(TStringProperty)
  public
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes;override;
  end;

{ TxlrMultisheetSourceEditor }

  TxlrMultisheetSourceEditor = class(TStringProperty)
  public
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes;override;
  end;

{ TxlrEditorG2 }

  TxlrEditorG2 = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

{ TxlrFileNameEditorG2 }

  TxlrFileNameEditorG2 = class(TPropertyEditor)
  public
    function GetValue:String;override;
    procedure SetValue(const Value: string); override;
    procedure Edit;override;
    function GetAttributes: TPropertyAttributes;override;
  end;

{ TxlrFilePathEditorG2 }

  TxlrFilePathEditorG2 = class(TPropertyEditor)
  public
    function GetValue:String;override;
    procedure SetValue(const Value: string); override;
    procedure Edit;override;
    function GetAttributes: TPropertyAttributes;override;
  end;

{ TxlrDataSourceEditorG2 }

  TxlrDataSourceEditorG2 = class(TStringProperty)
  public
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes;override;
  end;

procedure Register;

implementation

{ Register }

procedure Register;
begin
  RegisterComponents('XL Report', [TxlReport, TxlReportG2]);
  RegisterComponentEditor(TxlReport, TxlrEditor);
  RegisterComponentEditor(TxlReportG2, TxlrEditorG2);
  RegisterPropertyEditor(TypeInfo(String), TxlReport, 'XLSTemplate', TxlrFileNameEditor);
  RegisterPropertyEditor(TypeInfo(String), TxlReportG2, 'XLSTemplate', TxlrFileNameEditorG2);
  RegisterPropertyEditor(TypeInfo(String), TxlReport, 'TempPath', TxlrFilePathEditor);
  RegisterPropertyEditor(TypeInfo(String), TxlReportG2, 'TempPath', TxlrFilePathEditorG2);
  RegisterPropertyEditor(TypeInfo(String), TxlDataSource, 'MasterSourceName', TxlrDataSourceEditor);
  RegisterPropertyEditor(TypeInfo(String), Tg2DataSource, 'MasterSourceName', TxlrDataSourceEditorG2);
  RegisterPropertyEditor(TypeInfo(String), TxlReport, 'MultisheetAlias', TxlrMultisheetSourceEditor);
  RegisterPropertyEditor(TypeInfo(String), TxlReportG2, 'MultisheetAlias', TxlrMultisheetSourceEditor);
end;

{ TxlrEditor }

procedure TxlrEditor.ExecuteVerb(Index: Integer);

  procedure DoDebugReport(Report: TxlReport);
  var
    OLDDebug: boolean;
  begin
    OLDDebug := Report.Debug;
    Report.Debug := true;
    try
      Report.Report;
    finally
      Report.Debug := OLDDebug;
    end;
  end;

  procedure DoRefresh(Report: TxlReport);
  var
    OLDOptions: TxlReportOptionsSet;
  begin
    OLDOptions := Report.Options;
    Report.Options := Report.Options + [xroRefreshParams];
    try
      Report.Edit;
    finally
      Report.Options := OLDOptions;
    end;
  end;

  procedure DoAbout;
  var
    f: TfxlAbout;
  begin
    f := TfxlAbout.Create(Application);
    try
      f.ShowModal;
    finally
      f.Free;
    end;
  end;

var
  s, s1, CurrentDir: string;
  r: TxlReport;
begin
  r := Component as TxlReport;
  s := r.XLSTemplate;
  s1 := GetCurrentDir;
  try
    if trim(r.XLSTemplate) <> '' then begin
      CurrentDir := ExtractFilePath(ToolServices.GetProjectName);
      SetCurrentDir(CurrentDir);
      if pos('..\', r.XLSTemplate) <> 0 then begin
        r.XLSTemplate := ExpandFileName(r.XLSTemplate);
      end
      else begin
        if trim( ExtractFilePath(r.XLSTemplate) ) = '' then
          r.XLSTemplate := CurrentDir + r.XLSTemplate
      end;
    end;
    case Index of
      0: r.Edit;
      1: r.Report;
{$IFNDEF XLR_TRIAL}
      2: DoDebugReport(r);
      3: DoRefresh(r);
      4: DoAbout;
{$ELSE}
      2: DoAbout;
{$ENDIF XLR_TRIAL}
    end;
  finally
    R.XLSTemplate := s;
    SetCurrentDir(s1);
  end;
end;

function TxlrEditor.GetVerb(Index: Integer): string;
begin
{$IFNDEF XLR_TRIAL}
  case Index of
    0: Result := LoadStr(msgComponentMenuEdit);
    1: Result := LoadStr(msgComponentMenuBuild);
    2: Result := LoadStr(msgComponentMenuBuildDebug);
    3: Result := LoadStr(msgComponentMenuRefresh);
    4: Result := LoadStr(msgComponentMenuAbout);
    else Result := '';
  end;
{$ELSE}
  case Index of
    0: Result := LoadStr(msgComponentMenuEdit);
    1: Result := LoadStr(msgComponentMenuBuild);
    2: Result := LoadStr(msgComponentMenuAbout);
    else Result := '';
  end;
{$ENDIF XLR_TRIAL}
end;

function TxlrEditor.GetVerbCount: Integer;
begin
{$IFNDEF XLR_TRIAL}
  Result := 5;
{$ELSE}
  Result := 3;
{$ENDIF XLR_TRIAL}
end;

{ TxlrFileNameEditor }

procedure TxlrFileNameEditor.Edit;
var OpenDialog:TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.DefaultExt := 'xls';
    OpenDialog.Filter := '*.xls|*.XLS|*.xlt|*.XLT';
    OpenDialog.Title := LoadStr(msgPropertyEditorSelectTemplate);
    OpenDialog.Options := [ofFileMustExist, ofPathMustExist];
    OpenDialog.InitialDir := ExtractFilePath(GetStrValue);
    OpenDialog.FileName := GetStrValue;
    if OpenDialog.Execute then SetStrValue(OpenDialog.FileName);
  finally
    OpenDialog.Free;
  end;
end;

function TxlrFileNameEditor.GetAttributes: TPropertyAttributes;
begin
 Result := [paDialog];
end;

function TxlrFileNameEditor.GetValue: String;
begin
  Result := GetStrValue;
end;

procedure TxlrFileNameEditor.SetValue(const Value: string);
begin
  SetStrValue(Value);
end;

{ TxlrFilePathEditor }

procedure TxlrFilePathEditor.Edit;
var Dir: string;
begin
  Dir := GetStrValue;
  if SelectDirectory( LoadStr(msgPropertyEditorSelectTempPath),
    'Desktop', Dir) then begin
    if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';
    SetStrValue(Dir);
  end;
end;

function TxlrFilePathEditor.GetAttributes: TPropertyAttributes;
begin
 Result := [paDialog];
end;

function TxlrFilePathEditor.GetValue: String;
begin
  Result := GetStrValue;
end;

procedure TxlrFilePathEditor.SetValue(const Value: string);
begin
  SetStrValue(Value);
end;

{ TxlrDataSourceEditor }

function TxlrDataSourceEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

procedure TxlrDataSourceEditor.GetValueList(List: TStrings);
var
  CurrentDataSource: TxlDataSource;
  Report: TxlReport;
  i: integer;
begin
  CurrentDataSource := GetComponent(0) as TxlDataSource;
  if CurrentDataSource.Range <> '' then begin
    Report := CurrentDataSource.Report;
    for i := 0 to Report.DataSources.Count - 1 do
      if (Report.DataSources[i].RangeType <> rtNoRange)  and
        (Report.DataSources[i] <> CurrentDataSource) then begin
        List.Add(Report.DataSources[i].Alias);
      end;
  end;
end;

procedure TxlrDataSourceEditor.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

{ TxlrMultisheetSourceEditor }

function TxlrMultisheetSourceEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

procedure TxlrMultisheetSourceEditor.GetValueList(List: TStrings);
var
  Report: TxlReport;
  i: integer;
begin
  Report := GetComponent(0) as TxlReport;
  for i := 0 to Report.DataSources.Count - 1 do
    if Report.DataSources[i].RangeType in [rtNoRange, rtRange] then
      List.Add(Report.DataSources[i].Alias);
end;

procedure TxlrMultisheetSourceEditor.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

{ TxlrEditorG2 }

procedure TxlrEditorG2.ExecuteVerb(Index: Integer);

  procedure DoAbout;
  var f: TfxlAbout;
  begin
    f := TfxlAbout.Create(Application);
    try
      f.ShowModal;
    finally
      f.Free;
    end;
  end;

var
  s, s1, CurrentDir: string;
  r: TxlReportG2;
begin
  r := Component as TxlReportG2;
  s := r.XLSTemplate;
  s1 := GetCurrentDir;
  try
    if trim(r.XLSTemplate) <> '' then begin
      CurrentDir := ExtractFilePath(ToolServices.GetProjectName);
      SetCurrentDir(CurrentDir);
      if pos('..\', r.XLSTemplate) <> 0 then begin
        r.XLSTemplate := ExpandFileName(r.XLSTemplate);
      end
      else begin
        if trim( ExtractFilePath(r.XLSTemplate) ) = '' then
          r.XLSTemplate := CurrentDir + r.XLSTemplate
      end;
    end;
    case Index of
      0: r.Edit;
      1: r.Report;
      3: DoAbout;
    end;
  finally
    R.XLSTemplate := s;
    SetCurrentDir(s1);
  end;
end;

function TxlrEditorG2.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := LoadStr(msgComponentMenuEdit);
    1: Result := LoadStr(msgComponentMenuBuild);
    2: Result := '-';
    3: Result := LoadStr(msgComponentMenuAbout);
    else Result := '';
  end;
end;

function TxlrEditorG2.GetVerbCount: Integer;
begin
  Result := 4;
end;

{ TxlrFileNameEditorG2 }

procedure TxlrFileNameEditorG2.Edit;
var OpenDialog:TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.DefaultExt := 'xls';
    OpenDialog.Filter := '*.xls|*.XLS|*.xlt|*.XLT';
    OpenDialog.Title := LoadStr(msgPropertyEditorSelectTemplate);
    OpenDialog.Options := [ofFileMustExist, ofPathMustExist];
    OpenDialog.InitialDir := ExtractFilePath(GetStrValue);
    OpenDialog.FileName := GetStrValue;
    if OpenDialog.Execute then SetStrValue(OpenDialog.FileName);
  finally
    OpenDialog.Free;
  end;
end;

function TxlrFileNameEditorG2.GetAttributes: TPropertyAttributes;
begin
 Result := [paDialog];
end;

function TxlrFileNameEditorG2.GetValue: String;
begin
  Result := GetStrValue;
end;

procedure TxlrFileNameEditorG2.SetValue(const Value: string);
begin
  SetStrValue(Value);
end;

{ TxlrFilePathEditorG2 }

procedure TxlrFilePathEditorG2.Edit;
var Dir: string;
begin
  Dir := GetStrValue;
  if SelectDirectory( LoadStr(msgPropertyEditorSelectTempPath),
    'Desktop', Dir) then begin
    if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';
    SetStrValue(Dir);
  end;
end;

function TxlrFilePathEditorG2.GetAttributes: TPropertyAttributes;
begin
 Result := [paDialog];
end;

function TxlrFilePathEditorG2.GetValue: String;
begin
  Result := GetStrValue;
end;

procedure TxlrFilePathEditorG2.SetValue(const Value: string);
begin
  SetStrValue(Value);
end;

{ TxlrDataSourceEditorG2 }

function TxlrDataSourceEditorG2.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

procedure TxlrDataSourceEditorG2.GetValueList(List: TStrings);
var
  CurrentDataSource: Tg2DataSource;
  Report: TxlReportG2;
  i: integer;
begin
  CurrentDataSource := GetComponent(0) as Tg2DataSource;
  if CurrentDataSource.Range <> '' then begin
    Report := CurrentDataSource.Report;
    for i := 0 to Report.DataSources.Count - 1 do
      if (Report.DataSources[i].RangeType <> rtNoRange)  and
        (Report.DataSources[i] <> CurrentDataSource) then begin
        List.Add(Report.DataSources[i].Alias);
      end;
  end;
end;

procedure TxlrDataSourceEditorG2.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

end.
