unit UICatalog;

interface
uses classes, coreClasses, db, EntityServiceIntf, UIServiceIntf, variants,
  cxStyles, graphics, windows, generics.collections, sysutils, ShellIntf,
  UIClasses, StrUtils, forms, Contnrs;

type
  TUICatalog = class(TComponent)
  const
    ENTC_UI = 'BFW_UI';
    ENTC_UI_VIEW_LIST = 'List';
    ENTC_UI_VIEW_CMD = 'Commands';
    ENTC_UI_VIEW_STYLES = 'Styles';

  private
    FWorkItem: TWorkItem;
    procedure ReloadConfigurationHandler(EventData: Variant);
    class procedure LoadUI(AWorkItem: TWorkItem);
    class procedure LoadStyles(AWorkItem: TWorkItem);
    class procedure Load(AWorkItem: TWorkItem);
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;

  type

    TCommandCondition = class(TObject)
    private
      FParams: TStringList;
      FCommandName: string;
      FEntityName: string;
      FViewName: string;
      FParamsStr: string;
      FRunOnce: boolean;
      FSetUnavailable: boolean;
    public
      constructor Create(const ACommandName, ACondition, AParamsStr: string);
      destructor Destroy; override;
      property CommandName: string read FCommandName;
      property EntityName: string read FEntityName;
      property ViewName: string read FViewName;
      property ParamsStr: string read FParamsStr;
      property Params: TStringList read FParams;
      property RunOnce: boolean read FRunOnce;
      property SetUnavailable: boolean read FSetUnavailable;
    end;

    TViewCommandExtension = class(TViewExtension, IExtensionCommand)
    const
      CMDPROXY_DATA_HANDLER = 'PROXY_HANDLER';
      CMDPROXY_DATA_PARAMS = 'PROXY_PARAMS';
      CMDPROXY_OPTION_PREF = 'PROXY_OPTION.';

    private
      FConditions: TObjectList;

      procedure CommandProxyHandler(Sender: TObject);
    protected
      procedure CommandExtend;
      procedure CommandUpdate;
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      class function CheckView(AView: IView): boolean; override;
    end;

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
  FWorkItem.EventTopics[ET_RELOAD_CONFIGURATION].AddSubscription(Self, ReloadConfigurationHandler);
end;

class procedure TUICatalog.Load(AWorkItem: TWorkItem);
begin
  LoadUI(AWorkItem);
  LoadStyles(AWorkItem);
  RegisterViewExtension(TViewCommandExtension);
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
  entityName: string;
  entityViewName: string;
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

        entityName := VarToStr(list['ENTITYNAME']);
        entityViewName := VarToStr(list['VIEWNAME']);

        strList.Clear;
        ExtractStrings([';'], [], PWideChar(VarToStr(list['OPTIONS'])), strList);
        Options.Clear;
        Options.AddStrings(strList);
        Options.Add(TViewActivityOptions.EntityName + '=' + entityName);
        Options.Add(TViewActivityOptions.EntityViewName + '=' + entityViewName);

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

{ TUICatalog.TViewCommandExtension }

class function TUICatalog.TViewCommandExtension.CheckView(
  AView: IView): boolean;
var
  intf: IInterface;
begin
  AView.QueryInterface(ICustomView, intf);
  Result := intf <> nil;
end;


procedure TUICatalog.TViewCommandExtension.CommandExtend;

  procedure CommandSetOptions(ACommand: ICommand; const AOptions: string);
  var
    I: integer;
    strList: TStringList;
    optionValue: string;
    optionName: string;
  begin
     strList := TStringList.Create;
     try
        ExtractStrings([',',';'], [], PWideChar(AOptions), strList);
        for I := 0 to strList.Count - 1 do
        begin
          optionValue := strList.ValueFromIndex[I];
          if optionValue = '' then
            optionValue := '1';

          optionName := strList.Names[I];
          if optionName = '' then
            optionName := strList[I];

          optionName := CMDPROXY_OPTION_PREF + optionName;
          ACommand.Data[optionName] := optionValue;
        end;
     finally
       strList.Free;
     end;
  end;


var
  list: TDataSet;
  cmd: ICommand;
  cmdID: string;
  cmdExists: boolean;
  I: integer;
begin
  if not Supports(GetView, ICustomView) then Exit;

  list := App.Entities[ENTC_UI].GetView(ENTC_UI_VIEW_CMD, WorkItem).Load([GetView.ViewURI]);
  while not list.Eof do
  begin
    cmdID := list['CMD'];

    cmdExists := false;
    for I := 0 to WorkItem.Commands.Count - 1 do
    begin
      cmdExists := SameText(WorkItem.Commands.GetItem(I).ID, cmdID);
      if cmdExists then Break;
    end;

    cmd := WorkItem.Commands[cmdID];

    cmd.Data[CMDPROXY_DATA_HANDLER] := VarToStr(list['HANDLER']);
    cmd.Data[CMDPROXY_DATA_PARAMS] := VarToStr(list['PARAMS']);
    cmd.SetHandler(CommandProxyHandler);

    if not cmdExists then
      (GetView as ICustomView).CommandBar.
        AddCommand(cmd.Name, VarToStr(list['CAPTION']), '', VarToStr(list['GRP']), list['DEF'] = 1);

    CommandSetOptions(cmd, VarToStr(list['OPTIONS']));

    if (VarToStr(list['CONDITION']) <> '') or (VarToStr(list['CONDITION_PARAMS']) <> '') then
      FConditions.Add(TCommandCondition.Create(cmd.Name,
        VarToStr(list['CONDITION']), VarToStr(list['CONDITION_PARAMS'])));

    list.Next;
  end;

