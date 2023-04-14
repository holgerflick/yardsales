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

    function GetYardSale( ASaleId: Integer ): TYardSale;

    function ItemCategories( ASortOrder: TItemCategorySortOrder ): TItemCategories;

  end;

implementation
uses
  XData.Sys.Exceptions,

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

function TParticipantManager.GetYardSale(ASaleId: Integer): TYardSale;
var
  LQuery: TFDQuery;

begin
  Result := TYardSale.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add(Result);

  LQuery := TDbController.Shared.GetQuery;
  try
    TParticipantSqlManager.YardSale( LQuery, ASaleId );
    LQuery.Open;

    if LQuery.Eof then
    begin
      raise EXDataHttpException.Create(404, 'Yard Sale not found.');
    end;

    Result.Transfer( LQuery );

  finally
    LQuery.ReturnToPool;
  end;
end;

function TParticipantManager.ItemCategories(
  ASortOrder: TItemCategorySortOrder ): TItemCategories;
var
  LQuery: TFDQuery;

begin
  Result := TItemCategories.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add(Result);

  LQuery := TDbController.Shared.GetQuery;
  try
    TParticipantSqlManager.ItemCategories( LQuery, ASortOrder );

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
