unit ViewManagerService;

interface
uses classes, CoreClasses, Controls, Contnrs, ViewServiceIntf, SysUtils, dialogs,
  forms, windows, ConfigServiceIntf, variants;

type
  TViewClassItem = class(TObject)
    ViewURI: string;
    ViewClass: TViewClass;
  end;

  TPresenterClassItem = class(TObject)
    ViewURI: string;
    PresenterClass: TPresenterClass;
    PresenterOwner: TWorkItem;
  end;

  TExtensionClassItem = class(TObject)
    ViewURI: string;
    ExtensionClass: TViewExtensionClass;
  end;

  TViewManagerService = class(TComponent, IViewManagerService, IMessageBox, IInputBox, IWaitBox, IViewStyle)
  private
    FWorkItem: TWorkItem;
    FViews: TObjectList;
    FPresenters: TObjectList;
    FExtensions: TObjectList;
    function FindPresenterClassItem(const ViewURI: string): TPresenterClassItem;
    function FindViewClassItem(const ViewURI: string): TViewClassItem;
    procedure ExecutePresenter(Sender: IAction);
    procedure InstantiateExtensions(AView: TView);
  protected
    //IViewManagerService
    procedure RegisterView(const ViewURI: string; AViewClass: TViewClass;
      APresenterClass: TPresenterClass);


    procedure RegisterExtension(const ViewURI: string;
      AExtensionClass: TViewExtensionClass);

    function GetView(const ViewURI: string; APresenter: TPresenter): IView;

    function MessageBox: IMessageBox;
    function InputBox: IInputBox;
    function WaitBox: IWaitBox;
    // IMessageBox
    function ConfirmYesNo(const AMessage: string): boolean;
    function ConfirmYesNoCancel(const AMessage: string): integer;
    procedure InfoMessage(const AMessage: string);
    procedure ErrorMessage(const AMessage: string);
    procedure StatusBarMessage(const AMessage: string);
    // InputBox
    function InputString(const APrompt: string; var AText: string): boolean;
    // WaitBox
    procedure StartWait;
    procedure StopWait;
    // IViewStyle
    function GetViewScale: integer;
    function ViewStyle: IViewStyle;
    function IViewStyle.Scale = GetViewScale;
    procedure Notify(const AMessage: string);
    procedure NotifyExt(const AID, ASender, AMessage: string; ADateTime: TDateTime);
    procedure NotifyAccept(const AID: string);
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TViewManagerService }

function TViewManagerService.ConfirmYesNo(const AMessage: string): boolean;
begin
  Result := Application.MessageBox(PChar(AMessage), PChar(Application.Title),
     MB_YESNO + MB_ICONQUESTION) = ID_YES;
end;

function TViewManagerService.ConfirmYesNoCancel(
  const AMessage: string): integer;
begin
  Result := Application.MessageBox(PChar(AMessage), PChar(Application.Title),
     MB_YESNOCANCEL + MB_ICONQUESTION);
end;

