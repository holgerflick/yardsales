unit uParticipantManager;

interface

uses
  XData.Server.Module,

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
uses
  FireDAC.Comp.Client,
  uFDCustomQueryHelper,
  uDbController,
  uSqlGenerator
  ;


{ TParticipantManager }

class procedure TParticipantManager.AddParticipant(
  ANewParticipant: TNewParticipant);
var
  LQuery: TFDQuery;

begin
  LQuery := TDbController.Shared.GetQuery;
  try
    TSqlGenerator.AddParticipantQuery( LQuery, ANewParticipant );
    TXDataOperationContext.Current.Response.StatusCode := 204;
  finally
    LQuery.ReturnToPool;
  end;
end;

class procedure TParticipantManager.DeleteParticipant;
var
  LQuery: TFDQuery;

begin
  LQuery := TDbController.Shared.GetQuery;
  try
    LQuery.ExecSQL;
  finally
    LQuery.ReturnToPool;
  end;
end;

class procedure TParticipantManager.UpdateParticipant(
  AParticipant: TUpdateParticipant);
begin

end;

end.
