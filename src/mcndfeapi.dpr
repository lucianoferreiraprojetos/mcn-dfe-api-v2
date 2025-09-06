program mcndfeapi;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.OctetStream,
  Horse.CORS,
  Horse.GBSwagger,
  Horse.JWT,
  Horse.HandleException,
  Server.Data.Models in 'Server.Data.Models.pas',
  Server.PerfilUsuarioService in 'Server.PerfilUsuarioService.pas',
  Server.PerfilUsuarioController in 'Server.PerfilUsuarioController.pas',
  Server.DbMigrationUtils in 'Server.DbMigrationUtils.pas',
  Server.AppLogger in 'Server.AppLogger.pas',
  Server.AppLoggerTypes in 'Server.AppLoggerTypes.pas',
  Server.AbstractService in 'Server.AbstractService.pas',
  Server.SwaggerConfig in 'Server.SwaggerConfig.pas',
  Server.AppLoggerLoki in 'Server.AppLoggerLoki.pas',
  Server.AppLoggerConsole in 'Server.AppLoggerConsole.pas',
  Server.AppLoggerUtils in 'Server.AppLoggerUtils.pas',
  Server.AppLoggerFile in 'Server.AppLoggerFile.pas',
  Server.AppSysUtils in 'Server.AppSysUtils.pas',
  Server.Data.JsonConverter in 'Server.Data.JsonConverter.pas',
  Server.Exceptions in 'Server.Exceptions.pas',
  Server.UsuarioService in 'Server.UsuarioService.pas',
  Server.UsuarioController in 'Server.UsuarioController.pas',
  Server.EmpresaDao in 'Server.EmpresaDao.pas',
  Server.EmpresaService in 'Server.EmpresaService.pas',
  Server.EmpresaController in 'Server.EmpresaController.pas',
  Server.ConsultaDfeDao in 'Server.ConsultaDfeDao.pas',
  Server.DocumentoDfeDao in 'Server.DocumentoDfeDao.pas',
  Server.NotaEntradaNfeDao in 'Server.NotaEntradaNfeDao.pas',
  Server.ManifestoDao in 'Server.ManifestoDao.pas',
  Server.ConsultaDfeService in 'Server.ConsultaDfeService.pas',
  Server.DocumentoDfeService in 'Server.DocumentoDfeService.pas',
  Server.NotaEntradaNfeService in 'Server.NotaEntradaNfeService.pas',
  Server.ManifestoService in 'Server.ManifestoService.pas',
  Server.FilaConsultaDfeConsumerService in 'Server.FilaConsultaDfeConsumerService.pas',
  Server.FilaConsultaDfeProducerService in 'Server.FilaConsultaDfeProducerService.pas',
  Server.DbMigrationService in 'Server.DbMigrationService.pas',
  Server.Data.Dtos in 'Server.Data.Dtos.pas',
  Server.PerfilUsuarioDao in 'Server.PerfilUsuarioDao.pas',
  Server.UsuarioDao in 'Server.UsuarioDao.pas',
  Server.AbstractDao in 'Server.AbstractDao.pas',
  Server.DataAccess.DbParams in 'Server.DataAccess.DbParams.pas',
  Server.DataAccess.DbConnection in 'Server.DataAccess.DbConnection.pas',
  Server.DataAccess.UpdateSQL in 'Server.DataAccess.UpdateSQL.pas',
  Server.DataAccess.RttiUtil in 'Server.DataAccess.RttiUtil.pas',
  Server.DataAccess.AttributeMappings in 'Server.DataAccess.AttributeMappings.pas',
  Server.DataAccess.CustomQuerySQL in 'Server.DataAccess.CustomQuerySQL.pas',
  Server.DataAccess.NativeQuery in 'Server.DataAccess.NativeQuery.pas',
  Server.DataAccess.QuerySQL in 'Server.DataAccess.QuerySQL.pas',
  Server.Data.ValuesObjectsVO in 'Server.Data.ValuesObjectsVO.pas',
  Server.DataAccess.ObjectMapper in 'Server.DataAccess.ObjectMapper.pas',
  Server.DataAccess.ObjectValidation in 'Server.DataAccess.ObjectValidation.pas',
  Server.DataAccess.DeleteSQL in 'Server.DataAccess.DeleteSQL.pas',
  Server.Data.Filters in 'Server.Data.Filters.pas',
  Server.DataAccess.SqlBuilder in 'Server.DataAccess.SqlBuilder.pas',
  Server.DataAccess.CriteriaQuery in 'Server.DataAccess.CriteriaQuery.pas',
  Server.StrUtils in 'Server.StrUtils.pas',
  Server.RespConsultaDfeService in 'Server.RespConsultaDfeService.pas',
  Server.RotinasAgendadasService in 'Server.RotinasAgendadasService.pas',
  Server.Autenticacao.Controller in 'Server.Autenticacao.Controller.pas',
  Server.Autenticacao.Service in 'Server.Autenticacao.Service.pas',
  Server.Autorizacao.Service in 'Server.Autorizacao.Service.pas',
  Server.FilaConsultaDfeService in 'Server.FilaConsultaDfeService.pas',
  Server.AppConfig in 'Server.AppConfig.pas';

var
  App: THorse;

procedure RegistrarControllers();
begin
  THorseGBSwaggerRegister.RegisterPath(TAutenticacaoController);
  THorseGBSwaggerRegister.RegisterPath(TPerfilUsuarioController);
  THorseGBSwaggerRegister.RegisterPath(TUsuarioController);
  THorseGBSwaggerRegister.RegisterPath(TEmpresaController);
end;

procedure ConfigurarCORS();
begin
  HorseCORS
    .AllowedOrigin('*')
    .AllowedCredentials(true)
    .AllowedHeaders('*')
    .AllowedMethods('*')
    .ExposedHeaders('*');
end;

procedure RegistrarUsesHorse();
begin
  App.Use(CORS);
  App.Use(Jhonson);
  App.Use(OctetStream);
  App.Use(HandleException);
end;

begin

  //TDbMigrationUtils.GerarScriptDllCreate('teste.sql');

  //TDbMigrationService.ApplyUpdate();

  TRotinasAgendadasService.IniciarRotinas();

  ConfigurarCORS();

  App := THorse.Create();

  RegistrarUsesHorse();

  TSwaggerConfig.Configurar(App);

  RegistrarControllers();

  App.Listen(AppConfig.GetAppParams.Port,
    procedure()
    begin
      LogInfo('Servidor em execução na porta: ' + AppConfig.GetAppParams.Port.ToString,nil);
    end,
    procedure()
    begin
      LogInfo('Servidor finalizado',nil);
    end);

end.
