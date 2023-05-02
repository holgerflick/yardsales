unit uAdminManager;

interface

uses
  System.Classes,
  System.SysUtils,

  XData.Server.Module,

  uLoginManager,
  uDbController,
  uYardSaleTypes,
  uBitmapTools
  ;

type
  TAdminManager = class

  public
    function GetYardSales: TYardSales;
    function GetYardSaleLogo( ASaleId, AWidth, AHeight: Integer ): TBytes;

    function GetParticipants( ASaleId: Integer ): TDetailedParticipants;
    function GetParticipantCategories(
      AParticipantId: Integer ): TParticipantCategories;

    function GetParticipantsReport( ASaleId: Integer ): TStream;
  end;

implementation

uses
  XData.Sys.Exceptions,

  System.Math,

  FireDAC.Comp.Client,
  uFDCustomQueryHelper,
  uAdminSqlManager,
  uReportManager,

  DB
  ;

{ TAdminManager }

function TAdminManager.GetParticipantCategories(
  AParticipantId: Integer): TParticipantCategories;
var
  LQuery: TFDQuery;

begin
  Result := TParticipantCategories.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add( Result );

  LQuery := TDbController.Shared.GetQuery;
  try
    TAdminSqlManager.GetParticipantCategoriesQuery( LQuery, AParticipantId );

    // we're not going to throw an exception
    // the list of categories can be empty

    LQuery.Open;
    while not LQuery.Eof do
    begin
      var LItem := TParticipantCategory.Create;
      LItem.Id := LQuery.FieldByName('Id').AsInteger;
      LItem.Name := LQuery.FieldByName('Name').AsString;
      LItem.Comment := LQuery.FieldByName('Comment').AsString;

      // add to list
      Result.Add(LItem);

      LQuery.Next;
    end;
  finally
    LQuery.ReturnToPool;
  end;
end;

function TAdminManager.GetParticipants(ASaleId: Integer): TDetailedParticipants;
var
  LQuery: TFDQuery;

begin
  Result := TDetailedParticipants.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add( Result );

  LQuery := TDbController.Shared.GetQuery;
  try
    TAdminSqlManager.GetParticipantsQuery( LQuery, ASaleId );

    LQuery.Open;
    if LQuery.Eof then
    begin
      raise EXDataHttpException.Create(404, 'Yard Sale not found.');
    end;

    while not LQuery.Eof do
    begin
      var LItem := TDetailedParticipant.Create;

      LItem.Id := LQuery.FieldByName('Id').AsInteger;
      LItem.Name := LQuery.FieldByName('Name').AsString;
      LItem.Street := LQuery.FieldByName('Street').AsString;
      LItem.Zip := LQuery.FieldByName('Zip').AsString;
      LItem.City := LQuery.FieldByName('City').AsString;
      LItem.State := LQuery.FieldByName('State').AsString;
      LItem.MapUrl := LQuery.FieldByName('MapUrl').AsString;

      Result.Add(LItem);

      LQuery.Next;
    end;
  finally
    LQuery.ReturnToPool;
  end;
end;

function TAdminManager.GetParticipantsReport(ASaleId: Integer): TStream;
var
  LCon: TFDConnection;
  LManager: TReportManager;

begin
  Result := TMemoryStream.Create;
  TXDataOperationContext.Current.Handler.ManagedObjects.Add(Result);

  LCon := TDbController.Shared.GetConnection;
  try
    LManager := TReportManager.Create( nil, LCon );
    try
      LManager.ReportParticipants(ASaleId);
      LManager.CreateLastReportPdf(Result);
    finally
      LManager.Free;
    end;
  finally
    LCon.Free;
  end;
end;

function TAdminManager.GetYardSaleLogo(ASaleId, AWidth,
  AHeight: Integer): TBytes;
var
  LQuery: TFDQuery;
  LEffValue: Integer;
  LDim: TBitmapTools.TFixedDimension;
begin
  // only one measurement is used. width takes priority.
  //
  if ( AWidth = 0 ) and ( AHeight = 0 ) then
  begin
    AWidth := 500;
  end;

  if AWidth <> 0 then
  begin
    LEffValue := AWidth;
    LDim := fdWidth;
  end
  else
  begin
    LEffValue := AHeight;
    LDim := fdHeight;
  end;

  LQuery := TDbController.Shared.GetQuery;
  try
    TAdminSqlManager.GetYardSaleLogo( LQuery, ASaleId );

    LQuery.Open;
    if LQuery.Eof then
    begin
      raise EXDataHttpException.Create(404, 'Yard Sale not found.');
    end;

    if LQuery.FieldByName('logo').IsNull then
    begin
      raise EXDataHttpException.Create(404,'Yard Sale has no logo.');
    end;

    Result := TBitmapTools.Resize(
      LQuery.FieldByName('logo').AsBytes,
      LEffValue,
      LDim );
  finally
    LQuery.ReturnToPool;
  end;
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
      LSale.Transfer( LQuery );

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
