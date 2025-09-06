unit Server.Exceptions;

interface

uses
  System.Classes, System.SysUtils, Horse;

type

  ERecursoNaoEncontradoException = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

  EErroInternoDoServidorException = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

  EEntidadeJaExisteException = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

  ERegraDeNegocioException = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

  EValidacaoCampoException = class(Exception)
  public
    constructor Create(const Msg: string);
  end;


implementation

uses
  Server.AppLogger;

{ ERecursoNaoEncontradoException }

constructor ERecursoNaoEncontradoException.Create(const Msg: string);
begin
  LogInfo(Msg,Self.ClassType);
  raise EHorseException.New.Error(Msg).Status(THTTPStatus.NotFound);
end;

{ EEntidadeJaExisteException }

constructor EEntidadeJaExisteException.Create(const Msg: string);
begin
  LogInfo(Msg,Self.ClassType);
  raise EHorseException.New.Error(Msg).Status(THTTPStatus.BadRequest);
end;

{ EValidacaoCampoException }

constructor EValidacaoCampoException.Create(const Msg: string);
begin
  LogInfo(Msg,Self.ClassType);
  raise EHorseException.New.Error(Msg).Status(THTTPStatus.BadRequest);
end;

{ ERegraDeNegocioException }

constructor ERegraDeNegocioException.Create(const Msg: string);
begin
  LogInfo(Msg,Self.ClassType);
  raise EHorseException.New.Error(Msg).Status(THTTPStatus.BadRequest);
end;

{ EErroInternoDoServidorException }

constructor EErroInternoDoServidorException.Create(const Msg: string);
begin
  LogError(Msg,Self.ClassType);
  raise EHorseException.New.Error(Msg).Status(THTTPStatus.InternalServerError);
end;

end.
