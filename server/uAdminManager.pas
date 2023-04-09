unit uAdminManager;

interface

uses
  XData.Server.Module,

  uLoginManager,
  uDbController,
  uYardSaleTypes
  ;

type
  TAdminManager = class
  public
    function GetYardSales: TYardSales;
    function GetParticipants( ASaleId: Integer ): TDetailedParticipants;
    function GetParticipantCategories(
      AParticipantId: Integer ): TParticipantCategories;
  end;

implementation

{ TAdminManager }

function TAdminManager.GetParticipantCategories(
  AParticipantId: Integer): TParticipantCategories;
begin

end;

function TAdminManager.GetParticipants(ASaleId: Integer): TDetailedParticipants;
begin

end;

function TAdminManager.GetYardSales: TYardSales;
begin

end;

end.
