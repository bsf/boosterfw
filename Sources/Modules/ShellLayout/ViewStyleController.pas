unit ViewStyleController;

interface
uses classes, SysUtils, ShellIntf, cxLookAndFeels, dxSkinsCore, dxSkinsForm,
  dxSkinsDefaultPainters, dxSkinsdxNavBar2Painter, dxSkinsdxStatusBarPainter,
  dxSkinsdxBarPainter, dxSkinscxPCPainter, CoreClasses, ConfigServiceIntf,
  strUtils, forms;

type

  TViewStyleController = class(TComponent)
  private
    FWorkItem: TWorkitem;
    FSkinFile: string;
    FSkinName: string;
    FSkinFolderPath: string;
    FdxSkinController: TdxSkinController;
    procedure ProfileChangedEventHandler(EventData: Variant);
    procedure LoadSkin(const ASkinFile, ASkinName: string);
    procedure RegisterSettings;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    procedure LoadPreferences;
    procedure SavePreferences;
    procedure ResetPreferences;
    function UseSkin: boolean;
  end;

implementation

{ TViewStyleController }

constructor TViewStyleController.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FSkinFolderPath := ExtractFilePath(ParamStr(0)) + 'Skins\';
  FdxSkinController := TdxSkinController.Create(nil);
  FdxSkinController.UseSkins := false;
  FdxSkinController.SkinName := '';
  FdxSkinController.Kind := lfOffice11;
  FWorkItem.EventTopics[ET_PROFILE_CHANGED].AddSubscription(Self,
    ProfileChangedEventHandler);

  RegisterSettings;
end;

destructor TViewStyleController.Destroy;
begin
 // FdxSkinController.Free; AV !!!
  inherited;
end;

procedure TViewStyleController.LoadPreferences;
begin
  FdxSkinController.UseSkins := App.Settings['ViewStyle.SkinEnabled']= '1';
  FSkinName := App.Settings['ViewStyle.SkinName'];
  FSkinFile := App.Settings['ViewStyle.SkinName'];
  if FdxSkinController.UseSkins and (FSkinName <> '') then
    LoadSkin(FSkinFile, FSkinName);
end;

procedure TViewStyleController.LoadSkin(const ASkinFile, ASkinName: string);
var
  SkinFileName: string;
begin
  SkinFileName := FSkinFolderPath + ASkinFile + '.skinres';
  if FileExists(SkinFileName) and
     dxSkinsUserSkinLoadFromFile(SkinFileName, {ASkinName}'') then
  begin
     FdxSkinController.SkinName := 'UserSkin';
     // FdxSkinController.Refresh;
  end;
end;

procedure TViewStyleController.ProfileChangedEventHandler(
  EventData: Variant);
var
  scale: integer;
  I: integer;
begin
  if AnsiStartsText('ViewStyle', EventData) then
    LoadPreferences;
  if EventData = 'ViewStyle.Scale' then
  begin
    try
      scale := StrToInt(App.Settings['ViewStyle.Scale']);
    except
      scale := 1;
    end;

    for I := 0 to Screen.FormCount - 1 do
    begin
      case scale of
        1: Screen.Forms[I].PixelsPerInch := 96;
        2: Screen.Forms[I].PixelsPerInch := 120;
        3: Screen.Forms[I].PixelsPerInch := 144;
      else
        Screen.Forms[I].PixelsPerInch := 96;
      end;
    end
  end;
end;

procedure TViewStyleController.RegisterSettings;
begin


  with App.Settings.Add('ViewStyle.Scale') do
  begin
    Caption := 'Маштаб';
    Category := 'Вид';
    DefaultValue := '1';
    StorageLevels := [slUserProfile];
  end;
end;

procedure TViewStyleController.ResetPreferences;
begin

end;

procedure TViewStyleController.SavePreferences;
begin

end;

function TViewStyleController.UseSkin: boolean;
begin
  Result := FdxSkinController.UseSkins;  
end;

end.
