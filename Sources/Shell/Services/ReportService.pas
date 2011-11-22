unit ReportService;

interface

uses
  Windows, SysUtils, Classes, ReportServiceIntf, Contnrs, Variants, CoreClasses,
  SecurityIntf, EntityServiceIntf;

const
  SECURITY_RES_PROVIDER_ID = 'security.resprovider.app.reports';

type

  TReport = class;

  TDesignReportEvent = procedure(Sender: TReport; Caller: TWorkItem) of object;


  TReport = class(TComponent, IReport, ISecurityResNode)
  private
    FWorkItem: TWorkItem;
    FReportName: string;
    FCaption: string;
    FGroup: string;
    FTemplate: string;
    FParamValues: array of variant;
    FParamNames: TStringList;

    //FOnExecuteReport: TExecuteReportEvent;
    FOnDesignReport: TDesignReportEvent;
    procedure GetParamValueCallback(const AName: string; var AValue: Variant);
  protected
    function ReportName: string;

    function GetGroup: string;
    procedure SetGroup(const AValue: string);

    function GetCaption: string;
    procedure SetCaption(const AValue: string);

    function GetTemplate: string;
    procedure SetTemplate(const AValue: string);

    procedure Execute(Caller: TWorkItem; ExecuteAction: TReportExecuteAction = reaExecute);
    procedure Design(Caller: TWorkItem);

    function GetParam(const AName: string): Variant;
    procedure SetParam(const AName: string; AValue: Variant);

    //ISecurityResNode
    function GetSecurityResNodeID: string;
    function ISecurityResNode.ID = GetSecurityResNodeID;
    function GetSecurityResNodeName: string;
    function ISecurityResNode.Name = GetSecurityResNodeName;
    function GetSecurityResNodeDescription: string;
    function ISecurityResNode.Description = GetSecurityResNodeDescription;
  public
    constructor Create(AOwner: TComponent; const AReportName: string; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

  TReportService = class(TComponent, IReportService, ISecurityResProvider)
  private
    FEntities: IEntityManagerService;
    FReports: TComponentList;
    FFactories: TComponentList;
    FWorkItem: TWorkItem;
    function GetLauncher(const ATemplate: string): IReportLauncher;
    function InternalAdd(const AName: string): integer;
    function Find(const AName: string): integer;
    function GetConnection: IEntityStorageConnection;
    procedure DoDesignReport(Sender: TReport; Caller: TWorkItem);
    procedure ReportProgressCallback(AProgressState: TReportProgressState);
  protected
    //IReportManagerService
    function Count: integer;
    function Add(const AName: string): IReport;
    procedure Remove(const AName: string);
    procedure Delete(AIndex: integer);
    procedure Clear;
    function Get(AIndex: integer): IReport;
    function GetReport(const AName: string): IReport;
    procedure RegisterLauncherFactory(Factory: TComponent);
    procedure UnRegisterLauncherFactory(Factory: TComponent);

    //ISecurityResProvider
    function GetSecurityResProviderID: string;
    function ISecurityResProvider.ID = GetSecurityResProviderID;
    function GetSecurityTopRes: IInterfaceList;
    function ISecurityResProvider.GetTopRes = GetSecurityTopRes;
    function GetSecurityChildRes(const AParentResID: string): IInterfaceList;
    function ISecurityResProvider.GetChildRes = GetSecurityChildRes;
    function GetSecurityGetRes(const ID: string): ISecurityResNode;
    function ISecurityResProvider.GetRes = GetSecurityGetRes;
  public
    constructor Create(AOwner: TComponent; AWorkItem: TWorkItem); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TReportService }

function TReportService.InternalAdd(const AName: string): integer;
var
  Item: TReport;
begin
  Item := TReport.Create(Self, AName, FWorkItem);

  Item.FOnDesignReport := DoDesignReport;
  Result := FReports.Add(Item);
end;

function TReportService.Count: integer;
begin
  Result := FReports.Count;
end;

