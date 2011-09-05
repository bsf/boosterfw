unit GridVCtrlUtils;

interface
uses cxVGrid, cxDBVGrid, Contnrs, controls, CustomView, classes, sysutils, db,
  EntityServiceIntf, cxButtonEdit, cxEdit, CoreClasses, StrUtils, Variants,
  cxInplaceContainer, cxDBLookupComboBox, cxDropDownEdit, menus, cxCheckBox, forms,
  CommonViewIntf, ViewServiceIntf, cxCalendar, typinfo;

const
  EDITOR_DATA_ENTITY = 'EntityName';
  EDITOR_DATA_EVIEW = 'EViewName';
  EDITOR_DATA_FIELD = 'FieldName';
  EDITOR_DATA_FILTER = 'Filter';
  EDITOR_DATA_POPUP = 'Popup';

type
  TcxVGridViewHelper = class(TViewHelper, IViewHelper,
                             IViewDataSetHelper, IViewValueEditorHelper)
  private
    FViewValueChangedHandler: TViewValueChangedHandler;

    FGridList: TComponentList;

    //PickListEditor
    procedure PickListEditorButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure PickListEditorValueChanged(Sender: TObject);
    procedure PickListEditorExecute(ADataSet: TDataSet;
      const AFieldName, APickNameFilter: string; AButtonClick: boolean);
    procedure PickListEditorCommandHandler(Sender: TObject);

    procedure InitRowEditor(AEditorRow: TcxDBEditorRow; AField: TField);
    procedure InitPickListEditor(ARow: TcxDBEditorRow; ADataSet: TDataSet);
    procedure InitLookupEditor(ARow: TcxDBEditorRow; ADataSet: TDataSet);
    procedure InitComboBoxEditor(ARow: TcxDBEditorRow; ADataSet: TDataSet);
    procedure InitCheckBoxEditor(ARow: TcxDBEditorRow);
    procedure InitImageEditor(ARow: TcxDBEditorRow);

    procedure TuneGridForDataSet(AGrid: TcxDBVerticalGrid;
      ADataSet: TDataSet);

    procedure CreateAllItems(AGrid: TcxDBVerticalGrid; ADataSet: TDataSet);
    function GetDBGridList: TComponentList;
    function GetGridList: TComponentList;

    function FindGridByDataSet(ADataSet: TDataSet): TcxDBVerticalGrid;

    function FindEditorRowByFieldName(AGrid: TcxDBVerticalGrid;
      const AFieldName: string): TcxDBEditorRow;
    function FindOrCreateCategoryRow(AGrid: TcxDBVerticalGrid;
      const ACaption: string): TcxCategoryRow;

    procedure DBGrid_OnEditedHandler(Sender: TObject;
      ARowProperties: TcxCustomEditorRowProperties);

    procedure Grid_OnEditValueChanged(Sender: TObject;
      ARowProperties: TcxCustomEditorRowProperties);

    procedure GridRow_OnEditValueChanged(Sender: TObject);

    function WorkItem: TWorkItem;
  protected
    //IViewHelper
    procedure ViewInitialize;
    procedure ViewShow;
    procedure ViewClose;
    //IViewDataSetHelper
    procedure LinkDataSet(ADataSource: TDataSource; ADataSet: TDataSet);
    procedure FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string; var Done: boolean);
    function GetFocusedField(ADataSet: TDataSet; var Done: boolean): string;
    procedure SetFocusedField(ADataSet: TDataSet; const AFieldName: string; var Done: boolean);
    procedure SetFocusedFieldChangedHandler(AHandler: TViewFocusedFieldChangedHandler; var Done: boolean);

    //IViewValueEditorHelper
    function CheckEditorClass(AControl: TComponent): boolean;
    function ReadValue(AControl: TComponent): Variant;
    procedure WriteValue(AControl: TComponent; AValue: Variant);
    procedure SetValueChangedHandler(AControl: TComponent;
      AHandler: TViewValueChangedHandler);
    function ReadValueStatus(AControl: TComponent): TValueStatus;
    procedure WriteValueStatus(AControl: TComponent; AStatus: TValueStatus);
  public
    constructor Create(AOwner: TfrCustomView); override;
    destructor Destroy; override;
  end;


