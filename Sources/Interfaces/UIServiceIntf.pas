unit UIServiceIntf;

interface

const
  ET_STATUSBARMESSAGE = '{F43E594D-6A5B-4762-A599-9286A9E86BD5}';
  ET_WAITBOX_START ='{E2D75073-4CEE-485C-A7F7-66D1DC351897}';
  ET_WAITBOX_STOP = '{D6616EE3-B4CE-4DAC-A74E-B8FFBC78C11C}';
  ET_NOTIFY_MESSAGE = '{A6B4B2EC-28CE-43A3-A733-E843F0CE238D}';
  ET_NOTIFY_ACCEPT = '{47857789-AAB1-4AAF-97A1-292E48C5EEDD}';

type

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

  IUIService = interface
  ['{20005BF6-C242-4C36-8967-EBB976354DDE}']

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

end.
