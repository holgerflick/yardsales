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

  System.Threading,
  System.RegularExpressions
  ;

type
  TMainViewController = class
  private
    FNeedLocations: TNeedLocations;
    FParticipants: TParticipants;
    FProgress:  TFrmProgress;
    FGeocoder: TTMSFNCGeocoding;

    function GetDataUrlForSaleIcon: String;
    function StripHtml( AText: String ): String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddParticipants(
      ASalesId: Integer;
      AMap: TTMSFNCGoogleMaps;
      AModel: TDbModel
      );

    procedure GeocodeParticipants(
      ASalesId: Integer;
      AGeocoder: TTMSFNCGeocoding;
      AModel: TDbModel
    );

    procedure OptimizeRoute(ASalesId: Integer; AHome: String;
        AMap: TTMSFNCGoogleMaps; AModel: TDbModel);

    procedure DisplayRoutes(ARoutes: TListView; ADirectionsData:
        TTMSFNCGoogleMapsDirectionsData);

    property Geocoder: TTMSFNCGeocoding read FGeocoder;

  end;

implementation

uses
  System.SysUtils,
  System.NetEncoding,
  System.Classes,
  WinApi.Windows
  ;

{ TMainViewController }

procedure TMainViewController.AddParticipants(ASalesId: Integer; AMap:
    TTMSFNCGoogleMaps; AModel: TDbModel);
var
  LIconDataUrl: String;

begin
  LIconDataUrl := GetDataUrlForSaleIcon;

  FParticipants.Free;
  FParticipants := AModel.GetParticipants(ASalesId);
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
  FParticipants := nil;
  FNeedLocations := nil;
  FProgress := TFrmProgress.Create(nil);
end;

destructor TMainViewController.Destroy;
begin
  FProgress.Free;
  FParticipants.Free;
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
    TTMSFNCGeocoding; AModel: TDbModel);
begin
  if not Assigned( FGeocoder ) then
  begin
    FNeedLocations.Free;

    FGeocoder := AGeocoder;

    FNeedLocations := AModel.GetNeedLocations(ASalesId);

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

procedure TMainViewController.OptimizeRoute(ASalesId: Integer; AHome: String;
    AMap: TTMSFNCGoogleMaps; AModel: TDbModel);
var
  LWaypoints: TStringlist;
begin
  FParticipants.Free;
  FParticipants := AModel.GetParticipants(ASalesId);

  LWayPoints := TStringlist.Create;
  try
    // add all participants as waypoints
    for var LParticipant in FParticipants do
    begin
      LWaypoints.Add( LParticipant.Street + ',' + LParticipant.City + ',' +
        LParticipant.State + ' ' + LParticipant.Zip + ', USA' );
    end;

    AMap.AddDirections( AHome, AHome, False, True, clRed, 2, 0.5, dtmDriving,
       True, LWaypoints, True );

  finally
    LWaypoints.Free;
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
