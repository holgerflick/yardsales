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
  end;

implementation

uses
  uLoginManager
  ;

{ TAdminSqlManager }

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
