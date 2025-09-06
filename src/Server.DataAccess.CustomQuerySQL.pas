unit Server.DataAccess.CustomQuerySQL;

interface

uses
  Data.DB, System.Classes, System.Generics.Collections,
  Server.DataAccess.DbConnection, Server.DataAccess.NativeQuery,
  Server.DataAccess.RttiUtil;

type

  IQuerySQL = interface
    ['{0BC6AC9E-7E94-4842-907B-147DC98E36FD}']
    function GetNativeQuery: INativeQuery;
    property SQL: INativeQuery read GetNativeQuery;
    function From(const ATableName: String; const AAlias: String = ''): IQuerySQL;
    function Join(const AJoinTableName: String; const AAlias: String; const AOn: String): IQuerySQL;
    function WhereEq(const AWhereKey: String; const AValue: Variant): IQuerySQL;
    function SelectAll: IQuerySQL;
    function Select(const ASelectColumns: String): IQuerySQL;
    function SelectColumn(const ASelectColumn: String; const ASelectColumnAs: String = ''): IQuerySQL;
    function IsEmpty: Boolean;
    function IsNotEmpty: Boolean;
    function GetDataSet: TDataSet;
    function GetResultList(AClazz: TClass): TObjectList<TObject>;
    function GetFirstSingleResult(AClazz: TClass): TObject;
    procedure GetDataSetForEach(AProcDataSetForEach: TProcDataSetForEach);
  end;

  TQuerySQL = class(TInterfacedObject,IQuerySQL)
  private
    FDbConnection: TDbConnection;
    FTableName: String;
    FTableAlias: String;
    FInternalQuerySQL: INativeQuery;
    FSelectList: TStringList;
    FWhereList: TStringList;
    FJoinList: TStringList;
    function GetNativeQuery: INativeQuery;
    function GetSelectConcat: String;
    function GetWhereConcat: String;
    constructor Create(ADbConnection: TDbConnection);
    destructor Destroy; override;
  public
    property SQL: INativeQuery read GetNativeQuery;
  public
    function From(const ATableName: String; const AAlias: String = ''): IQuerySQL;
    function Join(const AJoinTableName: String; const AAlias: String; const AOn: String): IQuerySQL;
    function WhereEq(const AWhereKey: String; const AValue: Variant): IQuerySQL;
    function SelectAll: IQuerySQL;
    function Select(const ASelectColumns: String): IQuerySQL;
    function SelectColumn(const ASelectColumn: String; const ASelectColumnAs: String = ''): IQuerySQL;
    function IsEmpty: Boolean;
    function IsNotEmpty: Boolean;
    function GetDataSet: TDataSet;
    function GetFirstSingleResult(AClazz: TClass): TObject;
    function GetResultList(AClazz: TClass): TObjectList<TObject>;
    procedure GetDataSetForEach(AProcDataSetForEach: TProcDataSetForEach);
  public
    class function New(ADbConnection: TDbConnection): IQuerySQL;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.Variants;

{ TQuerySQL }

constructor TQuerySQL.Create(ADbConnection: TDbConnection);
begin
  FDbConnection := ADbConnection;
  FInternalQuerySQL := TNativeQuery.New(ADbConnection);
  FSelectList := TStringList.Create;
  FWhereList := TStringList.Create;
  FJoinList := TStringList.Create;
end;

destructor TQuerySQL.Destroy;
begin
  FreeAndNil(FSelectList);
  FreeAndNil(FWhereList);
  FreeAndNil(FJoinList);
 inherited;
end;

function TQuerySQL.From(const ATableName: String; const AAlias: String = ''): IQuerySQL;
begin
  Result := Self;
  FTableName := ATableName;
  FTableAlias := AAlias;
end;

function TQuerySQL.GetDataSet: TDataSet;
var
  WhereConcat: String;
begin
  WhereConcat := GetWhereConcat;

  FInternalQuerySQL
    .Clear
    .Add('SELECT ' + GetSelectConcat + ' FROM ' + FTableName + ' ' + FTableAlias);

  for var Join in FJoinList do
    FInternalQuerySQL.Add(Join);

  if not WhereConcat.IsEmpty then
   FInternalQuerySQL.Add('WHERE ' + WhereConcat);

  Result := FInternalQuerySQL.GetDataSet;
end;

procedure TQuerySQL.GetDataSetForEach(
  AProcDataSetForEach: TProcDataSetForEach);
var
  Dts: TDataSet;
begin
  Dts := GetDataSet;
  Dts.First;
  while not Dts.Eof do
  begin
    if Assigned(AProcDataSetForEach) then
      AProcDataSetForEach(Dts.Fields);
    Dts.Next;
  end;
end;

function TQuerySQL.GetNativeQuery: INativeQuery;
begin
  Result := FInternalQuerySQL;
end;

function TQuerySQL.GetResultList(AClazz: TClass): TObjectList<TObject>;
begin
  Result := TObjectList<TObject>.Create;
  var Dts := GetDataSet;
  Dts.First;
  while not Dts.Eof do
  begin
    Result.Add(TRttiUtil.GetObjectFromDataSetFields(AClazz,Dts.Fields));
    Dts.Next;
  end;
end;

function TQuerySQL.GetSelectConcat: String;
begin
  for var Str in FSelectList do
    Result := Result + IfThen(Result.IsEmpty,'',',') + Str;

  if Result.IsEmpty then
    Result := '*';

end;

function TQuerySQL.GetFirstSingleResult(AClazz: TClass): TObject;
begin
  Result := nil;
  var Dts := GetDataSet();
  if not Dts.IsEmpty then
  begin
    Dts.First;
    Result := TRttiUtil.GetObjectFromDataSetFields(AClazz,Dts.Fields);
  end;
end;

function TQuerySQL.GetWhereConcat: String;
begin
  for var Str in FWhereList do
    Result := Result + IfThen(Result.IsEmpty,'',' AND ') + '(' + Str + ')';
end;

function TQuerySQL.IsEmpty: Boolean;
begin
  Result := not GetDataSet.IsEmpty;
end;

function TQuerySQL.IsNotEmpty: Boolean;
begin
  Result := not GetDataSet.IsEmpty;
end;

function TQuerySQL.Join(const AJoinTableName, AAlias,
  AOn: String): IQuerySQL;
begin
  Result := Self;
  FJoinList.Add('LEFT JOIN ' + AJoinTableName + ' ' + AAlias + ' ON ' + AOn);
end;

class function TQuerySQL.New(ADbConnection: TDbConnection): IQuerySQL;
begin
  Result := Self.Create(ADbConnection);
end;

function TQuerySQL.Select(const ASelectColumns: String): IQuerySQL;
begin
  Result := Self;
  FSelectList.Add(ASelectColumns);
end;

function TQuerySQL.SelectAll: IQuerySQL;
begin
  Result := Self;
  FSelectList.Text := '*';
end;

function TQuerySQL.SelectColumn(const ASelectColumn,
  ASelectColumnAs: String): IQuerySQL;
begin
  Result := Self;
  FSelectList.Add(ASelectColumn + IfThen(ASelectColumnAs.IsEmpty,'',' ') + ASelectColumnAs);
end;

function TQuerySQL.WhereEq(const AWhereKey: String;
  const AValue: Variant): IQuerySQL;
var
  LValue: String;
begin
  Result := Self;

  if VarIsStr(AValue) then
    LValue := QuotedStr(AValue)
  else
    LValue := VarToStr(AValue);

  FWhereList.Add(AWhereKey + ' = ' + LValue);
end;

end.
