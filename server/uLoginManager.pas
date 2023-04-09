unit uLoginManager;

interface

uses
  XData.Server.Module,

  Bcl.Jose.Core.Builder,
  Bcl.Jose.Core.JWT,

  uYardSaleTypes
  ;

type
  TLoginManager = class
  private
   function GetBaseJwt: TJWT;

   function GetJwtParticipant(
      ASaleId: Integer;
      AEmail: String): String;

    function GetJwtAdmin: String;

  public
    function LoginParticipant( ASaleId: Integer; AEmail: String ): TLoginResponse;
    function LoginAdmin( ALogin, APassword: String ): TLoginResponse;

    class function GetEmailFromToken: String;
    class function GetSaleIdFromToken: Integer;

    class procedure AdminOnly( AValue: Boolean = true );
    class procedure ParticipantOnly;
  end;

implementation
uses
  System.DateUtils,

  XData.Sys.Exceptions,

  Sparkle.Security,

  FireDAC.Comp.Client,

  uFDCustomQueryHelper,
  uServerSettings,

  uDbController,
  uSqlGenerator

  ;

{ TLoginManager }



class procedure TLoginManager.AdminOnly(AValue: Boolean);
var
  LUser: IUserIdentity;
  LText: String;

begin
  LUser := TXDataOperationContext.Current.Request.User;

  if Assigned( LUser ) then
  begin
    if LUser.Claims.Exists('admin') then
    begin
      if LUser.Claims['admin'].AsBoolean = AValue then
      begin
        Exit;
      end;
    end;
  end;

  LText := 'Only ';
  if AValue then
  begin
     LText := LText + 'administrators ';
  end
  else
  begin
    LText := LText + 'participants ';
  end;

  LText := LText + 'can access this endpoint';

  // we are still here that means conditions are not met
  raise EXDataHttpUnauthorized.Create(LText);
end;

function TLoginManager.GetBaseJwt: TJWT;
begin
  Result := TJWT.Create;

  Result.Claims.IssuedAt := TDateTime.NowUtc;
  Result.Claims.Expiration := TDateTime.NowUTC.IncDay(1);
  Result.Claims.Issuer := 'YardSale Issuer';
end;

class function TLoginManager.GetEmailFromToken: String;
begin
  Result := '';
  if TXDataOperationContext.Current.Request.User.Claims.Exists('email') then
  begin
    Result := TXDataOperationContext.Current.Request.User.Claims['email'].AsString
  end;
end;

class function TLoginManager.GetSaleIdFromToken: Integer;
begin
  Result := -1;
  if TXDataOperationContext.Current.Request.User.Claims.Exists('saleid') then
  begin
    Result := TXDataOperationContext.Current.Request.User.Claims['saleid'].AsInteger
  end;
end;

function TLoginManager.GetJwtAdmin: String;
var
  LToken: TJWT;

begin
  LToken := GetBaseJwt;
  try
    LToken.Claims.SetClaimOfType<Boolean>( 'admin', True );

    Result := TJOSE.SHA256CompactToken(
        TServerSettings.Shared.JWTSecret,
        LToken
      );
  finally
    LToken.Free;
  end;

end;

function TLoginManager.GetJwtParticipant(ASaleId: Integer;
  AEmail: String): String;
var
  LToken: TJWT;

begin
  LToken := GetBaseJwt;
  try
    LToken.Claims.SetClaimOfType<string>( 'email', AEmail );
    LToken.Claims.SetClaimOfType<integer>( 'saleid', ASaleId );
    LToken.Claims.SetClaimOfType<Boolean>( 'admin', False );

    Result := TJOSE.SHA256CompactToken(
        TServerSettings.Shared.JWTSecret,
        LToken
      );
  finally
    LToken.Free;
  end;
end;


function TLoginManager.LoginAdmin(ALogin,
  APassword: String): TLoginResponse;
var
  LQuery: TFDQuery;

begin
  // create response object and hand it over to XData
  Result := TLoginResponse.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add( Result );

  LQuery := TDbController.Shared.GetQuery;
  try
    if TSqlGenerator.LoginAdminQuery( LQuery, ALogin, APassword ) then
    begin
      Result.Token := GetJwtAdmin;
    end;
  finally
    LQuery.ReturnToPool;
  end;
end;

function TLoginManager.LoginParticipant(
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
    if TSqlGenerator.LoginParticipantQuery( LQuery, ASaleId, AEmail ) then
    begin
      // generate token
      Result.Token := GetJwtParticipant( ASaleId, AEmail );
    end;

  finally
    LQuery.ReturnToPool;
  end;
end;

class procedure TLoginManager.ParticipantOnly;
begin
  AdminOnly(False);
end;

end.
