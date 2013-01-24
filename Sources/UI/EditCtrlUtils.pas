unit EditCtrlUtils;

interface
uses classes, CustomView, UIClasses, cxEdit, controls, Typinfo,
  cxDropDownEdit, cxDateUtils, sysutils, strUtils;


implementation


function MySmartTextToDate(const AText: string; var ADate: TDateTime): Boolean;
var
  Year: Integer;
  Month: Integer;
  Day: integer;
  DayStr: string;
begin
  if (AText <> '') and (Length(AText) <= 3) then
  begin
    DayStr := AText;
    if Length(DayStr) = 3 then
      Delete(DayStr, 3, 1);

    Day := StrToIntDef(DayStr, 0);
    if Day in [1..31] then
    begin
      Year := GetDateElement(Date, deYear);
      Month := GetDateElement(Date, deMonth);
      ADate := EncodeDate(Year, Month, Day);

      //Indicating that function was a success.
      Result := True;
    end
    else
      Result := false;
  end
  else
    //Otherwise the function was a failure.
    Result := false;
end;



initialization
  cxDateUtils.SmartTextToDateFunc := MySmartTextToDate;
end.
