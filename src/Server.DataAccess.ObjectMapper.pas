unit Server.DataAccess.ObjectMapper;

interface

uses
  Server.DataAccess.RttiUtil, System.Generics.Collections, System.Rtti,
  System.TypInfo;

type

  TObjectMapper = class
  public
    class function MapTo<T: class>(AObjectOrigin: TObject; AAutoDestroyOrigin: Boolean): T; overload;
    class function MapTo<O,T: class>(AObjectOriginList: TObjectList<O>;
      AAutoDestroyOrigin: Boolean): TObjectList<T>; overload;
    class procedure Merge(AMapValuesOrigin: TDictionary<String,Variant>;
      AObjectTarget: TObject; AAutoDestroyOrigin: Boolean);
  end;

implementation

uses
  System.SysUtils, System.Variants;

{ TObjectMapper }

class function TObjectMapper.MapTo<O, T>(AObjectOriginList: TObjectList<O>;
  AAutoDestroyOrigin: Boolean): TObjectList<T>;
begin
  try
    Result := TObjectList<T>.Create;
    for var ItemOrigin in AObjectOriginList do
      Result.Add(MapTo<T>(ItemOrigin,False));
  finally
    FreeAndNil(AObjectOriginList);
  end;
end;

class function TObjectMapper.MapTo<T>(AObjectOrigin: TObject;
  AAutoDestroyOrigin: Boolean): T;
begin
  Result := TRttiUtil._ConvertTo(T,AObjectOrigin,AAutoDestroyOrigin) as T;
end;

class procedure TObjectMapper.Merge(
  AMapValuesOrigin: TDictionary<String, Variant>; AObjectTarget: TObject;
  AAutoDestroyOrigin: Boolean);
var
  rCtx: TRttiContext;
  rTyp: TRttiType;
  rPrp: TRttiProperty;
  IsFound: Boolean;
  LValue: TValue;
begin
  try
    rCtx := TRttiContext.Create;
    try
      rTyp := rCtx.GetType(AObjectTarget.ClassType);
      for var Item in AMapValuesOrigin do
      begin
        IsFound := False;
        for rPrp in rTyp.GetProperties do
        begin
          if SameText(Item.Key,rPrp.Name) then
          begin
            IsFound := True;
            if (rPrp.IsBoolean) and (VarIsStr(Item.Value)) then
            begin
              if LowerCase(Item.Value) = 'true' then
                LValue := TValue.FromVariant(True)
              else if LowerCase(Item.Value) = 'false' then
                LValue := TValue.FromVariant(False)
              else
                raise Exception.Create('Error converting boolean to string');
            end
            else if (rPrp.PropertyType.TypeKind = tkInt64) and (VarIsStr(Item.Value)) then
              LValue := TValue.FromVariant(StrToInt64(Item.Value))
            else
              LValue := TValue.FromVariant(Item.Value);
            rPrp.SetValue(Pointer(AObjectTarget),LValue);
            Break;
          end;
        end;
        if not IsFound then
          raise Exception.Create(Format('Não existe a propriedade (%s)',[Item.Key]));
      end;
    finally
      rCtx.Free;
    end;
  finally
    if AAutoDestroyOrigin then
      FreeAndNil(AMapValuesOrigin);
  end;
end;

end.
