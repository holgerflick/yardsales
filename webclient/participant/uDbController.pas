unit uDbController;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Modules, Data.DB, WEBLib.CDS,
  XData.Web.Connection, XData.Web.Client;

type
  TDbController = class(TWebDataModule)
    Client: TXDataWebClient;
    Connection: TXDataWebConnection;
    ItemCategories: TWebClientDataSet;
    ItemCategoriesId: TIntegerField;
    ItemCategoriesName: TStringField;
    procedure ConnectionConnect(Sender: TObject);
    procedure ConnectionError(Error: TXDataWebConnectionError);

  private
    FOnConnectionError: TNotifyEvent;
    FOnUpdateItemCategories: TNotifyEvent;
    { Private declarations }

    [async]
    procedure RequestItemCategories;

    procedure AssignItemCategories( AResponse: TXDataClientResponse );
  public
    { Public declarations }
    procedure Connect;

    property OnUpdateItemCategories: TNotifyEvent
      read FOnUpdateItemCategories write FOnUpdateItemCategories;

    property OnConnectionError: TNotifyEvent
      read FOnConnectionError write FOnConnectionError;
  end;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

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

procedure TDbController.RequestItemCategories;
var
  LResponse: TXDataClientResponse;

begin
  try
    LResponse := await(
      Client.RawInvokeAsync('IYardSaleService.ItemCategories', [] )
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

end.
