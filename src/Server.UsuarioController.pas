unit Server.UsuarioController;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.Generics.Collections,
  REST.Json, Horse, Horse.GBSwagger, GBSwagger.Path.Attributes,
  Server.Data.Models, Server.UsuarioService, Server.AppLogger, Server.Data.Dtos;

type

  [SwagPath('api/v1/usuarios','3. Usuários')]
  TUsuarioController = class(THorseGBSwagger)
  public

    [SwagGET('/','Listagem')]
    [SwagResponse(200,TUsuarioDto,True)]
    [SwagResponse(400)]
    [SwagResponse(500)]
    procedure Listar;

    [SwagGET('/{id}','Buscar por id')]
    [SwagParamPath('id','Id do usuário',True)]
    [SwagResponse(200,TUsuarioDto,False)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure BuscarPorId;

    [SwagGET('/por-login/{login}','Buscar por login')]
    [SwagParamPath('login','Login do usuário',False)]
    [SwagResponse(200,TUsuarioDto,False)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure BuscarPorLogin;

    [SwagGET('/por-email/{email}','Buscar por e-mail')]
    [SwagParamPath('email','E-Mail do usuário',False)]
    [SwagResponse(200,TUsuarioDto,False)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure BuscarPorEmail;

    [SwagPOST('/','Inclusão')]
    [SwagConsumes(TGBSwaggerContentType.gbAppJSON)]
    [SwagProduces(TGBSwaggerContentType.gbAppJSON)]
    [SwagParamBody('data',TUsuarioInsertDto,'',False,True)]
    [SwagResponse(201,TUsuarioDto,False)]
    [SwagResponse(400)]
    [SwagResponse(500)]
    procedure Incluir;

    [SwagPUT('/{id}','Alteração',False,'Alteração parcial, informe apenas os campos que deseja alterar')]
    [SwagConsumes(TGBSwaggerContentType.gbAppJSON)]
    [SwagProduces(TGBSwaggerContentType.gbAppJSON)]
    [SwagParamPath('id','Id do usuário',True)]
    [SwagParamBody('data',TUsuarioUpdateDto,'Informe apenas os campos que deseja alterar, remova os que não for preencher',False,True)]
    [SwagResponse(200,TUsuarioDto,False)]
    [SwagResponse(400)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure Alterar;

    [SwagDELETE('/{id}','Excluir por id')]
    [SwagParamPath('id','Id do usuário',True)]
    [SwagResponse(204)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure ExcluirPorId;

  end;

implementation

uses
  Server.Data.JsonConverter;

{ TUsuarioController }

procedure TUsuarioController.Alterar;
var
  Service: TUsuarioService;
  DtoRes: TUsuarioDto;
  MapReq: TDictionary<String,Variant>;
  Id: Int64;
begin
  Id := StrToIntDef(FRequest.Params['id'],0);
  MapReq := TJsonConverter.JsonObjectToMapValues(FRequest.Body<TJSONObject>);
  Service := TUsuarioService.Create;
  try
    DtoRes := Service.Alterar(Id,MapReq);
    FResponse
        .Send(TJsonConverter.ObjectToJsonObject(DtoRes,True))
        .Status(THTTPStatus.OK);
  finally
    FreeAndNil(MapReq);
    FreeAndNil(Service);
  end;
end;

procedure TUsuarioController.BuscarPorEmail;
var
  Service: TUsuarioService;
  Dto: TUsuarioDto;
  Email: String;
begin
  Dto := nil;
  Email := FRequest.Params['email'];
  Service := TUsuarioService.Create;
  try
    Dto := Service.BuscarPorEmail(Email);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Dto,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TUsuarioController.BuscarPorId;
var
  Service: TUsuarioService;
  Dto: TUsuarioDto;
  Id: Int64;
begin
  Dto := nil;
  Id := StrToIntDef(FRequest.Params['id'],0);
  Service := TUsuarioService.Create;
  try
    Dto := Service.BuscarPorId(Id);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Dto,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TUsuarioController.BuscarPorLogin;
var
  Service: TUsuarioService;
  Dto: TUsuarioDto;
  Login: String;
begin
  Dto := nil;
  Login := FRequest.Params['login'];
  Service := TUsuarioService.Create;
  try
    Dto := Service.BuscarPorLogin(Login);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Dto,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TUsuarioController.ExcluirPorId;
var
  Service: TUsuarioService;
  Id: Int64;
begin
  Id := StrToIntDef(FRequest.Params['id'],0);
  Service := TUsuarioService.Create;
  try
    Service.ExcluirPorId(Id);
    FResponse.Status(THTTPStatus.NoContent);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TUsuarioController.Incluir;
var
  Service: TUsuarioService;
  DtoInsert: TUsuarioInsertDto;
  DtoRes: TUsuarioDto;
begin
  DtoInsert := TJsonConverter.JsonObjectToObject<TUsuarioInsertDto>(FRequest.Body);
  Service := TUsuarioService.Create;
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

procedure TUsuarioController.Listar;
var
  Service: TUsuarioService;
  Lista: TObjectList<TUsuarioDto>;
begin
  Service := TUsuarioService.Create;
  try
    Lista := Service.BuscarLista;
    FResponse
      .Send(TJsonConverter.ObjectListToJsonArray<TUsuarioDto>(Lista,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

end.
