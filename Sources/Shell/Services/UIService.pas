unit UIService;

interface
uses classes, coreClasses, UIServiceIntf;

type
  TUIService = class(TComponent, IUIService)
  private
    FWorkItem: TWorkItem;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
  end;

implementation

{ TUIService }

constructor TUIService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FWorkItem := AWorkItem;
end;

end.
