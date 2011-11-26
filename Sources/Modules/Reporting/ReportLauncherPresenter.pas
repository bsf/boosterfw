unit ReportLauncherPresenter;

interface
uses classes, CoreClasses, CustomPresenter, ShellIntf, UIClasses, SysUtils,
  dxmdaset, db, ReportCatalogClasses, EntityServiceIntf,
  variants, StrUtils, controls, ReportCatalogConst, CommonUtils,
  cxDateUtils, Generics.Collections;

const
  COMMAND_EXECUTE = '{1D84C651-1B31-4F77-87BF-86A00AC0232B}';
  COMMAND_CLOSE = '{4744CD2A-2140-4507-8D75-79CD70FEE9BF}';

  COMMAND_DATA_PARAMNAME = 'ParamName';
  COMMAND_PARAM_CHANGED = 'commands.paramchanged.';
  COMMAND_LAYOUT_CHANGED = 'commands.layoutchanged';

type

  IReportLauncherView = interface(ICustomView)
  ['{52F4B023-C2FC-47E6-BF67-576C28683977}']
    procedure LinkParamDataSet(const ADataSet: TDataSet);
    procedure InitParamEditor_DBLookup(const AParamName: string; ADataSet: TDataSet;
      const AKeyFieldName, AListFieldName: string);
    procedure InitParamEditor_CheckBox(const AParamName: string);
    procedure InitParamEditor_CheckBoxList(const AParamName: string; AItems: TStrings);

    procedure InitParamEditor_Lookup(const AParamName: string; AItems: TStrings);
    procedure InitParamEditor_ButtonEdit(const AParamName, ACommanName: string);

    procedure InitLayoutEditor(const AParamName: string; ADataSet: TDataSet);
    procedure SetParamsStatus;
  end;


  TReportLauncherPresenter = class(TCustomPresenter)
  const
    ACTIVITY_REPORT_LAUNCHER = 'views.reports.launcher';
    REPORT_LAYOUT_PARAM = TReportActivityParams.Layout;
    PARAM_LABEL_SUFFIX = '.Label';
    PARAM_PREFIX = 'Init.';
  private
    FParamDataSet: TdxMemData;
    FLayoutDataSet: TdxMemData;
    FReportCatalogItem: TReportCatalogItem;
    FInitialized: boolean;
    procedure InitParamDataSet;
    procedure InitViewParamEditors;
    procedure InitParamDefaultValues;
    procedure InitParamValues;
    procedure ParamValueChangeHandler(Sender: TField);

    procedure CmdPickListEditorExecute(Sender: TObject);
    procedure CmdLayoutChanged(Sender: TObject);
    procedure CmdExecute(Sender: TObject);
    procedure CmdClose(Sender: TObject);

  protected
    //TAbstractController
    function OnGetWorkItemState(const AName: string): Variant; override;
    procedure OnSetWorkItemState(const AName: string; const AValue: Variant); override;

    //
    function View: IReportLauncherView;
    procedure OnInit(Sender: IActivity); override;
    procedure OnReinit(Sender: IActivity); override;

    procedure OnViewShow; override;
  end;

implementation

{ TReportLauncherPresenter }

procedure TReportLauncherPresenter.CmdExecute(Sender: TObject);
var
  doClose: boolean;
begin

  doClose := not IsControlKeyDown;

  if FParamDataSet.State in [dsEdit] then FParamDataSet.Post;

  App.UI.MessageBox.StatusBarMessage('Формирование отчета: ' + FReportCatalogItem.Caption);
  try
   (WorkItem.Services[IReportCatalogService] as IReportCatalogService).
     LaunchReport(WorkItem, FReportCatalogItem.ID,
       WorkItem.State[TReportActivityParams.Layout],
       WorkItem.State[TReportActivityParams.LaunchMode]);
  finally
    App.UI.MessageBox.StatusBarMessage('Готово');
  end;

  if doClose then CloseView(false);


end;

procedure TReportLauncherPresenter.CmdLayoutChanged(Sender: TObject);
var
  I: integer;
  field: TField;
  fieldLabel: TField;
  mParam: TManifestParamNode;
  layout: string;
  fieldHiden: boolean;
  fieldLabelHiden: boolean;
