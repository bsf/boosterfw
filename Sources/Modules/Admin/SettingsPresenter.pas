unit SettingsPresenter;

interface
uses coreClasses, CustomContentPresenter, UIClasses, ShellIntf,
  sysutils, Contnrs, classes, ConfigServiceIntf, db, CommonUtils,
  dxmdaset, EntityServiceIntf, variants, AdminConst, UIStr;

const
  VIEW_SETTINGS = 'views.shell.settings';


  COMMAND_RESET_VALUE = '{B8BF4546-DB9D-49AD-A85C-6B09983931DD}';

type
  ISettingsView = interface(IContentView)
  ['{1A6A98E7-8662-4D57-AE0A-6F8899424057}']
    procedure BindAppSettingsData(ACommonData, AAliasData, AHostData: TDataSet);
    procedure BindDBSettings(AData: TDataSet);
  end;

  TSettingsPresenter = class(TCustomContentPresenter)
  private
    FCommonAppSettingsData: TdxMemData;
    FAliasAppSettingsData: TdxMemData;
    FHostAppSettingsData: TdxMemData;
    FDBSettingsData: TDataSet;
    function View: ISettingsView;
    procedure InitAppSettingsData;
    procedure AppSettingsChangedHandler(AField: TField );
    procedure LoadAppSettingValue(AField: TField; ALevel: TSettingStorageLevel);
  protected
    procedure OnInit(Sender: IActivity); override;
    procedure OnViewReady; override;
    procedure OnViewClose; override;
  end;

implementation

{ TSettingsPresenter }

procedure TSettingsPresenter.AppSettingsChangedHandler(
  AField: TField);

  procedure ReloadSettingValue(AData: TDataSet; ASettingName: string; ALevel: TSettingStorageLevel);
  var
    field: TField;
    setting: ISetting;
  begin
    field := AData.FindField(NormalizeComponentName(ASettingName));
    if Assigned(field) then
    begin
      setting := App.Settings.GetItemByName(ASettingName);
      field.OnChange := nil;
      AData.Edit;
      //field.Value := setting.GetStoredValue(ALevel);
      LoadAppSettingValue(field, ALevel);
      AData.Post;
      field.OnChange := AppSettingsChangedHandler;

      field.Tag := 0;
      if setting.GetStoredLevel(ALevel) = ALevel then field.Tag := 1;
    end;
  end;

var
  storageLevel: TSettingStorageLevel;
begin
  storageLevel := slNone;

  if AField.DataSet = FCommonAppSettingsData then
    storageLevel := slDefault
  else if AField.DataSet = FAliasAppSettingsData then
    storageLevel := slAlias
  else if AField.DataSet = FHostAppSettingsData then
    storageLevel := slHostProfile;

  App.Settings.GetItemByName(AField.Origin).SetStoredValue(VarToStr(AField.Value), storageLevel);

  if storageLevel = slDefault then
  begin
    ReloadSettingValue(FCommonAppSettingsData, AField.Origin, slDefault);
    ReloadSettingValue(FAliasAppSettingsData, AField.Origin, slAlias);
    ReloadSettingValue(FHostAppSettingsData, AField.Origin, slHostProfile);
  end
  else if storageLevel = slAlias then
  begin
    ReloadSettingValue(FAliasAppSettingsData, AField.Origin, slAlias);
    ReloadSettingValue(FHostAppSettingsData, AField.Origin, slHostProfile);
  end
  else if storageLevel = slHostProfile then
    ReloadSettingValue(FHostAppSettingsData, AField.Origin, slHostProfile);


end;

