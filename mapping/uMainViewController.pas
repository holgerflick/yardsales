unit uMainViewController;

interface

uses
  uMappingTypes,
  uDbController,

  VCL.TMSFNCMapsCommonTypes,
  VCL.TMSFNCMaps
  ;

type
  TMainViewController = class
  private
    FParticipants: TParticipants;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddParticipants(
      ASalesId: Integer;
      AMap: TTMSFNCMaps;
      AModel: TDbController
      );
  end;

implementation

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
end;

destructor TMainViewController.Destroy;
begin
  FParticipants.Free;

  inherited;
end;

end.
