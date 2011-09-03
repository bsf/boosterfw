unit WindowWorkspace;

interface

uses Classes, Controls, CoreClasses, Workspace, Forms, Contnrs, messages,
  windows;

type
  TWindowSiteInfo = class(TViewSiteInfo)
  private
    FForm: TForm;
    FModal: boolean;
    procedure SetModal(const Value: boolean);
    procedure SetStyle(const Value: TFormStyle);
    function GetStyle: TFormStyle;
    function GetPosition: TPosition;
    procedure SetPosition(const Value: TPosition);
    function GetWindowState: TWindowState;
    procedure SetWindowState(const Value: TWindowState);
    function GetHeight: integer;
    procedure SetWidth(const Value: integer);
    function GetWidth: integer;
    procedure SetHeight(const Value: integer);
    function GetModalResult: TModalResult;
    procedure SetModalResult(const Value: TModalResult);
  protected
    procedure SetTitle(const AValue: string); override;
  public
    constructor Create(AOwner: TComponent; AForm: TForm); reintroduce;
    property Modal: boolean read FModal write SetModal;
    property ModalResult: TModalResult read GetModalResult write SetModalResult;
    property Style: TFormStyle read GetStyle write SetStyle;
    property Position: TPosition read GetPosition write SetPosition;
    property WindowState: TWindowState read GetWindowState write SetWindowState;
    property Height: integer read GetHeight write SetHeight;
    property Width: integer read GetWidth write SetWidth;
  end;

  TWindowSiteInfoClass = class of TWindowSiteInfo;

  TWindowWorkspace = class;

  TWindowItem = class(TComponent)
  private
    FInfo: TWindowSiteInfo;
    FForm: TForm;
    FView: TControl;
    FViewParent: TWinControl;
    FInitTitle: string;
    function Workspace: TWindowWorkspace;
    procedure OnFormShortCutHandler(var Msg: TWMKey; var Handled: Boolean);
    procedure OnFormShowHandler(Sender: TObject);
    procedure OnFormCloseHandler(Sender: TObject; var Action: TCloseAction);
    procedure OnFormKeyPress(Sender: TObject; var Key: Char);
    procedure OnFormChangeCaptionHandler;
    procedure OnFormActivateHandler(Sender: TObject);
    procedure OnFormDeactivateHandler(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TWindowWorkspace; AView: TControl;
      const ATitle: string); reintroduce;
    destructor Destroy; override;
    procedure Show;
    function Close: boolean;
    property Info: TWindowSiteInfo read FInfo;
  end;

  TWindowWorkspace = class(TWorkspace)
  private
    FScaleM: integer;
    FScaleD: integer;
    FItems: TComponentList;
    function FindWindowItem(AView: TControl; EnsureExists: boolean): TWindowItem;
  protected
    function GetSiteInfoClass: TWindowSiteInfoClass; virtual;
    function GetFormClass: TFormClass; virtual;
    function GetForm(AView: TControl): TForm;
    function Add(AView: TControl; const ATitle: string): TViewSiteInfo; virtual;
    //IWorkspace
    function ViewCount: integer; override;
    function GetView(Index: integer): TControl; override;
    function ViewExists(AView: TControl): boolean; override;
    procedure Show(AView: TControl; const ATitle: string); override;
    function Close(AView: TControl): boolean; override;
    function GetViewSiteInfo(AView: TControl): TViewSiteInfo; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ScaleBy(M, D: Integer); override;
  end;

  TMdiWorkspace = class(TWindowWorkspace)
  protected
    function Add(AView: TControl; const ATitle: string): TViewSiteInfo; override;
  end;

  TDialogWorkspace = class(TWindowWorkspace)
  protected
    function Add(AView: TControl; const ATitle: string): TViewSiteInfo; override;
    function GetFormClass: TFormClass; override;
  end;

  TDialogForm = class(TForm)
  protected
    procedure WMClose(var Message: TWMClose); message WM_CLOSE;
    procedure CMRelease(var Message: TMessage); message CM_RELEASE;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

implementation

{ TWindowWorkspace }

function TWindowWorkspace.Close(AView: TControl): boolean;
begin
  Result := FindWindowItem(AView, true).Close;

//  SendMessage(FindWindowItem(AView, true).FForm.Handle, WM_CLOSE, 0, 0);
end;

constructor TWindowWorkspace.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TComponentList.Create(True);
  FScaleM := 96;
  FScaleD := 96;
end;

function TWindowWorkspace.Add(AView: TControl; const ATitle: string): TViewSiteInfo;
var
  Item: TWindowItem;
