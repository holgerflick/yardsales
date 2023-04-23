unit uBitmapTools;

interface
uses
   System.SysUtils
   ;

type
  TBitmapTools = class
  type
    TFixedDimension = ( fdWidth, fdHeight );

    class function Resize(
      AData: TBytes;
      AFixedValue: Integer = 900;
      AFixedDimension: TFixedDimension = fdWidth
      ): TBytes;
  end;

implementation
uses
  Vcl.Graphics,
  Vcl.Imaging.jpeg,

  System.Classes,

  Gr32,
  Gr32_Resamplers,
  GR32.ImageFormats
  ;

{ TBitmapTools }

class function TBitmapTools.Resize(AData: TBytes; AFixedValue: Integer; AFixedDimension: TFixedDimension): TBytes;
var
  LStream: TBytesStream;

  LJpeg: TJpegImage;
  LImage: TBitmap32;

  LTmpBitmap: TBitmap;
  LNew: TBitmap32;

  LResampler: TKernelResampler;

  LHeight: Integer;
  LWidth: Integer;

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
    if AFixedDimension = fdWidth then
    begin
      LHeight := trunc( LImage.Height / ( LImage.Width / AFixedValue ) );
      LWidth := AFixedValue;
    end
    else
    begin
      LHeight := AFixedValue;
      LWidth := trunc( LImage.Width / ( LImage.Height / AFixedValue ) );
    end;

    // create new bitmap32 for thumbnail
    LNew := TBitmap32.Create( LWidth, LHeight );

    // we use bicubic kernel for good performance/quality ratio
    LResampler := TKernelResampler.Create;

    LResampler.Kernel := TCubicKernel.Create;  //   TLanczosKernel.Create;

    LImage.Resampler := LResampler;

    //
    LImage.DrawTo( LNew,  Rect( 0,0, LWidth, LHeight ) );

    // save jpeg to stream
    LStream.Clear;

    // create new JPEG image
    LJpeg := TJpegImage.Create;

    // assign bitmap32
    LJpeg.Assign(LNew);

    // compress
    LJpeg.CompressionQuality := 90;
    LJpeg.Compress;

    // save
    LJPeg.SaveToStream(LStream);

    // return bytes
    Result := LStream.Bytes;
  finally
    LNew.Free;
    LTmpBitmap.Free;
    LJpeg.Free;
    LImage.Free;
    LStream.Free;
  end;
end;


end.
