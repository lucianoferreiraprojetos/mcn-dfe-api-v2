unit Server.AppSysUtils;

interface

uses
  System.Generics.Collections;

type
  TAppSysUtils = class
  public
    class function PegarCmdParams(): TDictionary<String,String>;
    class function PegarCmdParam(ParamName: String): String;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.Types;

{ TAppSysUtils }

class function TAppSysUtils.PegarCmdParam(ParamName: String): String;
var
  Params: TDictionary<String, String>;
  Pair: TPair<String,String>;
begin
  Params := PegarCmdParams();
  try
    for Pair in Params do
    begin
      if SameText(Pair.Key,ParamName) then
      begin
        Exit(Pair.Value);
      end;
    end;
  finally
    FreeAndNil(Params)
  end;
end;

class function TAppSysUtils.PegarCmdParams: TDictionary<String, String>;
const
  PREFIXO_SEM_VALOR = '--';
var
  I: Integer;
  PosSep: Integer;
  LParam: String;
  LKey, LVal: String;
  FaltaTratarOValor: Boolean;
begin
  Result := TDictionary<String, String>.Create;
  FaltaTratarOValor := False;
  for I := 1 to ParamCount do
  begin
    LParam := ParamStr(I);
    if FaltaTratarOValor then
    begin
      LVal := LParam;
      FaltaTratarOValor := False;
      Result.Add(LKey,LVal);
    end
    else
    begin
      PosSep := Pos('=',LParam);
      if PosSep > 0 then
      begin
        FaltaTratarOValor := False;
        LKey := LeftStr(LParam,PosSep - 1);
        LVal := RightStr(LParam,Length(LParam) - PosSep);
        Result.Add(LKey,LVal);
      end
      else
      begin
        LKey := LParam;
        if (LeftStr(LParam,2) = PREFIXO_SEM_VALOR) then
        begin
          FaltaTratarOValor := False;
          LVal := '';
          Result.Add(LKey,LVal);
        end
        else
          FaltaTratarOValor := True;
      end;
    end;
  end;
end;


end.
