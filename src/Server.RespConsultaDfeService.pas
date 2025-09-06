unit Server.RespConsultaDfeService;

interface

uses
  System.Classes, System.NetEncoding, System.SysUtils, System.Generics.Collections,
  ACBrBase, ACBrDFe, ACBrNFe,ACBrDFeSSL, pcnConversaoNFe, blcksock,
  pcnConversao, Server.Data.Dtos, Server.Data.ValuesObjectsVO, Server.StrUtils,
  Server.AppLogger;

type

  TRespostaConsultaDfeService = class
  private
    FEmpresaVO: TEmpresaVO;
    FACBrNFe: TACBrNFe;
    function PegarCertificadoStrFromStream(): AnsiString;
    procedure PreencherConsultaDfeDto(DtoConsDfe: TConsultaDfeDto);
    procedure PreencherDocumentos(ALista: TObjectList<TDocumentoDfeDto>);
    function CriarACBrNFe(): TACBrNFe;
    function CriarRespConsultaDfeDto(): TRespConsultaDfeDto;
    function PegarCodigoIbgeUf(const AUfFiscal: String): Integer;
  public
    constructor Create(AEmpresaVO: TEmpresaVO);
    destructor Destroy; override;
    function DistribuicaoDFePorUltNSU(const AUltNsu: String): TRespConsultaDfeDto;
  end;

const
  COD_DOCTO_NAO_LOCALIZADO = 137;
  COD_CONSUMO_INDEVIDO = 656;
  COD_DOCUMENTO_LOCALIZADO = 138;

implementation

uses
  synautil, Server.AppConfig;

{ TRespostaConsultaDfeService }

constructor TRespostaConsultaDfeService.Create(AEmpresaVO: TEmpresaVO);
begin
  FEmpresaVO := AEmpresaVO;
  FACBrNFe := CriarACBrNFe();
end;

function TRespostaConsultaDfeService.CriarRespConsultaDfeDto(): TRespConsultaDfeDto;
begin
  Result := TRespConsultaDfeDto.Create;
  PreencherConsultaDfeDto(Result.ConsultaDfe);
  PreencherDocumentos(Result.DocumentosDfe);
end;

destructor TRespostaConsultaDfeService.Destroy;
begin
  FreeAndNil(FACBrNFe);
  inherited;
end;

function TRespostaConsultaDfeService.DistribuicaoDFePorUltNSU(const AUltNsu: String): TRespConsultaDfeDto;
begin
  Result := nil;

  FEmpresaVO.UltNsuConsultado := TStrUtils.StrToZero(AUltNsu,15);

  var CodigoIbge := PegarCodigoIbgeUf(FEmpresaVO.UfFiscal);

  try
    FACBrNFe.DistribuicaoDFePorUltNSU(CodigoIbge,FEmpresaVO.CpfCnpj,FEmpresaVO.UltNsuConsultado);
    Result := CriarRespConsultaDfeDto();
  except
    on E: EACBrException do
    begin

      var LRespStatus := FACBrNFe.WebServices.DistribuicaoDFe.retDistDFeInt.cStat;

      LogError('Erro ao consultar distribuição DFe (EACBrException): ' + E.Message,Self.ClassType);

      if LRespStatus = COD_CONSUMO_INDEVIDO then
        Result := CriarRespConsultaDfeDto();

    end;
    on E: Exception do
    begin
      LogError('Erro ao consultar distribuição DFe: ' + E.Message,Self.ClassType);
      raise E;
    end;
  end;

end;

function TRespostaConsultaDfeService.CriarACBrNFe(): TACBrNFe;
begin
  Result := TACBrNFe.Create(nil);

  with Result.Configuracoes do
  begin
    {$IFDEF LINUX}
      Geral.SSLLib := libOpenSSL;
      Geral.SSLCryptLib := cryOpenSSL;
      Geral.SSLHttpLib := httpOpenSSL;
      Geral.SSLXmlSignLib := xsLibXml2;
    {$ELSE}
      Geral.SSLCryptLib := cryWinCrypt;
      Geral.SSLHttpLib := httpWinHttp;
      Geral.SSLLib := libWinCrypt;
      Geral.SSLXmlSignLib := xsLibXml2;
    {$ENDIF}
    Geral.VersaoDF := ve400;
    Geral.Salvar := True;
  end;

  with Result.Configuracoes do
  begin
    Arquivos.Salvar := True;
    Arquivos.PathSchemas := AppConfig.GetNfeParams.PathSchemas;
    Arquivos.PathSalvar := IncludeTrailingPathDelimiter(AppConfig.GetNfeParams.PathDownloadXml) + FEmpresaVO.CpfCnpj;
    Arquivos.SepararPorDia := True;
  end;

  with Result.Configuracoes do
  begin
    WebServices.SSLType := LT_TLSv1_2;
    WebServices.TimeOut := 15000;
    WebServices.Salvar := True;
  end;

  with Result.Configuracoes do
  begin
    Certificados.DadosPFX := PegarCertificadoStrFromStream();
    Certificados.Senha := FEmpresaVO.CertSenha;
  end;

  with Result.Configuracoes do
  begin
    if FEmpresaVO.AmbienteNfe	= 'P' then
      WebServices.Ambiente := taProducao
    else
      WebServices.Ambiente := taHomologacao;
    WebServices.UF := FEmpresaVO.UfFiscal;
  end;
end;

function TRespostaConsultaDfeService.PegarCertificadoStrFromStream(): AnsiString;
var
  BytesStream: TBytesStream;
