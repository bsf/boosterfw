unit GridTreeGtrlUtils;

interface
uses cxTL, cxTLdxBarBuiltInMenu, cxTLData, cxDBTL,
  Contnrs, controls, CustomView, classes, sysutils, db,
  EntityServiceIntf, cxButtonEdit, cxEdit, CoreClasses, StrUtils, Variants,
  CustomPresenter, cxInplaceContainer, cxDBLookupComboBox, menus, cxCheckBox,
  UIClasses;

type
  TcxTreeGridViewHelper = class(TViewHelper, IViewHelper)
  private
    FGridList: TComponentList;

    //PickListEditor
   { procedure PickListEditorButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure PickListEditorValueChanged(Sender: TObject);
    procedure PickListEditorExecute(ADataSet: TDataSet;
      const AFieldName, APickNameFilter: string);

    procedure InitRowEditor(AEditorRow: TcxDBEditorRow; AField: TField);
    procedure InitPickListEditor(ARow: TcxDBEditorRow);
    procedure InitLookupEditor(ARow: TcxDBEditorRow; ADataSet: TDataSet);
    procedure InitCheckBoxEditor(ARow: TcxDBEditorRow);
    }

    procedure TuneGridForDataSet(AGrid: TcxDBTreeList; ADataSet: TDataSet);

   // procedure CreateAllItems(AGrid: TcxDBVerticalGrid; ADataSet: TDataSet);
    function GetGridList: TComponentList;

   {  function FindEditorRowByFieldName(AGrid: TcxDBVerticalGrid;
       const AFieldName: string): TcxDBEditorRow;
     function FindOrCreateCategoryRow(AGrid: TcxDBVerticalGrid;
       const ACaption: string): TcxCategoryRow;}
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

     TuneGridForDataSet(TcxDBTreeList(_gridList[I]), ADataSet);
end;


procedure TcxTreeGridViewHelper.SetFocusedField(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
begin

end;

procedure TcxTreeGridViewHelper.TuneGridForDataSet(
  AGrid: TcxDBTreeList; ADataSet: TDataSet);
var
  grController: TcxDBTreeListDataController;
//  CategoryCaption: string;
 // I: integer;

begin
  if not Assigned(ADataSet) then Exit;

  grController := AGrid.DataController;
  {if grController.KeyField = '' then
  begin
    if APrimaryKey <> '' then
      grController.KeyField := APrimaryKey
    else if ADataSet.FieldCount > 0 then
      grController.KeyField := ADataSet.Fields[0].FieldName;
  end;
   }

  grController.CreateAllItems;

{  for I := 0 to ADataSet.FieldCount - 1 do
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
    if ADataSet.Fields[I].ReadOnly then
    begin
    //  grEditorRow.Options.TabStop := false;
      grEditorRow.Properties.Options.Editing := false;
      grEditorRow.Properties.Options.ShowEditButtons := eisbNever;
    end
    else
      InitRowEditor(grEditorRow, ADataSet.Fields[I]);

  end
 }

end;

procedure TcxTreeGridViewHelper.ViewClose;
begin

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
