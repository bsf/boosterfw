unit ReportLauncherPresenter;

interface
uses classes, CoreClasses, CustomPresenter, ShellIntf, CommonViewIntf, SysUtils,
  dxmdaset, db, ReportCatalogClasses, EntityServiceIntf, ViewServiceIntf,
  variants, StrUtils, controls, ReportCatalogConst, CommonUtils,
  cxDateUtils;

const
  COMMAND_EXECUTE = '{1D84C651-1B31-4F77-87BF-86A00AC0232B}';
  COMMAND_CLOSE = '{4744CD2A-2140-4507-8D75-79CD70FEE9BF}';

  COMMAND_DATA_PARAMNAME = 'ParamName';
  COMMAND_PARAM_CHANGED = 'commands.paramchanged.';

type

  IReportLauncherView = interface(ICustomView)
  ['{52F4B023-C2FC-47E6-BF67-576C28683977}']
    procedure LinkParamDataSet(const ADataSet: TDataSet);
    procedure InitParamEditor_DBLookup(const AParamName: string; ADataSet: TDataSet;
      const AKeyFieldName, AListFieldName: string);
    procedure InitParamEditor_CheckBox(const AParamName: string);
    procedure InitParamEditor_Lookup(const AParamName: string; AItems: TStrings);
    procedure InitParamEditor_ButtonEdit(const AParamName, ACommanName: string);
  end;

  TReportLauncherPresenterData = class(TPresenterData)
  private
    FReportURI: string;
    FImmediateRun: variant;
  public
    procedure AssignLaunchData(AData: TReportLaunchData);
  published
    property ImmediateRun: variant read FImmediateRun write FImmediateRun;
    property ReportURI: string read FReportURI write FReportURI;
  end;

  TReportLauncherPresenter = class(TCustomPresenter)
  private
    FParamDataSet: TdxMemData;
    FReportCatalogItem: TReportCatalogItem;
    procedure InitParamDataSet;
    procedure InitViewParamEditors;
    procedure InitParamDefaultValues;
    procedure InitParamValues;
    procedure ParamValueChangeHandler(Sender: TField);

    procedure CmdPickListEditorExecute(Sender: TObject);

    procedure CmdExecute(Sender: TObject);
    procedure CmdClose(Sender: TObject);

  protected
    //TAbstractController
    function OnGetWorkItemState(const AName: string): Variant; override;
    procedure OnSetWorkItemState(const AName: string; const AValue: Variant); override;

    //
    function View: IReportLauncherView;
    procedure OnInit(Sender: IAction); override;
    procedure OnReinit(Sender: IAction); override;

    procedure OnViewReady; override;
    procedure OnViewShow; override;
  public
    class function ExecuteDataClass: TActionDataClass; override;
  end;

implementation

{ TReportLauncherPresenter }

procedure TReportLauncherPresenter.CmdExecute(Sender: TObject);
var
  doClose: boolean;
  reportID: string;
begin

  doClose := not IsControlKeyDown;

  if FParamDataSet.State in [dsEdit] then FParamDataSet.Post;

  App.Views.MessageBox.StatusBarMessage('Формирование отчета: ' + FReportCatalogItem.Caption);
  try
    App.Reports[FReportCatalogItem.ID].Execute(WorkItem);
  finally
    App.Views.MessageBox.StatusBarMessage('Готово');
  end;

  reportID := FReportCatalogItem.ID;

  if doClose then CloseView(false);


end;

procedure TReportLauncherPresenter.OnInit(Sender: IAction);
begin
  FreeOnViewClose := false;

  if WorkItem.Context = WorkItem.ID then
    WorkItem.Context := '';

  FReportCatalogItem :=
   (WorkItem.Services[IReportCatalogService] as IReportCatalogService).
      GetItem(WorkItem.State['ReportURI']);


  if VarIsEmpty(WorkItem.State['ImmediateRun']) and
     FReportCatalogItem.Manifest.ImmediateRun  then
    WorkItem.State['ImmediateRun'] := '1';

  ViewHidden := (not VarIsEmpty(WorkItem.State['ImmediateRun']))
    and (VarToStr(WorkItem.State['ImmediateRun']) <> '0');

  FParamDataSet := TdxMemData.Create(Self);

  ViewTitle := FReportCatalogItem.Caption;

  InitParamDataSet;
  InitParamDefaultValues;
  InitParamValues;
end;

procedure TReportLauncherPresenter.OnViewShow;
begin
 // InitParamValues;

  GetView.FocusDataSetControl(FParamDataSet);
end;

