unit Server.RotinasAgendadasService;

interface

type

  TRotinasAgendadasService = class
  public
    class procedure IniciarRotinas;
  end;

implementation

uses
  System.SysUtils,
  Server.FilaConsultaDfeProducerService,
  Server.FilaConsultaDfeConsumerService;

{ TRotinasAgendadasService }

class procedure TRotinasAgendadasService.IniciarRotinas;
const
  TEMPO_DE_TRES_SEGUNDOS = 1000 * 3;
begin
  TFilaConsultaDfeProducerService.Starter;
  Sleep(TEMPO_DE_TRES_SEGUNDOS);
  TFilaConsultaDfeConsumerService.Starter;
end;

end.
