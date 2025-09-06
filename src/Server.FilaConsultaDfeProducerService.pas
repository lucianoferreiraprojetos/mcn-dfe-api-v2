unit Server.FilaConsultaDfeProducerService;

interface

uses
  System.Classes, System.SysUtils, Server.AppLogger, Server.EmpresaService,
  Server.Data.Filters, Server.FilaConsultaDfeService;

type

  TFilaConsultaDfeProducerService = class(TThread)
  private
    procedure CarregarAdicionarEmpresasNaFila;
  public
    constructor Create;
    procedure Execute; override;
  public
    class procedure Starter;
  end;

implementation

var
  FilaConsultaDfeProducerService: TFilaConsultaDfeProducerService;

{ TFilaConsultaDfeProducerService }

procedure TFilaConsultaDfeProducerService.CarregarAdicionarEmpresasNaFila;
var
  EmpresaService: TEmpresaService;
begin
  EmpresaService := TEmpresaService.Create;
  try
    var Filtro: TEmpresaFiltro;
    Filtro.Situacao := TEnumSituacao.eSitAtivo;
    var Empresas := EmpresaService.BuscarLista(Filtro);
    try
      for var Emp in Empresas do
        TFilaConsultaDfeService.Adicionar(Emp.Id);
    finally
      FreeAndNil(Empresas);
    end;
  finally
    FreeAndNil(EmpresaService);
  end;
end;

constructor TFilaConsultaDfeProducerService.Create;
begin
  inherited Create(True);
end;

procedure TFilaConsultaDfeProducerService.Execute;
const
  TEMPO_DE_UM_MINUTO = 1000 * 60;
  TEMPO_DE_UMA_HORA = TEMPO_DE_UM_MINUTO * 60;
begin
  inherited;
  LogInfo('Producer consulta dfe service started',Self.ClassType);
  while True do
  begin
    CarregarAdicionarEmpresasNaFila();
    Sleep(TEMPO_DE_UM_MINUTO);
  end;
end;

class procedure TFilaConsultaDfeProducerService.Starter;
begin
  FilaConsultaDfeProducerService.Start;
end;

initialization
  FilaConsultaDfeProducerService := TFilaConsultaDfeProducerService.Create;

finalization
  FreeAndNil(FilaConsultaDfeProducerService);

end.
