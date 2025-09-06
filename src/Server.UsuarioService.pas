unit Server.UsuarioService;

interface

uses
  System.Generics.Collections, System.SysUtils, Server.PerfilUsuarioDao,
  Server.Data.Models, Server.AbstractService, Server.Exceptions,
  Server.AppLogger, Server.Data.Dtos,
  Server.UsuarioDao, Server.DataAccess.ObjectMapper, Server.Data.ValuesObjectsVO,
  Server.DataAccess.ObjectValidation;

type

  TUsuarioService = class(TAbstractService)
  private
    DaoUsuario: TUsuarioDao;
    DaoPerfilUsuario: TPerfilUsuarioDao;
    function ChecarSeExisteUmOutroUsuarioComEsteEmail(IdUsuarioAtual: Int64; Email: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function BuscarPorId(const Id: Int64): TUsuarioDto;
    function BuscarPorEmail(const Email: String): TUsuarioDto;
    function BuscarPorLogin(const Login: String): TUsuarioDto;
    function BuscarLista(): TObjectList<TUsuarioDto>;
  public
    function Incluir(const DtoInsert: TUsuarioInsertDto): TUsuarioDto;
    function Alterar(Id: Int64; MapValues: TDictionary<String,Variant>): TUsuarioDto;
    procedure ExcluirPorId(const Id: Int64);
  public
    class function GerarHashSenha(const Login, Senha: String): String;
  end;

implementation

uses
  System.Hash;

{ TUsuarioService }

function TUsuarioService.BuscarPorEmail(const Email: String): TUsuarioDto;
begin
  var Vo := DaoUsuario.BuscarPorEmail(Email.ToLower);

  if not Assigned(Vo) then
    raise ERecursoNaoEncontradoException.Create(Format('Não foi encontrado nenhum usuário com este e-mail: %s',[Email]));

  Result := TObjectMapper.MapTo<TUsuarioDto>(Vo,True);
end;

function TUsuarioService.BuscarPorId(const Id: Int64): TUsuarioDto;
begin
  var Vo := DaoUsuario.BuscarPorId(Id);

  if not Assigned(Vo) then
    raise ERecursoNaoEncontradoException.Create(Format('Não foi encontrado nenhum usuário com este id: %d',[Id]));

  Result := TObjectMapper.MapTo<TUsuarioDto>(Vo,True);
end;

function TUsuarioService.BuscarPorLogin(const Login: String): TUsuarioDto;
begin
  var Vo := DaoUsuario.BuscarPorLogin(Login.ToLower);

  if not Assigned(Vo) then
    raise ERecursoNaoEncontradoException.Create(Format('Não foi encontrado nenhum usuário com este login: %s',[Login]));

  Result := TObjectMapper.MapTo<TUsuarioDto>(Vo,True);
end;

function TUsuarioService.BuscarLista: TObjectList<TUsuarioDto>;
begin
  Result := TObjectMapper.MapTo<TUsuarioVO,TUsuarioDto>(DaoUsuario.BuscarLista,True);
end;

function TUsuarioService.ChecarSeExisteUmOutroUsuarioComEsteEmail(
  IdUsuarioAtual: Int64; Email: String): Boolean;
begin
  Result := False;

  var Usuario := DaoUsuario.BuscarPorEmail(Email.ToLower);

  if not Assigned(Usuario) then
    Exit;

  try
    Result := Usuario.Id <> IdUsuarioAtual;
  finally
    FreeAndNil(Usuario);
  end;
end;

constructor TUsuarioService.Create;
begin
  inherited;
  DaoUsuario := TUsuarioDao.Create(GetDbConnection);
  DaoPerfilUsuario := TPerfilUsuarioDao.Create(GetDbConnection);
end;

destructor TUsuarioService.Destroy;
begin
  FreeAndNil(DaoUsuario);
  FreeAndNil(DaoPerfilUsuario);
  inherited;
end;

procedure TUsuarioService.ExcluirPorId(const Id: Int64);
begin
  var Usuario := DaoUsuario.BuscarPorId(Id);

  if not Assigned(Usuario) then
    raise ERecursoNaoEncontradoException.Create(Format('Não existe usuário com este id: %d',[Id]));

  try
    DaoUsuario.ExcluirPorId(Usuario.Id);
  finally
    FreeAndNil(Usuario);
  end;
end;

class function TUsuarioService.GerarHashSenha(const Login, Senha: String): String;
begin
  Result := THashMD5.GetHashString(Login.ToLower + Senha);
end;

function TUsuarioService.Incluir(const DtoInsert: TUsuarioInsertDto): TUsuarioDto;
begin

  var VOInsert := TObjectMapper.MapTo<TUsuarioInsertVO>(DtoInsert,False);

  TObjectValidation.Validate(VOInsert);

  if DaoUsuario.ChecarSeExistePorCampo('LOGIN',VOInsert.Login.ToLower) then
    raise Exception.Create('Já existe um usuário com este login');

  if DaoUsuario.ChecarSeExistePorCampo('EMAIL',VOInsert.Email.ToLower) then
    raise Exception.Create('Já existe um usuário com este e-mail');

  if not DaoPerfilUsuario.ChecarSeExistePorId(VOInsert.IdPerfil) then
    raise Exception.Create(Format('Não existe um perfil com este id: %d',[VOInsert.IdPerfil]));

  VOInsert.Senha := GerarHashSenha(VOInsert.Login,VOInsert.Senha);

  GetDbConnection.StartTransaction;
  try

    Result := TObjectMapper.MapTo<TUsuarioDto>(DaoUsuario.Incluir(VOInsert),True);

    GetDbConnection.Commit;

  except on E: Exception do
    begin
      GetDbConnection.Rollback;
      LogError(E.Message,Self.ClassType);
      raise E;
    end;
  end;

end;

function TUsuarioService.Alterar(Id: Int64; MapValues: TDictionary<String,Variant>): TUsuarioDto;
var
  UsuarioUpdateVO: TUsuarioUpdateVO;
begin
  var UsuarioVO := DaoUsuario.BuscarPorId(Id);

  if not Assigned(UsuarioVO) then
    raise Exception.Create(Format('Não existe um usuário com este id:%d',[Id]));

  try
    UsuarioUpdateVO := TObjectMapper.MapTo<TUsuarioUpdateVO>(UsuarioVO,False);
    try
      TObjectMapper.Merge(MapValues,UsuarioUpdateVO,False);

      TObjectValidation.Validate(UsuarioUpdateVO);

      if ChecarSeExisteUmOutroUsuarioComEsteEmail(UsuarioVO.Id,UsuarioVO.Email.ToLower) then
        raise Exception.Create(Format('Já existe um outro usuário com este e-mail: %s',[UsuarioUpdateVO.Email]));

      if not DaoPerfilUsuario.ChecarSeExistePorId(UsuarioUpdateVO.IdPerfil) then
        raise Exception.Create(Format('Não existe um perfil com este id: %d',[UsuarioUpdateVO.IdPerfil]));

      if UsuarioUpdateVO.Senha <> UsuarioVO.Senha then
        UsuarioUpdateVO.Senha := GerarHashSenha(UsuarioVO.Login,UsuarioUpdateVO.Senha);

      GetDbConnection.StartTransaction;
      try
        Result := TObjectMapper.MapTo<TUsuarioDto>(DaoUsuario.Alterar(UsuarioUpdateVO),True);
        GetDbConnection.Commit;
      except on E: Exception do
        begin
          GetDbConnection.Rollback;
          LogError(E.Message,Self.ClassType);
          raise E;
        end;
      end;
    finally
      FreeAndNil(UsuarioUpdateVO);
    end;
  finally
    FreeAndNil(UsuarioVO);
  end;
end;

end.
