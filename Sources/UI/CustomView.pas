unit CustomView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, cxControls, cxContainer,  Menus,
  cxGroupBox, CoreClasses, CustomPresenter, ShellIntf,
  ImgList, cxGraphics, ActnList, cxButtons, ViewServiceIntf,
  CommonViewIntf, db, Contnrs, cxEdit, Typinfo, cxLookAndFeels, dxSkinsCore,
  dxSkinsDefaultPainters, CommonUtils, inifiles;

const
  const_PreferenceValueFileName = 'PreferenceValue.ini';

type
  TfrCustomView = class;

  TViewHelper = class(TComponent)
  protected
    function GetForm: TfrCustomView;
  public
    constructor Create(AOwner: TfrCustomView); reintroduce; virtual;
  end;

  TViewHelperClass = class of TViewHelper;

  IViewHelper = interface
  ['{76FD0829-E20E-46F2-927E-AB8D7B29FEE9}']
    procedure ViewInitialize;
    procedure ViewShow;
    procedure ViewClose;
  end;

  IViewDataSetHelper = interface
  ['{09366273-0BAD-4E50-977D-29702D425137}']
    procedure LinkDataSet(ADataSource: TDataSource; ADataSet: TDataSet);
    procedure FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string; var Done: boolean);

    function GetFocusedField(ADataSet: TDataSet; var Done: boolean): string;
    procedure SetFocusedField(ADataSet: TDataSet; const AFieldName: string; var Done: boolean);
    procedure SetFocusedFieldChangedHandler(AHandler: TViewFocusedFieldChangedHandler; var Done: boolean);

  end;



  IViewValueEditorHelper = interface
  ['{BFBC8B15-A59C-44EB-9E94-CA7EDA8D817E}']
    //function GetControlClass: TComponentClass;
    function CheckEditorClass(AControl: TComponent): boolean;
    function ReadValue(AControl: TComponent): Variant;
    procedure WriteValue(AControl: TComponent; AValue: Variant);
    procedure SetValueChangedHandler(AControl: TComponent;
      AHandler: TViewValueChangedHandler);
    function ReadValueStatus(AControl: TComponent): TValueStatus;
    procedure WriteValueStatus(AContorl: TComponent; AStatus: TValueStatus);
  end;

  TStubControl = class(TControl)
  public
     procedure ChangeScale(M, D: Integer);  override;
  end;

  TfrCustomView = class(TView, IView, ICustomView, IViewOwner)
    ViewControl: TcxGroupBox;
    ActionList: TActionList;
  private

    FActivateHandler: TViewActivateHandler;
    FDeactivateHandler: TViewDeactivateHandler;
    FShowHandler: TViewShowHandler;
    FCloseHandler: TViewCloseHandler;
    FCloseQueryHandler: TViewCloseQueryHandler;
    FValueChangedHandler: TViewValueChangedHandler;

    FPreferenceValues: TMemInifile;

    FAddonsInitialized: boolean;
    FViewHelperClasses: TClassList;
    FViewHelpers: TComponentList;

    FChildInterfaces: TStringList;
    FChildInterfacesIntf: TInterfaceList;

    procedure InitializeAddons;
    function GetHelperList(const AHelperInterface: TGUID): TInterfaceList;


    function GetValueEditorHelper(AControl: TComponent): IViewValueEditorHelper;
    function ReadValue(AControl: TComponent): Variant;
    procedure WriteValue(AControl: TComponent; AValue: Variant);
    function ReadValueStatus(AControl: TComponent): TValueStatus;
    procedure WriteValueStatus(AControl: TComponent; AStatus: TValueStatus);

    function GetPreferenceValues: TMemIniFile;
    procedure SavePreferenceValues;
  protected

    //IView
    function GetViewControl: TControl; override;

    //ICustomView
    function CommandBar: ICommandBar; virtual; abstract;

    function GetValue(const AName: string): Variant;
    procedure SetValue(const AName: string; AValue: Variant);
    function GetValueStatus(const AName: string): TValueStatus;
    procedure SetValueStatus(const AName: string; AStatus: TValueStatus);

    procedure LinkDataSet(const AName: string; ADataSet: TDataSet); overload;
    procedure LinkDataSet(ADataSource: TDataSource; ADataSet: TDataSet); overload;

    procedure FocusValueControl(const AName: string);
    procedure FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string = '');

    function GetFocusedField(ADataSet: TDataSet): string;
    procedure SetFocusedField(ADataSet: TDataSet; const AFieldName: string);
    procedure SetFocusedFieldChangedHandler(AHandler: TViewFocusedFieldChangedHandler);

    function GetChildInterface(const AName: string): IInterface;

    function GetPreferencePath: string;
    procedure SetPreferenceValue(const AName, AValue: string);
    function GetPreferenceValue(const AName: string): string;

    procedure SetActivateHandler(AHandler: TViewActivateHandler);
    procedure SetDeactivateHandler(AHandler: TViewDeactivateHandler);
    procedure SetShowHandler(AHandler: TViewShowHandler);
    procedure SetCloseHandler(AHandler: TViewCloseHandler);
    procedure SetCloseQueryHandler(AHandler: TViewCloseQueryHandler);
    procedure SetValueChangedHandler(AHandler: TViewValueChangedHandler);

    //IViewOwner
    procedure OnViewActivate(AView: TControl); virtual;
    procedure OnViewDeactivate(AView: TControl); virtual;
    procedure OnViewShow(AView: TControl); virtual;
    procedure OnViewCloseQuery(AView: TControl; var CanClose: boolean); virtual;
    procedure OnViewClose(AView: TControl); virtual;
    procedure OnViewSiteChange(AView: TControl); virtual;
    procedure OnViewShortCut(AView: TControl; var Msg: TWMKey;
      var Handled: Boolean); virtual;
    procedure OnViewKeyPress(AView: TControl; var Key: Char); virtual;
    procedure OnViewMouseWheel(AView: TControl; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean); virtual;


    //
    procedure OnLinkDataSet(const AName: string; ADataSet: TDataSet); virtual;
    procedure OnGetValue(const AName: string; var AValue: Variant); virtual;
    procedure OnSetValue(const AName: string; AValue: Variant; var Done: boolean); virtual;
    procedure OnFocusDataSetControl(ADataSet: TDataSet; const AFieldName: string;
      var Done: boolean); virtual;
    procedure DoInitialize; virtual;
    procedure OnInitialize; virtual;
  public
    constructor Create(APresenterWI: TWorkItem; const AViewURI: string); override;
    destructor Destroy; override;

    procedure RegisterHelper(AHelperClass: TViewHelperClass);
    procedure RegisterChildInterface(const AName: string; AInterface: IInterface);

  end;

