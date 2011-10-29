unit EntityCatalogIntf;

interface
uses CommonViewIntf, db, Classes, ShellIntf, CoreClasses,
  variants;

const
  ENT_OPER_STATE_CHANGE_DEFAULT = 'StateChange';

  ENT_INF_GID = 'INF_GID';
  ENT_INF_GID_OPER_DECODE = 'Decode';

  ACTION_ENTITY_NEW = 'actions.entity.new';
  ACTION_ENTITY_ITEM = 'actions.entity.item';

  ACTION_ENTITY_DETAIL_NEW = 'actions.entity.detail.new';
  ACTION_ENTITY_DETAIL = 'actions.entity.detail';

type
  TEntityNewActionData = class(TActionData)
  private
    FHID: variant;
    FEntityName: string;
  published
    property HID: Variant read FHID write FHID;
    property EntityName: string read FEntityName write FEntityName;
  end;

  TEntityItemActionData = class(TActionData)
  private
    FID: variant;
    FEntityName: string;
  published
    property ID: variant read FID write FID;
    property EntityName: string read FEntityName write FEntityName;
  end;

  TEntityActionData = class(TActionData)
  public
    constructor Create(const ActionURI: string); override;
  end;

  TEntityPresenterData = class(TPresenterData)
  end;

  TEntityPickListPresenterData = class(TEntityPresenterData, IPickListPresenterData)
  private
    FFilter: string;
    FID: Variant;
    FNAME: Variant;
  protected
    function GetFilter: string;
    function GetID: Variant;
    function GetName: Variant;
    procedure SetFilter(Value: string);
    procedure SetID(Value: Variant);
    procedure SetNameValue(Value: Variant);
    procedure IPickListPresenterData.SetName = SetNameValue;
  public
    constructor Create(const ActionURI: string); override;
  published
    property Filter: string read GetFilter write SetFilter;
    property ID: Variant read GetID write SetID;
    property NAME: Variant read GetNAME write SetNAMEValue;
  end;

  TEntitySelectorPresenterData = class(TEntityPresenterData)
  end;

  TEntityNewPresenterData = class(TEntityPresenterData)
  private
    FFocusField: string;
    FNextAction: string;
    FHID: variant;
  published
    property HID: Variant read FHID write FHID;
    property FOCUS_FIELD: string read FFocusField write FFocusField;
    property NEXT_ACTION: string read FNextAction write FNextAction;
  end;

  TEntityItemPresenterData = class(TEntityPresenterData)
  private
    FFocusField: string;
    FID: Variant;
    procedure SetID(const Value: Variant);
  published
    property ID: Variant read FID write SetID;
    property FOCUS_FIELD: string read FFocusField write FFocusField;
  end;

  IEntityItemView = interface(IContentView)
  ['{1DBB5B01-51A0-4BB0-85D2-D6724AEDC6F4}']
    procedure SetItemDataSet(ADataSet: TDataSet);
  end;

  TEntityListPresenterData = class(TEntityPresenterData)
  end;

  IEntityListView = interface(IContentView)
  ['{B1E6FCB6-EAC1-4B63-880F-C662B09579B4}']
    function Selection: ISelection;
    procedure SetListDataSet(ADataSet: TDataSet);
    procedure SetInfoText(const AText: string);    
  end;


  IEntityPickListView = interface(IDialogView)
  ['{87CC1751-FFA3-4F9E-9336-5C4E9D765593}']
    function Selection: ISelection;
    procedure SetFilterText(const AText: string);
    function GetFilterText: string;
    procedure SetListDataSet(ADataSet: TDataSet);
  end;


  IEntityJournalView = interface(IContentView)
  ['{254B9732-7666-4733-BC3C-6D9D078FC5A7}']
    function Selection: ISelection;
    function Tabs: ITabs;
    procedure SetInfoText(const AText: string);
    procedure SetJournalDataSet(ADataSet: TDataSet);
  end;

  TEntityOrgChartData = class(TEntityPresenterData)
  private
    FROOT_ID: Variant;
    procedure SetROOT_ID(const Value: Variant);
  published
    property ROOT_ID: Variant read FROOT_ID write SetROOT_ID;
  end;


implementation

uses SysUtils;


{ TEntityItemPresenterData }

procedure TEntityItemPresenterData.SetID(const Value: Variant);
begin
  FID := Value;
  PresenterID := VarToStr(Value);
end;


{ TEntityPickListPresenterData }

constructor TEntityPickListPresenterData.Create(const ActionURI: string);
begin
  inherited Create(ActionURI);
  AddOut('ID');
  AddOut('NAME');
end;

function TEntityPickListPresenterData.GetFilter: string;
begin
  Result := FFilter;
end;

function TEntityPickListPresenterData.GetID: Variant;
begin
  Result := FID;
end;

function TEntityPickListPresenterData.GetName: Variant;
begin
  Result := FName;
end;

procedure TEntityPickListPresenterData.SetFilter(Value: string);
begin
  FFilter := Value;
end;

procedure TEntityPickListPresenterData.SetID(Value: Variant);
begin
  FID := Value;
end;

procedure TEntityPickListPresenterData.SetNameValue(Value: Variant);
begin
  FName := Value;
end;

{ TEntityOrgChartData }

procedure TEntityOrgChartData.SetROOT_ID(const Value: Variant);
begin
  FROOT_ID := Value;
  PresenterID := VarToStr(Value);
end;

{ TEntityActionData }

constructor TEntityActionData.Create(const ActionURI: string);
begin
  inherited Create(ActionURI);
end;


end.
