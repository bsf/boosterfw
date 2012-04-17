unit ICommandBarImpl;

interface
uses classes, cxGroupBox, cxButtons, ActnList, sysutils, CoreClasses, ShellIntf,
  UIClasses, Menus, types, windows, Graphics, forms, controls, CommonUtils;

const
  const_TopMargin: integer = 8;
  const_CaptionMargin = 22;
  const_ButtonMargin = 4;
  const_ButtonMinWidth = 75;
  const_ButtonHeight = 25;

type
  TButtonAlignment = (alLeft, alRight);

  TICommandBarImpl = class(TComponent, ICommandBar)
  private
    FActionList: TActionList;
    FWorkItem: TWorkItem;
    FBar: TcxGroupBox;
    FButtonAlignment: TButtonAlignment;
    function FindOrCreateGroupButton(ACaption: string): TcxButton;
    function GetNextButtonPosition: integer;
    function GetTopMargin: integer;
    function GetButtonMargin: integer;
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


//  AddCommand(AName, AGroup, ADefault);
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
var
  nextPosition: integer;
begin
  nextPosition := GetNextButtonPosition;
  Result := TcxButton.Create(Owner);

  with Result do
  begin
    Parent := FBar;
    Caption := ACaption;

    Width := GetButtonWidth(ACaption);
    Height :=  const_ButtonHeight;

    Top := GetTopMargin;
    if FButtonAlignment = alLeft then
      Left := nextPosition
    else
      Left := nextPosition - MulDiv(Width, App.UI.Scale, 100);

    if FButtonAlignment = alRight then
      Anchors := [akRight, akBottom];

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

function TICommandBarImpl.GetButtonMargin: integer;
begin
  Result := MulDiv(const_ButtonMargin, App.UI.Scale, 100);
end;

function TICommandBarImpl.GetButtonWidth(const ACaption: string): integer;
begin
  Result := GetTextWidth(FBar.Font, ACaption);
  Result := Result + const_CaptionMargin;
  if Result < const_ButtonMinWidth then
    Result := const_ButtonMinWidth;
end;

function TICommandBarImpl.GetNextButtonPosition: integer;
var
  I: integer;
begin
  if FButtonAlignment = alLeft then
  begin
    Result := 0;

    for I := 0 to FBar.ControlCount - 1 do
      if (FBar.Controls[I] is TcxButton) and
         ((FBar.Controls[I].Width + FBar.Controls[I].Left) > Result) then
        Result := FBar.Controls[I].Width + FBar.Controls[I].Left;

    Result := Result + GetButtonMargin;
  end
  else
  begin
    Result := MaxInt;

    for I := 0 to FBar.ControlCount - 1 do
      if (FBar.Controls[I] is TcxButton) and
         ((FBar.Controls[I].Width + FBar.Controls[I].Left) < Result) then
        Result := FBar.Controls[I].Left;

    if Result = MaxInt then  Result := FBar.Width;

    Result := Result - GetButtonMargin;
  end
end;

function TICommandBarImpl.GetTopMargin: integer;
begin
  Result := MulDiv(const_TopMargin, App.UI.Scale, 100);
end;

end.
