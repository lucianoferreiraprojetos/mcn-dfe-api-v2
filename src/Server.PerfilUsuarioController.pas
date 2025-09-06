unit Server.PerfilUsuarioController;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.Generics.Collections,
  REST.Json, Horse, Horse.GBSwagger, GBSwagger.Path.Attributes,
  Server.PerfilUsuarioService, Server.AppLogger, Server.Data.Dtos;

type

  [SwagPath('api/v1/perfis-usuarios','2. Perfis de Usuários')]
  TPerfilUsuarioController = class(THorseGBSwagger)
  public

    [SwagGET('/','Listagem')]
    [SwagResponse(200,TPerfilUsuarioDto,True)]
    [SwagResponse(400)]
    [SwagResponse(500)]
    procedure Listar;

    [SwagGET('/{id}','Buscar por id')]
    [SwagParamPath('id','Id do Perfil',True)]
    [SwagResponse(200,TPerfilUsuarioDto,False)]
    [SwagResponse(404)]
    [SwagResponse(500)]
    procedure BuscarPorId;

  end;

implementation

uses
  Server.Data.JsonConverter;

{ TPerfilUsuarioController }

procedure TPerfilUsuarioController.BuscarPorId;
var
  Service: TPerfilUsuarioService;
  Id: Int64;
begin
  Id := StrToIntDef(FRequest.Params['id'],0);
  Service := TPerfilUsuarioService.Create;
  try
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Service.BuscarPorId(Id),True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

procedure TPerfilUsuarioController.Listar;
var
  Service: TPerfilUsuarioService;
  Lista: TObjectList<TPerfilUsuarioDto>;
begin
  Service := TPerfilUsuarioService.Create;
  try
    Lista := Service.BuscarLista;
    FResponse
      .Send(TJsonConverter.ObjectListToJsonArray<TPerfilUsuarioDto>(Lista,True))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

end.