end;

procedure TUICatalog.TViewCommandExtension.CommandProxyHandler(Sender: TObject);
const
  OPTION_CLOSE_VIEW_BEFORE = CMDPROXY_OPTION_PREF + 'CloseViewBefore';
  OPTION_CLOSE_VIEW_AFTER = CMDPROXY_OPTION_PREF + 'CloseViewAfter';

var
  cmd: ICommand;
  activity: IActivity;
  cmdHandler: string;
  cmdParams: string;
  callerWI: TWorkItem;

begin
  Sender.GetInterface(ICommand, cmd);

  cmdHandler := cmd.Data[CMDPROXY_DATA_HANDLER];
  cmdParams := cmd.Data[CMDPROXY_DATA_PARAMS];

  activity := WorkItem.Activities[cmdHandler];
  activity.Params.Assign(WorkItem, cmdParams);

  callerWI := WorkItem;

  if VarToStr(cmd.Data[OPTION_CLOSE_VIEW_BEFORE]) = '1' then
  begin
    if WorkItem.ID <> WorkItem.Context then
    begin
      callerWI := WorkItem.Root.WorkItems.Find(WorkItem.Context);
      if callerWI = nil then
        callerWI := WorkItem.Parent;
    end
    else
      callerWI := WorkItem.Parent;

    WorkItem.Commands[COMMAND_CLOSE].Execute;
  end;

  activity.Execute(callerWI);

  if VarToStr(cmd.Data[OPTION_CLOSE_VIEW_AFTER]) = '1' then
    WorkItem.Commands[COMMAND_CLOSE].Execute;

end;

procedure TUICatalog.TViewCommandExtension.CommandUpdate;

  function ConditionBySQL(ACondition: TCommandCondition): TCommandStatus;
  begin
    Result := csEnabled;
    if App.Entities[ACondition.EntityName].GetView(ACondition.ViewName, WorkItem).
      Load(true, ACondition.ParamsStr).Fields[0].AsInteger = 0 then
      Result := csDisabled;
  end;

  function ConditionByParams(ACondition: TCommandCondition): TCommandStatus;
  var
    I: integer;
  begin
    Result := csEnabled;

    for I := 0 to ACondition.Params.Count - 1 do
    begin

      if SameText(ACondition.Params.ValueFromIndex[I], 'NotEmpty') then
      begin
        if VarIsEmpty(WorkItem.State[ACondition.Params.Names[I]]) or
           VarIsNull(WorkItem.State[ACondition.Params.Names[I]]) then
          Result := csDisabled;
      end
      else
      begin
        if VarToStr(WorkItem.State[ACondition.Params.Names[I]]) <>
             ACondition.Params.ValueFromIndex[I] then
          Result := csDisabled;
      end;

      if Result = csDisabled then Exit;
    end;

  end;

var
  I: integer;
  condition: TCommandCondition;
  commandStatus: TCommandStatus;
begin
  for I := FConditions.Count - 1 downto 0 do
  begin
    condition := TCommandCondition(FConditions[I]);

    if condition.EntityName <> '' then
      commandStatus := ConditionBySQL(condition)
    else
      commandStatus := ConditionByParams(condition);

    if (commandStatus = csDisabled) and condition.SetUnavailable then
      commandStatus := csUnavailable;

    WorkItem.Commands[condition.CommandName].Status := commandStatus;

    if condition.RunOnce then
      FConditions.Delete(I);
  end;
end;


constructor TUICatalog.TViewCommandExtension.Create(AOwner: TComponent);
begin
  inherited;
  FConditions := TObjectList.Create;
end;

destructor TUICatalog.TViewCommandExtension.Destroy;
begin
  FConditions.Free;
  inherited;
end;

{ TUICatalog.TCommandCondition }

constructor TUICatalog.TCommandCondition.Create(const ACommandName, ACondition, AParamsStr: string);

  function DecodeValue(const AValue: string): string;
  var
    val: string;
  begin
    if StartsText('[', AValue) and EndsText(']', AValue) then
    begin
      val := AValue;
      Delete(val, 1, 1);
      Delete(val, Length(val), 1);
      Result := val;
    end
    else
      Result := AValue;
  end;

var
  strList: TStringList;
  I: integer;

begin
  FParams := TStringList.Create;

  FCommandName := ACommandName;
  FParamsStr := AParamsStr;

  strList := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(ACondition), strList);
    FEntityName := strList.Values['Entity'];
    FViewName := strList.Values['EView'];
    FRunOnce := strList.IndexOf('RunOnce') <> -1;
    FSetUnavailable  := strList.IndexOf('SetUnavailable') <> -1;

    if FEntityName = '' then
    begin
      strList.Clear;
      ExtractStrings([';'], [], PWideChar(AParamsStr), strList);
      for I := 0 to strList.Count - 1 do
        FParams.Values[strList.Names[I]] := DecodeValue(strList.ValueFromIndex[I]);
    end;

  finally
    strList.Free;
  end;

end;

destructor TUICatalog.TCommandCondition.Destroy;
begin
  FParams.Free;
  inherited;
end;

initialization
  ColorDictionaryInit;

end.