implementation

procedure GridUtilsAddon(AForm: TfrCustomView);
begin
  AForm.RegisterHelper(TcxVGridViewHelper);

end;

{ TcxVGridViewHelper }

constructor TcxVGridViewHelper.Create(AOwner: TfrCustomView);
begin
  inherited;
  FGridList := TComponentList.Create(false);
end;

procedure TcxVGridViewHelper.CreateAllItems(AGrid: TcxDBVerticalGrid; ADataSet: TDataSet);
var
  I: Integer;
  AItem: TcxDBEditorRow;
begin
  if ADataSet = nil then Exit;

  AGrid.BeginUpdate;
  try
    for I := 0 to ADataSet.FieldCount - 1 do
    begin
      if AGrid.DataController.GetItemByFieldName(ADataSet.Fields[I].FieldName) = nil then
      begin
        AItem := TcxDBEditorRow(AGrid.Add(TcxDBEditorRow));
        AItem.Name := AGrid.Name + 'ColumnAutoCreate' + IntToStr(I);
             //CreateUniqueName(AGrid.Owner, AGrid, AItem, 'Tcx', Fields[I].FieldName);
        with AItem.Properties do
        begin
          DataBinding.FieldName := ADataSet.Fields[I].FieldName;
          Caption := DataBinding.DefaultCaption;
        end;
        AItem.Visible := ADataSet.Fields[I].Visible;
      end
    end;
  finally
    AGrid.EndUpdate;
  end;

end;

destructor TcxVGridViewHelper.Destroy;
begin
  FGridList.Free;
  inherited;
end;

function TcxVGridViewHelper.FindEditorRowByFieldName(AGrid: TcxDBVerticalGrid;
  const AFieldName: string): TcxDBEditorRow;
var
  I: integer;
begin
  Result := nil;
  for I := 0 to AGrid.Rows.Count - 1 do
    if (AGrid.Rows[I] is TcxDBEditorRow) and
       (TcxDBEditorRow(AGrid.Rows[I]).
         Properties.DataBinding.FieldName = AFieldName) then
     begin
       Result := TcxDBEditorRow(AGrid.Rows[I]);
       Exit;
     end;
end;

function TcxVGridViewHelper.FindOrCreateCategoryRow(AGrid: TcxDBVerticalGrid;
  const ACaption: string): TcxCategoryRow;
var
  I: integer;
begin
  for I := 0 to AGrid.Rows.Count - 1 do
    if (AGrid.Rows[I] is TcxCategoryRow) and
       SameText(TcxCategoryRow(AGrid.Rows[I]).
          Properties.Caption, ACaption) then
     begin
       Result := TcxCategoryRow(AGrid.Rows[I]);
       Exit;
     end;

  Result := TcxCategoryRow(AGrid.Add(TcxCategoryRow));
  Result.Expanded := true;
  Result.Options.ShowExpandButton := false;
  Result.Options.TabStop := false;
  Result.Properties.Caption := ACaption;    
end;

