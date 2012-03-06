unit UICatalog;

interface
uses classes, coreClasses, db, EntityServiceIntf, UIServiceIntf, variants,
  cxStyles, graphics, windows, generics.collections, sysutils, ShellIntf;

type
  TUICatalog = class(TComponent)
  const
    ENTC_UI = 'BFW_UI';
    ENTC_UI_VIEW_LIST = 'List';
    ENTC_UI_VIEW_CMD = 'Commands';
    ENTC_UI_VIEW_STYLES = 'Styles';
    OPTION_ENTITYNAME = 'ENTITYNAME';
    OPTION_ENTITYVIEWNAME = 'ENTITYVIEWNAME';

  private
    FWorkItem: TWorkItem;
    procedure ReloadConfigurationHandler(EventData: Variant);
    class procedure LoadUI(AWorkItem: TWorkItem);
    class procedure LoadStyles(AWorkItem: TWorkItem);
    class procedure Load(AWorkItem: TWorkItem);
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
  end;

implementation

var
  ColorDictionary: TDictionary<string, integer>;

procedure ColorDictionaryInit;
begin
  ColorDictionary := TDictionary<string, integer>.Create;

{clBlack = TColor($000000);
  clMaroon = TColor($000080);
  clGreen = TColor($008000);
  clOlive = TColor($008080);
  clNavy = TColor($800000);

  clPurple = TColor($800080);
  clTeal = TColor($808000);
  clGray = TColor($808080);
  clSilver = TColor($C0C0C0);

  clRed = TColor($0000FF);
  clLime = TColor($00FF00);
  clYellow = TColor($00FFFF);
  clBlue = TColor($FF0000);

  clFuchsia = TColor($FF00FF);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($C0C0C0);
  clDkGray = TColor($808080);
  clWhite = TColor($FFFFFF);
  StandardColorsCount = 16;

  clMoneyGreen = TColor($C0DCC0);
  clSkyBlue = TColor($F0CAA6);
  clCream = TColor($F0FBFF);
  clMedGray = TColor($A4A0A0);
  ExtendedColorsCount = 4;

  clNone = TColor($1FFFFFFF);
  clDefault = TColor($20000000);
}
  ColorDictionary.Add('BLACK', clBlack);
  ColorDictionary.Add('MAROON', clMaroon);
  ColorDictionary.Add('GREEN', clGreen);
  ColorDictionary.Add('OLIVE', clOlive);
  ColorDictionary.Add('NAVY', clNavy);
  ColorDictionary.Add('PURPLE', clPurple);
  ColorDictionary.Add('TEAL', clTeal);
  ColorDictionary.Add('GRAY', clGray);
  ColorDictionary.Add('SILVER', clSilver);
  ColorDictionary.Add('RED', clRed);
  ColorDictionary.Add('LIME', clLime);
  ColorDictionary.Add('YELLOW', clYellow);
  ColorDictionary.Add('BLUE', clBlue);
  ColorDictionary.Add('FUCHSIA', clFuchsia);
  ColorDictionary.Add('AQUA', clAqua);
  ColorDictionary.Add('LTGRAY', clLtGray);
  ColorDictionary.Add('DKGRAY', clDkGray);
  ColorDictionary.Add('WHITE', clWhite);
  ColorDictionary.Add('MONEYGREEN', clMoneyGreen);
  ColorDictionary.Add('SKYBLUE', clSkyBlue);
  ColorDictionary.Add('CREAM', clCream);
  ColorDictionary.Add('MEDGRAY', clMedGray);

  ColorDictionary.Add('INFOBK', clInfoBk);
end;
{ TActivityCatalog }


constructor TUICatalog.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  Load(FWorkItem);
//  FWorkItem.EventTopics[ET_LOAD_CONFIGURATION].AddSubscription(Self, LoadConfigurationHandler);
  FWorkItem.EventTopics[ET_RELOAD_CONFIGURATION].AddSubscription(Self, ReloadConfigurationHandler);
end;

class procedure TUICatalog.Load(AWorkItem: TWorkItem);
begin
  LoadUI(AWorkItem);
  LoadStyles(AWorkItem);
end;

procedure TUICatalog.ReloadConfigurationHandler(EventData: Variant);
begin
  Load(FWorkItem);
