unit Server.Autorizacao.Service;

interface

uses
  System.Classes,
  Horse,
  Horse.JWT,
  JOSE.Core.JWT,
  JOSE.Core.Builder,
  System.SysUtils,
  System.StrUtils,
  System.Hash,
  Server.Data.Dtos;

type
  IAutorizacaoService = interface
    ['{941C742B-F5F0-4B1E-9520-0A6192E15D0A}']
    function GerarTokenAutenticacao(Login: String): TTokenAutenticacaoDto;
  end;

  TAutorizacaoService = class(TInterfacedObject, IAutorizacaoService)
  public
    function GerarTokenAutenticacao(Login: String): TTokenAutenticacaoDto;
    class function New: IAutorizacaoService;
  end;

const
  SECRET_KEY = '@Mcn159159';

implementation

{ TAutorizacaoService }

function TAutorizacaoService.GerarTokenAutenticacao(
  Login: String): TTokenAutenticacaoDto;
var
  LToken: TJWT;
  LCompactToken: string;
begin
  Result := TTokenAutenticacaoDTO.Create;
  LToken := TJWT.Create;
  try
    LToken.Claims.Issuer := 'MCN Sistemas';
    LToken.Claims.Subject := Login;
    LToken.Claims.Expiration := Now() + 1;
    LCompactToken := TJOSE.SHA256CompactToken(SECRET_KEY,LToken);
    Result.Token := LCompactToken;
    Result.BearerToken := 'Bearer '+ LCompactToken;
  finally
    LToken.Free;
  end;
end;

class function TAutorizacaoService.New: IAutorizacaoService;
begin
  Result := Self.Create;
end;

end.
