unit UIClasses;

interface
uses classes, db, CoreClasses, sysutils, controls, ShellIntf,
  Contnrs, forms, variants;

const
  COMMAND_CLOSE = 'commands.view.close';
  //COMMAND_CLOSE_CAPTION = 'Закрыть';
  COMMAND_CLOSE_SHORTCUT = 'Ctrl+W';

  COMMAND_SAVE = 'commands.view.save';
 // COMMAND_SAVE_CAPTION = 'Сохранить';
  COMMAND_SAVE_SHORTCUT = 'Ctrl+S;Shift+Enter';

  COMMAND_OK = 'commands.view.ok';
//  COMMAND_OK_CAPTION = 'OK';
  COMMAND_OK_SHORTCUT = 'Enter';

  COMMAND_CANCEL = 'commands.view.cancel';
//  COMMAND_CANCEL_CAPTION = 'Отмена';
  COMMAND_CANCEL_SHORTCUT = 'Ctrl+W';

 // COMMAND_NEXT = 'commands.view.next';
 // COMMAND_NEXT_CAPTION = 'Далее';

  COMMAND_RELOAD = 'commands.view.reload';
//  COMMAND_RELOAD_CAPTION = 'Обновить';
  COMMAND_RELOAD_SHORTCUT = 'F5';

  COMMAND_RELOAD_CALLER = 'commands.reload.caller';

  COMMAND_OPEN = 'commands.view.open';
// COMMAND_OPEN_CAPTION = 'Открыть';
  COMMAND_OPEN_SHORTCUT = 'Ctrl+Enter';

  COMMAND_NEW = 'commands.view.new';
 // COMMAND_NEW_CAPTION = 'Добавить';
  COMMAND_NEW_SHORTCUT = 'Ins';

  COMMAND_DELETE = 'commands.view.del';
 // COMMAND_DELETE_CAPTION = 'Удалить';
  COMMAND_DELETE_SHORTCUT = 'Ctrl+Del';

  COMMAND_DETAIL_OPEN = 'commands.view.detail.open';
//  COMMAND_DETAIL_OPEN_CAPTION = 'Открыть запись';
  COMMAND_DETAIL_OPEN_SHORTCUT = 'Ctrl+Enter';

  COMMAND_DETAIL_NEW = 'commands.view.detail.new';
//  COMMAND_DETAIL_NEW_CAPTION = 'Добавить запись';
  COMMAND_DETAIL_NEW_SHORTCUT = 'Ins';

  COMMAND_DETAIL_DELETE = 'commands.view.detail.del';
//  COMMAND_DETAIL_DELETE_CAPTION = 'Удалить запись';
  COMMAND_DETAIL_DELETE_SHORTCUT = 'Ctrl+Del';

  COMMAND_STATE_CHANGE_NEXT = 'commands.view.statechange.next';
 // COMMAND_STATE_CHANGE_NEXT_CAPTION = 'Следующее состояние';

  COMMAND_STATE_CHANGE_PREV = 'commands.view.statechange.prev';
 // COMMAND_STATE_CHANGE_PREV_CAPTION = 'Предыдущее состояние';

//UI EVENTS
  ON_DBLCLICK = 'on.dblclick';
  ON_DETAIL_DBLCLICK = 'on.Detail.DblClick';

  COMMAND_UPDATE_COMMAND_STATUS = '{0FF76DEB-19F3-45E4-8AA7-CE915687C335}';
