﻿unit uYardSaleServiceImpl;

interface

uses
  System.Classes,
  System.SysUtils,

  XData.Server.Module,
  XData.Service.Common,

  uYardSaleTypes,
  uYardSaleService


  ;

type
  [ServiceImplementation]
  TYardSaleService = class(TInterfacedObject, IYardSaleService)
    function LoginAdmin( Login, Password: String ): TLoginResponse;
    function LoginParticipant( SaleId: Integer; Email, Name, Zip : String ): TLoginResponse;

    function GetYardSale( SaleId: Integer ): TYardSale;

    // --- Participant
    procedure AddParticipant( NewParticipant: TNewParticipant );
    procedure UpdateParticipant( Participant: TUpdateParticipant );
    procedure DeleteParticipant;

    function ItemCategories( SortOrder: TItemCategorySortOrder ): TItemCategories;

    // --- Admin
    function GetParticipantsReportPdf( SaleId: Integer ): TStream;
    function GetYardSales: TYardSales;
    function GetYardSaleLogo( SaleId: Integer; Width, Height: Integer ): TBytes;
    function GetParticipants( SaleId: Integer ): TDetailedParticipants;
    function GetParticipantCategories(
      ParticipantId: Integer ): TParticipantCategories;
  end;

implementation

uses
  uAdminManager,
  uLoginManager,
  uParticipantManager

  ;


{ TYardSaleService }

procedure TYardSaleService.AddParticipant(NewParticipant: TNewParticipant);
var
  LManager: TParticipantManager;

begin
  LManager := TParticipantManager.Create;
  try
    LManager.AddParticipant( NewParticipant );
  finally
    LManager.Free;
  end;
end;

procedure TYardSaleService.DeleteParticipant;
var
  LManager: TParticipantManager;

begin
  TLoginManager.ParticipantOnly;

  LManager := TParticipantManager.Create;
  try
    LManager.DeleteParticipant;
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetParticipantCategories(
  ParticipantId: Integer): TParticipantCategories;
var
  LManager: TAdminManager;

begin
  TLoginManager.AdminOnly;

  LManager := TAdminManager.Create;
  try
    Result := LManager.GetParticipantCategories(ParticipantId);
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetParticipants(
  SaleId: Integer): TDetailedParticipants;
var
  LManager: TAdminManager;

begin
  TLoginManager.AdminOnly;

  LManager := TAdminManager.Create;
  try
    Result := LManager.GetParticipants(SaleId);
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetParticipantsReportPdf(SaleId: Integer): TStream;
var
  LManager: TAdminManager;

begin
  LManager := TAdminManager.Create;
  try
    Result := LManager.GetParticipantsReport(SaleId);

  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetYardSale(SaleId: Integer): TYardSale;
var
  LManager: TParticipantManager;

begin
  LManager := TParticipantManager.Create;
  try
    Result := LManager.GetYardSale( SaleId );
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetYardSaleLogo(
  SaleId,
  Width,
  Height: Integer): TBytes;

var
  LManager: TAdminManager;

begin
  TLoginManager.AdminOnly;

  LManager := TAdminManager.Create;
  try
    Result := LManager.GetYardSaleLogo( SaleId, Width, Height );
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.GetYardSales: TYardSales;
var
  LManager: TAdminManager;

begin
  TLoginManager.AdminOnly;

  LManager := TAdminManager.Create;
  try
    Result := LManager.GetYardSales;
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.ItemCategories(
  SortOrder: TItemCategorySortOrder ): TItemCategories;
var
  LManager: TParticipantManager;

begin
  LManager := TParticipantManager.Create;
  try
    Result := LManager.ItemCategories(SortOrder);
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.LoginAdmin(Login, Password: String): TLoginResponse;
var
  LManager: TLoginManager;

begin
  LManager := TLoginManager.Create;
  try
    Result := LManager.LoginAdmin( Login, Password );
  finally
    LManager.Free;
  end;
end;

function TYardSaleService.LoginParticipant(SaleId: Integer; Email, Name, Zip: String): TLoginResponse;
var
  LManager: TLoginManager;

begin
  LManager := TLoginManager.Create;
  try
    Result := LManager.LoginParticipant( SaleId, Email, Name, Zip );
  finally
    LManager.Free;
  end;
end;

procedure TYardSaleService.UpdateParticipant(Participant: TUpdateParticipant);
begin
  TLoginManager.ParticipantOnly;

  raise ENotImplemented.Create('Not implemented.');
end;

initialization
  RegisterServiceType(TYardSaleService);

end.
