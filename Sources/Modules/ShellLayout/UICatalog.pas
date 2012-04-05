unit UICatalog;

interface
uses classes, coreClasses, db, EntityServiceIntf, UIServiceIntf, variants,
  cxStyles, graphics, windows, generics.collections, sysutils, ShellIntf,
  UIClasses, StrUtils;

type
  TUICatalog = class(TComponent)
  const
    ENTC_UI = 'BFW_UI';
    ENTC_UI_VIEW_LIST = 'List';
    ENTC_UI_VIEW_CMD = 'Commands';
    ENTC_UI_VIEW_STYLES = 'Styles';
    OPTION_ENTITYNAME = 'ENTITYNAME';
    OPTION_ENTITYVIEWNAME = 'ENTITYVIEWNAME';
    OPTION_ID = 'ID';

  private
    FWorkItem: TWorkItem;
    procedure ReloadConfigurationHandler(EventData: Variant);
    class procedure LoadUI(AWorkItem: TWorkItem);
    class procedure LoadStyles(AWorkItem: TWorkItem);
    class procedure Load(AWorkItem: TWorkItem);
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;

  type
    TViewCommandExtension = class(TViewExtension, IExtensionCommand)
    private
      function GetDataValue(const AValue: string): Variant;
      procedure CmdHandlerCommand(Sender: TObject);
      procedure CmdHandlerAction(Sender: TObject);
      procedure CmdEntityOperExec(Sender: TObject);
    protected
      procedure CommandExtend;
      procedure CommandUpdate;
    public
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
//  FWorkItem.EventTopics[ET_LOAD_CONFIGURATION].AddSubscription(Self, LoadConfigurationHandler);
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
        Options.Add(OPTION_ENTITYNAME + '=' + entityName);
        Options.Add(OPTION_ENTITYVIEWNAME + '=' + entityViewName);

        //auto add primary key
{        if (entityName <> '') and (entityViewName <> '')
            and svc.EntityViewExists(entityName, entityViewName) then
        begin
          strList.Clear;
          ExtractStrings([',',';'], [],
            PWideChar(svc.Entity[entityName].Info.GetViewInfo(entityViewName).PrimaryKey), strList);
          for I := 0 to strList.Count - 1 do
            Params[strList[I]] := Unassigned;
        end;                                                     }

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

procedure TUICatalog.TViewCommandExtension.CmdEntityOperExec(Sender: TObject);
var
  intf: ICommand;
  entityName: string;
  operName: string;
  oper: IEntityOper;
  I: integer;
  confirmText: string;
  confirm: boolean;
begin
  Sender.GetInterface(ICommand, intf);


  entityName := intf.Data['ENTITY'];
  operName := intf.Data['OPER'];
  confirmText := intf.Data['CONFIRM'];
  if (confirmText <> '') then
    confirm := App.UI.MessageBox.ConfirmYesNo(confirmText)
  else
    confirm := true;

  if confirm then
  begin
    oper := App.Entities[entityName].GetOper(operName, WorkItem);
    for I := 0 to oper.Params.Count - 1 do
      oper.Params[I].Value := GetDataValue(intf.Data[oper.Params[I].Name]);

    App.UI.WaitBox.StartWait;
    try
      oper.Execute;
    finally
      App.UI.WaitBox.StopWait;
      WorkItem.Commands[COMMAND_RELOAD].Execute;
    end;
  end;

end;

procedure TUICatalog.TViewCommandExtension.CmdHandlerAction(Sender: TObject);
var
  intf: ICommand;
  actionName: string;
  action: IActivity;
  cmdData: string;
  dataList: TStringList;
  I: integer;
begin
  Sender.GetInterface(ICommand, intf);
  cmdData := intf.Data['CMD_DATA'];
  actionName := intf.Data['HANDLER'];
  intf := nil;

  action := WorkItem.Activities[actionName];

  dataList := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(cmdData), dataList);
    for I := 0 to dataList.Count - 1 do
      action.Params[dataList.Names[I]] :=  GetDataValue(dataList.ValueFromIndex[I]);
  finally
    dataList.Free;
  end;

  action.Execute(WorkItem);

end;

procedure TUICatalog.TViewCommandExtension.CmdHandlerCommand(Sender: TObject);
var
  intf: ICommand;
  cmdName: string;
  cmdData: string;
  dataList: TStringList;
  I: integer;
begin
  Sender.GetInterface(ICommand, intf);
  cmdName := intf.Data['HANDLER'];
  cmdData := intf.Data['CMD_DATA'];

  intf := WorkItem.Commands[cmdName];
  dataList := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(cmdData), dataList);
    for I := 0 to dataList.Count - 1 do
      intf.Data[dataList.Names[I]] := GetDataValue(dataList.ValueFromIndex[I]);
  finally
    dataList.Free;
  end;

  intf.Execute;

end;

procedure TUICatalog.TViewCommandExtension.CommandExtend;
const
  COMMAND_ENTITY_OPER_EXEC = 'view.commands.EntityOperExec';
var
  list: TDataSet;
  cmd: ICommand;
  handlerKind: integer;
begin
  if not Supports(GetView, ICustomView) then Exit;

  list := App.Entities[ENTC_UI].GetView(ENTC_UI_VIEW_CMD, WorkItem).Load([GetView.ViewURI]);
  while not list.Eof do
  begin
    cmd := WorkItem.Commands[list['CMD']];
    cmd.Caption := list['CAPTION'];
    cmd.Data['HANDLER'] := VarToStr(list['HANDLER']);
    cmd.Data['CMD_DATA'] := VarToStr(list['CMD_DATA']);
    cmd.Data['BINDINGPARAMS'] := VarToStr(list['PARAMS']);

    handlerKind := list['HANDLER_KIND'];

    case handlerKind of
      1: cmd.SetHandler(CmdHandlerCommand);
      2: cmd.SetHandler(CmdHandlerAction);
    end;


    if handlerKind in [1, 2] then
      (GetView as ICustomView).CommandBar.
        AddCommand(cmd.Name, VarToStr(list['GRP']), list['DEF'] = 1);

    list.Next;
  end;

  //embedded commands
  WorkItem.Commands[COMMAND_ENTITY_OPER_EXEC].SetHandler(CmdEntityOperExec);

end;

procedure TUICatalog.TViewCommandExtension.CommandUpdate;
begin

end;

function TUICatalog.TViewCommandExtension.GetDataValue(
  const AValue: string): Variant;
const
  const_WI_STATE = 'WI.';
  const_EV_VALUE = 'EV.';

var
  valueName, entityName, eviewName: string;
begin
  if AnsiStartsText(const_WI_STATE, AValue) then
    Result := WorkItem.State[StringReplace(AValue, const_WI_STATE, '', [rfIgnoreCase])]
  else if AnsiStartsText(const_EV_VALUE, AValue) then
  begin
    valueName := StringReplace(AValue, const_EV_VALUE, '', [rfIgnoreCase]);
    entityName := AnsiLeftStr(valueName, Pos('.', valueName) - 1);
    Delete(valueName, 1, Pos('.', valueName));
    eviewName := AnsiLeftStr(valueName, Pos('.', valueName) - 1);
    Delete(valueName, 1, Pos('.', valueName));
    Result := App.Entities[entityName].GetView(eviewName, WorkItem).DataSet[valueName];
  end
  else
    Result := AValue;

end;

initialization
  ColorDictionaryInit;

end.
