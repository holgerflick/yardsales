{*******************************************************************************}
{                                                                               }
{ Copyright © 2022                                                              }
{   FlixEngineering, LLC                                                        }
{   Email : info@flixengineering.com                                            }
{   Web : https://www.flixengineering.com                                       }
{                                                                               }
{ The source code is given as is. The author is not responsible                 }
{ for any possible damage done due to the use of this code.                     }
{ The component can be freely used in any application. The complete             }
{ source code remains property of the author and may not be distributed,        }
{ published, given or sold in any form as such. No parts of the source          }
{ code can be included in any other component or application without            }
{ written authorization of the author.                                          }
{                                                                               }
{*******************************************************************************}
unit uDbController;

interface

uses
  System.SysUtils,
  System.Classes,

  Bcl.Logging,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Phys,
  FireDAC.Comp.Client,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL
  ;

type
  TDbController = class(TDataModule)
    Manager: TFDManager;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;

    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    class var FInstance: TDbController;

    function IsConnectionDefined: Boolean;
    function GetConnectionDefName: String;
    function GetDriverName: String;
    function GetLogger: ILogger;

  public
    { Public declarations }
    class function Shared: TDbController;
    class destructor Destroy;

    function GetConnection: TFDConnection;
    function GetQuery: TFDQuery;

    property Logger: ILogger read GetLogger;
  end;

implementation

uses
  uServerSettings
  ;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDbController }

procedure TDbController.DataModuleCreate(Sender: TObject);
begin
  Manager.Active := True;
end;

class destructor TDbController.Destroy;
begin
  FInstance.Free;
end;

function TDbController.GetConnection: TFDConnection;
var
  LParams: TStringlist;

begin
  if not IsConnectionDefined then
  begin
    LParams := TStringlist.Create;
    try
      TServerSettings.Shared.LoadConnectionParams(LParams);

      Manager.AddConnectionDef(
        self.GetConnectionDefName,
        self.GetDriverName,
        LParams,
        False);

       Logger.Info( 'Added new connection definition named ' +
        self.GetConnectionDefName );
    finally
      LParams.Free;
    end;
  end;

  Result := TFDConnection.Create( nil );
  Result.LoginPrompt := False;
  Result.ConnectionDefName := self.GetConnectionDefName;

  Logger.Debug( 'New connection retrieved from pool.' );
end;

function TDbController.GetConnectionDefName: String;
begin
  Result := TServerSettings.Shared.ConnectionDefName;
end;

function TDbController.GetDriverName: String;
begin
  Result := TServerSettings.Shared.DriverName;
end;

function TDbController.GetLogger: ILogger;
begin
  Result := LogManager.GetLogger;
end;

function TDbController.GetQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := GetConnection;
end;

function TDbController.IsConnectionDefined: Boolean;
begin
  Result := Manager.ConnectionDefs.FindConnectionDef(self.GetConnectionDefName)
    <> nil;
end;

class function TDbController.Shared: TDbController;
begin
  if not Assigned( FInstance ) then
  begin
    FInstance := TDbController.Create(nil);
  end;

  Result := FInstance;
end;

end.
