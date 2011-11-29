unit AdminConst;

interface
uses UIClasses, variants, coreClasses;

resourcestring
  VIEW_SETTINGS_CAPTION = 'Settings';
  VIEW_USERACCOUNTS_CAPTION = 'Users';
  VIEW_SECURITYPOLICIES_TITLE = 'Permissions';

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

procedure Localization(const ALocale: string);

implementation

procedure Localization_ru;
begin
  SetLocaleString(@VIEW_SETTINGS_CAPTION, 'Параметры системы');
  SetLocaleString(@VIEW_USERACCOUNTS_CAPTION,  'Диспетчер пользователей');
  SetLocaleString(@VIEW_SECURITYPOLICIES_TITLE, 'Настройка разрешений');
end;

procedure Localization(const ALocale: string);
begin
  if ALocale = 'ru-RU' then
    Localization_ru;

end;


end.
