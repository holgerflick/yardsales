unit uSqlGenerator;

interface
uses
  FireDAC.Comp.Client,

  uYardSaleTypes
  ;


type
  TSqlGenerator = class
  public
    class procedure LoginQuery( AQuery: TFDQuery;
       ASaleId: Integer; AEmail: String );

    class procedure AddParticipantQuery( AQuery: TFDQuery;
      ANewParticipant: TNewParticipant );
    class procedure UpdateParticipantQuery( AQuery: TFDQuery;
      AParticipant: TUpdateParticipant );
    class procedure DeleteParticipantQuery( AQuery: TFDQuery );
  end;

implementation
uses
  uLoginManager
  ;

{ TSqlGenerator }

class procedure TSqlGenerator.AddParticipantQuery(AQuery: TFDQuery;
  ANewParticipant: TNewParticipant);
var
  LParticipantId: Integer;

begin
  // add participant
  AQuery.SQL.Text := 'INSERT INTO SalesParticipant ' +
    '(Email, SalesId, Name, Street, Zip, City, State ) VALUES ' +
    '(:Email, :SalesId, :Name, :Street, :Zip, :City, :State )'
    ;
  AQuery.ParamByName('Email').AsString := ANewParticipant.Email;
  AQuery.ParamByName('SalesId').AsInteger := ANewParticipant.SaleId;
  AQuery.ParamByName('Name').AsString := ANewParticipant.Participant.Name;
  AQuery.ParamByName('Street').AsString := ANewParticipant.Participant.Street;
  AQuery.ParamByName('Zip').AsString := ANewParticipant.Participant.Zip;
  AQuery.ParamByName('City').AsString := ANewParticipant.Participant.City;
  AQuery.ParamByName('State').AsString := ANewParticipant.Participant.State;
  AQuery.ExecSQL;

  // determine id of new participant
  LParticipantId := AQuery.Connection.GetLastAutoGenValue('');

  // add categories
  AQuery.SQL.Text := 'INSERT INTO ParticipantItemCategories ' +
    '(IdParticipant, IdCategory, Comment) VALUES ' +
    '(:IdParticipant, :IdCategory, :Comment)'
    ;
  AQuery.ParamByName('IdParticipant').AsInteger := LParticipantId;
  for var LCategory in ANewParticipant.Categories do
  begin
    AQuery.ParamByName('IdCategory').AsInteger := LCategory.Id;
    AQuery.ParamByName('Comment').AsString := LCategory.Comment;
    AQuery.ExecSQL;
  end;
end;

class procedure TSqlGenerator.DeleteParticipantQuery(AQuery: TFDQuery);
begin
  AQuery.SQL.Text := 'DELETE FROM SalesParticipant WHERE ' +
    '( SalesId = :SalesId ) AND ( Email = :Email )';

  AQuery.ParamByName('SalesId').AsInteger := TLoginManager.GetSaleIdFromToken;
  AQuery.ParamByName('Email').AsString := TLoginManager.GetEmailFromToken;
end;

class procedure TSqlGenerator.LoginQuery(AQuery: TFDQuery; ASaleId: Integer;
  AEmail: String);
begin
  AQuery.SQL.Text := 'SELECT (COUNT(*) > 0) AS valid FROM SalesParticipant ' +
    'WHERE ( SalesId = :SalesId ) AND ( Email = :Email )';
  AQuery.ParamByName('SalesId').AsInteger := ASaleId;
  AQuery.ParamByName('Email').AsString := AEmail;
end;

class procedure TSqlGenerator.UpdateParticipantQuery(AQuery: TFDQuery;
  AParticipant: TUpdateParticipant);
begin
  AQuery.SQL.Text := 'UPDATE SalesParticipant ' +
    'WHERE ( Email = :Email ) AND ( SalesId = :SalesId )';

  AQuery.ParamByName('email').AsString := TLoginManager.GetEmailFromToken;
  AQuery.ParamByName('salesid').AsInteger := TLoginManager.GetSaleIdFromToken;
end;

end.
