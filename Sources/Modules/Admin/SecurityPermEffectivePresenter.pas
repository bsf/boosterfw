unit SecurityPermEffectivePresenter;

interface
uses CustomContentPresenter, UIClasses, coreClasses, ShellIntf, SecurityIntf,
  AdminConst, sysutils, classes, variants, db, UIStr;


type
  ISecurityPermEffectiveView = interface(IContentView)
  ['{D1A21631-0948-4CA9-9B39-EF204F9C6C6B}']
    procedure AddItem(const UserName, Perm, InheritByPerm, InheritByRes: string;
      State: TPermissionState);
  end;

  TSecurityPermEffectivePresenter = class(TCustomContentPresenter)
  private
    FPolicy: ISecurityPolicy;
    FResProvider: ISecurityResProvider;
    procedure FillList;
  protected
    procedure OnViewReady; override;
  end;

implementation

{ TSecurityPermEffectivePresenter }

procedure TSecurityPermEffectivePresenter.FillList;
var
  ds: TDataSet;
  resID: string;
  resName: string;
begin
  ds := FPolicy.GetPermEffective(WorkItem.State['PERMID'], WorkItem.State['RESID']);
  while not ds.Eof do
  begin
   resID := VarToStr(ds['INHERITBY_RESID']);
   resName := '';
   if (resID <> '') and (FResProvider <> nil) then
     resName := FResProvider.GetRes(resID).Name
   else
     resName := '';

   (GetView as ISecurityPermEffectiveView).
     AddItem(ds['USERNAME'], ds['PERM'], VarToStr(ds['INHERITBY_PERM']), resName,
       ds['STATE']);
    ds.Next;
  end;
end;

procedure TSecurityPermEffectivePresenter.OnViewReady;
begin
  FreeOnViewClose := true;

  FPolicy := App.Security.FindPolicy(WorkItem.State['POLID']);
  if FPolicy.ResProviderID <> '' then
  begin
    FResProvider := App.Security.GetResProvider(FPolicy.ResProviderID);
    ViewTitle := FResProvider.GetRes(WorkItem.State['RESID']).Name + ' [действующие разрешения]';
  end
  else
    ViewTitle := FPolicy.Name + ' [действующие разрешения]';

  (GetView as ISecurityPermEffectiveView).CommandBar.
    AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT, CmdClose);

  FillList;  
end;

end.
