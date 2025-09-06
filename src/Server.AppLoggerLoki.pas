unit Server.AppLoggerLoki;

interface

uses
  Server.AppLoggerTypes, Server.AppConfig,
  System.Classes, System.Threading;

type

  TAppLoggerLoki = class(TInterfacedObject,ILogger)
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
  Server.AppLoggerUtils,
  RESTRequest4D, System.JSON, System.DateUtils, System.SysUtils, System.StrUtils;

type

  TLokiStream = class
  private
    class var FLevel: TAppLoggerTypeLevel;
    class var FMsg: String;
    class var FClazz: TClass;
    class function GetClassTypeName(AClazz: TClass): String;
    class function MontarMensagem(): String;
  public
    class function GerarJson(Level: TAppLoggerTypeLevel;
      Msg: String; AClazz: TClass): TJSONObject;
  end;

  TLokiStreamsAggregator = class
  public
    class function GerarToStr(Level: TAppLoggerTypeLevel;
      Msg: String; AClazz: TClass): String;
  end;

{ TAppLoggerLoki }

procedure TAppLoggerLoki.Send(Level: TAppLoggerTypeLevel; Msg: String;
  AClazz: TClass);
begin
  if AppConfig.GetLogGrafanaLokiParams.UrlBase.IsEmpty then
    Exit;

  TThread.CreateAnonymousThread(
     procedure begin
       try
        TRequest.New
          .BaseURL(AppConfig.GetLogGrafanaLokiParams.UrlBase)
          .Resource('/loki/api/v1/push')
          .BasicAuthentication(AppConfig.GetLogGrafanaLokiParams.User,AppConfig.GetLogGrafanaLokiParams.Pass)
          .AcceptCharset('utf-8, *;q=0.8')
          .Accept('application/json, text/plain; q=0.9, text/html;q=0.8,')
          .AddBody(TLokiStreamsAggregator.GerarToStr(Level,Msg,AClazz))
          .ContentType('application/json')
          .Post;
       except on E: Exception do
         WriteLn('Erro ao enviar log para o Loki:' + E.Message);
       end;
      end).start();

      // ESSE CODIGO VAI SERVIR COMO EXEMPLO PARA EU MONTAR UM POOL DE CONEXOES

//  TThread.CreateAnonymousThread(
//  procedure
//  begin
//      TThread.Sleep(1000);
//      TThread.Synchronize(TThread.CurrentThread,
//      procedure
//      begin
//        //Sleep(1000 * 10);
//        writeln('enviado');
//        TRequest.New
//          .BaseURL(AppConfig.LogGrafanaLokiUrlBase)
//          .Resource('/loki/api/v1/push')
//          .BasicAuthentication(AppConfig.LogGrafanaLokiUser,AppConfig.LogGrafanaLokiPass)
//          .AcceptCharset('utf-8, *;q=0.8')
//          .Accept('application/json, text/plain; q=0.9, text/html;q=0.8,')
//          .AddBody(TLokiStreamsAggregator.GerarToStr(Level,Msg,AClazz))
//          .ContentType('application/json')
//          .Post;
//      end);
//  end).Start;
end;

procedure TAppLoggerLoki.SendDebug(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelDebug,Msg,AClazz);
end;

procedure TAppLoggerLoki.SendError(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelError,Msg,AClazz);
end;

procedure TAppLoggerLoki.SendFatal(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelFatal,Msg,AClazz);
end;

procedure TAppLoggerLoki.SendInfo(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelInfo,Msg,AClazz);
end;

procedure TAppLoggerLoki.SendTrace(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelTrace,Msg,AClazz);
end;

procedure TAppLoggerLoki.SendWarn(Msg: String; AClazz: TClass);
begin
  Send(TAppLoggerTypeLevel.alLevelWarn,Msg,AClazz);
end;

{ TLokiStream }

class function TLokiStream.GerarJson(Level: TAppLoggerTypeLevel; Msg: String;
  AClazz: TClass): TJSONObject;
  function GerarHeader(): TJSONObject;
  begin
    Result := TJSONObject.Create;
    Result.AddPair('sistema','mcn-dfe-api');
    Result.AddPair('ambiente',AppConfig.GetAppParams.Environment);
    Result.AddPair('tipoMsg','info');
    Result.AddPair('classType',GetClassTypeName(AClazz));
  end;
  function GerarValue(): TJSONArray;
  begin
    Result := TJSONArray.Create;
    Result.Add(TAppLoggerUtils.GerarUnixEpochStr());
    Result.Add(MontarMensagem());
  end;
  function GerarMultipleValues(): TJSONArray;
  begin
    Result := TJSONArray.Create;
    Result.Add(GerarValue());
  end;
  function GerarStreamAndMultipleValues(): TJSONObject;
  begin
    Result := TJSONObject.Create;
    Result.AddPair('stream',GerarHeader);
    Result.AddPair('values',GerarMultipleValues);
  end;
begin
  FLevel := Level;
  FMsg := Msg;
  FClazz := AClazz;
  Result := GerarStreamAndMultipleValues();
end;

class function TLokiStream.GetClassTypeName(AClazz: TClass): String;
begin
  if Assigned(AClazz) then
    Result := AClazz.ClassName
  else
    Result := 'program';
end;

class function TLokiStream.MontarMensagem: String;
const
  TmplLogValue = '[%s] - %s - ClassType=%s';
var
  MsgLevelSiglaFmt: String;
  MsgClassName: String;
begin
  MsgLevelSiglaFmt := GetAppLoggerTypeLevelSigla(FLevel).ToUpper.PadRight(5,' ');
  MsgClassName := GetClassTypeName(FClazz);
  Result := Format(TmplLogValue,[MsgLevelSiglaFmt,FMsg,MsgClassName]);
end;

{ TLokiStreamsAggregator }

class function TLokiStreamsAggregator.GerarToStr(Level: TAppLoggerTypeLevel;
  Msg: String; AClazz: TClass): String;
var
  Jo: TJSONObject;
  function GerarValues: TJSONArray;
  begin
    Result := TJSONArray.Create;
    Result.AddElement(TLokiStream.GerarJson(Level,Msg,AClazz));
  end;
begin
  Jo := TJSONObject.Create;
  try
    Jo.AddPair('streams',GerarValues);
    Result := Jo.ToString;
  finally
    FreeAndNil(Jo);
  end
end;

end.
