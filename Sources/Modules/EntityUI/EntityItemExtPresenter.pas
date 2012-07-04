unit EntityItemExtPresenter;

interface
uses classes, CoreClasses, CustomPresenter, EntityServiceIntf, UIClasses,
  SysUtils, Variants, ShellIntf, CustomContentPresenter, db,
  EntityCatalogIntf, EntityCatalogConst, UIStr;

type
  IEntityItemExtView = interface(IContentView)
  ['{F2CB6C89-5688-4566-A972-5D787A528C0C}']
  end;

  TEntityItemExtPresenter = class(TEntityContentPresenter)
  private
    FEntityViewReady: boolean;
    function View: IEntityItemExtView;
  protected
    function OnGetWorkItemState(const AName: string; var Done: boolean): Variant; override;
    procedure OnViewReady; override;
  end;

implementation

{ TEntityItemExtPresenter }

function TEntityItemExtPresenter.OnGetWorkItemState(const AName: string;
  var Done: boolean): Variant;
begin

end;

procedure TEntityItemExtPresenter.OnViewReady;
begin
  inherited;

end;

function TEntityItemExtPresenter.View: IEntityItemExtView;
begin

end;

end.
