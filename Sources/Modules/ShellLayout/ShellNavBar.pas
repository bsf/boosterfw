unit ShellNavBar;

interface

uses classes, types, ViewStyleController, dxNavBar, dxNavBarGroupItems, dxNavBarCollns,
  sysutils, controls, CoreClasses, Graphics, cxGraphics, IniFiles,
  windows, menus, cxLookAndFeels, ShellIntf;

const
  DefNavView = 13;
  DefExpView = 16;
  SkinNavView = 15;
  SkinExpView = 14;
  PreferencePath = '\Shell\NavBar\';
  PreferenceFile = 'NavBar';

type
  TNavBarItemInfo = class(TComponent)
  const INSTANCE_NAME = 'ItemInfo';
  public
    URI: string;
  end;

  TdxNavBarControlManager = class(TComponent)
  private
    FScaleM: integer;
    FScaleD: integer;
    FImageList: TcxImageList;
    FNavBar: TdxNavBar;
    FWorkItem: TWorkItem;
    FLookAndFeelListener: TcxLookAndFeel;
    procedure LookAndFeelChangedHandler(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues);
    procedure LoadPreferenceFromFile(AFile: TMemIniFile);
    procedure SavePreferenceToFile(AFile: TMemIniFile);
    procedure ScaleByCategory(ACategory: TdxNavBarGroup; M, D: integer);


    procedure NavBarItemClickHandler(Sender: TObject; ALink: TdxNavBarItemLink);
    function FindOrCreateCategory(const ACaption: string): TdxNavBarGroup;
    function FindOrCreateGroup(const ACaption: string; ACategory: TdxNavBarGroup): TdxNavBarGroup;

  public
    constructor Create(AOwner: TComponent; ANavBar: TdxNavBar;
      AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    procedure ScaleBy(M, D: integer);
    procedure SavePreference;
    procedure LoadPreference;
    procedure BuildMainMenu;
  end;




implementation

{ TdxNavBarControlManager }

constructor TdxNavBarControlManager.Create(AOwner: TComponent;
  ANavBar: TdxNavBar; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FNavBar := ANavBar;
  FWorkItem := AWorkItem;
  FImageList := TcxImageList(FNavBar.OptionsImage.LargeImages);
  if not Assigned(FImageList) then
    raise Exception.Create('NavBar ImageList not present');


  FLookAndFeelListener := TcxLookAndFeel.Create(Self);
  FLookAndFeelListener.OnChanged := LookAndFeelChangedHandler;

  if cxLookAndFeels.cxUseSkins then
    FNavBar.View := SkinNavView
  else
    FNavBar.View := DefNavView;


  FScaleM := 100;
  FScaleD := 100;

end;


procedure TdxNavBarControlManager.BuildMainMenu;

  procedure AddItem(Activity: IActivity; Group: TdxNavBarGroup);
  var
    categoryNavBar: TdxNavBar;
    dxItem: TdxNavBarItem;
    ItemInfo: TNavBarItemInfo;
  begin
    categoryNavBar := TdxNavBar(Group.Collection.Owner);

    if (Group.LinkCount > 0) and Activity.OptionExists('BeginSection') then
    begin
      dxItem := categoryNavBar.Items.Add(TdxNavBarSeparator);
      Group.CreateLink(dxItem);
    end;

    dxItem := categoryNavBar.Items.Add;
    dxItem.Caption := Activity.Title;
    if not Activity.Image.Empty then
      dxItem.SmallImageIndex :=
        categoryNavBar.SmallImages.AddMasked(Activity.Image, clDefault);

    Group.CreateLink(dxItem);

    ItemInfo := TNavBarItemInfo.Create(dxItem);
    ItemInfo.Name := TNavBarItemInfo.INSTANCE_NAME;
    ItemInfo.URI := Activity.URI;
  end;

var
  activity: IActivity;
  I: integer;
  category: TdxNavBarGroup;
begin

  category := FindOrCreateCategory('Главное меню');

  for I := 0 to FWorkItem.Activities.Count - 1 do
  begin
    activity := FWorkItem.Activities.GetItem(I);

    if (activity.Group <> '') and (activity.MenuIndex > -1) and activity.HavePermission then
      AddItem(activity, FindOrCreateGroup(activity.Group, category));
  end;
end;

function TdxNavBarControlManager.FindOrCreateCategory(
  const ACaption: string): TdxNavBarGroup;
var
  dxCategoryNavBar: TdxNavBar;
  I: integer;
begin
  for I := 0 to FNavBar.Groups.Count -  1 do
  begin
    Result := FNavBar.Groups[I];
    if SameText(Result.Caption, ACaption) then Exit;
  end;

  Result := FNavBar.Groups.Add;

  Result.OptionsGroupControl.UseControl := true;
  Result.Control.UseStyle := true;
  Result.UseSmallImages := false;
  dxCategoryNavBar := TdxNavBar.Create(Result.Control); //Parent and Owner must be equal !
  dxCategoryNavBar.Name := 'NavBar';
  dxCategoryNavBar.OnLinkClick := NavBarItemClickHandler;

  if cxLookAndFeels.cxUseSkins then
    dxCategoryNavBar.View := SkinExpView
  else
    dxCategoryNavBar.View := DefExpView;

  dxCategoryNavBar.SmallImages := FNavBar.SmallImages;

  dxCategoryNavBar.Align := alClient;
  dxCategoryNavBar.Parent := Result.Control;
  dxCategoryNavBar.TabStop := true;
  dxCategoryNavBar.OptionsBehavior.Common.DragDropFlags :=
    dxCategoryNavBar.OptionsBehavior.Common.DragDropFlags - [fAllowDragGroup, fAllowDragLink];

  Result.Caption := ACaption;

{  if not ACategory.GetImage.Empty then
  begin
    dxCategory.LargeImageIndex :=
      FImageList.AddMasked(ACategory.GetImage, clDefault);
    FNavBar.SmallImages.AddMasked(ACategory.GetImage, clDefault);
  end;
 }
  ScaleByCategory(Result, FScaleM, FScaleD);


end;

function TdxNavBarControlManager.FindOrCreateGroup(const ACaption: string;
  ACategory: TdxNavBarGroup): TdxNavBarGroup;
var
  dxCategoryNavBar: TdxNavBar;
  I: integer;
begin
  dxCategoryNavBar := TdxNavBar(ACategory.Control.FindComponent('NavBar'));

  for I := 0 to dxCategoryNavBar.Groups.Count -  1 do
  begin
    Result := dxCategoryNavBar.Groups[I];
    if SameText(Result.Caption, ACaption) then Exit;
  end;

  Result := dxCategoryNavBar.Groups.Add;
  Result.Caption := ACaption;
end;

procedure TdxNavBarControlManager.NavBarItemClickHandler(Sender: TObject;
  ALink: TdxNavBarItemLink);
var
  uri: string;
begin
  uri := TNavBarItemInfo(ALink.Item.FindComponent(TNavBarItemInfo.INSTANCE_NAME)).URI;
//  FWorkItem.Actions[uri].Execute(FWorkItem);
  FWorkItem.Activities[uri].Execute(FWorkItem);
end;


procedure TdxNavBarControlManager.LookAndFeelChangedHandler(
  Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
var
  I: integer;
  idxViewStyleNav: integer;
  idxViewStyleExp: integer;
  dxCategoryNavBar: TComponent;
begin
  if Sender.SkinName <> '' then
  begin
    idxViewStyleNav := SkinNavView;
    idxViewStyleExp := SkinExpView;
  end
  else
  begin
    idxViewStyleNav := DefNavView;
    idxViewStyleExp := DefExpView;
  end;

  FNavBar.View := idxViewStyleNav;

  for I := 0 to FNavBar.Groups.Count - 1 do
  begin
    if assigned(FNavBar.Groups[I].Control) then
    begin
      dxCategoryNavBar := FNavBar.Groups[I].Control.FindComponent('NavBar');
      if Assigned(dxCategoryNavBar) then
        TdxNavBar(dxCategoryNavBar).View := idxViewStyleExp;
    end;
  end;

  ScaleBy(FScaleM, FScaleD);
end;

destructor TdxNavBarControlManager.Destroy;
begin
  FLookAndFeelListener.Free;
  inherited;
end;

procedure TdxNavBarControlManager.LoadPreference;
var
  stream: TMemoryStream;
  iniFile: TMemIniFile;
  content: TStringList;
begin
  stream := TMemoryStream.Create;
  iniFile := TMemIniFile.Create('');
  content := TStringList.Create;
  try
    App.UserProfile.LoadData(ShellIntf.PROFILE_VIEW_PREFERENCE_STORAGE + PreferencePath,
      PreferenceFile, stream);
    stream.Position := 0;
    content.LoadFromStream(stream);
    iniFile.SetStrings(content);
    LoadPreferenceFromFile(iniFile);
  finally
    stream.Free;
    iniFile.Free;
    content.Free;
  end;
end;

procedure TdxNavBarControlManager.SavePreference;
var
  stream: TMemoryStream;
  iniFile: TMemIniFile;
  content: TStringList;
begin
  stream := TMemoryStream.Create;
  iniFile := TMemIniFile.Create('');
  content := TStringList.Create;
  try
    SavePreferenceToFile(iniFile);
    iniFile.GetStrings(content);
    content.SaveToStream(stream);
    stream.Position := 0;
    App.UserProfile.SaveData(ShellIntf.PROFILE_VIEW_PREFERENCE_STORAGE + PreferencePath,
      PreferenceFile, stream);
  finally
    stream.Free;
    iniFile.Free;
    content.Free;
  end;
end;

procedure TdxNavBarControlManager.LoadPreferenceFromFile(AFile: TMemIniFile);
var
  I, Y: integer;
  ChildNavBar: TdxNavBar;
  ParentGroupID: string;
  ChildGroupID: string;
  ChildGroupSection: string;
begin
  FNavBar.ActiveGroupIndex :=
    AFile.ReadInteger('Common', 'ActiveGroupIndex', 0);

  FNavBar.Width :=
    AFile.ReadInteger('Common', 'Width', 300);
  FNavBar.OptionsBehavior.NavigationPane.Collapsed :=
    AFile.ReadBool('Common', 'Collapsed', false);

  for I := 0 to FNavBar.Groups.Count - 1 do
  begin
    ParentGroupID := FNavBar.Groups[I].Caption;
    if not Assigned(FNavBar.Groups[I].Control) then Continue;

    ChildNavBar := TdxNavBar(FNavBar.Groups[I].Control.FindComponent('NavBar'));
    if not Assigned(ChildNavBar) then Continue;

    for Y := 0 to ChildNavBar.Groups.Count - 1 do
    begin
      ChildGroupID := ChildNavBar.Groups[Y].Caption;
      ChildGroupSection := 'Group.' + ParentGroupID + '.' + ChildGroupID;

      ChildNavBar.Groups[Y].Expanded :=
        AFile.ReadBool(ChildGroupSection, 'Expanded', true);

    end;
  end;

  if not FNavBar.OptionsView.Common.ShowGroupCaptions then
    FNavBar.ActiveGroupIndex := 0;
end;

procedure TdxNavBarControlManager.SavePreferenceToFile(AFile: TMemIniFile);
var
  I, Y: integer;
  ChildNavBar: TdxNavBar;
  ParentGroupID: string;
  ChildGroupID: string;
  ChildGroupSection: string;

begin
  AFile.WriteInteger('Common', 'ActiveGroupIndex', FNavBar.ActiveGroupIndex);
  AFile.WriteInteger('Common', 'Width', FNavBar.Width);
  AFile.WriteBool('Common', 'Collapsed',
    FNavBar.OptionsBehavior.NavigationPane.Collapsed);

  for I := 0 to FNavBar.Groups.Count - 1 do
  begin
    ParentGroupID := FNavBar.Groups[I].Caption;
    if not Assigned(FNavBar.Groups[I].Control) then Continue;

    ChildNavBar := TdxNavBar(FNavBar.Groups[I].Control.FindComponent('NavBar'));
    if not Assigned(ChildNavBar) then Continue;

    for Y := 0 to ChildNavBar.Groups.Count - 1 do
    begin
      ChildGroupID := ChildNavBar.Groups[Y].Caption;
      ChildGroupSection := 'Group.' + ParentGroupID + '.' + ChildGroupID;

      AFile.WriteBool(ChildGroupSection, 'Expanded', ChildNavBar.Groups[Y].Expanded);

    end;
  end;

end;

procedure TdxNavBarControlManager.ScaleBy(M, D: integer);
var
  I: integer;
begin
  FScaleM := M;
  FScaleD := D;

  for I := 0 to FNavBar.OptionsStyle.DefaultStyles.DefaultStyleCount - 1 do
    FNavBar.OptionsStyle.DefaultStyles.DefaultStyles[I].Font.Size :=
       MulDiv(
        FNavBar.OptionsStyle.DefaultStyles.DefaultStyles[I].Font.Size, FScaleM, FScaleD);

  for I := 0 to FNavBar.Groups.Count - 1 do
    ScaleByCategory(FNavBar.Groups[I], FScaleM, FScaleD);
end;

procedure TdxNavBarControlManager.ScaleByCategory(ACategory: TdxNavBarGroup; M, D: integer);
var
  dxCategoryNavBar: TdxNavBar;
  I: integer;
begin
  dxCategoryNavBar := TdxNavBar(ACategory.Control.FindComponent('NavBar'));
  for I := 0 to dxCategoryNavBar.OptionsStyle.DefaultStyles.DefaultStyleCount - 1 do
    dxCategoryNavBar.OptionsStyle.DefaultStyles.DefaultStyles[I].Font.Size :=
       MulDiv(
        dxCategoryNavBar.OptionsStyle.DefaultStyles.DefaultStyles[I].Font.Size, M, D);
end;




end.
