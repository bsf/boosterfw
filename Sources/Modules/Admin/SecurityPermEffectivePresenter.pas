unit SecurityPermEffectivePresenter;

interface
uses CustomPresenter, UIClasses, coreClasses, ShellIntf, SecurityIntf,
  AdminConst, sysutils, classes, variants, db, UIStr;


type
  ISecurityPermEffectiveView = interface(IContentView)
  ['{D1A21631-0948-4CA9-9B39-EF204F9C6C6B}']
    procedure AddItem(const UserName, Perm, InheritByPerm, InheritByRes: string;
      State: TPermissionState);
  end;

  TSecurityPermEffectivePresenter = class(TCustomPresenter)
  protected
    procedure OnViewReady; override;
  end;

implementation

{ TSecurityPermEffectivePresenter }


procedure TSecurityPermEffectivePresenter.OnViewReady;
var
  policy: ISecurityPolicy;
  ds: TDataSet;
  resID: string;
  resName: string;
  resPolicy: ISecurityPolicy;
  resPolID: string;
begin
  FreeOnViewClose := true;

  policy := App.Security.FindPolicy(WorkItem.State['POLID']);
  if policy.ResProviderID <> '' then
  begin
    if VarToStr(WorkItem.State['RESID']) <> '' then
      ViewTitle := App.Security.GetResProvider(policy.ResProviderID).
        GetRes(WorkItem.State['RESID']).Name + ' [действующие разрешени€]'
    else
      ViewTitle := policy.Name + ' [действующие разрешени€ - все элементы]';
  end
  else
    ViewTitle := policy.Name + ' [действующие разрешени€]';

  ds := policy.GetPermEffective(WorkItem.State['PERMID'], WorkItem.State['RESID']);
  while not ds.Eof do
  begin
   resPolID := VarToStr(ds['INHERITBY_POLID']);
   resID := VarToStr(ds['INHERITBY_RESID']);
   resName := '';
   resPolicy := App.Security.FindPolicy(resPolID);
   if resPolicy.ResProviderID <> '' then
     if resID <> '' then
       resName := App.Security.GetResProvider(resPolicy.ResProviderID).
         GetRes(resID).Name
     else
       resName := '¬се элементы'
   else
     resName := '';

   (GetView as ISecurityPermEffectiveView).
     AddItem(ds['USERNAME'], ds['PERM'], VarToStr(ds['INHERITBY_PERM']), resName,
       ds['STATE']);
    ds.Next;
  end;

  (GetView as ISecurityPermEffectiveView).CommandBar.
    AddCommand(COMMAND_CLOSE,
      GetLocaleString(@COMMAND_CLOSE_CAPTION), COMMAND_CLOSE_SHORTCUT);
  WorkItem.Commands[COMMAND_CLOSE].SetHandler(CmdClose);

end;

end.
