unit ViewServiceIntf;

interface
uses classes, CoreClasses, Controls, forms, Contnrs;

const
  ET_STATUSBARMESSAGE = '{F43E594D-6A5B-4762-A599-9286A9E86BD5}';
  ET_WAITBOX_START ='{E2D75073-4CEE-485C-A7F7-66D1DC351897}';
  ET_WAITBOX_STOP = '{D6616EE3-B4CE-4DAC-A74E-B8FFBC78C11C}';
  ET_NOTIFY_MESSAGE = '{A6B4B2EC-28CE-43A3-A733-E843F0CE238D}';
  ET_NOTIFY_ACCEPT = '{47857789-AAB1-4AAF-97A1-292E48C5EEDD}';

type
  IView = interface
  ['{D75B8CB7-65A8-45FC-841A-9AA02F6A8EEB}']
    function GetViewControl: TControl;
    function WorkItem: TWorkItem;
    function ViewURI: string;
    function Extensions(const AExtensionInterface: TGUID): TInterfaceList;
  end;

  TView = class(TForm, IView)
  private
    FViewURI: string;
    FWorkItem: TWorkItem;
    FExtensions: TComponentList;
  protected
    function GetViewControl: TControl; virtual; abstract;
    function ViewURI: string;
    function Extensions(const AExtensionInterface: TGUID): TInterfaceList;
  public
    constructor Create(AWorkItem: TWorkItem; // PresenterWorkItem
      const AViewURI: string); reintroduce; virtual;
    destructor Destroy; override;
    function WorkItem: TWorkItem;    
  end;

  TViewClass = class of TView;

  TPresenterData = class(TActionData)
  private
    FPresenterID: string;
    FWorkspace: string;
    FModalResult: TModalResult;
    FViewTitle: string;
    FBackViewUri: string;
  public
    constructor Create(const ActionURI: string); override;
  published
    property PresenterID: string read FPresenterID write FPresenterID;
    property Workspace: string read FWorkspace write FWorkspace;
    property ModalResult: TModalResult read FModalResult write FModalResult;
    property ViewTitle: string read FViewTitle write FViewTitle;
    property BackViewUri: string read FBackViewUri write FBackViewUri;
  end;

  TPresenter = class(TAbstractController)
  public
    // called by IViewManagerService
    class procedure Execute(Sender: IAction; AWorkItem: TWorkItem); virtual; abstract;
    class function ExecuteDataClass: TActionDataClass; virtual;
  end;

  TPresenterClass = class of TPresenter;

  TViewExtension = class(TComponent)
  protected
    function GetView: IView;
    function WorkItem: TWorkItem;
  end;

  TViewExtensionClass = class of TViewExtension;



  IMessageBox = interface
  ['{B1E6EC9F-96A2-46F0-81F8-BD23A38F41F5}']
    function ConfirmYesNo(const AMessage: string): boolean;
    function ConfirmYesNoCancel(const AMessage: string): integer;
    procedure InfoMessage(const AMessage: string);
    procedure ErrorMessage(const AMessage: string);
    procedure StatusBarMessage(const AMessage: string);
  end;

  IInputBox = interface
  ['{F414CFA3-EAC9-4969-BEF0-B602A2C78441}']
    function InputString(const APrompt: string; var AText: string): boolean;
  end;

  IWaitBox = interface
  ['{470B3C58-5A7A-446D-B71C-ACF9D826D411}']
    procedure StartWait;
    procedure StopWait;
  end;

  IViewStyle = interface
  ['{B489F70F-6D69-4FD3-BEC1-01C84DEE8633}']
    function Scale: integer;
  end;

  IViewManagerService = interface
  ['{ADB2E9D7-662B-4270-A72E-6C9FF7BC4E90}']

    procedure RegisterView(const ViewURI: string; AViewClass: TViewClass; APresenterClass: TPresenterClass);

    procedure RegisterExtension(const ViewURI: string;
      AExtensionClass: TViewExtensionClass);

    function GetView(const ViewURI: string; APresenter: TPresenter): IView;


   // function GetViewManifes(const ViewURI): IViewManifest;

    function MessageBox: IMessageBox;
    function InputBox: IInputBox;
    function WaitBox: IWaitBox;
    //
    function ViewStyle: IViewStyle;
    //
    procedure Notify(const AMessage: string);
    procedure NotifyExt(const AID, ASender, AMessage: string; ADateTime: TDateTime);
    procedure NotifyAccept(const AID: string);
  end;

implementation
uses ActivityServiceIntf, ShellIntf;

{ TView }

constructor TView.Create(AWorkItem: TWorkItem; const AViewURI: string);
begin
  inherited Create(nil);
  FViewURI := AViewURI;
  FWorkItem := AWorkItem;
  FExtensions := TComponentList.Create(true);
end;


destructor TView.Destroy;
begin
  FExtensions.Free;
  inherited;
end;

function TView.Extensions(
  const AExtensionInterface: TGUID): TInterfaceList;
var
  I: integer;
  Intf: IInterface;
begin
  Result := TInterfaceList.Create;
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TViewExtension) and
        Components[I].GetInterface(AExtensionInterface, Intf) then
      Result.Add(Intf);
end;

function TView.ViewURI: string;
begin
  Result := FViewURI;
end;

function TView.WorkItem: TWorkItem;
begin
  Result := FWorkItem;
end;

{ TPresenter }

class function TPresenter.ExecuteDataClass: TActionDataClass;
begin
  Result := nil;
end;

{ TViewExtension }

function TViewExtension.GetView: IView;
begin
  Result := Owner as IView;
end;

function TViewExtension.WorkItem: TWorkItem;
begin
  Result := GetView.WorkItem;
end;

{ TPresenterData }

constructor TPresenterData.Create(const ActionURI: string);
var
  viewInfo: IActivityInfo;
  I: integer;
begin
  inherited Create(ActionURI);
  AddOut('ModalResult');

  viewInfo := (App.WorkItem.Services[IActivityService] as IActivityService).ActivityInfo(ActionURI);

  for I := 0 to viewInfo.Params.Count - 1 do
    Add(viewInfo.Params[I]);

  for I := 0 to viewInfo.Outs.Count - 1 do
    AddOut(viewInfo.Outs[I]);


end;

end.
