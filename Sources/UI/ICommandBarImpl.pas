unit ICommandBarImpl;

interface
uses classes, cxGroupBox, cxButtons, ActnList, sysutils, CoreClasses, ShellIntf,
  UIClasses, Menus, types, windows, Graphics, forms, controls, CommonUtils;

type
  TButtonAlignment = (alLeft, alRight);

  TCommandActionLink = class(TActionLink)
  protected
    FClient: TObject;
    FButton: TcxButton;
    procedure AssignClient(AClient: TObject); override;
    procedure SetVisible(Value: Boolean); override;
  end;

  TICommandBarImpl = class(TComponent, ICommandBar)
  const
    TOP_BOTTOM_MARGIN = 5;
    BUTTON_MIN_WITH = 75;
    BUTTON_MARGIN = 4;
    BUTTON_CAPTION_MARGIN = 22;

  private
    FActionList: TActionList;
    FActionLinks: TList;
    FWorkItem: TWorkItem;
    FBar: TcxGroupBox;
    FButtons: TList;
    FButtonAlignment: TButtonAlignment;
    function FindOrCreateGroupButton(ACaption: string): TcxButton;
    function GetButtonWidth(const ACaption: string): integer;
    function CreateButton(const ACaption: string): TcxButton;
    procedure DoExecuteDefaultCommand(Sender: TObject);
    procedure AlignButton(AButton: TcxButton);
  protected
    procedure AddCommand(const AName, ACaption: string; const AShortCut: string = '';
      const AGroup: string = ''; ADefault: boolean = false);
  public
    constructor Create(AOwner: TForm; WorkItem: TWorkItem;
      ABar: TcxGroupBox; AButtonAlignment: TButtonAlignment = alLeft); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TICommandBarImpl }

procedure TICommandBarImpl.AddCommand(const AName, ACaption: string; const AShortCut: string;
  const AGroup: string; ADefault: boolean);
var
  btn: TcxButton;
  mi: TMenuItem;
  commandAction: TAction;
  actionLink: TCommandActionLink;
begin
  commandAction := TAction.Create(FBar);
  commandAction.ActionList := FActionList;

  actionLink := TCommandActionLink.Create(Self);
  FActionLinks.Add(actionLink);
  actionLink.Action := commandAction;

  with FWorkItem.Commands[AName] do
  begin
    Caption := ACaption;
    Group := AGroup;
    ShortCut := AShortCut;
  end;

  FWorkItem.Commands[AName].AddInvoker(commandAction);

  if AGroup <> '' then
  begin
    btn := FindOrCreateGroupButton(AGroup);
    mi := TMenuItem.Create(FBar);
    mi.Action := commandAction;
    btn.DropDownMenu.Items.Add(mi);

    if ADefault then
    begin
      mi.Default := true;
      btn.Kind := cxbkDropDownButton;
      btn.OnClick := DoExecuteDefaultCommand;
      actionLink.FButton := btn;
    end;
  end
  else
  begin
    btn := CreateButton(commandAction.Caption);
    btn.Action := commandAction;
    actionLink.FButton := btn;
  end;
end;

procedure TICommandBarImpl.AlignButton(AButton: TcxButton);
var
  idx: integer;
  I: integer;
  minLeft: integer;
begin
  minLeft := AButton.Left;
  idx := FButtons.IndexOf(AButton);
  for I := idx + 1 to FButtons.Count - 1 do
    if TcxButton(FButtons[I]).Left < minLeft then
      minLeft := TcxButton(FButtons[I]).Left;
  AButton.Left := minLeft;
end;

constructor TICommandBarImpl.Create(AOwner: TForm; WorkItem: TWorkItem;
  ABar: TcxGroupBox; AButtonAlignment: TButtonAlignment);
begin
  inherited Create(AOwner);
  FWorkItem := WorkItem;
  FBar := ABar;
  FActionList := TActionList.Create(AOwner); //for shortcut
  FButtonAlignment := AButtonAlignment;
  FActionLinks := TList.Create;
  FButtons := TList.Create;
