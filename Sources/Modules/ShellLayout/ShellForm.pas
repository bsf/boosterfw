unit ShellForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus,ActnList, ComCtrls, ShellIntf, CustomApp,
  ToolWin, ExtCtrls,  Contnrs, cxGraphics,
  cxControls, dxStatusBar,  cxClasses, dxNavBarBase,
  dxNavBarCollns, dxNavBar, cxSplitter, dxBar, dxNavBarGroupItems,
  cxContainer, cxEdit, cxLabel, cxTextEdit, cxHyperLinkEdit, StdActns,
  dxNavBarStyles, CoreClasses, WindowWorkspace,
  cxProgressBar, ShellNavBar,
  ImgList, UILocalization, cxLocalization,
  ShellWaitBox,
  ViewStyleController, cxPC, cxDropDownEdit,
  cxBarEditItem, cxButtonEdit, dxBarExtItems, EntityServiceIntf,
  cxLookAndFeels, cxLookAndFeelPainters, TabbedWorkspace, ShellAbout,
   UIClasses,
  UserPreferencesPresenter, UserPreferencesView,
  CommonUtils, dxGDIPlusClasses, cxGroupBox, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, dxOffice11, UIServiceIntf,
  NotifyReceiver, NotifySenderPresenter, NotifySenderView,
  UICatalog, ShellLayoutStr, SplashForm, cxPCdxBarPopupMenu;

const
  STATUSBAR_INFO_PANEL = 0;
  STATUSBAR_PROGRESS_PANEL = 1;

  COMMAND_SHOW_ABOUT = '{9421F2C7-F526-4858-975B-B01698C70530}';
  COMMAND_CLOSE_APP = '{1E3FCF4E-9E40-4D5B-ADE4-3F78428CA24B}';
  COMMAND_RELOAD_CONFIGURATION = '{E94B5DA4-980A-428B-98A4-9DEC73E63980}';
  COMMAND_SHOWVIEWINFO = '{5BB48548-EF9C-4778-B1B5-A41D5FA89285}';

  START_ACTIVITY_SETTING = 'StartActivity';

type
  TfrMain = class(TCustomShellForm)
    BarStatus: TdxStatusBar;
    ilNavBarLarge: TcxImageList;
    BarStatusContainer1: TdxStatusBarContainerControl;
    WaitProgressBar: TcxProgressBar;
    NavBar: TdxNavBar;
    SplitterLeft: TcxSplitter;
    cxStyleRepositoryShellForm: TcxStyleRepository;
    cxStyleInfoBk: TcxStyle;
    cxStyleNotifyCellTime: TcxStyle;
    cxStyleNotifyCellText: TcxStyle;
    ilNavBarSmall: TImageList;
    PanelContent: TcxGroupBox;
    pcMain: TcxPageControl;
    SplitterNotifyPanel: TcxSplitter;
    pnNotify: TcxGroupBox;
    grNotify: TcxGrid;
    grNotifyListView: TcxGridTableView;
    grNotifyListViewHeader: TcxGridColumn;
    grNotifyListViewText: TcxGridColumn;
    grNotifyListViewID: TcxGridColumn;
    grNotifyListViewSENDER: TcxGridColumn;
    grNotifyListViewTime: TcxGridColumn;
    grNotifyLevel1: TcxGridLevel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grNotifyListViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure grNotifyListViewDataControllerAfterDelete(
      ADataController: TcxCustomDataController);
    procedure grNotifyListViewDataControllerBeforeDelete(
      ADataController: TcxCustomDataController; ARecordIndex: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    FScale: integer;
    FWorkItem: TWorkItem;
    FContentWorkspace: TTabbedWorkspace;
    FDialogWorkspace: TDialogWorkspace;
    FWaitBox: TShellWaitBox;
    FUICatalog: TUICatalog;
    FSplash: TSplash;

    FViewStyleController: TViewStyleController;
    FNavBarControlManager: TdxNavBarControlManager;

    FLookAndFeelListener: TcxLookAndFeel;
    procedure LookAndFeelChangedHandler(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues);

    procedure SplashShow;
    procedure SplashHide;

    procedure CloseNotifyPanel;
    procedure ShowNotifyPanel;

    function CloseAllContentView: boolean;

    //Event Handlers
    procedure StatusUpdateHandler(EventData: Variant);
    procedure NotifyMessageHandler(EventData: Variant);

    procedure WaitProgressStartHandler(EventData: Variant);
    procedure WaitProgressStopHandler(EventData: Variant);
    procedure WaitProgressUpdateHandler(EventData: Variant);

    procedure AppStartedHandler(EventData: Variant);
    procedure AppStopedHandler(EventData: Variant);

    //Shell Commands
    procedure RegisterShellCommands;


    type
      TCloseAppHandler = class(TActivityHandler)
      private
        FMainForm: TForm;
      public
        constructor Create(AMainForm: TForm);
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

      TShowAboutHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

      TReloadConfigurationHandler = class(TActivityHandler)
      private
        FNavBar: TdxNavBarControlManager;
      public
        constructor Create(ANavBar: TdxNavBarControlManager);
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

      TShowViewInfoHandler = class(TActivityHandler)
      public
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AWorkItem: TWorkItem); override;
    property WorkItem: TWorkItem read FWorkItem write FWorkItem;
  end;