procedure RegisterViewHelperClass(AClass: TViewHelperClass);
function GetViewHelperClasses: TClassList;

implementation
uses
  // for linked only
  GridCtrlUtils, EditCtrlUtils, GridVCtrlUtils, GridTreeCtrlUtils,
  ISelectionGridImpl, ITabsImpl; //View helpers

{$R *.dfm}

var
  ViewHelperClasses: TClassList;

procedure RegisterViewHelperClass(AClass: TViewHelperClass);
begin
  GetViewHelperClasses.Add(AClass);
end;

function GetViewHelperClasses: TClassList;
begin
  if not Assigned(ViewHelperClasses) then
    ViewHelperClasses := TClassList.Create;

  Result := ViewHelperClasses;
end;

{ TfrCustomView }


constructor TfrCustomView.Create(APresenterWI: TWorkItem; const AViewURI: string);
begin
  inherited;

  FViewHelperClasses := TClassList.Create;
  FViewHelpers := TComponentList.Create(true);

  FChildInterfaces := TStringList.Create;
  FChildInterfacesIntf := TInterfaceList.Create;

  if not FAddonsInitialized then
    InitializeAddons;

  DoInitialize;

end;

destructor TfrCustomView.Destroy;
begin
  try
    SavePreferenceValues;

    FViewHelperClasses.Free;
    FViewHelpers.Free;

    FChildInterfaces.Free;
    FChildInterfacesIntf.Free;

    inherited;
  except
    on E: Exception do raise Exception.CreateFmt('Ошибка при закрытии: %s', [E.Message]);
  end;
end;


function TfrCustomView.GetValue(const AName: string): Variant;
var
  valControl: TComponent;