type

  IView = interface
  ['{D75B8CB7-65A8-45FC-841A-9AA02F6A8EEB}']
    function GetViewControl: TControl;
    function WorkItem: TWorkItem;
    function ViewURI: string;
    function Extensions(const AExtensionInterface: TGUID): TInterfaceList;
  end;

  TView = class(TForm, IView)
  private
    FViewURI: string;
    FWorkItem: TWorkItem;
    FExtensions: TComponentList;
  protected
    function GetViewControl: TControl; virtual; abstract;
    function ViewURI: string;
    function Extensions(const AExtensionInterface: TGUID): TInterfaceList;
  public
    constructor Create(AWorkItem: TWorkItem; // PresenterWorkItem
      const AViewURI: string); reintroduce; virtual;
    destructor Destroy; override;
    function WorkItem: TWorkItem;
  end;

  TViewClass = class of TView;

  TPresenter = class(TWorkItemController)
  public
    // called by ViewActivityBuilder
    class procedure Execute(Sender: TWorkItem; Activity: IActivity; AViewClass: TViewClass); virtual; abstract;
  end;

  TPresenterClass = class of TPresenter;

  TViewExtension = class(TComponent)
  protected
    function GetView: IView;
    function WorkItem: TWorkItem;
  public
    class function CheckView(AView: IView): boolean; virtual; abstract;
  end;

  TViewExtensionClass = class of TViewExtension;

  TViewActivateHandler = procedure of object;
  TViewDeactivateHandler = procedure of object;
  TViewShowHandler = procedure of object;
  TViewCloseHandler = procedure of object;
  TViewCloseQueryHandler = procedure(var CanClose: boolean) of object;

 // TViewFocusedFieldChangedHandler = procedure(ADataSet: TDataSet);

  ICommandBar = interface;

  ICustomView = interface(IView)
  ['{5A77F2C8-C19A-4BD6-A8B0-E9F737BC4775}']
    function CommandBar: ICommandBar;

    procedure FocusValueControl(const AName: string);
    procedure FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string = '');

    function GetPreferencePath: string;
    procedure SetPreferenceValue(const AName, AValue: string);
    function GetPreferenceValue(const AName: string): string;
    property PreferenceValue[const AName: string]: string read GetPreferenceValue
      write SetPreferenceValue;

    procedure SetActivateHandler(AHandler: TViewActivateHandler);
    procedure SetDeactivateHandler(AHandler: TViewDeactivateHandler);
    procedure SetShowHandler(AHandler: TViewShowHandler);
    procedure SetCloseHandler(AHandler: TViewCloseHandler);
    procedure SetCloseQueryHandler(AHandler: TViewCloseQueryHandler);
  end;

//------------------------------------------------------------------------------


  TTabChangedHandler = procedure of object;

  ITabs = interface
  ['{2CD9A2D9-98FC-46A4-AA71-B6797E89C4D5}']
    function Add(ATab: string): integer;
    procedure Delete(AIndex: integer);
    procedure Hide(AIndex: integer);
    procedure Show(AIndex: integer);
    function GetActive: integer;
    procedure SetActive(AIndex: integer);
    property Active: integer read GetActive write SetActive;
    function GetTabCaption(AIndex: integer): string;
    procedure SetTabCaption(AIndex: integer; const AValue: string);
    property TabCaption[AIndex: integer]: string read GetTabCaption write SetTabCaption;
    function Count: integer;
    procedure SetTabChangedHandler(AHandler: TTabChangedHandler);
  end;

  IList = interface
  ['{E0D5178B-E286-42C6-88D8-C3008CAAA877}']
    function Count: integer;
    function GetItem(AIndex: integer): Variant;
    function First: Variant;
    function AsArray: variant;
    function AsString(ADelimiter: char = ';'): string;
    property Items[AIndex: integer]: Variant read GetItem; default;
  end;

  TSelectionChangedHandler = procedure of object;

  ISelection = interface(IList)
  ['{F348CAB1-78EF-4F87-9428-D76AC586FFB4}']
    procedure SetChangedCommand(const AName: string);
    procedure SetSelectionChangedHandler(AHandler: TSelectionChangedHandler);
    procedure ChangeSelection(AItem: Variant; ASelected: boolean);
    procedure SelectFocused;
    procedure SelectAll;
    procedure ClearSelection;
    function GetCanMultiSelect: boolean;
    procedure SetCanMultiSelect(AValue: boolean);
    property CanMultiSelect: boolean read GetCanMultiSelect write SetCanMultiSelect;
  end;


  ICommandBar = interface
  ['{BF9EB98D-ABA0-4EE0-9776-28AB336431E4}']
    procedure AddCommand(const AName, ACaption: string; const AShortCut: string = '';
     const AGroup: string = ''; ADefault: boolean = false); overload;

  end;


  IContentView = interface(ICustomView)
  ['{45410026-2DBE-4CBF-B2EE-D0AD93B7AF6A}']
  end;

  IDialogView = interface(ICustomView)
  ['{7C1DBBD0-90BF-431D-BF48-D4EC34E39244}']
  end;


  IExtensionCommand = interface
  ['{C4670269-B360-45A6-A3DD-836A1B635DA0}']
    procedure CommandExtend;
    procedure CommandUpdate;
  end;

