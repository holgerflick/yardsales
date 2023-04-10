﻿unit uAdminManager;

interface

uses
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
  end;

implementation

uses
  XData.Sys.Exceptions,

  System.Math,

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
          LThumb := TBitmapTools.Resize( LQuery.FieldByName('logo').AsBytes );

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