begin
  //Params
  if FParamDataSet.State in [dsEdit] then
    FParamDataSet.Post;

  layout := WorkItem.State[TReportActivityParams.Layout];
  for I := 0 to FReportCatalogItem.Manifest.ParamNodes.Count - 1 do
  begin
    mParam := FReportCatalogItem.Manifest.ParamNodes[I];
    field := FParamDataSet.FieldByName(mParam.Name);
    fieldLabel := FParamDataSet.FieldByName(mParam.Name + PARAM_LABEL_SUFFIX);
    if mParam.Layouts.Count <> 0 then
    begin
      fieldHiden := GetFieldAttribute(field, FIELD_ATTR_HIDDEN) = '1';
      fieldLabelHiden := GetFieldAttribute(fieldLabel, FIELD_ATTR_HIDDEN) = '1';
      field.Visible := (not fieldHiden) and (mParam.Layouts.IndexOf(layout) <> -1);
      fieldLabel.Visible := (not fieldLabelHiden) and (mParam.Layouts.IndexOf(layout) <> -1);
    end;
  end;

  View.SetParamsStatus;
end;

procedure TReportLauncherPresenter.OnInit(Sender: IActivity);

  procedure LayoutDataSetCreateFields;
  var
    field: TStringField;
  begin
    //ID
    field := TStringField.Create(Self);
    field.DisplayWidth := 255;
    field.Size := 255;
    field.FieldName := 'ID';
    field.DataSet := FLayoutDataSet;
    //NAME
    field := TStringField.Create(Self);
    field.DisplayWidth := 255;
    field.Size := 255;
    field.FieldName := 'NAME';
    field.DataSet := FLayoutDataSet;
  end;

var
  layout: TReportLayout;
begin
  FreeOnViewClose := false;

  if WorkItem.Context = WorkItem.ID then
    WorkItem.Context := '';

  FReportCatalogItem :=
   (WorkItem.Services[IReportCatalogService] as IReportCatalogService).
      GetItem(WorkItem.State['ReportURI']);

  ViewHidden := Sender.Params[TReportLaunchParams.LaunchMode] <> 0;

  ViewTitle := FReportCatalogItem.Caption;

  FParamDataSet := TdxMemData.Create(Self);

  FLayoutDataSet := TdxMemData.Create(Self);
  LayoutDataSetCreateFields;
  FLayoutDataSet.Open;
  for layout in FReportCatalogItem.Manifest.Layouts do
  begin
    FLayoutDataSet.Append;
    FLayoutDataSet.FieldValues['ID'] := layout.ID;
    FLayoutDataSet.FieldValues['NAME'] := layout.Caption;
    FLayoutDataSet.Post;
  end;

  InitParamDataSet;
  InitParamDefaultValues;

  View.LinkParamDataSet(FParamDataSet);
  InitViewParamEditors;

  View.CommandBar.AddCommand(COMMAND_EXECUTE, 'Выполнить', '', CmdExecute);
  View.CommandBar.AddCommand(COMMAND_CLOSE, 'Отмена', '', CmdClose);

  WorkItem.Commands[COMMAND_LAYOUT_CHANGED].SetHandler(CmdLayoutChanged);
  WorkItem.Commands[COMMAND_EXECUTE].SetHandler(CmdExecute);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

  InitParamValues;

  if ViewHidden then
    WorkItem.Commands[COMMAND_EXECUTE].Execute;

  FInitialized := true;
end;

procedure TReportLauncherPresenter.OnViewShow;
begin
 // InitParamValues;

  GetView.FocusDataSetControl(FParamDataSet);
end;
procedure TReportLauncherPresenter.InitParamDataSet;
  procedure CreateField(AParam: TManifestParamNode);
  var
    prmField: TField;
    lblField: TField;
  begin
    case AParam.Editor of
      peInteger: prmField := TIntegerField.Create(Self);
      peString: prmField := TStringField.Create(Self);
      peDate: prmField := TDateField.Create(Self);
      peFloat: prmField := TFloatField.Create(Self);
      peDBList: prmField := TStringField.Create(Self);
     // peNone: prmField := TVariantField.Create(Self); not supported by TdxMemData
    else
      prmField := TStringField.Create(Self);
    end;

    if prmField is TStringField then
    begin
      TStringField(prmField).DisplayWidth := 255;
      TStringField(prmField).Size := 255;
    end;

    prmField.DisplayLabel := AParam.Caption;
    prmField.FieldName := AParam.Name;
    prmField.DataSet := FParamDataSet;
    prmField.Visible := not AParam.Hidden;
    prmField.Alignment := taLeftJustify;
    prmField.OnChange := ParamValueChangeHandler;

    //Label Field
    lblField := TStringField.Create(Self);
    TStringField(lblField).DisplayWidth := 255;
    TStringField(lblField).Size := 255;
    lblField.DisplayLabel := AParam.Caption;
    lblField.FieldName := AParam.Name + PARAM_LABEL_SUFFIX;
    lblField.DataSet := FParamDataSet;
    //lblField.Visible := false;
    lblField.ReadOnly := true;
    lblField.Alignment := taLeftJustify;
  end;

  procedure CreateReportLayoutsField;
  var
    field: TStringField;
  begin
    field := TStringField.Create(Self);
    TStringField(Field).DisplayWidth := 255;
    TStringField(Field).Size := 255;
    field.DisplayLabel := 'Макет';
    field.FieldName := REPORT_LAYOUT_PARAM;
    field.DataSet := FParamDataSet;
   // field.Required := true;
    //field.Visible := FLayoutCaptions.Count > 1;

  end;

