unit Server.SwaggerConfig;

interface

uses
  System.Classes, Horse, Horse.JWT, Horse.GBSwagger;

type
  TSwaggerConfig = class
  public
    class procedure Configurar(const App: THorse);
  end;

implementation

uses
  Server.Autorizacao.Service;

{ TSwaggerConfig }

class procedure TSwaggerConfig.Configurar(const App: THorse);
var
  VersaoApp: String;
begin
  VersaoApp := '1.026';
  App.Use(HorseSwagger('/api/doc'));
  Swagger
    .Info
      .Title('MCN DF-e Server API')
      .Description('API de monitoramento de distribuição de documentos fiscais - MCN Software')
      .Version(VersaoApp)
      .Contact
        .Name('Telefone - (65) 3054-4339')
        .Email('Email: suporte@mcnsistemas.com.br')
        .URL('http://www.mcnsistemas.com.br')
      .&End
  .&End
  .AddBearerSecurity
  .AddCallback(HorseJWT(SECRET_KEY));
end;

end.
