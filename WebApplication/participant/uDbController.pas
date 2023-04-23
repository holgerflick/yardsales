unit uDbController;

interface

uses
  System.SysUtils,
  System.Classes,

  JS,
  Web,

  Data.DB,

  WEBLib.Modules,
  WEBLib.CDS,

  XData.Web.Connection,
  XData.Web.Client,

  uYardSaleClientTypes
  ;

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
    FOnSendNewParticipantFail: TNotifyEvent;
    FOnSendNewParticipantSuccess: TNotifyEvent;

    FDetails: TYardSaleDetails;

  private

    { Private declarations }

    [async]
    procedure RequestItemCategories;

    procedure AssignItemCategories( AResponse: TXDataClientResponse );
    procedure ProcessYardSaleDetails( AResponse: TXDataClientResponse );
  public
    { Public declarations }
    procedure Connect;

    [async]
    procedure SendNewParticipant( ANewParticipant: TNewParticipant );


    [async]
    procedure RequestYardSaleDetails( ASaleId: Integer );

    property YardSaleDetails: TYardSaleDetails read FDetails;

    property OnUpdateItemCategories: TNotifyEvent
      read FOnUpdateItemCategories write FOnUpdateItemCategories;

    property OnUpdateYardSaleDetails: TNotifyEvent
      read FOnUpdateYardSaleDetails write FOnUpdateYardSaleDetails;

    property OnConnectionError: TNotifyEvent
      read FOnConnectionError write FOnConnectionError;

    property OnSendNewParticipantSuccess: TNotifyEvent
      read FOnSendNewParticipantSuccess write FOnSendNewParticipantSuccess;

    property OnSendNewParticipantFail: TNotifyEvent
      read FOnSendNewParticipantFail write FOnSendNewParticipantFail;
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
  FOnUpdateItemCategories := nil;
  FOnUpdateYardSaleDetails := nil;
  FOnConnectionError := nil;
  FOnSendNewParticipantSuccess := nil;
  FOnSendNewParticipantFail := nil;
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
  FDetails.LogoDataUrl := 'data:image/jpeg;base64,' +
    JS.toString( LObj['Logo'] );

  if Assigned( FOnUpdateYardSaleDetails ) then
  begin
    FOnUpdateYardSaleDetails( FDetails );
  end;
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

procedure TDbController.SendNewParticipant(ANewParticipant: TNewParticipant);
var
  LResp: TXDataClientResponse;
  LObj: TJsObject;

begin
  LObj := ANewParticipant.AsJsObject;
  try
    LResp := await( Client.RawInvokeAsync( 'IYardSaleService.AddParticipant', [LObj] ) );

    if LResp.StatusCode = 204 then
    begin
      if Assigned( FOnSendNewParticipantSuccess ) then
      begin
        FOnSendNewParticipantSuccess( LResp );
      end;
    end;
  except
    on E: EXDataClientException do
    begin
      if Assigned( FOnSendNewParticipantFail ) then
      begin
        FOnSendNewParticipantFail( LResp );
      end;
    end;

  end;
end;

end.
