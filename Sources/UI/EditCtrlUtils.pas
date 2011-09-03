unit EditCtrlUtils;

interface
uses classes, CustomView, CommonViewIntf, cxEdit, controls, Typinfo,
  cxDropDownEdit, cxDateUtils, sysutils, strUtils;

type
  TcxCustomViewValueEditorHelper = class(TViewHelper, IViewValueEditorHelper)
  private
    FViewValueChangedHandler: TViewValueChangedHandler;
    procedure EditValueChangedHandler(Sender: TObject);
    function FindEditorLabel(AControl: TComponent): TControl;
  protected
    //IViewValueEditorHelper
    function CheckEditorClass(AControl: TComponent): boolean; virtual; abstract;
    function ReadValue(AControl: TComponent): Variant; virtual;
    procedure WriteValue(AControl: TComponent; AValue: Variant); virtual;
    procedure SetValueChangedHandler(AControl: TComponent;
      AHandler: TViewValueChangedHandler);
    function ReadValueStatus(AControl: TComponent): TValueStatus;
    procedure WriteValueStatus(AControl: TComponent; AStatus: TValueStatus);
  end;

  TcxEditHelper = class(TcxCustomViewValueEditorHelper)
  protected
    function CheckEditorClass(AControl: TComponent): boolean; override;
  end;

  TcxComboBoxHelper = class(TcxCustomViewValueEditorHelper)
  protected
    //IViewValueEditorHelper
    function CheckEditorClass(AControl: TComponent): boolean; override;
    function ReadValue(AControl: TComponent): Variant; override;
    procedure WriteValue(AControl: TComponent; AValue: Variant); override;

  end;


implementation

type
  TcxCustomeEditAccess = class(TcxCustomEdit)
  end;


{ TcxCustomViewValueEditorHelper }


procedure TcxCustomViewValueEditorHelper.EditValueChangedHandler(
  Sender: TObject);
begin
  if Assigned(FViewValueChangedHandler) then
    FViewValueChangedHandler(TComponent(Sender).Name);
end;

function TcxCustomViewValueEditorHelper.FindEditorLabel(
  AControl: TComponent): TControl;
var
  I: integer;
  cmp: TComponent;
begin
  Result := nil;
  for I := 0 to AControl.Owner.ComponentCount - 1 do
  begin
    cmp := AControl.Owner.Components[I];
    if cmp is TControl and Typinfo.IsPublishedProp(cmp, 'FocusControl')
       and (Typinfo.GetObjectProp(cmp, 'FocusControl') = AControl) then
    begin
      Result := TControl(cmp);
      Exit;
    end
  end;
end;

function TcxCustomViewValueEditorHelper.ReadValue(
  AControl: TComponent): Variant;
begin
  Result := TcxCustomEdit(AControl).EditValue;
end;

function TcxCustomViewValueEditorHelper.ReadValueStatus(
  AControl: TComponent): TValueStatus;
begin
  if (not TcxCustomEdit(AControl).Enabled) and (not TcxCustomEdit(AControl).Visible) then
    Result := vsUnavailable
  else if (not TcxCustomEdit(AControl).Enabled) then
    Result := vsDisabled
  else
    Result := vsEnabled;
end;

procedure TcxCustomViewValueEditorHelper.SetValueChangedHandler(
  AControl: TComponent; AHandler: TViewValueChangedHandler);
begin
  FViewValueChangedHandler := AHandler;
  TcxCustomeEditAccess(AControl).Properties.OnEditValueChanged :=
    EditValueChangedHandler;
end;

procedure TcxCustomViewValueEditorHelper.WriteValue(AControl: TComponent;
  AValue: Variant);
begin
  TcxCustomEdit(AControl).EditValue := AValue;
end;

procedure TcxCustomViewValueEditorHelper.WriteValueStatus(
  AControl: TComponent; AStatus: TValueStatus);
var
  valueLabel: TControl;
begin

  case AStatus of

    vsEnabled: begin
      TcxCustomEdit(AControl).Enabled := True;
      TcxCustomEdit(AControl).Visible := True;
    end;

    vsDisabled: begin
      TcxCustomEdit(AControl).Enabled := False;
      TcxCustomEdit(AControl).Visible := True;
    end;

    vsUnavailable: begin
      TcxCustomEdit(AControl).Enabled := False;
      TcxCustomEdit(AControl).Visible := False;
    end;

  end;

  valueLabel := FindEditorLabel(AControl);
  if Assigned(valueLabel) then
  begin
    valueLabel.Enabled := TcxCustomEdit(AControl).Enabled;
    valueLabel.Visible := TcxCustomEdit(AControl).Visible;
  end;
end;

{ TcxEditHelper }

function TcxEditHelper.CheckEditorClass(AControl: TComponent): boolean;
begin
  Result := (AControl is TcxCustomEdit)
            and (not (AControl is TcxComboBox));
end;


{ TcxComboBoxHelper }

function TcxComboBoxHelper.CheckEditorClass(AControl: TComponent): boolean;
begin
  Result := AControl is TcxComboBox;
end;

function TcxComboBoxHelper.ReadValue(AControl: TComponent): Variant;
begin
  Result := (AControl as TcxComboBox).ItemIndex;
end;

procedure TcxComboBoxHelper.WriteValue(AControl: TComponent;
  AValue: Variant);
begin
  (AControl as TcxComboBox).ItemIndex := AValue;
end;

function MySmartTextToDate(const AText: string; var ADate: TDateTime): Boolean;
var
  Year: Integer;
  Month: Integer;
  Day: integer;
  DayStr: string;
begin
  if (AText <> '') and (Length(AText) <= 3) then
  begin
    DayStr := AText;
    if Length(DayStr) = 3 then
      Delete(DayStr, 3, 1);

    Day := StrToIntDef(DayStr, 0);
    if Day in [1..31] then
    begin
      Year := GetDateElement(Date, deYear);
      Month := GetDateElement(Date, deMonth);
      ADate := EncodeDate(Year, Month, Day);

      //Indicating that function was a success.
      Result := True;
    end
    else
      Result := false;
  end
  else
    //Otherwise the function was a failure.
    Result := false;
end;



initialization
  RegisterViewHelperClass(TcxEditHelper);
  RegisterViewHelperClass(TcxComboBoxHelper);
  cxDateUtils.SmartTextToDateFunc := MySmartTextToDate;
end.
