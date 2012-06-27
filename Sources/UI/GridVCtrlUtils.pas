unit GridVCtrlUtils;

interface
uses cxVGrid, cxDBVGrid, Contnrs, controls, CustomView, classes, sysutils, db,
  EntityServiceIntf, cxButtonEdit, cxEdit, CoreClasses, StrUtils, Variants,
  cxInplaceContainer, cxDBLookupComboBox, cxDropDownEdit, menus, cxCheckBox, forms,
  UIClasses, cxCalendar, typinfo, cxImage, graphics, inifiles, ShellIntf,
  cxColorComboBox, cxMemo, stdctrls, cxStyles, cxCalc;

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
    procedure InitCheckBoxEditor(ARow: TcxDBEditorRow; AField: TField);
    procedure InitImageEditor(ARow: TcxDBEditorRow);
    procedure InitColorEditor(ARow: TcxDBEditorRow);
    procedure InitMemoEditor(ARow: TcxDBEditorRow);
    procedure InitCalcEditor(ARow: TcxDBEditorRow; AField: TField);

    procedure ImageRow_OnAssignPicture(Sender: TObject; const Picture: TPicture);

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

    procedure GridRow_OnPropertiesGetEditProperties(
      Sender: TcxCustomEditorRowProperties; ARecordIndex: Integer;
      var AProperties: TcxCustomEditProperties);

    function WorkItem: TWorkItem;

    //Preferences
    function GetPreferenceFileName(AGrid: TcxDBVerticalGrid): string;
    procedure LoadPreference(AGrid: TcxDBVerticalGrid);
    procedure SavePreference(AGrid: TcxDBVerticalGrid);
    procedure SaveAllPreference;

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
  Result.Options.ShowExpandButton := true;
  Result.Options.TabStop := false;
  Result.Properties.Caption := ACaption;
  Result.Visible := false;
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
      if not (grid.Rows[I] is TcxDBEditorRow) then Continue;

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
  begin
     TuneGridForDataSet(TcxDBVerticalGrid(_gridList[I]), ADataSet);
     LoadPreference(TcxDBVerticalGrid(_gridList[I]));
  end;
end;

procedure TcxVGridViewHelper.LoadPreference(AGrid: TcxDBVerticalGrid);

  procedure LoadFromStorage(AGrid: TcxDBVerticalGrid; AStorage: TMemInifile);
  var
    _section: string;
    I: integer;
  begin
    _section := 'COMMON';
    AGrid.OptionsView.ValueWidth :=
      AStorage.ReadInteger(_section, 'ValueWidth', AGrid.OptionsView.ValueWidth);
    AGrid.OptionsView.RowHeaderWidth :=
      AStorage.ReadInteger(_section, 'RowHeaderWidth', AGrid.OptionsView.RowHeaderWidth);

    for I := 0 to AGrid.Rows.Count - 1 do
    begin

      if AGrid.Rows[I] is TcxCategoryRow then
      begin
        _section := 'BAND_' + IntToStr(I);
        if AStorage.SectionExists(_section) then
        begin
          AGrid.Rows[I].Expanded :=
            AStorage.ReadBool(_section, 'Expanded', AGrid.Rows[I].Expanded);
        end;
      end;

    end;

  end;

var
  _storage: TMemInifile;
  _strings: TStringList;
  data: TMemoryStream;
begin
  data := TMemoryStream.Create;
  try
    App.UserProfile.LoadData((Owner as ICustomView).GetPreferencePath,
      GetPreferenceFileName(AGrid), data);
    data.Position := 0;

    if (data.Size = 0) then
    begin
      //Default settings
    end
    else
    begin
      _storage := TMemInifile.Create('');
      try
        _strings := TStringList.Create;
        try
          _strings.LoadFromStream(data);
          _storage.SetStrings(_strings);
        finally
          _strings.Free;
        end;

        LoadFromStorage(AGrid, _storage);

      finally
        _storage.Free
      end;
    end;
  finally
    data.free;
  end;
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

  procedure SetUIAttrField(AField: TField);
  begin

  end;

var
  grController: TcxDBVerticalGridDataController;
  CategoryCaption: string;
  grCategoryRow: TcxCategoryRow;
  grEditorRow: TcxDBEditorRow;
  I: integer;
  field: TField;
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
    field := ADataSet.Fields[I];
    grEditorRow := FindEditorRowByFieldName(AGrid, field.FieldName);

    //Category
    CategoryCaption := GetFieldAttribute(field, 'band');
    if  (CategoryCaption <> '') then
    begin
      grCategoryRow := FindOrCreateCategoryRow(AGrid, CategoryCaption);
      grEditorRow.Parent := grCategoryRow;
      if grCategoryRow.Expanded then
        grCategoryRow.Expanded := not CheckFieldAttribute(field, FIELD_ATTR_BANDCOLLAPSED);

      if not grCategoryRow.Visible then
        grCategoryRow.Visible := field.Visible;
    end;

    //Style
    grEditorRow.Styles.Header :=
      TcxStyle(App.UI.Styles[GetFieldAttribute(field, FIELD_ATTR_STYLE_HEADER)]);
    grEditorRow.Styles.Content :=
      TcxStyle(App.UI.Styles[GetFieldAttribute(field, FIELD_ATTR_STYLE_CONTENT)]);

    //Editor
    InitRowEditor(grEditorRow, field);



  end

