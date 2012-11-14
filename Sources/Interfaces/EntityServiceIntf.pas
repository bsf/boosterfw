unit EntityServiceIntf;

interface
uses classes, db, dbclient, CoreClasses;

const
  CONST_PRIMARYKEY_NAME_DEFAULT = 'ID';

  //Event Topics
  ET_ENTITY_VIEW_OPEN_START = '{562D3153-2DD5-4FD8-BE15-8DC303FF25D8}';
  ET_ENTITY_VIEW_OPEN_FINISH = '{012994BE-31B4-42FD-98B6-386FF8B6A6EA}';

  FIELD_ATTR_BAND = 'Band';
  FIELD_ATTR_HIDDEN = 'Hidden';
  FIELD_ATTR_FIELDID = 'FieldID';
  FIELD_ATTR_REQUIRED = 'Required';

  FIELD_ATTR_BANDCOLLAPSED = 'BandCollapsed';

  FIELD_ATTR_STYLE_CONTENT = 'Style';
  FIELD_ATTR_STYLE_HEADER = 'Style.Header';

  FIELD_ATTR_EDITOR = 'Editor';
  FIELD_ATTR_EDITOR_COMMAND = 'Editor.Command';
  FIELD_ATTR_EDITOR_ACTION = 'Editor.Action';
  FIELD_ATTR_EDITOR_DATAIN = 'Editor.DataIn.';
  FIELD_ATTR_EDITOR_DATAOUT = 'Editor.DataOut.';

  FIELD_ATTR_EDITOR_ENTITY = 'Editor.Entity';
  FIELD_ATTR_EDITOR_EVIEW = 'Editor.EView';
  FIELD_ATTR_EDITOR_KEYFIELD = 'Editor.ID';
  FIELD_ATTR_EDITOR_NAMEFIELD = 'Editor.NAME';

  FIELD_ATTR_EDITOR_CHECKBOX_ALLOWGRAYED = 'Editor.AllowGrayed';

  FIELD_ATTR_EDITOR_CALC_AUTOPOPUP = 'Editor.AutoPopup';

  FIELD_ATTR_EDITOR_PICKLIST = 'PickList';
  FIELD_ATTR_EDITOR_LOOKUP = 'Lookup';
  FIELD_ATTR_EDITOR_COMBOBOX = 'ComboBox';
  FIELD_ATTR_EDITOR_CHECKBOX = 'CheckBox';
  FIELD_ATTR_EDITOR_IMAGE = 'Image';
  FIELD_ATTR_EDITOR_COLOR = 'Color';
  FIELD_ATTR_EDITOR_MEMO = 'Memo';
  FIELD_ATTR_EDITOR_CALC = 'Calc';
  FIELD_ATTR_EDITOR_DATETIME = 'DateTime';

  DATASET_ATTR_PRIMARYKEY = 'PrimaryKey';
  DATASET_ATTR_READONLY = 'ReadOnly';
  DATASET_ATTR_ENTITY = 'Entity';
  DATASET_ATTR_ENTITY_VIEW = 'EntityView';
  DATASET_ATTR_REFRESH_AFTER_UPDATE = 'RefreshAfterUpdate';

  //System field names
  FIELD_UI_TITLE = 'UI_TITLE';
  FIELD_UI_ROW_STYLE = 'UI_ROW_STYLE';
  FIELD_UI_STYLE_FMT = 'UI_%s_STYLE';
  FIELD_UI_ROW_READONLY = 'UI_ROW_READONLY';
  FIELD_UI_READONLY_FMT = 'UI_%s_READONLY';
  FIELD_UI_VISIBLE_FMT = 'UI_%s_VISIBLE';
  FIELD_UI_FIRST_FOCUS = 'UI_FIELD_FOCUS';

