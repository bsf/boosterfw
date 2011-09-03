unit CustomModule;

interface
uses classes, CoreClasses;

type
  TCustomModule = class(TComponent, IModule)
  private
    FWorkItem: TWorkItem;
  protected
    //IModule
    procedure AddServices(AWorkItem: TWorkItem);
    procedure Load;
    procedure UnLoad;

    function InstantiateController(
      AControllerClass: TControllerClass): TAbstractController;

    procedure OnLoading; virtual;
    procedure OnLoaded; virtual;
    procedure OnUnload; virtual;

    property WorkItem: TWorkItem read FWorkItem;
  end;

implementation

{ TCustomModule }

function TCustomModule.InstantiateController(
  AControllerClass: TControllerClass): TAbstractController;
begin
  Result := FWorkItem.WorkItems.Add(AControllerClass.ClassName, AControllerClass).Controller;
end;

procedure TCustomModule.AddServices(AWorkItem: TWorkItem);
begin
  FWorkItem := AWorkItem.WorkItems.Add(Self.ClassName);
  OnLoading;
end;

procedure TCustomModule.Load;
begin
  OnLoaded;
end;

procedure TCustomModule.OnLoaded;
begin

end;

procedure TCustomModule.OnLoading;
begin

end;

procedure TCustomModule.OnUnload;
begin

end;

procedure TCustomModule.UnLoad;
begin
  OnUnload;
  FWorkItem.Free;
end;

end.
