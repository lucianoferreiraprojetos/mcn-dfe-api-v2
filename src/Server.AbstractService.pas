unit Server.AbstractService;

interface

uses
  Server.AppLogger, Server.AppConfig, Server.DataAccess.DbParams,
  Server.DataAccess.DbConnection;

type

  TAbstractService = class
  private
    FIsOwnerDbConnection: Boolean;
    FDbConnection: TDbConnection;
  public
    constructor Create; overload;
    constructor Create(ADbConnection: TDbConnection); overload;
    destructor Destroy; override;
  public
    procedure StartTransaction();
    procedure CommitTransaction();
    procedure RollbackTranscation();
    procedure CloseConnection();
    function GetDbConnection: TDbConnection;
  end;

implementation

uses
  System.SysUtils;

{ TAbstractService }

constructor TAbstractService.Create;
begin
  FIsOwnerDbConnection := True;
  FDbConnection := TDbConnection.Create(AppConfig.GetDbParams);
end;

constructor TAbstractService.Create(ADbConnection: TDbConnection);
begin
  FIsOwnerDbConnection := False;
  FDbConnection := ADbConnection;
end;

procedure TAbstractService.CloseConnection;
begin
  if (FIsOwnerDbConnection) then
    GetDbConnection.CloseConnection;
end;

procedure TAbstractService.CommitTransaction;
begin
  if (FIsOwnerDbConnection) then
    GetDbConnection.Commit;
end;

destructor TAbstractService.Destroy;
begin
  if (FIsOwnerDbConnection) then
  begin
    FreeAndNil(FDbConnection);
  end;
  inherited;
end;

function TAbstractService.GetDbConnection: TDbConnection;
begin
  Result := FDbConnection;
end;

procedure TAbstractService.RollbackTranscation;
begin
  if (FIsOwnerDbConnection) then
    GetDbConnection.Rollback;
end;

procedure TAbstractService.StartTransaction;
begin
  if (FIsOwnerDbConnection) then
  begin
    GetDbConnection.StartTransaction;
  end;
end;

end.
