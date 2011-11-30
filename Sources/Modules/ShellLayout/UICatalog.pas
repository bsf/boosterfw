unit UICatalog;

interface
uses classes, coreClasses, db, EntityServiceIntf, UIServiceIntf, variants,
  cxStyles, graphics, windows;

type
  TUICatalog = class(TComponent)
  const
    ENTC_UI = 'ENTC_UI';
    ENTC_UI_VIEW_LIST = 'List';
    ENTC_UI_VIEW_CMD = 'Commands';
    ENTC_UI_VIEW_STYLES = 'Styles';
    OPTION_ENTITYNAME = 'ENTITYNAME';
    OPTION_ENTITYVIEWNAME = 'ENTITYVIEWNAME';

  private
    class procedure LoadUI(AWorkItem: TWorkItem);
    class procedure LoadStyles(AWorkItem: TWorkItem);
  public
    class procedure Load(AWorkItem: TWorkItem);

  end;

implementation

{ TActivityCatalog }


class procedure TUICatalog.Load(AWorkItem: TWorkItem);
begin
  LoadUI(AWorkItem);
  LoadStyles(AWorkItem);
end;

class procedure TUICatalog.LoadStyles(AWorkItem: TWorkItem);

  procedure ColorSet(const AValue: string; AStyle: TcxStyle);
  begin
    AStyle.Color := clInfoBk;
  end;

  procedure FontStyleSet(const AValue: string; AStyle: TcxStyle);
  begin
    if AValue = 'Bold' then
      AStyle.Font.Style := [fsBold];
  end;

var
  I: integer;
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
      strList.Clear;
      ExtractStrings([';'], [], PWideChar(VarToStr(ds['OPTIONS'])), strList);

      ColorSet(strList.Values['Color'], style);
      FontStyleSet(strList.Values['Font.Style'], style);

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
        ActivityClass := list['UIClass'];
        Title := list['Title'];
        Group := VarToStr(list['GRP']);
        MenuIndex := list['MENUIDX'];
        UsePermission := list['USEPERM'] = 1;

        strList.Clear;
        ExtractStrings([';'], [], PWideChar(VarToStr(list['OPTIONS'])), strList);
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

end.
