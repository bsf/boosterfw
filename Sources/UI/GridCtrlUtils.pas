unit GridCtrlUtils;

interface
uses classes, forms, cxGridPopupMenu, cxGrid, menus, inifiles, variants,
  cxGridCustomPopupMenu, ActnList, Dialogs, cxGridExportLink, ShellAPI,
  windows, cxGridCustomView, CustomView, SysUtils, cxGridCustomTableView,
  db, cxGridDBDataDefinitions, Contnrs, cxGridTableView, cxGridDBTableView,
  cxGridStdPopupMenu, cxGridMenuOperations, cxGridHeaderPopupMenuItems,
  cxGridDBBandedTableView, EntityServiceIntf, cxCustomData, cxFilter, cxGraphics,
  cxDBLookupComboBox, cxCheckBox, UIClasses, ShellIntf;


resourcestring
  cxGridExportToExcel = 'Экспорт в Excel';
  cxGridAdjustColumnWidths = 'По ширине таблицы';
  cxGridQuickFilter = 'Фильтр по выделенному';

type

// Represents a column header menu operation associated with the menu item.
// To provide an image for the menu item override the GetImageResourceName
// function to return the name of the image from a resource file.
// To link a resource file use the {$R } compiler directive. Note that this
// file should be in the search path.


  TcxGridExportToExcelMenuOperation = class(TcxGridHeaderPopupMenuOperation)
  protected
    procedure Execute(Sender: TObject); override;
    function GetDown: Boolean; override;
    function GetEnabled: Boolean; override;
  public
    constructor Create; override;
  end;

  TcxGridAdjustColumWidthsMenuOperation = class(TcxGridHeaderPopupMenuOperation)
  protected
    procedure Execute(Sender: TObject); override;
    function GetDown: Boolean; override;
    function GetEnabled: Boolean; override;
  public
    constructor Create; override;
  end;

  TcxGridQuickFilterMenuOperation = class(TcxGridHeaderPopupMenuOperation)
  protected
    procedure Execute(Sender: TObject); override;
    function GetDown: Boolean; override;
    function GetEnabled: Boolean; override;
  public
    constructor Create; override;
  end;

  TGridQuickFilterExtMenuItem = class(TMenuItem)
  private
    FAction: TAction;
    FGrid: TcxGridTableView;
    procedure OnClickHandler(Sender: TObject);
    procedure OnUpdateHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AGrid: TcxGridTableView); reintroduce;
  end;

  TGridQuickFilterResetExtMenuItem = class(TMenuItem)
  private
    FAction: TAction;
    FGrid: TcxGridTableView;
    procedure OnClickHandler(Sender: TObject);
    procedure OnUpdateHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AGrid: TcxGridTableView); reintroduce;
  end;

// Represents a column header menu operation set that extends the built-in
// operation set with a new menu operation
  TcxGridNewHeaderPopupMenuOperations = class(TcxGridHeaderPopupMenuOperations)
  protected
    procedure AddItems; override;
  end;

// Represents a popup menu that includes the created operation set
  TcxGridNewHeaderMenu = class(TcxGridStdHeaderMenu)
  protected
    function GetOperationsClass: TcxGridPopupMenuOperationsClass; override;
  end;

  TcxGridViewHelper = class(TViewHelper, IViewHelper, IViewDataSetHelper)
  private
    FGridList: TComponentList;
    FGridViewList: TComponentList;
    procedure InitColumnEditor(AColumn: TcxGridColumn; AField: TField);
    procedure InitLookupEditor(AColumn: TcxGridColumn; AField: TField);
    procedure InitCheckBoxEditor(AColumn: TcxGridColumn; AField: TField);

    procedure TuneGridForDataSet(AView: TcxCustomGridView; ADataSet: TDataSet);
    function GetGridList: TComponentList;
    function GetGridViewList: TComponentList;
    function FindGridViewByDataSet(ADataSet: TDataSet): TcxCustomGridView;
    procedure CreateGridPopupMenus(AGrid: TcxGrid);
    procedure LinkGridPopupMenus(AForm: TForm);
    procedure ExtendGridExtMenu(AMenu: TPopupMenu; AGridView: TcxGridTableView);

    //IViewPreferenceHelper
    function GetPreferenceFileName(AGridView: TcxCustomGridView): string;
    procedure LoadPreference(AGridView: TcxCustomGridView);
    procedure SavePreference(AGridView: TcxCustomGridView);
    procedure SaveAllPreference; //(AGridView: TcxCustomGridView; AData: TStream);
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

  public
    constructor Create(AOwner: TfrCustomView); override;
    destructor Destroy; override;
  end;

