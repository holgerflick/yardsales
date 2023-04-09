unit uYardSaleServiceImpl;

interface

uses
  XData.Server.Module,
  XData.Service.Common,

  uYardSaleTypes,
  uYardSaleService;

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
begin
  TLoginManager.ParticipantOnly;

end;

function TYardSaleService.GetParticipantCategories(
  ParticipantId: Integer): TParticipantCategories;
begin
  TLoginManager.AdminOnly;

end;

function TYardSaleService.GetParticipants(
  SaleId: Integer): TDetailedParticipants;
begin
  TLoginManager.AdminOnly;
end;

function TYardSaleService.GetYardSales: TYardSales;
var
  LManager: TAdminManager;

begin
  TLoginManager.AdminOnly;


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
end;

initialization
  RegisterServiceType(TYardSaleService);

end.