procedure TcxVGridViewHelper.FocusDataSetControl(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
var
  grid: TcxDBVerticalGrid;
  row: TcxDBEditorRow;
  I: integer;
begin
  grid := FindGridByDataSet(ADataSet);
  if Assigned(grid) then
  begin
    row := nil;
    for I := 0 to grid.Rows.Count - 1 do
    begin
      row := grid.Rows[I] as TcxDBEditorRow;
      if AFieldName <> '' then
      begin
        if SameText(row.Properties.DataBinding.FieldName, AFieldName) then
          Break
        else
          row := nil;
      end
      else
      begin
        if row.Visible and row.Properties.Options.Editing then
          Break
        else
          row := nil;
      end;
    end;

    if Assigned(Row) then
    begin
      GetParentForm(grid).ActiveControl := grid;
     // if grid.CanFocus then grid.SetFocus;
      row.MakeVisible;
      grid.FocusedRow := row;

    end;
    Done := true;
  end;
end;

function TcxVGridViewHelper.GetDBGridList: TComponentList;
var
  I: integer;
begin
  FGridList.Clear;
  for I := 0 to GetForm.ComponentCount - 1 do
    if GetForm.Components[I] is TcxDBVerticalGrid then
      FGridList.Add(GetForm.Components[I]);

  Result := FGridList;
end;

procedure TcxVGridViewHelper.LinkDataSet(ADataSource: TDataSource; ADataSet: TDataSet);
var
  I: integer;
  _gridList: TComponentList;
begin
  _gridList := GetDBGridList;
  for I := 0 to _gridList.Count - 1 do
    if (TcxDBVerticalGrid(_gridList[I]).DataController.DataSource <> nil)
       and
      (ADataSet =
       TcxDBVerticalGrid(_gridList[I]).DataController.DataSource.DataSet) then

     TuneGridForDataSet(TcxDBVerticalGrid(_gridList[I]), ADataSet);

end;

procedure TcxVGridViewHelper.PickListEditorButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if TcxCustomEdit(Sender).EditModified then
    TcxCustomEdit(Sender).PostEditValue
  else
    PickListEditorExecute(
      TcxDBVerticalGrid(TcxButtonEdit(Sender).Owner).DataController.DataSource.DataSet,
      TcxButtonEdit(Sender).Properties.LookupItems[0],
      VarToStr(TcxCustomEdit(Sender).EditValue), true);
end;

procedure TcxVGridViewHelper.PickListEditorValueChanged(
  Sender: TObject);
begin
  PickListEditorExecute(
    TcxDBVerticalGrid(TcxButtonEdit(Sender).Owner).DataController.DataSource.DataSet,
    TcxButtonEdit(Sender).Properties.LookupItems[0],
    VarToStr(TcxCustomEdit(Sender).EditValue), false);
end;

procedure TcxVGridViewHelper.PickListEditorExecute(ADataSet: TDataSet;
  const AFieldName, APickNameFilter: string; AButtonClick: boolean);
var
  field: TField;
  commandName: string;
  command: ICommand;
begin
  field := ADataSet.FieldByName(AFieldName);
  commandName := GetFieldAttribute(field, FIELD_ATTR_EDITOR_COMMAND);
  command := WorkItem.Commands[commandName];

  command.Data[EDITOR_DATA_FILTER] := APickNameFilter;
  command.Data[EDITOR_DATA_POPUP] := AButtonClick;

  command.Execute;

end;

procedure TcxVGridViewHelper.TuneGridForDataSet(AGrid: TcxDBVerticalGrid;
  ADataSet: TDataSet);


var
  grController: TcxDBVerticalGridDataController;
  CategoryCaption: string;
  grCategoryRow: TcxCategoryRow;
  grEditorRow: TcxDBEditorRow;
  I: integer;
  primaryKey: string;
begin
  if not Assigned(ADataSet) then Exit;

  grController := AGrid.DataController;
  if grController.KeyFieldNames = '' then
  begin
    primaryKey := GetDataSetAttribute(ADataSet, DATASET_ATTR_PRIMARYKEY);
    if primaryKey <> '' then
      grController.KeyFieldNames := primaryKey
    else if ADataSet.FieldCount > 0 then
      grController.KeyFieldNames := ADataSet.Fields[0].FieldName;
  end;

//  AGrid.OnEdited := GridOnEdited;

  for I := 0 to ADataSet.FieldCount - 1 do
    ADataSet.Fields[I].Alignment := taLeftJustify;

  CreateAllItems(AGrid, ADataSet);

  for I := 0 to ADataSet.FieldCount - 1 do
  begin
    grEditorRow := FindEditorRowByFieldName(AGrid, ADataSet.Fields[I].FieldName);

    //Category
    CategoryCaption := GetFieldAttribute(ADataSet.Fields[I], 'band');
    if  CategoryCaption <> '' then
    begin
      grCategoryRow := FindOrCreateCategoryRow(AGrid, CategoryCaption);
      grEditorRow.Parent := grCategoryRow;
    end;

    //Editor
{    if ADataSet.Fields[I].ReadOnly then
    begin
    //  grEditorRow.Options.TabStop := false;
      grEditorRow.Properties.Options.Editing := false;
      grEditorRow.Properties.Options.ShowEditButtons := eisbNever;
    end
    else
   }
    InitRowEditor(grEditorRow, ADataSet.Fields[I]);

  end

end;

procedure TcxVGridViewHelper.ViewClose;
begin

end;

procedure TcxVGridViewHelper.ViewInitialize;
var
  I, Y: integer;
  _gridList: TComponentList;
  row: TcxCustomRow;
begin
  _gridList := GetDBGridList;
  for I := 0 to _gridList.Count - 1 do
   (_gridList[I] as TcxDBVerticalGrid).OnEdited := DBGrid_OnEditedHandler; //!! �������� ImmediatePost (�� ������ �������� ������ AV)

  _gridList := GetGridList;
  for I := 0 to _gridList.Count - 1 do
  begin
    (_gridList[I] as TcxVerticalGrid).OnEditValueChanged := Grid_OnEditValueChanged;
    for Y := 0 to (_gridList[I] as TcxVerticalGrid).Rows.Count - 1 do
    begin
      row := (_gridList[I] as TcxVerticalGrid).Rows[Y];
      if (row is TcxEditorRow) and assigned((row as TcxEditorRow).Properties.EditProperties) then
        (row as TcxEditorRow).Properties.EditProperties.OnEditValueChanged :=
          GridRow_OnEditValueChanged;
    end;
  end;
end;

procedure TcxVGridViewHelper.ViewShow;
begin

end;


procedure TcxVGridViewHelper.InitRowEditor(AEditorRow: TcxDBEditorRow; AField: TField);
var
  editorTyp: string;
begin
  editorTyp := GetFieldAttribute(AField, FIELD_ATTR_EDITOR);

  if not AField.ReadOnly then
  begin

    if AField is TFloatField then
      TFloatField(AField).DisplayFormat := '';


    if SameText(editorTyp, FIELD_ATTR_EDITOR_PICKLIST) then
       InitPickListEditor(AEditorRow, AField.DataSet)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_LOOKUP) then
       InitLookupEditor(AEditorRow, AField.DataSet)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_COMBOBOX) then
       InitComboBoxEditor(AEditorRow, AField.DataSet)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_CHECKBOX) then
       InitCheckBoxEditor(AEditorRow)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_IMAGE) then
       InitImageEditor(AEditorRow)

    else if AField is TDateTimeField then
    begin
      AEditorRow.Properties.EditPropertiesClass := TcxDateEditProperties;
      with AEditorRow.Properties.EditProperties as TcxDateEditProperties do
      begin
        ImmediatePost := true;
      end;
    end;
  end
  else
  begin
  
    if SameText(editorTyp, FIELD_ATTR_EDITOR_LOOKUP) then
       InitLookupEditor(AEditorRow, AField.DataSet)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_CHECKBOX) then
       InitCheckBoxEditor(AEditorRow);

    AEditorRow.Properties.Options.Editing := false;
    AEditorRow.Properties.Options.ShowEditButtons := eisbNever;
  end;

