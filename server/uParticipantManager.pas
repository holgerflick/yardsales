unit uParticipantManager;

interface

uses
  uYardSaleTypes
  ;

type
  TParticipantManager = class
  public
    class procedure AddParticipant( ANewParticipant: TNewParticipant );
    class procedure UpdateParticipant( AParticipant: TUpdateParticipant );
    class procedure DeleteParticipant;

  end;

implementation

{ TParticipantManager }

class procedure TParticipantManager.AddParticipant(
  ANewParticipant: TNewParticipant);
begin

end;

class procedure TParticipantManager.DeleteParticipant;
begin

end;

class procedure TParticipantManager.UpdateParticipant(
  AParticipant: TUpdateParticipant);
begin

end;

end.