end;

class procedure TUICatalog.LoadStyles(AWorkItem: TWorkItem);

  procedure ColorSet(const AValue: string; AStyle: TcxStyle);
  var
    color: integer;
  begin
    if ColorDictionary.TryGetValue(UpperCase(AValue), color) then
      AStyle.Color := color
    else if StrToIntDef(AValue, -1) <> -1 then
      AStyle.Color := StrToInt(AValue);
  end;

  procedure FontColorSet(const AValue: string; AStyle: TcxStyle);
  var
    color: integer;
  begin
    if ColorDictionary.TryGetValue(UpperCase(AValue), color) then
      AStyle.TextColor := color
    else if StrToIntDef(AValue, -1) <> -1 then
      AStyle.TextColor := StrToInt(AValue);
  end;

  procedure FontStyleSet(const AValue: string; AStyle: TcxStyle);
  var
    valUpper: string;
  begin
    valUpper := UpperCase(AValue);
    if valUpper = 'BOLD' then
      AStyle.Font.Style := [fsBold]
    else if valUpper = 'ITALIC' then
      AStyle.Font.Style := [fsItalic]
    else if valUpper = 'UNDERLINE' then
     AStyle.Font.Style := [fsUnderline]
    else if valUpper = 'STRIKEOUT' then
      AStyle.Font.Style := [fsStrikeOut];
  end;

var
  ds: TDataSet;
  strList: TStringList;
  style: TcxStyle;
  uiSvc: IUIService;
begin
  uiSvc := AWorkItem.Services[IUIService] as IUIService;

  strList := TStringList.Create;
  try
    ds := (AWorkItem.Services[IEntityService] as IEntityService).
      Entity[ENTC_UI].GetView(ENTC_UI_VIEW_STYLES, AWorkItem).Load([]);
    while not ds.Eof do
    begin
      style := TcxStyle.Create(AWorkItem);
      style.Font.Size := MulDiv(style.Font.Size, uiSvc.Scale, 100);
      style.Font.Name := 'MS Sans Serif';
      strList.Clear;
      ExtractStrings([';'], [], PWideChar(VarToStr(ds['OPTIONS'])), strList);

      ColorSet(strList.Values['Color'], style);
      FontStyleSet(strList.Values['Font.Style'], style);
      FontColorSet(strList.Values['Font.Color'], style);
      uiSvc.Styles[ds['ID']] := style;
      ds.Next;
    end
  finally
    strList.Free;
  end;

end;

class procedure TUICatalog.LoadUI(AWorkItem: TWorkItem);
var
  I: integer;
  list: TDataSet;
  svc: IEntityService;
  strList: TStringList;
begin
  strList := TStringList.Create;
  try
    svc := AWorkItem.Services[IEntityService] as IEntityService;
    list := svc.Entity[ENTC_UI].GetView(ENTC_UI_VIEW_LIST, AWorkItem).Load([]);
    while not list.Eof do
    begin
      with AWorkItem.Activities[list['URI']] do
      begin
        ActivityClass := list['CLS'];
        Title := list['Title'];
        Group := VarToStr(list['GRP']);
        MenuIndex := list['MENUIDX'];
        UsePermission := list['USEPERM'] = 1;

        strList.Clear;
        ExtractStrings([';'], [], PWideChar(VarToStr(list['OPTIONS'])), strList);
        Options.Clear;
        Options.AddStrings(strList);
        Options.Add(OPTION_ENTITYNAME + '=' + VarToStr(list['ENTITYNAME']));
        Options.Add(OPTION_ENTITYVIEWNAME + '=' + VarToStr(list['VIEWNAME']));

        strList.Clear;
        ExtractStrings([',',';'], [], PWideChar(VarToStr(list['PARAMS'])), strList);
        for I := 0 to strList.Count - 1 do
          Params[strList[I]] := Unassigned;

        strList.Clear;
        ExtractStrings([',',';'], [], PWideChar(VarToStr(list['OUTS'])), strList);
        for I := 0 to strList.Count - 1 do
          Outs[strList[I]] := Unassigned;
      end;

      list.Next;
    end;
  finally
    strList.Free;
  end;
end;

initialization
  ColorDictionaryInit;

end.