end;

procedure TcxVGridViewHelper.InitPickListEditor(ARow: TcxDBEditorRow; ADataSet: TDataSet);
const
  COMMAND_FIELD_EDITED_PICKLIST = 'commands.picklisteditor.';

var
  commandName: string;
  command: ICommand;
  entityName: string;
  eviewName: string;
  fieldName: string;
  field: TField;
begin
  entityName := GetDataSetAttribute(ADataSet, DATASET_ATTR_ENTITY);
  eviewName := GetDataSetAttribute(ADataSet, DATASET_ATTR_ENTITY_VIEW);
  fieldName :=  ARow.Properties.DataBinding.FieldName;

  field := ADataSet.FieldByName(fieldName);
  if not Assigned(field) then Exit;

  commandName := COMMAND_FIELD_EDITED_PICKLIST + entityName + eviewName + fieldName;
  command := WorkItem.Commands[commandName];
  command.Data[EDITOR_DATA_ENTITY] := entityName;
  command.Data[EDITOR_DATA_EVIEW] := eviewName;
  command.Data[EDITOR_DATA_FIELD] := fieldName;
  command.Data[EDITOR_DATA_FILTER] := '';
  command.Data[EDITOR_DATA_POPUP] := false;
  command.SetHandler(PickListEditorCommandHandler);


  SetFieldAttribute(field, FIELD_ATTR_EDITOR_COMMAND, commandName);



