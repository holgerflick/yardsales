unit uAddParticipant;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, Vcl.StdCtrls, Vcl.CheckLst,
  WEBLib.CheckLst,
  uBsWebCheckListBox,
  uYardSaleClientTypes,
  uDbController, Data.DB, WEBLib.DB, WEBLib.Lists, WEBLib.StdCtrls
  ;

type
  TFrmAddParticipant = class(TWebForm)
    btnSend: TWebButton;
    txtName: TWebEdit;
    txtStreet: TWebEdit;
    txtZip: TWebEdit;
    txtEmail: TWebEdit;
    txtCity: TWebEdit;
    txtState: TWebEdit;

    procedure btnSendClick(Sender: TObject);
    procedure WebFormCreate(Sender: TObject);
  private
    { Private declarations }
    FController: TDbController;
    FCheckListBox: TBsWebCheckListBox;
    FSaleId: Integer;

    FYardSale: TYardSaleDetails;

    procedure InitForm;

    procedure TransferTo( ANewParticipant: TNewParticipant );

    [async]
    procedure SendFormData;

    procedure OnUpdateItemCategories(Sender: TObject);
    procedure OnUpdateYardSaleDetails(Sender: TObject);
    procedure OnConnectionError(Sender: TObject);
  public
    { Public declarations }
    procedure HideAll;
  end;

var
  FrmAddParticipant: TFrmAddParticipant;

implementation
uses
 WebLib.WebTools,
 DateUtils
 ;

{$R *.dfm}

procedure TFrmAddParticipant.btnSendClick(Sender: TObject);
begin
  SendFormData;
end;

procedure TFrmAddParticipant.HideAll;
begin
  document.getHTMLElementById('container').hidden := true;
end;

procedure TFrmAddParticipant.InitForm;
var
  LSaleId: String;

begin
  txtName.Text := '';
  txtStreet.Text := '';
  txtZip.Text := '';
  txtEmail.Text := '';
  txtCity.Text := '';
  txtState.Text := '';

  FCheckListBox := TBsWebCheckListBox.Create('ListItemCategories');
  FCheckListBox.Selection := Multiple;

  // read SaleId from query string -- if it is not there, default to 0
  if HasQueryParam('id', LSaleId ) then
  begin
    FSaleId := LSaleId.ToInteger;
  end
  else
  begin
    FSaleId := 0;
  end;

  FController := TDbController.Create(self);
  FController.OnUpdateItemCategories := OnUpdateItemCategories;
  FController.OnUpdateYardSaleDetails := OnUpdateYardSaleDetails;

  FController.OnConnectionError := OnConnectionError;
  FController.Connect;
end;

procedure TFrmAddParticipant.OnConnectionError(Sender: TObject);
begin
  HideAll;
  ShowMessage('Cannot connect to web services.');
end;

procedure TFrmAddParticipant.OnUpdateItemCategories(Sender: TObject);
var
  LDataset: TDataset;
  LItem: TBsWebCheckListBoxItem;
begin
  // request yard sale details
  FController.RequestYardSaleDetails( FSaleId );

  FCheckListBox.Clear;

  LDataset := TDataSet( Sender );
  while not LDataset.Eof do
  begin
    LItem := FCheckListBox.Add;

    LItem.Text := LDataset.FieldByName('Name').AsString;
    LItem.Id := LDataset.FieldByName('Id').AsString;

    LDataset.Next;
  end;

  FCheckListBox.Update;
end;


procedure TFrmAddParticipant.OnUpdateYardSaleDetails(Sender: TObject);
var
  LImage: TJSHTMLImageElement;
  LRange,
  LTitle: TJSHTMLElement;
  LFormat: TFormatSettings;

begin
  FYardSale := TYardSaleDetails( Sender );

  LImage := document.getHTMLElementById( 'YardSaleLogo' )
    as TJSHTMLImageElement;
  LImage.src := FYardSale.LogoDataUrl;

  LTitle := document.getHTMLElementById( 'YardSaleTitle' );
  LTitle.innerText := FYardSale.Title;

  LRange := document.getHTMLElementById('YardSaleDates');

  LFormat := TFormatSettings.Create;
  LFormat.ShortDateFormat := 'dddd MMMM d';

  LRange.innerHtml :=
    DateToStr( FYardSale.EventStart, LFormat ) + '<br>Starts @ ' +
    IntToStr( HourOf( FYardSale.EventStart ) ) +
     '00 and ends @ ' + IntToStr( HourOf( FYardSale.EventEnd ) ) + '00';
end;

procedure TFrmAddParticipant.SendFormData;
var
  LNewParticipant: TNewParticipant;

begin
  LNewParticipant := TNewParticipant.Create;
  try
    TransferTo( LNewParticipant );

    await( FController.SendNewParticipant( LNewParticipant ) );
  finally
    LNewParticipant.Free;
  end;
end;

procedure TFrmAddParticipant.TransferTo(ANewParticipant: TNewParticipant);
var
  LSelectedCategories: TBsWebCheckListBoxSelectedItems;
  i: Integer;
  LItem: TBsWebCheckListBoxItem;
  LCategory: TParticipantCategory;
begin
  ANewParticipant.SaleId := FSaleid;
  ANewParticipant.Email := txtEmail.Text;
  ANewParticipant.Participant.Name := txtName.Text;
  ANewParticipant.Participant.Street := txtStreet.Text;
  ANewParticipant.Participant.Zip := txtZip.Text;
  ANewParticipant.Participant.City := txtCity.Text;
  ANewParticipant.Participant.State := txtState.Text;

  LSelectedCategories := FCheckListBox.Selected;

  for i := 0 to Length(LSelectedCategories)-1 do
  begin
    LCategory := TParticipantCategory.Create;
    LItem := LSelectedCategories[i];
    LCategory.Id := LItem.Id.ToInteger;
    // we only need to transmit Id
    LCategory.Comment := '';
    LCategory.Name := '';

    ANewParticipant.Categories.Add( LCategory );
  end;
end;

procedure TFrmAddParticipant.WebFormCreate(Sender: TObject);
begin
  InitForm;
end;

end.
