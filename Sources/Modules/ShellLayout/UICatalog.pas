unit UICatalog;

interface
uses classes, coreClasses, db, EntityServiceIntf, UIServiceIntf, variants,
  cxStyles, graphics, windows, generics.collections, sysutils, ShellIntf,
  UIClasses, StrUtils, forms, Contnrs, LicenseServiceIntf;

type
  TUICatalog = class(TComponent)
  const
    ENTC_UI = 'BFW_UI';
    ENTC_UI_VIEW_LIST = 'List';
    ENTC_UI_VIEW_CMD = 'Commands';
    ENTC_UI_VIEW_STYLES = 'Styles';

  private
    FWorkItem: TWorkItem;
    procedure ReloadConfigurationHandler(Context: TWorkItem; EventData: Variant);
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
      CMD_HANDLER = 'HANDLER';
      CMD_PARAMS = 'PARAMS';
      CMD_OPTION_CONFIRM = 'Confirm';
      CMD_OPTION_FOREACH = 'ForEach';
      CMD_OPTION_FOREACH_PARAM = 'ForEachParam';
      CMD_OPTION_HIDDEN = 'Hidden';
      CMD_OPTION_CLOSE_VIEW_BEFORE = 'CloseViewBefore';
      CMD_OPTION_CLOSE_VIEW_AFTER = 'CloseViewAfter';
    private
      FConditions: TObjectList;
      function CommandExists(const AName: string): boolean;
      procedure CommandHandler(Sender: TObject);
      procedure CommandHandlerFor(Sender: TObject);
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
var
  svc: ILicenseService;
begin
  svc := AWorkItem.Services[ILicenseService] as ILicenseService;
  if svc.GetStatus <> lsRegistered then Exit;

  LoadUI(AWorkItem);
  LoadStyles(AWorkItem);
  RegisterViewExtension(TViewCommandExtension);
end;

procedure TUICatalog.ReloadConfigurationHandler(Context: TWorkItem; EventData: Variant);
begin
  Load(FWorkItem);
end;

class procedure TUICatalog.LoadStyles(AWorkItem: TWorkItem);

  procedure FontSizeSet(const AValue: string; AStyle: TcxStyle; AScale: integer);
  var
    size: integer;
  begin
    size := StrToIntDef(AValue, AStyle.Font.Size);
    size := MulDiv(size, AScale, 100);
    AStyle.Font.Size := size;
  end;

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
      //style.Font.Size := MulDiv(style.Font.Size, uiSvc.Scale, 100);
      style.Font.Name := 'MS Sans Serif';
      strList.Clear;
      ExtractStrings([';'], [], PWideChar(VarToStr(ds['OPTIONS'])), strList);

      ColorSet(strList.Values['Color'], style);
      FontStyleSet(strList.Values['Font.Style'], style);
      FontColorSet(strList.Values['Font.Color'], style);
      FontSizeSet(strList.Values['Font.Size'], style, uiSvc.Scale);
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
        Options.Add(TViewActivityOptions.EntityName + '=' + VarToStr(list['ENTITYNAME']));
        Options.Add(TViewActivityOptions.EntityViewName + '=' + VarToStr(list['VIEWNAME']));

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


function TUICatalog.TViewCommandExtension.CommandExists(
  const AName: string): boolean;
var
  I: integer;
begin
  Result := false;
  for I := 0 to WorkItem.Commands.Count - 1 do
  begin
    Result := SameText(WorkItem.Commands.GetItem(I).ID, AName);
    if Result then Break;
  end;

end;

procedure TUICatalog.TViewCommandExtension.CommandExtend;

  procedure SetHandlerFor(const ACommands, AHandler: string);
  var
    I: integer;
    strList: TStringList;
  begin
     strList := TStringList.Create;
     try
        ExtractStrings([',',';'], [], PWideChar(ACommands), strList);
        for I := 0 to strList.Count - 1 do
        begin
          WorkItem.Commands[strList[I]].Data[CMD_HANDLER] := AHandler;
          WorkItem.Commands[strList[I]].SetHandler(CommandHandlerFor);
        end;
     finally
       strList.Free;
     end;
  end;

  procedure CommandSetOptions(ACommand: ICommand; const AOptions: string);
  var
    I: integer;
    strList: TStringList;
    optionValue: string;
    optionName: string;
  begin
     strList := TStringList.Create;
     try
        ExtractStrings([';'], [], PWideChar(AOptions), strList);
        for I := 0 to strList.Count - 1 do
        begin
          optionValue := strList.ValueFromIndex[I];
          if optionValue = '' then
            optionValue := '1';

          optionName := strList.Names[I];
          if optionName = '' then
            optionName := strList[I];

          ACommand.Data[optionName] := optionValue;
        end;
     finally
       strList.Free;
     end;
  end;

  function FindForEachParam(ACommand: ICommand; const AParamStr: string): string;
  var
    I: integer;
    strList: TStringList;
  begin
     strList := TStringList.Create;
     try
        ExtractStrings([';'], [], PWideChar(AParamStr), strList);
        for I := 0 to strList.Count - 1 do
        begin
          if SameText(strList.ValueFromIndex[I], 'ForEachValue') then
          begin
            Result := strList.Names[I];
            break;
          end;
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
begin
  if not Supports(GetView, ICustomView) then Exit;

  list := App.Entities[ENTC_UI].GetView(ENTC_UI_VIEW_CMD, WorkItem).Load([GetView.ViewURI]);
  while not list.Eof do
  begin
    cmdID := list['CMD'];

    cmdExists := CommandExists(cmdID);  //!!! must be before ->  cmd := WorkItem.Commands[cmdID];

    cmd := WorkItem.Commands[cmdID];
    cmd.Caption := VarToStr(list['CAPTION']);
    cmd.Group := VarToStr(list['GRP']);

    if VarToStr(list['SHORTCUT']) <> '' then
      cmd.ShortCut := VarToStr(list['SHORTCUT']);

    cmd.Data[CMD_HANDLER] := VarToStr(list['HANDLER']);
    cmd.Data[CMD_PARAMS] := VarToStr(list['PARAMS']);
    cmd.SetHandler(CommandHandler);

    CommandSetOptions(cmd, VarToStr(list['OPTIONS']));

    if cmd.Data[CMD_OPTION_FOREACH] <> '' then
      cmd.Data[CMD_OPTION_FOREACH_PARAM] := FindForEachParam(cmd, cmd.Data[CMD_PARAMS]);


    if (not cmdExists) and (cmd.Data[CMD_OPTION_HIDDEN] <> '1')  then
      (GetView as ICustomView).CommandBar.
        AddCommand(cmd.Name, cmd.Caption, cmd.ShortCut, cmd.Group, list['DEF'] = 1);

    if (VarToStr(list['CONDITION']) <> '') or (VarToStr(list['CONDITION_PARAMS']) <> '') then
      FConditions.Add(TCommandCondition.Create(cmd.Name,
        VarToStr(list['CONDITION']), VarToStr(list['CONDITION_PARAMS'])));

    if VarToStr(list['HANDLER_FOR']) <> '' then
      SetHandlerFor(list['HANDLER_FOR'], cmd.Name);

    list.Next;
  end;

