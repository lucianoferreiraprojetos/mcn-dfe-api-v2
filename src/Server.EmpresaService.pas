unit Server.EmpresaService;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Classes,
  System.NetEncoding, Server.Data.Models, Server.AbstractService,
  Server.Exceptions, Server.EmpresaDao, Server.AppLogger, Server.Data.Dtos,
  Server.Data.ValuesObjectsVO, Server.DataAccess.RttiUtil,
  Server.DataAccess.ObjectMapper, Server.DataAccess.ObjectValidation,
  Server.Data.Filters;

type

  TEmpresaService = class(TAbstractService)
  private
    DaoEmpresa: TEmpresaDao;
    function ChecarSeExisteOutraEmpresaComEsteEmail(IdEmpresaAtual: Int64; Email: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function BuscarPorId(Id: Int64): TEmpresaDto;
    function BuscarPorCpfCnpj(const ACpfCnpj: String): TEmpresaDto;
    function BuscarPorEmail(const AEmail: String): TEmpresaDto;
    function BuscarLista(AFiltro: TEmpresaFiltro): TObjectList<TEmpresaDto>;
    function Incluir(DtoInsert: TEmpresaInsertDto): TEmpresaDto;
    function Alterar(const Id: Int64; MapValues: TDictionary<String,Variant>): TEmpresaDto;
    procedure UploadCertificado(const IdEmpresa: Int64; const ACertSenha: String; ACertStream: TStream);
  end;

implementation

{ TEmpresaService }

function TEmpresaService.Alterar(const Id: Int64;
  MapValues: TDictionary<String, Variant>): TEmpresaDto;
var
  EmpresaUpdateVO: TEmpresaUpdateVO;
begin

  var EmpresaVO := DaoEmpresa.BuscarPorId(Id);

  if not Assigned(EmpresaVO) then
    raise Exception.Create(Format('Não existe uma empresa com este id:%d',[Id]));

  try
    EmpresaUpdateVO := TObjectMapper.MapTo<TEmpresaUpdateVO>(EmpresaVO,False);
    try
      TObjectMapper.Merge(MapValues,EmpresaUpdateVO,False);

      TObjectValidation.Validate(EmpresaUpdateVO);

      if ChecarSeExisteOutraEmpresaComEsteEmail(EmpresaVO.Id,EmpresaVO.Email.ToLower) then
        raise Exception.Create(Format('Já existe outra empresa com este e-mail: %s',[EmpresaUpdateVO.Email]));

      GetDbConnection.StartTransaction;
      try
        Result := TObjectMapper.MapTo<TEmpresaDto>(DaoEmpresa.Alterar(EmpresaUpdateVO),True);
        GetDbConnection.Commit;
      except on E: Exception do
        begin
          GetDbConnection.Rollback;
          LogError(E.Message,Self.ClassType);
          raise E;
        end;
      end;
    finally
      FreeAndNil(EmpresaUpdateVO);
    end;
  finally
    FreeAndNil(EmpresaVO);
  end;
end;

function TEmpresaService.BuscarPorCpfCnpj(const ACpfCnpj: String): TEmpresaDto;
begin
  var EmpresaVO := DaoEmpresa.BuscarPorCpfCnpj(ACpfCnpj);

  if not Assigned(EmpresaVO) then
    raise ERecursoNaoEncontradoException.Create(Format('Não foi encontrado nenhuma empresa com este CPF/CNPJ: %s',[ACpfCnpj]));

  Result := TObjectMapper.MapTo<TEmpresaDto>(EmpresaVO,True);
end;

function TEmpresaService.BuscarPorEmail(const AEmail: String): TEmpresaDto;
begin
  var EmpresaVO := DaoEmpresa.BuscarPorEmail(AEmail);

  if not Assigned(EmpresaVO) then
    raise ERecursoNaoEncontradoException.Create(Format('Não foi encontrado nenhuma empresa com este e-mail: %s',[AEmail]));

  Result := TObjectMapper.MapTo<TEmpresaDto>(EmpresaVO,True);
end;

function TEmpresaService.BuscarPorId(Id: Int64): TEmpresaDto;
begin
  var EmpresaVO := DaoEmpresa.BuscarPorId(Id);

  if not Assigned(EmpresaVO) then
    raise ERecursoNaoEncontradoException.Create(Format('Não foi encontrado nenhuma empresa com este id: %d',[Id]));

  Result := TObjectMapper.MapTo<TEmpresaDto>(EmpresaVO,True);
end;

function TEmpresaService.BuscarLista(AFiltro: TEmpresaFiltro): TObjectList<TEmpresaDto>;
begin
  Result := TObjectMapper.MapTo<TEmpresaVO,TEmpresaDto>(DaoEmpresa.BuscarLista(AFiltro),True);
end;

function TEmpresaService.ChecarSeExisteOutraEmpresaComEsteEmail(
  IdEmpresaAtual: Int64; Email: String): Boolean;
begin
  Result := False;

  var Empresa := DaoEmpresa.BuscarPorEmail(Email.ToLower);

  if not Assigned(Empresa) then
    Exit;

  try
    Result := Empresa.Id <> IdEmpresaAtual;
  finally
    FreeAndNil(Empresa);
  end;
end;

constructor TEmpresaService.Create;
begin
  inherited;
  DaoEmpresa := TEmpresaDao.Create(GetDbConnection);
end;

destructor TEmpresaService.Destroy;
begin
  FreeAndNil(DaoEmpresa);
  inherited;
end;

function TEmpresaService.Incluir(DtoInsert: TEmpresaInsertDto): TEmpresaDto;
begin
  var VOInsert := TObjectMapper.MapTo<TEmpresaInsertVO>(DtoInsert,False);

  TObjectValidation.Validate(VOInsert);

  if DaoEmpresa.ChecarSeExistePorCampo('CPF_CNPJ',VOInsert.CpfCnpj) then
    raise Exception.Create('Já existe uma empresa com este CPF/CNPJ');

  if DaoEmpresa.ChecarSeExistePorCampo('EMAIL',VOInsert.Email) then
    raise Exception.Create('Já existe uma empresa com este e-mail');

  GetDbConnection.StartTransaction;
  try

    Result := TObjectMapper.MapTo<TEmpresaDto>(DaoEmpresa.Incluir(VOInsert),True);

    GetDbConnection.Commit;

  except on E: Exception do
    begin
      GetDbConnection.Rollback;
      LogError(E.Message,Self.ClassType);
      raise E;
    end;
  end;

end;

procedure TEmpresaService.UploadCertificado(const IdEmpresa: Int64;
  const ACertSenha: String; ACertStream: TStream);
begin
  var EmpresaVO := DaoEmpresa.BuscarPorId(IdEmpresa);

  if not Assigned(EmpresaVO) then
    raise Exception.Create(Format('Não existe uma empresa com este id:%d',[IdEmpresa]));

  try
    var EmpresaUpdateVO := TObjectMapper.MapTo<TEmpresaUpdateVO>(EmpresaVO,False);

    try
      if not ACertSenha.IsEmpty then
        EmpresaUpdateVO.CertSenha := ACertSenha;

      EmpresaUpdateVO.LoadCertBytesFromStream(ACertStream);
      DaoEmpresa.Alterar(EmpresaUpdateVO);
    finally
      FreeAndNil(EmpresaUpdateVO);
    end;

  finally
    FreeAndNil(EmpresaVO);
  end;
end;

end.
