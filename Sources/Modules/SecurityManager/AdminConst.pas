unit AdminConst;

interface
uses CommonViewIntf, variants;

const
  VIEW_SECURITYPOLICY = 'views.security.policy';
  VIEW_SECURITYPOLICYRES = 'views.security.policyres';
  VIEW_SECURITYPERMEFFECTIVE = 'views.security.permeffective';

type
  TSecurityPolicyPresenterData = class(TPresenterData)
  private
    FPolID: variant;
    procedure SetPolID(const Value: variant);
  published
    property PolID: variant read FPolID write SetPolID;
  end;

  TSecurityPermEffectivePresenterData = class(TPresenterData)
  private
    FPermID: string;
    FResID: string;
    FPolID: string;
    procedure SetPermID(const Value: string);
    procedure SetResID(const Value: string);
    procedure SetPolID(const Value: string);
  published
    property PolID: string read FPolID write SetPolID;
    property PermID: string read FPermID write SetPermID;
    property ResID: string read FResID write SetResID;
  end;

implementation

{ TSecurityPolicyPresenterData }

procedure TSecurityPolicyPresenterData.SetPolID(const Value: variant);
begin
  FPolID := Value;
  PresenterID := Value;
end;

{ TSecurityPermEffectivePresenterData }

procedure TSecurityPermEffectivePresenterData.SetPermID(
  const Value: string);
begin
  FPermID := Value;
  PresenterID := FPolID + FPermID + FResID;
end;

procedure TSecurityPermEffectivePresenterData.SetPolID(
  const Value: string);
begin
  FPolID := Value;
  PresenterID := FPolID + FPermID + FResID;
end;

procedure TSecurityPermEffectivePresenterData.SetResID(
  const Value: string);
begin
  FResID := Value;
  PresenterID := FPolID + FPermID + FResID;
end;

end.
