unit ReportLauncherView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox, Menus,
  cxStyles, cxInplaceContainer, cxVGrid, cxDBVGrid, DB, dxmdaset, StdCtrls,
  cxButtons, cxLabel, cxDBLookupComboBox, cxCheckBox, ReportLauncherPresenter,
  CustomContentView, cxButtonEdit, cxDropDownEdit, cxCheckComboBox, cxDBCheckComboBox, cxCheckListBox,
  cxDBCheckListBox, cxClasses;


type
  TfrReportLauncherView = class(TfrCustomContentView, IReportLauncherView)
    ParamDataSource: TDataSource;
    grParams: TcxDBVerticalGrid;
    grParamsCategoryTop: TcxCategoryRow;
    cxStyleRepository1: TcxStyleRepository;
    cxStyleReadOnlyParam: TcxStyle;
    cxStyleLayoutHeader: TcxStyle;
  private

    function FindParamEditor(AParamName: string): TcxDBEditorRow;
    procedure ParamEditorButtonEditClick(Sender: TObject; AButtonIndex: Integer);
    procedure ParamEditorButtonEditValueChanged(Sender: TObject);
    procedure ParamEditorValueChanged(Sender: TObject);
    procedure LayoutChanged(Sender: TObject);
  protected
    //TCustomView
    procedure OnFocusDataSetControl(ADataSet: TDataSet; const AFieldName: string;
      var Done: boolean); override;

    //IReportLauncherView
    procedure LinkParamDataSet(const ADataSet: TDataSet);
    procedure InitParamEditor_DBLookup(const AParamName: string; ADataSet: TDataSet;
      const AKeyFieldName, AListFieldName: string);
    procedure InitParamEditor_CheckBox(const AParamName: string);
    procedure InitParamEditor_CheckBoxList(const AParamName: string; AItems: TStrings);
    procedure InitParamEditor_Lookup(const AParamName: string; AItems: TStrings);
    procedure InitParamEditor_ButtonEdit(const AParamName, ACommandName: string);
    procedure InitLayoutEditor(const AParamName: string; ADataSet: TDataSet);
    procedure SetParamsStatus;
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

type
  HackEditorRowProperties = class(TcxCustomEditorRowProperties);
  HackInplaceEditContainer = class(TcxCellEdit);// (TcxCustomInplaceEditContainer);


function TfrReportLauncherView.FindParamEditor(
  AParamName: string): TcxDBEditorRow;
var
  I: integer;
begin
  Result := nil;
  for I := 0 to grParams.Rows.Count - 1 do
    if (grParams.Rows[I] is TcxDBEditorRow) and
       (TcxDBEditorRow(grParams.Rows[I]).
         Properties.DataBinding.FieldName = AParamName) then
     begin
       Result := TcxDBEditorRow(grParams.Rows[I]);
       Exit;
     end;
end;

procedure TfrReportLauncherView.InitParamEditor_DBLookup(
  const AParamName: string; ADataSet: TDataSet; const AKeyFieldName,
  AListFieldName: string);
var
  grRow: TcxDBEditorRow;
  lookupDS: TDataSource;
begin
  grRow := FindParamEditor(AParamName);
  if not Assigned(grRow) then Exit;

  lookupDS := TDataSource.Create(grRow);
  lookupDS.DataSet := ADataSet;

  grRow.Properties.EditPropertiesClass := TcxLookupComboBoxProperties;
  with TcxLookupComboBoxProperties(grRow.Properties.EditProperties) do
  begin
    ClearKey := TextToShortCut('Del');
    ListOptions.ShowHeader := false;
    if lookupDS.DataSet.RecordCount < 25 then
      DropDownRows := lookupDS.DataSet.RecordCount
    else
      DropDownRows := 25;
    ListSource := lookupDS;
    KeyFieldNames := AKeyFieldName;
    ListFieldNames := AListFieldName;

    OnEditValueChanged := ParamEditorValueChanged;
  end;
end;

procedure TfrReportLauncherView.LayoutChanged(Sender: TObject);
begin
  TcxCustomEdit(Sender).PostEditValue;
  WorkItem.Commands[COMMAND_LAYOUT_CHANGED].Execute;
end;

procedure TfrReportLauncherView.LinkParamDataSet(const ADataSet: TDataSet);
begin
  ParamDataSource.DataSet := ADataSet;
  grParams.DataController.CreateAllItems;
end;

procedure TfrReportLauncherView.InitParamEditor_CheckBox(
  const AParamName: string);
var
  grRow: TcxDBEditorRow;
begin
  grRow := FindParamEditor(AParamName);
  if not Assigned(grRow) then Exit;

  grRow.Properties.EditPropertiesClass := TcxCheckBoxProperties;
  with TcxCheckBoxProperties(grRow.Properties.EditProperties) do
  begin
    AllowGrayed := false;
    ValueChecked := 1;
    ValueUnchecked := 0;
    ValueGrayed := 0;
    ImmediatePost := true;
    Alignment := taLeftJustify;
    UseAlignmentWhenInplace := true;
  end;

end;

procedure TfrReportLauncherView.InitParamEditor_CheckBoxList(
  const AParamName: string; AItems: TStrings);
var
  grRow: TcxDBEditorRow;
  I: integer;
begin
  grRow := FindParamEditor(AParamName);
  if not Assigned(grRow) then Exit;

  {lookupDS := TDataSource.Create(grRow);
  lookupDS.DataSet := ADataSet;}

  grRow.Properties.EditPropertiesClass := TcxCheckComboBoxProperties;
  with TcxCheckComboBoxProperties(grRow.Properties.EditProperties) do
  begin

    if not grRow.Properties.DataBinding.Field.Required then
      ClearKey := TextToShortCut('Del');

    for I := 0 to AItems.Count - 1 do
      Items.AddCheckItem(AItems[I]);

    ImmediatePost := true;

    EmptySelectionText := '';
   { if lookupDS.DataSet.RecordCount < 25 then
      DropDownRows := lookupDS.DataSet.RecordCount
    else
      DropDownRows := 25;}
  end;

