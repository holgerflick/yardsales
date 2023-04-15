unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, VCL.TMSFNCTypes,
  VCL.TMSFNCUtils, VCL.TMSFNCGraphics, VCL.TMSFNCGraphicsTypes,
  VCL.TMSFNCMapsCommonTypes, VCL.TMSFNCCustomControl, VCL.TMSFNCWebBrowser,
  VCL.TMSFNCMaps,

  uMappingTypes,
  uDbController,
  uMainViewController, VCL.TMSFNCCustomComponent, VCL.TMSFNCCloudBase,
  VCL.TMSFNCGeocoding, VCL.TMSFNCRouteCalculator
  ;

type
  TFrmMain = class(TForm)
    cbSales: TComboBox;
    btnRoute: TButton;
    Map: TTMSFNCMaps;
    btnMarker: TButton;
    Geocoding: TTMSFNCGeocoding;
    btnGeocode: TButton;
    Routing: TTMSFNCRouteCalculator;
    procedure btnGeocodeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnMarkerClick(Sender: TObject);
    procedure btnRouteClick(Sender: TObject);
    procedure cbSalesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSales: TSales;

    FModel: TDbModel;
    FViewController: TMainViewController;

    procedure InitForm;

    procedure LoadSales;
    procedure UpdateButtonStates;
    function GetSelectedSale: TSale;

    procedure LocateParticipants;
    procedure GeocodeParticipants;

  public
    { Public declarations }
    property SelectedSale: TSale read GetSelectedSale;
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  DB;

{$R *.dfm}

procedure TFrmMain.btnGeocodeClick(Sender: TObject);
begin
  GeocodeParticipants;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FViewController.Free;
  FSales.Free;
end;

procedure TFrmMain.btnMarkerClick(Sender: TObject);
begin
  LocateParticipants;
end;

procedure TFrmMain.btnRouteClick(Sender: TObject);
begin
  //OptimizeRoute;
end;

procedure TFrmMain.cbSalesChange(Sender: TObject);
begin
  UpdateButtonStates;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FModel := TDbModel.Create(self);
  FViewController := TMainViewController.Create;

  FSales := nil;

  InitForm;
end;

procedure TFrmMain.GeocodeParticipants;
begin
  FViewController.GeocodeParticipants(
    SelectedSale.Id,
    Geocoding,
    FModel
    );
end;

function TFrmMain.GetSelectedSale: TSale;
begin
  Result := nil;
  if cbSales.ItemIndex <> -1 then
  begin
    Result := cbSales.Items.Objects[cbSales.ItemIndex] as TSale;
  end;
end;

procedure TFrmMain.InitForm;
begin
  cbSales.Enabled := False;
  btnRoute.Enabled := False;
  btnMarker.Enabled := False;

  LoadSales;
end;

procedure TFrmMain.LoadSales;

begin
  FSales.Free;
  FSales := FModel.GetSales;

  cbSales.Clear;

  for var LSale in FSales do
  begin
    cbSales.AddItem(
      Format( '%d: %s', [ LSale.Id, LSale.Title ] ),
      LSale );
  end;

  cbSales.Enabled := cbSales.Items.Count > 0;
end;

procedure TFrmMain.LocateParticipants;
begin
  FViewController.AddParticipants(
    SelectedSale.Id,
    Map,
    FModel );
end;

procedure TFrmMain.UpdateButtonStates;
begin
  btnRoute.Enabled   := SelectedSale <> nil;
  btnMarker.Enabled  := SelectedSale <> nil;
  btnGeocode.Enabled := SelectedSale <> nil;
end;

end.
