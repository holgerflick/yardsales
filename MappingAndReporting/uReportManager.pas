unit uReportManager;

interface

uses
  System.SysUtils,
  System.Classes,

  Data.DB,

  Vcl.FlexCel.Core,
  FlexCel.XlsAdapter,
  FlexCel.Report,

  uMappingTypes
  ;

type
  TReportManager = class(TDataModule)
  private
    { Private declarations }
    procedure LoadTemplate( AName: String; ATemplate: TStream );
  public
    { Public declarations }

    function GetParticipants(ASale, AParticipants, ACategories: TDataSet): TXlsFile;
  end;

implementation

uses
  WinApi.Windows;

resourcestring
  cTemplateParticipants = 'PARTICIPANTS';

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TReportManager }

function TReportManager.GetParticipants(ASale, AParticipants, ACategories:
    TDataSet): TXlsFile;
var
  LBmParticipants: TBookmark;
  LTemplate: TMemoryStream;
  LReport : TFlexCelReport;
  LOutput: TMemoryStream;

begin
  Result := nil;
  LTemplate := nil;
  LReport := nil;
  LOutput := nil;
  try
    ACategories.Open;
    AParticipants.Open;

    LBmParticipants := AParticipants.GetBookmark;
    AParticipants.First;

    // set up template
    LTemplate := TMemoryStream.Create;
    LoadTemplate( cTemplateParticipants, LTemplate );

    // create report
    LReport := TFlexCelReport.Create( true );

    // link tables to report
    LReport.AddTable( 'P', AParticipants );

    // set header
    LReport.SetValue( 'YardSaleTitle',
      ASale.FieldByName( 'Title' ).AsString );

    // use calculated field to display date and time of event
    LReport.SetValue( 'YardSaleEventDates',
      ASale.FieldByName( 'EventDates' ).AsString );

    LReport.SetValue( 'YardSaleThumb', ASale.FieldByName('Logo').AsBytes );

    // run report
    LOutput := TMemoryStream.Create;
    LReport.Run( LTemplate, LOutput );

    // create document with report
    LOutput.Position := 0;
    Result := TXlsFile.Create(LOutput, True);

  finally
    AParticipants.GotoBookmark( LBmParticipants );
    AParticipants.FreeBookmark( LBmParticipants );

    LReport.Free;
    LTemplate.Free;
    LOutput.Free;
  end;
end;

procedure TReportManager.LoadTemplate(AName: String; ATemplate: TStream);
var
  LResourceStream: TResourceStream;

begin
  LResourceStream := TResourceStream.Create(
    HInstance, 'TEMPLATE_' + AName, RT_RCDATA );
  try
    LResourceStream.Position := 0;
    ATemplate.CopyFrom( LResourceStream );
    ATemplate.Position := 0;
  finally
    LResourceStream.Free;
  end;
end;

end.