type
  TEntityViewLinkInfo = class
    EntityName: string;
    ViewName: string;
    FieldName: string;
  end;

  IEntityViewInfo = interface
  ['{19239A00-F141-4794-BF3E-2A0298C6981B}']
    function Title: string;
    function Fields: TFields;
    function PrimaryKey: string;
    function ReadOnly: boolean;
    function IsExec: boolean;
    function LinksCount: integer;
    function GetLinksInfo(AIndex: integer): TEntityViewLinkInfo;
    function LinkedFields: TStringList;
    function OptionExists(const AName: string): boolean;
    function GetOptions(const AName: string): string;
    property Options[const AName: string]: string read GetOptions;
  end;


  IEntityInfo = interface
  ['{92D6D592-F914-4870-BBC7-0FED51D128C4}']
    function SchemeName: string;
    function Fields: TFields;
    function GetViewInfo(const AViewName: string): IEntityViewInfo;
    function ViewExists(const AViewName: string): boolean;

    function GetOptions(const AName: string): string;
    procedure SetOptions(const AName, AValue: string);
    property Options[const AName: string]: string read GetOptions write SetOptions;

  end;

  IEntitySchemeInfo = interface
  ['{5B621325-516A-4EE0-8994-004FA55A5CEB}']
    function Fields: TFields;
  end;

  IEntityStorageInfo = interface
  ['{A97A209B-6AD6-4C11-B431-4844409B9AFA}']
  end;

  IEntityView = interface
  ['{202A5D1F-10B2-4372-A25F-436A0CB3DEFC}']
    function EntityName: string;
    function ViewName: string;
    function Title: string;
    function Params: TParams;
    function DataSet: TDataSet;
    function Load(AParams: array of variant): TDataSet; overload;
    function Load(AReload: boolean = true; AParamBindingRule: string = ''): TDataSet; overload;
    procedure ReloadRecord(APrimaryKeyValues: Variant;
      SyncRecord: boolean = false);
    procedure ReloadLinksData;
    procedure Save;
    procedure SetImmediateSave(Value: boolean);
    function GetImmediateSave: boolean;
    property ImmediateSave: boolean read GetImmediateSave write SetImmediateSave;
    procedure UndoLastChange;
    procedure CancelUpdates;
    procedure DoModify;
    function IsModified: boolean;
    function IsLoaded: boolean;
    function Info: IEntityViewInfo;

    procedure SynchronizeOnEntityChange(const AEntityName, AViewName: string;
      const AFieldName: string = '');

    //JSON
    function JSONLoad: string;
    procedure JSONInsert(const Data: string);
    procedure JSONUpdate(const Data: string);
    procedure JSONDelete(const Data: string);
  end;

  IEntityOper = interface
  ['{5A3002CD-ABFB-4328-96FA-A1B10E783DDF}']
    function EntityName: string;  
    function OperName: string;
    function Params: TParams;
    procedure ParamsBind(const ABindingRule: string = '');
    function ResultData: TDataSet;
    function Execute(AParams: array of variant): TDataSet; overload;
    function Execute: TDataSet; overload;    
    function Info: IEntityViewInfo;
  end;

  IEntity = interface
  ['{9104ED0A-E2E5-48F9-8005-C4757BF4E4DD}']
    function EntityName: string;
    function GetView(const AViewName: string; AWorkItem: TWorkItem;
      AInstanceID: string = ''): IEntityView;
    function GetOper(const AOperName: string; AWorkItem: TWorkItem;
      AInstanceID: string = ''): IEntityOper;
    function Info: IEntityInfo;
  end;

  IDataSetProxy = interface
  ['{DC5507EB-C88D-4E75-B962-FDEB5283F651}']
    function GetDataSet: TDataSet;
    function GetParams: TParams;
    function GetCommandText: string;
    procedure SetCommandText(const AValue: string);
    procedure SetMaster(ADataSource: TDataSource);
    function GetMaster: TDataSource;

    property DataSet: TDataSet read GetDataSet;
    property Params: TParams read GetParams;
    property Master: TDataSource read GetMaster write SetMaster;
    property CommandText: string read GetCommandText write SetCommandText;
  end;

  IEntityService = interface
  ['{E644CC6B-5ED0-4F55-9C20-9E2267381A0F}']
    function GetDataSetProxy(AOwner: TComponent): IDataSetProxy;
    function GetSchemeInfo(const ASchemeName: string): IEntitySchemeInfo;
    function EntityExists(const AEntityName: string): boolean;
    function EntityViewExists(const AEntityName, AEntityViewName: string): boolean;
    function GetEntity(const AEntityName: string): IEntity;
    property Entity[const AEntityName: string]: IEntity read GetEntity; default;

    procedure Connect(const AConnectionEngine, AConnectionParams: string);
    procedure Disconnect;
    procedure ClearMetadataCache;
  end;

