unit Server.EmpresaController;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.Generics.Collections,
  REST.Json, Horse, Horse.GBSwagger, GBSwagger.Path.Attributes,
  Server.Data.Models, Server.EmpresaService, Server.AppLogger, Server.Data.Dtos,
  Server.Data.JsonConverter, Server.Data.Filters;

type

  [SwagPath('api/v1/empresas','4. Empresas')]
  TEmpresaController = class(THorseGBSwagger)
  private
  public

    [SwagGET('/','Listagem')]
    [SwagParamQuery('situacao','A = Ativas, I = Inativas, Em branco = Ambos')]
    [SwagParamQuery('manifesto-automatico','Somente empresas com manifesto automático, S = Sim, N = Não')]
    [SwagParamQuery('nome','Iniciais do nome')]
    [SwagParamQuery('cpf-cnpj','CPF/CNPJ')]
    [SwagResponse(200,TEmpresaDto,True)]
    [SwagResponse(400)]
    [SwagResponse(500)]
    procedure Listar;

    [SwagGET('/{id}','Buscar por id')]
    [SwagParamPath('id','Id da empresa',True)]
    [SwagResponse(200,TEmpresaDto,False)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure BuscarPorId;

    [SwagGET('/por-email/{email}','Buscar por e-mail')]
    [SwagParamPath('email','E-Mail da empresa',False)]
    [SwagResponse(200,TEmpresaDto,False)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure BuscarPorEmail;

    [SwagGET('/por/cpf-cnpj/{cpf-cnpj}','Buscar por CPF/CNPJ')]
    [SwagParamPath('cpf-cnpj','CPF/CNPJ da empresa, informe apenas os números, sem a máscara',False)]
    [SwagResponse(200,TEmpresaDto,False)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure BuscarPorCpfCnpj;

    [SwagPOST('/','Inclusão')]
    [SwagConsumes(TGBSwaggerContentType.gbAppJSON)]
    [SwagProduces(TGBSwaggerContentType.gbAppJSON)]
    [SwagParamBody('data',TEmpresaInsertDto,'',False,True)]
    [SwagResponse(201,TEmpresaDto,False)]
    [SwagResponse(400)]
    [SwagResponse(500)]
    procedure Incluir;

    [SwagPUT('/{id}','Alteração')]
    [SwagConsumes(TGBSwaggerContentType.gbAppJSON)]
    [SwagProduces(TGBSwaggerContentType.gbAppJSON)]
    [SwagParamPath('id','Id da empresa',True)]
    [SwagParamBody('data',TEmpresaUpdateDto,'Informe apenas os campos que deseja alterar, remova os que não for preencher',False,True)]
    [SwagResponse(200,TEmpresaDto,False)]
    [SwagResponse(400)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure Alterar;

    [SwagPUT('/upload-certificado/{id}','Upload de certificado')]
    [SwagConsumes(TGBSwaggerContentType.gbMultiPartFormData)]
    [SwagProduces(TGBSwaggerContentType.gbAppJSON)]
    [SwagParamPath('id','Id da empresa',True)]
    [SwagParamFormData('certificado',True)]
    [SwagParamFormData('senha',False)]
    [SwagResponse(200,TEmpresa,False)]
    [SwagResponse(400)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure UploadCertificadoBytes();

  end;

implementation

{ TEmpresaController }

procedure TEmpresaController.Alterar;
var
  Service: TEmpresaService;
  Id: Int64;
  MapValues: TDictionary<String,Variant>;
  DtoRes: TEmpresaDto;
begin
  Id := StrToIntDef(FRequest.Params['id'],0);
  MapValues := TJsonConverter.JsonObjectToMapValues(FRequest.Body<TJSONObject>);
  Service := TEmpresaService.Create;
  try
    DtoRes := Service.Alterar(Id,MapValues);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(DtoRes,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(MapValues);
    FreeAndNil(Service);
  end;
end;

procedure TEmpresaController.BuscarPorCpfCnpj;
var
  Service: TEmpresaService;
  CpfCnpj: String;
  Dto: TEmpresaDto;
begin
  CpfCnpj := FRequest.Params['cpf-cnpj'];
  Service := TEmpresaService.Create;
  try
    Dto := Service.BuscarPorCpfCnpj(CpfCnpj);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Dto,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TEmpresaController.BuscarPorEmail;
var
  Service: TEmpresaService;
  Email: String;
  Dto: TEmpresaDto;
begin
  Email := FRequest.Params['email'];
  Service := TEmpresaService.Create;
  try
    Dto := Service.BuscarPorEmail(Email);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Dto,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TEmpresaController.BuscarPorId;
var
  Service: TEmpresaService;
  Id: Int64;
  Dto: TEmpresaDto;
begin
  Id := StrToIntDef(FRequest.Params['id'],0);
  Service := TEmpresaService.Create;
  try
    Dto := Service.BuscarPorId(Id);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Dto,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TEmpresaController.Incluir;
var
  Service: TEmpresaService;
  DtoInsert: TEmpresaInsertDto;
  DtoRes: TEmpresaDto;
begin
  DtoInsert := TJsonConverter.JsonObjectToObject<TEmpresaInsertDto>(FRequest.Body);
  Service := TEmpresaService.Create;
  try
    DtoRes := Service.Incluir(DtoInsert);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(DtoRes,True))
      .Status(THTTPStatus.Created);
  finally
    FreeAndNil(DtoInsert);
    FreeAndNil(Service);
  end;
end;

procedure TEmpresaController.Listar;
var
  Service: TEmpresaService;
  Filtro: TEmpresaFiltro;
begin
  Filtro.Clear;
  if FRequest.Query['situacao'].ToUpper = 'A' then
    Filtro.Situacao := TEnumSituacao.eSitAtivo
  else if FRequest.Query['situacao'].ToUpper = 'I' then
    Filtro.Situacao := TEnumSituacao.eSitAtivo
  else
    Filtro.Situacao := TEnumSituacao.eSitTodos;
  Filtro.CpfCnpj := FRequest.Query['cpf-cnpj'];
  Service := TEmpresaService.Create;
  try
    var Lista := Service.BuscarLista(Filtro);
    FResponse
      .Send(TJsonConverter.ObjectListToJsonArray<TEmpresaDto>(Lista,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TEmpresaController.UploadCertificadoBytes;
var
  Id: Int64;
  Service: TEmpresaService;
  CertSenha: String;
begin
  Id := StrToIntDef(FRequest.Params['id'],0);
  CertSenha := FRequest.ContentFields['senha'];
  Service := TEmpresaService.Create;
  try
    Service.UploadCertificado(Id,CertSenha,FRequest.ContentFields.Field('certificado').AsStream);
    FResponse
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

end.
