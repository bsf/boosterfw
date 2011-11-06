unit xlReportMetadata;

interface
uses classes, Inifiles, Contnrs, SysUtils;

type

  TpfwXLReportDataSourceMetadata = class(TComponent)
  private
    FDataSourceName: string;
    FRange: string;
    FCommandText: TStringList;
    FCrossColumnsCommandText: TStringList;
    FCrossDataCommandText: TStringList;
    FMacroBefore: string;
    FMacroAfter: string;
    FMasterSource: string;
    FIsCross: boolean;
    FKeyField: string;
    FCrossDataRowKeyField: string;
    FCrossDataColKeyField: string;
    FCrossColumnsKeyField: string;
    FCrossColumnsDataFieldName: string;
    FShowCrossEmptyRow: boolean;
    function GetCommandText: TStrings;
    function GetCrossDataCommandText: TStrings;
    function GetCrossColumnsCommandText: TStrings;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DataSourceName: string read FDataSourceName write FDataSourceName;
    property Range: string read FRange write FRange;
    property MacroBefore: string read FMacroBefore write FMacroBefore;
    property MacroAfter: string read FMacroAfter write FMacroAfter;
    property MasterSource: string read FMasterSource write FMasterSource;
    property CommandText: TStrings read GetCommandText;
    property KeyField: string read FKeyField write FKeyField;
    property IsCross: boolean read FIsCross write FIsCross;
    property ShowCrossEmptyRow: boolean read FShowCrossEmptyRow write FShowCrossEmptyRow;
    property CrossDataRowKeyField: string read FCrossDataRowKeyField
      write FCrossDataRowKeyField;
    property CrossDataColKeyField: string read FCrossDataColKeyField
      write FCrossDataColKeyField;
    property CrossColumnsKeyField: string read FCrossColumnsKeyField
      write FCrossColumnsKeyField;
    property CrossColumnsDataFieldName: string read FCrossColumnsDataFieldName
      write FCrossColumnsDataFieldName;
    property CrossDataCommandText: TStrings read GetCrossDataCommandText;
    property CrossColumnsCommandText: TStrings read GetCrossColumnsCommandText;
  end;

  TpfwXLReportDataSourcesMetadata = class(TComponent)
  private
    FItems: TComponentList;
    function Find(const AName: string): integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Count: integer;
    function Add(const AName: string): integer;
    procedure Remove(const AName: string);
    procedure Delete(AIndex: integer);
    procedure Clear;
    function GetByName(const AName: string): TpfwXLReportDataSourceMetadata;
    function Get(AIndex: integer): TpfwXLReportDataSourceMetadata;
    property Items[AIndex: integer]: TpfwXLReportDataSourceMetadata
      read Get; default;
  end;

  TpfwXLReportParamMetadata = class(TCollectionItem)
  private
    FValue: Variant;
    FParamName: string;
  public
    property Value: Variant read FValue write FValue;
    property ParamName: string read FParamName write FParamName;
  end;

  TpfwXLReportParamsMetadata = class(TCollection)
  private
    function GetItem(AIndex: integer): TpfwXLReportParamMetadata;
  public
    procedure AddParam(const AName: string);
    property Items[AIndex: integer]: TpfwXLReportParamMetadata read GetItem; default;
  end;

  TpfwXLReportMetadata = class(TComponent)
  private
    //Common properties
    FXLSTemplate: string;
    FDataSources: TpfwXLReportDataSourcesMetadata;
    FParams: TpfwXLReportParamsMetadata;
    FActiveSheet: string;
    FMacroBefore: string;
    FMacroAfter: string;
    function GetDataSources: TpfwXLReportDataSourcesMetadata;
    function GetParams: TpfwXLReportParamsMetadata;
    //
    procedure LoadMetadata(AMetadata: TMemIniFile);
    procedure SaveMetadata(AMetadata: TMemIniFile);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    property ActiveSheet: string read FActiveSheet write FActiveSheet;
    property MacroBefore: string read FMacroBefore write FMacroBefore;
    property MacroAfter: string read FMacroAfter write FMacroAfter;
    property XLSTemplate: string read FXLSTemplate write FXLSTemplate;
    property DataSources: TpfwXLReportDataSourcesMetadata read GetDataSources;
    property Params: TpfwXLReportParamsMetadata read GetParams;
  end;

