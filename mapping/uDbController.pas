unit uDbController;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL,

  uMappingTypes
  ;

type
  TDbController = class(TDataModule)
    Connection: TFDConnection;
    Sales: TFDQuery;
    Participants: TFDQuery;
    ParticipantCategories: TFDQuery;
    sourceParticipants: TDataSource;
    ParticipantLocations: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetupConnection;
  public
    { Public declarations }

    function GetSales: TSales;
    function GetParticipants( ASalesId: Integer ): TParticipants;

  end;

implementation
uses
  System.IOUtils,
  System.IniFiles
  ;


{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDbController.DataModuleCreate(Sender: TObject);
begin
  SetupConnection;
end;

function TDbController.GetParticipants(ASalesId: Integer): TParticipants;
begin
  ParticipantCategories.Close;
  Participants.Close;

  Participants.ParamByName('SalesId').AsInteger := ASalesId;
  Participants.Open;
  ParticipantCategories.Open;

  Result := TParticipants.Create;
  while not Participants.Eof do
  begin
    Result.Add( TParticipant.Create(
      Participants,
      ParticipantCategories ) );

    Participants.Next;
  end;

end;

function TDbController.GetSales: TSales;
begin
  Sales.DisableControls;
  try
    Sales.Open;
    Sales.First;

    Result := TSales.Create;

    while not Sales.Eof do
    begin
      Result.Add(TSale.Create(Sales));

      Sales.Next;
    end;
  finally
    Sales.EnableControls;
  end;
end;

procedure TDbController.SetupConnection;
var
  LFileName: String;
  LIni: TIniFile;
  LParams: TStringlist;

begin
  LFileName := TPath.Combine( TPath.GetLibraryPath, 'server.ini' );

  LIni := TIniFile.Create(LFileName);
  LParams := nil;
  try
    LParams := TStringlist.Create;
    LIni.ReadSectionValues( 'Connection', LParams );
    Connection.Params.Assign( LParams );
    Connection.DriverName := LIni.ReadString('Driver','Name','MySQL');

  finally
    LParams.Free;
    LIni.Free;
  end;
end;

end.
