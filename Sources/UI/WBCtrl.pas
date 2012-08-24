unit WBCtrl;

interface
uses Windows, ActiveX, Classes, SHDocVw, Variants, sysutils, coreClasses;

const
  DOCHOSTUIFLAG_DIALOG = 1;
  DOCHOSTUIFLAG_DISABLE_HELP_MENU = 2;
  DOCHOSTUIFLAG_NO3DBORDER = 4;
  DOCHOSTUIFLAG_SCROLL_NO = 8;
  DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE = 16;
  DOCHOSTUIFLAG_OPENNEWWIN = 32;
  DOCHOSTUIFLAG_DISABLE_OFFSCREEN = 64;
  DOCHOSTUIFLAG_FLAT_SCROLLBAR = 128;
  DOCHOSTUIFLAG_DIV_BLOCKDEFAULT = 256;
  DOCHOSTUIFLAG_ACTIVATE_CLIENTHIT_ONLY = 512;

  DOCHOSTUIDBLCLK_DEFAULT = 0;
  DOCHOSTUIDBLCLK_SHOWPROPERTIES = 1;
  DOCHOSTUIDBLCLK_SHOWCODE = 2;


type
  TScriptFunction = function (Params: array of OleVariant): OleVariant of object;

  TDocHostInfo = packed record
    cbSize: ULONG;
    dwFlags: DWORD;
    dwDoubleClick: DWORD;
  end;

  IDocHostUIHandler = interface(IUnknown)
    ['{bd3f23c0-d43e-11cf-893b-00aa00bdce1a}']
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown;
      const pdispReserved: IDispatch): HRESULT; stdcall;
    function GetHostInfo(var pInfo: TDocHostInfo): HRESULT; stdcall;
    function ShowUI(const dwID: DWORD;
      const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget;
      const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow): HRESULT; stdcall;
    function HideUI: HRESULT; stdcall;
    function UpdateUI: HRESULT; stdcall;
    function EnableModeless(const fEnable: BOOL): HRESULT; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HRESULT;
      stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HRESULT;
      stdcall;
    function ResizeBorder(const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow;
      const fRameWindow: BOOL): HRESULT; stdcall;
    function TranslateAccelerator(const lpMsg: PMSG;
      const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HRESULT; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR;
      const dw: DWORD): HRESULT; stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HRESULT; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HRESULT;
      stdcall;
    function TranslateUrl(const dwTranslate: DWORD;
      const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT;
      stdcall;
    function FilterDataObject(const pDO: IDataObject;
      out ppDORet: IDataObject): HRESULT; stdcall;
  end;

  TWebBrowserCtrl = class(TWebBrowser, IDocHostUIHandler, IDispatch)
  private
    FWorkItem: TWorkItem;
    FScriptFuncEntries: TStringList;

    function ScriptFunc_GetWorkItemState(AParams: array of OleVariant): OleVariant;
    function ScriptFunc_SetWorkItemState(AParams: array of OleVariant): OleVariant;
  protected
    // IDocHostUIHandler
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown;
      const pdispReserved: IDispatch): HRESULT; stdcall;
    function GetHostInfo(var pInfo: TDocHostInfo): HRESULT;
      stdcall;
    function ShowUI(const dwID: DWORD;
      const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget;
      const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow): HRESULT; stdcall;
    function HideUI: HRESULT; stdcall;
    function UpdateUI: HRESULT; stdcall;
    function EnableModeless(const fEnable: BOOL): HRESULT; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HRESULT;
      stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HRESULT;
      stdcall;
    function ResizeBorder(const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow;
      const fRameWindow: BOOL): HRESULT; stdcall;
    function TranslateAccelerator(const lpMsg: PMSG;
      const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HRESULT; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR;
      const dw: DWORD): HRESULT; stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HRESULT; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HRESULT;
      stdcall;
    function TranslateUrl(const dwTranslate: DWORD;
      const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT;
      stdcall;
    function FilterDataObject(const pDO: IDataObject;
      out ppDORet: IDataObject): HRESULT; stdcall;

    // IDispatch for external
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
    function InvokeScript(ScriptName: WideString; ScriptParams: array of OleVariant): OleVariant;
    procedure RegisterScriptFunc(AName: WideString; Func: TScriptFunction);
    procedure UnregisterScriptFunc(AName: WideString);

  end;

implementation

const
  IID_IDISPATCH: TGUID = '{00020400-0000-0000-C000-000000000046}';
  IID_NULL: TGUID = '{00000000-0000-0000-0000-000000000000}';
  ScriptFuncDispIdStart = 10001;

type
  TScriptFuncPtrObj = class
    Func: TScriptFunction;
    DispId: SYSINT;
  end;


{ TEntityWebBrowser }
constructor TWebBrowserCtrl.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FScriptFuncEntries := TStringList.Create;
  FWorkItem := AWorkItem;

  RegisterScriptFunc('getWorkItemState', ScriptFunc_GetWorkItemState);
  RegisterScriptFunc('setWorkItemState', ScriptFunc_SetWorkItemState);
end;

destructor TWebBrowserCtrl.Destroy;
begin
  FScriptFuncEntries.Free;
  inherited;
end;

function TWebBrowserCtrl.EnableModeless(const fEnable: BOOL): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.FilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.GetExternal(out ppDispatch: IDispatch): HRESULT;
begin
  ppDispatch := Self;
  Result := S_OK;
end;

function TWebBrowserCtrl.GetHostInfo(var pInfo: TDocHostInfo): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
var
  i, idx: integer;
  Name: WideString;  // Имена передаются в UNICODE
  DispId: SYSINT;
begin
  Result := NOERROR;
  for i := 0 to NameCount - 1 do
  begin
    Name := POleStrList(Names)^[i];
    idx := FScriptFuncEntries.IndexOf(Name);
    if idx <> -1 then
    begin
      DispId := (FScriptFuncEntries.Objects[idx] as TScriptFuncPtrObj).DispId;
      PDispIdList(DispIDs)^[i] := DispId;
    end
    else
    begin
      if inherited GetIDsOfNames(IID, @Name, 1, LocaleID, @DispId) = NOERROR then
        PDispIdList(DispIDs)^[i] := DispId
      else
      begin
        PDispIdList(DispIDs)^[i] := DISPID_UNKNOWN;
        Result := HResult(DISP_E_UNKNOWNNAME);
      end;
    end;
  end;
end;

function TWebBrowserCtrl.GetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.HideUI: HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
var
    Func: TScriptFunction;
    DispParams: ActiveX.DISPPARAMS absolute Params;
    args: array of OleVariant;
    i: integer;
    RResult: OleVariant;
begin
  if DispId >= ScriptFuncDispIdStart then
  begin
    Result := S_OK;
    RResult := Unassigned;

    Func := (FScriptFuncEntries.Objects[DispId - ScriptFuncDispIdStart] as TScriptFuncPtrObj).Func;

    SetLength(args, DispParams.cArgs);
    for i := 0 to DispParams.cArgs - 1 do
      args[i] := OleVariant(DispParams.rgvarg^[i]);

    if Flags and DISPATCH_METHOD <> 0 then
      RResult := Func(args);


    if Flags and DISPATCH_PROPERTYGET <> 0 then
    begin
      if VarResult <> NIL then
        if VarIsEmpty(RResult) then
          OleVariant(VarResult^) := Func(args)
        else
          OleVariant(VarResult^) := RResult
      else
        Result := DISP_E_EXCEPTION;
      end;

      if Flags and DISPATCH_PROPERTYPUT <> 0 then
        Result := E_NOTIMPL;

    end
    else
      Result := inherited Invoke(DispID, IID, LocaleID, Flags, Params,
        VarResult, ExcepInfo, ArgErr);
end;

function TWebBrowserCtrl.InvokeScript(ScriptName: WideString;
  ScriptParams: array of OleVariant): OleVariant;
var
    doc: OleVariant; // Будем использовать позднее связывание
    ScriptEngineDispatch: IDispatch;
    DispId: SYSINT;
    hr: HRESULT;
    DispParams: ActiveX.DISPPARAMS;
    i : integer;
begin
    Result := Unassigned;

    doc := Self.Document;
    ScriptEngineDispatch := doc.Script;
    hr := ScriptEngineDispatch.GetIDsOfNames(IID_NULL,
            @ScriptName,
            1,
            LOCALE_USER_DEFAULT,
            @DispId);
    if hr = S_OK then
    begin
        with DispParams do
        begin
            cArgs := Length(ScriptParams);
            GetMem(rgvarg, cArgs*SizeOf(OleVariant));
            for i := 0 to cArgs - 1 do
              OleVariant(rgvarg^[i]) := ScriptParams[i];
            rgdispidNamedArgs := NIL;
            cNamedArgs := 0;
        end;
        try
            ScriptEngineDispatch.Invoke(DispId,
              IID_NULL,
              LOCALE_USER_DEFAULT,
              DISPATCH_METHOD,
              DispParams,
              NIL, NIL, NIL);
        finally
            FreeMem(DispParams.rgvarg);
        end;
    end
    else
    begin
        raise Exception.Create('Unknown script name in WebBrowser.InvokeScript');
    end;

end;

function TWebBrowserCtrl.OnDocWindowActivate(const fActivate: BOOL): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.OnFrameWindowActivate(
  const fActivate: BOOL): HRESULT;
begin
  Result := S_FALSE;
end;

procedure TWebBrowserCtrl.RegisterScriptFunc(AName: WideString;
  Func: TScriptFunction);
var
  item: TScriptFuncPtrObj;
begin
  item := TScriptFuncPtrObj.Create;
  item.Func := Func;
  item.DispId := ScriptFuncDispIdStart + FScriptFuncEntries.Count;

  FScriptFuncEntries.AddObject(AName, item);
end;

function TWebBrowserCtrl.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.ScriptFunc_GetWorkItemState(
  AParams: array of OleVariant): OleVariant;
var
  stateName: WideString;
begin
  Result := Unassigned;
  if Length(AParams) = 0 then Exit;
  stateName := AParams[0];
  Result := FWorkItem.State[stateName];
end;

function TWebBrowserCtrl.ScriptFunc_SetWorkItemState(
  AParams: array of OleVariant): OleVariant;
begin

end;

function TWebBrowserCtrl.ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
  const pcmdtReserved: IInterface; const pdispReserved: IDispatch): HRESULT;
begin
  Result := S_OK;
{  if Assigned(PopupMenu) then begin
    PopupMenu.Popup(ppt.X, ppt.Y);
    Result := S_OK;
  end
  else Result := S_FALSE;}
end;

function TWebBrowserCtrl.ShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HRESULT;
begin
  Result := S_OK;
end;

function TWebBrowserCtrl.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT;
begin
  Result := S_FALSE;
end;

procedure TWebBrowserCtrl.UnregisterScriptFunc(AName: WideString);
begin
  FScriptFuncEntries.Delete(FScriptFuncEntries.IndexOfName(Name));
end;

function TWebBrowserCtrl.UpdateUI: HRESULT;
begin
  Result := S_FALSE;
end;

end.
