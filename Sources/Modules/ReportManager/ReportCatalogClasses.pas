unit ReportCatalogClasses;

interface
uses Classes, sysutils, ComObj, inifiles, windows, Contnrs, HashLists,Generics.Collections;

const
  cnstReportManifestFileName = 'ReportManifest.ini';

  TManifestParamEditorNames: array[0..10] of string =
    ('peNone', 'peString', 'peInteger', 'peDate', 'peFloat',
    'Lookup', 'List', 'peDBList', 'CheckBox', 'CheckBoxList', 'PickList');


type
  TManifestParamEditor = (peNone, peString, peInteger, peDate, peFloat,
    peLookup, peList, peDBList, peCheckBox, peCheckBoxList, pePickList);

  TManifestParamNode = class(TCollectionItem)
  private
    FName: string;
    FCaption: string;
    FEditor: TManifestParamEditor;
    FEditorOptions: TStrings;
    FValues: TStrings;
    FHint: string;
    FHidden: boolean;
    FDefaultValue: string;
    FRequired: boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;
    property Editor: TManifestParamEditor read FEditor write FEditor;
    property EditorOptions: TStrings read FEditorOptions;
    property Values: TStrings read FValues;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property Hint: string read FHint write FHint;
    property Hidden: boolean read FHidden write FHidden;
    property Required: boolean read FRequired write FRequired;
  end;

  TManifestParamNodes = class(TCollection)
  private
    function GetItem(AIndex: integer): TManifestParamNode;
    function InternalAdd(const AName: string): TManifestParamNode;
  public
    constructor Create;
    function Add(const AName: string): TManifestParamNode;
    function Find(const AName: string): TManifestParamNode;
    procedure Remove(const AName: string);
    property Items[AIndex: integer]: TManifestParamNode read GetItem; default;
  end;

  TReportLayout = class(TObject)
  private
    FTemplate: string;
    FCaption: string;
    FID: string;
  public
    constructor Create(const AID, ACaption, ATemplate: string);
    property ID: string read FID;
    property Caption: string read FCaption;
    property Template: string read FTemplate;
  end;


  TReportCatalogManifest = class(TComponent)
  const
    BASE_REPORT_LAYOUT_CAPTION = 'Основной макет';
  private
    FParamNodes: TManifestParamNodes;
    FLayouts: THashObjectList<TReportLayout>;

    FGroup: string;
    FCaption: string;
    FTemplate: string;
    FDescription: string;
    FExtendCommands: TStringList;
    FID: string;
    FIsTop: boolean;
