unit Server.DataAccess.QuerySQL;

interface

uses
  Data.DB, System.Classes, System.Generics.Collections,
  Server.DataAccess.CustomQuerySQL, Server.DataAccess.DbConnection,
  Server.DataAccess.NativeQuery, Server.DataAccess.RttiUtil;

type

  IQuerySQL = Server.DataAccess.CustomQuerySQL.IQuerySQL;
  TQuerySQL = Server.DataAccess.CustomQuerySQL.TQuerySQL;

  IQuerySQL<T: class> = interface
    ['{8E715AA9-729D-41C5-B119-E3229A66E123}']
    function From(const ATableName: String; const AAlias: String = ''): IQuerySQL<T>; overload;
    function Join(const AJoinTableName: String; const AAlias: String; const AOn: String): IQuerySQL<T>;
    function WhereEq(const AWhereKey: String; const AValue: Variant): IQuerySQL<T>;
    function SelectAll: IQuerySQL<T>;
    function Select(const ASelectColumns: String): IQuerySQL<T>;
    function SelectColumn(const ASelectColumn: String; const ASelectColumnAs: String = ''): IQuerySQL<T>;
    function GetResultList: TObjectList<T>;
    function GetFirstSingleResult: T;
    function GetSingleResult: T;
    function IsEmpty: Boolean;
    function IsNotEmpty: Boolean;
  end;

  TQuerySQL<T: class> = class(TInterfacedObject,IQuerySQL<T>)
  private
    FInternalQuerySQL: IQuerySQL;
    constructor Create(ADbConnection: TDbConnection);
  public
    function From(const ATableName: String; const AAlias: String = ''): IQuerySQL<T>; overload;
    function Join(const AJoinTableName: String; const AAlias: String; const AOn: String): IQuerySQL<T>; overload;
    function WhereEq(const AWhereKey: String; const AValue: Variant): IQuerySQL<T>;
    function SelectAll: IQuerySQL<T>;
    function Select(const ASelectColumns: String): IQuerySQL<T>;
    function SelectColumn(const ASelectColumn: String; const ASelectColumnAs: String = ''): IQuerySQL<T>;
    function GetResultList: TObjectList<T>;
    function GetSingleResult: T;
    function GetFirstSingleResult: T;
    function IsEmpty: Boolean;
    function IsNotEmpty: Boolean;
  public
    class function New(ADbConnection: TDbConnection): IQuerySQL<T>;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.Variants;

{ TQuerySQL<T> }

constructor TQuerySQL<T>.Create(ADbConnection: TDbConnection);
begin
  FInternalQuerySQL := TQuerySQL.New(ADbConnection);
end;

function TQuerySQL<T>.From(const ATableName,
  AAlias: String): IQuerySQL<T>;
begin
  Result := Self;
  FInternalQuerySQL.From(ATableName,AAlias);
end;

function TQuerySQL<T>.GetFirstSingleResult: T;
begin
  Result := FInternalQuerySQL.GetFirstSingleResult(T) as T;
end;

function TQuerySQL<T>.GetResultList: TObjectList<T>;
begin
  Result := TObjectList<T>(FInternalQuerySQL.GetResultList(T));
end;

function TQuerySQL<T>.GetSingleResult: T;
begin
  Result := FInternalQuerySQL.GetFirstSingleResult(T) as T;
end;

function TQuerySQL<T>.IsEmpty: Boolean;
begin
  Result := FInternalQuerySQL.IsEmpty;
end;

function TQuerySQL<T>.IsNotEmpty: Boolean;
begin
  Result := FInternalQuerySQL.IsNotEmpty;
end;

function TQuerySQL<T>.Join(const AJoinTableName, AAlias,
  AOn: String): IQuerySQL<T>;
begin
  Result := Self;
  FInternalQuerySQL.Join(AJoinTableName,AAlias,AOn);
end;

class function TQuerySQL<T>.New(
  ADbConnection: TDbConnection): IQuerySQL<T>;
begin
  Result := Self.Create(ADbConnection);
end;

function TQuerySQL<T>.Select(
  const ASelectColumns: String): IQuerySQL<T>;
begin
  Result := Self;
  FInternalQuerySQL.Select(ASelectColumns);
end;

function TQuerySQL<T>.SelectAll: IQuerySQL<T>;
begin
  Result := Self;
  FInternalQuerySQL.SelectAll;
end;

function TQuerySQL<T>.SelectColumn(const ASelectColumn,
  ASelectColumnAs: String): IQuerySQL<T>;
begin
  Result := Self;
  FInternalQuerySQL.SelectColumn(ASelectColumn,ASelectColumnAs);
end;

function TQuerySQL<T>.WhereEq(const AWhereKey: String;
  const AValue: Variant): IQuerySQL<T>;
begin
  Result := Self;
  FInternalQuerySQL.WhereEq(AWhereKey,AValue);
end;

end.