var
  I: integer;
begin

  CreateReportLayoutsField;

  {create fields}
  for I := 0 to FReportCatalogItem.Manifest.ParamNodes.Count - 1 do
    CreateField(FReportCatalogItem.Manifest.ParamNodes[I]);

  FParamDataSet.Open;
  FParamDataSet.Insert;
  FParamDataSet.Post;

end;

procedure TReportLauncherPresenter.InitParamDefaultValues;


  procedure Init_DateByDefValue(AParam: TManifestParamNode; AField: TField);
  var
    dat: TDateTime;
  begin
    if not SmartTextToDate(AParam.DefaultValue, dat) then
      dat := Date;
    AField.Value := dat;
  end;


  procedure Init_DBLookup(AParam: TManifestParamNode; AField: TField);
  {var
    editorProp: TcxLookupComboBoxProperties;
    listDataSet: TDataSet;}

  begin
    {editorProp := TcxLookupComboBoxProperties(
      FindParamEditor(AParam.Name).Properties.EditProperties);
    listDataSet := editorProp.ListSource.DataSet;
    if not listDataSet.IsEmpty then
      AField.Value := listDataSet[editorProp.KeyFieldNames];}

  end;

var
  I: integer;
  field: TField;
  mParam: TManifestParamNode;
  defVal: Variant;
begin
  FParamDataSet.Edit;
  FParamDataSet.FieldByName(REPORT_LAYOUT_PARAM).Value :=
    FReportCatalogItem.Manifest.Layouts.Items[0].ID;

  for I := 0 to FReportCatalogItem.Manifest.ParamNodes.Count - 1 do
  begin
    mParam := FReportCatalogItem.Manifest.ParamNodes[I];
    field := FParamDataSet.FieldByName(mParam.Name);

    defVal := Unassigned;
    if mParam.DefaultValue <> '' then
      defVal := mParam.DefaultValue;

    if VarIsEmpty(defVal) then
      case mParam.Editor of
        peDate: field.AsDateTime := Date;
        peDBList: Init_DBLookup(mParam, field);
        peCheckBox: field.asInteger := 0;
      end
    else
      case mParam.Editor of
        peDate: Init_DateByDefValue(mParam, field);
        else
         // Field.AsString := mParam.DefaultValue;
          Field.Value := defVal;
      end;
  end;

  FParamDataSet.Post;
end;

procedure TReportLauncherPresenter.InitParamValues;
var
  I: integer;
  field: TField;
  fieldLabel: TField;
  mParam: TManifestParamNode;
  Val: Variant;
  initLayout: string;
