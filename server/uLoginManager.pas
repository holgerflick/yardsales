unit uLoginManager;

interface

uses
  XData.Server.Module,

  uYardSaleTypes
  ;

type
  TLoginManager = class
  private
    class function GetJwtToken(ASaleId: Integer; AEmail: String): String;
  public
    class function Login( ASaleId: Integer; AEmail: String ): TLoginResponse;
  end;

implementation
uses
  System.DateUtils,

  FireDAC.Comp.Client,

  uFDCustomQueryHelper,
  uServerSettings,

  uDbController,
  uSqlGenerator,

  Bcl.Jose.Core.Builder,
  Bcl.Jose.Core.JWT

  ;

{ TLoginManager }

class function TLoginManager.GetJwtToken(ASaleId: Integer; AEmail: String): String;
var
  LToken: TJWT;

begin
  LToken := TJWT.Create;
  try
    LToken.Claims.IssuedAt := TDateTime.NowUtc;
    LToken.Claims.Expiration := TDateTime.NowUTC.IncDay(1);
    LToken.Claims.Issuer := 'YardSale Issuer';


    LToken.Claims.SetClaimOfType<string>( 'email', AEmail );
    LToken.Claims.SetClaimOfType<integer>( 'saleid', ASaleId );

    Result := TJOSE.SHA256CompactToken(
        TServerSettings.Shared.JWTSecret,
        LToken
      );
  finally
    LToken.Free;
  end;
end;

class function TLoginManager.Login(
  ASaleId: Integer;
  AEmail: String): TLoginResponse;
var
  LQuery: TFDQuery;

begin
  // create response object and hand it over to XData
  Result := TLoginResponse.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add( Result );

  // check if saleId and email exists
  // TODO: add password or other security token for user to identify/
  //       change verification
  LQuery := TDbController.Shared.GetQuery;
  try
    TSqlGenerator.LoginQuery( LQuery, ASaleId, AEmail );
    LQuery.Open;
    if LQuery.FieldByName('valid').AsInteger = 1 then
    begin
      // generate token
      Result.Token := GetJwtToken( ASaleId, AEmail );
    end;

  finally
    LQuery.ReturnToPool;
  end;

end;

end.