end;

procedure TUICatalog.TViewCommandExtension.CommandHandler(Sender: TObject);

  function GetCallerWI: TWorkItem;
  var
    I: integer;
  begin
    for I := 0 to Workitem.CallStack.Count - 1 do
    begin
      Result := WorkItem.Root.WorkItems.Find(WorkItem.CallStack[I]);
      if Assigned(Result) then Exit;
    end;
    Result := WorkItem.Parent;
  end;

  function ExecuteHandler(ACommand: ICommand; const AHandler: string): boolean;
  var
    callerWI: TWorkItem;
    activity: IActivity;
    forEachArray: Variant;
    forEachCount: integer;
    forEachParam: string;
    I: integer;
    batchCall: boolean;
    workItemClosed: boolean;
  begin
    Result := true;
    if CommandExists(AHandler) then
    begin
      WorkItem.Commands[AHandler].Execute;
      Exit;
    end;

    activity := WorkItem.Activities[AHandler];

    activity.Params.Assign(WorkItem, ACommand.Data[CMD_PARAMS]);

    forEachArray := Unassigned;
    forEachCount := 0;
    forEachParam := '';

    batchCall := ACommand.Data[CMD_OPTION_FOREACH] <> '';
    if batchCall then
    begin
      forEachArray := WorkItem.State[ACommand.Data[CMD_OPTION_FOREACH]];
      if not VarIsArray(forEachArray) then Exit;
      forEachParam := ACommand.Data[CMD_OPTION_FOREACH_PARAM];
      forEachCount := VarArrayHighBound(forEachArray, 1);
    end;

    callerWI := WorkItem;

    workItemClosed := false;
    if ACommand.Data[CMD_OPTION_CLOSE_VIEW_BEFORE] = '1' then
    begin
      callerWI := GetCallerWI;

      WorkItem.Commands[COMMAND_CLOSE].Execute;
      workItemClosed := true;
      Result := false;
    end;

    if batchCall then
    begin
      for I := 0 to forEachCount do
      begin
        if forEachCount = 0 then
          activity.CallMode := acmSingle
        else if I = 0 then
          activity.CallMode := acmBatchFirst
        else if I = forEachCount then
          activity.CallMode := acmBatchLast
        else
          activity.CallMode := acmBatchNext;

        if not WorkItemClosed then
          activity.Params.Assign(WorkItem, ACommand.Data[CMD_PARAMS]);

        activity.Params[forEachParam] := forEachArray[I];
        activity.Execute(callerWI);
      end
    end
    else
      activity.Execute(callerWI);

    if ACommand.Data[CMD_OPTION_CLOSE_VIEW_AFTER] = '1' then
    begin
      WorkItem.Commands[COMMAND_CLOSE].Execute;
      Result := false;
    end;
  end;

var
  cmd: ICommand;
  cmdHandler: string;
  I: integer;
  strList: TStringList;
  confirmText: string;
  confirm: boolean;
begin
  Sender.GetInterface(ICommand, cmd);

  cmdHandler := cmd.Data[CMD_HANDLER];
  confirmText := cmd.Data[CMD_OPTION_CONFIRM];

  if (confirmText <> '') then
    confirm := App.UI.MessageBox.ConfirmYesNo(confirmText)
  else
    confirm := true;

  if not confirm then Exit;

  strList := TStringList.Create;
  try
    ExtractStrings([';', ','], [], PWideChar(cmdHandler), strList);
    for I := 0 to strList.Count - 1 do
      if not ExecuteHandler(cmd, strList[I]) then Break;
  finally
    strList.Free;
  end;


end;

procedure TUICatalog.TViewCommandExtension.CommandHandlerFor(Sender: TObject);
var
  cmd: ICommand;
begin
  Sender.GetInterface(ICommand, cmd);
  WorkItem.Commands[cmd.Data[CMD_HANDLER]].Execute;
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
      else if SameText(ACondition.Params.ValueFromIndex[I], 'Empty') then
      begin
        if not (VarIsEmpty(WorkItem.State[ACondition.Params.Names[I]]) or
            VarIsNull(WorkItem.State[ACondition.Params.Names[I]])) then
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
