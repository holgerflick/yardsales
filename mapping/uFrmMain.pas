unit uFrmMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  VCL.TMSFNCTypes,
  VCL.TMSFNCUtils,
  VCL.TMSFNCGraphics,
  VCL.TMSFNCGraphicsTypes,
  VCL.TMSFNCMapsCommonTypes,
  VCL.TMSFNCCustomControl,
  VCL.TMSFNCWebBrowser,
  VCL.TMSFNCMaps,
  VCL.TMSFNCCustomComponent,
  VCL.TMSFNCCloudBase,
  VCL.TMSFNCGeocoding,
  VCL.TMSFNCGoogleMaps,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  AdvSplitter,
  AdvCustomControl,
  AdvTreeViewBase,
  AdvTreeViewData,
  AdvCustomTreeView,
  AdvTreeView,

  uMappingTypes,
  uMainViewController
  ;

type
  TFrmMain = class(TForm)
    Geocoding: TTMSFNCGeocoding;
    Map: TTMSFNCGoogleMaps;
    AdvSplitter1: TAdvSplitter;
    Panel1: TPanel;
    cbSales: TComboBox;
    btnGeocode: TButton;
    btnMarker: TButton;
    btnRoute: TButton;
    txtHome: TEdit;
    Routes: TListView;
    btnReportParticipants: TButton;
    procedure btnGeocodeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnMarkerClick(Sender: TObject);
    procedure btnRouteClick(Sender: TObject);
    procedure cbSalesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MapMapDblClick(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapRetrievedDirectionsData(Sender: TObject; AEventData:
        TTMSFNCMapsEventData; ADirectionsData: TTMSFNCGoogleMapsDirectionsData);
  private
    { Private declarations }
    FLastDirections: TTMSFNCGoogleMapsDirectionsData;
    FHome: TTMSFNCMapsCoordinateRec;

    FViewController: TMainViewController;

    procedure InitForm;

    procedure UpdateButtonStates;
    function GetSelectedSale: TSale;

    procedure LocateParticipants;
    procedure GeocodeParticipants;
    procedure InitFields;
    procedure OptimizeRoute;

  public
    { Public declarations }
    property SelectedSale: TSale read GetSelectedSale;
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  DB,
  uApiKeyLoader
  ;

{$R *.dfm}

procedure TFrmMain.btnGeocodeClick(Sender: TObject);
begin
  GeocodeParticipants;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FViewController.Free;
end;

procedure TFrmMain.btnMarkerClick(Sender: TObject);
begin
  LocateParticipants;
end;

procedure TFrmMain.btnRouteClick(Sender: TObject);
begin
  OptimizeRoute;
end;

procedure TFrmMain.cbSalesChange(Sender: TObject);
begin
  UpdateButtonStates;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  InitFields;
  InitForm;
end;

procedure TFrmMain.GeocodeParticipants;
begin
  FViewController.GeocodeParticipants(
    SelectedSale.Id,
    Geocoding
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

procedure TFrmMain.InitFields;
begin
  FViewController := TMainViewController.Create;

  Geocoding.APIKey := TApiKeyLoader.GoogleApiKey;
  Map.APIKey := TApiKeyLoader.GoogleApiKey;
end;

procedure TFrmMain.InitForm;
begin
  cbSales.Enabled := False;
  btnRoute.Enabled := False;
  btnMarker.Enabled := False;

  Routes.Clear;

  FViewController.LoadSales( cbSales );
end;


procedure TFrmMain.LocateParticipants;
begin
  FViewController.AddParticipants(
    SelectedSale.Id,
    Map );
end;

procedure TFrmMain.MapMapDblClick(Sender: TObject; AEventData:
    TTMSFNCMapsEventData);
begin
  FHome.Longitude := AEventData.Coordinate.Longitude;
  FHome.Latitude := AEventData.Coordinate.Latitude;

  txtHome.Text := Format( 'Home set to lat: %.3f lon: %.3f',
    [FHome.Latitude, FHome.Longitude] );
end;

procedure TFrmMain.MapRetrievedDirectionsData(Sender: TObject; AEventData:
    TTMSFNCMapsEventData; ADirectionsData: TTMSFNCGoogleMapsDirectionsData);
begin
  FLastDirections := ADirectionsData;

  FViewController.DisplayRoutes( Routes, ADirectionsData );
end;

procedure TFrmMain.OptimizeRoute;
begin
  FViewController.OptimizeRoute(
    SelectedSale.Id,
    txtHome.Text,
    Map );
end;

procedure TFrmMain.UpdateButtonStates;
begin
  btnRoute.Enabled   := SelectedSale <> nil;
  btnMarker.Enabled  := SelectedSale <> nil;
  btnGeocode.Enabled := SelectedSale <> nil;
end;

end.