begin
  Item := TWindowItem.Create(Self, AView, ATitle);
  FItems.Add(Item);
  Result := Item.Info;
  Item.FForm.ScaleBy(FScaleM, FScaleD);
end;

destructor TWindowWorkspace.Destroy;
var
  I: integer;
begin
  for I := FItems.Count - 1 downto 0 do
    TWindowItem(FItems[I]).Close;
  FItems.Free;
  inherited;
end;

function TWindowWorkspace.FindWindowItem(AView: TControl;
  EnsureExists: boolean): TWindowItem;
var
  I: integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Result := TWindowItem(FItems[I]);
    if Result.FView = AView then Exit;
  end;

  Result := nil;

  if EnsureExists then
    raise EViewMissingError.Create('View not found.');
end;

procedure TWindowWorkspace.Show(AView: TControl; const ATitle: string);
var
  Item: TWindowItem;
begin
  Item := FindWindowItem(AView, false);
  if Item = nil then
    Add(AView, ATitle);

  Item := FindWindowItem(AView, true);
  Item.Info.Title := ATitle;
  Item.Show;
end;

function TWindowWorkspace.GetViewSiteInfo(AView: TControl): TViewSiteInfo;
begin
  Result := FindWindowItem(AView, true).Info;
end;

function TWindowWorkspace.GetSiteInfoClass: TWindowSiteInfoClass;
begin
  Result := TWindowSiteInfo;
end;

function TWindowWorkspace.GetFormClass: TFormClass;
begin
  Result := TForm;
end;

function TWindowWorkspace.GetView(Index: integer): TControl;
begin
  Result := TWindowItem(FItems[Index]).FView;
end;

function TWindowWorkspace.ViewCount: integer;
begin
  Result := FItems.Count;
end;

function TWindowWorkspace.GetForm(AView: TControl): TForm;
begin
  Result := FindWindowItem(AView, true).FForm;  
end;

function TWindowWorkspace.ViewExists(AView: TControl): boolean;
begin
  result := Assigned(FindWindowItem(AView, false));
end;

procedure TWindowWorkspace.ScaleBy(M, D: integer);
var
  I: integer;
begin
  FScaleM := M;
  FScaleD := D;

  for I := 0 to FItems.Count - 1 do
    TWindowItem(FItems[I]).FForm.ScaleBy(FScaleM, FScaleD);
end;

{ TWindowItem }

function TWindowItem.Close: boolean;
var
  CanClose: boolean;
begin
  CanClose := true;
  FForm.BringToFront;
  Workspace.DoViewCloseQuery(FView, CanClose);
  Result := CanClose;
  if Result then
    FForm.Close; // для модальных окон обязательно делать Close а не Release
end;

constructor TWindowItem.Create(AOwner: TWindowWorkspace; AView: TControl;
  const ATitle: string);
begin
  inherited Create(AOwner);
  FView := AView;
  FInitTitle := ATitle;
  FView.FreeNotification(Self);
  FViewParent := AView.Parent;

  if AOwner.GetFormClass = TDialogForm then
    FForm := AOwner.GetFormClass.CreateNew(Self)
  else
    FForm := AOwner.GetFormClass.Create(Self);

  FInfo := AOwner.GetSiteInfoClass.Create(Self, FForm);

  FForm.FreeNotification(Self);

  FInfo.Height := FView.Height;
  FInfo.Width := FView.Width;

  if not Owner.InheritsFrom(TMdiWorkspace) then
    FForm.OnShow := OnFormShowHandler;  //for MDI Child fired OnCreate !!!

  FForm.OnActivate := OnFormActivateHandler;
  FForm.OnDeactivate := OnFormDeactivateHandler;
  FForm.OnClose := OnFormCloseHandler;
  FForm.OnShortCut := OnFormShortCutHandler;
  FForm.OnKeyPress := OnFormKeyPress;
  FInfo.Title := FInitTitle;
end;

destructor TWindowItem.Destroy;
begin
  if Assigned(FView) then
    TWindowWorkspace(Owner).DoViewClose(FView);

  if Assigned(FView) then
  begin
    FView.Parent := FViewParent;
    FView.RemoveFreeNotification(Self);
  end;
  
  inherited;

end;


procedure TWindowItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FView) then
    FView := nil;
end;

procedure TWindowItem.OnFormActivateHandler(Sender: TObject);
begin
  TWindowWorkspace(Owner).DoViewActivate(FView);
end;

procedure TWindowItem.OnFormChangeCaptionHandler;
begin
  TWindowWorkspace(Owner).DoViewSiteChange(FView);
end;

