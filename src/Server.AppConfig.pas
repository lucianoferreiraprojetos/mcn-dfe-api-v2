unit Server.AppConfig;

interface

uses
  Server.DataAccess.DbParams, System.IniFiles;

type

  TAppParams = record
    Port: Integer;
    Environment: String;
  end;

  TNfeParams = record
    PathSchemas: String;
    PathDownloadXml: String;
  end;

  TLogGrafanaLokiParams = record
    UrlBase: String;
    User: String;
    Pass: String;
    LevelMsg: String;
  end;

  TLogConsoleParams = record
    LevelMsg: String;
  end;

  TLogFileParams = record
    LevelMsg: String;
    PathLogs: String;
  end;

  TAppConfig = class
  private
    FDbParams: TDbParams;
    FAppParams: TAppParams;
    FNfeParams: TNfeParams;
    FLogGrafanaLokiParams: TLogGrafanaLokiParams;
    FLogConsoleParams: TLogConsoleParams;
    FLogFileParams: TLogFileParams;
    procedure LoadParams();
    procedure LoadAppParams(AIniFile: TIniFile);
    procedure LoadDbParams(AIniFile: TIniFile);
    procedure LoadNfeParams(AIniFile: TIniFile);
    procedure LoadLogGrafanaLokiParams(AIniFile: TIniFile);
    procedure LoadLogConsoleParams(AIniFile: TIniFile);
    procedure LoadLogFileParams(AIniFile: TIniFile);
    function GetEnvMcnDfeApiSufix(Sufix: String): String; overload;
    function GetEnvMcnDfeApiSufix(SectionName, Sufix: String): String; overload;
    function GetEnvMcnDfeApiSufixOrIniString(SectionName, Sufix: String; IniFile: TIniFile): String;
    function GetEnvMcnDfeApiSufixOrIniInteger(SectionName, Sufix: String; IniFile: TIniFile): Integer;
    procedure CreateIni(PathFile: String);
  public
    constructor Create;
    destructor Destroy;
  public
    function GetAppParams: TAppParams;
    function GetDbParams: TDbParams;
    function GetNfeParams: TNfeParams;
    function GetLogGrafanaLokiParams: TLogGrafanaLokiParams;
    function GetLogConsoleParams: TLogConsoleParams;
    function GetLogFileParams: TLogFileParams;
  end;

var
  AppConfig: TAppConfig;

implementation

uses
  System.SysUtils;

const
  MCN_DFE_API_INI = 'mcndfeapi.ini';

{ TAppConfig }

constructor TAppConfig.Create;
begin
  FDbParams := TDbParams.Create;
  LoadParams();
end;

procedure TAppConfig.CreateIni(PathFile: String);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(IncludeTrailingPathDelimiter(PathFile) + MCN_DFE_API_INI);
  try
    IniFile.WriteInteger('APP','PORT',0);
    IniFile.WriteString('APP','ENVIRONMENT','');

    IniFile.WriteString('DB','HOST','');
    IniFile.WriteInteger('DB','PORT',0);
    IniFile.WriteString('DB','USER','');
    IniFile.WriteString('DB','PASS','');
    IniFile.WriteString('DB','NAME','');

    IniFile.WriteString('LOG_FILE','PATH_LOGS','');
    IniFile.WriteString('LOG_FILE','LEVEL_MSG','');

    IniFile.WriteString('LOG_CONSOLE','LEVEL_MSG','');

    IniFile.WriteString('GRAFANA_LOKI','LEVEL_MSG','');
    IniFile.WriteString('GRAFANA_LOKI','URLBASE','');
    IniFile.WriteString('GRAFANA_LOKI','USER','');
    IniFile.WriteString('GRAFANA_LOKI','PASS','');

    IniFile.WriteString('NFE','PATH_SCHEMAS','');
    IniFile.WriteString('NFE','PATH_DOWNLOAD_XML','');

  finally
    IniFile.Free;
  end;
end;

destructor TAppConfig.Destroy;
begin
  FreeAndNil(FDbParams);
end;

function TAppConfig.GetAppParams: TAppParams;
begin
  Result := FAppParams;
end;

function TAppConfig.GetDbParams: TDbParams;
begin
  Result := FDbParams;
end;

function TAppConfig.GetEnvMcnDfeApiSufix(Sufix: String): String;
begin
  Result := Trim(GetEnvironmentVariable('MCN_DFE_API_' + Sufix.ToUpper));
end;

function TAppConfig.GetEnvMcnDfeApiSufix(SectionName, Sufix: String): String;
begin
  Result := GetEnvMcnDfeApiSufix(SectionName + '_' + Sufix.ToUpper);
end;

function TAppConfig.GetEnvMcnDfeApiSufixOrIniInteger(SectionName, Sufix: String;
  IniFile: TIniFile): Integer;
