unit Server.Data.Filters;

interface

type

  TEnumSituacao = (eSitAtivo,eSitInativo,eSitTodos);

  TEmpresaFiltro = record
  private
    FSomenteAtivas: Boolean;
    FSituacao: TEnumSituacao;
    FCpfCnpj: String;
  public
    property Situacao: TEnumSituacao read FSituacao write FSituacao;
    property CpfCnpj: String read FCpfCnpj write FCpfCnpj;
  public
    procedure Clear;
  end;

implementation

uses
  System.StrUtils, System.SysUtils;

{ EmpresaFiltro }

procedure TEmpresaFiltro.Clear;
begin
  FSomenteAtivas := False;
  FCpfCnpj := '';
end;

end.