function CheckFieldAttribute(AField: TField; const AttributeName: string): boolean;
function GetFieldAttribute(AField: TField; const AttributeName: string): string;
procedure GetFieldAttributeList(AField: TField; AList: TStrings);
procedure SetFieldAttribute(AField: TField; const AttributeName, AValue: string);
procedure SetFieldAttributeText(AField: TField; const AText: string; Append: boolean = true);
procedure CopyFieldAttribute(ASource: TField; ADest: TField);

function GetDataSetAttribute(ADataSet: TDataSet; const AttributeName: string): string;
procedure SetDataSetAttribute(ADataSet: TDataSet; const AttributeName, AValue: string);



implementation



type
  TFieldAttributes = class(TComponent)
  private
    FAttr: TStringList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TDataSetAttributes = class(TComponent)
  private
    FAttr: TStringList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TFieldAttributes }

constructor TFieldAttributes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAttr := TStringList.Create;
end;

destructor TFieldAttributes.Destroy;
begin
  FAttr.Free;
  inherited;
end;

function GetFieldAttr(AField: TField): TStringList;
const
  constAttrName = 'FieldAttributeContainer';
var
  attr: TComponent;
begin
  attr := AField.FindComponent(constAttrName);
  if not Assigned(attr) then
  begin
    attr := TFieldAttributes.Create(AField);
    attr.Name := constAttrName;
  end;

  Result := TFieldAttributes(attr).FAttr;
end;

function CheckFieldAttribute(AField: TField; const AttributeName: string): boolean;
begin
  Result := GetFieldAttr(AField).IndexOf(AttributeName) <> -1;
end;

function GetFieldAttribute(AField: TField; const AttributeName: string): string;
begin
  Result := GetFieldAttr(AField).Values[AttributeName];
end;

procedure GetFieldAttributeList(AField: TField; AList: TStrings);
begin
  AList.AddStrings(GetFieldAttr(AField));
end;

procedure SetFieldAttribute(AField: TField; const AttributeName, AValue: string);
begin
  GetFieldAttr(AField).Values[AttributeName] := AValue;
end;

procedure SetFieldAttributeText(AField: TField; const AText: string; Append: boolean);
var
  _list: TStringList;
begin
  _list := GetFieldAttr(AField);
  if not Append then _list.Clear;
  ExtractStrings([';'], [], PWideChar(AText), _list);
end;

procedure CopyFieldAttribute(ASource: TField; ADest: TField);
begin
  GetFieldAttr(ADest).AddStrings(GetFieldAttr(ASource));
end;


{ TDataSetAttributes }

constructor TDataSetAttributes.Create(AOwner: TComponent);
begin
  inherited;
  FAttr := TStringList.Create;
end;

destructor TDataSetAttributes.Destroy;
begin
  FAttr.Free;
  inherited;
end;

function GetDataSetAttr(ADataSet: TDataSet): TStringList;
const
  constAttrName = 'DataSetAttributeContainer';
var
  attr: TComponent;
begin
  attr := ADataSet.FindComponent(constAttrName);
  if not Assigned(attr) then
  begin
    attr := TDataSetAttributes.Create(ADataSet);
    attr.Name := constAttrName;
  end;

  Result := TDataSetAttributes(attr).FAttr;

end;

function GetDataSetAttribute(ADataSet: TDataSet; const AttributeName: string): string;
begin
  Result := GetDataSetAttr(ADataSet).Values[AttributeName];
end;

procedure SetDataSetAttribute(ADataSet: TDataSet; const AttributeName, AValue: string);
begin
  GetDataSetAttr(ADataSet).Values[AttributeName] := AValue;
end;



end.
