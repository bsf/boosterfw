unit UserPreferencesPresenter;
interface
uses coreClasses, CustomContentPresenter, CommonViewIntf, cxCustomData, ShellIntf,
  cxVGrid, sysutils, Contnrs, classes, ConfigServiceIntf, db, CommonUtils,
  dxmdaset, EntityServiceIntf, variants;

const
  URI_USERPREFERENCES = 'views.shell.userpreferences';
  COMMAND_RESET_VALUE = '{B8BF4546-DB9D-49AD-A85C-6B09983931DD}';

type
  IUserPreferencesView = interface(IContentView)
  ['{DC531533-08E8-4F57-9295-E17D3A5B8997}']
    procedure BindAppPreferences(AData: TDataSet);
    procedure BindDBPreferences(AData: TDataSet);
    function GetSelectedAppSetting: string;
  end;

  TUserPreferencesPresenter = class(TCustomContentPresenter)
  private
    FAppPreferencesData: TdxMemData;
    FDBPreferencesData: TDataSet;
    procedure CmdResetValue(Sender: TObject);
    function View: IUserPreferencesView;
    procedure InitAppPreferencesData;
    procedure AppPreferencesChangedHandler(AField: TField);
    procedure LoadAppPreferenceValue(AField: TField);
  protected
    procedure OnInit(Sender: IAction); override;
    procedure OnViewReady; override;
    procedure OnViewClose; override;
  end;

implementation

{ TUserPreferencesPresenter }

procedure TUserPreferencesPresenter.AppPreferencesChangedHandler(
  AField: TField);
var
  setting: ISetting;
begin
  setting := App.Settings.GetItemByName(AField.Origin);
  setting.SetStoredValue(VarToStr(AField.Value), slUserProfile);

  AField.OnChange := nil;
  LoadAppPreferenceValue(AField);
  AField.OnChange := AppPreferencesChangedHandler;

  AField.Tag := 0;
  if setting.GetStoredLevel(slUserProfile) = slUserProfile then AField.Tag := 1;

end;

procedure TUserPreferencesPresenter.CmdResetValue(Sender: TObject);
begin
 // GetView.GetFocusedField()
end;

procedure TUserPreferencesPresenter.InitAppPreferencesData;

  procedure CreateField(ASetting: ISetting);
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
    field.DataSet := FAppPreferencesData;
    field.Alignment := taLeftJustify;
    SetFieldAttribute(field, FIELD_ATTR_BAND, ASetting.Category);
    if ASetting.GetStoredLevel(slUserProfile) = slUserProfile then field.Tag := 1;
    //field.OnChange := AppPreferenceChangedHandler;

    case ASetting.Editor of
      seBoolean: SetFieldAttribute(field, FIELD_ATTR_EDITOR, FIELD_ATTR_EDITOR_CHECKBOX);
    end;
  end;

var
  I: integer;
begin
  FAppPreferencesData := TdxMemData.Create(Self);
  for I := 0 to App.Settings.Count - 1 do
    if slUserProfile in App.Settings.GetItem(I).StorageLevels then
      CreateField(App.Settings.GetItem(I));

  FAppPreferencesData.Open;
  FAppPreferencesData.Insert;
  FAppPreferencesData.Post;

  FAppPreferencesData.Edit;
  for I := 1 to FAppPreferencesData.FieldCount - 1 do // exlude REC_ID dxMem field
    LoadAppPreferenceValue(FAppPreferencesData.Fields[I]);
       //App.Settings.GetItemByName(FAppPreferencesData.Fields[I].Origin).GetStoredValue(slUserProfile));
  FAppPreferencesData.Post;


  for I := 1 to FAppPreferencesData.FieldCount - 1 do // exlude REC_ID dxMem field
    FAppPreferencesData.Fields[I].OnChange := AppPreferencesChangedHandler;

end;

procedure TUserPreferencesPresenter.LoadAppPreferenceValue(AField: TField);
var
  setting: ISetting;
begin
  setting := App.Settings.GetItemByName(AField.Origin);
  case setting.Editor of
    seBoolean:
      AField.Value := StrToIntDef(setting.GetStoredValue(slUserProfile), 0);
    else
      AField.Value := setting.GetStoredValue(slUserProfile);
  end;
end;

procedure TUserPreferencesPresenter.OnInit(Sender: IAction);
begin
  FreeOnViewClose := true;
  InitAppPreferencesData;
  FDBPreferencesData := App.Entities.Settings.GetUserPreferences(WorkItem);
end;

procedure TUserPreferencesPresenter.OnViewClose;
begin
  if FAppPreferencesData.State in [dsEdit] then
    try
      FAppPreferencesData.Post;
    except
      FAppPreferencesData.Cancel;
      raise;
    end;

  if FDBPreferencesData.State in [dsEdit] then
    try
      FDBPreferencesData.Post;
    except
      FDBPreferencesData.Cancel;
      raise;
    end;

end;

procedure TUserPreferencesPresenter.OnViewReady;
begin
  ViewTitle := '������������';

  View.CommandBar.AddCommand(COMMAND_CLOSE, COMMAND_CLOSE_CAPTION,
    COMMAND_CLOSE_SHORTCUT, CmdClose);

  View.CommandBar.AddCommand(COMMAND_RESET_VALUE, '��������', '', CmdResetValue);

  View.BindAppPreferences(FAppPreferencesData);
  View.BindDBPreferences(FDBPreferencesData);
end;

function TUserPreferencesPresenter.View: IUserPreferencesView;
begin
  Result := GetView as IUserPreferencesView;
end;


end.
