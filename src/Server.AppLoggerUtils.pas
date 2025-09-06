unit Server.AppLoggerUtils;

interface

type
  TAppLoggerUtils = class
  public
    class function GerarUnixEpochStr(): String;
  end;

implementation

uses
  System.StrUtils,System.DateUtils, System.SysUtils;

{ TAppLoggerUtils }

class function TAppLoggerUtils.GerarUnixEpochStr: String;
begin
  Result := IntToStr(DateTimeToUnix(Now, False)).PadRight(19,'0');
end;

end.
