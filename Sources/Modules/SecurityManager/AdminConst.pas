unit AdminConst;

interface
uses UIClasses, variants;

const
  VIEW_SECURITYPOLICY = 'views.security.policy';
  VIEW_SECURITYPOLICYRES = 'views.security.policyres';
  VIEW_SECURITYPERMEFFECTIVE = 'views.security.permeffective';

type
  TSecurityPolicyActivityParams = record
    const
      PolID = 'POLID';
  end;

  TSecurityPermEffectiveActivityParams = record
    const
      PolID = 'POLID';
      PermID = 'PERMID';
      ResID = 'RESID';
  end;


implementation


end.
