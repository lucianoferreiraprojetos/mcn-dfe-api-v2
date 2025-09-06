unit Server.DataAccess.DbParams;

interface

type

  TDbParams = class
  private
    FHost: String;
    FPort: Integer;
    FUser: String;
    FPass: String;
    FDbName: String;
    FFbClientPath: String;
  public
    constructor Create; overload;
    constructor Create(AHost: String; APort: Integer;
      AUser, APass, ADbName: String); overload;
  public
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property User: String read FUser write FUser;
    property Pass: String read FPass write FPass;
    property DbName: String read FDbName write FDbName;
    property FbClientPath: String read FFbClientPath write FFbClientPath;
  end;

implementation

{ TDbParams }

constructor TDbParams.Create(AHost: String; APort: Integer; AUser, APass,
  ADbName: String);
begin
  inherited Create;
  FHost := AHost;
  FPort := APort;
  FUser := AUser;
  FPass := APass;
  FDbName := ADbName;
end;

constructor TDbParams.Create;
begin
  inherited Create;
end;

end.