//-------------------------
  ARow.Properties.EditPropertiesClass := TcxButtonEditProperties;
  with TcxButtonEditProperties(ARow.Properties.EditProperties) do
  begin
    LookupItems.Text := ARow.Properties.DataBinding.FieldName;
    OnButtonClick := PickListEditorButtonClick;
    OnEditValueChanged := PickListEditorValueChanged;
  end;
end;

procedure TcxVGridViewHelper.InitLookupEditor(ARow: TcxDBEditorRow;
  ADataSet: TDataSet);
var
  lookupDS: TDataSource;
  svc: IEntityManagerService;
  entityName: string;
  eviewName: string;
  eviewID: string;
  field: TField;
  I: integer;
begin
  svc := WorkItem.Services[IEntityManagerService] as IEntityManagerService;
  field := ADataSet.FindField(ARow.Properties.DataBinding.FieldName);
  if field = nil then Exit;

  entityName := GetFieldAttribute(field, FIELD_ATTR_EDITOR_ENTITY);
  eviewName := GetFieldAttribute(field, FIELD_ATTR_EDITOR_EVIEW);
  eviewID := ADataSet.Name + '_lookupData_' + field.FieldName;

  lookupDS := TDataSource.Create(ARow);
  lookupDS.DataSet := svc.Entity[entityName].GetView(eviewName, WorkItem, eviewID).Load;


  ARow.Properties.EditPropertiesClass := TcxLookupComboBoxProperties;


  with TcxLookupComboBoxProperties(ARow.Properties.EditProperties) do
  begin
   // DropDownListStyle := lsEditList;// lsEditFixedList;
  //  OnInitPopup := LookupEditorInitPopup;
    ImmediatePost := true;
    ClearKey := TextToShortCut('Del');
    ListOptions.ShowHeader := false;
   // ListOptions.GridLines := glNone;
    if lookupDS.DataSet.RecordCount < 25 then
      DropDownRows := lookupDS.DataSet.RecordCount
    else
      DropDownRows := 25;
    ListSource := lookupDS;
    KeyFieldNames := GetFieldAttribute(field, FIELD_ATTR_EDITOR_KEYFIELD);
    if KeyFieldNames = '' then
      KeyFieldNames := 'ID';

    ListFieldNames := GetFieldAttribute(field, FIELD_ATTR_EDITOR_NAMEFIELD);
    if ListFieldNames = '' then
    begin
      ListFieldNames := 'NAME';
      for I := 0 to lookupDS.DataSet.FieldCount - 1 do
      begin
        if (not SameText(lookupDS.DataSet.Fields[I].FieldName, 'ID'))
            and
           (not SameText(lookupDS.DataSet.Fields[I].FieldName, 'NAME'))
            and
           (lookupDS.DataSet.Fields[I].Visible)
            then
          ListFieldNames := ListFieldNames + ';' + lookupDS.DataSet.Fields[I].FieldName;
      end;
    end;
  end;
