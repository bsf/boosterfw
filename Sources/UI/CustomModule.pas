unit CustomModule;

interface
uses classes, CoreClasses;

type
  TCustomModule = class(TModule)
  public
    //IModule
    procedure Load; override;
    procedure UnLoad; override;

    function InstantiateController(
      AControllerClass: TControllerClass): TAbstractController;

    procedure OnLoading; virtual;
    procedure OnLoaded; virtual;
    procedure OnUnload; virtual;

  end;

implementation

{ TCustomModule }

function TCustomModule.InstantiateController(
  AControllerClass: TControllerClass): TAbstractController;
begin
  Result := WorkItem.WorkItems.Add(AControllerClass.ClassName, AControllerClass).Controller;
end;

procedure TCustomModule.Load;
begin
  OnLoading;
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
  WorkItem.Free;
end;

end.
