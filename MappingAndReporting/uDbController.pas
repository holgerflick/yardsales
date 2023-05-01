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
  TDbModel = class(TDataModule)
    Connection: TFDConnection;
    Sales: TFDQuery;
    Participants: TFDQuery;
    ParticipantCategories: TFDQuery;
    sourceParticipants: TDataSource;
    ParticipantLocations: TFDQuery;
    NeedLocation: TFDQuery;
    UpdateLocation: TFDQuery;
    SalesEventDates: TStringField;
    ParticipantsCategories: TStringField;
    SalesId: TFDAutoIncField;
    SalesEventStart: TDateTimeField;
    SalesEventEnd: TDateTimeField;
    SalesTitle: TWideStringField;
    SalesLogo: TBlobField;
    SalesThumb: TBlobField;
    ParticipantsId: TFDAutoIncField;
    ParticipantsEmail: TWideStringField;
    ParticipantsSalesId: TLongWordField;
    ParticipantsName: TWideStringField;
    ParticipantsStreet: TWideStringField;
    ParticipantsZip: TWideStringField;
    ParticipantsCity: TWideStringField;
    ParticipantsState: TWideStringField;
    ParticipantsMapUrl: TWideStringField;
    ParticipantsLongitude: TFloatField;
    ParticipantsLatitude: TFloatField;
    ParticipantsCreated: TDateTimeField;
    ParticipantsAddress: TStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure ParticipantsCalcFields(DataSet: TDataSet);
    procedure SalesCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
    procedure SetupConnection;
  public
    { Public declarations }

    procedure MoveToSalesId( ASalesId: Integer );

    function GetSales: TSales;
    function GetParticipants( ASalesId: Integer ): TParticipants;
    function GetNeedLocations( ASalesId: Integer ): TNeedLocations;

    // called when location is updated
    procedure OnUpdateLocation( Sender: TObject );


  end;

implementation
uses
  System.IOUtils,
  System.IniFiles
  ;


{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDbModel.DataModuleCreate(Sender: TObject);
begin
  SetupConnection;
end;

function TDbModel.GetNeedLocations(ASalesId: Integer): TNeedLocations;
var
  LNeedLocation: TNeedLocation;
begin
  NeedLocation.Close;
  NeedLocation.ParamByName('SalesId').AsInteger := ASalesId;
  NeedLocation.Open;

  Result := TNeedLocations.Create;

  while not NeedLocation.Eof do
  begin
    LNeedLocation := TNeedLocation.Create( NeedLocation );
    LNeedLocation.Location.OnUpdateLocation := self.OnUpdateLocation;
    Result.Add( LNeedLocation );

    NeedLocation.Next;
  end;
end;

function TDbModel.GetParticipants(ASalesId: Integer): TParticipants;
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

function TDbModel.GetSales: TSales;
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

procedure TDbModel.MoveToSalesId(ASalesId: Integer);
begin
  Sales.Locate( 'Id', ASalesId, [] );
end;

procedure TDbModel.OnUpdateLocation(Sender: TObject);
var
  LLocation: TNeedLocation;
  LQuery: TFDQuery;

begin
  LLocation := TNeedLocation( Sender );

  LQuery := UpdateLocation;
  TMonitor.Enter( LQuery );
  try
    LQuery.ParamByName('Id').AsInteger := LLocation.Id;
    LQuery.ParamByName('Latitude').AsFloat := LLocation.Location.Latitude;
    LQuery.ParamByName('Longitude').AsFloat := LLocation.Location.Longitude;
    LQuery.ExecSQL;
  finally
    TMonitor.Exit(LQuery);
  end;
end;

procedure TDbModel.ParticipantsCalcFields(DataSet: TDataSet);
var
  LBuffer: String;
  LBookmark: TBookmark;

begin
   Dataset.FieldByName('Address').AsString :=
        Dataset.FieldByName('Street').AsString + ', ' +
        Dataset.FieldByName('City').AsString;

  Dataset.FieldByName('Categories').AsString := '';

  LBookmark := ParticipantCategories.GetBookmark;
  try
    ParticipantCategories.First;
    while not ParticipantCategories.Eof do
    begin
      if not LBuffer.IsEmpty then
      begin
        LBuffer := LBuffer + ', ';
      end;

      LBuffer := LBuffer + ParticipantCategories.FieldByName('Name').AsString;

      ParticipantCategories.Next;
    end;

    DataSet.FieldByName('Categories').AsString := LBuffer;


    ParticipantCategories.GotoBookmark(LBookmark);
  finally
    ParticipantCategories.FreeBookmark(LBookmark);
  end;

end;

procedure TDbModel.SalesCalcFields(DataSet: TDataSet);
var
  LBuffer: String;

begin
  LBuffer := FormatDateTime(
    'mmmm d, yyyy (ham/pm to ',
    DataSet.FieldByName('EventStart').AsDateTime );
  LBuffer := LBuffer + FormatDateTime(
    'ham/pm)',
    DataSet.FieldByName('EventEnd').AsDateTime );

  DataSet.FieldByName('EventDates').AsString := LBuffer;
end;

procedure TDbModel.SetupConnection;
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