implementation

{ TpfwXLReportMetadata }

constructor TpfwXLReportMetadata.Create(AOwner: TComponent);
begin
  inherited;
  FDataSources := TpfwXLReportDataSourcesMetadata.Create(Self);
  FParams := TpfwXLReportParamsMetadata.Create(TpfwXLReportParamMetadata);
end;

destructor TpfwXLReportMetadata.Destroy;
begin
  inherited;
end;

function TpfwXLReportMetadata.GetDataSources: TpfwXLReportDataSourcesMetadata;
begin
  Result := FDataSources;
end;

function TpfwXLReportMetadata.GetParams: TpfwXLReportParamsMetadata;
begin
  Result := FParams;
end;

procedure TpfwXLReportMetadata.LoadFromFile(const AFileName: string);
var
  fileMetadata: TMemIniFile;
begin
  fileMetadata := TMemIniFile.Create(AFileName);
  try
    LoadMetadata(fileMetadata);
  finally
    fileMetadata.Free;
  end;
end;

procedure TpfwXLReportMetadata.LoadMetadata(AMetadata: TMemIniFile);

  procedure GetSectionList(const SectionName: string; AList: TStrings);
  var
    I: integer;
    check: string;
  begin
    AList.Clear;
    AMetadata.ReadSections(AList);
    for I := AList.Count - 1 downto 0 do
    begin
      if Pos(SectionName, AList[I]) = 1 then
      begin
        check := StringReplace(AList[I], SectionName, '', []);
        if Pos('.', check) > 0 then AList.Delete(I);
      end
      else
        AList.Delete(I);

    end;
  end;

var
  I: integer;
  Sections: TStringList;
  nameID: string;
  Idx: integer;
begin
  Sections := TStringList.Create;

  {Common}
  FActiveSheet := AMetadata.ReadString('Common', 'ActiveSheet', '');
  FMacroBefore := AMetadata.ReadString('Common', 'MacroBefore', '');
  FMacroAfter := AMetadata.ReadString('Common', 'MacroAfter', '');
  FXLSTemplate := AMetadata.ReadString('Common', 'XLSTemplate', '');

  {DataSource}
  FDataSources.Clear;
  GetSectionList('DataSource.', Sections);
  for I := 0 to Sections.Count - 1 do
  begin
    nameID := StringReplace(Sections[I], 'DataSource.', '', []);
    Idx := FDataSources.Add(nameID);

    FDataSources[Idx].Range := AMetadata.ReadString(Sections[I], 'Range', '');
    FDataSources[Idx].MacroBefore := AMetadata.ReadString(Sections[I], 'MacroBefore', '');
    FDataSources[Idx].MacroAfter := AMetadata.ReadString(Sections[I], 'MacroAfter', '');
    FDataSources[Idx].MasterSource := AMetadata.ReadString(Sections[I], 'MasterSource', '');    
    FDataSources[Idx].IsCross := AMetadata.ReadString(Sections[I], 'IsCross', '0') = '1';
    FDataSources[Idx].ShowCrossEmptyRow := AMetadata.ReadString(Sections[I], 'ShowCrossEmptyRow', '0') = '1';
    FDataSources[Idx].KeyField := AMetadata.ReadString(Sections[I], 'KeyField', '');

    FDataSources[Idx].CrossColumnsKeyField :=
      AMetadata.ReadString(Sections[I] + '.CrossColumns', 'KeyField', '');

    FDataSources[Idx].CrossColumnsDataFieldName :=
      AMetadata.ReadString(Sections[I] + '.CrossColumns', 'DataFieldName', '');

    FDataSources[Idx].CrossDataRowKeyField :=
      AMetadata.ReadString(Sections[I] + '.CrossData', 'RowKeyField', '');

    FDataSources[Idx].CrossDataColKeyField :=
      AMetadata.ReadString(Sections[I] + '.CrossData', 'ColKeyField', '');

    AMetadata.ReadSectionValues(Sections[I] + '.Command', FDataSources[Idx].CommandText);
    AMetadata.ReadSectionValues(Sections[I] + '.CrossData.Command',
      FDataSources[Idx].CrossDataCommandText);
    AMetadata.ReadSectionValues(Sections[I] + '.CrossColumns.Command',
      FDataSources[Idx].CrossColumnsCommandText);

  end;

  {Params}
  FParams.Clear;
  GetSectionList('Param.', Sections);
  for I := 0 to Sections.Count - 1 do
  begin
    nameID := StringReplace(Sections[I], 'Param.', '', []);
    FParams.AddParam(nameID);
  end;

  Sections.Free;
