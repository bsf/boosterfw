unit ConstUnit;

interface

const
  AGENT_NAME = 'BoosterUpdater';

type
  TShellCallbackProc = procedure of object;

  IShellView = interface
  ['{ECE88105-2B62-41E4-9F9A-6BB47C5FC5E6}']
    procedure SetOnShowCallback(ACallback: TShellCallbackProc);
    procedure SetOnUserCancelCallback(ACallback: TShellCallbackProc);
    procedure SetProgressPosition(AValue: integer);
    procedure SetProgressMax(AValue: integer);
    procedure SetTitle(const AValue: string);
    procedure SetInfo(const AValue: string);
  end;

implementation

end.
