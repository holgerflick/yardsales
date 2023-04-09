unit uYardSaleTypes;

interface
uses
  System.Generics.Collections,

  Bcl.Json.Attributes,

  System.DateUtils
  ;

type
  TLoginResponse = class
  private
    FToken: String;
  public
    property Token: String read FToken write FToken;
  end;

  TCategory = class
  private
    FName: String;
    FId: Integer;
  public
    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
  end;

  TCategories = TObjectList<TCategory>;

  TParticipantCategory = class
  private
    FId: Integer;
    FComment: String;
  public
    property Id: Integer read FId write FId;
    property Comment: String read FComment write FComment;
  end;

  TParticipantCategories = TObjectList<TParticipantCategory>;

  TParticipantCore = class
  private
    FName: String;
    FStreet: String;
    FState: String;
    FZip: String;
    FCity: String;

  public
    property Name: String read FName write FName;
    property Street: String read FStreet write FStreet;
    property Zip: String read FZip write FZip;
    property City: String read FCity write FCity;
    property State: String read FState write FState;

  end;

  TUpdateParticipant = class
  private
    FParticipant: TParticipantCore;
    FCategories: TParticipantCategories;
  public
    constructor Create;
    destructor Destroy; override;

    property Participant: TParticipantCore read FParticipant write FParticipant;
    property Categories: TParticipantCategories read FCategories write FCategories;
  end;

  TNewParticipant = class( TUpdateParticipant )
  private
    FEmail: String;
    FSaleId: Integer;

  public
    property SaleId: Integer read FSaleId write FSaleId;
    property Email: String read FEmail write FEmail;
  end;


  TDetailedParticipant = class( TParticipantCore )
  private
    FMapUrl: String;
  public
    property MapUrl: String read FMapUrl write FMapUrl;
  end;

  TDetailedParticipants = TObjectList<TDetailedParticipant>;


  TYardSale = class
  private
    FId: Integer;
    FEventStart: TDateTime;
    FEventEnd: TDateTime;
    function GetEventEndEpoch: Integer;
    function GetEventStartEpoch: Integer;
  public
    property Id: Integer read FId write FId;
    property EventStart: TDateTime read FEventStart write FEventStart;
    property EventEnd: TDateTime read FEventEnd write FEventEnd;

    [JsonProperty]
    property EventStartEpoch: Integer read GetEventStartEpoch;

    [JsonProperty]
    property EventEndEpoch: Integer read GetEventEndEpoch;
  end;

  TYardSales = TObjectList<TYardSale>;

implementation

{ TUpdateParticipant }

constructor TUpdateParticipant.Create;
begin
  FParticipant := TParticipantCore.Create;
  FCategories := TParticipantCategories.Create;
end;

destructor TUpdateParticipant.Destroy;
begin
  FCategories.Free;
  FParticipant.Free;

  inherited;
end;

{ TYardSale }

function TYardSale.GetEventEndEpoch: Integer;
begin
  Result := EventEnd.ToUnix;
end;

function TYardSale.GetEventStartEpoch: Integer;
begin
  Result := EventStart.ToUnix;
end;

end.
