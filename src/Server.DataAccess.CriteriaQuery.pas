unit Server.DataAccess.CriteriaQuery;

interface

uses
  Data.DB,
  System.Generics.Collections, Server.DataAccess.DbConnection,
  Server.DataAccess.NativeQuery, Server.DataAccess.RttiUtil;

type

  ICriteriaQuery = interface
    ['{0C92B85D-E229-4B7D-B0EB-A242B4761042}']
    function From(AClazz: TClass): ICriteriaQuery;
    function GetSingleResult: TObject;
    function GetFirstResult: TObject;
    function GetResultList: TObjectLIst<TObject>;
  end;

  TCriteriaQuery = class(TInterfacedObject,ICriteriaQuery)
  private
    FDbConnection: TDbConnection;
    FRootClass: TClass;
    constructor Create(ADbConnection: TDbConnection);
  public
    function From(AClazz: TClass): ICriteriaQuery;
    function GetSingleResult: TObject;
    function GetFirstResult: TObject;
    function GetResultList: TObjectLIst<TObject>;
  public
    class function New(ADbConnection: TDbConnection): ICriteriaQuery;
  end;

{******************************************************************************}  

  ICriteriaQuery<T: class> = interface
    ['{23909378-8464-4A14-9D96-4F3ED0299DEF}']
    function From(AClazz: TClass): ICriteriaQuery<T>;
    function GetSingleResult: T;
    function GetFirstResult: T;
    function GetResultList: TObjectLIst<T>;
  end;

  TCriteriaQuery<T: class> = class(TInterfacedObject,ICriteriaQuery<T>)
  private
    FInternalCriteriaQuery: ICriteriaQuery;
    constructor Create(ADbConnection: TDbConnection);
  public
    function From(AClazz: TClass): ICriteriaQuery<T>;
    function GetSingleResult: T;
    function GetFirstResult: T;
    function GetResultList: TObjectLIst<T>;
  public  
    class function New(ADbConnection: TDbConnection): ICriteriaQuery<T>;
  end;

implementation

uses
  System.SysUtils;

{ TCriteriaQuery }

constructor TCriteriaQuery.Create(ADbConnection: TDbConnection);
begin
  FDbConnection := ADbConnection;
end;

function TCriteriaQuery.From(AClazz: TClass): ICriteriaQuery;
begin
  Result := Self;
  FRootClass := AClazz;
end;

function TCriteriaQuery.GetFirstResult: TObject;
begin
//
end;

function TCriteriaQuery.GetResultList: TObjectLIst<TObject>;
var
  SQL: String;
  Dts: TDataSet;
begin
  Result := TObjectList<TObject>.Create;
  SQL := 'SELECT * ' + 'FROM ' + TRttiUtil.GetEntityTableName(FRootClass);
  try
    Dts := TNativeQuery.New(FDbConnection).Add(SQL).GetDataSetDetached;
    Dts.First;
    while not Dts.Eof do
    begin
      var LObject := TRttiUtil.GetObjectFromDataSetFields(FRootClass,Dts.Fields);
      Result.Add(LObject);
      Dts.Next;
    end;
  finally
    FreeAndNil(Dts);
  end;
end;

function TCriteriaQuery.GetSingleResult: TObject;
begin
//
end;

class function TCriteriaQuery.New(ADbConnection: TDbConnection): ICriteriaQuery;
begin
  Result := Self.Create(ADbConnection);
end;

{ TCriteriaQuery<T> }

constructor TCriteriaQuery<T>.Create(ADbConnection: TDbConnection);
begin
  FInternalCriteriaQuery := TCriteriaQuery.New(ADbConnection);
  FInternalCriteriaQuery.From(T);
end;

function TCriteriaQuery<T>.From(AClazz: TClass): ICriteriaQuery<T>;
begin
  Result := Self;
  FInternalCriteriaQuery.From(AClazz);
end;

function TCriteriaQuery<T>.GetFirstResult: T;
begin
//
end;

function TCriteriaQuery<T>.GetResultList: TObjectLIst<T>;
begin
  Result := TObjectList<T>.Create;
  for var Obj in FInternalCriteriaQuery.GetResultList do
  begin
    Result.Add(Obj);
  end;
end;

function TCriteriaQuery<T>.GetSingleResult: T;
begin
//
end;

class function TCriteriaQuery<T>.New(
  ADbConnection: TDbConnection): ICriteriaQuery<T>;
begin
  Result := Self.Create(ADbConnection);
end;

end.
