unit uYardSaleClientTypes;

interface

uses
  System.Generics.Collections,

  Web,
  JS
  ;

type
  TItemCategorySortOrder = (soName, soUsage);

  TItemCategory = class
  private
    FName: String;
    FId: Integer;
    function GetAsJsObject: TJsObject;
  public
    property AsJsObject: TJsObject read GetAsJsObject;

    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
  end;

  TItemCategories = TObjectList<TItemCategory>;

  TParticipantCategory = class(TItemCategory)
  private

    FComment: String;
  public
    property Comment: String read FComment write FComment;
  end;

  TParticipantCategories = TObjectList<TParticipantCategory>;

  TYardSaleDetails = class
  private
    FEventStart: TDateTime;
    FEventEnd: TDateTime;
    FTitle: String;
    FLogoDataUrl: String;
  public
    property Title: String read FTitle write FTitle;
    property EventStart: TDateTime read FEventStart write FEventStart;
    property EventEnd: TDateTime read FEventEnd write FEventEnd;
    property LogoDataUrl: String read FLogoDataUrl write FLogoDataUrl;
  end;

  TParticipantCore = class
  private
    FName: String;
    FStreet: String;
    FState: String;
    FZip: String;
    FCity: String;

    function GetAsJSObject: TJSObject; virtual;

  public
    property Name: String read FName write FName;
    property Street: String read FStreet write FStreet;
    property Zip: String read FZip write FZip;
    property City: String read FCity write FCity;
    property State: String read FState write FState;

    property AsJSObject: TJSObject read GetAsJSObject;
  end;

  TUpdateParticipant = class
  private
    FParticipant: TParticipantCore;
    FCategories: TParticipantCategories;

    function GetAsJSObject: TJSObject; virtual;

  public
    constructor Create;
    destructor Destroy; override;

    property AsJsObject: TJSObject read GetAsJSObject;

    property Participant: TParticipantCore read FParticipant write FParticipant;
    property Categories: TParticipantCategories read FCategories write FCategories;
  end;

  TNewParticipant = class( TUpdateParticipant )
  private
    FEmail: String;
    FSaleId: Integer;

    function GetAsJSObject: TJSObject; override;
  public
    property SaleId: Integer read FSaleId write FSaleId;
    property Email: String read FEmail write FEmail;
  end;


implementation

{ TUpdateParticipant }

constructor TUpdateParticipant.Create;
begin
  FParticipant := TParticipantCore.Create;
  FCategories := TParticipantCategories.Create
end;

destructor TUpdateParticipant.Destroy;
begin
  FParticipant.Free;
  FCategories.Free;

  inherited;
end;

function TUpdateParticipant.GetAsJSObject: TJSObject;
var
  c: Integer;
  LArray: TJSArray;
begin
  Result := TJSObject.new;
  Result['Participant'] := self.Participant.AsJSObject;

  LArray := TJSArray.new( self.Categories.Count );
  for c := 0 to self.Categories.Count-1 do
  begin
    LArray[c] := self.Categories[c].AsJsObject;
  end;

  Result['Categories'] := LArray;
end;

{ TParticipantCore }

function TParticipantCore.GetAsJSObject: TJSObject;
begin
  Result := TJSObject.new;

  Result['Name'] := self.Name;
  Result['Street'] := self.Street;
  Result['Zip'] := self.Zip;
  Result['City'] := self.City;
  Result['State'] := self.State;
end;

{ TItemCategory }

function TItemCategory.GetAsJsObject: TJsObject;
begin
  Result := TJSObject.new;

  Result['Id'] := self.Id;
  Result['Name'] := self.Name;
end;


{ TNewParticipant }

function TNewParticipant.GetAsJSObject: TJSObject;
begin
  Result := inherited;

  Result['Email'] := self.Email;
  Result['SaleId'] := self.SaleId;
end;

end.
