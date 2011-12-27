unit frDataSet;

interface
uses
  Windows, Classes, frxClass, frxCustomDB, DB, coreClasses, EntityServiceIntf,
  ShellIntf, Graphics;

type
  TfrDataSet = class(TfrxCustomQuery)
  private
    FDSProxy: IDataSetProxy;
    FSQL: TStringList;
    procedure OnChangeSQLText(Sender: TObject);
  protected
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetSQL(Value: TStrings); override;
    function GetSQL: TStrings; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure UpdateParams; override;
  end;


implementation
{$R frDataSet.res}

uses
  fs_iinterpreter, frxDsgnIntf, frxRes;

{ TfrReportDataSet }

constructor TfrDataSet.Create(AOwner: TComponent);
begin
  FDSProxy := App.Entities.GetDataSetProxy(Self);
  DataSet := FDSProxy.DataSet;
  FSQL := TStringList.Create;
  FSQL.OnChange := OnChangeSQLText;
  inherited;
end;

destructor TfrDataSet.Destroy;
begin
  FSQL.OnChange := nil;
  FSQL.Free;
  inherited;
end;

class function TfrDataSet.GetDescription: String;
begin
  Result := 'TfrDataSet';
end;

function TfrDataSet.GetSQL: TStrings;
begin
  Result := FSQL;
end;

procedure TfrDataSet.OnChangeSQLText(Sender: TObject);
begin
  FDSProxy.CommandText := FSQL.Text;
end;

procedure TfrDataSet.SetMaster(const Value: TDataSource);
begin
  FDSProxy.Master := Value;
end;

procedure TfrDataSet.SetSQL(Value: TStrings);
begin
  FSQL.Assign(Value);
end;

procedure TfrDataSet.UpdateParams;
begin
  frxParamsToTParams(Self, FDSProxy.Params);
end;

{////////////// REGISTERED ////////////////////////////////////////////////}
var
  Bitmap: TBitmap;

function LoadImage(const ResName: string): TBitmap;
var
  ImgRes: TResourceStream;
begin
  if Bitmap = nil then
    Bitmap := Graphics.TBitmap.Create;

  ImgRes := TResourceStream.Create(HInstance, ResName, 'file');
  try
    Bitmap.LoadFromStream(ImgRes);
  finally
    ImgRes.Free;
  end;
  Result := Bitmap;
end;

type
  TFunctions = class(TfsRTTIModule)
  public
   constructor Create(AScript: TfsScript); override;
  end;

{ TFunctions }

constructor TFunctions.Create;
begin
  inherited Create(AScript);
  AScript.AddClass(TfrDataSet, 'TfrxCustomQuery');
end;

 
initialization

  frxObjects.RegisterObject1(TfrDataSet, LoadImage('FR_DATASET_IMAGE'));
  fsRTTIModules.Add(TFunctions);

finalization
  frxObjects.Unregister(TfrDataSet);

  if Bitmap <> nil then Bitmap.Free;

end.
