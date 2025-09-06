unit Server.AppConfigV2;

interface

uses
  Server.DataAccess.DbParams, System.IniFiles;

type

  TIniFileHelper = class helper for TInifile
  public
    function TryReadString(ASection: String; AIdent: String; ADefault: String): String;
    function TryReadInteger(ASection: String; AIdent: String; ADefault: Integer): Integer;
  end;

  TAppParams = record
    Port: Integer;
    Environment: String;
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

  TAppConfigV2 = class
  private
    class var FDbParams: TDbParams;
    class var FAppParams: TAppParams;
    class var FLogGrafanaLokiParams: TLogGrafanaLokiParams;
    class var FLogConsoleParams: TLogConsoleParams;
    class var FLogFileParams: TLogFileParams;
    class procedure LoadParams();
    class procedure LoadDbParams(AIniFile: TIniFile);
    class procedure LoadAppParams(AIniFile: TIniFile);
    class procedure LoadLogGrafanaLokiParams(AIniFile: TIniFile);
    class procedure LoadLogConsoleParams(AIniFile: TIniFile);
    class procedure LoadLogFileParams(AIniFile: TIniFile);
  public
    class constructor Create;
    class destructor Destroy;
  public
    class function GetDbParams: TDbParams;
    class function GetAppParams: TAppParams;
  end;

implementation

uses
  System.SysUtils;

const
  MCN_DFE_API_INI = 'mcndfeapi.ini';

{ TAppConfigV2 }

class constructor TAppConfigV2.Create;
begin
  LoadParams();
end;

class destructor TAppConfigV2.Destroy;
begin
  FreeAndNil(FDbParams);
end;

class function TAppConfigV2.GetAppParams: TAppParams;
begin
  Result := FAppParams;
end;

class function TAppConfigV2.GetDbParams: TDbParams;
begin
  Result := FDbParams;
end;

class procedure TAppConfigV2.LoadAppParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'APP_SERVER';
begin
  FAppParams.Port := AIniFile.TryReadInteger(SECTION_NAME,'PORT',0);
  FAppParams.Environment := AIniFile.TryReadString(SECTION_NAME,'ENVIRONMENT','');
end;

class procedure TAppConfigV2.LoadDbParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'DB_CONNECTION';
begin
  FDbParams.Host := AIniFile.TryReadString(SECTION_NAME,'HOST','');
  FDbParams.Port := AIniFile.TryReadInteger(SECTION_NAME,'PORT',0);
  FDbParams.User := AIniFile.TryReadString(SECTION_NAME,'USER','');
  FDbParams.Pass := AIniFile.TryReadString(SECTION_NAME,'PASS','');
  FDbParams.DbName := AIniFile.TryReadString(SECTION_NAME,'DBNAME','');
end;

class procedure TAppConfigV2.LoadLogConsoleParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'LOG_CONSOLE';
begin
  FLogConsoleParams.LevelMsg := AIniFile.TryReadString(SECTION_NAME,'LEVEL_MSG','');
end;

class procedure TAppConfigV2.LoadLogFileParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'LOG_FILE';
begin
  FLogFileParams.LevelMsg := AIniFile.TryReadString(SECTION_NAME,'LEVEL_MSG','');
  FLogFileParams.PathLogs := AIniFile.TryReadString(SECTION_NAME,'PATH_LOGS','');
end;

class procedure TAppConfigV2.LoadLogGrafanaLokiParams(AIniFile: TIniFile);
const
  SECTION_NAME = 'LOG_GRAFANA_LOKI';
begin
  FLogGrafanaLokiParams.UrlBase := AIniFile.TryReadString(SECTION_NAME,'URLBASE','');
  FLogGrafanaLokiParams.User := AIniFile.TryReadString(SECTION_NAME,'USER','');
  FLogGrafanaLokiParams.Pass := AIniFile.TryReadString(SECTION_NAME,'PASS','');
  FLogGrafanaLokiParams.LevelMsg := AIniFile.TryReadString(SECTION_NAME,'LEVEL_MSG','');
end;

class procedure TAppConfigV2.LoadParams;
var
  IniFile: TIniFile;
  PathApp: String;
  PathConf: String;
begin
  PathApp := ExtractFilePath(ParamStr(0));
  PathConf := IncludeTrailingPathDelimiter(PathApp) + '..' + PathDelim + 'conf' + PathDelim;
  IniFile := TIniFile.Create(IncludeTrailingPathDelimiter(PathConf) + MCN_DFE_API_INI);
  try
    LoadDbParams(Inifile);
    LoadAppParams(IniFile);
    LoadLogGrafanaLokiParams(IniFile);
  finally
    FreeAndNil(IniFile);
  end;
end;

{ TIniFileHelper }

function TIniFileHelper.TryReadInteger(ASection, AIdent: String; ADefault: Integer): Integer;
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
  if not Self.ValueExists(ASection,AIdent) then
  begin
    Self.WriteString(ASection,AIdent,ADefault);
  end;
  Result := Self.ReadString(ASection,AIdent,ADefault);
end;

end.
