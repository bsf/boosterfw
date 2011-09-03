unit TabbedWorkspace;

interface
uses classes, controls, CoreClasses, Workspace, cxPC, Contnrs, messages,
  sysutils, Graphics,  windows, forms, menus,
  cxGroupBox, cxLookAndFeels, cxGraphics, cxControls, cxLookAndFeelPainters,
  cxEdit, cxButtons, ShellIntf, ConfigServiceIntf;

const
  SETTING_HIDE_TABS = 'ViewStyle.Shell.HideTabs';
  SETTING_TABS_BOTTOM = 'ViewStyle.Shell.TabsBottom';
type

  TContentSiteInfo = class(TViewSiteInfo)
  private
    FPage: TcxTabSheet;
  protected
    procedure SetTitle(const AValue: string); override;
  public
    constructor Create(AOwner: TComponent; APage: TcxTabSheet); reintroduce;
  end;

  TTabbedWorkspace = class;

  TPage = class(TcxTabSheet)
  private
    procedure CMRelease(var Message: TMessage); message CM_RELEASE;
  public
    procedure Release;
  end;

  TViewItem = class(TComponent)
  private
    FLastActiveControl: TWinControl;
    FActiveControl: TWinControl;
    FView: TWinControl;
    FViewParent: TWinControl;
    FInitTitle: string;
    FPage: TPage;
    FInfo: TContentSiteInfo;
    FCaptionPanel: TcxGroupBox;
    function Workspace: TTabbedWorkspace;
    procedure DoViewChangeTitle;
    procedure PageShowHandler(Sender: TObject);
    procedure PageHideHandler(Sender: TObject);
    procedure ActiveControlChangeHandler;
    procedure ButtonCloseOnClick(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TTabbedWorkspace; AView: TWinControl;
      const ATitle: string); reintroduce;
    destructor Destroy; override;
    procedure Show;
    function Close: boolean;
    property Info: TContentSiteInfo read FInfo;
  end;

  TTabbedWorkspace = class(TWorkspace)
  private
    FToolWinMenu: TPopupMenu;
    FScaleM: integer;
    FScaleD: integer;
    FPageCtrl: TcxPageControl;
    FViewItems: TComponentList;
    FSelectTabState: boolean;
    FPrevHideTabsState: boolean;
    function FindViewItem(AView: TControl; EnsureExists: boolean): TViewItem;
    function GetActiveView: TControl;

    procedure PageControlChange(Sender: TObject);
    procedure PageControlCanCloseHandler(Sender: TObject; var ACanClose: Boolean);
    procedure ActiveControlChangeHandler(Sender: TObject);
    procedure ToolWinMenuOnPopup(Sender: TObject);
    procedure ToolWinCmdTabsBottom(Sender: TObject);
    procedure ToolWinCmdTabsTop(Sender: TObject);
    procedure ToolWinCmdHideTabs(Sender: TObject);
    procedure ToolWinCmdCloseAll(Sender: TObject);
    procedure ToolWinCmdActivateTab(Sender: TObject);
    function IsShortCut(var Msg: TWMKey): boolean;
    procedure SelectTabStart;
    procedure SelectTabStop;
  protected
    procedure CloseActivePage;
    function ToolWinMenu: TPopupMenu;
    function Add(AView: TWinControl; const ATitle: string): TViewSiteInfo; virtual;
    //IWorkspace
    function ViewCount: integer; override;
    function GetView(Index: integer): TControl; override;
    function ViewExists(AView: TControl): boolean; override;
    procedure Show(AView: TControl; const ATitle: string); override;
    function Close(AView: TControl): boolean; override;
    function GetViewSiteInfo(AView: TControl): TViewSiteInfo; override;
  public
    constructor Create(AOwner: TComponent; APageCtrl: TcxPageControl); reintroduce;
    destructor Destroy; override;
    procedure ShortCutHandler(var Msg: TWMKey; var Handled: Boolean);
    procedure KeyUpHandler(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MouseWheelHandler(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ScaleBy(M, D: integer); override;
    property PageControl: TcxPageControl read FPageCtrl;
  end;


implementation

type
  TWinControlHack = class(TWinControl)
  end;

{ TTabbedWorkspace }

procedure TTabbedWorkspace.ActiveControlChangeHandler(Sender: TObject);
var
  I: integer;
  viewItem: TViewItem;
begin
  viewItem := nil;
  for I := 0 to FViewItems.Count - 1 do
    if FPageCtrl.ActivePage = TViewItem(FViewItems[i]).FPage then
    begin
      viewItem := TViewItem(FViewItems[i]);
      break;
    end;

  if Assigned(viewItem) and viewItem.FView.ContainsControl(Screen.ActiveControl) then
    viewItem.ActiveControlChangeHandler;
end;

function TTabbedWorkspace.Add(AView: TWinControl;
  const ATitle: string): TViewSiteInfo;
var
  Item: TViewItem;
begin
  Item := TViewItem.Create(Self, AView, ATitle);
  FViewItems.Add(Item);
  Result := Item.Info;
  TViewItem(Item).FPage.ScrollBy(FScaleM, FScaleD);
end;

function TTabbedWorkspace.Close(AView: TControl): boolean;
begin
  Result := FindViewItem(AView, true).Close;
end;

procedure TTabbedWorkspace.CloseActivePage;
var
  _view: TControl;
begin
  _view := GetActiveView;
  if assigned(_view) then
    Close(_view);
end;

constructor TTabbedWorkspace.Create(AOwner: TComponent; APageCtrl: TcxPageControl);
begin
  inherited Create(AOwner);
  FViewItems := TComponentList.Create(true);
  FPageCtrl := APageCtrl;
  FPageCtrl.OnCanClose := PageControlCanCloseHandler;
  FPageCtrl.OnChange := PageControlChange;
  Screen.OnActiveControlChange := ActiveControlChangeHandler;
  FScaleM := 96;
  FScaleD := 96;
 // FPageCtrl.ScaleBy(120, 100);

  FToolWinMenu := TPopupMenu.Create(Self);
  FToolWinMenu.OnPopup := ToolWinMenuOnPopup;

  //Preferences

  with App.Settings.Add(SETTING_HIDE_TABS) do
  begin
    Caption := 'Скрыть закладки';
    Category := 'Главное окно';
    DefaultValue := '0';
    Editor := seBoolean;
    StorageLevels := [slUserProfile];
  end;

  with App.Settings.Add(SETTING_TABS_BOTTOM) do
  begin
    Caption := 'Отображать закладки снизу';
    Category := 'Главное окно';
    DefaultValue := '0';
    Editor := seBoolean;
    StorageLevels := [slUserProfile];
  end;

  if StrToBoolDef(App.Settings[SETTING_TABS_BOTTOM], false) then ToolWinCmdTabsBottom(nil);
  if StrToBoolDef(App.Settings[SETTING_HIDE_TABS], false) then ToolWinCmdHideTabs(nil);


end;

destructor TTabbedWorkspace.Destroy;
var
  I: integer;
begin
  for I := FViewItems.Count - 1 downto 0 do
    TViewItem(FViewItems[I]).Close;

  FViewItems.Free;
  inherited;
end;

function TTabbedWorkspace.FindViewItem(AView: TControl;
  EnsureExists: boolean): TViewItem;
var
  I: integer;
begin
  for I := 0 to FViewItems.Count - 1 do
  begin
    Result := TViewItem(FViewItems[I]);
    if Result.FView = AView then Exit;
  end;

  Result := nil;

  if EnsureExists then
    raise EViewMissingError.Create('View not found.');

end;

function TTabbedWorkspace.GetActiveView: TControl;
var
  idx: integer;
begin
  Result := nil;
  idx := FPageCtrl.ActivePageIndex;
  if idx <> -1 then
    Result := GetView(idx);
end;

function TTabbedWorkspace.GetView(Index: integer): TControl;
begin
  Result := TViewItem(FViewItems[Index]).FView;
end;

function TTabbedWorkspace.GetViewSiteInfo(AView: TControl): TViewSiteInfo;
begin
  Result := FindViewItem(AView, true).Info;
end;

function TTabbedWorkspace.IsShortCut(var Msg: TWMKey): boolean;
begin
  if (ssCtrl in KeyDataToShiftState(Msg.KeyData)) and (Msg.CharCode = VK_TAB) then
  begin
    SelectTabStart;
    Result := true;
  end
  else
    Result := false;
end;

procedure TTabbedWorkspace.KeyUpHandler(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_CONTROL) and FSelectTabState	then SelectTabStop;
end;

procedure TTabbedWorkspace.MouseWheelHandler(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  _view: TControl;
begin
  _view := GetActiveView;
  if assigned(_view) then
    Self.DoViewMouseWheel(_view, Shift, WheelDelta, MousePos, Handled);
end;

procedure TTabbedWorkspace.PageControlCanCloseHandler(Sender: TObject;
  var ACanClose: Boolean);
begin
  ACanClose := false;
  CloseActivePage;
end;

procedure TTabbedWorkspace.PageControlChange(Sender: TObject);
var
  I: integer;
  viewItem: TViewItem;
begin
  viewItem := nil;
  for I := 0 to FViewItems.Count - 1 do
    if FPageCtrl.ActivePage = TViewItem(FViewItems[i]).FPage then
    begin
      viewItem := TViewItem(FViewItems[i]);
      break;
    end;

  if Assigned(viewItem) and Assigned(viewItem.FLastActiveControl)
     and viewItem.FLastActiveControl.CanFocus then
    viewItem.FLastActiveControl.SetFocus;
end;

procedure TTabbedWorkspace.ScaleBy(M, D: integer);
var
  I: integer;
begin
  FScaleM := M;
  FScaleD := D;

  for I := 0 to FViewItems.Count - 1 do
    TViewItem(FViewItems[I]).FPage.ScaleBy(FScaleM, FScaleD);
end;

procedure TTabbedWorkspace.SelectTabStart;
begin
  if not FSelectTabState then
  begin
    FPrevHideTabsState := PageControl.HideTabs;
    PageControl.HideTabs := false;
  end;

  FSelectTabState := true;
  PageControl.SelectNextPage(true);

end;

procedure TTabbedWorkspace.SelectTabStop;
begin
  PageControl.HideTabs := FPrevHideTabsState;
  FSelectTabState := false;
end;

procedure TTabbedWorkspace.ShortCutHandler(var Msg: TWMKey;
  var Handled: Boolean);
var
  _view: TControl;
begin
  Handled := IsShortCut(Msg);
  if not Handled then
  begin
    _view := GetActiveView;
    if assigned(_view) then
      DoViewShortCut(_view, Msg, Handled);
  end;
end;

procedure TTabbedWorkspace.Show(AView: TControl; const ATitle: string);
var
  Item: TViewItem;
begin
  Item := FindViewItem(AView, false);
  if Item = nil then
    Add(TWinControl(AView), ATitle);

  Item := FindViewItem(AView, true);
  Item.Info.Title := ATitle;
  Item.Show;

end;

procedure TTabbedWorkspace.ToolWinCmdActivateTab(Sender: TObject);
begin
  PageControl.ActivePageIndex := (Sender as TMenuItem).Tag;
end;

procedure TTabbedWorkspace.ToolWinCmdCloseAll(Sender: TObject);
var
  I: integer;
begin
  for I := PageControl.PageCount - 1 downto 0 do
    CloseActivePage;
end;

procedure TTabbedWorkspace.ToolWinCmdHideTabs(Sender: TObject);
begin
  PageControl.HideTabs := true;
  if Sender <> nil then
    App.Settings.GetItemByName(SETTING_HIDE_TABS).SetStoredValue('1', slUserProfile);
end;

procedure TTabbedWorkspace.ToolWinCmdTabsBottom(Sender: TObject);
begin
  PageControl.HideTabs := false;
  PageControl.TabPosition := tpBottom;

  if Sender <> nil then
  begin
    App.Settings.GetItemByName(SETTING_HIDE_TABS).
      SetStoredValue('0', slUserProfile);
    App.Settings.GetItemByName(SETTING_TABS_BOTTOM).
      SetStoredValue('1', slUserProfile);
  end;
end;

procedure TTabbedWorkspace.ToolWinCmdTabsTop(Sender: TObject);
begin
  PageControl.HideTabs := false;
  PageControl.TabPosition := tpTop;
  if Sender <> nil then
  begin
    App.Settings.GetItemByName(SETTING_HIDE_TABS).
      SetStoredValue('0', slUserProfile);
    App.Settings.GetItemByName(SETTING_TABS_BOTTOM).
      SetStoredValue('0', slUserProfile);
  end;
end;

function TTabbedWorkspace.ToolWinMenu: TPopupMenu;
begin
  Result := FToolWinMenu;
end;

procedure TTabbedWorkspace.ToolWinMenuOnPopup(Sender: TObject);
  function AddItem(const ACaption: string; AHandler: TNotifyEvent; ATag: integer): TMenuItem;
  begin
    Result := TMenuItem.Create(FToolWinMenu);
    FToolWinMenu.Items.Add(Result);
    with Result do
    begin
      Caption := ACaption;
      OnClick := AHandler;
      Tag := ATag;
    end;
  end;
var
  I: integer;
begin
  FToolWinMenu.Items.Clear;

  for I := 0 to PageControl.TabCount - 1 do
    AddItem(PageControl.Tabs[I].Caption,ToolWinCmdActivateTab, I).Default := PageControl.ActivePageIndex = I;

  AddItem('-', nil, -1);
  AddItem('Скрыть закладки', ToolWinCmdHideTabs, -1);
  AddItem('Закладки вверху', ToolWinCmdTabsTop, -1);
  AddItem('Закладки снизу', ToolWinCmdTabsBottom, -1);
  AddItem('-', nil, -1);
  AddItem('Закрыть все', ToolWinCmdCloseAll, -1);
end;

function TTabbedWorkspace.ViewCount: integer;
begin
  Result := FPageCtrl.PageCount;
end;

function TTabbedWorkspace.ViewExists(AView: TControl): boolean;
begin
  Result := Assigned(FindViewItem(AView, false));
end;

{ TContentSiteInfo }

constructor TContentSiteInfo.Create(AOwner: TComponent;
  APage: TcxTabSheet);
begin
  inherited Create(AOwner);
  FPage := APage;
end;

procedure TContentSiteInfo.SetTitle(const AValue: string);
begin
  inherited;
  FPage.Caption := AValue;
  TViewItem(Owner).DoViewChangeTitle;
end;

{ TViewItem }

procedure TViewItem.ActiveControlChangeHandler;
begin
  FActiveControl := Screen.ActiveControl;
end;

procedure TViewItem.ButtonCloseOnClick(Sender: TObject);
begin
  (Owner as TTabbedWorkspace).CloseActivePage;
end;

function TViewItem.Close: boolean;
var
  CanClose: boolean;
  prevActivePage: TcxTabSheet;
begin
//если закрывается не активная закладка то сделать активной закрываемую
//а потом сделать активной ту которая была активна до этого

  CanClose := true;

  if FPage.PageControl.ActivePage <> FPage then
  begin
    prevActivePage := FPage.PageControl.ActivePage;
    FPage.PageControl.ActivePage := FPage;
  end
  else
    prevActivePage := nil;

  Workspace.DoViewCloseQuery(FView, CanClose);

  Result := CanClose;
  if Result then
  begin
    FPage.OnShow := nil;
    FPage.OnHide := nil;

    Workspace.DoViewDeactivate(FView);

    if prevActivePage <> nil then
      FPage.PageControl.ActivePage := prevActivePage;

    FPage.Release;
  end;
end;

constructor TViewItem.Create(AOwner: TTabbedWorkspace; AView: TWinControl;
  const ATitle: string);

  procedure LoadButtonImage(AButton: TcxButton; const ResName: string);
  var
    Image: Graphics.TBitMap;
    ImgRes: TResourceStream;
  begin
    Image := Graphics.TBitMap.Create;
    try
      ImgRes := TResourceStream.Create(HInstance, ResName, 'file');
      try
        Image.LoadFromStream(ImgRes);
      finally
        ImgRes.Free;
      end;
      AButton.Glyph.Assign(Image);

    finally
      Image.Free;
    end;
  end;

  function AddToolButton(const ImageResName: string; APrevButton: TcxButton): TcxButton;
  begin
    Result := TcxButton.Create(FCaptionPanel);
    with Result do
    begin
      Align := alRight;
      Anchors := [akRight, akBottom];
      LookAndFeel.Kind := FCaptionPanel.LookAndFeel.Kind;
      Width := 38;
      SpeedButtonOptions.CanBeFocused := false;
      SpeedButtonOptions.Transparent := true;
      if APrevButton <> nil then
        Left := APrevButton.Left - Width;
      Parent := FCaptionPanel;
    end;
    LoadButtonImage(Result, ImageResName);

  end;

const
  TABWS_WIN_IMAGE_RES = 'TabWS_WIN_IMAGE';
  TABWS_CROSS_IMAGE_RES = 'TabWS_CROSS_IMAGE';

var
  btn: TcxButton;
begin
  inherited Create(AOwner);

  FView := AView;
  FInitTitle := ATitle;
  FView.FreeNotification(Self);
  FViewParent := AView.Parent;
  FPage := TPage.Create(Self);

  FPage.Visible := false;
  FPage.PageControl := Workspace.PageControl;
  FInfo := TContentSiteInfo.Create(Self, FPage);
  FCaptionPanel := TcxGroupBox.Create(Self);
  FCaptionPanel.Parent := FPage;


  with FCaptionPanel do
  begin
    Align := alTop;
    PanelStyle.CaptionIndent := 10;
    PanelStyle.Active := True;
    PanelStyle.OfficeBackgroundKind := pobkGradient;
    Style.BorderStyle := ebsNone;
    Style.LookAndFeel.Kind := lfOffice11;
    Style.TextStyle := [fsBold];
    Style.Font.Size := 10;
    Height := 38;
   // Visible := false;
  end;

  btn := AddToolButton(TABWS_CROSS_IMAGE_RES, nil);
  btn.OnClick := ButtonCloseOnClick;

  btn := AddToolButton(TABWS_WIN_IMAGE_RES, btn);
  btn.Kind := cxbkDropDown;
  btn.DropDownMenu := (Owner as TTabbedWorkspace).ToolWinMenu;

  FInfo.Title := FInitTitle;
end;

destructor TViewItem.Destroy;
var
  activePage: TcxTabSheet;
begin

  if Workspace.PageControl.ActivePage <> FPage then
    activePage := Workspace.PageControl.ActivePage
  else
    activePage := nil;

  //ищу AV
  try
    if Assigned(FView) then
      Workspace.DoViewClose(FView);
  except
    on E: Exception do
      App.Views.MessageBox.InfoMessage(
        format('Ошибка закрытия: %s', [E.Message]));
  end;

  if Assigned(FView) then
  begin
    FView.Parent := FViewParent;
    FView.RemoveFreeNotification(Self);
  end;

  FPage.Free;

  inherited;

    //on E: Exception do
    // SysUtils.ShowException(E, ExceptAddr);

  if Assigned(activePage) then
    activePage.PageControl.ActivePage := activePage;
end;

procedure TViewItem.DoViewChangeTitle;
begin
  FCaptionPanel.Caption := FInfo.Title;
  FPage.Caption := FInfo.Title;
end;

procedure TViewItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FView) then
    FView := nil;
end;

procedure TViewItem.PageHideHandler(Sender: TObject);
begin
  FLastActiveControl := FActiveControl;
  Workspace.DoViewDeactivate(FView);
end;

procedure TViewItem.PageShowHandler(Sender: TObject);
begin
  Workspace.DoViewActivate(FView);
end;

procedure TViewItem.Show;
var
  activeControl: TWinControl;
begin
  activeControl := nil;
  if FView.Parent = FViewParent then
  begin
    if FView.Owner is TCustomForm then
      activeControl := (FView.Owner as TCustomForm).ActiveControl;

    if activeControl = nil then
      activeControl := TWinControlHack(FView).FindNextControl(nil, true, true, false);
  end;

  FView.Parent := FPage;
  FPage.Visible := true;
  FPage.PageControl.ActivePage := FPage;

  if (activeControl <> nil) and activeControl.CanFocus then
    activeControl.SetFocus;

  Workspace.DoViewShow(FView);
  Workspace.DoViewActivate(FView);

  FPage.OnShow := PageShowHandler;
  FPage.OnHide := PageHideHandler;
end;

function TViewItem.Workspace: TTabbedWorkspace;
begin
  Result := TTabbedWorkspace(Owner);
end;

{ TTabPage }

procedure TPage.CMRelease(var Message: TMessage);
begin
  Owner.Free;
end;

procedure TPage.Release;
begin
  PostMessage(Handle, CM_RELEASE, 0, 0);
end;

end.
