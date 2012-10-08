unit LicenseServiceIntf;

interface

const
  LicenseTypeStr: array[0..5] of string = ('Undefined', 'Demo', 'Freeware',
    'Commercial', 'Enterprise', 'Developer');

type
  TLicenseStatus = (lsNotRegistered, lsRegistered, lsExpired);
  TLicenseType = (ltUndefined, ltDemo, ltFreeware, ltCommercial, ltEnterprise, ltDeveloper);


  ILicenseService = interface
  ['{DB4FD3CF-4A43-45D6-AE72-7C2532C40008}']
    function GetStatus: TLicenseStatus;
    function GetType: TLicenseType;
    function GetExpires: string;
    function GetDescription: string;
    function GetData(const AName: string): string;
    function GetClientID: string;
  end;

implementation

end.
