unit ShellNavBar;

interface

uses classes, types, ViewStyleController, dxNavBar, dxNavBarGroupItems, dxNavBarCollns,
  sysutils, controls, CoreClasses, Graphics, cxGraphics, IniFiles,
  NavBarServiceIntf, windows, menus, cxLookAndFeels, ShellIntf;

const
  DefNavView = 13;
  DefExpView = 16;
  SkinNavView = 15;
  SkinExpView = 14;
  PreferencePath = '\Shell\NavBar\';
  PreferenceFile = 'NavBar';

type
  TNavBarItemLinkControlInfo = class(TComponent)
  private
    FItemID: string;
    FNavBar: TdxNavBar;
  end;

  TdxNavBarControlManager = class(TComponent, INavBarControlManager)
  private
    FScaleM: integer;
    FScaleD: integer;
    FImageList: TcxImageList;
    FNavBar: TdxNavBar;
    FWorkItem: TWorkItem;
    FItemMenu: TPopupMenu;
    FItemLinkSubItemsCallback: TNavBarItemLinkSubItemsCallback;
    FLookAndFeelListener: TcxLookAndFeel;
    function FindCategoryControl(ACategory: INavBarCategory): TdxNavBarGroup;
    function FindGroupControl(AGroup: INavBarGroup): TdxNavBarGroup;
    function FindItemLinkControl(AItemLink: INavBarItemLink): TdxNavBarItemLink;
    procedure ShiftImageIndex(ARemoveIndex: integer);
    procedure NavBarLinkClickHandler(Sender: TObject; ALink: TdxNavBarItemLink);
    function IsControlKeyDown: boolean;
    procedure ShowItemLinkSubItems(ALink: TdxNavBarItemLink);
    function GetItemLinkInfo(ALink: TdxNavBarItemLink): TNavBarItemLinkControlInfo;
    procedure LookAndFeelChangedHandler(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues);
    procedure LoadPreferenceFromFile(AFile: TMemIniFile);
    procedure SavePreferenceToFile(AFile: TMemIniFile);
    procedure ScaleByCategory(ACategory: TdxNavBarGroup; M, D: integer);
  protected
    procedure AddCategory(ACategory: INavBarCategory);
    procedure RemoveCategory(ACategory: INavBarCategory);
    procedure ChangeCategory(ACategory: INavBarCategory);
    procedure AddGroup(AGroup: INavBarGroup);
    procedure RemoveGroup(AGroup: INavBarGroup);
    procedure AddItemLink(AItemLink: INavBarItemLink);
    procedure RemoveItemLink(AItemLink: INavBarItemLink);
    procedure ChangeItemLink(AItemLink: INavBarItemLink);
    procedure RemoveAllItems;
    procedure SetItemLinkSubItemsCallback(Value: TNavBarItemLinkSubItemsCallback);
    //CustomDraw
    procedure OnCustomDrawGroupCaption(Sender: TObject;
         ACanvas: TCanvas; AViewInfo: TdxNavBarGroupViewInfo; var AHandled: Boolean);
  public
    constructor Create(AOwner: TComponent; ANavBar: TdxNavBar;
      AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    procedure ScaleBy(M, D: integer);
    procedure SavePreference;
    procedure LoadPreference;
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

  FItemMenu := TPopupMenu.Create(Self);

  FScaleM := 100;
  FScaleD := 100;
end;

procedure TdxNavBarControlManager.AddCategory(ACategory: INavBarCategory);
var
  dxCategory: TdxNavBarGroup;
  dxCategoryNavBar: TdxNavBar;
begin
  dxCategory := FNavBar.Groups.Add;

  dxCategory.OptionsGroupControl.UseControl := true;
  dxCategory.Control.UseStyle := true;
  dxCategory.UseSmallImages := false;
  dxCategoryNavBar := TdxNavBar.Create(dxCategory.Control); //Parent and Owner must be equal !
  dxCategoryNavBar.Name := 'NavBar';

  if cxLookAndFeels.cxUseSkins then
    dxCategoryNavBar.View := SkinExpView
  else
    dxCategoryNavBar.View := DefExpView;

  dxCategoryNavBar.SmallImages := FNavBar.SmallImages;
    //TcxImageList.Create(dxCategoryNavBar);
  //dxCategoryNavBar.SmallImages.BkColor := clNone;
  //dxCategoryNavBar.SmallImages.BlendColor := clNone;

  dxCategoryNavBar.Align := alClient;
  dxCategoryNavBar.Parent := dxCategory.Control;
  dxCategoryNavBar.TabStop := true;
  dxCategoryNavBar.OptionsBehavior.Common.DragDropFlags :=
    dxCategoryNavBar.OptionsBehavior.Common.DragDropFlags - [fAllowDragGroup, fAllowDragLink];

  dxCategory.Caption := ACategory.Caption;

  if not ACategory.GetImage.Empty then
  begin
    dxCategory.LargeImageIndex :=
      FImageList.AddMasked(ACategory.GetImage, clDefault);
    FNavBar.SmallImages.AddMasked(ACategory.GetImage, clDefault);
  end;

  ScaleByCategory(dxCategory, FScaleM, FScaleD);

end;

procedure TdxNavBarControlManager.AddGroup(AGroup: INavBarGroup);
var
  dxCategory: TdxNavBarGroup;
  dxCategoryNavBar: TdxNavBar;
  dxGroup: TdxNavBarGroup;
begin
  dxCategory := FindCategoryControl(AGroup.Category);
  dxCategoryNavBar := TdxNavBar(dxCategory.Control.FindComponent('NavBar'));

  dxGroup := dxCategoryNavBar.Groups.Add;
  dxGroup.Caption := AGroup.Caption;
  dxGroup.Visible := false;
end;


procedure TdxNavBarControlManager.AddItemLink(AItemLink: INavBarItemLink);
var
  dxGroup: TdxNavBarGroup;
  dxCategoryNavBar: TdxNavBar;
  dxItem: TdxNavBarItem;
  ItemInfo: TNavBarItemLinkControlInfo;
begin
  dxGroup := FindGroupControl(AItemLink.Group);
  dxCategoryNavBar := TdxNavBar(
     FindCategoryControl(AItemLink.Group.Category).Control.FindComponent('NavBar'));


  if (dxGroup.LinkCount > 0) and  (AItemLink.SectionIndex <> 0) then
  begin
    dxItem := dxCategoryNavBar.Items.Add(TdxNavBarSeparator);
    dxGroup.CreateLink(dxItem);
  end;

  dxItem := dxCategoryNavBar.Items.Add;
  dxItem.Caption := AItemLink.Caption;
  if not AItemLink.Image.Empty then
    dxItem.SmallImageIndex :=
      dxCategoryNavBar.SmallImages.AddMasked(AItemLink.Image, clDefault);

  dxGroup.CreateLink(dxItem);
  dxGroup.Visible := true;

  ItemInfo := TNavBarItemLinkControlInfo.Create(dxItem);
  ItemInfo.Name := 'ItemLinkInfo';
  ItemInfo.FItemID := AItemLink.ItemID;
  ItemInfo.FNavBar := dxCategoryNavBar;
  dxCategoryNavBar.OnLinkClick := NavBarLinkClickHandler;
end;

procedure TdxNavBarControlManager.RemoveGroup(AGroup: INavBarGroup);
begin
  FindGroupControl(AGroup).Free;
end;

procedure TdxNavBarControlManager.RemoveItemLink(
  AItemLink: INavBarItemLink);
var
  dxGroup: TdxNavBarGroup;
begin
  dxGroup := FindGroupControl(AItemLink.Group);
  FindItemLinkControl(AItemLink).Free;
  dxGroup.Visible := dxGroup.LinkCount > 0;
end;

procedure TdxNavBarControlManager.RemoveCategory(
  ACategory: INavBarCategory);
var
  ImageIdx: integer;
  dxCategory: TdxNavBarGroup;
begin
  dxCategory := FindCategoryControl(ACategory);
  ImageIdx := dxCategory.LargeImageIndex;
  if ImageIdx > -1 then
    ShiftImageIndex(ImageIdx);
  dxCategory.Free;  
end;

procedure TdxNavBarControlManager.RemoveAllItems;
begin
  FNavBar.Groups.Clear;
  FNavBar.Items.Clear;
  FImageList.Clear;
end;

procedure TdxNavBarControlManager.ChangeCategory(ACategory: INavBarCategory);
var
  ImageIdx: integer;
  dxCategory: TdxNavBarGroup;
begin
  dxCategory := FindCategoryControl(ACategory);
  ImageIdx := dxCategory.LargeImageIndex;

  if (ImageIdx = -1) and (not ACategory.GetImage.Empty) then //Add
    dxCategory.LargeImageIndex := FImageList.AddMasked(ACategory.GetImage, clDefault)
  else if (ImageIdx <> -1) and (not ACategory.GetImage.Empty) then //Replace
    FImageList.ReplaceMasked(ImageIdx, ACategory.GetImage, clDefault)
  else if (ImageIdx <> -1) and (ACategory.GetImage.Empty) then //Clear
  begin
    dxCategory.LargeImageIndex := -1;
    FImageList.Delete(ImageIdx);
    ShiftImageIndex(ImageIdx);
  end;
end;


procedure TdxNavBarControlManager.ChangeItemLink(
  AItemLink: INavBarItemLink);
begin

end;

function TdxNavBarControlManager.FindCategoryControl(
  ACategory: INavBarCategory): TdxNavBarGroup;
var
  I: integer;
begin
  for I := 0 to FNavBar.Groups.Count -  1 do
  begin
    Result := FNavBar.Groups[I];
    if SameText(Result.Caption, ACategory.Caption) then Exit;
  end;

  raise Exception.CreateFmt('NavBar Category %s not found', [ACategory.Caption]);
end;



procedure TdxNavBarControlManager.ShiftImageIndex(ARemoveIndex: integer);
var
  I: integer;
begin
  if ARemoveIndex = -1 then Exit;

  for I := 0 to FNavBar.Groups.Count - 1 do
    if FNavBar.Groups[I].LargeImageIndex > ARemoveIndex then
      FNavBar.Groups[I].LargeImageIndex :=
        FNavBar.Groups[I].LargeImageIndex - 1;

  for I := 0 to FNavBar.Items.Count - 1 do
    if FNavBar.Items[I].LargeImageIndex > ARemoveIndex then
      FNavBar.Items[I].LargeImageIndex :=
        FNavBar.Items[I].LargeImageIndex - 1;

end;

function TdxNavBarControlManager.FindGroupControl(
  AGroup: INavBarGroup): TdxNavBarGroup;
var
  dxCategory: TdxNavBarGroup;
  dxCategoryNavBar: TdxNavBar;
  I: integer;
begin
  dxCategory := FindCategoryControl(AGroup.Category);
  dxCategoryNavBar := TdxNavBar(dxCategory.Control.FindComponent('NavBar'));

  for I := 0 to dxCategoryNavBar.Groups.Count -  1 do
  begin
    Result := dxCategoryNavBar.Groups[I];
    if SameText(Result.Caption, AGroup.Caption) then Exit;
  end;

  raise Exception.CreateFmt('NavBar Group %s not found', [AGroup.Caption]);

end;

function TdxNavBarControlManager.FindItemLinkControl(
  AItemLink: INavBarItemLink): TdxNavBarItemLink;
var
  dxGroup: TdxNavBarGroup;
  I: integer;
begin
  dxGroup := FindGroupControl(AItemLink.Group);
  for I := 0 to dxGroup.LinkCount - 1 do
  begin
    Result := dxGroup.Links[I];
    if SameText(Result.Item.Caption, AItemLink.Caption) then Exit;
  end;

  raise Exception.CreateFmt('NavBar ItemLink %s not found', [AItemLink.Caption]);
end;

procedure TdxNavBarControlManager.NavBarLinkClickHandler(Sender: TObject;
  ALink: TdxNavBarItemLink);
begin
  FWorkItem.Actions[GetItemLinkInfo(ALink).FItemID].Execute(FWorkItem);

end;

procedure TdxNavBarControlManager.OnCustomDrawGroupCaption(Sender: TObject;
  ACanvas: TCanvas; AViewInfo: TdxNavBarGroupViewInfo; var AHandled: Boolean);
{var
  ARect: TRect;
  AColor1, AColor2: TColor;
  AAlphaBlend1, AAlphaBlend2: Byte;
  AGradientMode: TdxBarStyleGradientMode;
  W70: Integer;
  AButtonPainter: TdxNavBarCustomButtonPainterClass;}
begin
{  AColor1 := $FFBF00;
  AColor2 := clWhite;
  AAlphaBlend1 := 255;

  AAlphaBlend2 := 255;
  AGradientMode := gmHorizontal;

  AButtonPainter := TdxNavBarCustomButtonPainter;
  ARect := AViewInfo.CaptionRect;
  // The width of the left section of the group background
  W70 := Trunc((ARect.Right - ARect.Left)*0.7);

  // Draw the left section of the group background
  ARect.Right := ARect.Left + W70;
  AButtonPainter.DrawButton(ACanvas, ARect, nil, AColor1, AColor2, AAlphaBlend1, AAlphaBlend2, AGradientMode, clWhite, AViewInfo.State);

  // Draw the right section of the group background
  ARect.Left := ARect.Right;
  ARect.Right := AViewInfo.CaptionRect.Right;
  AButtonPainter.DrawButton(ACanvas, ARect, nil, AColor2, AColor1, AAlphaBlend1, AAlphaBlend2, AGradientMode, clWhite, AViewInfo.State);

  // Draw the group image
  ARect := AViewInfo.CaptionImageRect;
  TdxNavBarCustomImagePainter.DrawImage(ACanvas, AViewInfo.ImageList, AViewInfo.ImageIndex, ARect);

  // Draw the hearder sign

  ARect := AViewInfo.CaptionSignRect;
  TdxNavBarExplorerBarSignPainter.DrawSign(ACanvas, ARect, clYellow, clBlack, clBlack, AViewInfo.State);

  // Draw the group caption
  ARect := AViewInfo.CaptionTextRect;
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font := AViewInfo.CaptionFont;
  ACanvas.Font.Color := AViewInfo.CaptionFontColor;
  DrawText(ACanvas.Handle, PChar(AViewInfo.Group.Caption), Length(AViewInfo.Group.Caption), ARect, AViewInfo.GetDrawEdgeFlag);
   }
  AHandled := false;

end;

function TdxNavBarControlManager.IsControlKeyDown: boolean;
begin
  result:=(Word(GetKeyState(VK_CONTROL)) and $8000)<>0;
end;

procedure TdxNavBarControlManager.SetItemLinkSubItemsCallback(
  Value: TNavBarItemLinkSubItemsCallback);
begin
  FItemLinkSubItemsCallback := Value;
end;

procedure TdxNavBarControlManager.ShowItemLinkSubItems(
  ALink: TdxNavBarItemLink);
var
  _point: TPoint;
  ItemInfo: TNavBarItemLinkControlInfo;
  I: integer;
  mi: TMenuItem;
  SubItems: INavBarItems;
begin
  ItemInfo := GetItemLinkInfo(ALink);
  FItemMenu.Items.Clear;

  {Fill items}
  SubItems := nil;
  if Assigned(FItemLinkSubItemsCallback) then
    SubItems := FItemLinkSubItemsCallback(ItemInfo.FItemID);

  if (SubItems <> nil) and (SubItems.Count > 0) then
  begin
    for I := 0 to SubItems.Count - 1 do
    begin
      mi := TMenuItem.Create(FItemMenu);
      mi.Caption := SubItems.GetItem(I).Caption;
      FItemMenu.Items.Add(mi);      
      FWorkItem.Commands[SubItems.GetItem(I).ID].AddInvoker(mi, 'OnClick');
    end;
  end
  else
  begin
    mi := TMenuItem.Create(FItemMenu);
    mi.Caption := 'Нет дополнительных действий';
    FItemMenu.Items.Add(mi);
  end;

  _point := Point(ItemInfo.FNavBar.ViewInfo.GetLinkViewInfoByLink(ALink).Rect.Left + 20,
    ItemInfo.FNavBar.ViewInfo.GetLinkViewInfoByLink(ALink).Rect.Bottom);
  _point := ItemInfo.FNavBar.ClientToScreen(_Point);

  FItemMenu.Popup(_point.X, _point.Y);


end;

function TdxNavBarControlManager.GetItemLinkInfo(
  ALink: TdxNavBarItemLink): TNavBarItemLinkControlInfo;
begin
  Result := TNavBarItemLinkControlInfo(ALink.Item.FindComponent('ItemLinkInfo'));
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
  FNavBar.ActiveGroupIndex := 0;
    //AFile.ReadInteger('Common', 'ActiveGroupIndex', 0);
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
