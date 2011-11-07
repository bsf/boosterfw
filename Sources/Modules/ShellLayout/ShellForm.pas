unit ShellForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus,ActnList, ComCtrls, ShellIntf,
  ToolWin, ExtCtrls,  Contnrs, cxGraphics,
  cxControls, dxStatusBar,  cxClasses, dxNavBarBase,
  dxNavBarCollns, dxNavBar, cxSplitter, dxBar, dxNavBarGroupItems,
  cxContainer, cxEdit, cxLabel, cxTextEdit, cxHyperLinkEdit, StdActns,
  dxNavBarStyles, CoreClasses, WindowWorkspace,
  cxProgressBar, ShellNavBar,
  ReportServiceIntf,  ImgList, UILocalization,
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
  ActivityCatalog;

const
  STATUSBAR_INFO_PANEL = 0;
  STATUSBAR_PROGRESS_PANEL = 1;

  COMMAND_SHOW_ABOUT = '{9421F2C7-F526-4858-975B-B01698C70530}';
  COMMAND_CLOSE_APP = '{1E3FCF4E-9E40-4D5B-ADE4-3F78428CA24B}';

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
    Panel1: TPanel;
    SplitterNotifyPanel: TcxSplitter;
    pcMain: TcxPageControl;
    cxGroupBox1: TcxGroupBox;
    grNotify: TcxGrid;
    grNotifyListView: TcxGridTableView;
    grNotifyListViewText: TcxGridColumn;
    grNotifyLevel1: TcxGridLevel;
    grNotifyListViewTime: TcxGridColumn;
    cxStyleNotifyCellTime: TcxStyle;
    cxStyleNotifyCellText: TcxStyle;
    grNotifyListViewID: TcxGridColumn;
    grNotifyListViewSENDER: TcxGridColumn;
    grNotifyListViewHeader: TcxGridColumn;
    ilNavBarSmall: TImageList;
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

    FViewStyleController: TViewStyleController;
    FNavBarControlManager: TdxNavBarControlManager;

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

    type
      TShowAboutHandler = class(TActivityHandler)
        procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
      end;

  public
    constructor Create(AOwner: TComponent); override;
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
  CanClose := App.UI.MessageBox.ConfirmYesNo('Закрыть программу ?');
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
end;


procedure TfrMain.Initialize(AWorkItem: TWorkItem);
begin
  Self.Color := dxOffice11ToolbarsColor1;
  Panel1.Color := Self.Color;
  pcMain.Color := Self.Color;
  FWorkItem := AWorkItem;

  FScale := (FWorkItem.Services[IUIService] as IUIService).ViewStyle.Scale;
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

  FWorkItem.EventTopics[ET_REPORT_PROGRESS_START].AddSubscription(Self, WaitProgressStartHandler);
  FWorkItem.EventTopics[ET_REPORT_PROGRESS_FINISH].AddSubscription(Self, WaitProgressStopHandler);
  FWorkItem.EventTopics[ET_REPORT_PROGRESS_PROCESS].AddSubscription(Self, WaitProgressUpdateHandler);

  FWorkItem.EventTopics[etAppStarted].AddSubscription(Self, AppStartedHandler);
  FWorkItem.EventTopics[etAppStoped].AddSubscription(Self, AppStopedHandler);

  RegisterShellCommands;

  TActivityCatalog.Create(Self, FWorkItem).Load;

  Localization;

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
begin
  FViewStyleController.LoadPreferences;

  FNavBarControlManager.BuildMainMenu;
  FNavBarControlManager.LoadPreference;

  FWorkItem.EventTopics[ET_ENTITY_VIEW_OPEN_START].AddSubscription(Self, WaitProgressStartHandler);
  FWorkItem.EventTopics[ET_ENTITY_VIEW_OPEN_FINISH].AddSubscription(Self, WaitProgressStopHandler);

  FWorkItem.EventTopics[ET_WAITBOX_START].AddSubscription(Self, WaitProgressStartHandler);
  FWorkItem.EventTopics[ET_WAITBOX_STOP].AddSubscription(Self, WaitProgressStopHandler);

end;

procedure TfrMain.AppStopedHandler(EventData: Variant);
begin
  FNavBarControlManager.SavePreference;
end;

procedure TfrMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if assigned(FContentWorkspace) then
    FContentWorkspace.ShortCutHandler(Msg, Handled);
end;

procedure TfrMain.RegisterShellCommands;
begin
{
  with WorkItem.Activities.Infos.Add(COMMAND_LOCK_APP) do
  begin
    Title := 'Блокировка';
    Group := MAIN_MENU_FILE_GROUP;
    ShortCut := 'Ctrl+L';
  end;
 }
  with WorkItem.Activities[COMMAND_CLOSE_APP] do
  begin
    Title := 'Закрыть';
    Group := MAIN_MENU_FILE_GROUP;
  end;
  WorkItem.Activities.RegisterHandler(COMMAND_CLOSE_APP, TCloseAppHandler.Create(Self));

//  WorkItem.Actions[COMMAND_CLOSE_APP].SetHandler(CloseAppHandler);

  with WorkItem.Activities[COMMAND_SHOW_ABOUT] do
  begin
    Title := 'О программе...';
    Group := MAIN_MENU_FILE_GROUP;
  end;
  WorkItem.Activities.RegisterHandler(COMMAND_SHOW_ABOUT, TShowAboutHandler.Create);

  with WorkItem.Activities[URI_USERPREFERENCES] do
  begin
    Title := 'Предпочтения';
    Group := MAIN_MENU_SERVICE_GROUP;
  end;
  WorkItem.Activities.RegisterHandler(URI_USERPREFERENCES,
    TViewActivityHandler.Create(TUserPreferencesPresenter, TfrUserPreferencesView));

  WorkItem.Root.WorkItems.Add(TNotifyReceiver, TNotifyReceiver.ClassName);

  with WorkItem.Activities[VIEW_NOTIFYSENDER] do
  begin
    Title := VIEW_NOTIFYSENDER_TITLE;
    Group := MAIN_MENU_SERVICE_GROUP;
    UsePermission := true;
  end;
  WorkItem.Activities.RegisterHandler(VIEW_NOTIFYSENDER,
    TViewActivityHandler.Create(TNotifySenderPresenter, TfrNotifySenderView));
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

end.