begin
//in View autopost!!!

  //Layouts
  initLayout := WorkItem.State[TReportLaunchParams.InitLayout];

  FParamDataSet.Edit;
  if (initLayout = '') or (FReportCatalogItem.Manifest.Layouts.IndexOf(initLayout) = -1) then
    FParamDataSet.FieldByName(REPORT_LAYOUT_PARAM).Value :=
      FReportCatalogItem.Manifest.Layouts.Items[0].ID
  else
    FParamDataSet.FieldByName(REPORT_LAYOUT_PARAM).Value := initLayout;


  if FParamDataSet.State in [dsEdit] then
    FParamDataSet.Post;

  FParamDataSet.FieldByName(REPORT_LAYOUT_PARAM).Visible :=
    (initLayout <> '') or (FReportCatalogItem.Manifest.Layouts.Count > 1);

  FParamDataSet.FieldByName(REPORT_LAYOUT_PARAM).ReadOnly := initLayout <> '';

  //Params
  for I := 0 to FReportCatalogItem.Manifest.ParamNodes.Count - 1 do
  begin
    mParam := FReportCatalogItem.Manifest.ParamNodes[I];
    field := FParamDataSet.FieldByName(mParam.Name);

    Val := WorkItem.State[PARAM_PREFIX + mParam.Name];

    if not VarIsEmpty(Val) then
    begin
      FParamDataSet.Edit;
      if VarIsStr(Val) and (VarToStr(Val) = '') then
        field.Value := null
      else
        field.Value := Val;
    end;

    //Label
    fieldLabel := FParamDataSet.FieldByName(mParam.Name + PARAM_LABEL_SUFFIX);
    Val := WorkItem.State[PARAM_PREFIX + mParam.Name + PARAM_LABEL_SUFFIX];
    if not VarIsEmpty(Val) then
    begin
      field.Visible := false;
      fieldLabel.Visible := true;
      FParamDataSet.Edit;
      fieldLabel.Value := VarToStr(Val);
    end
    else
    begin
      fieldLabel.Visible := false;
      field.Visible := not mParam.Hidden;
    end;

    if field.Visible then
      SetFieldAttribute(field, FIELD_ATTR_HIDDEN, '0')
    else
      SetFieldAttribute(field, FIELD_ATTR_HIDDEN, '1');

   if fieldLabel.Visible then
      SetFieldAttribute(fieldLabel, FIELD_ATTR_HIDDEN, '0')
    else
      SetFieldAttribute(fieldLabel, FIELD_ATTR_HIDDEN, '1');

  end;

  if FParamDataSet.State in [dsEdit] then
    FParamDataSet.Post;

  WorkItem.Commands[COMMAND_LAYOUT_CHANGED].Execute;

//  View.SetParamsStatus;
end;

function TReportLauncherPresenter.View: IReportLauncherView;
begin
  Result := GetView as IReportLauncherView;
end;

procedure TReportLauncherPresenter.InitViewParamEditors;

  procedure InitLookupEditor(AParamNode: TManifestParamNode);
  var
    lookupData: IEntityView;
    keyNames: string;
    listNames: string;
  begin
    lookupData := App.Entities[AParamNode.EditorOptions.Values['EntityName']].
      GetView(AParamNode.EditorOptions.Values['EntityViewName'], WorkItem,
        'ParamLookupDataSet_' + AParamNode.Name);
    lookupdata.Load([]);

    keyNames := AParamNode.EditorOptions.Values['KeyFieldNames'];
    listNames := AParamNode.EditorOptions.Values['ListFieldNames'];
    if keyNames = '' then keyNames := 'ID';
    if listNames = '' then listNames := 'NAME';

    View.InitParamEditor_DBLookup(AParamNode.Name, lookupData.DataSet,
      keyNames, listNames);
  end;


  procedure InitPickListEditor(AParamNode: TManifestParamNode);
  var
    commandName: string;
  begin
    commandName := 'command://reportLauncher.ActionButton.' + AParamNode.Name;
    WorkItem.Commands[commandName].Data[COMMAND_DATA_PARAMNAME] := AParamNode.Name;
    WorkItem.Commands[commandname].SetHandler(CmdPickListEditorExecute);

    View.InitParamEditor_ButtonEdit(AParamNode.Name, commandName);
  end;

  procedure InitCheckBoxEditor(AParamNode: TManifestParamNode);
  begin

  end;

  procedure InitCheckBoxListEditor(AParamNode: TManifestParamNode);
   var
    ds: TDataSet;
    keyNames: string;
    listNames: string;
    data: TStringList;
    field: TField;
  begin
    ds :=  App.Entities[AParamNode.EditorOptions.Values['EntityName']].
      GetView(AParamNode.EditorOptions.Values['EntityViewName'], WorkItem,
        'ParamLookupDataSet_' + AParamNode.Name).Load([]);

    data := TStringList.Create;
    try
      field := ds.FindField('NAME');
      if field = nil then
        field := ds.Fields[0];

      {listNames := AParamNode.EditorOptions.Values['ListFieldNames'];
      if keyNames = '' then keyNames := 'ID';
      if listNames = '' then listNames := 'NAME';}

      while not ds.Eof do
      begin
        data.Add(ds.Fields[field.Index].Value);
        ds.Next;
      end;
      View.InitParamEditor_CheckBoxList(AParamNode.Name, data);

    finally
      data.Free;
    end;
  end;

