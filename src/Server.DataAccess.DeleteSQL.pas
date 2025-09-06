unit Server.DataAccess.DeleteSQL;

interface

uses
  System.SysUtils, System.Generics.Collections, System.StrUtils, System.Types,
  System.TypInfo, System.Rtti,
  Server.DataAccess.DbConnection, Server.DataAccess.NativeQuery;

type

  IDeleteSQL = interface
    ['{73EF2E5D-9F52-4194-B04F-AD4483526FD6}']
    function AddWhereEq(const AColumnName: String; const AValue: Variant): IDeleteSQL;
    procedure ExecDelete(AIsForceDeleteWithoutWhere: Boolean = False);
  end;

  TDeleteSQL = class(TInterfacedObject,IDeleteSQL)
  private
    FDbConnection: TDbConnection;
    FTableName: String;
    FWhereList: TDictionary<String,Variant>;
    FIsForceDeleteWithoutWhere: Boolean;
    constructor Create(ADbConnection: TDbConnection; ATableName: String);
    destructor Destroy; override;
  public
    function AddWhereEq(const AColumnName: String; const AValue: Variant): IDeleteSQL;
    procedure ExecDelete(AIsForceDeleteWithoutWhere: Boolean = False);
  public
    class function New(ADbConnection: TDbConnection; ATableName: String): IDeleteSQL;
  end;

implementation

{ TDeleteSQL }

function TDeleteSQL.AddWhereEq(const AColumnName: String;
  const AValue: Variant): IDeleteSQL;
begin
  Result := Self;
  FWhereList.Add(AColumnName,AValue);
end;

constructor TDeleteSQL.Create(ADbConnection: TDbConnection; ATableName: String);
begin
  FDbConnection := ADbConnection;
  FTableName := ATableName;
  FIsForceDeleteWithoutWhere := False;
  FWhereList := TDictionary<String,Variant>.Create;
end;

destructor TDeleteSQL.Destroy;
begin
  FreeAndNil(FWhereList);
  inherited;
end;

procedure TDeleteSQL.ExecDelete(AIsForceDeleteWithoutWhere: Boolean = False);
var
  WhereConcat: String;
  Qry: INativeQuery;
begin
  FIsForceDeleteWithoutWhere := AIsForceDeleteWithoutWhere;

  for var Where in FWhereList do
  begin
    WhereConcat := WhereConcat +
      IfThen(WhereConcat.IsEmpty,'',' AND ') + '(' + Where.Key + ' = :' + Where.Key + ')';
  end;

  Qry := TNativeQuery.New(FDbConnection)
    .Add(Format('DELETE FROM %s ',[FTableName]));

  if (WhereConcat.IsEmpty) and (not AIsForceDeleteWithoutWhere) then
    raise Exception.Create('Error, delete without WHERE!!!')
  else
  begin
    if not WhereConcat.IsEmpty then
      Qry.Add('WHERE ' + WhereConcat);
  end;

  for var Param in FWhereList do
    Qry.SetParam(Param.Key,Param.Value);

  Qry.ExecSQL;
end;

class function TDeleteSQL.New(ADbConnection: TDbConnection;
  ATableName: String): IDeleteSQL;
begin
  Result := Self.Create(ADbConnection,ATableName);
end;

end.