//------------------------------------------------------------------------------
  TViewActivityOptions = record
  const
    Singleton = 'Singleton';
    InstanceIdentifiers = 'InstID';

    EntityName = 'EntityName';
    EntityViewName = 'EntityViewName';
  end;

  TViewActivityParams = record
  const
    InstanceID = 'InstanceID';
    Workspace = 'WORKSPACE';
    Title = 'TITLE';
  end;

  TViewActivityOuts = record
  const
    ModalResult = 'ModalResult';
  end;

  TViewActivityHandler = class(TActivityHandler)
  private
    FPresenterClass: TPresenterClass;
    FViewClass: TViewClass;
  public
    constructor Create(APresenterClass: TPresenterClass; AViewClass: TViewClass);

    //IActivityHandler
    procedure Execute(Sender: TWorkItem; Activity: IActivity); override;
    //
    property PresenterClass: TPresenterClass read FPresenterClass;
    property ViewClass: TViewClass read FViewClass;


  end;

procedure RegisterViewExtension(AExtensionClass: TViewExtensionClass);

procedure InstantiateViewExtensions(AView: TView);

implementation

var
  ExtensionClassList: TClassList;

function ExtensionClasses: TClassList;
begin
  if not Assigned(ExtensionClassList) then
    ExtensionClassList := TClassList.Create;
  Result := ExtensionClassList;
end;

procedure RegisterViewExtension(AExtensionClass: TViewExtensionClass);
begin
  if ExtensionClasses.IndexOf(AExtensionClass) = -1 then
    ExtensionClasses.Add(AExtensionClass);
end;

procedure InstantiateViewExtensions(AView: TView);
var
  I: integer;
begin
  for I := 0 to ExtensionClasses.Count - 1 do
    if TViewExtensionClass(ExtensionClasses[I]).CheckView(AView) then
      TViewExtensionClass(ExtensionClasses[I]).Create(AView);
end;


{ TViewActivityBuilder }

procedure TViewActivityHandler.Execute(Sender: TWorkItem; Activity: IActivity);
begin
  Activity.Outs[TViewActivityOuts.ModalResult] := Unassigned;
  FPresenterClass.Execute(Sender, Activity, FViewClass);
end;

constructor TViewActivityHandler.Create(APresenterClass: TPresenterClass;
  AViewClass: TViewClass);
begin
  FPresenterClass := APresenterClass;
  FViewClass := AViewClass;
end;

{ TViewExtension }

function TViewExtension.GetView: IView;
begin
  Result := Owner as IView;
end;

function TViewExtension.WorkItem: TWorkItem;
begin
  Result := GetView.WorkItem;
end;

{ TView }

constructor TView.Create(AWorkItem: TWorkItem; const AViewURI: string);
begin
  inherited Create(nil);
  FViewURI := AViewURI;
  FWorkItem := AWorkItem;
  FExtensions := TComponentList.Create(true);
end;

destructor TView.Destroy;
begin
  FExtensions.Free;
  inherited;
end;

function TView.Extensions(const AExtensionInterface: TGUID): TInterfaceList;
var
  I: integer;
  Intf: IInterface;
begin
  Result := TInterfaceList.Create;
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TViewExtension) and
        Components[I].GetInterface(AExtensionInterface, Intf) then
      Result.Add(Intf);
end;

function TView.ViewURI: string;
begin
  Result := FViewURI;
end;

function TView.WorkItem: TWorkItem;
begin
  Result := FWorkItem;
end;

end.
