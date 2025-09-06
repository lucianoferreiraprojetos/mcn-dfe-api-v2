unit Server.EmpresaDao;

interface

uses
  Server.Data.Models, System.SysUtils, Data.DB, System.Variants,
  System.Generics.Collections, Server.AbstractDao, Server.Data.Dtos,
  Server.DataAccess.QuerySQL, Server.DataAccess.RttiUtil,
  Server.Data.ValuesObjectsVO, Server.DataAccess.ObjectMapper,
  Server.Data.Filters, Server.DataAccess.SqlBuilder,
  Server.DataAccess.CriteriaQuery, Server.StrUtils;

type

  TEmpresaDao = class(TAbstractDao)
  public
    function BuscarPorId(const AId: Int64): TEmpresaVO;
    function BuscarPorCpfCnpj(const ACpfCnpj: String): TEmpresaVO;
    function BuscarPorEmail(const AEmail: String): TEmpresaVO;
    function BuscarLista(AFiltro: TEmpresaFiltro): TObjectList<TEmpresaVO>;
    function Incluir(EmpresaVO: TEmpresaInsertVO): TEmpresaVO;
    function Alterar(EmpresaVO: TEmpresaUpdateVO): TEmpresaVO;
    function ChecarSeExistePorCampo(const ANomeCampo: String; const AValue: Variant): Boolean;
    procedure RegistrarDataHoraAtualUltimaConsDfe(IdEmpresa: Int64);
    procedure RegistrarUltNsuConsultado(IdEmpresa: Int64; const UltNsu: String);
  end;

implementation

uses
  System.StrUtils, System.Math;

const
  EMPRESA = 'EMPRESA';

{ TEmpresaDao }

function TEmpresaDao.Alterar(EmpresaVO: TEmpresaUpdateVO): TEmpresaVO;
begin

  TSqlBuilder.New(GetDbConnection).Update[EMPRESA]
    .Add('NOME',EmpresaVO.Nome)
    .Add('IS_ATIVO',EmpresaVO.IsAtivo)
    .Add('EMAIL',EmpresaVO.Email.ToLower)
    .Add('UF_FISCAL',EmpresaVO.UfFiscal)
    .Add('MANIFESTO_AUTOMATICO',EmpresaVO.ManifestoAutomatico)
    .Add('AMBIENTE_NFE',EmpresaVO.AmbienteNfe)
    .Add('CERT_SENHA',EmpresaVO.CertSenha)
    .Add('CERT_BYTES',EmpresaVO.CertBytes)
    .Add('DTH_ALTERACAO',Now)
    .AddWhereEq('ID',EmpresaVO.Id)
    .ExecUpdate;

  Result := TObjectMapper.MapTo<TEmpresaVO>(BuscarPorId(EmpresaVO.Id),True);

end;

function TEmpresaDao.BuscarLista(AFiltro: TEmpresaFiltro): TObjectList<TEmpresaVO>;
var
  Qry: IQuerySQL<TEmpresaVO>;
begin

  Qry := TQuerySQL<TEmpresaVO>.New(GetDbConnection)
    .From(EMPRESA);

  if AFiltro.Situacao = TEnumSituacao.eSitAtivo then
    Qry.WhereEq('IS_ATIVO',True)
  else if AFiltro.Situacao = TEnumSituacao.eSitInativo then
    Qry.WhereEq('IS_ATIVO',False);

  if not AFiltro.CpfCnpj.IsEmpty then
    Qry.WhereEq('CPF_CNPJ',TStrUtils.OnlyNumbers(AFiltro.CpfCnpj));

  Result := Qry.GetResultList;
end;

function TEmpresaDao.BuscarPorCpfCnpj(const ACpfCnpj: String): TEmpresaVO;
begin
  Result := TQuerySQL<TEmpresaVO>.New(GetDbConnection)
    .From(EMPRESA).WhereEq('CPF_CNPJ',TStrUtils.OnlyNumbers(ACpfCnpj)).GetSingleResult
end;

function TEmpresaDao.BuscarPorEmail(const AEmail: String): TEmpresaVO;
begin
  Result := TQuerySQL<TEmpresaVO>.New(GetDbConnection)
    .From(EMPRESA).WhereEq('EMAIL',AEmail.ToLower).GetSingleResult
end;

function TEmpresaDao.BuscarPorId(const AId: Int64): TEmpresaVo;
begin
  Result := TQuerySQL<TEmpresaVo>.New(GetDbConnection)
    .From(EMPRESA).WhereEq('ID',AId).GetSingleResult
end;

function TEmpresaDao.ChecarSeExistePorCampo(const ANomeCampo: String;
  const AValue: Variant): Boolean;
begin
  Result := TQuerySQL.New(GetDbConnection)
    .From(EMPRESA).WhereEq(ANomeCampo,AValue).IsNotEmpty;
end;

function TEmpresaDao.Incluir(EmpresaVO: TEmpresaInsertVO): TEmpresaVO;
var
  Id: Int64;
begin
  Id := GetDbConnection.GetSequenceValue('SEQ_EMPRESA_ID');

  TSqlBuilder.New(GetDbConnection).Update[EMPRESA]
    .Add('ID',Id)
    .Add('NOME',EmpresaVO.Nome)
    .Add('CPF_CNPJ',TStrUtils.OnlyNumbers(EmpresaVO.CpfCnpj))
    .Add('EMAIL',EmpresaVO.Email.ToLower)
    .Add('UF_FISCAL',EmpresaVO.UfFiscal)
    .Add('MANIFESTO_AUTOMATICO',EmpresaVO.ManifestoAutomatico)
    .Add('AMBIENTE_NFE',EmpresaVO.AmbienteNfe)
    .Add('CERT_SENHA',EmpresaVO.CertSenha)
    .Add('CERT_BYTES',EmpresaVO.CertBytes)
    .Add('DTH_INCLUSAO',Now)
    .ExecInsert;

  Result := TObjectMapper.MapTo<TEmpresaVO>(BuscarPorId(Id),True);

end;

procedure TEmpresaDao.RegistrarDataHoraAtualUltimaConsDfe(IdEmpresa: Int64);
begin
  TUpdateSQL.New(GetDbConnection,'EMPRESA')
    .Add('DTH_ULT_CONS_NFE',Now())
    .AddWhereEq('ID',IdEmpresa)
    .ExecUpdate
end;

procedure TEmpresaDao.RegistrarUltNsuConsultado(IdEmpresa: Int64;
  const UltNsu: String);
begin
  TUpdateSQL.New(GetDbConnection,'EMPRESA')
    .Add('DTH_ULT_CONS_NFE',Now())
    .Add('ULT_NSU',UltNsu)
    .AddWhereEq('ID',IdEmpresa)
    .ExecUpdate;
end;

end.