var
  I: integer;
  prmItem: TManifestParamNode;

begin

  View.InitLayoutEditor(REPORT_LAYOUT_PARAM, FLayoutDataSet);

  //Params
  for I := 0 to FReportCatalogItem.Manifest.ParamNodes.Count - 1 do
  begin
    prmItem := FReportCatalogItem.Manifest.ParamNodes[I];
    if not FParamDataSet.FindField(prmItem.Name).Visible then Continue;
    case prmItem.Editor of
      peDBList: InitLookupEditor(prmItem);

      peCheckBox: View.InitParamEditor_CheckBox(prmItem.Name);

      peCheckBoxList: InitCheckBoxListEditor(prmItem);

      peLookup: View.InitParamEditor_Lookup(prmItem.Name, prmItem.Values);

      pePickList: InitPickListEditor(prmItem);

    end;
  end
end;

function TReportLauncherPresenter.OnGetWorkItemState(
  const AName: string): Variant;
begin
  if Assigned(FParamDataSet) and FParamDataSet.Active and (FParamDataSet.FindField(AName) <> nil) then
    Result := FParamDataSet[AName];
end;

procedure TReportLauncherPresenter.CmdClose(Sender: TObject);
begin
  CloseView;
end;


procedure TReportLauncherPresenter.ParamValueChangeHandler(Sender: TField);
begin

end;

procedure TReportLauncherPresenter.OnReinit(Sender: IActivity);
begin
  Sender.Params.AssignTo(WorkItem);
  InitParamValues;
  ViewHidden := Sender.Params[TReportLaunchParams.LaunchMode] <> 0;

  if ViewHidden  then
    WorkItem.Commands[COMMAND_EXECUTE].Execute;
end;

procedure TReportLauncherPresenter.CmdPickListEditorExecute(Sender: TObject);
const
  DataInPrefix = 'DATAIN.';
  DataInPrefixLength = length(DataInPrefix);

  DataOutPrefix = 'DATAOUT.';
  DataOutPrefixLength = length(DataOutPrefix);

var
  I: integer;
  command: ICommand;
  paramName: string;
  paramNode: TManifestParamNode;

  actionName: string;
  action: IActivity;
  optionName: string;
  dataName: string;
  dataValueName: string;
begin
  Sender.GetInterface(ICommand, command);
  paramName := command.Data[COMMAND_DATA_PARAMNAME];
  command := nil;

  paramNode := FReportCatalogItem.Manifest.ParamNodes.Find(paramName);
  actionName := paramNode.EditorOptions.Values['Action'];

  action := WorkItem.Activities[actionName];

  for I := 0 to paramNode.EditorOptions.Count - 1 do
  begin
    optionName := paramNode.EditorOptions.Names[I];

    //DataIn
    if AnsiStartsText(DataInPrefix, optionName) then
    begin
      dataName := RightStr(optionName, length(optionName) - DataInPrefixLength);
      dataValueName := paramNode.EditorOptions.Values[optionName];

      action.Params.SetValue(dataName, WorkItem.State[dataValueName]);
    end;

  end;

  action.Execute(WorkItem);

  if action.Params[TViewActivityOuts.ModalResult] = mrOK then
    //DataOut
    for I := 0 to paramNode.EditorOptions.Count - 1 do
    begin
      optionName := paramNode.EditorOptions.Names[I];
      if AnsiStartsText(DataOutPrefix, optionName) then
      begin
        dataName := RightStr(optionName, length(optionName) - DataOutPrefixLength);
        dataValueName := paramNode.EditorOptions.Values[optionName];
        WorkItem.State[dataValueName] := action.Params.GetValue(dataName);
        {if VarIsArray(action.DataOut[dataName]) then
          WorkItem.State[dataValueName] := action.DataOut[dataName][0]
        else
          WorkItem.State[dataValueName] := action.DataOut[dataName];}
      end;
    end;

end;

procedure TReportLauncherPresenter.OnSetWorkItemState(const AName: string;
  const AValue: Variant);
var
  field: TField;
begin
  if FInitialized then
  begin
    FParamDataSet.Edit;
    field := FParamDataSet.FindField(AName);
    if Assigned(field) then
      field.Value := AValue;
    FParamDataSet.Post;
  end;
end;

end.