end;

procedure TcxVGridViewHelper.ViewClose;
begin
  SaveAllPreference;
end;

procedure TcxVGridViewHelper.ViewInitialize;
var
  I, Y: integer;
  _gridList: TComponentList;
  row: TcxCustomRow;
begin
  _gridList := GetDBGridList;
  for I := 0 to _gridList.Count - 1 do
   (_gridList[I] as TcxDBVerticalGrid).OnEdited := DBGrid_OnEditedHandler; //!! имитация ImmediatePost (на других событиях глючит AV)

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
       InitCheckBoxEditor(AEditorRow, AField)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_IMAGE) then
       InitImageEditor(AEditorRow)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_COLOR) then
       InitColorEditor(AEditorRow)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_MEMO) then
       InitMemoEditor(AEditorRow)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_CALC) then
       InitCalcEditor(AEditorRow, AField)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_DATETIME) then
    begin
      AEditorRow.Properties.EditPropertiesClass := TcxDateEditProperties;
      with AEditorRow.Properties.EditProperties as TcxDateEditProperties do
      begin
        Kind := ckDateTime;
        ImmediatePost := true;
      end;

    end
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
       InitCheckBoxEditor(AEditorRow, AField)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_MEMO) then
        InitMemoEditor(AEditorRow);

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
  fieldIDName: string;
  fieldID: TField;
//
  rowID: TcxDBEditorRow;
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

//Hide ID Field
  fieldIDName := GetFieldAttribute(field, FIELD_ATTR_FIELDID);
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

  fieldID := ADataSet.FindField(fieldIDName);
  if Assigned(fieldID) then
  begin
    fieldID.Visible := false;
    rowID := FindEditorRowByFieldName(ARow.VerticalGrid as TcxDBVerticalGrid, fieldIDName);
    if Assigned(rowID) then
      rowID.Visible := false;
  end;
end;

procedure TcxVGridViewHelper.InitLookupEditor(ARow: TcxDBEditorRow;
  ADataSet: TDataSet);
var
  lookupDS: TDataSource;
  svc: IEntityService;
  entityName: string;
  eviewName: string;
  eviewID: string;
  field: TField;
  I: integer;
begin
  svc := WorkItem.Services[IEntityService] as IEntityService;
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
 //   Buttons.Add;
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

procedure TcxVGridViewHelper.InitMemoEditor(ARow: TcxDBEditorRow);
begin
  ARow.Properties.EditPropertiesClass := TcxMemoProperties;
  with TcxMemoProperties(ARow.Properties.EditProperties) do
  begin
    WordWrap := false;
    WantReturns := false;
    ScrollBars := ssVertical;
    VisibleLineCount := 0;
  end;
end;

procedure TcxVGridViewHelper.ImageRow_OnAssignPicture(Sender: TObject;
  const Picture: TPicture);
var
  row: TcxDBEditorRow;
  ds: TDataSet;
  fieldName: string;
  fieldDel: TField;
begin
  row := TcxDBEditorRow(TcxDBVerticalGrid(TcxImage(Sender).owner).FocusedRow);
  fieldName := row.Properties.DataBinding.FieldName;
  ds := row.Properties.DataBinding.DataController.DataSet;
  fieldDel := ds.FindField(fieldName + '_DEL');
  if fieldDel <> nil then
  begin
    if Picture.Graphic = nil then
      fieldDel.Value := 1
    else
      fieldDel.Value := 0;
  end;

end;

procedure TcxVGridViewHelper.InitCalcEditor(ARow: TcxDBEditorRow; AField: TField);
begin
  ARow.Properties.EditPropertiesClass := TcxCalcEditProperties;
  with TcxCalcEditProperties(ARow.Properties.EditProperties) do
  begin
    ImmediatePost := true;
    ImmediateDropDownWhenKeyPressed :=
      CheckFieldAttribute(AField, FIELD_ATTR_EDITOR_CALC_AUTOPOPUP);
  end;
end;

procedure TcxVGridViewHelper.InitCheckBoxEditor(ARow: TcxDBEditorRow; AField: TField);
var
  allowGrayedAttr: boolean;
begin
  allowGrayedAttr := CheckFieldAttribute(AField, FIELD_ATTR_EDITOR_CHECKBOX_ALLOWGRAYED);

  ARow.Properties.EditPropertiesClass := TcxCheckBoxProperties;
  with TcxCheckBoxProperties(ARow.Properties.EditProperties) do
  begin
    DisplayChecked := 'Да';
    DisplayUnchecked := 'Нет';
    AllowGrayed := allowGrayedAttr;
    ValueChecked := 1;
    ValueUnchecked := 0;
    ValueGrayed := -1;
    ImmediatePost := true;
    Alignment := taLeftJustify;
    UseAlignmentWhenInplace := true;
  end;