procedure GridQuickFilter(AGrid: TcxGridTableView);

implementation

uses cxGridBandedTableView;


procedure GridQuickFilter(AGrid: TcxGridTableView);
var
  FilterValue: Variant;
  FilterItem: TcxCustomGridTableItem;
begin
  if (not Assigned(AGrid.Controller.FocusedItem)) or
     (AGrid.Controller.SelectedRecordCount = 0) then Exit;

  FilterItem := AGrid.Controller.FocusedItem;
  FilterValue := AGrid.Controller.SelectedRecords[0].
    Values[FilterItem.Index];

  if (AGrid.Controller.IncSearchingText <> '') and
     ( (FilterItem.DataBinding.ValueType = 'String') or
        (FilterItem.DataBinding.ValueType = 'WideString')) then
  begin
    FilterValue := AGrid.Controller.IncSearchingText;
    FilterValue := FilterValue + '%';
  end;


  with AGrid.DataController.Filter.Root do
  begin
    //clear all existing filter conditions
    Clear;
    //set the logical operator
    //by which new conditions are combined
    //BoolOperatorKind := fboOr;
    //add new filter conditions
    AddItem(FilterItem, foLike, FilterValue, VarToStr(FilterValue));
    AGrid.DataController.Filter.Active := true;
  end;

end;

{ TcxGridViewHelper }


constructor TcxGridViewHelper.Create(AOwner: TfrCustomView);
begin
  inherited;
  FGridList := TComponentList.Create(false);
  FGridViewList := TComponentList.Create(false);
end;

procedure TcxGridViewHelper.CreateGridPopupMenus(AGrid: TcxGrid);
var
  gridMenu: TcxGridPopupMenu;
  ppmExt: TPopupMenu;
  ppmInfo: TcxPopupMenuInfo;
  I: integer;
begin
  gridMenu := TcxGridPopupMenu.Create(AGrid);
  gridMenu.Grid := AGrid;
  gridMenu.UseBuiltInPopupMenus := true;
  for I := 0 to AGrid.ViewCount - 1 do
  begin
    ppmExt := TPopupMenu.Create(AGrid.Views[I]);
    ppmInfo := TcxPopupMenuInfo(gridMenu.PopupMenus.Add);
    ppmInfo.GridView := AGrid.Views[I];
    ppmInfo.PopupMenu := ppmExt;
    ppmInfo.HitTypes := [gvhtCell, gvhtRecord, gvhtBand, gvhtBandHeader];
    ExtendGridExtMenu(ppmExt, TcxGridTableView(AGrid.Views[I]));
  end;
end;

destructor TcxGridViewHelper.Destroy;
begin
  FGridList.Free;
  FGridViewList.Free;  
  inherited;
end;

procedure TcxGridViewHelper.ExtendGridExtMenu(AMenu: TPopupMenu;
  AGridView: TcxGridTableView);
var
  mi: TMenuItem;
begin
  mi := TGridQuickFilterExtMenuItem.Create(AMenu, AGridView);
  AMenu.Items.Add(mi);
  mi := TGridQuickFilterResetExtMenuItem.Create(AMenu, AGridView);
  AMenu.Items.Add(mi);
end;

function TcxGridViewHelper.FindGridViewByDataSet(
  ADataSet: TDataSet): TcxCustomGridView;
var
  I: integer;
  _gridViews: TComponentList;
