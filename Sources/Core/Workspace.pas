unit Workspace;

interface

uses Classes, Controls, CoreClasses, forms, messages, types;

type
  TWorkspace = class(TComponent, IWorkspace)
  protected
    FOnViewShow: TNotifyEvent;
    FOnViewClose: TNotifyEvent;
    FOnViewSiteChange: TNotifyEvent;
    //IWorkspace
    function GetView(Index: integer): TControl; virtual;
    function ViewCount: integer; virtual;
    function ViewExists(AView: TControl): boolean; virtual;
    procedure Show(AView: TControl; const ATitle: string); virtual;
    function Close(AView: TControl): boolean; virtual;
    function GetViewSiteInfo(AView: TControl): TViewSiteInfo; virtual;
    //Events
    procedure SetOnViewShow(AEvent: TNotifyEvent);
    function GetOnViewShow: TNotifyEvent;
    procedure SetOnViewClose(AEvent: TNotifyEvent);
    function GetOnViewClose: TNotifyEvent;
    procedure SetOnViewSiteChange(AEvent: TNotifyEvent);
    function GetOnViewSiteChange: TNotifyEvent;
    //
    procedure DoViewActivate(AView: TControl); virtual;
    procedure DoViewDeactivate(AView: TControl); virtual;
    procedure DoViewSiteChange(AView: TControl); virtual;
    procedure DoViewShow(AView: TControl); virtual;
    procedure DoViewClose(AView: TControl); virtual;
    procedure DoViewCloseQuery(AView: TControl; var CanClose: boolean); virtual;
    procedure DoViewShortCut(AView: TControl; var Msg: TWMKey; var Handled: Boolean); virtual;
    procedure DoViewKeyPress(AView: TControl; var Key: Char); virtual;
    procedure DoViewMouseWheel(AView: TControl; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  public
    procedure ScaleBy(M, D: Integer); virtual;
    property View[Index: integer]: TControl read GetView;
    property OnViewShow: TNotifyEvent read GetOnViewShow write SetOnViewShow;
    property OnViewClose: TNotifyEvent read GetOnViewClose write SetOnViewClose;
    property OnViewSiteChange: TNotifyEvent read GetOnViewSiteChange write SetOnViewSiteChange;
  end;

implementation

{ TWorkspace }


function TWorkspace.Close(AView: TControl): boolean;
begin
  Result := false;
end;


procedure TWorkspace.Show(AView: TControl; const ATitle: string);
begin

end;


function TWorkspace.GetViewSiteInfo(AView: TControl): TViewSiteInfo;
begin
  Result := nil;
end;


function TWorkspace.GetOnViewClose: TNotifyEvent;
begin
  Result := FOnViewClose;
end;

procedure TWorkspace.SetOnViewClose(AEvent: TNotifyEvent);
begin
  FOnViewClose := AEvent;
end;


function TWorkspace.GetOnViewShow: TNotifyEvent;
begin
  Result := FOnViewShow;
end;

procedure TWorkspace.SetOnViewShow(AEvent: TNotifyEvent);
begin
  FOnViewShow := AEvent;
end;

function TWorkspace.GetOnViewSiteChange: TNotifyEvent;
begin
  Result := FOnViewSiteChange;
end;

procedure TWorkspace.SetOnViewSiteChange(AEvent: TNotifyEvent);
begin
  FOnViewSiteChange := AEvent;
end;

function TWorkspace.GetView(Index: integer): TControl;
begin
  Result := nil;
end;

function TWorkspace.ViewCount: integer;
begin
  Result := 0;
end;

procedure TWorkspace.DoViewSiteChange(AView: TControl);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewSiteChange(AView);

  if Assigned(FOnViewSiteChange) then FOnViewSiteChange(AView);
end;

procedure TWorkspace.DoViewShow(AView: TControl);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewShow(AView);

  if Assigned(FOnViewShow) then FOnViewShow(AView);
end;

procedure TWorkspace.DoViewClose(AView: TControl);
var
  Intf: IViewOwner;
begin
  if Assigned(FOnViewClose) then FOnViewClose(AView);
  
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewClose(AView);
end;

procedure TWorkspace.DoViewCloseQuery(AView: TControl; var CanClose: boolean);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewCloseQuery(AView, CanClose);
end;

procedure TWorkspace.DoViewShortCut(AView: TControl; var Msg: TWMKey;
  var Handled: Boolean);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewShortCut(AView, Msg, Handled);
end;

procedure TWorkspace.DoViewKeyPress(AView: TControl; var Key: Char);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewKeyPress(AView, Key);
end;

procedure TWorkspace.DoViewMouseWheel(AView: TControl; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewMouseWheel(AView, Shift, WheelDelta, MousePos, Handled);
end;

procedure TWorkspace.DoViewActivate(AView: TControl);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewActivate(AView);
end;

procedure TWorkspace.DoViewDeactivate(AView: TControl);
var
  Intf: IViewOwner;
begin
  if Assigned(AView.Owner) and AView.Owner.GetInterface(IViewOwner, Intf) then
    Intf.OnViewDeactivate(AView);
end;

function TWorkspace.ViewExists(AView: TControl): boolean;
begin
  Result := false;
end;

procedure TWorkspace.ScaleBy(M, D: Integer);
begin
  
end;

end.
