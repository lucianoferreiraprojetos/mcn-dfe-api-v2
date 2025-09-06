unit Server.AppLoggerConsole;

interface

uses
  Server.AppLoggerTypes;

type

  TAppLoggerConsole = class(TInterfacedObject, ILogger)
  public
    procedure Send(Level: TAppLoggerTypeLevel; Msg: String; AClazz: TClass);
    procedure SendInfo(Msg: String; AClazz: TClass);
    procedure SendError(Msg: String; AClazz: TClass);
    procedure SendDebug(Msg: String; AClazz: TClass);
    procedure SendWarn(Msg: String; AClazz: TClass);
    procedure SendTrace(Msg: String; AClazz: TClass);
    procedure SendFatal(Msg: String; AClazz: TClass);
  end;

implementation

uses
  Server.AppLoggerUtils, System.DateUtils, System.SysUtils, System.StrUtils;

{ TAppLoggerConsole }

procedure TAppLoggerConsole.Send(Level: TAppLoggerTypeLevel; Msg: String;
  AClazz: TClass);
const
  TmplLogValue = '%s - [%s] - %s - %s';
var
  ClassName: String;
  LevelSiglaFmt: String;
begin

  if (Assigned(AClazz)) then
    ClassName := AClazz.ClassName
  else
    ClassName := 'TApplication';

  LevelSiglaFmt := GetAppLoggerTypeLevelSigla(Level).ToUpper.PadRight(5,' ');

  WriteLn(Format(TmplLogValue,[DateTimeToStr(Now()),LevelSiglaFmt,Msg,ClassName]));
end;

procedure TAppLoggerConsole.SendDebug(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelDebug,Msg,AClazz);
end;

procedure TAppLoggerConsole.SendError(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelError,Msg,AClazz);
end;

procedure TAppLoggerConsole.SendFatal(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelFatal,Msg,AClazz);
end;

procedure TAppLoggerConsole.SendInfo(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelInfo,Msg,AClazz);
end;

procedure TAppLoggerConsole.SendTrace(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelTrace,Msg,AClazz);
end;

procedure TAppLoggerConsole.SendWarn(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelWarn,Msg,AClazz);
end;

end.
