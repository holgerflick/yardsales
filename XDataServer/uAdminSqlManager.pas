unit uAdminSqlManager;

interface

uses
  FireDAC.Comp.Client,

  XData.Sys.Exceptions,

  uYardSaleTypes
  ;

type
  TAdminSqlManager = class
  public
    class procedure GetYardSalesQuery( AQuery: TFDQuery );
    class procedure GetYardSaleLogo( AQuery: TFDQuery; ASaleId: Integer );
    class procedure GetParticipantsQuery( AQuery: TFDQuery; ASaleId: Integer );
    class procedure GetParticipantCategoriesQuery( AQuery: TFDQuery;
      AParticipantId: Integer );

  end;

implementation

uses
  uLoginManager
  ;

{ TAdminSqlManager }

class procedure TAdminSqlManager.GetParticipantCategoriesQuery(AQuery: TFDQuery;
  AParticipantId: Integer);
begin
  AQuery.SQL.Text :=
    'SELECT C.ID, C.NAME, P.COMMENT FROM ParticipantItemCategories P '+
    'LEFT JOIN ItemCategories C ON ( C.Id = P.IdCategory ) '+
    'WHERE P.IdParticipant = :Id';
  AQuery.ParamByName('Id').AsInteger := AParticipantId;
end;

class procedure TAdminSqlManager.GetParticipantsQuery(AQuery: TFDQuery;
  ASaleId: Integer);
begin
  AQuery.SQL.Text := 'SELECT * FROM SalesParticipant WHERE SalesId = :Id ' +
    'ORDER BY NAME, CITY, STATE';
  AQuery.ParamByName('Id').AsInteger := ASaleId;
end;

class procedure TAdminSqlManager.GetYardSaleLogo(AQuery: TFDQuery;
  ASaleId: Integer);
begin
  AQuery.SQL.Text := 'SELECT * FROM YardSales WHERE Id = :Id';
  AQuery.ParamByName('Id').AsInteger := ASaleId;
end;

class procedure TAdminSqlManager.GetYardSalesQuery(AQuery: TFDQuery);
begin
  AQuery.SQL.Text := 'SELECT * FROM YardSales ORDER BY EventStart DESC';
end;

end.
