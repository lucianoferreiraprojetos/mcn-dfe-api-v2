unit Server.DataAccess.NativeQuery;

interface

uses
  System.Rtti, System.SysUtils, System.Classes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.Generics.Collections,
  Server.DataAccess.DbConnection;

type

  TProcDataSetForEach = reference to procedure(const AFields: TFields);

  INativeQuery = interface
    ['{1A9CB8CF-DB53-42CD-BC7B-0EB58F14DC23}']
    function Clear(): INativeQuery;
    function Add(const ASQL: String): INativeQuery;
    function SetParam(const AParamName: String; const AValue: Variant): INativeQuery; overload;
    function SetParam(const AParamName: String; const AValue: TBytes): INativeQuery; overload;
    function GetDataSet: TDataSet;
    function GetDataSetDetached: TDataSet;
    function IsEmpty: Boolean;
    function IsNotEmpty: Boolean;
    procedure GetDataSetForEach(AProcDataSetForEach: TProcDataSetForEach);
    procedure ExecSQL;
  end;

  TNativeQuery = class(TInterfacedObject,INativeQuery)
  private
    FDbConnection: TDbConnection;
    FSlSQL: TStringList;
    FParamsList: TDictionary<String,TValue>;
    FFDQuery: TFDQuery;
    constructor Create(ADbConnection: TDbConnection);
    destructor Destroy; override;
  public
    function Clear(): INativeQuery;
    function Add(const ASQL: String): INativeQuery;
    function SetParam(const AParamName: String; const AValue: Variant): INativeQuery; overload;
    function SetParam(const AParamName: String; const AValue: TBytes): INativeQuery; overload;
    function GetDataSet: TDataSet;
    function GetDataSetDetached: TDataSet;
    function IsEmpty: Boolean;
    function IsNotEmpty: Boolean;
    procedure GetDataSetForEach(AProcDataSetForEach: TProcDataSetForEach);
    procedure ExecSQL;
  public
    class function New(ADbConnection: TDbConnection): INativeQuery;
  end;

implementation

{ TNativeQuery }

function TNativeQuery.Add(const ASQL: String): INativeQuery;
begin
  Result := Self;
  FSlSQL.Add(ASQL);
end;

function TNativeQuery.Clear: INativeQuery;
begin
  Result := Self;
  FSlSQL.Clear;
end;

constructor TNativeQuery.Create(ADbConnection: TDbConnection);
begin
  FDbConnection := ADbConnection;
  FSlSQL := TStringList.Create;
  FParamsList := TDictionary<String,TValue>.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := ADbConnection.GetFDConnection;
end;

destructor TNativeQuery.Destroy;
begin
  FreeAndNil(FSlSQL);
  FreeAndNil(FParamsList);
  FreeAndNil(FFDQuery);
  inherited;
end;

procedure TNativeQuery.ExecSQL;
begin
  FFDQuery.Close;
  FFDQuery.SQL.Text := FSlSQL.Text;
  for var Param in FParamsList do
  begin
    if Param.Value.IsType<TBytes> then
    begin
      var Bytes := TBytesStream.Create(Param.Value.AsType<TBytes>);
      try
        FFDQuery.ParamByName(Param.Key).LoadFromStream(Bytes,ftBlob);
      finally
        FreeAndNil(Bytes);
      end;
    end
    else
      FFDQuery.ParamByName(Param.Key).Value := Param.Value.AsVariant;
  end;
  FFDQuery.ExecSQL;
end;

function TNativeQuery.GetDataSet: TDataSet;
begin
  FFDQuery.Close;
  FFDQuery.SQL.Text := FSlSQL.Text;
  for var Param in FParamsList do
    FFDQuery.ParamByName(Param.Key).Value := Param.Value.AsVariant;
  FFDQuery.Open;
  FFDQuery.First;
  Result := FFDQuery;
end;

function TNativeQuery.GetDataSetDetached: TDataSet;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  Qry.Connection := FDbConnection.GetFDConnection;
  Qry.SQL.Text := FSlSQL.Text;
  for var Param in FParamsList do
    Qry.ParamByName(Param.Key).Value := Param.Value.AsVariant;
  Qry.Open;
  Qry.First;
  Result := Qry;
end;

procedure TNativeQuery.GetDataSetForEach(AProcDataSetForEach: TProcDataSetForEach);
var
  Dts: TDataSet;
begin
  Dts := GetDataSet;
  Dts.First;
  while not Dts.Eof do
  begin
    if Assigned(AProcDataSetForEach) then
      AProcDataSetForEach(Dts.Fields);
    Dts.Next;
  end;
end;

function TNativeQuery.IsEmpty: Boolean;
begin
  Result := GetDataSet.IsEmpty;
end;

function TNativeQuery.IsNotEmpty: Boolean;
begin
  Result := not GetDataSet.IsEmpty;
end;

class function TNativeQuery.New(ADbConnection: TDbConnection): INativeQuery;
begin
  Result := Self.Create(ADbConnection);
end;

function TNativeQuery.SetParam(const AParamName: String;
  const AValue: TBytes): INativeQuery;
begin
  Result := Self;
  FParamsList.Add(AParamName,TValue.From<TBytes>(AValue));
end;

function TNativeQuery.SetParam(const AParamName: String;
  const AValue: Variant): INativeQuery;
begin
  Result := Self;
  FParamsList.Add(AParamName,TValue.FromVariant(AValue));
end;

end.
