unit uYardSaleTypes;

interface
uses
  System.Generics.Collections,

  Bcl.Json.Attributes,

  System.Classes,
  System.DateUtils,
  System.SysUtils,

  Vcl.Imaging.jpeg
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
    FLogo: TBytes;
    FTitle: String;
    function GetEventEndEpoch: Integer;
    function GetEventStartEpoch: Integer;
  public
    property Id: Integer read FId write FId;

    property Title: String read FTitle write FTitle;
    property EventStart: TDateTime read FEventStart write FEventStart;
    property EventEnd: TDateTime read FEventEnd write FEventEnd;

    property Logo: TBytes read FLogo write FLogo;

    [JsonProperty]
    property EventStartEpoch: Integer read GetEventStartEpoch;

    [JsonProperty]
    property EventEndEpoch: Integer read GetEventEndEpoch;
  end;

  TYardSales = TObjectList<TYardSale>;

  TImageOperations = class
    class function ResizeImage(AData: TBytes; AWidth: Integer = 500): TBytes; static;
  end;

implementation

uses
  Gr32, Gr32_Resamplers,
  Graphics;

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

{ TImageOperations }

class function TImageOperations.ResizeImage(AData: TBytes;
  AWidth: Integer = 500): TBytes;
var
  LStream: TBytesStream;

  LJpeg: TJpegImage;
  LImage: TBitmap32;

  LTmpBitmap: TBitmap;
  LNew: TBitmap32;

  LResampler: TKernelResampler;

  LHeight: Integer;
begin
  LJpeg := nil;
  LImage := nil;
  LResampler := nil;
  LNew := nil;
  LTmpBitmap := nil;

  // read image data into stream
  LStream := TBytesStream.Create( AData );
  try
    // load jpeg into Bitmap32
    LImage := TBitmap32.Create;
    LImage.LoadFromStream(LStream);

    // calculate new height
    LHeight := trunc( LImage.Height / ( LImage.Width / AWidth ) );

    // create new bitmap32 for thumbnail
    LNew := TBitmap32.Create( AWidth, LHeight );

    // use lanczos kernel for resizing
    LResampler := TKernelResampler.Create;
    LResampler.Kernel := TLanczosKernel.Create;

    // helper variables for rect
    var LNewRect := Rect( 0,0, AWidth, LHeight );
    var LOrigRect := Rect( 0,0, LImage.Width, LImage.Height );

    // resize the image by drawing it onto the new image canvas
    // using resampler
    LResampler.Resample( LNew, LNewRect, LNewRect,
      LImage, LOrigRect,TDrawMode.dmOpaque, nil);

    // create a new bitmap to load into TJpegImage
    LTmpBitmap := TBitmap.Create;
    LTmpBitmap.Assign(LNew);

    // create new jpeg
    LJpeg := TJpegImage.Create;
    LJpeg.Assign( LTmpBitmap );
    LJpeg.CompressionQuality := 90;
    LJpeg.Compress;

    // save jpeg to stream
    LStream.Clear;
    LJpeg.SaveToStream(LStream);

    // return bytes
    Result := LStream.Bytes;
  finally
    LNew.Free;
    LResampler.Free;  // will also cleanup kernel instance
    LTmpBitmap.Free;
    LJpeg.Free;
    LImage.Free;
    LStream.Free;
  end;
end;

end.