begin
  Result := Unassigned;

  valControl := FindComponent(AName);
  if Assigned(valControl) then
    Result := ReadValue(valControl);

  OnGetValue(AName, Result);
end;

procedure TfrCustomView.OnViewClose(AView: TControl);
  procedure DoCloseHelpers;
  var
    I: integer;
    _helpers: TInterfaceList;
  begin
    _helpers := GetHelperList(IViewHelper);
    for I := 0 to _helpers.Count - 1 do
      IViewHelper(_helpers[I]).ViewClose;
  end;

begin
  DoCloseHelpers;
//  SavePreference;
  if Assigned(FCloseHandler) then FCloseHandler;
  //тут форма уже может быть фри
end;

procedure TfrCustomView.OnViewCloseQuery(AView: TControl;
  var CanClose: boolean);
begin
  if Assigned(FCloseQueryHandler) then FCloseQueryHandler(CanClose);
end;

procedure TfrCustomView.OnViewShortCut(AView: TControl; var Msg: TWMKey;
  var Handled: Boolean);
begin
  Handled := IsShortCut(Msg);
end;

procedure TfrCustomView.OnViewShow(AView: TControl);
var
  I: integer;
  _helpers: TInterfaceList;
begin
  _helpers := GetHelperList(IViewHelper);
  for I := 0 to _helpers.Count - 1 do
    IViewHelper(_helpers[I]).ViewShow;

//  LoadPreference;

  if Assigned(FShowHandler) then FShowHandler;    
end;

procedure TfrCustomView.OnViewSiteChange(AView: TControl);
begin

end;

procedure TfrCustomView.SetValue(const AName: string; AValue: Variant);
var
  valControl: TComponent;
  Done: boolean;
begin
  Done := false;
  OnSetValue(AName, AValue, Done);

  if not Done then
  begin
    valControl := FindComponent(AName);
    if Assigned(valControl) then
    begin
     WriteValue(valControl, AValue);
     Done := true;
    end;
  end;

end;

function TfrCustomView.GetViewControl: TControl;
begin
  Result := ViewControl;
end;

procedure TfrCustomView.LinkDataSet(const AName: string; ADataSet: TDataSet);
const
  DataSourceNameFmt = '%sDataSource';

var
  DS: TComponent;
  DSName: string;
begin

  DSName := Format(DataSourceNameFmt, [AName]);
  DS := FindComponent(DSName);
  if Assigned(DS) and (DS is TDataSource) then
    TDataSource(DS).DataSet := ADataSet;

  OnLinkDataSet(AName, ADataSet);

  LinkDataSet(TDataSource(DS), ADataSet);


end;

procedure TfrCustomView.OnGetValue(const AName: string; var AValue: Variant);
begin

end;

function TfrCustomView.ReadValue(AControl: TComponent): Variant;
var
  helper: IViewValueEditorHelper;
begin
  Result := Unassigned;
  helper := GetValueEditorHelper(AControl);
  if assigned(helper) then
    Result := helper.ReadValue(AControl);
end;

procedure TfrCustomView.OnSetValue(const AName: string; AValue: Variant;
  var Done: boolean);
begin

end;

procedure TfrCustomView.WriteValue(AControl: TComponent; AValue: Variant);
var
  helper: IViewValueEditorHelper;
begin
  helper := GetValueEditorHelper(AControl);
  if assigned(helper) then
    helper.WriteValue(AControl, AValue);
end;

procedure TfrCustomView.OnLinkDataSet(const AName: string; ADataSet: TDataSet);
begin

end;

procedure TfrCustomView.SetCloseQueryHandler(
  AHandler: TViewCloseQueryHandler);
begin
  FCloseQueryHandler := AHandler;
end;

procedure TfrCustomView.SetCloseHandler(AHandler: TViewCloseHandler);
begin
  FCloseHandler := AHandler;
end;

procedure TfrCustomView.SetPreferenceValue(const AName, AValue: string);
begin
  GetPreferenceValues.WriteString('_', AName, AValue);
end;





procedure TfrCustomView.SavePreferenceValues;
var
  prefValues: TStringList;
  data: TMemoryStream;