end;

procedure TcxVGridViewHelper.InitCheckBoxEditor(ARow: TcxDBEditorRow);
begin
  ARow.Properties.EditPropertiesClass := TcxCheckBoxProperties;
  with TcxCheckBoxProperties(ARow.Properties.EditProperties) do
  begin
    DisplayChecked := '��';
    DisplayUnchecked := '���';
    AllowGrayed := false;
    ValueChecked := 1;
    ValueUnchecked := 0;
    ValueGrayed := 0;
    ImmediatePost := true;
    Alignment := taLeftJustify;
    UseAlignmentWhenInplace := true;
  end;

end;

procedure TcxVGridViewHelper.InitComboBoxEditor(ARow: TcxDBEditorRow;
  ADataSet: TDataSet);

var
  lookupDS: TDataSet;
  svc: IEntityManagerService;
  entityName: string;
  eviewName: string;
  eviewID: string;
  field: TField;
begin
  svc := WorkItem.Services[IEntityManagerService] as IEntityManagerService;
  field := ADataSet.FindField(ARow.Properties.DataBinding.FieldName);
  if field = nil then Exit;

  entityName := GetFieldAttribute(field, FIELD_ATTR_EDITOR_ENTITY);
  eviewName := GetFieldAttribute(field, FIELD_ATTR_EDITOR_EVIEW);
  eviewID := ADataSet.Name + '_lookupData_' + field.FieldName;

  ARow.Properties.EditPropertiesClass := TcxComboBoxProperties;
  with TcxComboBoxProperties(ARow.Properties.EditProperties) do
  begin
    ClearKey := TextToShortCut('Del');
    DropDownListStyle := lsEditList;
    ImmediatePost := true;

   { if lookupDS.DataSet.RecordCount < 25 then
      DropDownRows := lookupDS.DataSet.RecordCount
    else
      DropDownRows := 25;}
  end;

  lookupDS := svc.Entity[entityName].GetView(eviewName, WorkItem, eviewID).Load;

  while not lookupDS.Eof do
  begin
    TcxComboBoxProperties(ARow.Properties.EditProperties).Items.Append(VarToStr(lookupDS.Fields[0].Value));
    lookupDS.Next;
  end;

end;

procedure TcxVGridViewHelper.InitImageEditor(ARow: TcxDBEditorRow);
begin

end;

function TcxVGridViewHelper.CheckEditorClass(
  AControl: TComponent): boolean;
begin
  Result := AControl is TcxEditorRow;
end;

function TcxVGridViewHelper.ReadValue(AControl: TComponent): Variant;
begin
  Result := (AControl as TcxEditorRow).Properties.Value;
end;

function TcxVGridViewHelper.ReadValueStatus(
  AControl: TComponent): TValueStatus;
begin
  if not (AControl as TcxEditorRow).Visible then
    Result := vsUnavailable
  else if not (AControl as TcxEditorRow).Properties.Options.Editing then
    Result := vsDisabled
  else
    Result := vsEnabled;

end;

procedure TcxVGridViewHelper.SetValueChangedHandler(AControl: TComponent;
  AHandler: TViewValueChangedHandler);
begin
  FViewValueChangedHandler := AHandler; 
end;

procedure TcxVGridViewHelper.WriteValue(AControl: TComponent;
  AValue: Variant);
begin
  (AControl as TcxEditorRow).Properties.Value := AValue;
  (AControl as TcxEditorRow).VerticalGrid.HideEdit; //!!! ���� ��� ������������ ����������� � ������
end;

procedure TcxVGridViewHelper.WriteValueStatus(AControl: TComponent;
  AStatus: TValueStatus);