//    FShowParamView: boolean;
    FImmediateRun: boolean;
    procedure LoadManifest(AManifest: TMemIniFile);
    procedure SaveManifest(AManifest: TMemIniFile);
    function GetExtendCommands: TStrings;
    procedure SetExtendCommands(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    property IsTop: boolean read FIsTop write FIsTop;
    property Group: string read FGroup write FGroup;
    property Caption: string read FCaption write FCaption;
    property Template: string read FTemplate write FTemplate;
    property Description: string read FDescription write FDescription;
    property ID: string read FID write FID;
//    property ShowParamView: boolean read FShowParamView write FShowParamView;
    property ImmediateRun: boolean read FImmediateRun write FImmediateRun;
    property ParamNodes: TManifestParamNodes read FParamNodes;
    property Layouts: THashObjectList<TReportLayout> read FLayouts;
    property ExtendCommands: TStrings read GetExtendCommands write SetExtendCommands;
  end;

  TReportCatalogGroup = class;

  TReportCatalogItem = class(TCollectionItem)
  private
    FName: string;
    FPath: string;
    FManifest: TReportCatalogManifest;
    FModified: boolean;
    FManifestLoaded: boolean;
    FLoadErrorCode: integer;
    FLoadErrorInfo: string;
    procedure LoadManifest;
    function GetCaption: string;
    function GetGroup: TReportCatalogGroup;
    function GetID: string;
    function GetManifest: TReportCatalogManifest;
    function GetIsTop: boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Save;
    property ID: string read GetID;
    property Path: string read FPath;
    property Name: string read FName;
    property Caption: string read GetCaption;
    property Group: TReportCatalogGroup read GetGroup;
    property IsTop: boolean read GetIsTop;
    property Manifest: TReportCatalogManifest read GetManifest;
    property Modified: boolean read FModified write FModified;
    property LoadErrorCode: integer read FLoadErrorCode;
    property LoadErrorInfo: string read FLoadErrorInfo;
  end;


  TReportCatalogItems = class(TCollection)
  private
    FGroup: TReportCatalogGroup;
    function GetItem(AIndex: integer): TReportCatalogItem;
    function InternalAdd(const AName: string): TReportCatalogItem;
    procedure Open(AGroup: TReportCatalogGroup);
  public
    constructor Create;
    function Add(const AName: string): TReportCatalogItem;
    function Find(const AName: string): TReportCatalogItem;
    procedure Delete(AIndex: integer);
    property Items[AIndex: integer]: TReportCatalogItem read GetItem; default;
  end;

  TReportCatalogGroup = class(TCollectionItem)
  private
    FName: string;
    FPath: string;
    FItems: TReportCatalogItems;
    procedure Open;
    function GetCaption: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property Name: string read FName;
    property Path: string read FPath;
    property Caption: string read GetCaption;
    property Items: TReportCatalogItems read FItems;
  end;

  TReportCatalogGroups = class(TCollection)
  private
    FCatalogPath: string;
    function GetItem(AIndex: integer): TReportCatalogGroup;
    function InternalAdd(const AName: string): TReportCatalogGroup;
    procedure Open(const ACatalogPath: string);
  public
    constructor Create;
    function Add(const AName: string): TReportCatalogGroup;
    function Find(const AName: string): TReportCatalogGroup;
    procedure Delete(AIndex: integer);
    property Items[AIndex: integer]: TReportCatalogGroup read GetItem; default;
  end;

  TReportCatalog = class(TComponent)
  private
    FCatalog: string;
    FGroups: TReportCatalogGroups;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open(const ACatalog: string);
    function FindItem(const AID: string): TReportCatalogItem;
    function GetItem(const AID: string): TReportCatalogItem;
    property Catalog: string read FCatalog;
    property Groups: TReportCatalogGroups read FGroups;
  end;


implementation

function  ParamEditorToString(AType: TManifestParamEditor): string;
begin
  Result := TManifestParamEditorNames[Ord(AType)];
end;


function  StringToParamEditor(const AType: string): TManifestParamEditor;
var
  I: integer;
begin
  Result := peNone;

  for I := 0 to High(TManifestParamEditorNames) do
   if SameText(AType, TManifestParamEditorNames[I]) then
   begin
     Result := TManifestParamEditor(I);
     Exit;
   end;

  Exception.Create('Bad param editor');
end;


procedure RemoveDirTree(const Dir: string);
var
  tfileinfo: TSearchRec;
  r: TFileName;
  retcode: longint;
  atribute: word;
begin
  r := Dir + '\*.*';

  retcode := FindFirst(r, faAnyFile - faVolumeID, tfileinfo);
  while retcode = 0 do
  begin
    if (tfileinfo.attr and faDirectory = faDirectory) then
    begin
      if (tfileinfo.name <> '.') and (tfileinfo.name <> '..') then
        RemoveDirTree(Dir + '\' + tfileinfo.name)
    end
    else
    begin
      atribute := tfileinfo.attr;
      atribute := atribute and not faReadOnly;
      atribute := atribute and not faArchive;
      atribute := atribute and not faSysFile;
      atribute := atribute and not faHidden;
      FileSetAttr(Dir + '\' + tfileinfo.name, atribute);
      if SysUtils.DeleteFile(Dir + '\' + tfileinfo.name) = false then
         writeln('Error deleting ', Dir + '\' + tfileinfo.name);
    end;
    retcode := FindNext(tfileinfo);
  end;
  SysUtils.FindClose(tfileinfo);
  atribute := FileGetAttr(Dir);
  atribute := atribute and not faReadOnly;
  atribute := atribute and not faArchive;
  atribute := atribute and not faSysFile;
  atribute := atribute and not faHidden;
  FileSetAttr(Dir, atribute);
  if RemoveDir(Dir) = false then
    writeln('Error removing ', Dir);

end;

{ TReportCatalog }

constructor TReportCatalog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGroups := TReportCatalogGroups.Create;
end;

destructor TReportCatalog.Destroy;
begin
  FGroups.Free;
  inherited;
end;

function TReportCatalog.FindItem(const AID: string): TReportCatalogItem;
var
  I, Y: integer;
begin
  for I := 0 to FGroups.Count - 1 do
    for Y := 0 to FGroups[I].Items.Count - 1 do
    begin
      Result := FGroups[I].Items[Y];
      if SameText(Result.ID, AID) then Exit;
    end;
  Result := nil;
end;

function TReportCatalog.GetItem(const AID: string): TReportCatalogItem;
begin
  Result := FindItem(AID);
  if Result = nil then
    raise Exception.CreateFmt('ReportCatalogItem %s not found', [AID]);
end;

procedure TReportCatalog.Open(const ACatalog: string);
begin
  if not DirectoryExists(ACatalog) then
    raise Exception.Create('Report Catalog: ' + ACatalog + ' not found.');
  FGroups.Clear;
  FCatalog := ACatalog;
  FGroups.Open(FCatalog);
end;

{ TReportCatalogGroups }

function TReportCatalogGroups.Add(const AName: string): TReportCatalogGroup;
begin
  if FCatalogPath = '' then
    raise Exception.Create('Report Catalog not open');

  Result := Find(AName);
  if Result = nil then
    Result := InternalAdd(AName);
end;

constructor TReportCatalogGroups.Create;
begin
  inherited Create(TReportCatalogGroup);
end;

procedure TReportCatalogGroups.Delete(AIndex: integer);
begin
  RemoveDirTree(GetItem(AIndex).Path);
  Delete(AIndex);
end;

function TReportCatalogGroups.Find(const AName: string): TReportCatalogGroup;
var
  I: integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := GetItem(I);
    if SameText(Result.Name, AName) then Exit;
  end;
  Result := nil;
end;

function TReportCatalogGroups.GetItem(AIndex: integer): TReportCatalogGroup;
begin
  Result := TReportCatalogGroup(inherited Items[AIndex]);
end;

function TReportCatalogGroups.InternalAdd(const AName: string): TReportCatalogGroup;
var
  groupPath: string;
begin
  groupPath := FCatalogPath + AName;
  if not DirectoryExists(groupPath) then
    CreateDir(groupPath);
  Result := TReportCatalogGroup(inherited Add);
  Result.FName := AName;
  Result.FPath := groupPath + '\';
  Result.Open;
end;


procedure TReportCatalogGroups.Open(const ACatalogPath: string);
var
  sr: TSearchRec;
  list: TStringList;
  I: integer;
begin
  FCatalogPath := ACatalogPath;

  list := TStringList.Create;
  try
    if SysUtils.FindFirst(FCatalogPath + '*.*' , faDirectory, sr) = 0 then
    begin
      repeat
        if (sr.Name = '.') or (sr.Name = '..') then Continue;
        if (sr.Attr and faDirectory) <> 0 then
          list.Add(sr.Name); //InternalAdd(sr.Name);
       until FindNext(sr) <> 0;
       SysUtils.FindClose(sr);
    end;

    list.Sort;
    for I := 0 to list.Count - 1 do
      InternalAdd(list[I]);
  finally
    list.Free;
  end;
end;

{ TReportCatalogGroup }

constructor TReportCatalogGroup.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FItems := TReportCatalogItems.Create;
end;

destructor TReportCatalogGroup.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TReportCatalogGroup.GetCaption: string;
begin
  Result := FName;
end;

procedure TReportCatalogGroup.Open;
begin
  FItems.Open(Self);
end;

{ TReportCatalogItems }

function TReportCatalogItems.Add(const AName: string): TReportCatalogItem;
begin
  Result := Find(AName);
  if Result = nil then
    Result := InternalAdd(AName);
end;

function TReportCatalogItems.Find(const AName: string): TReportCatalogItem;
var
  I: integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := GetItem(I);
    if SameText(Result.Name, AName) then Exit;
  end;
  Result := nil;
end;

function TReportCatalogItems.GetItem(AIndex: integer): TReportCatalogItem;
begin
  Result := TReportCatalogItem(inherited Items[AIndex]);
end;

procedure TReportCatalogItems.Open(AGroup: TReportCatalogGroup);
var
  sr: TSearchRec;
  list: TStringList;
  I: integer;
begin
  FGroup := AGroup;
  list := TStringList.Create;
  try
    if SysUtils.FindFirst(FGroup.Path + '*.*' , faDirectory, sr) = 0 then
    begin
      repeat
        if (sr.Name = '.') or (sr.Name = '..') then Continue;
        if (sr.Attr and faDirectory) <> 0 then
          list.Add(sr.Name); //InternalAdd(sr.Name);
       until SysUtils.FindNext(sr) <> 0;
       SysUtils.FindClose(sr);
    end;

    list.Sort;
    for I := 0 to list.Count - 1 do
      InternalAdd(list[I]);
  finally
    list.Free;
  end;
end;

function TReportCatalogItems.InternalAdd(const AName: string): TReportCatalogItem;
var
  itemPath: string;
begin
  itemPath := FGroup.Path + AName;
  if not DirectoryExists(itemPath) then
    CreateDir(itemPath);
  Result := TReportCatalogItem(inherited Add);
  Result.FName := AName;
  Result.FPath := itemPath + '\';
end;

procedure TReportCatalogItems.Delete(AIndex: integer);
begin
  RemoveDirTree(GetItem(AIndex).Path);
  inherited Delete(AIndex);
end;

constructor TReportCatalogItems.Create;
begin
  inherited Create(TReportCatalogItem);
end;

{ TReportCatalogItem }

constructor TReportCatalogItem.Create(Collection: TCollection);
begin
  inherited;
  FManifest := TReportCatalogManifest.Create(nil);
  FManifestLoaded := false;
end;

destructor TReportCatalogItem.Destroy;
begin
  FManifest.Free;
  inherited;
end;


function TReportCatalogItem.GetCaption: string;
begin
  Result := FName;
end;

function TReportCatalogItem.GetGroup: TReportCatalogGroup;
begin
  Result := TReportCatalogItems(Self.Collection).FGroup;
end;

function TReportCatalogItem.GetID: string;
begin
  Result := GetManifest.ID;
  if Result = '' then
    Result := FPath + FName;
end;

function TReportCatalogItem.GetIsTop: boolean;
begin
  Result := GetManifest.IsTop;
end;

function TReportCatalogItem.GetManifest: TReportCatalogManifest;
begin
  if not FManifestLoaded then
    LoadManifest;
  Result := FManifest;
end;

procedure TReportCatalogItem.LoadManifest;
begin
  try
    FManifest.LoadFromFile(FPath + cnstReportManifestFileName);
    FManifestLoaded := true;
  except
    on E: Exception do
    begin
      FLoadErrorCode := 1;
      FLoadErrorInfo := E.Message;
    end;
  end;
end;

procedure TReportCatalogItem.Save;
begin
  FManifest.SaveToFile(FPath + cnstReportManifestFileName);
end;

{ TReportCatalogManifest }

constructor TReportCatalogManifest.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParamNodes := TManifestParamNodes.Create;
  FExtendCommands := TStringList.Create;
  FLayouts := THashObjectList<TReportLayout>.Create(Self);
end;

destructor TReportCatalogManifest.Destroy;
begin
  FParamNodes.Free;
  FExtendCommands.Free;
  inherited;
end;

function TReportCatalogManifest.GetExtendCommands: TStrings;
begin
  Result := FExtendCommands;
end;

procedure TReportCatalogManifest.LoadFromFile(const AFileName: string);
var
  fileManifest: TMemIniFile;
begin
  fileManifest := TMemIniFile.Create(AFileName);
  try
    LoadManifest(fileManifest);
  finally
    fileManifest.Free;
  end;
end;

procedure TReportCatalogManifest.LoadManifest(AManifest: TMemIniFile);
  procedure GetSectionList(const SectionName: string; AList: TStrings);
  var
    I: integer;
    check: string;
  begin
    AList.Clear;
    AManifest.ReadSections(AList);
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
  paramItem: TManifestParamNode;
  layout: TReportLayout;
begin
  Sections := TStringList.Create;

  {Common}
  FID := AManifest.ReadString('Common', 'ID', '');
  FIsTop := AManifest.ReadBool('Common', 'IsTop', true);
  FGroup := AManifest.ReadString('Common', 'Group', '');
  FCaption := AManifest.ReadString('Common', 'Caption', '');
  FTemplate := AManifest.ReadString('Common', 'Template', '');
  FImmediateRun := AManifest.ReadBool('Common', 'ImmediateRun', false);
  FDescription := AManifest.ReadString('Common', 'Description', '');

  {Params}
  FParamNodes.Clear;
  GetSectionList('Param.', Sections);
  for I := 0 to Sections.Count - 1 do
  begin
    nameID := StringReplace(Sections[I], 'Param.', '', []);
    paramItem := FParamNodes.Add(nameID);
    paramItem.Caption := AManifest.ReadString(Sections[I], 'Caption', '');
    paramItem.Editor := StringToParamEditor(
      AManifest.ReadString(Sections[I], 'Editor', 'peNone'));
    paramItem.Hint := AManifest.ReadString(Sections[I], 'Hint', '');
    paramItem.Hidden := AManifest.ReadBool(Sections[I], 'Hidden', false);
    paramItem.Required := AManifest.ReadBool(Sections[I], 'Required', true);
    paramItem.DefaultValue := AManifest.ReadString(Sections[I], 'DefaultValue', '');

    {ExtractStrings([';'], [],
      PChar(AManifest.ReadString(Sections[I], 'EditorOptions', '')), paramItem.EditorOptions);}
    AManifest.ReadSectionValues(Sections[I] + '.EditorOptions', paramItem.EditorOptions);
    AManifest.ReadSectionValues(Sections[I] + '.Values', paramItem.Values);
  end;

  {ExtendCommands}
  FExtendCommands.Clear;
  AManifest.ReadSectionValues('ExtendCommands', FExtendCommands);

  FLayouts.Clear;

  FLayouts.Add(FID, TReportLayout.Create(FID, BASE_REPORT_LAYOUT_CAPTION, FTemplate));

  GetSectionList('Layout.', Sections);
  for i := 0 to Sections.Count - 1 do
  begin
    nameID := StringReplace(Sections[I], 'Layout.', '', []);
    FLayouts.Add(FID + '.' + nameID, TReportLayout.Create(FID + '.' + nameID,
      AManifest.ReadString(Sections[I], 'Caption', nameID),
      AManifest.ReadString(Sections[I], 'Template', FTemplate)));
  end;

  Sections.Free;


end;

procedure TReportCatalogManifest.SaveManifest(AManifest: TMemIniFile);
begin
  AManifest.WriteString('Common', 'Group', FGroup);
  AManifest.WriteString('Common', 'Caption', FCaption);
  AManifest.WriteString('Common', 'Template', FTemplate);
  AManifest.WriteString('Common', 'Description', FDescription);
end;

procedure TReportCatalogManifest.SaveToFile(const AFileName: string);
var
  fileManifest: TMemIniFile;
begin
  fileManifest := TMemIniFile.Create(AFileName);
  try
    SaveManifest(fileManifest);
    fileManifest.UpdateFile;
  finally
    fileManifest.Free;
  end;
end;


procedure TReportCatalogManifest.SetExtendCommands(const Value: TStrings);
begin
  FExtendCommands.Clear;
  FExtendCommands.AddStrings(Value);
end;

{ TManifestParamNodes }

function TManifestParamNodes.Add(const AName: string): TManifestParamNode;
begin
  Result := Find(AName);
  if Result = nil then
    Result := InternalAdd(AName);
end;

constructor TManifestParamNodes.Create;
begin
  inherited Create(TManifestParamNode);
end;


function TManifestParamNodes.Find(const AName: string): TManifestParamNode;
var
  I: integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := GetItem(I);
    if SameText(Result.Name, AName) then Exit;
  end;
  Result := nil;
end;

function TManifestParamNodes.GetItem(
  AIndex: integer): TManifestParamNode;
begin
  Result := TManifestParamNode(inherited Items[AIndex]);
end;

function TManifestParamNodes.InternalAdd(const AName: string): TManifestParamNode;
begin
  Result := TManifestParamNode(inherited Add);
  Result.Name := AName;
end;

procedure TManifestParamNodes.Remove(const AName: string);
var
  item: TManifestParamNode;
begin
  item := Find(AName);
  if item <> nil then
    Delete(item.Index);
end;

{ TManifestParamNode }

constructor TManifestParamNode.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEditorOptions := TStringList.Create;
  FValues := TStringList.Create;
end;

destructor TManifestParamNode.Destroy;
begin
  FValues.Free;
  FEditorOptions.Free;
  inherited;
end;


{ TReportLayout }

constructor TReportLayout.Create(const AID, ACaption, ATemplate: string);
begin
  FID := AID;
  FCaption := ACaption;
  FTemplate := ATemplate;
end;

end.
