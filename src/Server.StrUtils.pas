unit Server.StrUtils;

interface

type
  TStrUtils = class
  public
    class function OnlyNumbers(const Str: String): String;
    class function StrToZero(const Str: String; ASize: Integer): String;
    class function IsBlank(const Str: String): Boolean;
  end;

implementation

uses
  System.StrUtils, System.SysUtils;

{ TStrUtils }

class function TStrUtils.IsBlank(const Str: String): Boolean;
begin
  Result := (Trim(Str) = EmptyStr) or (Str = 'string');
end;

class function TStrUtils.OnlyNumbers(const Str: String): String;
begin
  for var I := 1 to Length(Str) do
  begin
    if Str[I] in ['0'..'9'] then
      Result := Result + Str[I];
  end;
end;

class function TStrUtils.StrToZero(const Str: String; ASize: Integer): String;
var
  Zeros: String;
begin
  for var I := 1 to (ASize - Length(Str)) do
    Zeros := Zeros + '0';
  Result := Zeros + Str;
end;

end.
