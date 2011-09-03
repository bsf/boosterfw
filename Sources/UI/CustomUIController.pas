unit CustomUIController;

interface
uses Classes, CoreClasses, ShellIntf, Controls, CustomPresenter, Variants,
  ViewServiceIntf, ActivityServiceIntf, sysutils;

type
  TCustomUIController = class(TAbstractController)
  private
    procedure AtivityHandlerDefault(Sender: TObject);
  protected

    procedure RegisterView(const ViewURI: string;
      APresenter: TPresenterClass; AView: TViewClass);
    procedure RegisterExtension(const ViewURI: string; AExtension: TViewExtensionClass);

    procedure RegisterActivity(const ActivityID, ACategory, AGroup, ACaption: string;
      AUseActivityPermission: boolean = true); overload;

    procedure RegisterActivity(const ActivityID, ACategory, AGroup, ACaption: string;
      AHandler: TActionHandlerMethod; AUseActivityPermission: boolean = true); overload;

    procedure RegisterActivity(const ViewURI, ACategory, AGroup, ACaption: string;
      APresenter: TPresenterClass; AView: TViewClass; ASection: integer = 0); overload;

    procedure RegisterAction(const AName: string; AHandler: TActionHandlerMethod; ADataClass: TActionDataClass = nil);
    //
    procedure OnInitialize; virtual;
  public
    constructor Create(AOwner: TWorkItem); override;
  end;

implementation

{ TCustomUIController }



procedure TCustomUIController.AtivityHandlerDefault(Sender: TObject);
var
  _commandName: string;
  intf: ICommand;
begin
  Sender.GetInterface(ICommand, intf);
  if Assigned(intf) then
  begin
    _commandName := intf.Name;
    intf := nil;

    WorkItem.Actions[_commandName].Execute(WorkItem);

  end;
end;

constructor TCustomUIController.Create(AOwner: TWorkItem);
begin
  inherited Create(AOwner);
  OnInitialize;
end;


procedure TCustomUIController.OnInitialize;
begin

end;

procedure TCustomUIController.RegisterActivity(const ActivityID,
  ACategory, AGroup, ACaption: string; AHandler: TActionHandlerMethod;
  AUseActivityPermission: boolean);
begin
  RegisterActivity(ActivityID, ACategory, AGroup, ACaption, AUseActivityPermission);
  WorkItem.Root.Actions[ActivityID].SetHandler(AHandler);
end;

procedure TCustomUIController.RegisterView(const ViewUri: string;
  APresenter: TPresenterClass; AView: TViewClass);
var
  ViewSvc: IViewManagerService;
begin
  ViewSvc := IViewManagerService(WorkItem.Services[IViewManagerService]);
  ViewSvc.RegisterView(ViewUri, AView, APresenter);
end;

procedure TCustomUIController.RegisterActivity(const ViewURI, ACategory,
  AGroup, ACaption: string; APresenter: TPresenterClass;
  AView: TViewClass; ASection: integer);
var
  activityItem: IActivity;
begin
  activityItem := App.Activities.Items.Add(ViewURi);
  activityItem.Caption := ACaption;
  activityItem.Category := ACategory;
  activityItem.Group := AGroup;
  activityItem.Section := ASection;
  activityItem.SetHandler(AtivityHandlerDefault);

  RegisterView(ViewURI, APresenter, AView);

end;

procedure TCustomUIController.RegisterAction(const AName: string;
  AHandler: TActionHandlerMethod; ADataClass: TActionDataClass = nil);
begin
  WorkItem.Root.Actions[AName].SetHandler(AHandler);
  if Assigned(ADataClass) then
    WorkItem.Root.Actions[AName].SetDataClass(ADataClass);  
end;

procedure TCustomUIController.RegisterExtension(const ViewURI: string;
  AExtension: TViewExtensionClass);
var
  ViewSvc: IViewManagerService;
begin
  ViewSvc := IViewManagerService(WorkItem.Services[IViewManagerService]);
  ViewSvc.RegisterExtension(ViewURI, AExtension);
end;

procedure TCustomUIController.RegisterActivity(const ActivityID, ACategory,
  AGroup, ACaption: string; AUseActivityPermission: boolean);
var
  activityItem: IActivity;
begin
  activityItem := App.Activities.Items.Add(ActivityID, AUseActivityPermission);
  activityItem.Caption := ACaption;
  activityItem.Category := ACategory;
  activityItem.Group := AGroup;
  activityItem.SetHandler(AtivityHandlerDefault);
end;

end.
