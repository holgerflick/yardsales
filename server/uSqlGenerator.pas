unit uSqlGenerator;

interface
uses
  FireDAC.Comp.Client;


type
  TSqlGenerator = class
  public
    class procedure LoginQuery( AQuery: TFDQuery;
       ASaleId: Integer; AEmail: String );
  end;

implementation


{ TSqlGenerator }

class procedure TSqlGenerator.LoginQuery(AQuery: TFDQuery; ASaleId: Integer;
  AEmail: String);
begin
  AQuery.SQL.Text := 'SELECT (COUNT(*) > 0) AS valid FROM SalesParticipant ' +
    'WHERE ( SalesId = :SalesId ) AND ( Email = :Email )';
  AQuery.ParamByName('SalesId').AsInteger := ASaleId;
  AQuery.ParamByName('Email').AsString := AEmail;
end;

end.
