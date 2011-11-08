unit SettingsView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CustomContentView, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ActnList, cxGroupBox,
  SettingsPresenter, cxPC, db, cxStyles, cxInplaceContainer, cxVGrid,
  cxDBVGrid, StdCtrls, cxRadioGroup;

type
  TfrSettingsView = class(TfrCustomContentView, ISettingsView)
    pcMain: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxGroupBox1: TcxGroupBox;
    chCommonAppSettings: TcxRadioButton;
    chAliasAppSettings: TcxRadioButton;
    chHostAppSettings: TcxRadioButton;
    pcAppSettings: TcxPageControl;
    tsCommonAppSettings: TcxTabSheet;
    grCommonAppSettings: TcxDBVerticalGrid;
    tsAliasAppSettings: TcxTabSheet;
    tsHostAppSettings: TcxTabSheet;
    dsCommonAppSettings: TDataSource;
    dsAliasAppSettings: TDataSource;
    dsHostAppSettings: TDataSource;
    dsDBSettings: TDataSource;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid3: TcxDBVerticalGrid;
    procedure chAppSettingsKindClick(Sender: TObject);
    procedure grCommonAppSettingsDrawValue(Sender: TObject;
      ACanvas: TcxCanvas; APainter: TcxvgPainter;
      AValueInfo: TcxRowValueInfo; var Done: Boolean);
  private
  protected
    procedure BindAppSettingsData(ACommonData, AAliasData, AHostData: TDataSet);
    procedure BindDBSettings(AData: TDataSet);
    procedure OnInitialize; override;
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

procedure TfrSettingsView.BindDBSettings(AData: TDataSet);
begin
  LinkDataSet(dsDBSettings, AData);
end;

procedure TfrSettingsView.chAppSettingsKindClick(Sender: TObject);
begin
  pcAppSettings.ActivePageIndex := TcxRadioButton(Sender).Tag;
end;

procedure TfrSettingsView.OnInitialize;
begin
  pcMain.ActivePageIndex := 0;
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