begin
  case AStatus of

    vsEnabled: begin
      (AControl as TcxEditorRow).Visible := true;
      (AControl as TcxEditorRow).Properties.Options.Editing := true;
    end;

    vsDisabled: begin
      (AControl as TcxEditorRow).Visible := true;
      (AControl as TcxEditorRow).Properties.Options.Editing := false;
    end;

    vsUnavailable: begin
      (AControl as TcxEditorRow).Visible := false;
      (AControl as TcxEditorRow).Properties.Options.Editing := false;
    end;

  end;


end;

function TcxVGridViewHelper.FindGridByDataSet(
  ADataSet: TDataSet): TcxDBVerticalGrid;
var
  I: integer;
  _gridList: TComponentList;
begin

  _gridList := GetDBGridList;
  for I := 0 to _gridList.Count - 1 do
    if ((_gridList[I] as TcxDBVerticalGrid).DataController.DataSource <> nil)
       and
      (ADataSet =
       (_gridList[I] as TcxDBVerticalGrid).DataController.DataSource.DataSet) then
    begin
      Result := (_gridList[I] as TcxDBVerticalGrid);
      Exit;
    end;

  Result := nil;
end;

function TcxVGridViewHelper.GetGridList: TComponentList;
var
  I: integer;
begin
  FGridList.Clear;
  for I := 0 to GetForm.ComponentCount - 1 do
    if GetForm.Components[I] is TcxVerticalGrid then
      FGridList.Add(GetForm.Components[I]);

  Result := FGridList;
end;

procedure TcxVGridViewHelper.DBGrid_OnEditedHandler(Sender: TObject;
  ARowProperties: TcxCustomEditorRowProperties);
var
  dataController: TcxDBVerticalGridDataController;
begin
  dataController := TcxDBVerticalGrid(Sender).DataController;
  if Assigned(dataController.DataSource.DataSet) and
     (dataController.DataSource.DataSet.State in [dsEdit]) then
     dataController.DataSource.DataSet.Post;
end;

procedure TcxVGridViewHelper.GridRow_OnEditValueChanged(Sender: TObject);
begin
  TcxCustomEdit(Sender).PostEditValue;
end;

procedure TcxVGridViewHelper.Grid_OnEditValueChanged(Sender: TObject;
  ARowProperties: TcxCustomEditorRowProperties);
begin
  if Assigned(FViewValueChangedHandler) then
    FViewValueChangedHandler(ARowProperties.Row.Name);
end;


function TcxVGridViewHelper.GetFocusedField(ADataSet: TDataSet;
  var Done: boolean): string;
var
  grid: TcxDBVerticalGrid;
  row: TcxCustomRow;//TcxDBEditorRow;
begin
  grid := FindGridByDataSet(ADataSet);
  if Assigned(grid) then
  begin
    row := grid.FocusedRow;
    if (row <> nil) and (row is TcxDBEditorRow) then
      Result := (row as TcxDBEditorRow).Properties.DataBinding.FieldName
    else
      Result := '';
    Done := true;
  end;
end;

