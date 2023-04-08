unit uServerContainer;

interface

uses
  System.SysUtils,
  System.Classes,

  Sparkle.HttpServer.Module,
  Sparkle.HttpServer.Context,
  Sparkle.Comp.Server,
  Sparkle.Comp.HttpSysDispatcher,

  Aurelius.Drivers.Interfaces,
  Aurelius.Comp.Connection,

  XData.Comp.ConnectionPool,
  XData.Server.Module,
  XData.Comp.Server, Sparkle.Comp.JwtMiddleware
  ;

type
  TServerContainer = class(TDataModule)
    SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher;
    XDataServer: TXDataServer;
    ServerJWT: TSparkleJwtMiddleware;
    procedure DataModuleCreate(Sender: TObject);
    procedure ServerJWTGetSecret(Sender: TObject; var Secret: string);
  end;

var
  ServerContainer: TServerContainer;

implementation
uses
  uServerSettings
  ;


{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TServerContainer.DataModuleCreate(Sender: TObject);
begin
  XDataServer.BaseUrl := TServerSettings.Shared.BaseUrl;
end;

procedure TServerContainer.ServerJWTGetSecret(Sender: TObject; var Secret:
    string);
begin
  Secret := TServerSettings.Shared.JWTSecret;
end;

end.
