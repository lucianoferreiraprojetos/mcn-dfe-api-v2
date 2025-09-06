unit Server.ConsultaDfeDao;

interface

uses
  Server.AbstractDao, Server.Data.Dtos, Server.DataAccess.UpdateSQL;

type

  TConsultaDfeDao = class(TAbstractDao)
  public
    procedure Incluir(DtoRespConsultaDfe: TRespConsultaDfeDto);
  end;

implementation

uses
  System.SysUtils;

{ TConsultaDfeDao }

procedure TConsultaDfeDao.Incluir(DtoRespConsultaDfe: TRespConsultaDfeDto);
var
  IdConsulta: Int64;
  DtoCons: TConsultaDfeDto;
begin
  DtoCons := DtoRespConsultaDfe.ConsultaDfe;

  IdConsulta := GetDbConnection.GetSequenceValue('SEQ_CONSULTA_DFE_ID');

  TUpdateSQL.New(GetDbConnection,'CONSULTA_DFE')
    .Add('ID',IdConsulta)
    .Add('ID_EMPRESA_DEST',DtoCons.IdEmpresa)
    .Add('CPF_CNPJ_DEST',DtoCons.CpfCnpjEmpresa)
    .Add('AMBIENTE_NFE',DtoCons.AmbienteNfe)
    .Add('UF_FISCAL_DEST',DtoCons.UfFiscal)
    .Add('ULT_NSU_CONS',DtoCons.UltNsuConsultado)
    .Add('IS_ATIVO',True)
    .Add('RESP_XML',DtoCons.RespXml)
    .Add('RESP_SOAP_XML',DtoCons.RespSoapXmpl)
    .Add('RESP_STATUS',DtoCons.RespStatus)
    .Add('RESP_TXT_MOTIVO',DtoCons.RespTxtMotivo)
    .Add('RESP_ULT_NSU',DtoCons.RespUltNsu)
    .Add('RESP_MAX_NSU',DtoCons.RespMaxNsu)
    .Add('RESP_QTDE_DOCTOS',DtoCons.RespQtdeDoctos)
    .Add('DTH_INCLUSAO',Now)
    .ExecInsert;

  for var Doc in DtoRespConsultaDfe.DocumentosDfe do
  begin
    var Id := GetDbConnection.GetSequenceValue('SEQ_DOCUMENTO_DFE_ID');
    TUpdateSQL.New(GetDbConnection,'DOCUMENTO_DFE')
      .Add('ID',Id)
      .Add('ID_CONSULTA_DFE',IdConsulta)
      .Add('RESP_SCHEMA',Doc.RespSchema)
      .Add('RESP_XML',Doc.RespXml)
      .Add('RESP_CHAVE_NFE',Doc.RespChaveNfe)
      .Add('RESP_EVENTO_ID',Doc.RespEventoId)
      .Add('RESP_NSU',Doc.RespNsu)
      .Add('RESP_IE',Doc.RespIe)
      .Add('RESP_SIT_NFE',Doc.RespSitNfe)
      .Add('CPF_CNPJ_EMITENTE',Doc.CpfCnpjEmitente)
      .Add('NOME_EMITENTE',Doc.NomeEmitente)
      .Add('VALOR_NOTA',Doc.ValorNota)
      .Add('IS_ATIVO',True)
      .Add('DTH_INCLUSAO',Now)
      .ExecInsert;
  end;

end;

end.