end;

procedure TfrReportLauncherView.InitParamEditor_Lookup(
  const AParamName: string; AItems: TStrings);
var
  grRow: TcxDBEditorRow;
//  lookupDS: TDataSource;
begin
  grRow := FindParamEditor(AParamName);
  if not Assigned(grRow) then Exit;

  {lookupDS := TDataSource.Create(grRow);
  lookupDS.DataSet := ADataSet;}

  grRow.Properties.EditPropertiesClass := TcxComboBoxProperties;
  with TcxComboBoxProperties(grRow.Properties.EditProperties) do
  begin

    if not grRow.Properties.DataBinding.Field.Required then
      ClearKey := TextToShortCut('Del');

    Items.AddStrings(AItems);
    DropDownListStyle := lsEditFixedList;
    ImmediatePost := true;

   { if lookupDS.DataSet.RecordCount < 25 then
      DropDownRows := lookupDS.DataSet.RecordCount
    else
      DropDownRows := 25;}
  end;

end;

procedure TfrReportLauncherView.InitLayoutEditor(const AParamName: string;
  ADataSet: TDataSet);
var
  grRow: TcxDBEditorRow;
  lookupDS: TDataSource;
begin
  grRow := FindParamEditor(AParamName);
  if not Assigned(grRow) then Exit;

  grRow.Styles.Header := cxStyleLayoutHeader;

  lookupDS := TDataSource.Create(grRow);
  lookupDS.DataSet := ADataSet;

  grRow.Properties.EditPropertiesClass := TcxLookupComboBoxProperties;
  with TcxLookupComboBoxProperties(grRow.Properties.EditProperties) do
  begin
  //  ClearKey := TextToShortCut('Del');
    ListOptions.ShowHeader := false;
    if lookupDS.DataSet.RecordCount < 25 then
      DropDownRows := lookupDS.DataSet.RecordCount
    else
      DropDownRows := 25;
    ListSource := lookupDS;
    KeyFieldNames := 'ID';
    ListFieldNames := 'NAME';
    Revertable := true;
    OnEditValueChanged := LayoutChanged;
  end;

end;

procedure TfrReportLauncherView.InitParamEditor_ButtonEdit(
  const AParamName, ACommandName: string);
var
  grRow: TcxDBEditorRow;
begin
  grRow := FindParamEditor(AParamName);
  if not Assigned(grRow) then Exit;


  grRow.Properties.EditPropertiesClass := TcxButtonEditProperties;
  with TcxButtonEditProperties(grRow.Properties.EditProperties) do
  begin
    LookupItems.Text := ACommandName;
    OnButtonClick := ParamEditorButtonEditClick;
    OnEditValueChanged := ParamEditorButtonEditValueChanged;
   //btn := TcxButtonEditProperties(grRow.Properties.EditProperties).Buttons.Add;
    {AllowGrayed := false;
    ValueChecked := 1;
    ValueUnchecked := 0;
    ValueGrayed := 0;
    ImmediatePost := true;
    Alignment := taLeftJustify;
    UseAlignmentWhenInplace := true;}
  end;

end;

procedure TfrReportLauncherView.ParamEditorButtonEditClick(
  Sender: TObject; AButtonIndex: Integer);
var
  _command: string;
begin
  TcxCustomEdit(Sender).PostEditValue;
  _command := TcxButtonEdit(Sender).Properties.LookupItems[0];
  WorkItem.Commands[_command].Execute;

end;

procedure TfrReportLauncherView.ParamEditorButtonEditValueChanged(
  Sender: TObject);
var
  _command: string;
begin
  TcxCustomEdit(Sender).PostEditValue;
  _command := TcxButtonEdit(Sender).Properties.LookupItems[0];
  WorkItem.Commands[_command].Execute;
end;


procedure TfrReportLauncherView.ParamEditorValueChanged(Sender: TObject);
begin
  TcxCustomEdit(Sender).PostEditValue;
end;

procedure TfrReportLauncherView.SetParamsStatus;
var
  I: integer;
  field: TField;
  ds: TDataSet;
  row: TcxDBEditorRow;
begin
  ds := ParamDataSource.DataSet;
  //for param's labels rows
  for I := 0 to grParams.Rows.Count - 1 do
  begin
    if (grParams.Rows[I] is TcxDBEditorRow) then
    begin
      row := TcxDBEditorRow(grParams.Rows[I]);
      field := ds.FindField(row.Properties.DataBinding.FieldName);

      if field = nil then Continue;

      row.Visible := field.Visible;

      if field.ReadOnly then
      begin
        with row do
        begin
          Styles.Content := cxStyleReadOnlyParam;
          Properties.Options.Editing := false;
          Properties.Options.ShowEditButtons := eisbNever;
        end;
      end
      else
      begin
        with row do
        begin
          Styles.Content := nil;
          Properties.Options.Editing := true;
          Properties.Options.ShowEditButtons := eisbDefault;
        end;
      end;
    end;
  end;

end;

procedure TfrReportLauncherView.OnFocusDataSetControl(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
var
  grRow: TcxDBEditorRow;
begin
  if ParamDataSource.DataSet = ADataSet then
  begin
    Done := true;

    //if grParams.CanFocus then grParams.SetFocus;
    GetParentForm(grParams).ActiveControl := grParams;

    grRow := FindParamEditor(AFieldName);
    if Assigned(grRow) then
      grParams.FocusRow(grRow);
  end
end;

end.