procedure TWindowItem.OnFormCloseHandler(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;

  FForm.OnDeactivate := nil; // иначе AV!!!

  if Assigned(FView) then
    TWindowWorkspace(Owner).DoViewDeactivate(FView);
end;


procedure TWindowItem.OnFormDeactivateHandler(Sender: TObject);
begin
  TWindowWorkspace(Owner).DoViewDeactivate(FView);
end;

procedure TWindowItem.OnFormKeyPress(Sender: TObject; var Key: Char);
begin
  TWindowWorkspace(Owner).DoViewKeyPress(FView, Key);
end;

procedure TWindowItem.OnFormShortCutHandler(var Msg: TWMKey;
  var Handled: Boolean);
begin
  TWindowWorkspace(Owner).DoViewShortCut(FView, Msg, Handled);
end;

procedure TWindowItem.OnFormShowHandler(Sender: TObject);
begin
  {if (FView is TWinControl) and TWinControl(FView).CanFocus then
    TWinControl(FView).SetFocus;}
  TWindowWorkspace(Owner).DoViewShow(FView);
end;

procedure TWindowItem.Show;
begin
  FView.Parent := FForm;
  if FInfo.Modal then
    FForm.ShowModal
  else
  if Owner.InheritsFrom(TMdiWorkspace) then
  begin
    FForm.Show;
    OnFormShowHandler(FForm); // for MDI Child fired OnCreate !!!
  end
  else
    FForm.Show;
end;

function TWindowItem.Workspace: TWindowWorkspace;
begin
  Result := TWindowWorkspace(Owner);
end;

{ TMdiWorkspace }

function TMdiWorkspace.Add(AView: TControl; const ATitle: string): TViewSiteInfo;
begin
  Result := inherited Add(AView, ATitle);
  with TWindowSiteInfo(Result) do
  begin
    Style := fsMDIChild;
    WindowState := wsMaximized;
  end;
end;

{ TWindowSiteInfo }

constructor TWindowSiteInfo.Create(AOwner: TComponent; AForm: TForm);
begin
  inherited Create(AOwner);
  FForm := AForm;
end;

function TWindowSiteInfo.GetHeight: integer;
begin
  Result := FForm.Height;  
end;

function TWindowSiteInfo.GetModalResult: TModalResult;
begin
  Result := FForm.ModalResult;
end;

function TWindowSiteInfo.GetPosition: TPosition;
begin
  Result := FForm.Position;
end;

function TWindowSiteInfo.GetStyle: TFormStyle;
begin
  Result := FForm.FormStyle;
end;

function TWindowSiteInfo.GetWidth: integer;
begin
  Result := FForm.Width;
end;

function TWindowSiteInfo.GetWindowState: TWindowState;
begin
  Result := FForm.WindowState;
end;

procedure TWindowSiteInfo.SetHeight(const Value: integer);
begin
  FForm.Height := Value;
end;

procedure TWindowSiteInfo.SetModal(const Value: boolean);
begin
  FModal := Value;
end;

procedure TWindowSiteInfo.SetModalResult(const Value: TModalResult);
begin
  FForm.ModalResult := Value;
end;

procedure TWindowSiteInfo.SetPosition(const Value: TPosition);
begin
  FForm.Position := Value;
end;

procedure TWindowSiteInfo.SetStyle(const Value: TFormStyle);
begin
  FForm.FormStyle := Value;
  if FForm.FormStyle = fsMdiChild then
    FForm.WindowState := wsMaximized;
end;

procedure TWindowSiteInfo.SetTitle(const AValue: string);
begin
  inherited;
  FForm.Caption := AValue;
  TWindowItem(Owner).OnFormChangeCaptionHandler;
end;

procedure TWindowSiteInfo.SetWidth(const Value: integer);
begin
  FForm.Width := Value;
end;

procedure TWindowSiteInfo.SetWindowState(const Value: TWindowState);
begin
  FForm.WindowState := Value;
end;

{ TDialogWorkspace }

function TDialogWorkspace.Add(AView: TControl;
  const ATitle: string): TViewSiteInfo;
begin
  Result := inherited Add(AView, ATitle);
  with TWindowSiteInfo(Result) do
  begin
    Position := poScreenCenter;
    Modal := true;
  end;
end;

function TDialogWorkspace.GetFormClass: TFormClass;
begin
  Result := TDialogForm;
end;

{ TDialogForm }

procedure TDialogForm.CMRelease(var Message: TMessage);
begin
  TWindowItem(Owner).Free;
end;

constructor TDialogForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;
  BorderIcons := [biSystemMenu, biMaximize];
  BorderStyle := bsDialog;
end;

procedure TDialogForm.WMClose(var Message: TWMClose);
begin
  TWindowItem(Owner).Close;
end;

end.
