unit Server.AbstractDao;

interface

uses
  System.Generics.Collections, System.SysUtils,
  Server.DataAccess.DbConnection, Server.DataAccess.NativeQuery,
  Server.DataAccess.QuerySQL, Server.DataAccess.RttiUtil;

type

  IAbstractDao = interface
    ['{893E54DA-F4E2-4A6C-80DD-511C46911C26}']
  end;

  IAbstractDao<T: class> = interface
    ['{9A4DE28D-AF07-4E78-85AF-CBB0EF169371}']
  end;

  TAbstractDao = class abstract(TInterfacedObject,IAbstractDao)
  private
    FDbConenection: TDbConnection;
  public
    constructor Create(ADbConenection: TDbConnection);
    destructor Destroy; override;
  public
    function GetDbConnection: TDbConnection;
  end;

  TAbstractDao<T: class> = class abstract(TInterfacedObject,IAbstractDao<T>)
  private
    FDbConenection: TDbConnection;
  public
    constructor Create(ADbConenection: TDbConnection);
    destructor Destroy; override;
  public
    function GetDbConnection: TDbConnection;
    function BuscarPorId(const Id: Int64): T;
    function BuscarLista(): TObjectList<T>;
    function ChecarSeExistePorId(const Id: Int64): Boolean;
  end;

implementation

uses
  System.Classes, Data.DB;

{ TAbstractDao }

constructor TAbstractDao.Create(ADbConenection: TDbConnection);
begin
  FDbConenection := ADbConenection;
end;

destructor TAbstractDao.Destroy;
begin
  inherited;
end;

function TAbstractDao.GetDbConnection: TDbConnection;
begin
  Result := FDbConenection;
end;

{ TAbstractDao<T> }

function TAbstractDao<T>.BuscarLista: TObjectList<T>;
begin
  Result := TQuerySQL<T>.New(GetDbConnection)
    .From(TRttiUtil.GetEntityTableName(T)).GetResultList;
end;

function TAbstractDao<T>.BuscarPorId(const Id: Int64): T;
begin
  Result := TQuerySQL<T>.New(GetDbConnection)
    .From(TRttiUtil.GetEntityTableName(T)).WhereEq('ID',Id).GetSingleResult;
end;

function TAbstractDao<T>.ChecarSeExistePorId(const Id: Int64): Boolean;
begin
  Result := TQuerySQL<T>.New(GetDbConnection)
    .From(TRttiUtil.GetEntityTableName(T)).WhereEq('ID',Id).IsNotEmpty;
end;

constructor TAbstractDao<T>.Create(ADbConenection: TDbConnection);
begin
  FDbConenection := ADbConenection;
end;

destructor TAbstractDao<T>.Destroy;
begin
  inherited;
end;

function TAbstractDao<T>.GetDbConnection: TDbConnection;
begin
  Result := FDbConenection;
end;

end.
