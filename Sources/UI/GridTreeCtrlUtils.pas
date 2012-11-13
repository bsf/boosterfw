unit GridTreeCtrlUtils;

interface
uses cxTL, cxTLdxBarBuiltInMenu, cxTLData, cxDBTL,
  Contnrs, controls, CustomView, classes, sysutils, db,
  EntityServiceIntf, cxButtonEdit, cxEdit, CoreClasses, StrUtils, Variants,
  CustomPresenter, cxInplaceContainer, cxDBLookupComboBox, menus, cxCheckBox,
  UIClasses, inifiles, ShellIntf, cxStyles;

type
  TcxTreeGridViewHelper = class(TViewHelper, IViewHelper, IViewDataSetHelper)
  private
    FGridList: TComponentList;

    procedure TuneGridForDataSet(AGrid: TcxDBTreeList; ADataSet: TDataSet);

    function GetGridList: TComponentList;

    function GetPreferenceFileName(ATree: TcxCustomTreeList): string;
    procedure LoadPreference(ATree: TcxCustomTreeList);
    procedure SavePreference(ATree: TcxCustomTreeList);
    procedure SaveAllPreference; //(AGridView: TcxCustomGridView; AData: TStream);

    //Style
    procedure OnGetColumnStyle(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn;
      ANode: TcxTreeListNode; var AStyle: TcxStyle);

    procedure OnGetRowStyle(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn;
      ANode: TcxTreeListNode; var AStyle: TcxStyle);

  protected
    //IViewHelper
    procedure ViewInitialize;
    procedure ViewShow;
    procedure ViewClose;
    //IViewDataSetHelper
    procedure LinkDataSet(ADataSource: TDataSource; ADataSet: TDataSet);
    procedure UnLinkDataSet(ADataSource: TDataSource);
    procedure FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string; var Done: boolean);

    function GetFocusedField(ADataSet: TDataSet; var Done: boolean): string;
    procedure SetFocusedField(ADataSet: TDataSet; const AFieldName: string; var Done: boolean);
    procedure SetFocusedFieldChangedHandler(AHandler: TViewFocusedFieldChangedHandler; var Done: boolean);

  public
    constructor Create(AOwner: TfrCustomView); override;
    destructor Destroy; override;
  end;

implementation


{ TcxTreeGridViewHelper }

constructor TcxTreeGridViewHelper.Create(AOwner: TfrCustomView);
begin
  inherited;
  FGridList := TComponentList.Create(false);
end;

destructor TcxTreeGridViewHelper.Destroy;
begin
  FGridList.Free;
  inherited;
end;

procedure TcxTreeGridViewHelper.FocusDataSetControl(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
begin

end;


function TcxTreeGridViewHelper.GetFocusedField(ADataSet: TDataSet;
  var Done: boolean): string;
begin

end;

function TcxTreeGridViewHelper.GetGridList: TComponentList;

var  I: integer;
begin
  FGridList.Clear;
  for I := 0 to GetForm.ComponentCount - 1 do
    if GetForm.Components[I] is TcxDBTreeList then
      FGridList.Add(GetForm.Components[I]);

  Result := FGridList;

end;

function TcxTreeGridViewHelper.GetPreferenceFileName(
  ATree: TcxCustomTreeList): string;
const
  cnstGridPreferenceCategoryFmt = 'Tree_%s';
begin
  Result := Format(cnstGridPreferenceCategoryFmt, [ATree.Name]);

end;

procedure TcxTreeGridViewHelper.LinkDataSet(ADataSource: TDataSource;
  ADataSet: TDataSet);
var
  I: integer;
  _gridList: TComponentList;
begin
  _gridList := GetGridList;
  for I := 0 to _gridList.Count - 1 do
    if (TcxDBTreeList(_gridList[I]).DataController.DataSource <> nil)
       and
      (ADataSet =
       TcxDBTreeList(_gridList[I]).DataController.DataSource.DataSet) then
    begin
      TuneGridForDataSet(TcxDBTreeList(_gridList[I]), ADataSet);
      LoadPreference(TcxDBTreeList(_gridList[I]));
    end;
end;


procedure TcxTreeGridViewHelper.LoadPreference(ATree: TcxCustomTreeList);

  procedure LoadDBTreeList(ATree: TcxDBTreeList; AStorage: TMemInifile);
  var
    I: integer;
    _section: string;
  begin
    //_section := 'COMMON';
    //AView.OptionsView.Footer :=
      //AStorage.ReadBool(_section, 'Footer', AView.OptionsView.Footer);

    // begin setup position
    for I := 0 to ATree.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + TcxDBItemDataBinding(ATree.Columns[I].DataBinding).FieldName;
      ATree.Columns[I].Position.ColIndex :=
        AStorage.ReadInteger(_section, 'ColIndex', ATree.Columns[I].Position.ColIndex);
    end;

    for I := 0 to ATree.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + TcxDBItemDataBinding(ATree.Columns[I].DataBinding).FieldName;
      ATree.Columns[I].Width :=
        AStorage.ReadInteger(_section, 'Width', ATree.Columns[I].Width);
      if ATree.Columns[I].Options.Customizing then
        ATree.Columns[I].Visible := AStorage.ReadBool(_section, 'Visible', ATree.Columns[I].Visible);

        //Summary
     { ATree.Columns[I].Summary.FooterKind :=
        TcxSummaryKind(
        AStorage.ReadInteger(_section + '_Summary', 'FooterKind', Ord(AView.Columns[I].Summary.FooterKind)));}
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
      GetPreferenceFileName(ATree), data);
    data.Position := 0;

    if (data.Size = 0) then
    begin
      ATree.ApplyBestFit;
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
        if ATree is TcxDBTreeList then
          LoadDBTreeList(TcxDBTreeList(ATree), _storage)
        else
          ATree.RestoreFromStream(data, false, false, ATree.Name);
      finally
        _storage.Free
      end;
    end;
  finally
    data.free;
  end;

