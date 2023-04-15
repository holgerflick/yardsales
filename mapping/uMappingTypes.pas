unit uMappingTypes;

interface
uses
  System.Classes,
  System.Generics.Collections,

  DB

  ;
type
  TSale = class
  private
    FId: Integer;
    FTitle: String;
    FEventStart: TDateTime;
    FEventEnd: TDateTime;

  public
    constructor Create( ADataset: TDataset );
    procedure TransferFrom( ADataset: TDataset );

    property Id: Integer read FId write FId;
    property Title: String read FTitle write FTitle;
    property EventStart: TDateTime read FEventStart write FEventStart;
    property EventEnd: TDateTime read FEventEnd write FEventEnd;
  end;

  TSales = TObjectList<TSale>;

  TLocation = class
  private
    FLatitude,
    FLongitude: Double;
    FOnUpdateLocation: TNotifyEvent;

    FOwner: TObject;
  public
    constructor Create( AOwner: TObject );


    procedure UpdateLocation( ALatitude, ALongitude: Double );

    property Owner: TObject read FOwner;
    property Latitude: Double read FLatitude;
    property Longitude: Double read FLongitude;

    property OnUpdateLocation: TNotifyEvent
      read FOnUpdateLocation write FOnUpdateLocation;

  end;

  TParticipant = class
  private
    FId: Integer;
    FEmail: String;
    FName: String;
    FStreet: String;
    FZip: String;
    FCity: String;
    FState: String;
    FCategories: String;
    FLocation: TLocation;
  public
    constructor Create( AParticipants, ACategories: TDataset );
    destructor Destroy; override;

    procedure TransferFrom( AParticipants, ACategories: TDataset );

    property Id: Integer read FId write FId;
    property Email: String read FEmail write FEmail;
    property Name: String read FName write FName;
    property Street: String read FStreet write FStreet;
    property Zip: String read FZip write FZip;
    property City: String read FCity write FCity;
    property State: String read FState write FState;

    property Categories: String read FCategories write FCategories;
    property Location: TLocation read FLocation write FLocation;
  end;

  TParticipants = TObjectList<TParticipant>;

  TNeedLocation = class
  private
    FId: Integer;
    FAddress: String;
    FLocation: TLocation;

  public
    constructor Create( ADataset: TDataset );
    destructor Destroy; override;

    procedure TransferFrom( ADataset: TDataset );

    property Id: Integer read FId write FId;
    property Address: String read FAddress write FAddress;
    property Location: TLocation read FLocation;
  end;

  TNeedLocations = TObjectList<TNeedLocation>;

implementation

uses
  System.SysUtils,
  System.DateUtils

  ;

{ TSale }

constructor TSale.Create(ADataset: TDataset);
begin
  if Assigned( ADataset ) then
  begin
    TransferFrom( ADataset );
  end;
end;

procedure TSale.TransferFrom(ADataset: TDataset);
begin
  self.Id := ADataset.FieldByName('Id').AsInteger;
  self.Title := ADataset.FieldByName('Title').AsString;
  self.EventStart :=
    TTimeZone.Local.ToLocalTime(
      ADataset.FieldByName('EventStart').AsDateTime
    );
  self.EventEnd :=
    TTimeZone.Local.ToLocalTime(
      ADataset.FieldByName('EventEnd').AsDateTime
    );

end;

{ TParticipant }

constructor TParticipant.Create( AParticipants, ACategories: TDataset );
begin
  FLocation := nil;

  if Assigned(AParticipants) and Assigned(ACategories)  then
  begin
    TransferFrom( AParticipants, ACategories );
  end;
end;


destructor TParticipant.Destroy;
begin
  FLocation.Free;

  inherited;
end;

procedure TParticipant.TransferFrom( AParticipants, ACategories: TDataset );
  function GetCategories( ADataset: TDataset ): String;
  begin
    Result := '';

    ADataset.First;
    while not ADataset.Eof do
    begin
      if Result <> '' then
      begin
        Result := Result + ', ';
      end;

      Result := Result + ADataset.FieldByName('Name').AsString;

      ADataset.Next;
    end;
  end;

begin
  self.Id := AParticipants.FieldByName('Id').AsInteger;
  self.Email := AParticipants.FieldByName('Email').AsString;
  self.Name := AParticipants.FieldByName('Name').AsString;
  self.Street := AParticipants.FieldByName('Street').AsString;
  self.Zip := AParticipants.FieldByName('Zip').AsString;
  self.City := AParticipants.FieldByName('City').AsString;
  self.State := AParticipants.FieldByName('State').AsString;

  if not AParticipants.FieldByName('Latitude').IsNull then
  begin
    Location := TLocation.Create(self);

    Location.UpdateLocation(
      AParticipants.FieldByName('Latitude').AsFloat,
      AParticipants.FieldByName('Longitude').AsFloat
    );
  end;

  self.Categories := GetCategories( ACategories );
end;

{ TNeedLocation }

constructor TNeedLocation.Create( ADataset: TDataset );
begin
  FLocation := TLocation.Create(self);

  if Assigned( ADataset ) then
  begin
    TransferFrom(ADataset)
  end;
end;

destructor TNeedLocation.Destroy;
begin
  FLocation.Free;

  inherited;
end;

procedure TNeedLocation.TransferFrom(ADataset: TDataset);
begin
  self.Id := ADataset.FieldByName('Id').AsInteger;
  self.Address := ADataset.FieldByName('Address').AsString;
end;

{ TLocation }

constructor TLocation.Create(AOwner: TObject);
begin
  FOnUpdateLocation := nil;
  FOwner := AOwner;
end;

procedure TLocation.UpdateLocation(ALatitude, ALongitude: Double);
begin
  FLatitude := ALatitude;
  FLongitude := ALongitude;

  if Assigned( FOnUpdateLocation ) then
  begin
    FOnUpdateLocation( self.Owner );
  end;
end;

end.