begin
  if FPreferenceValues = nil then exit;

  prefValues := TStringList.Create;
  data := TMemoryStream.Create;
  try
    FPreferenceValues.GetStrings(prefValues);
    prefValues.SaveToStream(data);
    App.UserProfile.SaveData(GetPreferencePath, const_PreferenceValueFileName, data);
  finally
    prefValues.Free;
    data.Free;
  end;
  FreeAndNil(FPreferenceValues);
end;

function TfrCustomView.GetPreferencePath: string;
begin
  Result := PROFILE_VIEW_PREFERENCE_STORAGE + '\' + ViewURI + '\';
end;

function TfrCustomView.GetPreferenceValue(const AName: string): string;
begin
  Result := GetPreferenceValues.ReadString('_', AName, '');
end;

function TfrCustomView.GetPreferenceValues: TMemIniFile;
var
  prefValues: TStringList;
  data: TMemoryStream;
begin
  if FPreferenceValues = nil then
  begin
    FPreferenceValues := TMemIniFile.Create('');
    prefValues := TStringList.Create;
    data := TMemoryStream.Create;
    try
      App.UserProfile.LoadData(GetPreferencePath, const_PreferenceValueFileName, data);
      Data.Position := 0;
      prefValues.LoadFromStream(data);
      FPreferenceValues.SetStrings(prefValues);
    finally
      prefValues.Free;
      data.Free;
    end;
  end;
  Result := FPreferenceValues;
end;

procedure TfrCustomView.InitializeAddons;
var
  I: integer;
  _helpers: TInterfaceList;

begin

  FViewHelperClasses.Assign(GetViewHelperClasses);

  for I := 0 to FViewHelperClasses.Count - 1 do
    FViewHelpers.Add(TViewHelperClass(FViewHelperClasses[I]).Create(Self));

  _helpers := GetHelperList(IViewHelper);
  for I := 0 to _helpers.Count - 1 do
    IViewHelper(_helpers[I]).ViewInitialize;

  FAddonsInitialized := true;
end;

procedure TfrCustomView.SetValueChangedHandler(
  AHandler: TViewValueChangedHandler);
var
  I: integer;
  helper: IViewValueEditorHelper;
begin
  FValueChangedHandler := AHandler;
  for I := 0 to ComponentCount - 1 do
  begin
    helper := GetValueEditorHelper(Components[I]);
    if assigned(helper) then
      helper.SetValueChangedHandler(Components[I], FValueChangedHandler);
  end;

end;

function TfrCustomView.GetValueEditorHelper(
  AControl: TComponent): IViewValueEditorHelper;
var
  I: integer;
  _helpers: TInterfaceList;
begin
  _helpers := GetHelperList(IViewValueEditorHelper);
  for I := 0 to _helpers.Count - 1 do
  begin
    Result := IViewValueEditorHelper(_helpers[I]);
    if Result.CheckEditorClass(AControl) then Exit;
  end;
  Result := nil;
end;

procedure TfrCustomView.OnViewKeyPress(AView: TControl; var Key: Char);
begin

end;


