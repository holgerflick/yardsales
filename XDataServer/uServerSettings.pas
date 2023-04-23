unit uServerSettings;

interface

uses
  Classes,
  IniFiles;

type
  TServerSettings = class
  strict private
    class var FInstance: TServerSettings;

    function GetIniFile: TIniFile;
    function GetIniString( ASection, AIdent: String; ADefault: String ) : String;

  private
    function GetBaseUrl: String;
    function GetConnectionDefName: String;
    function GetDriverName: String;

    function GetFilename: String;
    function GetSecret: String;
    

  public
    class destructor Destroy;
    class function Shared: TServerSettings;

    procedure LoadConnectionParams( AParams: TStrings );

    property DriverName: String read GetDriverName;
    property ConnectionDefName: String read GetConnectionDefName;
    property BaseUrl: String read GetBaseUrl;

    property JWTSecret: String read GetSecret;
    property Filename: String read GetFilename;

  end;

implementation
uses
  System.IOUtils
  ;


{ TServerSettings }

class destructor TServerSettings.Destroy;
begin
  FInstance.Free;
end;

function TServerSettings.GetBaseUrl: String;
begin
  Result := self.GetIniString( 'Server', 'BaseUrl', 'http://+:80/' );
end;

function TServerSettings.GetConnectionDefName: String;
begin
  Result := self.GetIniString('Definition', 'Name', 'temp');
end;

function TServerSettings.GetDriverName: String;
begin
  Result := self.GetIniString('Driver','Name', 'MySQL');
end;

function TServerSettings.GetFilename: String;
begin
  Result := 'server.ini';
end;

function TServerSettings.GetIniFile: TIniFile;
var
  LFilename: String;

begin
  LFilename := TPath.Combine(
    TPath.GetLibraryPath,
    self.GetFilename );

  Result := TIniFile.Create( LFilename );
end;

function TServerSettings.GetIniString(ASection, AIdent,
  ADefault: String): String;
var
  LIni: TIniFile;

begin
  LIni := GetIniFile;
  try
    Result := LIni.ReadString(ASection, AIdent, ADefault);
  finally
    LIni.Free;
  end;
end;

function TServerSettings.GetSecret: String;
begin
  Result := 'B309DDD6B309DDD6-8671-4AB1-8F4D-AF6665268D91';
end;

procedure TServerSettings.LoadConnectionParams(AParams: TStrings);
var
  LIni: TIniFile;

begin
  LIni := GetIniFile;
  try
    LIni.ReadSectionValues( 'Connection', AParams);
  finally
    LIni.Free;
  end;
end;

class function TServerSettings.Shared: TServerSettings;
begin
  if not Assigned( FInstance ) then
  begin
    FInstance := TServerSettings.Create;
  end;

  Result := FInstance;
end;

end.