begin
  if GetEnvMcnDfeApiSufix(SectionName, Sufix.ToUpper) <> '' then
    Result := StrToInt(GetEnvMcnDfeApiSufix(SectionName, Sufix.ToUpper))
  else
    Result := IniFile.ReadInteger(SectionName, Sufix.ToUpper, 0);
end;

function TAppConfig.GetEnvMcnDfeApiSufixOrIniString(SectionName, Sufix: String;
  IniFile: TIniFile): String;
begin
  if GetEnvMcnDfeApiSufix(SectionName, Sufix.ToUpper) <> '' then
    Result := GetEnvMcnDfeApiSufix(SectionName, Sufix.ToUpper)
  else
    Result := IniFile.ReadString(SectionName, Sufix.ToUpper, '');
end;

function TAppConfig.GetLogConsoleParams: TLogConsoleParams;
begin
  Result := FLogConsoleParams;
end;

function TAppConfig.GetLogFileParams: TLogFileParams;
begin
  Result := FLogFileParams;
end;

function TAppConfig.GetLogGrafanaLokiParams: TLogGrafanaLokiParams;
begin
  Result := FLogGrafanaLokiParams;
end;

function TAppConfig.GetNfeParams: TNfeParams;
begin
  Result := FNfeParams;
end;

procedure TAppConfig.LoadAppParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'APP';
begin
  FAppParams.Port := GetEnvMcnDfeApiSufixOrIniInteger(SECTION_NAME, 'PORT', AIniFile);
  FAppParams.Environment := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'ENVIRONMENT', AIniFile);
end;

procedure TAppConfig.LoadDbParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'DB';
begin
  FDbParams.Host := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'HOST', AIniFile);
  FDbParams.Port := GetEnvMcnDfeApiSufixOrIniInteger(SECTION_NAME, 'PORT', AIniFile);
  FDbParams.User := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'USER', AIniFile);
  FDbParams.Pass := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'PASS', AIniFile);
  FDbParams.DbName := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'NAME', AIniFile);
  //FDbParams.FbClientPath := AIniFile.TryReadString(SECTION_NAME,'FBCLIENT_PATH','');
end;

procedure TAppConfig.LoadLogConsoleParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'LOG_CONSOLE';
begin
  FLogConsoleParams.LevelMsg := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'LEVEL_MSG', AIniFile);
end;

procedure TAppConfig.LoadLogFileParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'LOG_FILE';
begin
  FLogFileParams.LevelMsg := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'LEVEL_MSG', AIniFile);
  FLogFileParams.LevelMsg := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'PATH_LOGS', AIniFile);
end;

procedure TAppConfig.LoadLogGrafanaLokiParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'GRAFANA_LOKI';
begin
  FLogGrafanaLokiParams.UrlBase := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'URLBASE', AIniFile);
  FLogGrafanaLokiParams.User := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'USER', AIniFile);
  FLogGrafanaLokiParams.Pass := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'PASS', AIniFile);
  FLogGrafanaLokiParams.LevelMsg := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'LEVEL_MSG', AIniFile);
end;

procedure TAppConfig.LoadNfeParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'NFE';
begin
  FNfeParams.PathSchemas := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'PATH_SCHEMAS', AIniFile);
  FNfeParams.PathDownloadXml := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'PATH_DOWNLOAD_XML', AIniFile);
end;

procedure TAppConfig.LoadParams;
var
  IniFile: TIniFile;
  PathApp: String;
  PathConf: String;
begin
  {$IFDEF LINUX}
    PathApp := '/apps/mcn-sistemas/mcn-dfe-api-v2';
    PathConf := PathApp + '/conf';
  {$ELSE}
    PathApp := ExtractFilePath(ParamStr(0));
    PathConf := StringReplace(PathApp,'\bin','\conf',[rfReplaceAll]);
  {$ENDIF}

  if not DirectoryExists(PathConf) then
    ForceDirectories(PathConf);

  if not FileExists(IncludeTrailingPathDelimiter(PathConf) + MCN_DFE_API_INI) then
    CreateIni(IncludeTrailingPathDelimiter(PathConf));

  IniFile := TIniFile.Create(IncludeTrailingPathDelimiter(PathConf) + MCN_DFE_API_INI);

  try
    LoadAppParams(IniFile);
    LoadDbParams(Inifile);
    LoadNfeParams(IniFile);
    LoadLogGrafanaLokiParams(IniFile);
    LoadLogConsoleParams(IniFile);
    LoadLogFileParams(IniFile);
  finally
    FreeAndNil(IniFile);
  end;
end;

initialization
  AppConfig := TAppConfig.Create;

finalization
  FreeAndNil(AppConfig);

end.
