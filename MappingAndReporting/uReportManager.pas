unit uReportManager;

interface

uses
  System.SysUtils,
  System.Classes,

  Data.DB,

  Vcl.FlexCel.Core,
  FlexCel.XlsAdapter,
  FlexCel.Report,

  uDbController
  ;

type
  TReportManager = class(TDataModule)
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FModel: TDbModel;

    FLastReport: TXlsFile;

    procedure LoadTemplate( AName: String; ATemplate: TStream );

  public
    { Public declarations }
    constructor Create( AOwner: TComponent; AModel: TDbModel ); reintroduce;


    procedure ReportParticipants(ASaleId: Integer);

    property LastReport: TXlsFile read FLastReport;

  end;

implementation

uses
  WinApi.Windows;

resourcestring
  cTemplateParticipants = 'PARTICIPANTS';

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TReportManager.DataModuleDestroy(Sender: TObject);
begin
  FLastReport.Free;
end;

constructor TReportManager.Create(AOwner: TComponent; AModel: TDbModel);
begin
  inherited Create( AOwner );

  FModel := AModel;
end;

procedure TReportManager.DataModuleCreate(Sender: TObject);
begin
  FLastReport := nil;
end;

{ TReportManager }

procedure TReportManager.ReportParticipants(ASaleId: Integer);
var
  LBmParticipants: TBookmark;
  LTemplate: TMemoryStream;
  LReport : TFlexCelReport;
  LOutput: TMemoryStream;

  LCategories,
  LParticipants,
  LSale: TDataSet;

begin
  LCategories := FModel.ParticipantCategories;
  LParticipants := FModel.Participants;
  LSale := FModel.Sales;

  FModel.MoveToSalesId( ASaleId );

  LTemplate := nil;
  LReport := nil;
  LOutput := nil;
  try
    LCategories.Open;
    LParticipants.Open;

    LBmParticipants := LParticipants.GetBookmark;
    LParticipants.First;

    // set up template
    LTemplate := TMemoryStream.Create;
    LoadTemplate( cTemplateParticipants, LTemplate );

    // create report
    LReport := TFlexCelReport.Create( true );

    // link tables to report
    LReport.AddTable( 'P', LParticipants );

    // set header
    LReport.SetValue( 'YardSaleTitle',
      LSale.FieldByName( 'Title' ).AsString );

    // use calculated field to display date and time of event
    LReport.SetValue( 'YardSaleEventDates',
      LSale.FieldByName( 'EventDates' ).AsString );

    LReport.SetValue( 'YardSaleThumb',
      LSale.FieldByName('Logo').AsBytes );

    // run report
    LOutput := TMemoryStream.Create;
    LReport.Run( LTemplate, LOutput );

    // create document with report
    LOutput.Position := 0;

    FLastReport.Free;
    FLastReport := TXlsFile.Create( LOutput, True );
  finally
    LParticipants.GotoBookmark( LBmParticipants );
    LParticipants.FreeBookmark( LBmParticipants );

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