begin
  _gridViews := GetGridViewList;
  for I := 0 to _gridViews.Count - 1 do
    if (TcxCustomGridView(_gridViews[I]).DataController is TcxGridDBDataController)
       and
      (TcxGridDBDataController(TcxCustomGridView(_gridViews[I]).DataController).DataSource <> nil)
       and
      (ADataSet =
       TcxGridDBDataController(TcxCustomGridView(_gridViews[I]).DataController).DataSource.DataSet) then
    begin
      Result := TcxCustomGridView(_gridViews[I]);
      Exit;
    end;
  Result := nil;
end;

procedure TcxGridViewHelper.FocusDataSetControl(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
var
  gridView: TcxCustomGridView;
  col: TcxCustomGridTableItem;
begin
  gridView := FindGridViewByDataSet(ADataSet);
  if gridView <> nil then
  begin
    col := (gridView.DataController as TcxGridDBDataController).
      GetItemByFieldName(AFieldName);
    if col <> nil then
      col.Focused := true;
  end;
end;

function TcxGridViewHelper.GetFocusedField(ADataSet: TDataSet;
  var Done: boolean): string;
begin


end;

function TcxGridViewHelper.GetGridList: TComponentList;
var
  I: integer;
begin
  FGridList.Clear;
  for I := 0 to GetForm.ComponentCount - 1 do
    if GetForm.Components[I] is TcxGrid then
      FGridList.Add(GetForm.Components[I]);

  Result := FGridList;
end;

function TcxGridViewHelper.GetGridViewList: TComponentList;
var
  I, Y: integer;
  _grids: TComponentList;
begin
  FGridViewList.Clear;
  _grids := GetGridList;
  for I := 0 to _grids.Count - 1 do
    for Y := 0 to TcxGrid(_grids[I]).ViewCount - 1 do
      FGridViewList.Add(TcxGrid(_grids[I]).Views[Y]);
  Result := FGridViewList;
end;

function TcxGridViewHelper.GetPreferenceFileName(AGridView: TcxCustomGridView): string;
const
  cnstGridPreferenceCategoryFmt = 'Grid_%s';
begin
  Result := Format(cnstGridPreferenceCategoryFmt, [AGridView.Name]);
  {for I := 0 to Owner.ComponentCount - 1 do
    if Owner.Components[I] is TcxGrid then
      for Y := 0 to TcxGrid(Owner.Components[I]).ViewCount - 1 do
        ACategories.Add(Format(cnstGridPreferenceCategoryFmt,
          [Owner.Components[I].Name,
            TcxGrid(Owner.Components[I]).Views[Y].Name]));}
end;


procedure TcxGridViewHelper.InitCheckBoxEditor(AColumn: TcxGridColumn;
  AField: TField);
begin
  AColumn.PropertiesClass := TcxCheckBoxProperties;
  with TcxCheckBoxProperties(AColumn.Properties) do
  begin
    DisplayChecked := 'Да';
    DisplayUnchecked := 'Нет';
    AllowGrayed := false;
    ValueChecked := 1;
    ValueUnchecked := 0;
    ValueGrayed := 0;
    ImmediatePost := true;
    Alignment := taCenter;//taLeftJustify;
    UseAlignmentWhenInplace := true;
  end;

end;

procedure TcxGridViewHelper.InitColumnEditor(AColumn: TcxGridColumn;
  AField: TField);
var
  editorTyp: string;
begin

  editorTyp := GetFieldAttribute(AField, 'Editor');

  if not AField.ReadOnly then
  begin
    if SameText(editorTyp, FIELD_ATTR_EDITOR_LOOKUP) then
       InitLookupEditor(AColumn, AField)

    else if SameText(editorTyp, FIELD_ATTR_EDITOR_CHECKBOX) then
       InitCheckBoxEditor(AColumn, AField);
  end
  else
  begin
    AColumn.Options.Editing := false;
    AColumn.Options.ShowEditButtons := isebNever;
    if SameText(editorTyp, FIELD_ATTR_EDITOR_CHECKBOX) then
       InitCheckBoxEditor(AColumn, AField);
  end
end;

procedure TcxGridViewHelper.InitLookupEditor(AColumn: TcxGridColumn;
  AField: TField);
var
  lookupDS: TDataSource;
  svc: IEntityManagerService;
  entityName: string;
  eviewName: string;
  eviewID: string;
  I: integer;
begin
  svc := (GetForm as IView).WorkItem.Services[IEntityManagerService] as IEntityManagerService;

  entityName := GetFieldAttribute(AField, FIELD_ATTR_EDITOR_ENTITY);
  eviewName := GetFieldAttribute(AField, FIELD_ATTR_EDITOR_EVIEW);
  eviewID := AField.DataSet.Name + '_lookupData_' + AField.FieldName;

  lookupDS := TDataSource.Create(AColumn);
  lookupDS.DataSet := svc.Entity[entityName].GetView(eviewName, (GetForm as IView).WorkItem, eviewID).Load;

  AColumn.PropertiesClass := TcxLookupComboBoxProperties;
  with TcxLookupComboBoxProperties(AColumn.Properties) do
  begin
    ClearKey := TextToShortCut('Del');
    ListOptions.ShowHeader := false;
    //ListOptions.GridLines := glNone;
    ImmediatePost := true;

    if lookupDS.DataSet.RecordCount < 25 then
      DropDownRows := lookupDS.DataSet.RecordCount
    else
      DropDownRows := 25;
    ListSource := lookupDS;
    KeyFieldNames := GetFieldAttribute(AField, FIELD_ATTR_EDITOR_KEYFIELD);
    if KeyFieldNames = '' then
      KeyFieldNames := 'ID';

    ListFieldNames := GetFieldAttribute(AField, FIELD_ATTR_EDITOR_NAMEFIELD);
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

    if ListColumns.Count > 1 then
      DropDownAutoSize := true;
  end;

end;

procedure TcxGridViewHelper.LinkDataSet(ADataSource: TDataSource; ADataSet: TDataSet);
var
  I: integer;
  _gridViews: TComponentList;
begin
  _gridViews := GetGridViewList;
  for I := 0 to _gridViews.Count - 1 do
    if (TcxCustomGridView(_gridViews[I]).DataController is TcxGridDBDataController)
       and
      (TcxGridDBDataController(TcxCustomGridView(_gridViews[I]).DataController).DataSource <> nil)
       and
      (ADataSet =
       TcxGridDBDataController(TcxCustomGridView(_gridViews[I]).DataController).DataSource.DataSet) then
    begin
      TuneGridForDataSet(TcxCustomGridView(_gridViews[I]), ADataSet);
      LoadPreference(TcxCustomGridView(_gridViews[I]));
    end;
end;

procedure TcxGridViewHelper.LinkGridPopupMenus(AForm: TForm);
var
  I: integer;
begin
  for I := 0 to AForm.ComponentCount - 1 do
    if AForm.Components[I] is TcxGrid then
      CreateGridPopupMenus(TcxGrid(AForm.Components[I]));
end;


procedure TcxGridViewHelper.LoadPreference(AGridView: TcxCustomGridView);


  procedure LoadDBBandedTableView(AView: TcxGridDBBandedTableView; AStorage: TMemInifile);
  var
    I: integer;
    _section: string;
  begin
    _section := 'COMMON';
    AView.OptionsView.Footer :=
      AStorage.ReadBool(_section, 'Footer', AView.OptionsView.Footer);

    for I := 0 to AView.Bands.Count - 1 do
    begin
      _section := 'BAND_' + IntToStr(I);
      if AStorage.SectionExists(_section) then
      begin
        AView.Bands[I].Width :=
          AStorage.ReadInteger(_section, 'Width', AView.Bands[I].Width);
        AView.Bands[I].Visible := AStorage.ReadBool(_section, 'Visible', AView.Bands[I].Visible);
      end;
    end;

    for I := 0 to AView.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + AView.Columns[I].DataBinding.FieldName;
      AView.Columns[I].Position.ColIndex :=
        AStorage.ReadInteger(_section, 'ColIndex', AView.Columns[I].Position.ColIndex);
    end;
   
    for I := 0 to AView.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + AView.Columns[I].DataBinding.FieldName;
      AView.Columns[I].Width :=
        AStorage.ReadInteger(_section, 'Width', AView.Columns[I].Width);
      if AView.Columns[I].VisibleForCustomization then
        AView.Columns[I].Visible := AStorage.ReadBool(_section, 'Visible', AView.Columns[I].Visible);

      //Summary
      AView.Columns[I].Summary.FooterKind :=
        TcxSummaryKind(
        AStorage.ReadInteger(_section + '_Summary', 'FooterKind', Ord(AView.Columns[I].Summary.FooterKind)));
    end;
  end;

  procedure LoadDBTableView(AView: TcxGridDBTableView; AStorage: TMemInifile);
  var
    I: integer;
    _section: string;
  begin
    _section := 'COMMON';
    AView.OptionsView.Footer :=
      AStorage.ReadBool(_section, 'Footer', AView.OptionsView.Footer);

    // begin setup position
    for I := 0 to AView.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + AView.Columns[I].DataBinding.FieldName;
      AView.Columns[I].Index :=
        AStorage.ReadInteger(_section, 'ColIndex', AView.Columns[I].Index);
    end;

    for I := 0 to AView.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + AView.Columns[I].DataBinding.FieldName;
      AView.Columns[I].Width :=
        AStorage.ReadInteger(_section, 'Width', AView.Columns[I].Width);
      if AView.Columns[I].VisibleForCustomization then
        AView.Columns[I].Visible := AStorage.ReadBool(_section, 'Visible', AView.Columns[I].Visible);

        //Summary
      AView.Columns[I].Summary.FooterKind :=
        TcxSummaryKind(
        AStorage.ReadInteger(_section + '_Summary', 'FooterKind', Ord(AView.Columns[I].Summary.FooterKind)));
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
      GetPreferenceFileName(AGridView), data);
    data.Position := 0;

    if (data.Size = 0) then
    begin
      if AGridView is TcxCustomGridTableView then
        TcxCustomGridTableView(AGridView).ApplyBestFit();
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
        if AGridView is TcxGridDBBandedTableView then
          LoadDBBandedTableView(TcxGridDBBandedTableView(AGridView), _storage)
        else if AGridView is TcxGridDBTableView then
          LoadDBTableView(TcxGridDBTableView(AGridView), _storage)
          //gridView.RestoreFromStream(AData, false, false, [], gridView.Name)
        else
          AGridView.RestoreFromStream(data, false, false, [], AGridView.Name);
      finally
        _storage.Free
      end;
    end;
  finally
    data.free;
  end;
