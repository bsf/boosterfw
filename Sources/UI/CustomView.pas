unit CustomView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, cxControls, cxContainer,  Menus,
  cxGroupBox, CoreClasses, CustomPresenter, ShellIntf,
  ImgList, cxGraphics, ActnList, cxButtons,
  UIClasses, db, Contnrs, cxEdit, Typinfo, cxLookAndFeels, dxSkinsCore,
  dxSkinsDefaultPainters, inifiles, cxStyles;

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
    procedure UnLinkDataSet(ADataSource: TDataSource);
    procedure FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string; var Done: boolean);
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

    FPreferenceValues: TMemInifile;

    FAddonsInitialized: boolean;
    FViewHelperClasses: TClassList;
    FViewHelpers: TComponentList;

    FChildInterfaces: TStringList;
    FChildInterfacesIntf: TInterfaceList;

    procedure InitializeAddons;
    function GetHelperList(const AHelperInterface: TGUID): TInterfaceList;

    function GetPreferenceValues: TMemIniFile;
    procedure SavePreferenceValues;
  protected
    //CustomForm
    procedure ChangeScale(M, D: Integer); override;

    //IView
    function GetViewControl: TControl; override;

    //ICustomView
    function CommandBar: ICommandBar; virtual; abstract;

    procedure LinkDataSet(ADataSource: TDataSource; ADataSet: TDataSet);
    procedure UnLinkDataSet(ADataSource: TDataSource);

    procedure FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string = '');

    function GetChildInterface(const AName: string): IInterface;

    function GetPreferencePath: string;
    procedure SetPreferenceValue(const AName, AValue: string);
    function GetPreferenceValue(const AName: string): string;

    procedure SetActivateHandler(AHandler: TViewActivateHandler);
    procedure SetDeactivateHandler(AHandler: TViewDeactivateHandler);
    procedure SetShowHandler(AHandler: TViewShowHandler);
    procedure SetCloseHandler(AHandler: TViewCloseHandler);
    procedure SetCloseQueryHandler(AHandler: TViewCloseQueryHandler);

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
    procedure Initialize; virtual;
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
  GridCtrlUtils, EditCtrlUtils, GridVCtrlUtils, GridTreeCtrlUtils, ISelectionTreeImpl,
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

procedure TfrCustomView.ChangeScale(M, D: Integer);
var
  I: integer;
begin
  inherited ChangeScale(M, D);
  for I := 0 to Self.ComponentCount - 1 do
    if Components[I] is TcxStyle then
      TcxStyle(Components[I]).Font.Size := MulDiv(TcxStyle(Components[I]).Font.Size, App.UI.Scale, 100);
end;

constructor TfrCustomView.Create(APresenterWI: TWorkItem; const AViewURI: string);
begin
  inherited;

  FViewHelperClasses := TClassList.Create;
  FViewHelpers := TComponentList.Create(true);

  FChildInterfaces := TStringList.Create;
  FChildInterfacesIntf := TInterfaceList.Create;

  if not FAddonsInitialized then
    InitializeAddons;

  Initialize;
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

function TfrCustomView.GetViewControl: TControl;
begin
  Result := ViewControl;
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
  Result := '\' + ViewURI + '\';
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

procedure TfrCustomView.Initialize;
begin

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

procedure TfrCustomView.UnLinkDataSet(ADataSource: TDataSource);
var
  I: integer;
  _helpers: TInterfaceList;
begin
  ADataSource.DataSet := nil;

  _helpers := GetHelperList(IViewDataSetHelper);
  for I := 0 to _helpers.Count - 1 do
    IViewDataSetHelper(_helpers[I]).UnLinkDataSet(ADataSource);
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

procedure TfrCustomView.FocusDataSetControl(ADataSet: TDataSet; const AFieldName: string);
var
  I: integer;
  _helpers: TInterfaceList;
  Done: boolean;
begin
  Done := false;
  _helpers := GetHelperList(IViewDataSetHelper);
  for I := 0 to _helpers.Count - 1 do
  begin
    IViewDataSetHelper(_helpers[I]).FocusDataSetControl(ADataSet, AFieldName, Done);
    if Done then Break;
  end;
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

  _helpers := GetHelperList(IViewDataSetHelper);
  for I := 0 to _helpers.Count - 1 do
    IViewDataSetHelper(_helpers[I]).LinkDataSet(ADataSource, ADataSet);
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


end.
