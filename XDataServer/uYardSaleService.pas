unit uYardSaleService;

interface

uses
  XData.Security.Attributes,
  XData.Service.Common,
  uYardSaleTypes,

  System.Classes,
  System.SysUtils

  ;

type
  [ServiceContract]
  IYardSaleService = interface(IInvokable)
    ['{7E7BEBC9-2BE3-425E-A579-590C3BE884A0}']

    function LoginAdmin( Login, Password: String ): TLoginResponse;
    function LoginParticipant( SaleId: Integer; Email, Name, Zip : String ): TLoginResponse;

    procedure AddParticipant( NewParticipant: TNewParticipant );
    function GetYardSale( SaleId: Integer ): TYardSale;

    // --- Participant operations

    [Authorize]
    procedure UpdateParticipant( Participant: TUpdateParticipant );

    [Authorize]
    procedure DeleteParticipant;

    function ItemCategories( SortOrder:TItemCategorySortOrder ) : TItemCategories;

    // --- Admin operations

    [Authorize]
    function GetYardSales: TYardSales;

    [Authorize]
    function GetYardSaleLogo(
      SaleId: Integer;
      Width, Height: Integer ): TBytes;

    [Authorize]
    function GetParticipants( SaleId: Integer ): TDetailedParticipants;

    [Authorize]
    function GetParticipantCategories(
      ParticipantId: Integer ): TParticipantCategories;
  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IYardSaleService));

end.