end;


procedure TcxGridViewHelper.SaveAllPreference;
var
  I, Y: integer;
begin
  for I := 0 to Owner.ComponentCount - 1 do
    if Owner.Components[I] is TcxGrid then
      for Y := 0 to TcxGrid(Owner.Components[I]).ViewCount - 1 do
        SavePreference(TcxGrid(Owner.Components[I]).Views[Y]);
        {ACategories.Add(Format(cnstGridPreferenceCategoryFmt,
          [Owner.Components[I].Name,
            TcxGrid(Owner.Components[I]).Views[Y].Name]));}

end;

procedure TcxGridViewHelper.SavePreference(AGridView: TcxCustomGridView);


  procedure SaveDBBandedTableView(AView: TcxGridDBBandedTableView; AStorage: TMemInifile);
  var
    I: integer;
    _section: string;
  begin
    _section := 'COMMON';
    AStorage.WriteBool(_section, 'Footer', AView.OptionsView.Footer);

    for I := 0 to AView.Bands.Count - 1 do
    begin
      _section := 'BAND_' + IntToStr(I);
      AStorage.WriteBool(_section, 'Visible', AView.Bands[I].Visible);
      AStorage.WriteInteger(_section, 'Width', AView.Bands[I].Width);
    end;

    for I := 0 to AView.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + AView.Columns[I].DataBinding.FieldName;

      AStorage.WriteInteger(_section, 'BandIndex', AView.Columns[I].Position.BandIndex);
      AStorage.WriteInteger(_section, 'ColIndex', AView.Columns[I].Position.ColIndex);
      AStorage.WriteBool(_section, 'Visible', AView.Columns[I].Visible);
      AStorage.WriteInteger(_section, 'Width', AView.Columns[I].Width);
      //footer
      AStorage.WriteInteger(_section + '_Summary', 'FooterKind', Ord(AView.Columns[I].Summary.FooterKind) );
    end
  end;

  procedure SaveDBTableView(AView: TcxGridDBTableView; AStorage: TMemInifile);
  var
    I: integer;
    _section: string;
  begin
    _section := 'COMMON';
    AStorage.WriteBool(_section, 'Footer', AView.OptionsView.Footer);

    for I := 0 to AView.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + AView.Columns[I].DataBinding.FieldName;
      AStorage.WriteInteger(_section, 'ColIndex', AView.Columns[I].Index);
      AStorage.WriteBool(_section, 'Visible', AView.Columns[I].Visible);
      AStorage.WriteInteger(_section, 'Width', AView.Columns[I].Width);
      //footer
      AStorage.WriteInteger(_section + '_Summary', 'FooterKind', Ord(AView.Columns[I].Summary.FooterKind) );
    end

  end;
