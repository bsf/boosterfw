unit ICommandBarImpl;

interface
uses classes, cxGroupBox, cxButtons, ActnList, sysutils, CoreClasses, ShellIntf,
  UIClasses, Menus, types, windows, Graphics, forms, controls, CommonUtils;

type
  TButtonAlignment = (alLeft, alRight);

  TICommandBarImpl = class(TComponent, ICommandBar)
  const
    TOP_BOTTOM_MARGIN = 5;
    BUTTON_MIN_WITH = 75;
    BUTTON_MARGIN = 4;
    BUTTON_CAPTION_MARGIN = 22;

  private
    FActionList: TActionList;
    FWorkItem: TWorkItem;
    FBar: TcxGroupBox;
    FButtonAlignment: TButtonAlignment;
    function FindOrCreateGroupButton(ACaption: string): TcxButton;
    function GetButtonWidth(const ACaption: string): integer;
    function CreateButton(const ACaption: string): TcxButton;
    procedure DoExecuteDefaultCommand(Sender: TObject);

  protected
    procedure AddCommand(const AName, ACaption: string; const AShortCut: string = '';
      const AGroup: string = ''; ADefault: boolean = false);
  public
    constructor Create(AOwner: TForm; WorkItem: TWorkItem;
      ABar: TcxGroupBox; AButtonAlignment: TButtonAlignment = alLeft); reintroduce;
  end;

implementation

{ TICommandBarImpl }

procedure TICommandBarImpl.AddCommand(const AName, ACaption: string; const AShortCut: string;
  const AGroup: string; ADefault: boolean);
var
  btn: TcxButton;
  mi: TMenuItem;
  commandAction: TAction;
begin
  commandAction := TAction.Create(FBar);
  commandAction.ActionList := FActionList;

  with FWorkItem.Commands[AName] do
  begin
    Caption := ACaption;
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
    end;
  end
  else
    CreateButton(commandAction.Caption).Action := commandAction;

end;

constructor TICommandBarImpl.Create(AOwner: TForm; WorkItem: TWorkItem;
  ABar: TcxGroupBox; AButtonAlignment: TButtonAlignment);
begin
  inherited Create(AOwner);
  FWorkItem := WorkItem;
  FBar := ABar;
  FActionList := TActionList.Create(AOwner); //for shortcut
  FButtonAlignment := AButtonAlignment;
end;

function TICommandBarImpl.CreateButton(const ACaption: string): TcxButton;
begin
  Result := TcxButton.Create(Owner);

  with Result do
  begin
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

end.
