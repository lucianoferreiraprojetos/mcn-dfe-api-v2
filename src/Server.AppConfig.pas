unit Server.AppConfig;

interface

uses
  Server.DataAccess.DbParams, System.IniFiles;

type

  TIniFileHelper = class helper for TIniFile
  public
    function TryReadString(ASection: String; AIdent: String; ADefault: String): String;
    function TryReadInteger(ASection: String; AIdent: String; ADefault: Integer): Integer;
  end;

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
    procedure LoadDbParams(AIniFile: TIniFile);
    procedure LoadAppParams(AIniFile: TIniFile);
    procedure LoadNfeParams(AIniFile: TIniFile);
    procedure LoadLogGrafanaLokiParams(AIniFile: TIniFile);
    procedure LoadLogConsoleParams(AIniFile: TIniFile);
    procedure LoadLogFileParams(AIniFile: TIniFile);
    function GetEnvMcnDfeApiSufix(Sufix: String): String; overload;
    function GetEnvMcnDfeApiSufix(SectionName, Sufix: String): String; overload;
    function GetEnvMcnDfeApiSufixOrIniString(SectionName, Sufix: String; IniFile: TIniFile): String;
    function GetEnvMcnDfeApiSufixOrIniInteger(SectionName, Sufix: String; IniFile: TIniFile): Integer;
  public
    constructor Create;
    destructor Destroy;
  public
    function GetDbParams: TDbParams;
    function GetAppParams: TAppParams;
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
    Result := IniFile.TryReadInteger(SectionName, Sufix.ToUpper, 0);
end;

function TAppConfig.GetEnvMcnDfeApiSufixOrIniString(SectionName, Sufix: String;
  IniFile: TIniFile): String;
begin
  if GetEnvMcnDfeApiSufix(SectionName, Sufix.ToUpper) <> '' then
    Result := GetEnvMcnDfeApiSufix(SectionName, Sufix.ToUpper)
  else
    Result := IniFile.TryReadString(SectionName, Sufix.ToUpper,'');
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
  FDbParams.Host := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'HOST',AIniFile);
  FDbParams.Port := GetEnvMcnDfeApiSufixOrIniInteger(SECTION_NAME, 'PORT', AIniFile);
  FDbParams.User := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'USER', AIniFile);
  FDbParams.Pass := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'PASS', AIniFile);
  FDbParams.DbName := GetEnvMcnDfeApiSufixOrIniString(SECTION_NAME, 'NAME', AIniFile);
  FDbParams.FbClientPath := AIniFile.TryReadString(SECTION_NAME,'FBCLIENT_PATH','');
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

  if GetEnvMcnDfeApiSufix('LOG_FILE_PATH_LOGS') <> '' then
    FLogFileParams.PathLogs := GetEnvMcnDfeApiSufix('LOG_FILE_PATH_LOGS')
  else
    FLogFileParams.PathLogs := AIniFile.TryReadString(SECTION_NAME,'PATH_LOGS','');
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
  PathApp := ExtractFilePath(ParamStr(0));
  PathConf := IncludeTrailingPathDelimiter(PathApp) + '..' + PathDelim + 'conf' + PathDelim;
  ForceDirectories(PathConf);
  IniFile := TIniFile.Create(IncludeTrailingPathDelimiter(PathConf) + MCN_DFE_API_INI);
  try
    LoadDbParams(Inifile);
    LoadAppParams(IniFile);
    LoadNfeParams(IniFile);
    LoadLogGrafanaLokiParams(IniFile);
    LoadLogConsoleParams(IniFile);
    LoadLogFileParams(IniFile);
  finally
    FreeAndNil(IniFile);
  end;
end;

{ TIniFileHelper }

function TIniFileHelper.TryReadInteger(ASection, AIdent: String;
  ADefault: Integer): Integer;
begin
  if not Self.ValueExists(ASection,AIdent) then
  begin
    Self.WriteInteger(ASection,AIdent,ADefault);
  end;
  Result := Self.ReadInteger(ASection,AIdent,ADefault);
end;

function TIniFileHelper.TryReadString(ASection, AIdent,
  ADefault: String): String;
begin
  if not ValueExists(ASection,AIdent) then
  begin
    WriteString(ASection,AIdent,ADefault);
  end;
  Result := ReadString(ASection,AIdent,ADefault);
end;

initialization
  AppConfig := TAppConfig.Create;

finalization
  FreeAndNil(AppConfig);

end.
