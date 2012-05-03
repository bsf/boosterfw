unit ISelectionGridImpl;

interface
uses classes, UIClasses, CustomView, cxGrid, cxGridCustomTableView, cxGridTableView,
  Variants, sysutils, contnrs, cxGridDBTableView, cxGridDBBandedTableView,
  CoreClasses, cxDBData, cxGridDBDataDefinitions, db;

type

  TISelectionGridImpl = class(TComponent, ISelection)
  private
    FWorkItem: TWorkItem;
    FGridView: TcxGridTableView;
    FSelectionChangedHandler: TSelectionChangedHandler;
    FChangedCommand: string;
    procedure OnGridViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure OnGridViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  protected
    procedure SetChangedCommand(const AName: string);
    procedure SetSelectionChangedHandler(AHandler: TSelectionChangedHandler);
    procedure ChangeSelection(AItem: Variant; ASelected: boolean);
    procedure SelectFocused;
    procedure SelectAll;
    procedure ClearSelection;
    function Count: integer;
    function First: Variant;
    function List: Variant;
    function AsArray: variant;
    function AsString(ADelimiter: char = ';'): string;
    function GetItem(AIndex: integer): Variant;
    property Items[AIndex: integer]: Variant read GetItem; default;
    function GetCanMultiSelect: boolean;
    procedure SetCanMultiSelect(AValue: boolean);
  public
    constructor Create(AOwner: TComponent; AGridView: TcxGridTableView;
      AWorkItem: TWorkItem); reintroduce;


  end;

  TISelectionGridImplHelper = class(TViewHelper, IViewHelper)
  protected
    //IViewHelper
    procedure ViewInitialize;
    procedure ViewShow;
    procedure ViewClose;
  end;

implementation

{ TISelectionGridImpl }

function TISelectionGridImpl.AsArray: variant;
var
  I: integer;
begin
  if Count > 0 then
  begin
    Result := VarArrayCreate([0, Count - 1], varVariant);
    for I := 0 to Count - 1 do Result[I] := Items[I];
  end
  else
    Result := Unassigned;
end;

function TISelectionGridImpl.AsString(ADelimiter: Char): string;
var
  I: integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    if Result = '' then
      Result := VarToStr(GetItem(I))
    else
      Result := Result + ADelimiter + VarToStr(GetItem(I));
end;

procedure TISelectionGridImpl.ChangeSelection(AItem: Variant;
  ASelected: boolean);
begin
  
end;

procedure TISelectionGridImpl.ClearSelection;
begin
  FGridView.Controller.ClearSelection;
end;

function TISelectionGridImpl.Count: integer;
begin
  Result := FGridView.Controller.SelectedRowCount;
end;

constructor TISelectionGridImpl.Create(AOwner: TComponent; AGridView: TcxGridTableView;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);

  FWorkItem := AWorkItem;
  FGridView := AGridView;

  if not Assigned(FGridView.OnSelectionChanged) then
    FGridView.OnSelectionChanged := OnGridViewSelectionChanged;


  if not Assigned(FGridView.OnFocusedRecordChanged) then
    FGridView.OnFocusedRecordChanged := OnGridViewFocusedRecordChanged;

end;

function TISelectionGridImpl.First: Variant;
begin
  Result := Unassigned;
  if Count > 0  then
    Result := GetItem(0);
end;

function TISelectionGridImpl.GetCanMultiSelect: boolean;
begin
  Result := FGridView.OptionsSelection.MultiSelect;
end;

function TISelectionGridImpl.GetItem(AIndex: integer): Variant;
var
  KeyFields: TList;
  I: integer;
  valIndex: integer;
begin
  Result := Unassigned;

  if (FGridView is TcxGridDBTableView) or (FGridView is TcxGridDBBandedTableView) then
  begin
    KeyFields := TList.Create;
    try
      TcxGridDBDataController(FGridView.DataController).GetKeyDBFields(KeyFields);

      if KeyFields.Count > 0 then
      begin
        if KeyFields.Count > 1 then
        begin
          Result := VarArrayCreate([0, KeyFields.Count - 1], varVariant);
          for I := 0 to KeyFields.Count - 1 do
            Result[I] := FGridView.Controller.SelectedRecords[AIndex].
              Values[TcxGridDBDataController(FGridView.DataController).
                      GetItemByFieldName(TField(KeyFields[I]).FieldName).Index];
        end
        else
          Result := FGridView.Controller.SelectedRecords[AIndex].
              Values[TcxGridDBDataController(FGridView.DataController).
                      GetItemByFieldName(TField(KeyFields[0]).FieldName).Index];
      end
      else if FGridView.ColumnCount > 0 then
         Result := FGridView.Controller.SelectedRecords[AIndex].Values[0];
    finally
      KeyFields.Free;
    end;

  end
  else if FGridView.ColumnCount > 0 then
    Result := FGridView.Controller.SelectedRecords[AIndex].Values[0];

end;


function TISelectionGridImpl.List: Variant;
var
  I: integer;
begin
  if Count > 0 then
  begin
    Result := VarArrayCreate([0, Count - 1], varVariant);
    for I := 0 to Count - 1 do Result[I] := Items[I];
  end
  else
    Result := Unassigned;
end;

procedure TISelectionGridImpl.OnGridViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if (not FGridView.OptionsSelection.MultiSelect) then
  begin
    if FChangedCommand <> '' then
      FWorkItem.Commands[FChangedCommand].Execute;

    if Assigned(FSelectionChangedHandler) then
      FSelectionChangedHandler;
  end
end;

procedure TISelectionGridImpl.OnGridViewSelectionChanged(
  Sender: TcxCustomGridTableView);
begin
  if FChangedCommand <> '' then
    FWorkItem.Commands[FChangedCommand].Execute;

  if Assigned(FSelectionChangedHandler) then
    FSelectionChangedHandler;
end;

procedure TISelectionGridImpl.SelectAll;
begin
  FGridView.Controller.SelectAll;
end;

procedure TISelectionGridImpl.SelectFocused;
begin
  //FGridView.DataController.CheckFocusedSelected;
end;

procedure TISelectionGridImpl.SetCanMultiSelect(AValue: boolean);
begin
  FGridView.OptionsSelection.MultiSelect := AValue;
end;

procedure TISelectionGridImpl.SetChangedCommand(const AName: string);
begin
  FChangedCommand := AName;
end;

procedure TISelectionGridImpl.SetSelectionChangedHandler(
  AHandler: TSelectionChangedHandler);
begin
  FSelectionChangedHandler := AHandler;
end;

{ TISelectionGridImplHelper }

procedure TISelectionGridImplHelper.ViewClose;
begin

end;

procedure TISelectionGridImplHelper.ViewInitialize;
var
  I: integer;
  intfImpl: TISelectionGridImpl;
begin
  for I := 0 to GetForm.ComponentCount - 1 do
    if GetForm.Components[I] is TcxGridTableView then
    begin
      intfImpl := TISelectionGridImpl.Create(GetForm, TcxGridTableView(GetForm.Components[I]), GetForm.WorkItem);
      GetForm.RegisterChildInterface(GetForm.Components[I].Name, intfImpl as ISelection);
    end
end;

procedure TISelectionGridImplHelper.ViewShow;
begin

end;

initialization
  RegisterViewHelperClass(TISelectionGridImplHelper);


end.
