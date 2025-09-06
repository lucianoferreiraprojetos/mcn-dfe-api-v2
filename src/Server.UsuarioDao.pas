unit Server.UsuarioDao;

interface

uses
  Data.DB, System.SysUtils, System.Generics.Collections, Server.Data.Dtos,
  Server.AbstractDao, Server.DataAccess.QuerySQL, Server.DataAccess.UpdateSQL,
  Server.DataAccess.RttiUtil, Server.DataAccess.NativeQuery, Server.Data.ValuesObjectsVO,
  Server.DataAccess.CustomQuerySQL, Server.DataAccess.SqlBuilder,
  Server.Data.Models, Server.DataAccess.CriteriaQuery;

type

  TUsuarioDao = class(TAbstractDao)
  private
    function CreateQuerySQL: IQuerySQL<TUsuarioVO>;
    function CreateUpdateSQL: IUpdateSQL;
  public
    function BuscarPorId(const Id: Int64): TUsuarioVO;
    function BuscarLista(): TObjectList<TUsuarioVO>;
    function BuscarPorLogin(const AValue: String): TUsuarioVO;
    function BuscarPorEmail(const AValue: String): TUsuarioVO;
    function ChecarSeExistePorCampo(const ANomeCampo: String; const AValue: Variant): Boolean;
    function Incluir(VoInsert: TUsuarioInsertVO): TUsuarioVO;
    function Alterar(VoUpdate: TUsuarioUpdateVO): TUsuarioVO;
    function ExisteAlgumUsuarioCadastrado: Boolean;
    procedure ExcluirPorId(const Id: Int64);
  end;

implementation

{ TUsuarioDao }

function TUsuarioDao.Incluir(VoInsert: TUsuarioInsertVO): TUsuarioVO;
var
  Id: Int64;
begin

  Id := GetDbConnection.GetSequenceValue('SEQ_USUARIO_ID');

  CreateUpdateSQL
    .Add('ID',Id)
    .Add('IS_ATIVO',True)
    .Add('NOME',VoInsert.Nome)
    .Add('EMAIL',VoInsert.Email.ToLower)
    .Add('LOGIN',VoInsert.Login.ToLower)
    .Add('ID_PERFIL',VoInsert.IdPerfil)
    .Add('SENHA',VoInsert.Senha)
    .Add('DTH_INCLUSAO',Now)
    .ExecInsert;

  Result := BuscarPorId(Id);

end;

function TUsuarioDao.Alterar(VoUpdate: TUsuarioUpdateVO): TUsuarioVO;
begin

  CreateUpdateSQL
    .Add('IS_ATIVO',VoUpdate.IsAtivo)
    .Add('NOME',VoUpdate.Nome)
    .Add('EMAIL',VoUpdate.Email.ToLower)
    .Add('ID_PERFIL',VoUpdate.IdPerfil)
    .Add('SENHA',VoUpdate.Senha)
    .Add('DTH_ALTERACAO',Now)
    .AddWhereEq('ID',VoUpdate.Id)
    .ExecUpdate;

  Result := BuscarPorId(VoUpdate.Id);

end;

function TUsuarioDao.BuscarPorEmail(const AValue: String): TUsuarioVO;
begin
  Result := CreateQuerySQL.WhereEq('U.EMAIL',AValue.ToLower).GetSingleResult;
end;

function TUsuarioDao.BuscarPorId(const Id: Int64): TUsuarioVO;
begin
  Result := CreateQuerySQL.WhereEq('U.ID',Id).GetSingleResult;
end;

function TUsuarioDao.BuscarPorLogin(const AValue: String): TUsuarioVO;
begin
  Result := CreateQuerySQL.WhereEq('U.LOGIN',AValue.ToLower).GetSingleResult;
end;

function TUsuarioDao.ChecarSeExistePorCampo(const ANomeCampo: String;
  const AValue: Variant): Boolean;
begin
  Result := CreateQuerySQL.WhereEq('U.' + ANomeCampo,AValue).IsNotEmpty;
end;

function TUsuarioDao.CreateQuerySQL: IQuerySQL<TUsuarioVO>;
begin
  Result := TQuerySQL<TUsuarioVO>.New(GetDbConnection)
    .From('USUARIO','U')
    .Join('PERFIL_USUARIO','P','P.ID = U.ID_PERFIL')
    .Select('U.*')
    .SelectColumn('P.NOME','NOME_PERFIL');
end;

function TUsuarioDao.CreateUpdateSQL: IUpdateSQL;
begin
  Result := TSqlBuilder.New(GetDbConnection).Update['USUARIO'];
end;

procedure TUsuarioDao.ExcluirPorId(const Id: Int64);
begin
  TSqlBuilder.New(GetDbConnection)
    .Delete['USUARIO'].AddWhereEq('ID',Id).ExecDelete();
end;

function TUsuarioDao.ExisteAlgumUsuarioCadastrado: Boolean;
begin
  Result := TQuerySQL.New(GetDbConnection)
    .From('USUARIO')
    .Select('COUNT(*) AS QDE')
    .GetDataSet.FieldByName('QDE').AsInteger > 0;
end;

function TUsuarioDao.BuscarLista: TObjectList<TUsuarioVO>;
begin
  Result := CreateQuerySQL.GetResultList;
end;

end.