constructor TViewManagerService.Create(AOwner: TComponent;  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
  FViews := TObjectList.Create(true);
  FPresenters := TObjectList.Create(true);
  FExtensions := TObjectList.Create(true);
end;

destructor TViewManagerService.Destroy;
begin
  FViews.Free;
  FPresenters.Free;
  FExtensions.Free;
  inherited;
end;


procedure TViewManagerService.ErrorMessage(const AMessage: string);
begin
  Windows.MessageBox(Application.Handle, PChar(AMessage),
    'Œ¯Ë·Í‡', MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_SETFOREGROUND + MB_TOPMOST);
end;

procedure TViewManagerService.ExecutePresenter(Sender: IAction);
var
  presenterClassItem: TPresenterClassItem;
begin
  presenterClassItem := FindPresenterClassItem(Sender.Name);
  if not Assigned(presenterClassItem) then
    raise Exception.CreateFmt('Presenter for URI %s not found', [Sender.Name]);

  presenterClassItem.PresenterClass.Execute(Sender, FWorkItem);

end;

function TViewManagerService.FindPresenterClassItem(
  const ViewURI: string): TPresenterClassItem;
var
  I: integer;
begin
  for I := 0 to FPresenters.Count - 1 do
  begin
    Result := TPresenterClassItem(FPresenters[I]);
    if Result.ViewURI = ViewURI then Exit;
  end;
  Result := nil;
end;

function TViewManagerService.FindViewClassItem(const ViewURI: string): TViewClassItem;
var
  I: integer;
begin
  for I := 0 to FViews.Count - 1 do
  begin
    Result := TViewClassItem(FViews[I]);
    if Result.ViewURI = ViewURI then Exit;
  end;
  Result := nil;
end;

function TViewManagerService.GetView(const ViewURI: string;
  APresenter: TPresenter): IView;
var
  presenterWI: TWorkItem;
  viewClassItem: TViewClassItem;
  view: TObject;
  viewID: string;
begin
  presenterWI := APresenter.WorkItem;
  viewID := 'View_' + ViewURI;
  view := presenterWI.Items[viewID, TView];
  if Assigned(view) then
  begin
    Result := TView(view) as IView;
    Exit;
  end;

  viewClassItem := FindViewClassItem(ViewURI);
  if not Assigned(viewClassItem) then
    raise Exception.CreateFmt('View for URI %s not found', [ViewURI]);

  view := viewClassItem.ViewClass.Create(presenterWI, ViewURI);
  Result := (view as TView) as IView;
  if not Assigned(Result) then
  begin
    view.Free;
    raise Exception.CreateFmt('ViewClass %s not implement %s interface',
      [viewClassItem.ViewClass.ClassName, GUIDToString(IView)]);
  end;

  presenterWI.Items.Add(viewID, view);
  InstantiateExtensions(view as TView);

  (view as TForm).ScaleBy(GetViewScale, 100);

end;

procedure TViewManagerService.InfoMessage(const AMessage: string);
begin
  Windows.MessageBox(Application.Handle, PChar(AMessage),
    PChar(Application.Title), MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_SETFOREGROUND + MB_TOPMOST);
end;

procedure TViewManagerService.InstantiateExtensions(AView: TView);
var
  extensionClassItem: TExtensionClassItem;
  I: integer;
begin
  for I := 0 to FExtensions.Count - 1 do
  begin
    extensionClassItem := (FExtensions[I] as TExtensionClassItem);
    if extensionClassItem.ViewURI = (AView as IView).ViewURI then
      extensionClassItem.ExtensionClass.Create(AView);
  end;
end;

function TViewManagerService.InputBox: IInputBox;
begin
  Result := Self as IInputBox;
end;

function TViewManagerService.InputString(const APrompt: string;
  var AText: string): boolean;
begin
  Result := InputQuery(Application.Title, APrompt, AText);
end;

function TViewManagerService.MessageBox: IMessageBox;
begin
  Result := Self as IMessageBox;
end;

procedure TViewManagerService.RegisterExtension(const ViewURI: string;
  AExtensionClass: TViewExtensionClass);
var
  ExtensionClassItem: TExtensionClassItem;
begin
  ExtensionClassItem := TExtensionClassItem.Create;
  ExtensionClassItem.ExtensionClass := AExtensionClass;
  ExtensionClassItem.ViewURI := ViewURI;
  FExtensions.Add(ExtensionClassItem);
end;


procedure TViewManagerService.RegisterView(const ViewURI: string;
  AViewClass: TViewClass; APresenterClass: TPresenterClass);
var
  item: TPresenterClassItem;
  ViewClassItem: TViewClassItem;
begin

  ViewClassItem := FindViewClassItem(ViewURI);
  if Assigned(ViewClassItem) then
    FViews.Remove(ViewClassItem);

  ViewClassItem := TViewClassItem.Create;
  ViewClassItem.ViewClass := AViewClass;
  ViewClassItem.ViewURI := ViewURI;
  FViews.Add(ViewClassItem);

  item := FindPresenterClassItem(ViewURI);
  if Assigned(Item) then
    FPresenters.Remove(item);

  item := TPresenterClassItem.Create;
  item.ViewURI := ViewURI;
  item.PresenterClass := APresenterClass;
  FPresenters.Add(item);

  FWorkItem.Actions[ViewURI].SetHandler(ExecutePresenter);
  FWorkItem.Actions[ViewURI].SetDataClass(APresenterClass.ExecuteDataClass);

end;

procedure TViewManagerService.StatusBarMessage(const AMessage: string);
begin
  FWorkItem.EventTopics[ET_STATUSBARMESSAGE].Fire(AMessage);
end;

function TViewManagerService.ViewStyle: IViewStyle;
begin
  Result := Self as IViewStyle;
end;

function TViewManagerService.GetViewScale: integer;
var
  conf_scale: string;
begin
  Result := 100;
  conf_scale := (FWorkItem.Services[IConfigurationService] as IConfigurationService).Settings['ViewStyle.Scale'];
  if conf_scale = '2' then
    Result := 120;
end;

procedure TViewManagerService.StartWait;
begin
  FWorkItem.EventTopics[ET_WAITBOX_START].Fire;
end;

procedure TViewManagerService.StopWait;
begin
  FWorkItem.EventTopics[ET_WAITBOX_STOP].Fire;
end;

function TViewManagerService.WaitBox: IWaitBox;
begin
  Result := Self as IWaitBox;
end;

procedure TViewManagerService.Notify(const AMessage: string);
begin
  NotifyExt('', '', AMessage, Now());
end;

procedure TViewManagerService.NotifyAccept(const AID: string);
begin
  FWorkItem.EventTopics[ET_NOTIFY_ACCEPT].Fire(AID);
end;

procedure TViewManagerService.NotifyExt(const AID, ASender,
  AMessage: string; ADateTime: TDateTime);
begin
  FWorkItem.EventTopics[ET_NOTIFY_MESSAGE].Fire(VarArrayOf([AID, ASender, AMessage, ADateTime]));
end;

end.
