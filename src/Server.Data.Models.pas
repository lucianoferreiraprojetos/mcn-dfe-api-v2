unit Server.Data.Models;

interface

uses
  System.SysUtils, System.Classes, Server.DataAccess.AttributeMappings;

type

  TEntidadeBase = class
  private
    FId: Int64;
    FIsAtivo: Boolean;
    FDataHoraInclusao: TDateTime;
    FDataHoraAlteracao: TDateTime;
  public
    [SqlColumn('ID')]
    property Id: Int64 read FId write FId;
    [SqlColumn('IS_ATIVO')]
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    [SqlColumn('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumn('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
  end;

  [SqlTable('PERFIL_USUARIO')]
  TPerfilUsuario = class
  private
    FNome: String;
    FIsAtivo: Boolean;
    FId: Int64;
    FDataHoraAlteracao: TDateTime;
    FDataHoraInclusao: TDateTime;
  public
    property Id: Int64 read FId write FId;
    property Nome: String read FNome write FNome;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    [SqlColumnMapping('DTH_INCLUSAO')]
    property DataHoraInclusao: TDateTime read FDataHoraInclusao write FDataHoraInclusao;
    [SqlColumnMapping('DTH_ALTERACAO')]
    property DataHoraAlteracao: TDateTime read FDataHoraAlteracao write FDataHoraAlteracao;
  end;

  [SqlTable('USUARIO')]
  TUsuario = class
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

  [SqlTable('EMPRESA')]
  TEmpresa = class(TEntidadeBase)
  private
    FNome: String;
    FCpfCnpj: String;
    FEmail: String;
    FCertSenha: String;
    FCertDataValidade: TDate;
    FUltNsu: String;
    FDataHoraUltConsNfe: TDateTime;
    FUfFiscal: String;
    FAmbienteNfe: String;
    FManifestoAutomatico: Boolean;
  public
    property Nome: String read FNome write FNome;
    property CpfCnpj: String read FCpfCnpj write FCpfCnpj;
    property Email: String read FEmail write FEmail;
    property UfFiscal: String read FUfFiscal write FUfFiscal;
    property CertSenha: String read FCertSenha write FCertSenha;
    property CertDataValidade: TDate read FCertDataValidade write FCertDataValidade;
    property ManifestoAutomatico: Boolean read FManifestoAutomatico write FManifestoAutomatico;
    property UltNsu: String read FUltNsu write FUltNsu;
    property AmbienteNfe: String read FAmbienteNfe write FAmbienteNfe;
    property DataHoraUltConsNfe: TDateTime read FDataHoraUltConsNfe write FDataHoraUltConsNfe;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  [SqlTable('CONSULTA_DFE')]
  [SqlSequence('SEQ_CONSULTA_DFE_ID')]
  TConsultaDfe = class(TEntidadeBase)
  private
    FIdEmpresaDest: Int64;
    FCpfCnpjDest: String;
    FSituacaoAtual: String;
  public
    [JoinColumn('ID_EMPRESA_DEST',[])]
    property IdEmpresaDest: Int64 read FIdEmpresaDest write FIdEmpresaDest;
    [SqlColumn('CPF_CNPJ_DEST')]
    property CpfCnpjDest: String read FCpfCnpjDest write FCpfCnpjDest;
    [SqlColumn('SITUACAO_ATUAL')]
    property SituacaoAtual: String read FSituacaoAtual write FSituacaoAtual;
  end;

  [SqlTable('DOCUMENTO_DFE')]
  [SqlSequence('SEQ_DOCUMENTO_DFE_ID')]
  TDocumentoDfe = class(TEntidadeBase)
  private
    FIdConsulta: Int64;
  public
    [JoinColumn('ID_CONSULTA_DFE',[])]
    property IdConsultaDfe: Int64 read FIdConsulta write FIdConsulta;
  end;

  [SqlTable('NOTA_ENTRADA_NFE')]
  [SqlSequence('SEQ_NOTA_ENTRADA_NFE_ID')]
  TNotaEntradaNfe = class(TEntidadeBase)
  end;

  [SqlTable('MANIFESTO')]
  [SqlSequence('SEQ_MANIFESTO_ID')]
  TManifesto = class(TEntidadeBase)
  end;

implementation

{ TEmpresa }

constructor TEmpresa.Create;
begin
  inherited;
end;

destructor TEmpresa.Destroy;
begin
  inherited;
end;

end.