end;

procedure TpfwXLReportMetadata.SaveMetadata(AMetadata: TMemIniFile);
begin
  AMetadata.WriteString('Common', 'XLSTemplate', FXLSTemplate);
end;

procedure TpfwXLReportMetadata.SaveToFile(const AFileName: string);
var
  fileMetadata: TMemIniFile;
begin
  fileMetadata := TMemIniFile.Create(AFileName);
  try
    SaveMetadata(fileMetadata);
    fileMetadata.UpdateFile;
  finally
    fileMetadata.Free;
  end;
end;



{ TpfwXLReportDataSourcesMetadata }

function TpfwXLReportDataSourcesMetadata.Add(const AName: string): integer;
begin
  if Find(AName) <> -1 then
    raise Exception.Create('Duplicate datasource name');

  Result := FItems.Add(TpfwXLReportDataSourceMetadata.Create(nil));
  Get(Result).DataSourceName := AName;
end;

procedure TpfwXLReportDataSourcesMetadata.Clear;
begin
  FItems.Clear;
end;

function TpfwXLReportDataSourcesMetadata.Count: integer;
begin
  Result := FItems.Count;
end;

constructor TpfwXLReportDataSourcesMetadata.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TComponentList.Create(true);
end;

procedure TpfwXLReportDataSourcesMetadata.Delete(AIndex: integer);
begin
  FItems.Delete(AIndex);
end;

destructor TpfwXLReportDataSourcesMetadata.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TpfwXLReportDataSourcesMetadata.Find(const AName: string): integer;
begin
  for Result := 0 to FItems.Count - 1 do
    if SameText(
      TpfwXLReportDataSourceMetadata(FItems[Result]).DataSourceName, AName) then Exit;
  Result := -1;
end;

function TpfwXLReportDataSourcesMetadata.Get(
  AIndex: integer): TpfwXLReportDataSourceMetadata;
begin
  Result := TpfwXLReportDataSourceMetadata(FItems[AIndex]);
end;

function TpfwXLReportDataSourcesMetadata.GetByName(
  const AName: string): TpfwXLReportDataSourceMetadata;
var
  Idx: integer;
begin
  Idx := Find(AName);
  if Idx = -1 then
    raise Exception.Create('DataSource not found');

  Result := Get(Idx);
end;

procedure TpfwXLReportDataSourcesMetadata.Remove(const AName: string);
var
  Idx: integer;
begin
  Idx := Find(AName);
  if Idx <> - 1 then
    Delete(Idx);
end;

{ TpfwXLReportDataSourceMetadata }

constructor TpfwXLReportDataSourceMetadata.Create(AOwner: TComponent);
begin
  inherited;
  FCommandText := TStringList.Create;
  FCrossColumnsCommandText := TStringList.Create;
  FCrossDataCommandText := TStringList.Create;
end;

destructor TpfwXLReportDataSourceMetadata.Destroy;
begin
  FCommandText.Free;
  FCrossColumnsCommandText.Free; 
  FCrossDataCommandText.Free;
  inherited;
end;

function TpfwXLReportDataSourceMetadata.GetCommandText: TStrings;
begin
  Result := FCommandText;
end;


function TpfwXLReportDataSourceMetadata.GetCrossColumnsCommandText: TStrings;
begin
  Result := FCrossColumnsCommandText;
end;

function TpfwXLReportDataSourceMetadata.GetCrossDataCommandText: TStrings;
begin
  Result := FCrossDataCommandText;
end;

{ TpfwXLReportParamsMetadata }

procedure TpfwXLReportParamsMetadata.AddParam(const AName: string);
begin
  TpfwXLReportParamMetadata(Self.Add).ParamName := AName;
end;

function TpfwXLReportParamsMetadata.GetItem(AIndex: integer): TpfwXLReportParamMetadata;
begin
  Result := TpfwXLReportParamMetadata(inherited Items[AIndex]);
end;

end.