end;

function TICommandBarImpl.CreateButton(const ACaption: string): TcxButton;
var
  leftPosition: integer;
begin
  Result := TcxButton.Create(Owner);
  FButtons.Add(Result);
  leftPosition := 0;
  if FBar.ControlCount <> 0 then
    leftPosition := FBar.Controls[FBar.ControlCount - 1].Left +
      FBar.Controls[FBar.ControlCount - 1].Width;

  with Result do
  begin
    Left := leftPosition; //important !!! must be set for fixed position order

    Parent := FBar;
    Caption := ACaption;

    Width := GetButtonWidth(ACaption);

    Margins.Top := TOP_BOTTOM_MARGIN;
    Margins.Bottom := TOP_BOTTOM_MARGIN;
    AlignWithMargins := true;
    if FButtonAlignment = alLeft then
    begin
      Align := TAlign.alLeft;
      Margins.Left := BUTTON_MARGIN;
      Margins.Right := 0;
    end
    else
    begin
      Align := TAlign.alRight;
      Margins.Right := BUTTON_MARGIN;
      Margins.Left := 0;
    end;

    LookAndFeel.Kind := FBar.LookAndFeel.Kind;
    SpeedButtonOptions.CanBeFocused := false;
  end;

  Result.ScaleBy(App.UI.Scale, 100);

end;

destructor TICommandBarImpl.Destroy;
var
  I: integer;
begin
  for I := FActionLinks.Count - 1 downto 0 do
  begin
    TActionLink(FActionLinks[I]).Action := nil;
    TActionLink(FActionLinks[I]).Free;
  end;

  FButtons.Free;

  inherited;
end;

procedure TICommandBarImpl.DoExecuteDefaultCommand(Sender: TObject);
var
  commandAction: TAction;
  P: TPoint;
  menu: TPopupMenu;
  mi: TMenuItem;
  btn: TcxButton;
  I: integer;
begin
  btn := TcxButton(Sender);
  menu := btn.DropDownMenu;
  mi := nil;
  for I := 0 to menu.Items.Count - 1 do
    if menu.Items[I].Default then
    begin
      mi := menu.Items[I];
      Break;
    end;

  commandAction := TAction(mi.Action);

  if not commandAction.Enabled then
  begin
    P := btn.ClientToScreen(Point(0, btn.ClientHeight));
    btn.DropDownMenu.Popup(P.X, P.Y)
  end
  else
    commandAction.Execute;

end;


function TICommandBarImpl.FindOrCreateGroupButton(
  ACaption: string): TcxButton;
var
  I: integer;
begin
  Result := nil;
  for I := 0 to FBar.ControlCount - 1 do
    if (FBar.Controls[I] is TcxButton) and SameText((FBar.Controls[I] as TcxButton).Caption, ACaption) then
      Result := FBar.Controls[I] as TcxButton;

  if Result = nil then
    Result := CreateButton(ACaption);

  if not(Result.Kind in [cxbkDropDown, cxbkDropDownButton]) then
  begin
    Result.Kind := cxbkDropDown;
    Result.DropDownMenu := TPopupMenu.Create(Owner);
  end;
end;

function TICommandBarImpl.GetButtonWidth(const ACaption: string): integer;
begin
  Result := GetTextWidth(FBar.Font, ACaption);
  Result := Result + BUTTON_CAPTION_MARGIN;
  if Result < BUTTON_MIN_WITH then
    Result := BUTTON_MIN_WITH;
end;

{ TCommandActionLink }

procedure TCommandActionLink.AssignClient(AClient: TObject);
begin
  FClient := AClient;
end;

procedure TCommandActionLink.SetVisible(Value: Boolean);
begin
  if Assigned(FButton) then
  begin
    FButton.Visible := Value; //1. For Group Button;
                              //2. ActionLink.SetVisible fired before FButton.ActionLink.SetVisible
    if FButton.Visible then
      TICommandBarImpl(FClient).AlignButton(FButton);
  end;
end;

end.
