unit Server.Autenticacao.Controller;

interface

uses
  System.Classes, System.SysUtils,
  Horse, Horse.GBSwagger, GBSwagger.Path.Attributes,
  Server.Data.Dtos;

type
  [SwagPath('api/autenticacao','1. Autenticação')]
  TAutenticacaoController = class(THorseGBSwagger)
  public
    [SwagPOST('/autenticar','Autenticar',True)]
    [SwagParamFormData('login','Login do usuário',false)]
    [SwagParamFormData('senha','Senha do usuário',False)]
    [SwagResponse(200,TTokenAutenticacaoDto)]
    [SwagResponse(400)]
    [SwagResponse(500)]
    [SwagProduces(TGBSwaggerContentType.gbAppJSON)]
    [SwagConsumes(TGBSwaggerContentType.gbMultiPartFormData)]
    procedure Autenticar;
  end;

implementation

uses
  Server.Data.JsonConverter, Server.Autenticacao.Service;

{ TAutenticacaoController }

procedure TAutenticacaoController.Autenticar;
var
  Service: TAutenticacaoService;
  Login, Senha: String;
  Dto: TTokenAutenticacaoDto;
begin
  Login := FRequest.ContentFields['login'];
  Senha := FRequest.ContentFields['senha'];
  Service := TAutenticacaoService.Create;
  try
    Dto := Service.Autenticar(Login,Senha);
    FResponse
      .Send(TJsonConverter.ObjectToJsonObject(Dto))
      .Status(THTTPStatus.OK);
  finally
    FreeAndNil(Service);
  end;
end;

end.
