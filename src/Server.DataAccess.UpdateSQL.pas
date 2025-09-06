unit Server.DataAccess.UpdateSQL;

interface

uses
  System.SysUtils, System.Generics.Collections, System.StrUtils, System.Types,
  System.TypInfo, System.Rtti,
  Server.DataAccess.DbConnection, Server.DataAccess.NativeQuery;

type

  IUpdateSQL = interface
    ['{6B07471B-8CC6-40BF-A334-18B8C77D5A04}']
    function Add(const AColumnName: String; const AValue: Variant): IUpdateSQL; overload;
    function Add(const AColumnName: String; const AValue: TBytes): IUpdateSQL; overload;
    function AddWhereEq(const AColumnName: String; const AValue: Variant): IUpdateSQL;
    procedure ExecInsert;
    procedure ExecUpdate;
  end;

  TUpdateSQL = class(TInterfacedObject,IUpdateSQL)
  private
    FDbConnection: TDbConnection;
    FTableName: String;
    FValues: TDictionary<String,TValue>;
    FWhereList: TDictionary<String,Variant>;
    constructor Create(ADbConnection: TDbConnection; ATableName: String);
    destructor Destroy; override;
  public
    function Add(const AColumnName: String; const AValue: Variant): IUpdateSQL; overload;
    function Add(const AColumnName: String; const AValue: TBytes): IUpdateSQL; overload;
    function AddWhereEq(const AColumnName: String; const AValue: Variant): IUpdateSQL;
    procedure ExecInsert;
    procedure ExecUpdate;
  public
    class function New(ADbConnection: TDbConnection; ATableName: String): IUpdateSQL;
  end;

implementation

{ TUpdateSQL }

function TUpdateSQL.Add(const AColumnName: String;
  const AValue: Variant): IUpdateSQL;
begin
  Result := Self;
  FValues.Add(AColumnName,TValue.FromVariant(AValue));
end;

function TUpdateSQL.Add(const AColumnName: String;
  const AValue: TBytes): IUpdateSQL;
begin
  Result := Self;
  FValues.Add(AColumnName,TValue.From<TBytes>(AValue));
end;

function TUpdateSQL.AddWhereEq(const AColumnName: String;
  const AValue: Variant): IUpdateSQL;
begin
  Result := Self;
  FWhereList.Add(AColumnName,AValue);
end;

constructor TUpdateSQL.Create(ADbConnection: TDbConnection;
  ATableName: String);
begin
  FDbConnection := ADbConnection;
  FTableName := ATableName;
  FValues := TDictionary<String,TValue>.Create;
  FWhereList := TDictionary<String,Variant>.Create;
end;

destructor TUpdateSQL.Destroy;
begin
  FreeAndNil(FValues);
  FreeAndNil(FWhereList);
  inherited;
end;

procedure TUpdateSQL.ExecInsert;
var
  Columns: String;
  Params: String;
  Qry: INativeQuery;
begin

  for var LVal in FValues do
  begin
    Columns := Columns + IfThen(Columns.IsEmpty,'',',') + LVal.Key;
    Params := Params + IfThen(Params.IsEmpty,'',',') + ':' + LVal.Key;
  end;

  Qry := TNativeQuery.New(FDbConnection)
    .Add(Format('INSERT INTO %s (%s) VALUES (%s)',[FTableName,Columns,Params]));

  for var Param in FValues do
  begin
    if Param.Value.IsType<TBytes> then
      Qry.SetParam(Param.Key,Param.Value.AsType<TBytes>)
    else
      Qry.SetParam(Param.Key,Param.Value.AsVariant);
  end;

  Qry.ExecSQL;
end;

procedure TUpdateSQL.ExecUpdate;
var
  SetColumns: String;
  WhereConcat: String;
  Qry: INativeQuery;
begin

  for var LVal in FValues do
    SetColumns := SetColumns + IfThen(SetColumns.IsEmpty,'',',') + LVal.Key + ' = :' + LVal.Key;

  for var Where in FWhereList do
  begin
    WhereConcat := WhereConcat +
      IfThen(WhereConcat.IsEmpty,'',' AND ') + '(' + Where.Key + ' = :' + Where.Key + ')';
  end;

  if not WhereConcat.IsEmpty then
    WhereConcat := 'WHERE ' + WhereConcat;

  Qry := TNativeQuery.New(FDbConnection)
    .Add(Format('UPDATE %s SET %s %s',[FTableName,SetColumns,WhereConcat]));

  for var Param in FValues do
  begin
    if Param.Value.IsType<TBytes> then
      Qry.SetParam(Param.Key,Param.Value.AsType<TBytes>)
    else
      Qry.SetParam(Param.Key,Param.Value.AsVariant);
  end;

  for var Param in FWhereList do
    Qry.SetParam(Param.Key,Param.Value);

  Qry.ExecSQL;
end;

class function TUpdateSQL.New(ADbConnection: TDbConnection;
  ATableName: String): IUpdateSQL;
begin
  Result := Self.Create(ADbConnection,ATableName);
end;

end.
