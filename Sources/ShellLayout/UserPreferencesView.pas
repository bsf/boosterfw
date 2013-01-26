unit UserPreferencesView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  cxStyles, cxCheckBox, cxVGrid, cxInplaceContainer, UserPreferencesPresenter,
  ShellIntf, Menus, StdCtrls, cxButtons, cxDropDownEdit,
  cxDBVGrid, cxPC, DB, cxPCdxBarPopupMenu, cxClasses, CustomView;

type

  TfrUserPreferencesView = class(TfrCustomView, IUserPreferencesView)
    AppPreferencesDataSource: TDataSource;
    cxStyleRepository1: TcxStyleRepository;
    cxStyleValueChanged: TcxStyle;
    grAppPreference: TcxDBVerticalGrid;
    procedure grAppPreferenceDrawValue(Sender: TObject; ACanvas: TcxCanvas;
      APainter: TcxvgPainter; AValueInfo: TcxRowValueInfo;
      var Done: Boolean);
    procedure grAppPreferenceDrawRowHeader(Sender: TObject;
      ACanvas: TcxCanvas; APainter: TcxvgPainter;
      AHeaderViewInfo: TcxCustomRowHeaderInfo; var Done: Boolean);
  private
  protected

    procedure BindAppPreferences(AData: TDataSet);
    function GetSelectedAppSetting: string;
  end;


implementation

{$R *.dfm}

procedure TfrUserPreferencesView.BindAppPreferences(AData: TDataSet);
begin
  LinkDataSet(AppPreferencesDataSource, AData);
end;


function TfrUserPreferencesView.GetSelectedAppSetting: string;
begin
//  grAppPreference.row
end;

procedure TfrUserPreferencesView.grAppPreferenceDrawValue(Sender: TObject;
  ACanvas: TcxCanvas; APainter: TcxvgPainter; AValueInfo: TcxRowValueInfo;
  var Done: Boolean);
var
  field: TField;
begin
  if (AValueInfo.Row is TcxDBEditorRow) then
  begin
    field := (AValueInfo.Row as TcxDBEditorRow).Properties.DataBinding.Field;
    if Assigned(field) and (field.Tag = 1) then
      ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
  end;
end;

procedure TfrUserPreferencesView.grAppPreferenceDrawRowHeader(
  Sender: TObject; ACanvas: TcxCanvas; APainter: TcxvgPainter;
  AHeaderViewInfo: TcxCustomRowHeaderInfo; var Done: Boolean);
var
  field: TField;
begin
  if (AHeaderViewInfo.Row is TcxDBEditorRow) then
  begin
    field := (AHeaderViewInfo.Row as TcxDBEditorRow).Properties.DataBinding.Field;
    if Assigned(field) and (field.Tag = 1) then
    begin
      //(AHeaderViewInfo.Row as TcxDBEditorRow).Styles.Header := cxStyleValueChanged;
      ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];

    end
    else
      (AHeaderViewInfo.Row as TcxDBEditorRow).Styles.Header := nil;
  end;

end;


end.