begin
  BytesStream := TBytesStream.Create(FEmpresaVO.CertBytes);
  try
    BytesStream.Position := 0;
    Result := ReadStrFromStream(BytesStream,BytesStream.Size);
  finally
    FreeAndNil(BytesStream);
  end;
end;

function TRespostaConsultaDfeService.PegarCodigoIbgeUf(const AUfFiscal: String): Integer;
begin
  Result := 51;
end;

procedure TRespostaConsultaDfeService.PreencherConsultaDfeDto(DtoConsDfe: TConsultaDfeDto);
begin
  DtoConsDfe.IdEmpresa := FEmpresaVO.Id;
  DtoConsDfe.CpfCnpjEmpresa := FEmpresaVO.CpfCnpj;
  DtoConsDfe.AmbienteNfe := FEmpresaVO.AmbienteNfe;
  DtoConsDfe.UfFiscal := FEmpresaVO.UfFiscal;
  DtoConsDfe.UltNsuConsultado := FEmpresaVO.UltNsuConsultado;
  DtoConsDfe.RespXml := FACBrNFe.WebServices.DistribuicaoDFe.RetWS;
  DtoConsDfe.RespSoapXmpl := FACBrNFe.WebServices.DistribuicaoDFe.RetornoWS;
  DtoConsDfe.RespStatus := FACBrNFe.WebServices.DistribuicaoDFe.retDistDFeInt.cStat;
  DtoConsDfe.RespUltNsu := FACBrNFe.WebServices.DistribuicaoDFe.retDistDFeInt.ultNSU;
  DtoConsDfe.RespMaxNsu := FACBrNFe.WebServices.DistribuicaoDFe.retDistDFeInt.maxNSU;
  DtoConsDfe.RespTxtMotivo := FACBrNFe.WebServices.DistribuicaoDFe.retDistDFeInt.xMotivo;
  DtoConsDfe.RespQtdeDoctos := FACBrNFe.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Count;
end;

procedure TRespostaConsultaDfeService.PreencherDocumentos(ALista: TObjectList<TDocumentoDfeDto>);
  function PegarCodigoSituacaoNfe(SitDfe: pcnConversao.TSituacaoDFe): String;
  begin
    if SitDfe = pcnConversao.TSituacaoDFe.snAutorizado then
      Result := 'Autorizado'
    else
    if SitDfe = pcnConversao.TSituacaoDFe.snDenegado then
      Result := 'Denegado'
    else
    if SitDfe = pcnConversao.TSituacaoDFe.snCancelado then
      Result := 'Cancelado'
    else
    if SitDfe = pcnConversao.TSituacaoDFe.snEncerrado then
      Result := 'Encerrado'
    else
      Result := '';
  end;
begin
  with FACBrNFe.WebServices.DistribuicaoDFe.retDistDFeInt do
  begin
    for var IndexDocto := 0 to docZip.Count -1 do
    begin
      var DocumentoDfe := TDocumentoDfeDto.Create;
      DocumentoDfe.RespNsu := docZip[IndexDocto].NSU;
      DocumentoDfe.RespXml := docZip[IndexDocto].XML;
      case docZip[IndexDocto].schema of
        schresNFe:
        begin
          DocumentoDfe.RespSchema := 'schresNFe';
          DocumentoDfe.RespChaveNfe := docZip[IndexDocto].resDFe.chDFe;
          DocumentoDfe.CpfCnpjEmitente := docZip[IndexDocto].resDFe.CNPJCPF;
          DocumentoDfe.NomeEmitente := docZip[IndexDocto].resDFe.xNome;
          DocumentoDfe.ValorNota := docZip[IndexDocto].resDFe.vNF;
          DocumentoDfe.RespIE := docZip[IndexDocto].resDFe.IE;
          DocumentoDfe.RespSitNfe := PegarCodigoSituacaoNfe(docZip[IndexDocto].resDFe.cSitDFe);
        end;
        schprocNFe:
        begin
          DocumentoDfe.RespSchema := 'schprocNFe';
          DocumentoDfe.RespChaveNfe := docZip[IndexDocto].resDFe.chDFe;
          DocumentoDfe.CpfCnpjEmitente := docZip[IndexDocto].resDFe.CNPJCPF;
          DocumentoDfe.NomeEmitente := docZip[IndexDocto].resDFe.xNome;
          DocumentoDfe.ValorNota := docZip[IndexDocto].resDFe.vNF;
          DocumentoDfe.RespIE := docZip[IndexDocto].resDFe.IE;
          DocumentoDfe.RespSitNfe := PegarCodigoSituacaoNfe(docZip[IndexDocto].resDFe.cSitDFe);
        end;
        schresEvento:
        begin
          DocumentoDfe.RespSchema := 'schresEvento';
          DocumentoDfe.RespChaveNfe := docZip[IndexDocto].resEvento.chDFe;
          DocumentoDfe.CpfCnpjEmitente := docZip[IndexDocto].resEvento.CNPJCPF;
          DocumentoDfe.ValorNota := 0;
        end;
        schprocEventoNFe:
        begin
          DocumentoDfe.RespSchema := 'schprocEventoNFe';
          DocumentoDfe.RespEventoId := docZip[IndexDocto].procEvento.Id;
          DocumentoDfe.RespChaveNfe := docZip[IndexDocto].procEvento.chDFe;
          DocumentoDfe.CpfCnpjEmitente := docZip[IndexDocto].procEvento.CNPJ;
          DocumentoDfe.ValorNota := 0;
        end;
      end;
      ALista.Add(DocumentoDfe);
    end;
  end;
end;

end.
