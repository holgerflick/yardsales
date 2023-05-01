unit uMainViewController;

interface

uses
  uMappingTypes,
  uDbController,

  uFrmProgress,

  VCL.TMSFNCMapsCommonTypes,
  VCL.TMSFNCMaps,
  VCL.TMSFNCGeocoding,
  VCL.TMSFNCCloudBase,
  VCL.TMSFNCGoogleMaps,

  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.StdCtrls,

  System.Threading,
  System.RegularExpressions
  ;

type
  TMainViewController = class
  private
    FNeedLocations: TNeedLocations;

    FModel: TDbModel;
    FSales: TSales;
    FParticipants: TParticipants;
    FProgress:  TFrmProgress;
    FGeocoder: TTMSFNCGeocoding;

    function GetDataUrlForSaleIcon: String;
    function StripHtml( AText: String ): String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSales( AComboBox: TComboBox );

    procedure AddParticipants(
      ASalesId: Integer;
      AMap: TTMSFNCGoogleMaps
      );

    procedure GeocodeParticipants(
      ASalesId: Integer;
      AGeocoder: TTMSFNCGeocoding
    );

    procedure OptimizeRoute(ASalesId: Integer; AHome: String;
        AMap: TTMSFNCGoogleMaps);

    procedure DisplayRoutes(ARoutes: TListView; ADirectionsData:
        TTMSFNCGoogleMapsDirectionsData);

    procedure PreviewParticipantReport(ASalesId: Integer);

    property Geocoder: TTMSFNCGeocoding read FGeocoder;

  end;

implementation

uses
  System.SysUtils,
  System.NetEncoding,
  System.Classes,
  WinApi.Windows,

  FlexCel.XlsAdapter,

  uReportManager
  ;

{ TMainViewController }

procedure TMainViewController.AddParticipants(ASalesId: Integer; AMap:
    TTMSFNCGoogleMaps);
var
  LIconDataUrl: String;

begin
  LIconDataUrl := GetDataUrlForSaleIcon;

  FParticipants.Free;
  FParticipants := FModel.GetParticipants(ASalesId);
  AMap.BeginUpdate;
  try
    AMap.Clear;

    for var LParticipant in FParticipants do
    begin
      if Assigned( LParticipant.Location ) then
      begin
        var LMarker := AMap.AddMarker(
          LParticipant.Location.Latitude,
          LParticipant.Location.Longitude,
          LParticipant.Name
          );

        LMarker.DataObject := LParticipant;
        LMarker.IconURL := LIconDataUrl;
      end;
    end;

    if AMap.Markers.Count > 0 then
    begin
      AMap.ZoomToBounds( AMap.Markers.ToCoordinateArray );
    end;
  finally
    AMap.EndUpdate;
  end;
end;

constructor TMainViewController.Create;
begin
  FModel := TDbModel.Create(nil);
  FSales := nil;
  FParticipants := nil;
  FNeedLocations := nil;
  FProgress := TFrmProgress.Create(nil);
end;

destructor TMainViewController.Destroy;
begin
  FProgress.Free;
  FParticipants.Free;
  FSales.Free;
  FModel.Free;
  FNeedLocations.Free;

  inherited;
end;

procedure TMainViewController.DisplayRoutes(ARoutes: TListView;
    ADirectionsData: TTMSFNCGoogleMapsDirectionsData);
var
  LColIdx,
  LColDistance,
  LColDuration,
  LColInstructions : TListColumn;

  LSteps: Integer;
begin
  // init tree
  ARoutes.Clear;
  ARoutes.ViewStyle := vsReport;

  LColIdx := ARoutes.Columns.Add;
  LColIdx.Caption := 'Step';
  LColIdx.Width := -2;
  LColIdx.Alignment := taRightJustify;

  LColDistance :=  ARoutes.Columns.Add;
  LColDistance.Caption := 'Distance';
  LColDistance.Width := -2;
  LColDistance.Alignment := taRightJustify;

  LColDuration := ARoutes.Columns.Add;
  LColDuration.Caption := 'Duration';
  LColDuration.Width := -2;
  LColDuration.Alignment := taRightJustify;

  LColInstructions := ARoutes.Columns.Add;
  LColInstructions.Caption := 'Instructions';
  LColInstructions.Width := -1;

  // we only show the first route
  // add more UI for selection options

  if Length(ADirectionsData.Routes) = 0 then
  begin
    exit;
  end;

  var LRoute := ADirectionsData.Routes[0];

  if Length( LRoute.Legs ) = 0 then
  begin
    exit;
  end;

  LSteps := 0;

  for var LLeg in LRoute.Legs do
  begin
    for var LStep in LLeg.Steps do
    begin
      Inc(LSteps);
      var LItem := ARoutes.Items.Add;
      LItem.Caption := LSteps.ToString;
      LItem.SubItems.Add( LStep.Distance.ToString + ' m' );
      LItem.SubItems.Add( LStep.Duration.ToString + ' min' );
      LItem.SubItems.Add( StripHTML( LStep.Instructions ) );
    end;
  end;
