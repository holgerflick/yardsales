unit uApiKeyLoader;

interface

uses
  Classes,
  Windows
  ;

type
  TApiKeyLoader = class
  private

  public
    class function GoogleApiKey: String;
  end;


implementation

{ TApiKeyLoader }

class function TApiKeyLoader.GoogleApiKey: String;
var
  LResourceStr: TResourceStream;
  LStringStr: TStringStream;

begin
  LStringStr := nil;
  LResourceStr := TResourceStream.Create( HInstance, 'APIKEY', RT_RCDATA );
  try
    LStringStr := TStringStream.Create;
    LStringStr.CopyFrom( LResourceStr );
    Result := LStringStr.DataString;
  finally
    LResourceStr.Free;
    LStringStr.Free;
  end;
end;

end.

