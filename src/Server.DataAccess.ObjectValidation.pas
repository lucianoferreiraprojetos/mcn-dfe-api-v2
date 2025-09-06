unit Server.DataAccess.ObjectValidation;

interface

uses
  Server.DataAccess.AttributeMappings, System.Generics.Collections,
  System.Rtti, System.TypInfo;

type

  TObjectValidation = class
  public
    class procedure Validate(AObject: TObject);
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.Variants, Server.DataAccess.RttiUtil;

{ TObjectValidation }

class procedure TObjectValidation.Validate(AObject: TObject);
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
      if rPrp.HasNotEmptyValidation then
      begin
        var LValue := rPrp.GetValue(Pointer(AObject));

        if (rPrp.IsLargeInt) and (LValue.AsInt64 <= 0) then
          raise Exception.Create(rPrp.GetNotEmptyValidation.Msg);

        if (rPrp.IsString) and ((LValue.IsEmpty) or (Trim(LValue.AsString) = '')) then
          raise Exception.Create(rPrp.GetNotEmptyValidation.Msg);
      end
      else if rPrp.HasMinValidation then
      begin
        var LValue := rPrp.GetValue(Pointer(AObject));

        if (LValue.AsInteger <= 0) then
          raise Exception.Create(rPrp.GetMinValidation.Msg);
      end;
    end;
  finally
    rCtx.Free;
  end;
end;

end.