constructor TReportService.Create(AOwner: TComponent; AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FReports := TComponentList.Create(true);
  FFactories := TComponentList.Create(false);
  FWorkItem := AWorkItem;
  FEntities := FWorkItem.Services[IEntityManagerService] as IEntityManagerService;

//  (FWorkItem.Services[ISecurityService] as ISecurityService).RegisterResProvider(Self);
end;


function TReportService.GetLauncher(const ATemplate: string): IReportLauncher;
var
  I: integer;
  Factory: IReportLauncherFactory;
begin
  Result := nil;
  for I := 0 to FFactories.Count - 1 do
  begin
    FFactories[I].GetInterface(IReportLauncherFactory, Factory);
    Result := Factory.GetLauncher(GetConnection, ATemplate);
    if Result <> nil then Break;
  end;

  if Result = nil then
    raise Exception.Create('Report factory not found.');
end;

destructor TReportService.Destroy;
begin
  FReports.Free;
  FFactories.Free;
  inherited;
end;

procedure TReportService.DoDesignReport(Sender: TReport; Caller: TWorkItem);
var
  Intf: IReportLauncher;
begin
  (FWorkItem.Services[ISecurityService] as ISecurityService).
     DemandPermission(SECURITY_PERMISSION_REPORT_ENGINE_ACCESS, Sender.ReportName);

  Intf := GetLauncher(Sender.GetTemplate);
  if Intf <> nil then
    Intf.Design(Caller);
end;


function TReportService.Find(const AName: string): integer;
begin
  for Result := 0 to FReports.Count - 1 do
    if SameText(AName, TReport(FReports[Result]).ReportName) then Exit;
  Result := -1;
end;

function TReportService.Get(AIndex: integer): IReport;
begin
  FReports[AIndex].GetInterface(IReport, Result)
end;

function TReportService.GetConnection: IEntityStorageConnection;
begin
  Result := FEntities.Connections.GetDefault;
end;

function TReportService.GetReport(const AName: string): IReport;
var
  Idx: integer;
begin
  Idx := Find(AName);
  if Idx = -1 then
    raise Exception.Create('Report ' + AName + ' not found');
    
  FReports[Idx].GetInterface(IReport, Result);
end;


procedure TReportService.RegisterLauncherFactory(Factory: TComponent);
var
  Intf: IReportLauncherFactory;
begin
  if not Factory.GetInterface(IReportLauncherFactory, Intf) then
    raise Exception.Create('Bad report factory');

  FFactories.Add(Factory);
end;

procedure TReportService.UnRegisterLauncherFactory(Factory: TComponent);
begin
  FFactories.Remove(Factory);
end;


{ TReport }

constructor TReport.Create(AOwner: TComponent; const AReportName: string;
  AWorkItem: TWorkItem);
begin
  inherited Create(AOwner);
  FReportName := AReportName;
  FParamNames := TStringList.Create;
  FWorkItem := AWorkItem;
end;

procedure TReport.Design(Caller: TWorkItem);
begin
  if Assigned(FOnDesignReport) then
    FOnDesignReport(Self, Caller);
end;

destructor TReport.Destroy;
begin
  FParamNames.Free;
  inherited;
end;

procedure TReport.Execute(Caller: TWorkItem;
  ExecuteAction: TReportExecuteAction = reaExecute);
var
  Intf: IReportLauncher;
begin
{  (FWorkItem.Services[ISecurityService] as ISecurityService).
    DemandPermission(SECURITY_PERMISSION_REPORT_EXECUTE, FReportName);}

  Intf :=  TReportService(Owner).GetLauncher(FTemplate);
  if Intf <> nil then
    Intf.Execute(Caller, ExecuteAction, GetParamValueCallback,
      TReportService(Owner).ReportProgressCallback, FCaption)
  else
    raise Exception.Create('Report launcher for template: ' + FTemplate + ' not found');

end;

function TReport.GetCaption: string;
begin
  Result := FCaption;
end;

function TReport.GetGroup: string;
begin
  Result := FGroup;
end;

function TReport.GetParam(const AName: string): Variant;
var
  Idx: integer;
begin
  Result := Unassigned;
  Idx := FParamNames.IndexOf(AName);
  if Idx <> - 1 then
    Result := FParamValues[Idx];
end;

procedure TReport.GetParamValueCallback(const AName: string;
  var AValue: Variant);
begin
  AValue := GetParam(AName);
end;

function TReport.GetSecurityResNodeDescription: string;
begin
  Result := FGroup;
end;

function TReport.GetSecurityResNodeID: string;
begin
  Result := FReportName;
end;

function TReport.GetSecurityResNodeName: string;
begin
  Result := FCaption;
end;

function TReport.GetTemplate: string;
begin
  Result := FTemplate;
end;

function TReport.ReportName: string;
begin
  Result := FReportName;
end;

procedure TReport.SetCaption(const AValue: string);
begin
  FCaption := AValue;
end;


procedure TReport.SetGroup(const AValue: string);
begin
  FGroup := AValue;
end;

procedure TReport.SetParam(const AName: string; AValue: Variant);
var
  Idx: integer;
begin
  Idx := FParamNames.IndexOf(AName);
  if Idx = - 1 then
  begin
    Idx := FParamNames.Add(AName);
    SetLength(FParamValues, Idx + 1);
  end;

  FParamValues[Idx] := AValue;
end;

procedure TReport.SetTemplate(const AValue: string);
begin
  FTemplate := AValue;
end;

procedure TReportService.Clear;
begin
  FReports.Clear;
end;

procedure TReportService.Delete(AIndex: integer);
begin
  FReports.Delete(AIndex);
end;

procedure TReportService.Remove(const AName: string);
var
  Idx: integer;
begin
  Idx := Find(AName);
  if Idx <> -1 then
    Delete(Idx);
end;

function TReportService.Add(const AName: string): IReport;
var
  Idx: integer;
begin
  Idx := Find(AName);
  if Idx <> -1 then
    raise Exception.Create('Duplicate report: ' + AName);

  Idx := InternalAdd(AName);
  Result := Get(Idx);
end;

procedure TReportService.ReportProgressCallback(
  AProgressState: TReportProgressState);
begin
  case AProgressState of
    rpsStart: FWorkItem.EventTopics[ET_REPORT_PROGRESS_START].Fire;
    rpsFinish: FWorkItem.EventTopics[ET_REPORT_PROGRESS_FINISH].Fire;
    rpsProcess: FWorkItem.EventTopics[ET_REPORT_PROGRESS_PROCESS].Fire;
  end;
end;



function TReportService.GetSecurityChildRes(
  const AParentResID: string): IInterfaceList;
begin
  Result := TInterfaceList.Create;
end;

function TReportService.GetSecurityResProviderID: string;
begin
  Result := SECURITY_RES_PROVIDER_ID;
end;

function TReportService.GetSecurityTopRes: IInterfaceList;
var
  I: integer;
begin
  Result := TInterfaceList.Create;
  for I := 0 to Count - 1 do
    Result.Add(Get(I) as ISecurityResNode);
end;

function TReportService.GetSecurityGetRes(
  const ID: string): ISecurityResNode;
begin
  Result := GetReport(ID) as ISecurityResNode;
end;

end.
