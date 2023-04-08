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
    function Login( SaleId: Integer; Email : String ): TLoginResponse;

    procedure AddParticipant( NewParticipant: TNewParticipant );
    procedure UpdateParticipant( Participant: TUpdateParticipant );
    procedure DeleteParticipant;

  end;

implementation

uses
  uLoginManager,
  uParticipantManager
  ;


{ TYardSaleService }

procedure TYardSaleService.AddParticipant(NewParticipant: TNewParticipant);
begin

end;

procedure TYardSaleService.DeleteParticipant;
begin

end;

function TYardSaleService.Login(SaleId: Integer; Email: String): TLoginResponse;
var
  LManager: TLoginManager;

begin
  LManager := TLoginManager.Create;
  try
    Result := LManager.Login( SaleId, Email );
  finally
    LManager.Free;
  end;
end;

procedure TYardSaleService.UpdateParticipant(Participant: TUpdateParticipant);
begin

end;

initialization
  RegisterServiceType(TYardSaleService);

end.
