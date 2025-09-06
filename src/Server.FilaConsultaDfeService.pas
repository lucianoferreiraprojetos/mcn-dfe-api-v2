unit Server.FilaConsultaDfeService;

interface

uses
  System.Generics.Collections, System.SysUtils;

type

  TFilaConsultaDfeService = class
  private
    class var FFila: TList<Int64>;
    class var FMultiReadExclusiveWrite : TMultiReadExclusiveWriteSynchronizer;
  public
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Adicionar(IdEmpresa: Int64);
    class procedure Remover(IdEmpresa: Int64);
    class function GetList: TList<Int64>;
  end;

implementation

uses
  System.Classes;

{ TFilaConsultaDfeService }

class procedure TFilaConsultaDfeService.Adicionar(IdEmpresa: Int64);
begin
  Self.FMultiReadExclusiveWrite.BeginWrite();
  try
    if not FFila.Contains(IdEmpresa) then
      FFila.Add(IdEmpresa);
  finally
    Self.FMultiReadExclusiveWrite.EndWrite();
  end;
end;

class constructor TFilaConsultaDfeService.Create;
begin
  FFila := TList<Int64>.Create;
  FMultiReadExclusiveWrite := TMultiReadExclusiveWriteSynchronizer.Create;
end;

class destructor TFilaConsultaDfeService.Destroy;
begin
  FreeAndNil(FFila);
  FreeAndNil(FMultiReadExclusiveWrite);
end;

class function TFilaConsultaDfeService.GetList: TList<Int64>;
begin
  Result := TList<Int64>.Create;
  Self.FMultiReadExclusiveWrite.BeginRead();
  try
    for var Item in FFila do
      Result.Add(Item);
  finally
    Self.FMultiReadExclusiveWrite.EndRead();
  end;
end;

class procedure TFilaConsultaDfeService.Remover(IdEmpresa: Int64);
begin
  Self.FMultiReadExclusiveWrite.BeginWrite();
  try
    if FFila.Contains(IdEmpresa) then
      FFila.Remove(IdEmpresa);
  finally
    Self.FMultiReadExclusiveWrite.EndWrite();
  end;
end;

end.