procedure TcxVGridViewHelper.SetFocusedField(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
begin

end;

procedure TcxVGridViewHelper.SetFocusedFieldChangedHandler(
  AHandler: TViewFocusedFieldChangedHandler; var Done: boolean);
begin

end;

procedure TcxVGridViewHelper.PickListEditorCommandHandler(Sender: TObject);
  procedure InitPickListData(AData: TActionData; ADataSet: TDataSet);
  var
    I: integer;
    val: Variant;
    valName: string;
  begin
    for I := 0 to AData.Count - 1 do
    begin
      valName := AData.ValueName(I);
      val := WorkItem.State[valName];
      if VarIsEmpty(val) and (ADataSet.FindField(valName) <> nil) then
        val := ADataSet.FieldValues[valName];
      if not VarIsEmpty(val) then
        AData.SetValue(valName, val);
    end;

  end;

const
  DataInPrefix = FIELD_ATTR_EDITOR_DATAIN;
  DataInPrefixLength = length(DataInPrefix);

  DataOutPrefix = FIELD_ATTR_EDITOR_DATAOUT;
  DataOutPrefixLength = length(DataOutPrefix);

var
  command: ICommand;
  entityName: string;
  eviewName: string;
  fieldName: string;
  field: TField;
  fieldID: TField;
  fieldIDName: string;
  pickFilter: string;
  fPopup: boolean;
  dataSet: TDataSet;
  OldValue: Variant;
  OldIDValue: Variant;

  fClear: boolean;
  I: integer;

  actionName: string;
  action: IAction;

  optionName: string;
  dataName: string;
  dataValueName: string;
  dataValueField: TField;

  editorOptions: TStringList;
begin
  Sender.GetInterface(ICommand, command);
  entityName := command.Data[EDITOR_DATA_ENTITY];
  eviewName := command.Data[EDITOR_DATA_EVIEW];
  fieldName := command.Data[EDITOR_DATA_FIELD];
  pickFilter := command.Data[EDITOR_DATA_FILTER];
  fPopup := command.Data[EDITOR_DATA_POPUP];
  command := nil;

  dataSet := (WorkItem.Services[IEntityManagerService] as IEntityManagerService).
    Entity[entityName].GetView(eviewName, WorkItem).DataSet;

  field := dataSet.FieldByName(fieldName);

  editorOptions := TStringList.Create;
  try
    GetFieldAttributeList(field, editorOptions);

    fieldIDName := editorOptions.Values[FIELD_ATTR_FIELDID];
    if fieldIDName = '' then
    begin
      if AnsiEndsText('_NAME', fieldName) then
      begin
        fieldIDName := LeftStr(fieldName, length(fieldName) - length('_NAME'));
        fieldIDName := fieldIDName + '_ID';
      end
      else
        fieldIDName := fieldName + '_ID';
    end;

    fieldID := dataSet.FindField(fieldIDName);

    OldValue := field.Value;
    if Assigned(fieldID) then
      OldIDValue := fieldID.Value;

    fClear := (not fPopup) and (VarToStr(OldValue) <> '') and (pickFilter = '');
    if not fClear then
    begin
      actionName := editorOptions.Values[FIELD_ATTR_EDITOR_ACTION];

      action := WorkItem.Actions[actionName];

      (action.Data as IPickListPresenterData).Filter := pickFilter;
      InitPickListData(action.Data, dataSet);

      WorkItem.Actions[actionName].Execute(WorkItem);

      dataSet.Edit;

      if (Action.Data as TPresenterData).ModalResult <> mrOK then
      begin
        field.Value := OldValue;
        if Assigned(fieldID) then
          fieldID.Value := OldIDValue;
      end
      else
      begin


        field.Value := (action.Data as IPickListPresenterData).Name;
        if Assigned(fieldID) then
          fieldID.Value := (action.Data as IPickListPresenterData).ID;

        //DataOutExt
        for I := 0 to editorOptions.Count - 1 do
        begin
          optionName := editorOptions.Names[I];
          if AnsiStartsText(DataOutPrefix, optionName) then
          begin
            dataName := RightStr(optionName, length(optionName) - DataOutPrefixLength);
            dataValueName := editorOptions.Values[optionName];
            dataValueField := dataSet.FindField(dataValueName);
            if dataValueField <> nil then
              dataValueField.Value := action.Data.GetValue(dataName)
            else
              WorkItem.State[dataValueName] := action.Data.GetValue(dataName);
          end;
        end;
      end;
    end
    // Clear
    else
    begin
      field.Value := Unassigned;
        if Assigned(fieldID) then
          fieldID.Value := null;
    end

  finally
    editorOptions.Free;
  end;

end;

function TcxVGridViewHelper.WorkItem: TWorkItem;
begin
  Result := (GetForm as IView).WorkItem;
end;

initialization
  RegisterViewHelperClass(TcxVGridViewHelper);
  
end.
