unit uParticipantManager;

interface

uses
  XData.Server.Module,

  uYardSaleTypes
  ;

type
  TParticipantManager = class
  public
    procedure AddParticipant( ANewParticipant: TNewParticipant );
    procedure UpdateParticipant( AParticipant: TUpdateParticipant );
    procedure DeleteParticipant;

    function ItemCategories: TItemCategories;

  end;

implementation
uses
  System.SysUtils,

  FireDAC.Comp.Client,
  uFDCustomQueryHelper,
  uDbController,
  uParticipantSqlManager
  ;


{ TParticipantManager }

procedure TParticipantManager.AddParticipant(
  ANewParticipant: TNewParticipant);
var
  LQuery: TFDQuery;

begin
  LQuery := TDbController.Shared.GetQuery;
  try
    TParticipantSqlManager.AddParticipantQuery( LQuery, ANewParticipant );
    TXDataOperationContext.Current.Response.StatusCode := 204;
  finally
    LQuery.ReturnToPool;
  end;
end;

procedure TParticipantManager.DeleteParticipant;
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

function TParticipantManager.ItemCategories: TItemCategories;
var
  LQuery: TFDQuery;

begin
  Result := TItemCategories.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add(Result);

  LQuery := TDbController.Shared.GetQuery;
  try
    TParticipantSqlManager.ItemCategories( LQuery );

    LQuery.Open;

    while not LQuery.Eof do
    begin
      var LItem := TItemCategory.Create;
      LItem.Id := LQuery.FieldByName('Id').AsInteger;
      LItem.Name := LQuery.FieldByName('Name').AsString;

      Result.Add(LItem);

      LQuery.Next;
    end;

  finally
    LQuery.ReturnToPool;
  end;
end;

procedure TParticipantManager.UpdateParticipant(
  AParticipant: TUpdateParticipant);
begin
  raise ENotImplemented.Create('Not implemented');
end;

end.