end;

procedure TcxTreeGridViewHelper.OnGetColumnStyle(Sender: TcxCustomTreeList;
  AColumn: TcxTreeListColumn; ANode: TcxTreeListNode; var AStyle: TcxStyle);
begin

end;

procedure TcxTreeGridViewHelper.OnGetRowStyle(Sender: TcxCustomTreeList;
  AColumn: TcxTreeListColumn; ANode: TcxTreeListNode; var AStyle: TcxStyle);
begin
  if ANode = nil then Exit;

  AStyle := TcxStyle(App.UI.Styles[VarToStr(ANode.Values[(Sender as TcxDBTreeList).
    GetColumnByFieldName(FIELD_UI_ROW_STYLE).ItemIndex])]);

end;

procedure TcxTreeGridViewHelper.SaveAllPreference;
var
  I: integer;
begin
  for I := 0 to Owner.ComponentCount - 1 do
    if Owner.Components[I] is TcxCustomTreeList then
      SavePreference(TcxCustomTreeList(Owner.Components[I]));
end;

procedure TcxTreeGridViewHelper.SavePreference(ATree: TcxCustomTreeList);

  procedure SaveDBTreeList(ATree: TcxDBTreeList; AStorage: TMemInifile);
  var
    I: integer;
    _section: string;
  begin
   // _section := 'COMMON';
   // AStorage.WriteBool(_section, 'Footer', AView.OptionsView.Footer);

    for I := 0 to ATree.ColumnCount - 1 do
    begin
      _section := 'COLUMN_' + TcxDBItemDataBinding(ATree.Columns[I].DataBinding).FieldName;
      AStorage.WriteInteger(_section, 'ColIndex', ATree.Columns[I].Position.ColIndex);
      AStorage.WriteBool(_section, 'Visible', ATree.Columns[I].Visible);
      AStorage.WriteInteger(_section, 'Width', ATree.Columns[I].Width);
      //footer
      //AStorage.WriteInteger(_section + '_Summary', 'FooterKind', Ord(AView.Columns[I].Summary.FooterKind) );
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
    if ATree is TcxDBTreeList then
      SaveDBTreeList(TcxDBTreeList(ATree), _storage)
    else
      ATree.StoreToStream(data, ATree.Name);

    _strings := TStringList.Create;
    try
      _storage.GetStrings(_strings);
      _strings.SaveToStream(data);
    finally
      _strings.Free;
    end;

    App.UserProfile.SaveData((Owner as ICustomView).GetPreferencePath,
      GetPreferenceFileName(ATree), data);
  finally
    _storage.Free;
    data.free;
  end;

end;

procedure TcxTreeGridViewHelper.SetFocusedField(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
begin

end;

procedure TcxTreeGridViewHelper.SetFocusedFieldChangedHandler(
  AHandler: TViewFocusedFieldChangedHandler; var Done: boolean);
begin

end;

procedure TcxTreeGridViewHelper.TuneGridForDataSet(
  AGrid: TcxDBTreeList; ADataSet: TDataSet);
var
  grController: TcxDBTreeListDataController;
  //CategoryCaption: string;
  I: integer;
  primaryKey: string;
  parentField: TField;
  col: TcxDBTreeListColumn;
  field: TField;
begin
  if not Assigned(ADataSet) then Exit;

  grController := AGrid.DataController;
  if grController.KeyField = '' then
  begin
    primaryKey := GetDataSetAttribute(ADataSet, DATASET_ATTR_PRIMARYKEY);
    if primaryKey <> '' then
      grController.KeyField := primaryKey
    else if ADataSet.FieldCount > 0 then
      grController.KeyField := ADataSet.Fields[0].FieldName;
  end;

  if grController.ParentField = '' then
  begin
    parentField := ADataSet.FindField('PARENT_ID');
    if parentField = nil then
      parentField := ADataSet.FindField('PARENTID');
    if parentField = nil then
      parentField := ADataSet.FindField('PARENT');

    if parentField <> nil then
      grController.ParentField := parentField.FieldName;
  end;

  grController.CreateAllItems;

  if GetDataSetAttribute(ADataSet, DATASET_ATTR_READONLY) = 'Yes' then
    with AGrid.OptionsData do
    begin
      Editing := false;
      Inserting := false;
      Deleting := false;
    end;

  if ADataSet.FindField(FIELD_UI_ROW_STYLE) <> nil then
    AGrid.Styles.OnGetContentStyle := OnGetRowStyle;

  //Tune columns
  for I := 0 to ADataSet.FieldCount - 1 do
  begin
    field := ADataSet.Fields[I];
    col := AGrid.GetColumnByFieldName(field.FieldName);

    col.Visible := field.Visible;
    col.Options.Customizing :=  not (GetFieldAttribute(field, FIELD_ATTR_HIDDEN) = '1');

    //Editor
    if field.ReadOnly then
    begin
      col.Options.Editing := false;
      col.Options.ShowEditButtons := eisbNever;
    end;
    //else
     // InitRowEditor(grEditorRow, ADataSet.Fields[I]);

  end


end;

procedure TcxTreeGridViewHelper.UnLinkDataSet(ADataSource: TDataSource);
begin

end;

procedure TcxTreeGridViewHelper.ViewClose;
begin
  SaveAllPreference;
end;

procedure TcxTreeGridViewHelper.ViewInitialize;
begin

end;

procedure TcxTreeGridViewHelper.ViewShow;
begin

end;

initialization
  RegisterViewHelperClass(TcxTreeGridViewHelper);

end.
