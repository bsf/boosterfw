unit EntityCatalogIntf;

interface
uses UIClasses, db, Classes, ShellIntf, CoreClasses, variants,
  CustomContentPresenter, CustomDialogPresenter;

const
  ENT_OPER_STATE_CHANGE_DEFAULT = 'StateChange';

  ENT_INF_GID = 'INF_GID';
  ENT_INF_GID_OPER_DECODE = 'Decode';

  ACTION_ENTITY_NEW = 'actions.entity.new';
  ACTION_ENTITY_ITEM = 'actions.entity.item';

  ACTION_ENTITY_DETAIL_NEW = 'actions.entity.detail.new';
  ACTION_ENTITY_DETAIL = 'actions.entity.detail';

type
  TEntityActivityOptions = record
    const
      EntityName = 'EntityName';
      EntityViewName = 'EntityViewName';
  end;

  TEntityNewActionParams = record
    const
      HID = 'HID';
      EntityName = 'EntityName';
  end;

{  TEntityNewActionData = class(TActionData)
  private
    FHID: variant;
    FEntityName: string;
  published
    property HID: Variant read FHID write FHID;
    property EntityName: string read FEntityName write FEntityName;
  end;}

  TEntityItemActionParams = record
    const
      ID = 'ID';
      EntityName = 'EntityName';
  end;

  {TEntityItemActionData = class(TActionData)
  private
    FID: variant;
    FEntityName: string;
  published
    property ID: variant read FID write FID;
    property EntityName: string read FEntityName write FEntityName;
  end;}

  TEntityNewActivityParams = record
    const
      HID = 'HID';
      FOCUS_FIELD = 'FOCUS_FIELD';
      NEXT_ACTION = 'NEXT_ACTION';
  end;

  {
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
   }

  TEntityItemActivityParams = record
    const
      ID = 'ID';
      FOCUS_FIELD = 'FOCUS_FIELD';
  end;

{  TEntityItemPresenterData = class(TEntityPresenterData)
  private
    FFocusField: string;
    FID: Variant;
    procedure SetID(const Value: Variant);
  published
    property ID: Variant read FID write SetID;
    property FOCUS_FIELD: string read FFocusField write FFocusField;
  end;
 }





  


  

  TEntityOrgChartActivityParams = record
    const
      ROOT_ID = 'ROOT_ID';
  end;

{  TEntityOrgChartData = class(TEntityPresenterData)
  private
    FROOT_ID: Variant;
    procedure SetROOT_ID(const Value: Variant);
  published
    property ROOT_ID: Variant read FROOT_ID write SetROOT_ID;
  end;
 }

   TEntityContentPresenter = class(TCustomContentPresenter)
   const
      EntityNameOption = 'EntityName';
      EntityViewNameOption = 'EntityViewName';

   protected
     function EntityName: string; virtual;
     function EntityViewName: string; virtual;
   end;

   TEntityDialogPresenter = class(TCustomDialogPresenter)
   const
      EntityNameOption = 'EntityName';
      EntityViewNameOption = 'EntityViewName';

   protected
     function EntityName: string;
     function EntityViewName: string;
   end;
implementation





{ TCustomEntityContentPresenter }

function TEntityContentPresenter.EntityName: string;
begin
  Result := ViewInfo.OptionValue(EntityNameOption);
end;

function TEntityContentPresenter.EntityViewName: string;
begin
  Result := ViewInfo.OptionValue(EntityViewNameOption);
end;

{ TEntityDialogPresenter }

function TEntityDialogPresenter.EntityName: string;
begin
  Result := ViewInfo.OptionValue(EntityNameOption);
end;

function TEntityDialogPresenter.EntityViewName: string;
begin
  Result := ViewInfo.OptionValue(EntityViewNameOption);
end;

end.
