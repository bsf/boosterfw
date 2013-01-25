unit ISelectionTreeImpl;

interface
uses classes, UIClasses, CustomView, Variants, sysutils, contnrs, cxTL, cxDBTL,
  CoreClasses;

type

  TISelectionTreeImpl = class(TComponent, ISelection)
  private
    FWorkItem: TWorkItem;
    FTree: TcxDBTreeList;
    FSelectionChangedHandler: TSelectionChangedHandler;
    FChangedCommand: string;
    procedure OnTreeSelectionChanged(Sender: TObject);
    procedure OnTreeFocusedNodeChanged(Sender: TcxCustomTreeList;
     APrevFocusedNode, AFocusedNode: TcxTreeListNode);
    function GetKeyColumnIndex: integer;
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
    constructor Create(AOwner: TComponent; ATree: TcxDBTreeList;
      AWorkItem: TWorkItem); reintroduce;


  end;

  TISelectionTreeHelper = class(TViewHelper, IViewHelper)
  protected
    //IViewHelper
    procedure ViewInitialize;
    procedure ViewShow;
    procedure ViewClose;
  end;

implementation

{ THelperTreeISelection }

function TISelectionTreeImpl.AsArray: variant;
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

function TISelectionTreeImpl.AsString(ADelimiter: Char): string;
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

procedure TISelectionTreeImpl.ChangeSelection(AItem: Variant;
  ASelected: boolean);
begin

end;

procedure TISelectionTreeImpl.ClearSelection;
begin
  FTree.ClearSelection();
end;

function TISelectionTreeImpl.Count: integer;
begin
  Result := FTree.SelectionCount;
end;

constructor TISelectionTreeImpl.Create(AOwner: TComponent; ATree: TcxDBTreeList;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);

  FWorkItem := AWorkItem;
  FTree := ATree;

  if not Assigned(FTree.OnSelectionChanged) then
    FTree.OnSelectionChanged := OnTreeSelectionChanged;

  if not Assigned(FTree.OnFocusedNodeChanged) then
    FTree.OnFocusedNodeChanged:= OnTreeFocusedNodeChanged;

end;

function TISelectionTreeImpl.First: Variant;
var
  KeyColumnIndex: integer;
begin
  Result := Unassigned;
  if Count > 0 then
  begin
    KeyColumnIndex := GetKeyColumnIndex;
    if KeyColumnIndex <> -1 then
      Result := FTree.Selections[0].Values[KeyColumnIndex];
  end;

end;

function TISelectionTreeImpl.GetCanMultiSelect: boolean;
begin
  Result := FTree.OptionsSelection.MultiSelect;
end;

function TISelectionTreeImpl.GetItem(AIndex: integer): Variant;
var
  KeyColumnIndex: integer;
begin
  KeyColumnIndex := GetKeyColumnIndex;
  if KeyColumnIndex <> -1 then
    Result := FTree.Selections[AIndex].Values[KeyColumnIndex];
end;


function TISelectionTreeImpl.GetKeyColumnIndex: integer;
begin
  Result := FTree.GetColumnByFieldName(FTree.DataController.KeyField).ItemIndex;
end;

function TISelectionTreeImpl.List: Variant;
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

procedure TISelectionTreeImpl.OnTreeFocusedNodeChanged(
  Sender: TcxCustomTreeList; APrevFocusedNode, AFocusedNode: TcxTreeListNode);
begin
  if (not FTree.OptionsSelection.MultiSelect) then
  begin
    if FChangedCommand <> '' then
      FWorkItem.Commands[FChangedCommand].Execute;

    if Assigned(FSelectionChangedHandler) then
      FSelectionChangedHandler;
  end
end;

procedure TISelectionTreeImpl.OnTreeSelectionChanged(Sender: TObject);
begin
  if FChangedCommand <> '' then
    FWorkItem.Commands[FChangedCommand].Execute;

  if Assigned(FSelectionChangedHandler) then
    FSelectionChangedHandler;
end;

procedure TISelectionTreeImpl.SelectAll;
begin
  FTree.SelectAll;
end;

procedure TISelectionTreeImpl.SelectFocused;
begin
  //FGridView.DataController.CheckFocusedSelected;
end;

procedure TISelectionTreeImpl.SetCanMultiSelect(AValue: boolean);
begin
  FTree.OptionsSelection.MultiSelect := AValue;
end;

procedure TISelectionTreeImpl.SetChangedCommand(const AName: string);
begin
  FChangedCommand := AName;
end;

procedure TISelectionTreeImpl.SetSelectionChangedHandler(
  AHandler: TSelectionChangedHandler);
begin
  FSelectionChangedHandler := AHandler;
end;

{ THelperTreeISelectionHelper }

procedure TISelectionTreeHelper.ViewClose;
begin

end;

procedure TISelectionTreeHelper.ViewInitialize;
var
  I: integer;
  intfImpl: TISelectionTreeImpl;
begin
  for I := 0 to GetForm.ComponentCount - 1 do
    if GetForm.Components[I] is TcxDBTreeList then
    begin
      intfImpl := TISelectionTreeImpl.Create(GetForm, TcxDBTreeList(GetForm.Components[I]), GetForm.WorkItem);
      GetForm.RegisterChildInterface(GetForm.Components[I].Name, intfImpl as ISelection);
    end
end;

procedure TISelectionTreeHelper.ViewShow;
begin

end;

initialization
  RegisterViewHelperClass(TISelectionTreeHelper);

end.
