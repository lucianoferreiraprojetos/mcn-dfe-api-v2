unit Server.FilaConsultaDfeConsumerService;

interface

uses
  System.Generics.Collections, System.Classes, Server.Data.Dtos,
  Server.Data.Filters, Server.AppLogger,  Server.FilaConsultaDfeService,
  Server.ConsultaDfeService;

type

  TFilaConsultaDfeConsumerService = class(TThread)
  private
    procedure ProcessarConsultaPorEmpresa(const IdEmpresa: Int64);
    procedure RecuperarEProcessarLista;
  public
    constructor Create;
    procedure Execute; override;
  public
    class procedure Starter;
  end;

implementation

uses
  System.SysUtils;

var
  FilaConsultaDfeConsumerService: TFilaConsultaDfeConsumerService;

{ TFilaConsultaDfeConsumerService }

constructor TFilaConsultaDfeConsumerService.Create;
begin
  inherited Create(True);
end;

procedure TFilaConsultaDfeConsumerService.Execute;
const
  TEMPO_DE_UM_MINUTO = 1000 * 60;
begin
  inherited;
  LogInfo('Consumer consulta dfe service started',Self.ClassType);
  while True do
  begin
    RecuperarEProcessarLista;
    Sleep(TEMPO_DE_UM_MINUTO);
  end;
end;

procedure TFilaConsultaDfeConsumerService.RecuperarEProcessarLista;
const
  TEMPO_DE_UM_SEGUNDO = 1000;
begin
  var Lista := TFilaConsultaDfeService.GetList;
  try
    for var IdEmpresa in Lista do
    begin
      ProcessarConsultaPorEmpresa(IdEmpresa);
      Sleep(TEMPO_DE_UM_SEGUNDO);
    end;
  finally
    FreeAndNil(Lista);
  end;
end;

procedure TFilaConsultaDfeConsumerService.ProcessarConsultaPorEmpresa(const IdEmpresa: Int64);
var
  Service: TConsultaDfeService;
begin
  Service := TConsultaDfeService.Create;
  try
    Service.ConsultarDistribuicaoDfe(IdEmpresa);
  finally
    FreeAndNil(Service);
  end;
end;

class procedure TFilaConsultaDfeConsumerService.Starter;
begin
  FilaConsultaDfeConsumerService.Start;
end;

initialization
  FilaConsultaDfeConsumerService := TFilaConsultaDfeConsumerService.Create;

finalization
  FreeAndNil(FilaConsultaDfeConsumerService);

end.
