unit SettingsView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  SettingsPresenter, cxPC, db, cxStyles, cxInplaceContainer, cxVGrid,
  cxDBVGrid, StdCtrls, cxRadioGroup, cxPCdxBarPopupMenu;

type
  TfrSettingsView = class(TfrCustomContentView, ISettingsView)
    dsCommonAppSettings: TDataSource;
    dsAliasAppSettings: TDataSource;
    dsHostAppSettings: TDataSource;
    cxGroupBox1: TcxGroupBox;
    chCommonAppSettings: TcxRadioButton;
    chAliasAppSettings: TcxRadioButton;
    chHostAppSettings: TcxRadioButton;
    pcAppSettings: TcxPageControl;
    tsCommonAppSettings: TcxTabSheet;
    grCommonAppSettings: TcxDBVerticalGrid;
    tsAliasAppSettings: TcxTabSheet;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    tsHostAppSettings: TcxTabSheet;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    procedure chAppSettingsKindClick(Sender: TObject);
    procedure grCommonAppSettingsDrawValue(Sender: TObject;
      ACanvas: TcxCanvas; APainter: TcxvgPainter;
      AValueInfo: TcxRowValueInfo; var Done: Boolean);
  private
  protected
    procedure BindAppSettingsData(ACommonData, AAliasData, AHostData: TDataSet);
    procedure Initialize; override;
  end;



implementation

{$R *.dfm}


{ TfrShellSettingsView }

procedure TfrSettingsView.BindAppSettingsData(ACommonData, AAliasData,
  AHostData: TDataSet);
begin
  LinkDataSet(dsCommonAppSettings, ACommonData);
  LinkDataSet(dsAliasAppSettings, AAliasData);
  LinkDataSet(dsHostAppSettings, AHostData);
end;

procedure TfrSettingsView.chAppSettingsKindClick(Sender: TObject);
begin
  pcAppSettings.ActivePageIndex := TcxRadioButton(Sender).Tag;
end;

procedure TfrSettingsView.Initialize;
begin
  pcAppSettings.HideTabs := true;
  pcAppSettings.ActivePageIndex := 0;
  chCommonAppSettings.Checked := true;
end;

procedure TfrSettingsView.grCommonAppSettingsDrawValue(
  Sender: TObject; ACanvas: TcxCanvas; APainter: TcxvgPainter;
  AValueInfo: TcxRowValueInfo; var Done: Boolean);
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

end.
