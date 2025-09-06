unit Server.ConsultaDfeService;

interface

uses
  System.Classes, System.SysUtils,
  Server.AbstractService, Server.Data.Dtos, Server.EmpresaDao,
  Server.Data.ValuesObjectsVO,
  Server.AppLogger, Server.RespConsultaDfeService, Server.StrUtils,
  Server.ConsultaDfeDao;

type

  TConsultaDfeService = class(TAbstractService)
  private
    DaoEmpresa: TEmpresaDao;
    DaoConsultaDfe: TConsultaDfeDao;
    function BuscarEmpresaPeloIdRaiseException(const IdEmpresa: Int64): TEmpresaVo;
    procedure ConsultarDistribuicaoDfe(const EmpresaVo: TEmpresaVO); overload;
    function ValidarEmpresa(const EmpresaVo: TEmpresaVO): Boolean;
    procedure GravarRespostaConsulta(DtoRespConsulta: TRespConsultaDfeDto);
  public
    constructor Create;
    destructor Destroy; override;
  public
    function ConsultarDistribuicaoDfe(const IdEmpresa: Int64): Boolean; overload;
  end;

implementation

uses
  System.DateUtils;

{ TConsultaDfeService }

function TConsultaDfeService.BuscarEmpresaPeloIdRaiseException(
  const IdEmpresa: Int64): TEmpresaVo;
begin
  Result := DaoEmpresa.BuscarPorId(IdEmpresa);

  if not Assigned(Result) then
    raise Exception.Create(Format('Nenhuma empresa encontrada com este id: %d',[IdEmpresa]));
end;

function TConsultaDfeService.ConsultarDistribuicaoDfe(const IdEmpresa: Int64): Boolean;
begin
  Result := False;
  var EmpresaVo := BuscarEmpresaPeloIdRaiseException(IdEmpresa);
  try
    if (not ValidarEmpresa(EmpresaVo)) then
    begin
      Exit;
    end;
    ConsultarDistribuicaoDfe(EmpresaVo);
    Result := True;
  finally
    FreeAndNil(EmpresaVo);
  end;
end;

procedure TConsultaDfeService.ConsultarDistribuicaoDfe(const EmpresaVo: TEmpresaVO);
var
  RespConsDfeService: TRespostaConsultaDfeService;
begin
  LogInfo(Format('Consultando distribuição DFe - Empresa: (%s) - %s',[EmpresaVo.CpfCnpj,EmpresaVo.Nome]),Self.ClassType);
  RespConsDfeService := TRespostaConsultaDfeService.Create(EmpresaVO);
  try
    while True do
    begin

      var DtoResp := RespConsDfeService.DistribuicaoDFePorUltNSU(EmpresaVO.UltNsuConsultado);

      if not Assigned(DtoResp) then
        Exit;

      try
        GravarRespostaConsulta(DtoResp);

        var RespStatus := DtoResp.ConsultaDfe.RespStatus;
        var RespUltNsu := DtoResp.ConsultaDfe.RespUltNsu;
        var RespMaxNsu := DtoResp.ConsultaDfe.RespMaxNsu;

        if (RespStatus = COD_CONSUMO_INDEVIDO) then
        begin
          LogInfo(Format('Consumo indevido Nsu usado %s, Nsu Resp: %s, Max %s',[EmpresaVo.UltNsuConsultado,RespUltNsu,RespMaxNsu]),Self.ClassType);
        end;

        EmpresaVo.UltNsuConsultado := RespUltNsu;

        if (RespStatus = COD_CONSUMO_INDEVIDO) or (RespStatus = COD_DOCUMENTO_LOCALIZADO) then
        begin
          DaoEmpresa.RegistrarUltNsuConsultado(EmpresaVo.Id,EmpresaVo.UltNsuConsultado);
        end;

        if (RespStatus <> COD_DOCUMENTO_LOCALIZADO) or
           ((RespStatus = COD_DOCUMENTO_LOCALIZADO) and (RespUltNsu >= RespMaxNsu)) then
        begin
          Break;
        end;

      finally
        FreeAndNil(DtoResp);
      end;

    end;
  finally
    FreeAndNil(RespConsDfeService);
  end;
  LogInfo('Fim da consulta de distribuição DFe',Self.ClassType);
end;

constructor TConsultaDfeService.Create;
begin
  inherited;
  DaoEmpresa := TEmpresaDao.Create(GetDbConnection);
  DaoConsultaDfe := TConsultaDfeDao.Create(GetDbConnection);
end;

destructor TConsultaDfeService.Destroy;
begin
  FreeAndNil(DaoEmpresa);
  FreeAndNil(DaoConsultaDfe);
  inherited;
end;

procedure TConsultaDfeService.GravarRespostaConsulta(
  DtoRespConsulta: TRespConsultaDfeDto);
begin
  GetDbConnection.StartTransaction;
  try
    DaoConsultaDfe.Incluir(DtoRespConsulta);
    GetDbConnection.Commit;
  except on E: Exception do
    begin
      GetDbConnection.Rollback;
    end;
  end;
end;

function TConsultaDfeService.ValidarEmpresa(
  const EmpresaVo: TEmpresaVO): Boolean;
begin
  Result := (EmpresaVo.IsAtivo) and
            (EmpresaVo.IsTemCertificado) and
            (EmpresaVo.IsJaPodeFazerNovaConsulta);
end;

end.
