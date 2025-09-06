unit Server.DataAccess.AttributeMappings;

interface

uses
  System.Classes;

type

  SqlTable = class abstract (TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(AName: String);
    property Name: String read FName write FName;
  end;

  SqlColumnMapping = class abstract (TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(AName: String);
    property Name: String read FName write FName;
  end;

  NotEmptyValidation = class abstract (TCustomAttribute)
  private
    FMsg: String;
  public
    constructor Create(AMsg: String);
    property Msg: String read FMsg write FMsg;
  end;

  MinValidation = class abstract (TCustomAttribute)
  private
    FMin: Integer;
    FMsg: String;
  public
    constructor Create(AMin: Integer; AMsg: String);
    property Min: Integer read FMin write FMin;
    property Msg: String read FMsg write FMsg;
  end;



implementation

{ SqlColumnMapping }

constructor SqlColumnMapping.Create(AName: String);
begin
  FName := AName;
end;

{ NotEmptyValidation }

constructor NotEmptyValidation.Create(AMsg: String);
begin
  FMsg := AMsg;
end;

{ MinValidation }

constructor MinValidation.Create(AMin: Integer; AMsg: String);
begin
  FMin := AMin;
  FMsg := AMsg;
end;

{ SqlTable }

constructor SqlTable.Create(AName: String);
begin
  FName := AName;
end;

end.