var
  _storage: TMemInifile;
  _strings: TStringList;
  data: TMemoryStream;
begin
  _storage := TMemInifile.Create('');
  data := TMemoryStream.Create;
  try
    if AGridView is TcxGridDBBandedTableView then
      SaveDBBandedTableView(TcxGridDBBandedTableView(AGridView), _storage)
    else if AGridView is TcxGridDBTableView then
      SaveDBTableView(TcxGridDBTableView(AGridView), _storage)
    else
      AGridView.StoreToStream(data, [], AGridView.Name);

    _strings := TStringList.Create;
    try
      _storage.GetStrings(_strings);
      _strings.SaveToStream(data);
    finally
      _strings.Free;
    end;

    App.UserProfile.SaveData((Owner as ICustomView).GetPreferencePath,
      GetPreferenceFileName(AGridView), data);
  finally
    _storage.Free;
    data.free;
  end;
end;

procedure TcxGridViewHelper.SetFocusedField(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
begin

end;

procedure TcxGridViewHelper.SetFocusedFieldChangedHandler(
  AHandler: TViewFocusedFieldChangedHandler; var Done: boolean);
begin

end;

procedure TcxGridViewHelper.TuneGridForDataSet(AView: TcxCustomGridView;
  ADataSet: TDataSet);

  function FindOrCreateBand(const ACaption: string): integer;
  var
    I: integer;
  begin
    for I := 0 to TcxGridDBBandedTableView(AView).Bands.Count - 1 do
      if TcxGridDBBandedTableView(AView).
           Bands[I].Caption = ACaption then
      begin
        Result := I;
        Exit;
      end;
    Result := TcxGridDBBandedTableView(AView).Bands.Add.Index;
    TcxGridDBBandedTableView(AView).Bands[Result].Caption := ACaption;
  end;

  procedure TuneColumn(AColumn: TcxGridColumn; AField: TField);
  begin
    if AField.DisplayLabel <> AField.FieldName then
    begin
      AColumn.Caption :=  ''; //надо сбросить !!! см. исходники DX
      AColumn.Caption := AField.DisplayLabel;
    end;

    AColumn.Visible := AField.Visible;
    AColumn.VisibleForCustomization :=  not (GetFieldAttribute(AField, FIELD_ATTR_HIDDEN) = '1');
  end;

var
  grController: TcxGridDBDataController;
  I: integer;
  BandCaption: string;
  BandIdx: integer;

  Col: TcxGridColumn;
  Field: TField;
  primaryKey: string;
begin
  if not Assigned(ADataSet) then Exit;

  grController := TcxGridDBDataController(AView.DataController);
  if grController.KeyFieldNames = '' then
  begin
    primaryKey := GetDataSetAttribute(ADataSet, DATASET_ATTR_PRIMARYKEY);
    if primaryKey <> '' then
      grController.KeyFieldNames := primaryKey
    else if ADataSet.FieldCount > 0 then
      grController.KeyFieldNames := ADataSet.Fields[0].FieldName;
  end;
  grController.Filter.Options := grController.Filter.Options + [fcoCaseInsensitive];

  grController.CreateAllItems(true);

  if AView is TcxGridTableView then
  begin
    if GetDataSetAttribute(ADataSet, DATASET_ATTR_READONLY) = 'Yes' then
    begin
      TcxGridTableView(AView).OptionsData.Editing := false;
      TcxGridTableView(AView).OptionsData.Inserting := false;
      TcxGridTableView(AView).OptionsData.Deleting := false;
      TcxGridTableView(AView).OptionsData.Appending := false;
    end;
  end;

  for I := 0 to ADataSet.FieldCount - 1 do
  begin
    Col := nil;
    Field := ADataSet.Fields[I];
    if AView is TcxGridDBBandedTableView then
    begin
      Col := TcxGridDBBandedTableView(AView).GetColumnByFieldName(Field.FieldName);

      TuneColumn(Col, Field);

      {Bands}
      BandCaption := GetFieldAttribute(Field, 'Band');
      if BandCaption <> '' then
      begin
        BandIdx := FindOrCreateBand(BandCaption);
        TcxGridDBBandedColumn(Col).Position.BandIndex := BandIdx;
      end;

    end
    else if AView is TcxGridDBTableView then
    begin
      Col := TcxGridDBTableView(AView).GetColumnByFieldName(Field.FieldName);
      TuneColumn(Col, Field);
    end;

    //InitEditors
{    if Assigned(Col) and Field.ReadOnly then
    begin
      Col.Options.Editing := false;
      Col.Options.ShowEditButtons := isebNever;
    end
    else}

    if Assigned(Col) then
      InitColumnEditor(Col, Field);

  end;


end;

procedure TcxGridViewHelper.ViewClose;
begin
  SaveAllPreference;
end;

procedure TcxGridViewHelper.ViewInitialize;
begin
  LinkGridPopupMenus(GetForm);
end;

procedure TcxGridViewHelper.ViewShow;
begin

end;

{ TcxGridExportToExcelMenuOperation }

constructor TcxGridExportToExcelMenuOperation.Create;
begin
  inherited Create;
  ResCaption := @cxGridExportToExcel;
end;

procedure TcxGridExportToExcelMenuOperation.Execute(Sender: TObject);
  function GetExportFileName: string;
  var
    FileDlg: TSaveDialog;
  begin
    Result := '';
    FileDlg := TSaveDialog.Create(Application);
    with FileDlg do begin
      DefaultExt := 'xls';
       Filter := 'Excel файлы (*.xls)|*.XLS';
       if Execute then
       Result := FileName;
    end;
  end;
var
  fileName: string;
begin
  fileName := GetExportFileName;
  if fileName <> '' then
  begin
    ExportGridToExcel(fileName, TcxGrid(Self.HitGridView.Site.Container));
    ShellExecute(0, 'open', 'excel', PChar('"' + fileName + '"'), '', SW_SHOWDEFAULT);
  end;

end;

function TcxGridExportToExcelMenuOperation.GetDown: Boolean;
begin
  Result := false;
end;

function TcxGridExportToExcelMenuOperation.GetEnabled: Boolean;
begin
  Result := true;
end;

{ TcxGridNewHeaderPopupMenuOperations }

procedure TcxGridNewHeaderPopupMenuOperations.AddItems;
begin
  inherited AddItems;
  AddItem(TcxGridAdjustColumWidthsMenuOperation);
  AddItem(TcxGridExportToExcelMenuOperation).BeginGroup := True;
  AddItem(TcxGridQuickFilterMenuOperation);
end;

{ TcxGridNewHeaderMenu }

function TcxGridNewHeaderMenu.GetOperationsClass: TcxGridPopupMenuOperationsClass;
begin
  Result := TcxGridNewHeaderPopupMenuOperations;
end;

{ TcxGridAdjustColumWidthsMenuOperation }

constructor TcxGridAdjustColumWidthsMenuOperation.Create;
begin
  inherited;
  ResCaption := @cxGridAdjustColumnWidths;
end;

procedure TcxGridAdjustColumWidthsMenuOperation.Execute(Sender: TObject);
begin
  Self.HitGridView.OptionsView.ColumnAutoWidth :=
    not Self.HitGridView.OptionsView.ColumnAutoWidth;
end;

function TcxGridAdjustColumWidthsMenuOperation.GetDown: Boolean;
begin
  Result := Self.HitGridView.OptionsView.ColumnAutoWidth;
end;

function TcxGridAdjustColumWidthsMenuOperation.GetEnabled: Boolean;
begin
  Result := true;
end;


{ TcxGridQuickFilterMenuOperation }

constructor TcxGridQuickFilterMenuOperation.Create;
begin
  inherited;
  ResCaption := @cxGridQuickFilter;
end;

procedure TcxGridQuickFilterMenuOperation.Execute(Sender: TObject);
begin
  GridQuickFilter(Self.HitGridView);
end;

function TcxGridQuickFilterMenuOperation.GetDown: Boolean;
begin
  Result := false;
end;

function TcxGridQuickFilterMenuOperation.GetEnabled: Boolean;
begin
  Result := (Self.HitGridView.Controller.SelectedRecordCount > 0)
    and (Self.HitGridView.Controller.FocusedItemIndex <> -1);
end;


{ TGridQuickFilterExtMenuItem }

constructor TGridQuickFilterExtMenuItem.Create(AOwner: TComponent; AGrid: TcxGridTableView);
begin
  inherited Create(AOwner);
  FGrid := AGrid;
  FAction := TAction.Create(AOwner);
  FAction.OnExecute := OnClickHandler;
  FAction.OnUpdate := OnUpdateHandler;
  FAction.ShortCut := TextToShortCut('F7');
  FAction.Visible := false;
  Self.Action := FAction;
end;

procedure TGridQuickFilterExtMenuItem.OnClickHandler(Sender: TObject);
begin
  GridQuickFilter(FGrid);
end;

procedure TGridQuickFilterExtMenuItem.OnUpdateHandler(Sender: TObject);
begin
  FAction.Enabled := Assigned(FGrid.Controller.FocusedItem) and
    (FGrid.Controller.SelectedRecordCount <> 0);
end;

{ TGridQuickFilterResetExtMenuItem }

constructor TGridQuickFilterResetExtMenuItem.Create(AOwner: TComponent;
  AGrid: TcxGridTableView);
begin
  inherited Create(AOwner);
  FGrid := AGrid;
  FAction := TAction.Create(AOwner);
  FAction.OnExecute := OnClickHandler;
  FAction.ShortCut := TextToShortCut('Ctrl+F7');
  FAction.Visible := false;
  Self.Action := FAction;
end;

procedure TGridQuickFilterResetExtMenuItem.OnClickHandler(Sender: TObject);
begin
  FGrid.DataController.Filter.Clear;
//  Active := false;
end;

procedure TGridQuickFilterResetExtMenuItem.OnUpdateHandler(Sender: TObject);
begin

{ FAction.Enabled :=  FGrid.DataController.Filter.Active
  FAction.Enabled := Assigned(FGrid.Controller.FocusedItem) and
    (FGrid.Controller.SelectedRecordCount <> 0);}

end;

initialization
  RegisterViewHelperClass(TcxGridViewHelper);

  // Registers the column header popup menu
  RegisterPopupMenuClass(TcxGridNewHeaderMenu, [gvhtColumnHeader], TcxGridTableView);


end.
