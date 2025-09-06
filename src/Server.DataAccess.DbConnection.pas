unit Server.DataAccess.DbConnection;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
  Data.DB, FireDAC.Comp.Client, REST.Backend.EMSServices, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB,
  REST.Backend.EMSFireDAC, Server.DataAccess.DbParams;

type

  TDbConnection = class
  private
    FFDConnection: TFDConnection;
    FDbParams: TDbParams;
    procedure Connect();
  public
    constructor Create(ADbParams: TDbParams);
    destructor Destroy; override;
  public
    function GetFDConnection: TFDConnection;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function IsConnected: Boolean;
    procedure CloseConnection;
  public
    function OpenSql(const ASql: String): TDataSet;
    procedure ExecSql(const ASql: String);
    function GetSequenceValue(ASequenceName: String): Int64;
    function CheckIsExistsBySql(ASql: String): Boolean;
  end;

implementation

{ TDbConnection }

function TDbConnection.CheckIsExistsBySql(ASql: String): Boolean;
var
  Dts: TDataSet;
begin
  Dts := OpenSql(ASql);
  try
    Result := not Dts.IsEmpty;
  finally
    FreeAndNil(Dts);
  end;
end;

procedure TDbConnection.CloseConnection;
begin
  FFDConnection.Connected := False;
end;

procedure TDbConnection.Commit;
begin
  FFDConnection.Commit;
end;

procedure TDbConnection.Connect;
begin
  try
    FFDConnection.DriverName := 'FB';
    FFDConnection.Params.Values['Server'] := FDbParams.Host;
    FFDConnection.Params.Values['Port'] := FDbParams.Port.ToString;
    FFDConnection.Params.Values['User_Name'] := FDbParams.User;
    FFDConnection.Params.Values['Password'] := FDbParams.Pass;
    FFDConnection.Params.Values['Database'] := FDbParams.DbName;
//    if (not FDbParams.FbClientPath.IsEmpty) then
//      FFDConnection.Params.Values['VendorLib'] := IncludeTrailingPathDelimiter(FDbParams.FbClientPath) + 'fbclient.dll';
    FFDConnection.Connected := True;
  except on E: Exception do
    begin
      raise E;
    end;
  end;
end;

constructor TDbConnection.Create(ADbParams: TDbParams);
begin
  FDbParams := ADbParams;
  FFDConnection := TFDConnection.Create(nil);
  Connect();
end;

destructor TDbConnection.Destroy;
begin
  if FFDConnection.Connected then
    FFDConnection.Connected := False;
  FreeAndNil(FFDConnection);
  inherited;
end;

procedure TDbConnection.ExecSql(const ASql: String);
begin
  FFDConnection.ExecSQL(ASql);
end;

function TDbConnection.GetFDConnection: TFDConnection;
begin
  Result := FFDConnection;
end;

function TDbConnection.GetSequenceValue(ASequenceName: String): Int64;
begin
 Result := GetFDConnection
    .ExecSQLScalar('SELECT NEXT VALUE FOR ' + ASequenceName + ' FROM RDB$DATABASE');
end;

function TDbConnection.IsConnected: Boolean;
begin
  Result := FFDConnection.Connected;
end;

function TDbConnection.OpenSql(const ASql: String): TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  Qry.Connection := FFDConnection;
  Qry.Open(ASql);
  Result := Qry;
end;

procedure TDbConnection.Rollback;
begin
  FFDConnection.Rollback;
end;

procedure TDbConnection.StartTransaction;
begin
  FFDConnection.StartTransaction;
end;

end.