procedure TReportLauncherPresenter.OnViewReady;
begin
  View.LinkParamDataSet(FParamDataSet);
  InitViewParamEditors;

  View.CommandBar.AddCommand(COMMAND_EXECUTE, 'Выполнить', '', CmdExecute);
  View.CommandBar.AddCommand(COMMAND_CLOSE, 'Отмена', '', CmdClose);

  WorkItem.Commands[COMMAND_EXECUTE].SetHandler(CmdExecute);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

  if ViewHidden then
    WorkItem.Commands[COMMAND_EXECUTE].Execute;
end;

procedure TReportLauncherPresenter.InitParamDataSet;
  procedure CreateField(AParam: TManifestParamNode);
  var
    prmField: TField;
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
  end;

  procedure CreateReportLayoutsField;
  var
    field: TStringField;
  begin
    field := TStringField.Create(Self);
    TStringField(Field).DisplayWidth := 255;
    TStringField(Field).Size := 255;
    field.DisplayLabel := 'Макет';
    field.FieldName := 'ReportLayout';
    field.DataSet := FParamDataSet;
  end;

var
  I: integer;
begin

  if FReportCatalogItem.Manifest.Layouts.Count > 1 then
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
  mParam: TManifestParamNode;
  Val: Variant;
begin
  FParamDataSet.Edit;
  for I := 0 to FReportCatalogItem.Manifest.ParamNodes.Count - 1 do
  begin
    mParam := FReportCatalogItem.Manifest.ParamNodes[I];
    field := FParamDataSet.FieldByName(mParam.Name);

    Val := WorkItem.State['Init.' + mParam.Name];

    if not VarIsEmpty(Val) then
    begin
      if VarIsStr(Val) and (VarToStr(Val) = '') then
        field.Value := null
      else
        field.Value := Val;
    end;
  end;

  FParamDataSet.Post;

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

var
  I: integer;
  prmItem: TManifestParamNode;

begin
  for I := 0 to FReportCatalogItem.Manifest.ParamNodes.Count - 1 do
  begin
    prmItem := FReportCatalogItem.Manifest.ParamNodes[I];
    case prmItem.Editor of
      peDBList: InitLookupEditor(prmItem);

      peCheckBox: View.InitParamEditor_CheckBox(prmItem.Name);

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

procedure TReportLauncherPresenter.OnReinit(Sender: IAction);
begin
  Sender.Data.AssignTo(WorkItem);
  InitParamValues;
  ViewHidden := not VarIsEmpty(WorkItem.State['ImmediateRun'])
   and (VarToStr(WorkItem.State['ImmediateRun']) <> '0');
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
  action: IAction;
  optionName: string;
  dataName: string;
  dataValueName: string;
begin
  Sender.GetInterface(ICommand, command);
  paramName := command.Data[COMMAND_DATA_PARAMNAME];
  command := nil;

  paramNode := FReportCatalogItem.Manifest.ParamNodes.Find(paramName);
  actionName := paramNode.EditorOptions.Values['Action'];

  action := WorkItem.Actions[actionName];

  for I := 0 to paramNode.EditorOptions.Count - 1 do
  begin
    optionName := paramNode.EditorOptions.Names[I];

    //DataIn
    if AnsiStartsText(DataInPrefix, optionName) then
    begin
      dataName := RightStr(optionName, length(optionName) - DataInPrefixLength);
      dataValueName := paramNode.EditorOptions.Values[optionName];

      action.Data.SetValue(dataName, WorkItem.State[dataValueName]);
    end;

  end;

  action.Execute(WorkItem);

  if (action.Data as TPresenterData).ModalResult = mrOK then
    //DataOut
    for I := 0 to paramNode.EditorOptions.Count - 1 do
    begin
      optionName := paramNode.EditorOptions.Names[I];
      if AnsiStartsText(DataOutPrefix, optionName) then
      begin
        dataName := RightStr(optionName, length(optionName) - DataOutPrefixLength);
        dataValueName := paramNode.EditorOptions.Values[optionName];
        WorkItem.State[dataValueName] := action.Data.GetValue(dataName);
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
  if Self.Initialized then
  begin
    FParamDataSet.Edit;
    field := FParamDataSet.FindField(AName);
    if Assigned(field) then
      field.Value := AValue;
    FParamDataSet.Post;
  end;
end;

class function TReportLauncherPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := TReportLauncherPresenterData;
end;

{ TReportLauncherPresenterData }
procedure TReportLauncherPresenterData.AssignLaunchData(
  AData: TReportLaunchData);
var
  I: integer;
  valName: string;
begin
  for I := 0 to AData.Count - 1 do
  begin
    valName := 'Init.' + AData.ValueName(I);
    Add(valName);
    SetValue(valName, AData.GetValue(AData.ValueName(I)));
  end;
end;

end.
