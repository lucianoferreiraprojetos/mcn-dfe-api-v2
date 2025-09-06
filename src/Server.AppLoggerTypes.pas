unit Server.AppLoggerTypes;

interface

type

   // All < Trace < Debug < Info < Warn < Error < Fatal < Console (pega o mesmo do console) < file (pega o mesmo do file) < Off (desliga)


  TAppLoggerTypeLevel = (alLevelAll = 0,
                         alLevelTrace = 1,
                         alLevelDebug = 2,
                         alLevelInfo = 3,
                         alLevelWarn = 4,
                         alLevelError = 5,
                         alLevelFatal = 6,
                         alLevelConsole = 7,
                         alLevelFile = 8,
                         alLevelOff = 9);

  ILogger = interface
    ['{99F10E47-F8B5-4AB1-8C5C-AE475194DABA}']
    procedure SendInfo(Msg: String; AClazz: TClass);
    procedure SendError(Msg: String; AClazz: TClass);
    procedure SendDebug(Msg: String; AClazz: TClass);
    procedure SendWarn(Msg: String; AClazz: TClass);
    procedure SendTrace(Msg: String; AClazz: TClass);
    procedure SendFatal(Msg: String; AClazz: TClass);
  end;

  function GetAppLoggerTypeLevelSigla(Level: TAppLoggerTypeLevel): String;

implementation

function GetAppLoggerTypeLevelSigla(Level: TAppLoggerTypeLevel): String;
begin
  case Level of
    TAppLoggerTypeLevel.alLevelAll:
      Result := 'All';
    TAppLoggerTypeLevel.alLevelTrace:
      Result := 'Trace';
    TAppLoggerTypeLevel.alLevelDebug:
      Result := 'Debug';
    TAppLoggerTypeLevel.alLevelInfo:
      Result := 'Info';
    TAppLoggerTypeLevel.alLevelWarn:
      Result := 'Warn';
    TAppLoggerTypeLevel.alLevelError:
      Result := 'Error';
    TAppLoggerTypeLevel.alLevelFatal:
      Result := 'Fatal';
    TAppLoggerTypeLevel.alLevelConsole:
      Result := 'Console';
    TAppLoggerTypeLevel.alLevelFile:
      Result := 'File';
    else
      Result := 'Off';
  end;
end;


end.