end;

procedure TcxVGridViewHelper.InitColorEditor(ARow: TcxDBEditorRow);
begin
  ARow.Properties.EditPropertiesClass := TcxColorComboBoxProperties;
  with TcxColorComboBoxProperties(ARow.Properties.EditProperties) do
  begin
    ClearKey := TextToShortCut('Del');
    ColorValueFormat := cxcvInteger;
    AllowSelectColor := true;
    ShowDescriptions := false;
    ImmediatePost := true;
   // PrepareList := cxplHTML4;
  end;
end;

procedure TcxVGridViewHelper.InitComboBoxEditor(ARow: TcxDBEditorRow;
  ADataSet: TDataSet);

var
  lookupDS: TDataSet;
  svc: IEntityService;
  entityName: string;
  eviewName: string;
  eviewID: string;
  field: TField;
begin
  svc := WorkItem.Services[IEntityService] as IEntityService;
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
  ARow.Properties.EditPropertiesClass := TcxImageProperties;
  ARow.Height := 150;
  with TcxImageProperties(ARow.Properties.EditProperties) do
  begin
    GraphicClassName := 'TJPEGImage';
    Stretch := true;
    //ClearKey := TextToShortCut('Del'); on move to next row and back dont work !
    ImmediatePost := true;
    OnAssignPicture := ImageRow_OnAssignPicture;
  end;

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
  (AControl as TcxEditorRow).VerticalGrid.HideEdit; //!!! надо для немедленного отображения в ячейке
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

function TcxVGridViewHelper.GetPreferenceFileName(
  AGrid: TcxDBVerticalGrid): string;
const
  cnstGridPreferenceCategoryFmt = 'VGrid_%s';
begin
  Result := Format(cnstGridPreferenceCategoryFmt, [AGrid.Name]);

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

procedure TcxVGridViewHelper.GridRow_OnPropertiesGetEditProperties(
  Sender: TcxCustomEditorRowProperties; ARecordIndex: Integer;
  var AProperties: TcxCustomEditProperties);
begin
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

procedure TcxVGridViewHelper.SaveAllPreference;
var
  I: integer;
begin
  for I := 0 to Owner.ComponentCount - 1 do
    if Owner.Components[I] is TcxDBVerticalGrid then
       SavePreference(TcxDBVerticalGrid(Owner.Components[I]));
end;

procedure TcxVGridViewHelper.SavePreference(AGrid: TcxDBVerticalGrid);

  procedure SaveToStorage(AGrid: TcxDBVerticalGrid; AStorage: TMemInifile);
  var
    _section: string;
    I: integer;
  begin
    _section := 'COMMON';
    AStorage.WriteInteger(_section, 'ValueWidth', AGrid.OptionsView.ValueWidth);
    AStorage.WriteInteger(_section, 'RowHeaderWidth', AGrid.OptionsView.RowHeaderWidth);

    for I := 0 to AGrid.Rows.Count - 1 do
    begin
      if AGrid.Rows[I] is TcxCategoryRow then
      begin
        _section := 'BAND_' + IntToStr(I);
        AStorage.WriteBool(_section, 'Expanded', AGrid.Rows[I].Expanded);
      end;
    end;
  end;

var
  _storage: TMemInifile;
  _strings: TStringList;
  data: TMemoryStream;
begin
  _storage := TMemInifile.Create('');
  data := TMemoryStream.Create;
  try
    SaveToStorage(AGrid, _storage);

    _strings := TStringList.Create;
    try
      _storage.GetStrings(_strings);
      _strings.SaveToStream(data);
    finally
      _strings.Free;
    end;

    App.UserProfile.SaveData((Owner as ICustomView).GetPreferencePath,
      GetPreferenceFileName(AGrid), data);
  finally
    _storage.Free;
    data.free;
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
  procedure InitPickListData(AData: IActivityData; ADataSet: TDataSet);
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
  activity: IActivity;

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

  dataSet := (WorkItem.Services[IEntityService] as IEntityService).
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

      activity := WorkItem.Activities[actionName];

      activity.Params[TPickListActivityParams.Filter] := pickFilter;
      InitPickListData(activity.Params, dataSet);

      activity.Execute(WorkItem);

      dataSet.Edit;

      if activity.Outs[TViewActivityOuts.ModalResult] <> mrOK then
      begin
        field.Value := OldValue;
        if Assigned(fieldID) then
          fieldID.Value := OldIDValue;
      end
      else
      begin
        field.Value := activity.Outs[TPickListActivityOuts.NAME];
        if Assigned(fieldID) then
          fieldID.Value := activity.Outs[TPickListActivityOuts.ID];

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
              dataValueField.Value := activity.Outs[dataName]
            else
              WorkItem.State[dataValueName] := activity.Outs[dataName];
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
