unit Server.DataAccess.SqlBuilder;

interface

uses
  Server.DataAccess.DbConnection, Server.DataAccess.UpdateSQL,
  Server.DataAccess.CustomQuerySQL, Server.DataAccess.DeleteSQL,
  Server.DataAccess.QuerySQL;

type

  IDeleteSQL = Server.DataAccess.DeleteSQL.IDeleteSQL;
  TDeleteSQL = Server.DataAccess.DeleteSQL.TDeleteSQL;

  IUpdateSQL = Server.DataAccess.UpdateSQL.IUpdateSQL;
  TUpdateSQL = Server.DataAccess.UpdateSQL.TUpdateSQL;

  IQuerySQL = Server.DataAccess.CustomQuerySQL.IQuerySQL;
  TQuerySQL = Server.DataAccess.CustomQuerySQL.TQuerySQL;

  ISqlBuilder = interface
    ['{5DE8FE4A-E685-4AB4-85B7-C9C7D9666280}']
    function GetUpdateSQL(const ATableName: String): IUpdateSQL;
    function GetDeleteSQL(const ATableName: String): IDeleteSQL;
    function GetQuerySQL: IQuerySQL;
    property Update[const ATableName: String]: IUpdateSQL read GetUpdateSQL;
    property Delete[const ATableName: String]: IDeleteSQL read GetDeleteSQL;
    property Query: IQuerySQL read GetQuerySQL;
  end;

  ISqlBuilder<T: class> = interface
    ['{072742DB-B896-4353-A31F-3DA977DCFA9A}']
  end;

  TSqlBuilder = class(TInterfacedObject,ISqlBuilder)
  private
    FDbConnection: TDbConnection;
    constructor Create(ADbConnection: TDbConnection);
    function GetUpdateSQL(const ATableName: String): IUpdateSQL;
    function GetDeleteSQL(const ATableName: String): IDeleteSQL;
    function GetQuerySQL: IQuerySQL;
  public
    property Update[const ATableName: String]: IUpdateSQL read GetUpdateSQL;
    property Delete[const ATableName: String]: IDeleteSQL read GetDeleteSQL;
    property Query: IQuerySQL read GetQuerySQL;
  public
    class function New(ADbConnection: TDbConnection): ISqlBuilder;
  end;

implementation

{ TSqlBuilder }

constructor TSqlBuilder.Create(ADbConnection: TDbConnection);
begin
  FDbConnection := ADbConnection;
end;

function TSqlBuilder.GetDeleteSQL(const ATableName: String): IDeleteSQL;
begin
  Result := TDeleteSQL.New(FDbConnection,ATableName);
end;

function TSqlBuilder.GetQuerySQL: IQuerySQL;
begin
  Result := TQuerySQL.New(FDbConnection);
end;

function TSqlBuilder.GetUpdateSQL(const ATableName: String): IUpdateSQL;
begin
  Result := TUpdateSQL.New(FDbConnection,ATableName);
end;

class function TSqlBuilder.New(ADbConnection: TDbConnection): ISqlBuilder;
begin
  Result := Self.Create(ADbConnection);
end;

end.