procedure TSettingsPresenter.InitAppSettingsData;

  procedure CreateField(AData: TDataSet; ASetting: ISetting);
  var
    field: TField;
  begin
    case ASetting.Editor of
      seInteger: field := TIntegerField.Create(Self);
      seString: field := TStringField.Create(Self);
      seBoolean: field := TIntegerField.Create(Self);
     // peNone: prmField := TVariantField.Create(Self); not supported by TdxMemData
    else
      field := TStringField.Create(Self);
    end;

    if field is TStringField then
    begin
      TStringField(field).DisplayWidth := 255;
      TStringField(field).Size := 255;
    end;

    field.DisplayLabel := ASetting.Caption;
    field.Origin := ASetting.Name;
    field.FieldName := NormalizeComponentName(ASetting.Name);
    field.DataSet := AData;
    field.Alignment := taLeftJustify;
    SetFieldAttribute(field, FIELD_ATTR_BAND, ASetting.Category);

    case ASetting.Editor of
      seBoolean: SetFieldAttribute(field, FIELD_ATTR_EDITOR, FIELD_ATTR_EDITOR_CHECKBOX);
    end;
  end;

  procedure InitData(AData: TDataSet; ALevel: TSettingStorageLevel);
  var
    I: integer;
    setting: ISetting;
  begin
    for I := 0 to App.Settings.Count - 1 do
      if ALevel in App.Settings.GetItem(I).StorageLevels then
        CreateField(AData, App.Settings.GetItem(I));

    AData.Open;
    AData.Insert;
    AData.Post;

    AData.Edit;
    for I := 1 to AData.FieldCount - 1 do // exclude REC_ID dxMem's field
    begin
      setting := App.Settings.GetItemByName(AData.Fields[I].Origin);
      LoadAppSettingValue(AData.Fields[I], ALevel);
      //AData.Fields[I].Value := setting.GetStoredValue(ALevel);
      if setting.GetStoredLevel(ALevel) = ALevel then AData.Fields[I].Tag := 1;
    end;
    AData.Post;

    for I := 1 to AData.FieldCount - 1 do // exclude REC_ID dxMem's field
      AData.Fields[I].OnChange := AppSettingsChangedHandler;
  end;

begin
  FCommonAppSettingsData := TdxMemData.Create(Self);
  InitData(FCommonAppSettingsData, slDefault);

  FAliasAppSettingsData := TdxMemData.Create(Self);
  InitData(FAliasAppSettingsData, slAlias);

  FHostAppSettingsData := TdxMemData.Create(Self);
  InitData(FHostAppSettingsData, slHostProfile);
end;

procedure TSettingsPresenter.LoadAppSettingValue(AField: TField; ALevel: TSettingStorageLevel);
var
  setting: ISetting;
begin
  setting := App.Settings.GetItemByName(AField.Origin);
  case setting.Editor of
    seBoolean:
      AField.Value := StrToIntDef(setting.GetStoredValue(ALevel), 0);
    else
      AField.Value := setting.GetStoredValue(ALevel);
  end;
end;

procedure TSettingsPresenter.OnInit(Sender: IActivity);
begin
  InitAppSettingsData;
  FDBSettingsData := App.Entities.Settings.GetCommonSettings(WorkItem);
end;

procedure TSettingsPresenter.OnViewClose;
  procedure PostEditData(AData: TDataSet);
  begin
    if AData.State in [dsEdit] then
    try
      AData.Post;
    except
      AData.Cancel;
      raise;
    end;
  end;

begin
  PostEditData(FCommonAppSettingsData);
  PostEditData(FAliasAppSettingsData);
  PostEditData(FHostAppSettingsData);
  PostEditData(FDBSettingsData);
end;

procedure TSettingsPresenter.OnViewReady;
begin
  ViewTitle := GetLocaleString(@VIEW_SETTINGS_CAPTION);

  View.CommandBar.AddCommand(COMMAND_CLOSE,
    GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

  View.BindAppSettingsData(FCommonAppSettingsData,
    FAliasAppSettingsData, FHostAppSettingsData);

  View.BindDBSettings(FDBSettingsData);    
end;

function TSettingsPresenter.View: ISettingsView;
begin
  Result := GetView as ISettingsView;
end;

end.
