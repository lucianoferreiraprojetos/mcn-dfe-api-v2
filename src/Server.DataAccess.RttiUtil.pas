unit Server.DataAccess.RttiUtil;

interface

uses
  System.Rtti, System.TypInfo, Data.DB, Server.DataAccess.AttributeMappings;

type

  TRttiPropertyHelper = class Helper for TRttiProperty
  public
    function IsDateTime: Boolean;
    function IsBytes: Boolean;
    function IsBoolean: Boolean;
    function IsString: Boolean;
    function IsLargeInt: Boolean;
    function HasSqlColumnMapping: Boolean;
    function GetSqlColummMapping: SqlColumnMapping;

    function HasNotEmptyValidation: Boolean;
    function GetNotEmptyValidation: NotEmptyValidation;

    function HasMinValidation: Boolean;
    function GetMinValidation: MinValidation;
  end;

  TRttiUtil = class
  public
    class function GetEntityTableName(AClazz: TClass): String;
    class function GetObjectFromDataSetFields(AClazz: TClass; AFields: TFields): TObject; overload;
    class function GetObjectFromDataSetFields<T: class>(AFields: TFields): T; overload;
    class procedure SetObjectValue(AObject: TObject; const APropName: String;
      const APropValue: Variant);
    class function _ConvertTo(AClazzTarget: TClass; AObjectOrigin: TObject; AAutoDestroyOrigin: Boolean): TObject;
  end;

implementation

uses
  System.SysUtils, System.StrUtils;

{ TRttiUtil }

class function TRttiUtil._ConvertTo(AClazzTarget: TClass; AObjectOrigin: TObject;
  AAutoDestroyOrigin: Boolean): TObject;
var
  rCtx: TRttiContext;
  rTypOrigin: TRttiType;
  rTypTarget: TRttiType;
  rPrpOrigin: TRttiProperty;
  rPrpTarget: TRttiProperty;
begin
  try
    Result := TClass(AClazzTarget).Create;
    rCtx := TRttiContext.Create;
    try
      rTypOrigin := rCtx.GetType(AObjectOrigin.ClassType);
      rTypTarget := rCtx.GetType(AClazzTarget);
      for rPrpOrigin in rTypOrigin.GetProperties do
      begin
        for rPrpTarget in rTypTarget.GetProperties do
        begin
          if SameText(rPrpTarget.Name,rPrpOrigin.Name) then
          begin
            rPrpTarget.SetValue(Pointer(Result),rPrpOrigin.GetValue(AObjectOrigin));
            Break;
          end;
        end;
      end;
    finally
      rCtx.Free;
    end;
  finally
    if AAutoDestroyOrigin then
      FreeAndNil(AObjectOrigin);
  end;
end;

class function TRttiUtil.GetEntityTableName(AClazz: TClass): String;
var
  rCtx: TRttiContext;
  rTyp: TRttiType;
begin
  rCtx := TRttiContext.Create;
  try
    rTyp := rCtx.GetType(AClazz);
    if rTyp.HasAttribute<SqlTable> then
      Result := SqlTable(rTyp.GetAttribute<SqlTable>).Name;
  finally
    rCtx.Free;
  end;
end;

class function TRttiUtil.GetObjectFromDataSetFields(AClazz: TClass;
  AFields: TFields): TObject;
var
  rCtx: TRttiContext;
  rTyp: TRttiType;
  rPrp: TRttiProperty;
begin
  Result := TClass(AClazz).Create;
  rCtx := TRttiContext.Create;
  try
    rTyp := rCtx.GetType(AClazz);
    for var LField in AFields do
    begin
      if LField.IsNull then
        Continue;
      for rPrp in rTyp.GetProperties do
      begin
        var FieldName := StringReplace(LField.FieldName,'_','',[rfReplaceAll]);
        if SameText(rPrp.Name,FieldName) or (rPrp.HasSqlColumnMapping and SameText(rPrp.GetSqlColummMapping.Name,LField.FieldName)) then
        begin
          if rPrp.IsDateTime then
            rPrp.SetValue(Pointer(Result),TValue.From<TDateTime>(LField.AsDateTime))
          else if rPrp.IsBoolean then
            rPrp.SetValue(Pointer(Result),TValue.FromVariant(LField.AsBoolean))
          else if rPrp.IsBytes then
            rPrp.SetValue(Pointer(Result),TValue.From<TBytes>(LField.AsBytes))
          else
            rPrp.SetValue(Pointer(Result),TValue.FromVariant(LField.Value));
        end;
      end;
    end;
  finally
    rCtx.Free;
  end;
end;

class function TRttiUtil.GetObjectFromDataSetFields<T>(AFields: TFields): T;
begin
  Result := GetObjectFromDataSetFields(T,AFields) as T;
end;

class procedure TRttiUtil.SetObjectValue(AObject: TObject;
  const APropName: String; const APropValue: Variant);
var
  rCtx: TRttiContext;
  rTyp: TRttiType;
  rPrp: TRttiProperty;
begin
  rCtx := TRttiContext.Create;
  try
    rTyp := rCtx.GetType(AObject.ClassType);
    for rPrp in rTyp.GetProperties do
    begin
      if SameText(rPrp.Name,APropName) then
      begin
        rPrp.SetValue(Pointer(AObject),TValue.FromVariant(APropValue));
        Break;
      end;
    end;
  finally
    rCtx.Free;
  end;
end;

{ TRttiPropertyHelper }

function TRttiPropertyHelper.GetMinValidation: MinValidation;
begin
  Result := GetAttribute<MinValidation>;
end;

function TRttiPropertyHelper.GetNotEmptyValidation: NotEmptyValidation;
begin
  Result := GetAttribute<NotEmptyValidation>;
end;

function TRttiPropertyHelper.GetSqlColummMapping: SqlColumnMapping;
begin
  Result := GetAttribute<SqlColumnMapping> as SqlColumnMapping;
end;

function TRttiPropertyHelper.HasMinValidation: Boolean;
begin
  Result := HasAttribute<MinValidation>;
end;

function TRttiPropertyHelper.HasNotEmptyValidation: Boolean;
begin
  Result := HasAttribute<NotEmptyValidation>;
end;

function TRttiPropertyHelper.HasSqlColumnMapping: Boolean;
begin
  Result := HasAttribute<SqlColumnMapping>;
end;

function TRttiPropertyHelper.IsBoolean: Boolean;
begin
  Result := (PropertyType.TypeKind = tkEnumeration) and (PropertyType.Name = 'Boolean');
end;

function TRttiPropertyHelper.IsBytes: Boolean;
begin
  Result := (PropertyType.TypeKind = tkDynArray) and (PropertyType.Name = 'TArray<System.Byte>');
end;

function TRttiPropertyHelper.IsDateTime: Boolean;
begin
  Result := (PropertyType.TypeKind = tkFloat) and (PropertyType.Name = 'TDateTime');
end;

function TRttiPropertyHelper.IsLargeInt: Boolean;
begin
  Result := (PropertyType.TypeKind in [tkInt64]);
end;

function TRttiPropertyHelper.IsString: Boolean;
begin
  Result := (PropertyType.TypeKind in [tkString,tkUString,tkChar,tkLString]);
end;

end.