end;

procedure TMainViewController.GeocodeParticipants(ASalesId: Integer; AGeocoder:
    TTMSFNCGeocoding);
begin
  if not Assigned( FGeocoder ) then
  begin
    FNeedLocations.Free;

    FGeocoder := AGeocoder;

    FNeedLocations := FModel.GetNeedLocations(ASalesId);

    FProgress.SetMax(FNeedLocations.Count);
    FProgress.Show;

    for var LNeedLocation in FNeedLocations do
    begin
      AGeoCoder.GetGeocoding( LNeedLocation.Address,
        // callback
        procedure(const ARequest: TTMSFNCGeocodingRequest; const ARequestResult: TTMSFNCCloudBaseRequestResult)
        var
          LItem: TNeedLocation;
        begin
          if ARequestResult.Success then
          begin
            LItem := TNeedLocation( ARequest.DataPointer );
            if ARequest.Items.Count > 0 then
            begin
              LItem.Location.UpdateLocation(
                ARequest.Items[0].Coordinate.Latitude,
                ARequest.Items[0].Coordinate.Longitude
              );
            end;
          end;

          TThread.Synchronize(
            nil,
            procedure
            begin
              FProgress.Increase;
            end
          );
        end, '', LNeedLocation
      );
    end;
  end;
end;

function TMainViewController.GetDataUrlForSaleIcon: String;
var
  LResource: TResourceStream;
  LOutput: TStringStream;

begin
  LResource := TResourceStream.Create( hInstance, 'SALEPNG', RT_RCDATA);
  LOutput := nil;
  try
    LOutput := TStringStream.Create;
    TBase64Encoding.Base64.Encode( LResource, LOutput );

    Result := 'data:image/png;base64,' + LOutput.DataString;
  finally
    LOutput.Free;
    LResource.Free;
  end;
end;

procedure TMainViewController.LoadSales(AComboBox: TComboBox);
begin
  FSales.Free;
  FSales := FModel.GetSales;

  AComboBox.Clear;

  for var LSale in FSales do
  begin
    AComboBox.AddItem(
      Format( '%d: %s', [ LSale.Id, LSale.Title ] ),
      LSale );
  end;

  AComboBox.Enabled := AComboBox.Items.Count > 0;
end;

procedure TMainViewController.OptimizeRoute(ASalesId: Integer; AHome: String;
    AMap: TTMSFNCGoogleMaps);
var
  LWaypoints: TStringlist;
begin
  FParticipants.Free;
  FParticipants := FModel.GetParticipants(ASalesId);

  LWayPoints := TStringlist.Create;
  try
    // add all participants as waypoints
    for var LParticipant in FParticipants do
    begin
      LWaypoints.Add( LParticipant.Address + ', USA' );
    end;

    AMap.AddDirections( AHome, AHome, False, True, clRed, 2, 0.5, dtmDriving,
       True, LWaypoints, True );

  finally
    LWaypoints.Free;
  end;
end;

procedure TMainViewController.PreviewParticipantReport(ASalesId: Integer);
var
  LManager: TReportManager;
  LXls: TXlsFile;
begin
  FModel.MoveToSalesId( ASalesId );

  LXls := nil;
  LManager := TReportManager.Create(nil);
  try
    LXls := LManager.GetParticipants( FModel.Sales, FModel.Participants, FModel.ParticipantCategories );
    LXls.Save('f:\report.xlsx');
  finally
    LXls.Free;
    LManager.Free;
  end;
end;

function TMainViewController.StripHtml(AText: String): String;
var
  R: TRegEx;
begin
  R := TRegEx.Create( '<([^>]+)>', [roIgnoreCase, roMultiLine] );
  Result := R.Replace( AText, ' ' );
  // replace duplicate spaces with one
  Result := Result.Replace('  ', ' ', [rfReplaceAll]);
end;

end.
