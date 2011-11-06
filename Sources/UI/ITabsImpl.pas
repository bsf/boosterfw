unit ITabsImpl;

interface
uses classes, UIClasses, cxPC, CustomView;

type
  TITabsImpl = class(TComponent, ITabs)
  private
    FTabControl: TcxTabControl;
    FTabChangedHandler: TTabChangedHandler;
    procedure OnTabChange(Sender: TObject);
  protected
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
  public
    constructor Create(AOwner: TComponent; ATabControl: TcxTabControl); reintroduce;
  end;

  TITabsImplHelper = class(TViewHelper, IViewHelper)
  protected
    //IViewHelper
    procedure ViewInitialize;
    procedure ViewShow;
    procedure ViewClose;
  end;

implementation


{ TITabsImpl }

function TITabsImpl.Add(ATab: string): integer;
begin
  Result := FTabControl.Tabs.Add(ATab);
end;

function TITabsImpl.Count: integer;
begin
  Result := FTabControl.Tabs.Count;
end;

constructor TITabsImpl.Create(AOwner: TComponent;
  ATabControl: TcxTabControl);
begin
  inherited Create(AOwner);
  FTabControl := ATabControl;
  if not Assigned(FTabControl.OnChange) then
    FTabControl.OnChange := OnTabChange;
end;

procedure TITabsImpl.Delete(AIndex: integer);
begin
  FTabControl.Tabs.Delete(AIndex);
end;

function TITabsImpl.GetActive: integer;
begin
  Result := FTabControl.TabIndex;
end;

function TITabsImpl.GetTabCaption(AIndex: integer): string;
begin
  Result := FTabControl.Tabs[AIndex].Caption;
end;

procedure TITabsImpl.Hide(AIndex: integer);
begin

end;

procedure TITabsImpl.OnTabChange(Sender: TObject);
begin
  if Assigned(FTabChangedHandler) then
    FTabChangedHandler;
end;

procedure TITabsImpl.SetActive(AIndex: integer);
begin
  FTabControl.TabIndex := AIndex;
end;

procedure TITabsImpl.SetTabCaption(AIndex: integer; const AValue: string);
begin
  FTabControl.Tabs[AIndex].Caption := AValue;
end;

procedure TITabsImpl.SetTabChangedHandler(AHandler: TTabChangedHandler);
begin
  FTabChangedHandler := AHandler;
end;

procedure TITabsImpl.Show(AIndex: integer);
begin

end;

{ TITabsImplHelper }

procedure TITabsImplHelper.ViewClose;
begin

end;

procedure TITabsImplHelper.ViewInitialize;
var
  I: integer;
  intfImpl: TITabsImpl;
begin
  for I := 0 to GetForm.ComponentCount - 1 do
    if GetForm.Components[I] is TcxTabControl then
    begin
      intfImpl := TITabsImpl.Create(GetForm, GetForm.Components[I] as TcxTabControl);
      GetForm.RegisterChildInterface(GetForm.Components[I].Name, intfImpl as ITabs);
    end;
end;

procedure TITabsImplHelper.ViewShow;
begin

end;

initialization
  RegisterViewHelperClass(TITabsImplHelper);

end.
