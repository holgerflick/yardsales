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
  uAdminSqlManager,
  Classes,
  DB

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
  LThumb: TBytes;

begin
  Result := TYardSales.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add(Result);

  LQuery := TDbController.Shared.GetQuery;
  try
    // get SQL query
    TAdminSqlManager.GetYardSalesQuery(LQuery);

    // open query
    LQuery.Open;

    // iterate all records
    while not LQuery.Eof do
    begin
      var LSale := TYardSale.Create;
      LSale.Id := LQuery.FieldByName('Id').AsInteger;
      LSale.EventStart := LQuery.FieldByName('EventStart').AsDateTime;
      LSale.EventEnd := LQuery.FieldByName('EventEnd').AsDateTime;
      LSale.Title := LQuery.FieldByName('title').AsString;

      // do we have a logo?
      if LQuery.FieldByName('logo').IsNull = False then
      begin
        // thumbnail available?
        if LQuery.FieldByName('thumb').IsNull then
        begin
          // generate thumbnail
          LThumb := TImageOperations.ResizeImage( LQuery.FieldByName('logo').AsBytes );

          // update database
          LQuery.Edit;
          LQuery.FieldByName('thumb').AsBytes := LThumb;
          LQuery.Post;
        end
        else
        begin
          // use thumbnail
          LThumb := LQuery.FieldByName('thumb').AsBytes;
        end;

        // assign thumbnail
        LSale.Logo := LThumb;
      end;

      // add to list
      Result.Add( LSale );

      // move to next record
      LQuery.Next;
    end;
  finally
    LQuery.ReturnToPool;
  end;
end;

end.
