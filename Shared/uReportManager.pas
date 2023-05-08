unit uReportManager;

interface

uses
  System.SysUtils,
  System.Classes,

  Data.DB,

  Vcl.FlexCel.Core,

  FlexCel.XlsAdapter,
  FlexCel.Report,
  FlexCel.Pdf,
  FlexCel.Render,

  uDbController,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client
  ;

type
  TReportManager = class(TDataModule)
    Sale: TFDQuery;
    SaleEventDates: TStringField;
    SaleId: TFDAutoIncField;
    SaleEventStart: TDateTimeField;
    SaleEventEnd: TDateTimeField;
    SaleTitle: TWideStringField;
    SaleLogo: TBlobField;
    SaleThumb: TBlobField;
    Participants: TFDQuery;
    ParticipantsCategories: TStringField;
    ParticipantsId: TFDAutoIncField;
    ParticipantsEmail: TWideStringField;
    ParticipantsSalesId: TLongWordField;
    ParticipantsName: TWideStringField;
    ParticipantsStreet: TWideStringField;
    ParticipantsZip: TWideStringField;
    ParticipantsCity: TWideStringField;
    ParticipantsState: TWideStringField;
    ParticipantsMapUrl: TWideStringField;
    ParticipantsLongitude: TFloatField;
    ParticipantsLatitude: TFloatField;
    ParticipantsCreated: TDateTimeField;
    ParticipantsAddress: TStringField;
    ParticipantCategories: TFDQuery;
    sourceParticipants: TDataSource;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ParticipantsCalcFields(DataSet: TDataSet);
    procedure SaleCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
    FLastReport: TXlsFile;
    FConnection: TFDConnection;

    procedure LoadTemplate( AName: String; ATemplate: TStream );


  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AConnection: TFDConnection); reintroduce;

    procedure CreateLastReportPdf( APdf: TStream );
    procedure ReportParticipants(ASaleId: Integer);

    property LastReport: TXlsFile read FLastReport;


  end;

implementation

uses
  WinApi.Windows,
  DateUtils;

resourcestring
  cTemplateParticipants = 'PARTICIPANTS';

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TReportManager.DataModuleDestroy(Sender: TObject);
begin
  FLastReport.Free;
end;

constructor TReportManager.Create(AOwner: TComponent; AConnection: TFDConnection);
begin
  inherited Create( AOwner );

  FConnection := AConnection;
  Sale.Connection := FConnection;
  Participants.Connection := FConnection;
  ParticipantCategories.Connection := FConnection;
end;

procedure TReportManager.CreateLastReportPdf(APdf: TStream);
var
  LExport: TFlexCelPdfExport;

begin
  if Assigned(FLastReport) then
  begin
    LExport := TFlexCelPdfExport.Create(FLastReport);
    try
      LExport.Export(APdf);
    finally
      LExport.Free;
    end;
  end;
end;

procedure TReportManager.DataModuleCreate(Sender: TObject);
begin
  FLastReport := nil;
end;

{ TReportManager }

procedure TReportManager.ReportParticipants(ASaleId: Integer);
var
  LTemplate: TMemoryStream;
  LReport : TFlexCelReport;
  LOutput: TMemoryStream;

  LParticipants,
  LSale: TFDQuery;

begin
  LParticipants := Participants;
  LSale := Sale;
  LSale.ParamByName('id').AsInteger := ASaleId;
  LSale.Open;

  LParticipants.ParamByName('SalesId').AsInteger := ASaleId;
  LParticipants.Open;

  LTemplate := nil;
  LReport := nil;
  LOutput := nil;
  try
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
    LParticipants.Close;
    LSale.Close;

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

procedure TReportManager.ParticipantsCalcFields(DataSet: TDataSet);
var
  LBuffer: String;

begin
   Dataset.FieldByName('Address').AsString :=
        Dataset.FieldByName('Street').AsString + ', ' +
        Dataset.FieldByName('City').AsString;

   ParticipantCategories.Close;
   ParticipantCategories.Open;


  LBuffer := '';

  ParticipantCategories.First;
  while not ParticipantCategories.Eof do
  begin
    if not LBuffer.IsEmpty then
    begin
      LBuffer := LBuffer + ', ';
    end;

    LBuffer := LBuffer + ParticipantCategories.FieldByName('Name').AsString;

    ParticipantCategories.Next;
  end;

  DataSet.FieldByName('Categories').AsString := LBuffer;
end;

procedure TReportManager.SaleCalcFields(DataSet: TDataSet);
var
  LBuffer: String;
  LLocalStart,
  LLocalEnd : TDateTime;
begin
  LLocalStart :=
    TTimeZone.Local.ToLocalTime(
      DataSet.FieldByName('EventStart').AsDateTime
    );

  LLocalEnd :=
    TTimeZone.Local.ToLocalTime(
      DataSet.FieldByName('EventEnd').AsDateTime
    );

  LBuffer := FormatDateTime(
    'mmmm d, yyyy (t ', LLocalStart
     );
  LBuffer := LBuffer + FormatDateTime( 't)', LLocalEnd );

  DataSet.FieldByName('EventDates').AsString := LBuffer;
end;

end.
