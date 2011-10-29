unit CommonUtils;

interface
uses SysUtils, windows, classes, UIClasses, variants, forms, controls,
  Graphics;


function FirstDayOfMonth(ADate: TDateTime): TDateTime;
function LastDayOfMonth(ADate: TDateTime): TDateTime;

function IsControlKeyDown: boolean;

function GetOptionsValue(const AOptionsText, AValueName: string): string;

//function IListToStr(AList: IList; ADelimiter: char = ';'): string;

function GetTextWidth(AFont: TFont; const AText: string): integer;
function GetTextHeight(AFont: TFont): integer;

function NormalizeComponentName(const AName: string): string;

implementation

function FirstDayOfMonth(ADate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(ADate, Year, Month, Day);
  Result := EncodeDate(Year, Month, 1);
end;

function LastDayOfMonth(ADate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(ADate, Year, Month, Day);
  if Month < 12 then inc(Month)
  else begin Month := 1; inc(Year) end;
  Result := EncodeDate(Year, Month, 1) - 1;
end;

function IsControlKeyDown: boolean;
begin
  result:=(Word(GetKeyState(VK_CONTROL)) and $8000)<>0;
end;

function GetOptionsValue(const AOptionsText, AValueName: string): string;
var
  _list: TStringList;
begin
  _list := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(AOptionsText), _list);
    Result := _list.Values[AValueName];
  finally
    _list.Free;
  end;
end;

function IListToStr(AList: IList; ADelimiter: char = ';'): string;
var
  I: integer;
begin
  Result := '';
  for I := 0 to AList.Count - 1 do
    if Result = '' then
      Result := VarToStr(AList[I])
    else
      Result := Result + ADelimiter + VarToStr(AList[I]);
end;

function GetTextWidth(AFont: TFont; const AText: string): integer;
var
  BM: TBitmap;
begin
  BM := TBitmap.Create;
  try
    BM.Canvas.Font := AFont;
    Result := BM.Canvas.TextWidth(AText);
  finally
    BM.Free;
  end;
end;

function GetTextHeight(AFont: TFont): integer;
var
  BM: TBitmap;
begin
  BM := TBitmap.Create;
  try
    BM.Canvas.Font := AFont;
    Result := BM.Canvas.TextHeight('0');
  finally
    BM.Free;
  end;
end;

function NormalizeComponentName(const AName: string): string;
const
  Alpha = ['A'..'Z', 'a'..'z', '_'];
  AlphaNumeric = Alpha + ['0'..'9'];
var
  I: Integer;
begin
  Result := AName;
  for I := 1 to Length(Result) do
    if not CharInSet(Result[I], AlphaNumeric) then
      Result[I] := '_';
end;

end.