procedure TfrCustomView.OnViewMouseWheel(AView: TControl; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrCustomView.RegisterHelper(AHelperClass: TViewHelperClass);
begin
  FViewHelperClasses.Add(AHelperClass);
end;

function TfrCustomView.GetHelperList(const AHelperInterface: TGUID): TInterfaceList;
var
  I: integer;
  Intf: IInterface;
begin
  Result := TInterfaceList.Create;
  for I := 0 to FViewHelpers.Count - 1 do
    if FViewHelpers[I].GetInterface(AHelperInterface, Intf) then
      Result.Add(Intf);
end;

function TfrCustomView.GetValueStatus(const AName: string): TValueStatus;
var
  valControl: TComponent;
begin
  Result := vsEnabled;

  valControl := FindComponent(AName);
  if Assigned(valControl) then
    Result := ReadValueStatus(valControl);

end;

procedure TfrCustomView.SetValueStatus(const AName: string; AStatus: TValueStatus);
var
  valControl: TComponent;
begin
  valControl := FindComponent(AName);
  if Assigned(valControl) then
    WriteValueStatus(valControl, AStatus);

end;

function TfrCustomView.ReadValueStatus(AControl: TComponent): TValueStatus;
var
  helper: IViewValueEditorHelper;
begin
  Result := Unassigned;
  helper := GetValueEditorHelper(AControl);
  if assigned(helper) then
    Result := helper.ReadValueStatus(AControl);
end;

procedure TfrCustomView.WriteValueStatus(AControl: TComponent;
  AStatus: TValueStatus);
var
  helper: IViewValueEditorHelper;
begin
  helper := GetValueEditorHelper(AControl);
  if assigned(helper) then
    helper.WriteValueStatus(AControl, AStatus);
end;

procedure TfrCustomView.OnViewActivate(AView: TControl);
begin
  if Assigned(FActivateHandler) then FActivateHandler;
end;

procedure TfrCustomView.OnViewDeactivate(AView: TControl);
begin
  if Assigned(FDeactivateHandler) then FDeactivateHandler;
end;

procedure TfrCustomView.SetActivateHandler(AHandler: TViewActivateHandler);
begin
  FActivateHandler := AHandler;
end;

procedure TfrCustomView.SetDeactivateHandler(
  AHandler: TViewDeactivateHandler);
begin
  FDeactivateHandler := AHandler;
end;

procedure TfrCustomView.OnInitialize;
begin

end;

procedure TfrCustomView.DoInitialize;
begin
  OnInitialize;
end;

procedure TfrCustomView.FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string);
var
  I: integer;
  _helpers: TInterfaceList;
  Done: boolean;
begin
  Done := false;
  OnFocusDataSetControl(ADataSet, AFieldName, Done);

  if not Done then
  begin
    _helpers := GetHelperList(IViewDataSetHelper);
    for I := 0 to _helpers.Count - 1 do
    begin
      IViewDataSetHelper(_helpers[I]).FocusDataSetControl(ADataSet, AFieldName, Done);
      if Done then Break;
    end;
  end;
end;

procedure TfrCustomView.FocusValueControl(const AName: string);
begin

end;

procedure TfrCustomView.OnFocusDataSetControl(ADataSet: TDataSet;
  const AFieldName: string; var Done: boolean);
begin

end;

procedure TfrCustomView.SetShowHandler(AHandler: TViewShowHandler);
begin
  FShowHandler := AHandler;
end;

function TfrCustomView.GetChildInterface(const AName: string): IInterface;
var
  Idx: integer;
begin
  Idx := FChildInterfaces.IndexOf(AName);
  if Idx = -1 then
    raise Exception.CreateFmt('Child interface %s not exists', [AName]);
  Result := FChildInterfacesIntf[Idx];  
end;

procedure TfrCustomView.RegisterChildInterface(const AName: string;
  AInterface: IInterface);
begin
  if FChildInterfaces.IndexOf(AName) <> -1 then
    raise Exception.CreateFmt('Child interface % already exists', [AName]);

  FChildInterfaces.Add(AName);
  FChildInterfacesIntf.Add(AInterface);

end;

procedure TfrCustomView.LinkDataSet(ADataSource: TDataSource;
  ADataSet: TDataSet);
var
  I: integer;
  _helpers: TInterfaceList;
begin

  ADataSource.DataSet := ADataSet;

//  OnLinkDataSet(AName, ADataSet);

  _helpers := GetHelperList(IViewDataSetHelper);
  for I := 0 to _helpers.Count - 1 do
    IViewDataSetHelper(_helpers[I]).LinkDataSet(ADataSource, ADataSet);

end;


function TfrCustomView.GetFocusedField(ADataSet: TDataSet): string;
begin

end;

procedure TfrCustomView.SetFocusedField(ADataSet: TDataSet;
  const AFieldName: string);
begin

end;

procedure TfrCustomView.SetFocusedFieldChangedHandler(
  AHandler: TViewFocusedFieldChangedHandler);
begin

end;

{ TViewHelper }

constructor TViewHelper.Create(AOwner: TfrCustomView);
begin
  inherited Create(AOwner);
end;

function TViewHelper.GetForm: TfrCustomView;
begin
  Result := TfrCustomView(Owner);
end;

{ TStubControl }

procedure TStubControl.ChangeScale(M, D: Integer);
begin
  inherited ChangeScale(M, D);
end;

end.
