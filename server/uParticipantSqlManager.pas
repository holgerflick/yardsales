unit uParticipantSqlManager;

interface
uses
  FireDAC.Comp.Client,

  XData.Sys.Exceptions,

  uYardSaleTypes
  ;


type
  TParticipantSqlManager = class
  public
    class function LoginParticipantQuery( AQuery: TFDQuery;
       ASaleId: Integer; AEmail: String ): Boolean;

    class function LoginAdminQuery( AQuery: TFDQuery;
      ALogin, APassword: String ): Boolean;

    class procedure YardSale( AQuery: TFDQuery;
      ASaleId: Integer );

    class procedure AddParticipantQuery( AQuery: TFDQuery;
      ANewParticipant: TNewParticipant );
    class procedure UpdateParticipantQuery( AQuery: TFDQuery;
      AParticipant: TUpdateParticipant );
    class procedure DeleteParticipantQuery( AQuery: TFDQuery );

    class procedure ItemCategories( LQuery: TFDQuery; ASortOrder: TItemCategorySortOrder );
  end;

implementation
uses
  uLoginManager
  ;

{ TParticipantSqlManager }

class procedure TParticipantSqlManager.AddParticipantQuery(AQuery: TFDQuery;
  ANewParticipant: TNewParticipant);
var
  LParticipantId: Integer;

begin
  // check for duplicate first
  AQuery.SQL.Text := 'SELECT COUNT(*) AS c FROM SalesParticipant WHERE ' +
    'Email = :Email AND SalesId = :SalesId';
  AQuery.ParamByName('Email').AsString := ANewParticipant.Email;
  AQuery.ParamByName('SalesId').AsInteger := ANewParticipant.SaleId;
  AQuery.Open;
  if AQuery.FieldByName('c').AsInteger > 0 then
  begin
    raise EXDataHttpException.Create(409, 'Duplicate. Participant already signed up.');
  end;
  AQuery.Close;

  // add participant
  AQuery.SQL.Text := 'INSERT INTO SalesParticipant ' +
    '(Email, SalesId, Name, Street, Zip, City, State ) VALUES ' +
    '(:Email, :SalesId, :Name, :Street, :Zip, :City, :State )'
    ;
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

class procedure TParticipantSqlManager.DeleteParticipantQuery(AQuery: TFDQuery);
begin


  AQuery.SQL.Text := 'DELETE FROM SalesParticipant WHERE ' +
    '( SalesId = :SalesId ) AND ( Email = :Email )';

  AQuery.ParamByName('SalesId').AsInteger := TLoginManager.GetSaleIdFromToken;
  AQuery.ParamByName('Email').AsString := TLoginManager.GetEmailFromToken;
end;

class procedure TParticipantSqlManager.ItemCategories(
  LQuery: TFDQuery;
  ASortOrder: TItemCategorySortOrder );
begin
  if ASortOrder = soName then
  begin
    LQuery.SQL.Text := 'SELECT Id, Name FROM ItemCategories ORDER BY Name';
  end;

  if ASortOrder = soUsage then
  begin
    LQuery.SQL.Text :=
    'SELECT Id, NAME, COUNT(IdCategory) AS cnt FROM ItemCategories' +
    '  LEFT JOIN ParticipantItemCategories ON Id = IdCategory' +
    '  GROUP BY Id ' +
    '  ORDER BY cnt DESC';
  end;
end;

class function TParticipantSqlManager.LoginAdminQuery(AQuery: TFDQuery; ALogin,
  APassword: String): Boolean;
begin
  AQuery.SQL.Text := 'SELECT password AS p FROM Admins WHERE login = :login';
  AQuery.ParamByName( 'login' ).AsString := ALogin;
  AQuery.Open;

  Result := False;
  if not AQuery.eof then
  begin
    // TODO: compare hash instead of clear text
    Result := APassword = AQuery.FieldByName('p').AsString;
  end;
end;

class function TParticipantSqlManager.LoginParticipantQuery(AQuery: TFDQuery; ASaleId: Integer;
  AEmail: String): Boolean;
begin
  AQuery.SQL.Text := 'SELECT (COUNT(*) > 0) AS valid FROM SalesParticipant ' +
    'WHERE ( SalesId = :SalesId ) AND ( Email = :Email )';
  AQuery.ParamByName('SalesId').AsInteger := ASaleId;
  AQuery.ParamByName('Email').AsString := AEmail;

  AQuery.Open;

  Result := AQuery.FieldByName('valid').AsInteger = 1;
end;

class procedure TParticipantSqlManager.UpdateParticipantQuery(AQuery: TFDQuery;
  AParticipant: TUpdateParticipant);
begin
  AQuery.SQL.Text := 'UPDATE SalesParticipant ' +
    'WHERE ( Email = :Email ) AND ( SalesId = :SalesId )';

  AQuery.ParamByName('email').AsString := TLoginManager.GetEmailFromToken;
  AQuery.ParamByName('salesid').AsInteger := TLoginManager.GetSaleIdFromToken;
end;

class procedure TParticipantSqlManager.YardSale(AQuery: TFDQuery;
  ASaleId: Integer);
begin
  AQuery.SQL.Text := 'SELECT * FROM YardSales WHERE Id = :Id';
  AQuery.ParamByName('Id').AsInteger := ASaleId;
end;

end.
