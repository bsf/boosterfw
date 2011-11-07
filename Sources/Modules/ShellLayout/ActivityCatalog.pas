unit ActivityCatalog;

interface
uses classes, coreClasses, db, EntityServiceIntf, variants;

type
  TActivityCatalog = class(TComponent)
  const
    ENTC_UI = 'ENTC_UI';
    ENTC_UI_VIEW_LIST = 'List';
    ENTC_UI_VIEW_CMD = 'Commands';
    OPTION_ENTITYNAME = 'ENTITYNAME';
    OPTION_ENTITYVIEWNAME = 'ENTITYVIEWNAME';

  private
    FWorkItem: TWorkItem;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    procedure Load;

  end;

implementation

{ TActivityCatalog }

constructor TActivityCatalog.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
end;

procedure TActivityCatalog.Load;
var
  I: integer;
  list: TDataSet;
  svc: IEntityManagerService;
  strList: TStringList;
begin
  strList := TStringList.Create;
  try
    svc := FWorkItem.Services[IEntityManagerService] as IEntityManagerService;
    list := svc.Entity[ENTC_UI].GetView(ENTC_UI_VIEW_LIST, FWorkItem).Load([]);
    while not list.Eof do
    begin
      with FWorkItem.Activities[list['URI']] do
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
