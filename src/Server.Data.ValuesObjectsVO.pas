{******************************************************************************}
{ Unit contendo objetos de transição de camadas, não serializáveis
{******************************************************************************}
unit Server.Data.ValuesObjectsVO;

interface

uses
  System.SysUtils, Server.Data.Dtos, Server.DataAccess.AttributeMappings,
  System.Classes;

type

  TUsuarioVO = class
  private
    FNome: String;
    FLogin: String;
    FSenha: String;
    FEmail: String;
    FIdPerfil: Int64;
    FId: Int64;
    FNomePerfil: String;
    FDataHoraAlteracao: TDateTime;
    FDataHoraInclusao: TDateTime;
    FIsAtivo: Boolean;
  public
    property Id: Int64 read FId write FId;
    property Nome: String read FNome write FNome;
    property Login: String read FLogin write FLogin;
    property Senha: String read FSenha write FSenha;
    property Email: String read FEmail write FEmail;
    property IdPerfil: Int64 read FIdPerfil write FIdPerfil;
    property NomePerfil: String read FNomePerfil write FNomePerfil;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    [SqlColumnMapping('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumnMapping('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
  end;

  TUsuarioInsertVO = class
  private
    FNome: String;
    FLogin: String;
    FSenha: String;
    FEmail: String;
    FIdPerfil: Int64;
  public
    [NotEmptyValidation('O nome deve ser informado')]
    property Nome: String read FNome write FNome;

    [NotEmptyValidation('O login deve ser informado')]
    property Login: String read FLogin write FLogin;

    [NotEmptyValidation('A senha deve ser informada')]
    property Senha: String read FSenha write FSenha;

    [NotEmptyValidation('O e-mail deve ser informado')]
    property Email: String read FEmail write FEmail;

    [MinValidation(1,'O id do perfil deve ser informado')]
    property IdPerfil: Int64 read FIdPerfil write FIdPerfil;
  end;

  TUsuarioUpdateVO = class
  private
    FNome: String;
    FSenha: String;
    FEmail: String;
    FIdPerfil: Int64;
    FId: Int64;
    FIsAtivo: Boolean;
  public
    property Id: Int64 read FId write FId;

    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;

    [NotEmptyValidation('O nome deve ser informado')]
    property Nome: String read FNome write FNome;

    [NotEmptyValidation('A senha deve ser informada')]
    property Senha: String read FSenha write FSenha;

    [NotEmptyValidation('O e-mail deve ser informado')]
    property Email: String read FEmail write FEmail;

    [MinValidation(1,'O id do perfil deve ser informado')]
    property IdPerfil: Int64 read FIdPerfil write FIdPerfil;
  end;

  TEmpresaAbstractVO = class abstract
  strict private
    FUfFiscal: String;
    FEmail: String;
    FCertBytes: TBytes;
    FManifestoAutomatico: Boolean;
    FAmbienteNfe: String;
    FNome: String;
    FCertSenha: String;
  public
    property Nome: String read FNome write FNome;
    property Email: String read FEmail write FEmail;
    property UfFiscal: String read FUfFiscal write FUfFiscal;
    property ManifestoAutomatico: Boolean read FManifestoAutomatico write FManifestoAutomatico;
    property AmbienteNfe: String read FAmbienteNfe write FAmbienteNfe;
    property CertSenha: String read FCertSenha write FCertSenha;
    property CertBytes: TBytes read FCertBytes write FCertBytes;
  public
    procedure LoadCertBytesFromBase64(const ACertBase64: String);
    procedure LoadCertBytesFromStream(const AStream: TStream);
  end;

  TEmpresaVO = class(TEmpresaAbstractVO)
  private
    FId: Int64;
    FIsAtivo: Boolean;
    FDataHoraAlteracao: TDateTime;
    FDataHoraInclusao: TDateTime;
    FCpfCnpj: String;
    FUltNsuConsultado: String;
    FDataHoraUltConsulta: TDateTime;
  public
    property Id: Int64 read FId write FId;
    property CpfCnpj: String read FCpfCnpj write FCpfCnpj;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    [SqlColumnMapping('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumnMapping('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
    [SqlColumnMapping('ULT_NSU')]
    property UltNsuConsultado: String read FUltNsuConsultado write FUltNsuConsultado;
    [SqlColumnMapping('DTH_ULT_CONS_NFE')]
    property DataHoraUltConsulta: TDateTime read FDataHoraUltConsulta write FDataHoraUltConsulta;
  public
    function IsJaPodeFazerNovaConsulta: Boolean;
    function IsTemCertificado: Boolean;
    function MinutosRestantesParaNovaConsulta: Integer;
  end;

  TEmpresaInsertVO = class(TEmpresaAbstractVO)
  strict private
    FCpfCnpj: String;
  public
    property CpfCnpj: String read FCpfCnpj write FCpfCnpj;
  public
    class function ConvertFrom(EmpresaInsertDto: TEmpresaInsertDto): TEmpresaInsertVO;
  end;

  TEmpresaUpdateVO = class(TEmpresaAbstractVO)
  private
    FId: Int64;
    FIsAtivo: Boolean;
  public
    property Id: Int64 read FId write FId;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
  end;

implementation

uses
  System.DateUtils, System.NetEncoding;

{ TEmpresaInsertVO }

class function TEmpresaInsertVO.ConvertFrom(
  EmpresaInsertDto: TEmpresaInsertDto): TEmpresaInsertVO;
begin
  Result := TEmpresaInsertVO.Create;
  Result.CpfCnpj := EmpresaInsertDto.CpfCnpj;
  Result.Nome := EmpresaInsertDto.Nome;
  Result.Email := EmpresaInsertDto.Email;
  Result.UfFiscal := EmpresaInsertDto.UfFiscal;
  Result.ManifestoAutomatico := EmpresaInsertDto.ManifestoAutomatico;
  Result.AmbienteNfe := EmpresaInsertDto.AmbienteNfe;
  Result.CertSenha := EmpresaInsertDto.CertSenha;
  if not EmpresaInsertDto.CertBase64.IsEmpty then
    Result.LoadCertBytesFromBase64(EmpresaInsertDto.CertBase64);
end;

{ TEmpresaAbstractVO }

procedure TEmpresaAbstractVO.LoadCertBytesFromBase64(const ACertBase64: String);
begin
  FCertBytes := TNetEncoding.Base64.DecodeStringToBytes(ACertBase64);
end;

procedure TEmpresaAbstractVO.LoadCertBytesFromStream(const AStream: TStream);
var
  BytesStream: TBytesStream;
begin
  BytesStream := TBytesStream.Create;
  try
    BytesStream.LoadFromStream(AStream);
    FCertBytes := BytesStream.Bytes;
  finally
    FreeAndNil(BytesStream);
  end;
end;

{ TEmpresaVO }

function TEmpresaVO.IsJaPodeFazerNovaConsulta: Boolean;
begin
  Result := MinutosRestantesParaNovaConsulta <= 0;
end;

function TEmpresaVO.IsTemCertificado: Boolean;
begin
  Result := not (CertBytes = nil);
end;

function TEmpresaVO.MinutosRestantesParaNovaConsulta: Integer;
const
  UMA_HORA_E_VINTE_MINUTOS = 80;
begin
  var DataHoraFutura := IncMinute(FDataHoraUltConsulta,UMA_HORA_E_VINTE_MINUTOS);
  if DataHoraFutura > Now then
    Result := MinutesBetween(DataHoraFutura,Now)
  else
    Result := 0;
end;

end.
