unit uYardSaleServiceImpl;

interface

uses
  System.Classes,
  System.SysUtils,

  XData.Server.Module,
  XData.Service.Common,

  uYardSaleTypes,
  uYardSaleService


  ;

type
  [ServiceImplementation]
  TYardSaleService = class(TInterfacedObject, IYardSaleService)
    function LoginAdmin( Login, Password: String ): TLoginResponse;
    function LoginParticipant( SaleId: Integer; Email : String ): TLoginResponse;

    // --- Participant
    procedure AddParticipant( NewParticipant: TNewParticipant );
    procedure UpdateParticipant( Participant: TUpdateParticipant );
    procedure DeleteParticipant;

    // --- Admin
    function GetYardSales: TYardSales;
    function GetYardSaleLogo( SaleId: Integer; Width, Height: Integer ): TStream;
    function GetParticipants( SaleId: Integer ): TDetailedParticipants;
    function GetParticipantCategories(
      ParticipantId: Integer ): TParticipantCategories;
  end;

implementation

uses
  uAdminManager,
  uLoginManager,
  uParticipantManager

  ;


{ TYardSaleService }

procedure TYardSaleService.AddParticipant(NewParticipant: TNewParticipant);
var
  LManager: TParticipantManager;

begin
  LManager := TParticipantManager.Create;
  try
    LManager.AddParticipant( NewParticipant );
  finally
    LManager.Free;
  end;
end;

procedure TYardSaleService.DeleteParticipant;
var
  LManager: TParticipantManager;

begin
  TLoginManager.ParticipantOnly;

  LManager := TParticipantManager.Create;
  try
    LManager.DeleteParticipant;
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetParticipantCategories(
  ParticipantId: Integer): TParticipantCategories;
begin
  TLoginManager.AdminOnly;

  raise ENotImplemented.Create('Not implemented.');
end;

function TYardSaleService.GetParticipants(
  SaleId: Integer): TDetailedParticipants;
begin
  TLoginManager.AdminOnly;

  raise ENotImplemented.Create('Not implemented.');
end;

function TYardSaleService.GetYardSaleLogo(
  SaleId,
  Width,
  Height: Integer): TStream;

var
  LManager: TAdminManager;

begin
  TLoginManager.AdminOnly;

  LManager := TAdminManager.Create;
  try
    LManager.GetYardSaleLogo( SaleId, Width, Height );
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetYardSales: TYardSales;
var
  LManager: TAdminManager;

begin
  TLoginManager.AdminOnly;

  LManager := TAdminManager.Create;
  try
    Result := LManager.GetYardSales;
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.LoginAdmin(Login, Password: String): TLoginResponse;
var
  LManager: TLoginManager;

begin
  LManager := TLoginManager.Create;
  try
    Result := LManager.LoginAdmin( Login, Password );
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.LoginParticipant(SaleId: Integer; Email: String): TLoginResponse;
var
  LManager: TLoginManager;

begin
  LManager := TLoginManager.Create;
  try
    Result := LManager.LoginParticipant( SaleId, Email );
  finally
    LManager.Free;
  end;
end;

procedure TYardSaleService.UpdateParticipant(Participant: TUpdateParticipant);
begin
  TLoginManager.ParticipantOnly;

  raise ENotImplemented.Create('Not implemented.');
end;

initialization
  RegisterServiceType(TYardSaleService);

end.
