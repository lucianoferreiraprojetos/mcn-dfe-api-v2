unit Server.Autenticacao.Service;

interface

uses
  System.Classes, System.SysUtils, Server.Data.Dtos,
  Server.AbstractService, Server.UsuarioDao, Server.UsuarioService,
  Server.Data.ValuesObjectsVO;

type

  TAutenticacaoService = class(TAbstractService)
  private
    UsuarioDao: TUsuarioDao;
    procedure IncluirUsuario(Login, Senha: String);
  public
    constructor Create;
    destructor Destroy; override;
  public
    function Autenticar(Login, Senha: String): TTokenAutenticacaoDto;
  end;

implementation

uses
  Server.Autorizacao.Service, Server.StrUtils, Server.Exceptions,
  System.Hash;

{ TAutenticacaoService }

function TAutenticacaoService.Autenticar(Login,
  Senha: String): TTokenAutenticacaoDto;
begin
  Result := nil;

  if TStrUtils.IsBlank(Login) then
    raise ERegraDeNegocioException.Create('Informe o login');

  if TStrUtils.IsBlank(Senha) then
    raise ERegraDeNegocioException.Create('Informe a senha');

  if not UsuarioDao.ExisteAlgumUsuarioCadastrado() then
  begin
    IncluirUsuario(Login,Senha);
  end;

  var Usuario := UsuarioDao.BuscarPorLogin(Login.ToLower);
  try
    if Assigned(Usuario) then
    begin
      if Usuario.Senha = THashMD5.GetHashString(Login.ToLower + Senha) then
      begin
        Result := TAutorizacaoService.New.GerarTokenAutenticacao(Login);
        Result.NomeUsuario := Usuario.Nome;
      end;
    end;
  finally
    FreeAndNil(Usuario);
  end;

  if not Assigned(Result) then
    raise ERegraDeNegocioException.Create('Usuário ou senha incorreto!');

end;

constructor TAutenticacaoService.Create;
begin
  inherited Create;
  UsuarioDao := TUsuarioDao.Create(GetDbConnection);
end;

destructor TAutenticacaoService.Destroy;
begin
  FreeAndNil(UsuarioDao);
  inherited;
end;

procedure TAutenticacaoService.IncluirUsuario(Login, Senha: String);
var
  VoInsert: TUsuarioInsertVO;
begin
  VoInsert := TUsuarioInsertVO.Create;
  try
    VoInsert.Nome := Login;
    VoInsert.Email := Login;
    VoInsert.Login := Login;
    VoInsert.IdPerfil := 1;
    VoInsert.Senha := TUsuarioService.GerarHashSenha(Login, Senha);
    UsuarioDao.Incluir(VoInsert);
  finally
    FreeAndNil(VoInsert);
  end;
end;

end.
