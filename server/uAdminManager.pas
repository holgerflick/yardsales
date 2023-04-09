unit uAdminManager;

interface

uses
  System.SysUtils,

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

uses
  FireDAC.Comp.Client,
  uFDCustomQueryHelper,
  uAdminSqlManager

  ;

{ TAdminManager }

function TAdminManager.GetParticipantCategories(
  AParticipantId: Integer): TParticipantCategories;
begin
  raise ENotImplemented.Create('Not implemented.');
end;

function TAdminManager.GetParticipants(ASaleId: Integer): TDetailedParticipants;
begin
  raise ENotImplemented.Create('Not implemented.');
end;

function TAdminManager.GetYardSales: TYardSales;
var
  LQuery: TFDQuery;

begin
  Result := TYardSales.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add(Result);

  LQuery := TDbController.Shared.GetQuery;
  try
    TAdminSqlManager.GetYardSalesQuery(LQuery);

    LQuery.Open;
    while not LQuery.Eof do
    begin
      var LSale := TYardSale.Create;
      LSale.Id := LQuery.FieldByName('Id').AsInteger;
      LSale.EventStart := LQuery.FieldByName('EventStart').AsDateTime;
      LSale.EventEnd := LQuery.FieldByName('EventEnd').AsDateTime;
      LSale.Title := LQuery.FieldByName('title').AsString;



      LSale.Logo := TImageOperations.ResizeImage(
        LQuery.FieldByName('logo').AsBytes );

      Result.Add( LSale );
      LQuery.Next;
    end;
  finally
    LQuery.ReturnToPool;
  end;
end;

end.
