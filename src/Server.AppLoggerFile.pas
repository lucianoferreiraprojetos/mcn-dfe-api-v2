unit Server.AppLoggerFile;

interface

uses
  Server.AppLoggerTypes, System.SysUtils, System.Classes, Server.AppConfig;

type

  TAppLoggerFile = class(TInterfacedObject, ILogger)
  private
    function PegarNomeArquivoComPath(): String;
    procedure SendWriteLog(Level: TAppLoggerTypeLevel; Msg: String; AClazz: TClass);
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
  Server.AppLoggerUtils, System.DateUtils;

var
  SemafaroMultiReadExclusiveWriteSynchronizer: TMultiReadExclusiveWriteSynchronizer;

{ TAppLoggerFile }

function TAppLoggerFile.PegarNomeArquivoComPath: String;
var
  PathLogs: String;
begin
  if (AppConfig.GetLogFileParams.PathLogs.IsEmpty) then
    PathLogs := ExtractFilePath(ParamStr(0))
  else
    PathLogs := AppConfig.GetLogFileParams.PathLogs;

  if (not DirectoryExists(PathLogs)) then
    ForceDirectories(PathLogs);

  Result := IncludeTrailingPathDelimiter(PathLogs) + 'log' + FormatDateTime('yyyyMMdd',Now()) + '.txt';
end;

procedure TAppLoggerFile.Send(Level: TAppLoggerTypeLevel; Msg: String;
  AClazz: TClass);
// Ref: https://devspace.tuttoilmondo.com.br/desenvolvimento/log-em-aplicacoes-delphi/
begin
  SemafaroMultiReadExclusiveWriteSynchronizer.BeginWrite;
  SendWriteLog(Level,Msg,AClazz);
  SemafaroMultiReadExclusiveWriteSynchronizer.EndWrite;
end;

procedure TAppLoggerFile.SendDebug(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelDebug,Msg,AClazz);
end;

procedure TAppLoggerFile.SendError(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelError,Msg,AClazz);
end;

procedure TAppLoggerFile.SendFatal(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelFatal,Msg,AClazz);
end;

procedure TAppLoggerFile.SendInfo(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelInfo,Msg,AClazz);
end;

procedure TAppLoggerFile.SendTrace(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelTrace,Msg,AClazz);
end;

procedure TAppLoggerFile.SendWarn(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelWarn,Msg,AClazz);
end;

procedure TAppLoggerFile.SendWriteLog(Level: TAppLoggerTypeLevel; Msg: String;
  AClazz: TClass);
const
  TmplLogValue = '%s - [%s] - %s - %s';
var
  ClassName: String;
  LevelSiglaFmt: String;
  FileLog: TextFile;
  FileFullName: String;
begin

  FileFullName := PegarNomeArquivoComPath();

  if (Assigned(AClazz)) then
    ClassName := AClazz.ClassName
  else
    ClassName := 'TApplication';

  LevelSiglaFmt := GetAppLoggerTypeLevelSigla(Level).ToUpper.PadRight(5,' ');

  AssignFile(FileLog, FileFullName);

  if FileExists(FileFullName) then
    Append(FileLog)
  else
    Rewrite(FileLog);

  WriteLn(FileLog,Format(TmplLogValue,[DateTimeToStr(Now()),LevelSiglaFmt,Msg,ClassName]));

  CloseFile(FileLog);

end;

initialization
  SemafaroMultiReadExclusiveWriteSynchronizer := TMultiReadExclusiveWriteSynchronizer.Create;

finalization
  FreeAndNil(SemafaroMultiReadExclusiveWriteSynchronizer);

end.
