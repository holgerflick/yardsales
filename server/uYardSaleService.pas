unit uYardSaleService;

interface

uses
  XData.Security.Attributes,
  XData.Service.Common,
  uYardSaleTypes

  ;

type
  [ServiceContract]
  IYardSaleService = interface(IInvokable)
    ['{7E7BEBC9-2BE3-425E-A579-590C3BE884A0}']

    function Login( SaleId: Integer; Email : String ): TLoginResponse;

    [Authorize]
    procedure AddParticipant( NewParticipant: TNewParticipant );

    [Authorize]
    procedure UpdateParticipant( Participant: TUpdateParticipant );

    [Authorize]
    procedure DeleteParticipant;
  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IYardSaleService));

end.
