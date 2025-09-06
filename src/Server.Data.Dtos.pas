unit Server.Data.Dtos;

interface

uses
  System.Classes, System.Generics.Collections,
  Server.Data.Models, Server.DataAccess.AttributeMappings,
  System.SysUtils;

type

{******************************************************************************}
{* Dto de autenticação                                                        *}
{******************************************************************************}

  TTokenAutenticacaoDto = class
  private
    FToken: String;
    FBearerToken: String;
    FNomeUsuario: String;
  public
    property Token: String read FToken write FToken;
    property BearerToken: String read FBearerToken write FBearerToken;
    property NomeUsuario: String read FNomeUsuario write FNomeUsuario;
  end;

{******************************************************************************}
{* Dto perfil de usuário                                                      *}
{******************************************************************************}

  TPerfilUsuarioDto = class
  private
    FIsAtivo: Boolean;
    FId: Int64;
    FNome: String;
    FDataHoraInclusao: TDateTime;
    FDataHoraAlteracao: TDateTime;
  public
    [SqlPk]
    property Id: Int64 read FId write FId;
    property Nome: String read FNome write FNome;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    [SqlColumnMapping('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumnMapping('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
  end;

{******************************************************************************}
{* Dtos de usuário                                                            *}
{******************************************************************************}

  TUsuarioAbstractDto = class abstract
  private
    FNome: String;
    FEmail: String;
    FIdPerfil: Int64;
  public
    property Nome: String read FNome write FNome;
    property Email: String read FEmail write FEmail;
    property IdPerfil: Int64 read FIdPerfil write FIdPerfil;
  end;

  TUsuarioInsertDto = class(TUsuarioAbstractDto)
  private
    FLogin: String;
    FSenha: String;
  public
    property Login: String read FLogin write FLogin;
    property Senha: String read FSenha write FSenha;
  end;

  TUsuarioUpdateDto = class(TUsuarioAbstractDto)
  private
    FSenha: String;
    FIsAtivo: Boolean;
  public
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    property Senha: String read FSenha write FSenha;
  end;

  TUsuarioDto = class(TUsuarioAbstractDto)
  private
    FLogin: String;
    FId: Int64;
    FNomePerfil: String;
    FDataHoraInclusao: TDateTime;
    FDataHoraAlteracao: TDateTime;
    FIsAtivo: Boolean;
  public
    property Id: Int64 read FId write FId;
    property Login: String read FLogin write FLogin;
    property NomePerfil: String read FNomePerfil write FNomePerfil;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    [SqlColumnMapping('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumnMapping('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
  public
  end;

  TUsuarioConsultaComSenhaDto = class(TUsuarioDto)
  private
    FSenha: String;
  public
    property Senha: String read FSenha write FSenha;
  end;

{******************************************************************************}
{* Dtos de empresa                                                            *}
{******************************************************************************}

  TEmpresaAbstractDto = class abstract
  private
    FUfFiscal: String;
    FEmail: String;
    FManifestoAutomatico: Boolean;
    FAmbienteNfe: String;
    FNome: String;
  public
    property Nome: String read FNome write FNome;
    property Email: String read FEmail write FEmail;
    property UfFiscal: String read FUfFiscal write FUfFiscal;
    property ManifestoAutomatico: Boolean read FManifestoAutomatico write FManifestoAutomatico;
    property AmbienteNfe: String read FAmbienteNfe write FAmbienteNfe;
  end;

  TEmpresaDto = class(TEmpresaAbstractDto)
  private
    FId: Int64;
    FIsAtivo: Boolean;
    FCertDataValidade: TDate;
    FDataHoraUltConsNfe: TDateTime;
    FCpfCnpj: String;
    FDataHoraAlteracao: TDateTime;
    FUltNsu: String;
    FDataHoraInclusao: TDateTime;
  public
    property Id: Int64 read FId write FId;
    property CpfCnpj: String read FCpfCnpj write FCpfCnpj;
    property CertDataValidade: TDate read FCertDataValidade write FCertDataValidade;
    property UltNsu: String read FUltNsu write FUltNsu;
    property DataHoraUltConsNfe: TDateTime read FDataHoraUltConsNfe write FDataHoraUltConsNfe;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    [SqlColumnMapping('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumnMapping('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
  end;

  TEmpresaUpdateDto = class(TEmpresaAbstractDto)
  private
    FCertBase64: String;
    FCertSenha: String;
    FIsAtivo: Boolean;
  public
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    property CertBase64: String read FCertBase64 write FCertBase64;
    property CertSenha: String read FCertSenha write FCertSenha;
  end;

  TEmpresaInsertDto = class(TEmpresaUpdateDto)
  private
    FCpfCnpj: String;
  public
    property CpfCnpj: String read FCpfCnpj write FCpfCnpj;
  end;

{******************************************************************************}
{* Dtos de consulta de dfe                                                    *}
{******************************************************************************}

  TConsultaDfeDto = class
  private
    FId: Int64;
    FIdEmpresa: Int64;
    FCpfCnpjEmpresa: String;
    FAmbienteNfe: String;
    FUfFiscal: String;
    FUltNsuConsultado: String;
    FRespXml: String;
    FRespXmlSoap: String;
    FRespStatus: Integer;
    FRespTxtMotivo: String;
    FRespUltNsu: String;
    FRespMaxNsu: String;
    FRespQtdeDoctos: Integer;
  public
    property Id: Int64 read FId write FId;
    property IdEmpresa: Int64 read FIdEmpresa write FIdEmpresa;
    property CpfCnpjEmpresa: String read FCpfCnpjEmpresa write FCpfCnpjEmpresa;
    property AmbienteNfe: String read FAmbienteNfe write FAmbienteNfe;
    property UfFiscal: String read FUfFiscal write FUfFiscal;
    property UltNsuConsultado: String read FUltNsuConsultado write FUltNsuConsultado;
    property RespXml: String read FRespXml write FRespXml;
    property RespSoapXmpl: String read FRespXmlSoap write FRespXmlSoap;
    property RespStatus: Integer read FRespStatus write FRespStatus;
    property RespTxtMotivo: String read FRespTxtMotivo write FRespTxtMotivo;
    property RespUltNsu: String read FRespUltNsu write FRespUltNsu;
    property RespMaxNsu: String read FRespMaxNsu write FRespMaxNsu;
    property RespQtdeDoctos: Integer read FRespQtdeDoctos write FRespQtdeDoctos;
  end;

{******************************************************************************}
{* Dtos de documento de dfe                                                   *}
{******************************************************************************}

  TDocumentoDfeDto = class
  private
    FId: Int64;
    FIdConsultaDfe: Int64;
    FRespSchema: String;
    FRespXml: String;
    FRespChaveNfe: String;
    FRespEventoId: String;
    FRespNsu: String;
    FCpfCnpjEmitente: String;
    FNomeEmitente: String;
    FValorNota: Double;
    FDataHoraDownloadXml: TDateTime;
    FDataHoraAlteracao: TDateTime;
    FDataHoraInclusao: TDateTime;
    FIsAtivo: Boolean;
    FRespIe: String;
    FRespSitNfe: String;
  public
    property Id: Int64 read FId write FId;
    property IdConsultaDfe: Int64 read FIdConsultaDfe write FIdConsultaDfe;
    property RespSchema: String read FRespSchema write FRespSchema;
    property RespXml: String read FRespXml write FRespXml;
    property RespChaveNfe: String read FRespChaveNfe write FRespChaveNfe;
    property RespEventoId: String read FRespEventoId write FRespEventoId;
    property RespNsu: String read FRespNsu write FRespNsu;
    property RespIe: String read FRespIe write FRespIe;
    property RespSitNfe: String read FRespSitNfe write FRespSitNfe;
    property CpfCnpjEmitente: String read FCpfCnpjEmitente write FCpfCnpjEmitente;
    property NomeEmitente: String read FNomeEmitente write FNomeEmitente;
    property ValorNota: Double read FValorNota write FValorNota;
    property DataHoraDownloadXml: TDateTime read FDataHoraDownloadXml write FDataHoraDownloadXml;
    [SqlColumnMapping('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumnMapping('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
  end;

{******************************************************************************}
{* Dtos de resposta de consulta dfe                                           *}
{******************************************************************************}

  TRespConsultaDfeDto = class
  private
    FConsultaDfe: TConsultaDfeDto;
    FDocumentosDfe: TObjectList<TDocumentoDfeDto>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property ConsultaDfe: TConsultaDfeDto read FConsultaDfe write FConsultaDfe;
    property DocumentosDfe: TObjectList<TDocumentoDfeDto> read FDocumentosDfe write FDocumentosDfe;
  end;

implementation

uses
  System.NetEncoding;


{ TRespConsultaDfeDto }

constructor TRespConsultaDfeDto.Create;
begin
  FConsultaDfe := TConsultaDfeDto.Create;
  FDocumentosDfe := TObjectList<TDocumentoDfeDto>.Create;
end;

destructor TRespConsultaDfeDto.Destroy;
begin
  FreeAndNil(FDocumentosDfe);
  FreeAndNil(FConsultaDfe);
  inherited;
end;

end.
