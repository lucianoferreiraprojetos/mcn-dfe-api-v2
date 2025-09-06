unit Server.PerfilUsuarioService;

interface

uses
  System.Generics.Collections, Server.AbstractService, Server.PerfilUsuarioDao,
  Server.Data.Dtos, Server.DataAccess.ObjectMapper, Server.Data.ValuesObjectsVO,
  Server.Data.Models;

type

  TPerfilUsuarioService = class(TAbstractService)
  private
    DaoPerfilUsuario: TPerfilUsuarioDao;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function BuscarPorId(const Id: Int64): TPerfilUsuarioDto;
    function BuscarLista(): TObjectList<TPerfilUsuarioDto>;
  end;

implementation

uses
  System.SysUtils, Data.DB, Server.Exceptions, Server.AppLogger;

{ TPerfilUsuarioService }

function TPerfilUsuarioService.BuscarPorId(const Id: Int64): TPerfilUsuarioDto;
begin
  var UsuarioVo := DaoPerfilUsuario.BuscarPorId(Id);

  if not Assigned(UsuarioVo) then
    raise ERecursoNaoEncontradoException.Create(Format('Não foi encontrado nenhum perfil com este id: %d',[Id]));

  Result := TObjectMapper.MapTo<TPerfilUsuarioDto>(UsuarioVo,True);
end;

function TPerfilUsuarioService.BuscarLista: TObjectList<TPerfilUsuarioDto>;
begin
  Result := TObjectMapper.MapTo<TPerfilUsuario,TPerfilUsuarioDto>(DaoPerfilUsuario.BuscarLista,True);
end;

constructor TPerfilUsuarioService.Create;
begin
  inherited;
  DaoPerfilUsuario := TPerfilUsuarioDao.Create(GetDbConnection);
end;

destructor TPerfilUsuarioService.Destroy;
begin
  FreeAndNil(DaoPerfilUsuario);
  inherited;
end;

end.
