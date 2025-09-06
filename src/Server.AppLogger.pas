unit Server.AppLogger;

interface

uses
  Server.AppLoggerTypes, Server.AppLoggerConsole, Server.AppLoggerLoki,
  Server.AppLoggerFile;

type

  TAppLogger = class(TInterfacedObject, ILogger)
  private
    FAppLoggerConsole: TAppLoggerConsole;
    FAppLoggerFile: TAppLoggerFile;
    FAppLoggerLoki: TAppLoggerLoki;
    procedure Send(Level: TAppLoggerTypeLevel; Msg: String; AClazz: TClass);
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure SendInfo(Msg: String; AClazz: TClass);
    procedure SendError(Msg: String; AClazz: TClass);
    procedure SendDebug(Msg: String; AClazz: TClass);
    procedure SendWarn(Msg: String; AClazz: TClass);
    procedure SendTrace(Msg: String; AClazz: TClass);
    procedure SendFatal(Msg: String; AClazz: TClass);
  end;

procedure LogInfo(Msg: String; AClazz: TClass);
procedure LogError(Msg: String; AClazz: TClass);
procedure LogDebug(Msg: String; AClazz: TClass);
procedure LogWarn(Msg: String; AClazz: TClass);
procedure LogTrace(Msg: String; AClazz: TClass);
procedure LogFatal(Msg: String; AClazz: TClass);

var
  AppLogger: TAppLogger;

implementation

uses
  System.SysUtils;

{ TAppLogger }

constructor TAppLogger.Create;
begin
  FAppLoggerConsole := TAppLoggerConsole.Create;
  FAppLoggerFile := TAppLoggerFile.Create;
  FAppLoggerLoki := TAppLoggerLoki.Create;
end;

destructor TAppLogger.Destroy;
begin
  FreeAndNil(FAppLoggerConsole);
  FreeAndNil(FAppLoggerFile);
  FreeAndNil(FAppLoggerLoki);
  inherited;
end;

procedure TAppLogger.Send(Level: TAppLoggerTypeLevel; Msg: String; AClazz: TClass);
begin
  try
    FAppLoggerConsole.Send(Level,Msg,AClazz);
    FAppLoggerFile.Send(Level,Msg,AClazz);
    FAppLoggerLoki.Send(Level,Msg,AClazz);
  except
    on E: Exception do
    begin
      WriteLn('Erro ao enviar dados para o log: ' + E.Message);
    end;
  end;
end;

procedure TAppLogger.SendDebug(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelDebug,Msg,AClazz);
end;

procedure TAppLogger.SendError(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelError,Msg,AClazz);
end;

procedure TAppLogger.SendFatal(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelFatal,Msg,AClazz);
end;

procedure TAppLogger.SendInfo(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelInfo,Msg,AClazz);
end;

procedure TAppLogger.SendTrace(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelTrace,Msg,AClazz);
end;

procedure TAppLogger.SendWarn(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelWarn,Msg,AClazz);
end;

{ Helpers }

procedure LogInfo(Msg: String; AClazz: TClass);
begin
  AppLogger.SendInfo(Msg,AClazz);
end;

procedure LogError(Msg: String; AClazz: TClass);
begin
  AppLogger.SendError(Msg,AClazz);
end;

procedure LogDebug(Msg: String; AClazz: TClass);
begin
  AppLogger.SendDebug(Msg,AClazz);
end;

procedure LogWarn(Msg: String; AClazz: TClass);
begin
  AppLogger.SendWarn(Msg,AClazz);
end;

procedure LogTrace(Msg: String; AClazz: TClass);
begin
  AppLogger.SendTrace(Msg,AClazz);
end;

procedure LogFatal(Msg: String; AClazz: TClass);
begin
  AppLogger.SendFatal(Msg,AClazz);
end;


initialization
  AppLogger := TAppLogger.Create;

finalization
  FreeAndNil(AppLogger);

end.
