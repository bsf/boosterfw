unit EntityCatalogIntf;

interface
uses UIClasses, db, Classes, ShellIntf, CoreClasses, variants,
  CustomContentPresenter, CustomDialogPresenter;




type

  TEntityContentPresenter = class(TCustomContentPresenter)
  public
    function EntityName: string;
    function EntityViewName: string;
  end;

  TEntityDialogPresenter = class(TCustomDialogPresenter)
  public
    function EntityName: string;
    function EntityViewName: string;
  end;

implementation





{ TCustomEntityContentPresenter }

function TEntityContentPresenter.EntityName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityName);
end;

function TEntityContentPresenter.EntityViewName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityViewName);
end;

{ TEntityDialogPresenter }

function TEntityDialogPresenter.EntityName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityName);
end;

function TEntityDialogPresenter.EntityViewName: string;
begin
  Result := ViewInfo.OptionValue(TViewActivityOptions.EntityViewName);
end;

end.
