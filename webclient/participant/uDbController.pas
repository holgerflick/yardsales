unit uDbController;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Modules, Data.DB, WEBLib.CDS,
  XData.Web.Connection, XData.Web.Client;

type
  TYardSaleDetails = class
  private
    FEventStart: TDateTime;
    FEventEnd: TDateTime;
    FTitle: String;
    FLogoDataUrl: String;
  public
    property Title: String read FTitle write FTitle;
    property EventStart: TDateTime read FEventStart write FEventStart;
    property EventEnd: TDateTime read FEventEnd write FEventEnd;
    property LogoDataUrl: String read FLogoDataUrl write FLogoDataUrl;
  end;

type
  TDbController = class(TWebDataModule)
    Client: TXDataWebClient;
    Connection: TXDataWebConnection;
    ItemCategories: TWebClientDataSet;
    ItemCategoriesId: TIntegerField;
    ItemCategoriesName: TStringField;
    procedure WebDataModuleCreate(Sender: TObject);
    procedure ConnectionConnect(Sender: TObject);
    procedure ConnectionError(Error: TXDataWebConnectionError);

  strict private
    FOnConnectionError: TNotifyEvent;
    FOnUpdateItemCategories: TNotifyEvent;
    FOnUpdateYardSaleDetails: TNotifyEvent;

    FDetails: TYardSaleDetails;

  private
    { Private declarations }

    [async]
    procedure RequestItemCategories;

    [async]
    procedure RequestYardSaleDetails( ASaleId: Integer );

    procedure AssignItemCategories( AResponse: TXDataClientResponse );
    procedure ProcessYardSaleDetails( AResponse: TXDataClientResponse );
  public
    { Public declarations }
    procedure Connect;

    property YardSaleDetails: TYardSaleDetails read FDetails;

    property OnUpdateItemCategories: TNotifyEvent
      read FOnUpdateItemCategories write FOnUpdateItemCategories;

    property OnUpdateYardSaleDetails: TNotifyEvent
      read FOnUpdateYardSaleDetails write FOnUpdateYardSaleDetails;

    property OnConnectionError: TNotifyEvent
      read FOnConnectionError write FOnConnectionError;
  end;


implementation

uses
  DateUtils,
  Bcl.Utils
  ;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDbController.WebDataModuleCreate(Sender: TObject);
begin
  FDetails := nil;
end;

procedure TDbController.AssignItemCategories(AResponse: TXDataClientResponse);
begin
  ItemCategories.Close;
  ItemCategories.Rows := TJSArray( AResponse.ResultAsObject['value'] );
  ItemCategories.Open;

  if Assigned( FOnUpdateItemCategories ) then
  begin
    FOnUpdateItemCategories(ItemCategories);
  end;
end;

procedure TDbController.Connect;
begin
  Connection.Connected := True;
end;

procedure TDbController.ConnectionConnect(Sender: TObject);
begin
  RequestItemCategories;
end;

procedure TDbController.ConnectionError(Error: TXDataWebConnectionError);
begin
//  HideAll;
  if Assigned( FOnConnectionError ) then
  begin
    FOnConnectionError( Error );
  end;
end;

procedure TDbController.ProcessYardSaleDetails(AResponse: TXDataClientResponse);
var
  LObj: TJSObject;


begin
  LObj := AResponse.ResultAsObject;
  FDetails.Free;
  FDetails := TYardSaleDetails.Create;
  FDetails.Title := JS.toString( LObj['Title'] );
  FDetails.EventStart :=
    TTimeZone.Local.ToLocalTime(
      TBclUtils.ISOToDateTime(
      JS.toString( LObj['EventStart'] ) )
    );
  FDetails.EventEnd :=
    TTimeZone.Local.ToLocalTime(
      TBclUtils.ISOToDateTime(
      JS.toString( LObj['EventEnd'] ) )
    );
  FDetails.LogoDataUrl := 'image/jpeg;base64,' +
    JS.toString( LObj['Logo'] );

  if Assigned( FOnUpdateYardSaleDetails ) then
  begin
    FOnUpdateYardSaleDetails( FDetails );
  end;

  //
end;

procedure TDbController.RequestItemCategories;
var
  LResponse: TXDataClientResponse;

begin
  try
    LResponse := await(
      Client.RawInvokeAsync('IYardSaleService.ItemCategories', [ 'soUsage' ] )
      );

    if LResponse.StatusCode = 200 then
    begin
      AssignItemCategories( LResponse );
    end;
  except
    on E: EXDataClientException do
    begin
      // handle error
      console.log( E.Message );
    end;
  end;
end;

procedure TDbController.RequestYardSaleDetails(ASaleId: Integer);
var
  LResponse: TXDataClientResponse;

begin
  try
    LResponse := await(
      Client.RawInvokeAsync('IYardSaleService.GetYardSale', [ ASaleId ] )
      );

    if LResponse.StatusCode = 200 then
    begin
      ProcessYardSaleDetails( LResponse );
    end;
  except
    on E: EXDataClientException do
    begin
      // handle error
      console.log( E.Message );
    end;
  end;
end;

end.
