unit Server.Data.JsonConverter;

interface

uses
  System.Classes,
  System.StrUtils, System.SysUtils,
  System.Generics.Collections,
  System.JSON, REST.Json;

type
  TJsonConverter = class
  public
    class function JsonObjectToMapValues(AJsonObj: TJSONObject): TDictionary<String,Variant>;
    class function JsonObjectToObject<T: class,constructor>(AJsonStr: string): T; overload;
    class function ObjectToJsonObject(Entity: TObject; AutoDestroy: Boolean = False): TJSONObject;
    class function ObjectListToJsonArray<T: class,constructor>(
      Lista: TObjectList<T>; AutoDestroy: Boolean = False): TJsonArray;
  end;

implementation

{ TJsonConverter }

class function TJsonConverter.JsonObjectToMapValues(
  AJsonObj: TJSONObject): TDictionary<String, Variant>;
var
  I: Integer;
  JPair: TJSONPair;
begin
  Result := TDictionary<String,Variant>.Create;
  for I := 0 to AJsonObj.Count -1 do
  begin
    JPair := AJsonObj.Get(I);
    Result.Add(JPair.JsonString.Value,JPair.JsonValue.Value);
  end;
end;

class function TJsonConverter.JsonObjectToObject<T>(AJsonStr: string): T;
begin
  Result := TJson.JsonToObject<T>(AJsonStr,[joIndentCasePreserve]);
end;

class function TJsonConverter.ObjectToJsonObject(Entity: TObject;
  AutoDestroy: Boolean = False): TJSONObject;
var
  Json: TJSONObject;
begin
  Json := TJson.ObjectToJsonObject(Entity,[joIndentCasePreserve]);

  if (AutoDestroy) then
    FreeAndNil(Entity);

  Result := Json;
end;

class function TJsonConverter.ObjectListToJsonArray<T>(
  Lista: TObjectList<T>; AutoDestroy: Boolean = False): TJsonArray;
var
  Item: T;
begin
  Result := TJSONArray.Create;

  for Item in Lista do
    Result.Add(TJsonConverter.ObjectToJsonObject(Item));

  if (AutoDestroy) then
    FreeAndNil(Lista);
end;

end.
