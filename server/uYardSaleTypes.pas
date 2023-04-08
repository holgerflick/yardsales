unit uYardSaleTypes;

interface
uses
  System.Generics.Collections
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
    FCategories: TCategories;
  public
    constructor Create;
    destructor Destroy; override;

    property Participant: TParticipantCore read FParticipant write FParticipant;
    property Categories: TCategories read FCategories write FCategories;
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


implementation

{ TUpdateParticipant }

constructor TUpdateParticipant.Create;
begin
  FParticipant := TParticipantCore.Create;
  FCategories := TCategories.Create;
end;

destructor TUpdateParticipant.Destroy;
begin
  FCategories.Free;
  FParticipant.Free;

  inherited;
end;

end.