var
  frMain: TfrMain;

implementation
uses NumLockDotHook; //Linked only

{$R *.dfm}

procedure TfrMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := App.UI.MessageBox.ConfirmYesNo(GetLocaleString(@CloseApplicationQuestion));
  if CanClose then
    CanClose := CloseAllContentView;
end;

function TfrMain.CloseAllContentView: boolean;
var
  I: integer;
  Intf: IWorkspace;
begin
  Result := true;
  FContentWorkspace.GetInterface(IWorkspace, Intf);
  for I := Intf.ViewCount - 1 downto 0 do
  begin
    try
      Result := Intf.Close(Intf.View[I]);
    except
      on E: Exception do
      begin
        Application.ShowException(E);
        Result := true;
      end;
    end;
    if not Result then Exit;
  end
end;

constructor TfrMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if App.Settings['Application.Title'] <> '' then
    Application.Title := App.Settings['Application.Title'];

  if (App.Settings.Aliases.Count > 0) and (App.Settings.CurrentAlias <> '') then
    Application.Title := Application.Title + ' <' +
      App.Settings.CurrentAlias  + '>';

end;


destructor TfrMain.Destroy;
begin
  FLookAndFeelListener.Free;
//  FLookAndFeelListener.OnChanged := nil; //AV on close app!!!
  inherited;
end;

procedure TfrMain.Initialize(AWorkItem: TWorkItem);
begin
  SplashShow;

  FWorkItem := AWorkItem;

  FScale := (FWorkItem.Services[IUIService] as IUIService).Scale;
  ScaleBy(FScale, 100);

  FViewStyleController := TViewStyleController.Create(Self, FWorkItem);
  FWaitBox := TShellWaitBox.Create(Self);
  FWaitBox.ScaleBy(FScale);

  // Add NavBar Service
  FNavBarControlManager := TdxNavBarControlManager.Create(Self, NavBar, FWorkItem);
  FNavBarControlManager.ScaleBy(FScale, 100);

  //AddWorkspace
  FDialogWorkspace := TDialogWorkspace.Create(Self);
  FWorkItem.Workspaces.RegisterWorkspace(WS_DIALOG, FDialogWorkspace);
  FDialogWorkspace.ScaleBy(FScale, 100);

  FContentWorkspace := TTabbedWorkspace.Create(Self, pcMain);
  FWorkItem.Workspaces.RegisterWorkspace(WS_CONTENT, FContentWorkspace);
  FContentWorkspace.ScaleBy(FScale, 100);
  //
  Caption := Application.Title;

  //Events Link
  FWorkItem.EventTopics[ET_STATUSBARMESSAGE].AddSubscription(Self, StatusUpdateHandler);
  FWorkItem.EventTopics[ET_NOTIFY_MESSAGE].AddSubscription(Self, NotifyMessageHandler);
  CloseNotifyPanel;

  FWorkItem.EventTopics[etAppStarted].AddSubscription(Self, AppStartedHandler);
  FWorkItem.EventTopics[etAppStoped].AddSubscription(Self, AppStopedHandler);

  RegisterShellCommands;

  FUICatalog := TUICatalog.Create(Self, FWorkItem);

  if (FWorkItem.Services[IUIService] as IUIService).ShellLayoutKind in [slDesk, slFullDesk] then
  begin
    NavBar.Visible := false;
    SplitterLeft.Visible := false;
    BarStatus.Visible := false;
  end
  else if (FWorkItem.Services[IUIService] as IUIService).ShellLayoutKind = slFullDesk then
  begin
    Self.BorderStyle := bsNone;
  end;

  //Init Shell Style
  Self.Color := dxOffice11ToolbarsColor1;
  pcMain.Color := dxOffice11ToolbarsColor1;
  pcMain.Properties.Style := 9;//tsSlanted;

  FLookAndFeelListener := TcxLookAndFeel.Create(Self);
  FLookAndFeelListener.OnChanged := LookAndFeelChangedHandler;

end;

