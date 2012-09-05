unit WBCtrl;

interface
uses Windows, Messages, ActiveX, Classes, SHDocVw, Variants, sysutils, coreClasses;

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
  IScriptHelper = interface
  ['{3E932722-DE2D-4242-825A-A6E3EB2B3C9E}']
    function CheckFunction(const AName: WideString): boolean;
    function InvokeFunction(const AName: WideString; Params: array of OleVariant): OleVariant;
  end;

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
  const
    DISPID_START = 1000;
  private
    FScriptHelpers: TInterfaceList;
    FDispList: TStringList;
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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function InvokeScript(ScriptName: WideString; ScriptParams: array of OleVariant): OleVariant;
    procedure RegisterScriptHelper(AHelper: IScriptHelper);
  end;

implementation

const
  IID_IDISPATCH: TGUID = '{00020400-0000-0000-C000-000000000046}';
  IID_NULL: TGUID = '{00000000-0000-0000-0000-000000000000}';

{ TEntityWebBrowser }
constructor TWebBrowserCtrl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScriptHelpers := TInterfaceList.Create;
  FDispList := TStringList.Create;
end;

destructor TWebBrowserCtrl.Destroy;
begin
  FScriptHelpers.Free;
  FDispList.Free;
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
  i, helperIdx, funcIdx: integer;
  Name: WideString;  // Имена передаются в UNICODE
  DispId: SYSINT;
begin
  Result := NOERROR;
  for i := 0 to NameCount - 1 do
  begin
    Name := POleStrList(Names)^[i];

    funcIdx := FDispList.IndexOf(Name);
    if funcIdx = -1 then
    begin
      for helperIdx := 0 to FScriptHelpers.Count - 1 do
      begin
        if (FScriptHelpers[helperIdx] as IScriptHelper).CheckFunction(Name) then
        begin
          funcIdx := FDispList.AddObject(Name, TObject(helperIdx));
          Break;
        end;
      end;
    end;

    if funcIdx >= 0 then
    begin
      DispId := funcIdx + DISPID_START;
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
  DispParams: ActiveX.DISPPARAMS absolute Params;
  args: array of OleVariant;
  i: integer;
  RResult: OleVariant;
  helperIdx: integer;
  funcIdx: integer;
  funcName: WideString;
begin
  if DispId >= DISPID_START then
  begin
    Result := S_OK;
    RResult := Unassigned;

    funcIdx := DispId - DISPID_START;
    funcName := FDispList[funcIdx];
    helperIdx := integer(FDispList.Objects[funcIdx]);

    SetLength(args, DispParams.cArgs);
    for i := 0 to DispParams.cArgs - 1 do //change order args
      args[DispParams.cArgs - i - 1] := OleVariant(DispParams.rgvarg^[i]);

    if Flags and DISPATCH_METHOD <> 0 then
      RResult := (FScriptHelpers[helperIdx] as IScriptHelper).InvokeFunction(funcName, args);

    if Flags and DISPATCH_PROPERTYGET <> 0 then
    begin
      if VarResult <> NIL then
        if VarIsEmpty(RResult) then
          OleVariant(VarResult^) :=
            (FScriptHelpers[helperIdx] as IScriptHelper).InvokeFunction(funcName, args)
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


procedure TWebBrowserCtrl.RegisterScriptHelper(AHelper: IScriptHelper);
begin
  FScriptHelpers.Add(AHelper);
end;

function TWebBrowserCtrl.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT;
begin
  Result := S_FALSE;
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
  //Ctrl+C/Ctrl+V
  if ((Word(GetKeyState(VK_CONTROL)) and $8000)<>0) and
      ((lpMsg.wParam = Ord('C')) or (lpMsg.wParam = Ord('V'))) then
     Result := S_FALSE;
end;

function TWebBrowserCtrl.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT;
begin
  Result := S_FALSE;
end;

function TWebBrowserCtrl.UpdateUI: HRESULT;
begin
  Result := S_FALSE;
end;

end.
