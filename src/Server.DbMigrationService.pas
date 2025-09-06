unit Server.DbMigrationService;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, System.Variants,
  Server.AppLogger, Server.DataAccess.DbConnection;

type

  TDbMigrationService = class
  private
    FDbConnection: TDbConnection;
    procedure CreateTableDbMigration;
    function CheckIsExistsTableDbMigration: Boolean;
    function CheckIsExistsScriptVersion(AScriptVersion: String): Boolean;
    function LoadScriptsFile(): TStringList;
    procedure ScriptExecute(AScriptFile: String);
    function GetPathScripts(): String;
    procedure RegisterScript(AScriptName: String);
  public
    constructor Create(ADbConnection: TDbConnection);
    destructor Destroy; override;
    procedure InternalApplyUpdate();
  public
    class procedure ApplyUpdate();
  end;

implementation


{ TDbMigrationService }

class procedure TDbMigrationService.ApplyUpdate;
var
  DbMigration: TDbMigrationService;
  DbConnection: TDbConnection;
begin
//  DbConnection := TDbConnectionFactory.GetDbConnection();
//  try
//    DbMigration := TDbMigrationService.Create(DbConnection);
//    try
//      try
//        DbMigration.InternalApplyUpdate();
//      except on E: Exception do
//        begin
//          LogError(Format('Erro ao atualizar o banco de dados - %s',[E.Message]), Self);
//          raise E;
//        end;
//      end;
//    finally
//      FreeAndNil(DbMigration);
//    end;
//  finally
//    FreeAndNil(DbConnection);
//  end;
end;

function TDbMigrationService.CheckIsExistsScriptVersion(
  AScriptVersion: String): Boolean;
const
  SQL = 'SELECT 1 FROM DB_MIGRATION WHERE VERSION = %s';
begin
  Result := FDbConnection.CheckIsExistsBySql(Format(SQL,[AScriptVersion.ToUpper.QuotedString]));
end;

function TDbMigrationService.CheckIsExistsTableDbMigration: Boolean;
const
  SQL = 'SELECT 1 FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''DB_MIGRATION''';
begin
  Result := FDbConnection.CheckIsExistsBySql(SQL);
end;

constructor TDbMigrationService.Create(ADbConnection: TDbConnection);
begin
  FDbConnection := ADbConnection;
end;

procedure TDbMigrationService.CreateTableDbMigration;
var
  SbSql: TStringBuilder;
begin
{
  SbSql := TStringBuilder.Create();
  try
    SbSql.Append('CREATE TABLE DB_MIGRATION                                 ');
    SbSql.Append('(                                                         ');
    SbSql.Append('VERSION VARCHAR(16) NOT NULL,                             ');
    SbSql.Append('DESCRIPTION VARCHAR(250) NOT NULL,                        ');
    SbSql.Append('FILE_NAME VARCHAR(350) NOT NULL,                          ');
    SbSql.Append('DTH_INSERT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL   ');
    SbSql.Append(');                                                        ');
    SbSql.Append('ALTER TABLE DB_MIGRATION ADD                              ');
    SbSql.Append('      CONSTRAINT PK_DB_MIGRATION                          ');
    SbSql.Append('      PRIMARY KEY(VERSION);                               ');
    try
      TDbExecScript.ExecSql(FDbConnection,SbSql.ToString);
      LogInfo('Tabela DB_MIGRATION criada com sucesso',Self.ClassType);
    except on E: Exception do
      begin
        LogError('Erro ao criar a tabela DB_MIGRATION - ' + E.Message,Self.ClassType);
        raise E;
      end;
    end;
  finally
    FreeAndNil(SbSql);
  end;
}
end;

destructor TDbMigrationService.Destroy;
begin
  inherited;
end;

procedure TDbMigrationService.InternalApplyUpdate;
var
  SlFiles: TStringList;
  StrLinha: String;
  ScriptVersion: String;
  I: Integer;
begin
  if not CheckIsExistsTableDbMigration() then
  begin
    CreateTableDbMigration();
  end;
  SlFiles := LoadScriptsFile();
  try
    SlFiles.Sort;
    for I := 0 to SlFiles.Count -1 do
    begin
      StrLinha := SlFiles[I];
      ScriptVersion := LeftStr(ExtractFileName(StrLinha),16);
      if not CheckIsExistsScriptVersion(ScriptVersion) then
      begin
        ScriptExecute(StrLinha);
      end;
    end;
  finally
    FreeAndNil(SlFiles);
  end;
end;

function TDbMigrationService.LoadScriptsFile: TStringList;
var
  F: TSearchRec;
  Ret: Integer;
  PathScripts: String;
  function ScriptFormatValidate(AFileName: String): Boolean;
  begin
    Result := (Length(AFileName) > 18) and 
              (LeftStr(AFileName,1).ToUpper = 'V') and 
              (Copy(AFileName,17,2) = '__');
  end;
begin
  Result := TStringList.Create;
  PathScripts := IncludeTrailingPathDelimiter(GetPathScripts);
  Ret := FindFirst(PathScripts + '*.sql', faAnyFile, F);
  try
    while Ret = 0 do
    begin
      if (ScriptFormatValidate(F.Name)) then
      begin
        F.Name[1] := 'V';
        Result.Add(PathScripts + F.Name);
      end;
      Ret := FindNext(F);
    end;
  finally
    FindClose(F);
  end;
end;

procedure TDbMigrationService.RegisterScript(AScriptName: String);
const
  SQL_INSERT = 'INSERT INTO DB_MIGRATION (VERSION,DESCRIPTION,FILE_NAME) VALUES (%s,%s,%s)';
var
  ScriptVersion: String;
  ScriptDescription: String;
begin

  ScriptVersion := LeftStr(AScriptName,16);

  ScriptDescription := RightStr(AScriptName,Length(AScriptName) - 18);

  ScriptDescription := StringReplace(ScriptDescription,'_', ' ',[rfReplaceAll]);

  ScriptDescription := StringReplace(ScriptDescription,'.sql', '',[rfReplaceAll,rfIgnoreCase]);

  try

    FDbConnection.ExecSql(Format(SQL_INSERT,[
       ScriptVersion.ToUpper.QuotedString,
       ScriptDescription.QuotedString,
       AScriptName.QuotedString]));

    LogInfo('Script registrado: ' + AScriptName,Self.ClassType);
  except on E: Exception do
    begin
      LogError('Erro ao registrar script: ' + AScriptName,Self.ClassType);
      raise E;
    end;
  end;

end;

procedure TDbMigrationService.ScriptExecute(AScriptFile: String);
var
  ScriptName: String;
begin
{
  ScriptName := ExtractFileName(AScriptFile);
  LogInfo(Format('Executando o script: %s',[ScriptName]),Self.ClassType);
  try
    TDbExecScript.ExecFile(FDbConnection,AScriptFile);
    RegisterScript(ScriptName);
  except on E: Exception do
    begin
      LogError('Erro executando o script: ' + ScriptName,Self.ClassType);
      raise E;
    end;
  end;
}
end;

function TDbMigrationService.GetPathScripts: String;
const
  DB_SCRIPTS = 'dbscripts';
var
  PathRoot: String;
begin
  PathRoot := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  //1. Linha de comando
  //2. Variaveis de ambiente
  //3. APP_CONFIG ...
  //4. Uma subpasta onde esta o binario
  //5. Uma pasta anterior onde ta o binario

  if DirectoryExists(PathRoot + DB_SCRIPTS) then
    Result := PathRoot + DB_SCRIPTS
  else
    Result := PathRoot + '..' + PathDelim + 'dbscripts';
end;

end.
