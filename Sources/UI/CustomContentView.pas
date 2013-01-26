unit CustomContentView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomView, cxLookAndFeelPainters, ImgList, cxGraphics,
  ActnList, cxPropertiesStore, cxControls, cxContainer, cxEdit, cxGroupBox,
  Menus, cxLabel, StdCtrls, cxButtons, cxLookAndFeels, UIClasses,
  ICommandBarImpl;

type
  TfrCustomContentView = class(TfrCustomView, IContentView)
  end;


implementation

{$R *.dfm}




end.
