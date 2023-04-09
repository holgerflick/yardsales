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
  end;

implementation

uses
  uLoginManager
  ;

{ TAdminSqlManager }

class procedure TAdminSqlManager.GetYardSalesQuery(AQuery: TFDQuery);
begin
  AQuery.SQL.Text := 'SELECT * FROM YardSales ORDER BY EventStart DESC';
end;

end.
