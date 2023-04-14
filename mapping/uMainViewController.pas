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
  Threading
  ;

type
  TMainViewController = class
  private
    FNeedLocations: TNeedLocations;
    FParticipants: TParticipants;
    FProgress:  TFrmProgress;
    FGeocoder: TTMSFNCGeocoding;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddParticipants(
      ASalesId: Integer;
      AMap: TTMSFNCMaps;
      AModel: TDbController
      );

    procedure GeocodeParticipants(
      ASalesId: Integer;
      AGeocoder: TTMSFNCGeocoding;
      AModel: TDbController
    );

    property Geocoder: TTMSFNCGeocoding read FGeocoder;

  end;

implementation

uses
  Classes;

{ TMainViewController }

procedure TMainViewController.AddParticipants(ASalesId: Integer; AMap: TTMSFNCMaps;
  AModel: TDbController);


begin
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
      end;
    end;

    AMap.ZoomToBounds( AMap.Markers.ToCoordinateArray );

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

procedure TMainViewController.GeocodeParticipants(ASalesId: Integer;
  AGeocoder: TTMSFNCGeocoding; AModel: TDbController);
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
              LItem.Location.Latitude := ARequest.Items[0].Coordinate.Latitude;
              LItem.Location.Longitude := ARequest.Items[0].Coordinate.Longitude;
            end;
          end;

          TThread.Synchronize(
            nil,
            procedure
            begin
              FProgress.Increase;

              if FGeocoder.RunningRequests.Count = 0 then
              begin
                FProgress.Close;
                FGeocoder := nil;
              end;
            end
          );
        end, '', LNeedLocation
      );
    end;
  end;
end;

end.