procedure TfrMain.LookAndFeelChangedHandler(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin

  if Sender.SkinName <> '' then
  begin
    BarStatus.PaintStyle := stpsUseLookAndFeel;
    pcMain.Properties.Style := 0;//tsDefault;
  end
  else
  begin
    Self.Color :=  dxOffice11ToolbarsColor1;
    pcMain.Color := dxOffice11ToolbarsColor1;
    pcMain.Properties.Style := 9;//tsSlanted;
  end;
end;

procedure TfrMain.StatusUpdateHandler(EventData: Variant);
begin
  BarStatus.Panels[STATUSBAR_INFO_PANEL].Text := VarToStr(EventData);
end;

procedure TfrMain.WaitProgressStartHandler(EventData: Variant);
begin
  if Assigned(FWaitBox) then FWaitBox.Show;
  BarStatus.Panels[STATUSBAR_PROGRESS_PANEL].Visible := true;
  WaitProgressBar.Properties.Marquee := true;
  Self.Update;
end;

procedure TfrMain.WaitProgressStopHandler(EventData: Variant);
begin
  if Assigned(FWaitBox) then FWaitBox.Hide;
  BarStatus.Panels[STATUSBAR_PROGRESS_PANEL].Visible := false;
  WaitProgressBar.Properties.Marquee := false;
end;

procedure TfrMain.WaitProgressUpdateHandler(EventData: Variant);
begin
  if Assigned(FWaitBox) then FWaitBox.Update;
  WaitProgressBar.Update;
end;

procedure TfrMain.AppStartedHandler(EventData: Variant);
var
  startActivity: string;
begin
  FWorkItem.EventTopics[ET_LOAD_CONFIGURATION].Fire;

  FViewStyleController.LoadPreferences;

  FNavBarControlManager.BuildMainMenu;
  FNavBarControlManager.LoadPreference;

  SplashHide;

  FWorkItem.EventTopics[ET_ENTITY_VIEW_OPEN_START].AddSubscription(Self, WaitProgressStartHandler);
  FWorkItem.EventTopics[ET_ENTITY_VIEW_OPEN_FINISH].AddSubscription(Self, WaitProgressStopHandler);

  FWorkItem.EventTopics[ET_WAITBOX_START].AddSubscription(Self, WaitProgressStartHandler);
  FWorkItem.EventTopics[ET_WAITBOX_UPDATE].AddSubscription(Self, WaitProgressUpdateHandler);
  FWorkItem.EventTopics[ET_WAITBOX_STOP].AddSubscription(Self, WaitProgressStopHandler);

 startActivity := App.Settings[START_ACTIVITY_SETTING];
  if startActivity <> '' then
    FWorkItem.Activities[startActivity].Execute(FWorkItem);
end;

procedure TfrMain.AppStopedHandler(EventData: Variant);
begin
  FNavBarControlManager.SavePreference;
end;

procedure TfrMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
var
  shortCut: TShortCut;
  ShiftState: TShiftState;
begin
  ShiftState := KeyDataToShiftState(Msg.KeyData);
  ShortCut := Menus.ShortCut(Msg.CharCode, ShiftState);

  Handled := FWorkItem.Activities.IsShortCut(FWorkItem, shortCut);
  if (not Handled) and assigned(FContentWorkspace) then
    FContentWorkspace.ShortCutHandler(Msg, Handled);
end;

procedure TfrMain.RegisterShellCommands;
begin

  with WorkItem.Activities[COMMAND_CLOSE_APP] do
  begin
    Title := GetLocaleString(@COMMAND_CLOSE_APP_CAPTION);
    Group := GetLocaleString(@MENU_GROUP_FILE);
  end;
  WorkItem.Activities.RegisterHandler(COMMAND_CLOSE_APP, TCloseAppHandler.Create(Self));

  with WorkItem.Activities[COMMAND_SHOW_ABOUT] do
  begin
    Title := GetLocaleString(@COMMAND_SHOW_ABOUT_CAPTION);
    Group := GetLocaleString(@MENU_GROUP_FILE);
  end;
  WorkItem.Activities.RegisterHandler(COMMAND_SHOW_ABOUT, TShowAboutHandler.Create);

  with WorkItem.Activities[VIEW_USER_PREFERENCES] do
  begin
    Title := GetLocaleString(@VIEW_USER_PREFERENCES_TITLE);
    Group := GetLocaleString(@MENU_GROUP_SERVICE);
  end;
  WorkItem.Activities.RegisterHandler(VIEW_USER_PREFERENCES,
    TViewActivityHandler.Create(TUserPreferencesPresenter, TfrUserPreferencesView));

  WorkItem.Root.WorkItems.Add(TNotifyReceiver, TNotifyReceiver.ClassName);

  with WorkItem.Activities[VIEW_NOTIFYSENDER] do
  begin
    Title := GetLocaleString(@VIEW_NOTIFYSENDER_TITLE);
    Group := GetLocaleString(@MENU_GROUP_SERVICE);
    UsePermission := true;
  end;

  WorkItem.Activities.RegisterHandler(VIEW_NOTIFYSENDER,
    TViewActivityHandler.Create(TNotifySenderPresenter, TfrNotifySenderView));

  with WorkItem.Activities[COMMAND_RELOAD_CONFIGURATION] do
  begin
    MenuIndex := -1;
    ShortCut := 'F12';
    RegisterHandler(TReloadConfigurationHandler.Create(FNavBarControlManager));
  end;

  with WorkItem.Activities[COMMAND_SHOWVIEWINFO] do
  begin
    MenuIndex := -1;
    ShortCut := 'F11';
    RegisterHandler(TShowViewInfoHandler.Create);
  end;

end;


procedure TfrMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if assigned(FContentWorkspace) then
    FContentWorkspace.KeyUpHandler(Sender, Key, Shift);
end;


procedure TfrMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if assigned(FContentWorkspace) then
    FContentWorkspace.MouseWheelHandler(Sender, Shift, WheelDelta, MousePos, Handled);
end;

procedure TfrMain.NotifyMessageHandler(EventData: Variant);
begin
  grNotifyListView.DataController.InsertRecord(0);
  grNotifyListView.DataController.Values[0, grNotifyListViewID.Index] := VarToStr(EventData[0]);
  grNotifyListView.DataController.Values[0, grNotifyListViewSender.Index] := VarToStr(EventData[1]);
  grNotifyListView.DataController.Values[0, grNotifyListViewText.Index] := VarToStr(EventData[2]);
  grNotifyListView.DataController.Values[0, grNotifyListViewTime.Index] := EventData[3];

  grNotifyListView.DataController.Values[0, grNotifyListViewHeader.Index] :=
    grNotifyListView.DataController.GetDisplayText(0, grNotifyListViewTime.Index) + '  [ ' +
    grNotifyListView.DataController.GetDisplayText(0, grNotifyListViewSender.Index) + ' ]';

  grNotifyListView.DataController.GotoFirst;  
  ShowNotifyPanel;
end;

procedure TfrMain.grNotifyListViewCellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  grNotifyListView.DataController.DeleteFocused;
end;

procedure TfrMain.CloseNotifyPanel;
begin
  SplitterNotifyPanel.CloseSplitter;
  SplitterNotifyPanel.Visible := false;
end;

procedure TfrMain.ShowNotifyPanel;
begin
  SplitterNotifyPanel.Visible := true;
  SplitterNotifyPanel.OpenSplitter;


  Application.Restore;
  Application.BringToFront;
end;

procedure TfrMain.SplashHide;
begin
  exit;
  if Assigned(FSplash) then
  begin
    FSplash.Hide;
    FreeAndNil(FSplash);
  end;
end;

procedure TfrMain.SplashShow;
begin
  exit;
  if not Assigned(FSplash) then
  begin
    FSplash := TSplash.Create;
    FSplash.Show('', 0);
  end;
end;

procedure TfrMain.grNotifyListViewDataControllerAfterDelete(
  ADataController: TcxCustomDataController);
begin
  if ADataController.RecordCount = 0 then CloseNotifyPanel;
end;

procedure TfrMain.grNotifyListViewDataControllerBeforeDelete(
  ADataController: TcxCustomDataController; ARecordIndex: Integer);
var
  nID: string;
begin
  nID := VarToStr(grNotifyListView.DataController.Values[ARecordIndex, grNotifyListViewID.Index]);
  if nID <> '' then
    App.UI.NotifyAccept(nID);
end;

{ TfrMain.TCloseAppHandler }

constructor TfrMain.TCloseAppHandler.Create(AMainForm: TForm);
begin
  FMainForm := AMainForm;
end;

procedure TfrMain.TCloseAppHandler.Execute(Sender: TWorkItem; Activity: IActivity);
begin
  FMainForm.Close;
end;

{ TfrMain.TShowAboutHandler }

procedure TfrMain.TShowAboutHandler.Execute(Sender: TWorkItem; Activity: IActivity);
begin
  ShellAboutShow;
end;

{ TfrMain.TReloadConfigurationHandler }

constructor TfrMain.TReloadConfigurationHandler.Create(
  ANavBar: TdxNavBarControlManager);
begin
  FNavBar := ANavBar;
end;

procedure TfrMain.TReloadConfigurationHandler.Execute(Sender: TWorkItem;
  Activity: IActivity);
begin

  App.Entities.ClearMetadataCache;

  Sender.EventTopics[ET_RELOAD_CONFIGURATION].Fire;

  FNavBar.SavePreference;
  FNavBar.BuildMainMenu;
  FNavBar.LoadPreference;
end;

{ TfrMain.TShowViewInfoHandler }

procedure TfrMain.TShowViewInfoHandler.Execute(Sender: TWorkItem;
  Activity: IActivity);
begin
end;

end.
