unit uReportManager;

interface

uses
  System.SysUtils,
  System.Classes,

  Vcl.FlexCel.Core,
  FlexCel.XlsAdapter,

  uMappingTypes
  ;

type
  TReportManager = class(TDataModule)
  private
    { Private declarations }
    function LoadTemplate( AName: String ): TMemoryStream;
  public
    { Public declarations }

    function GetParticipants( ASale: TSale; AParticipants: TParticipants ): TXlsFile;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TReportManager }

function TReportManager.GetParticipants(ASale: TSale; AParticipants:
    TParticipants): TXlsFile;
begin

end;

function TReportManager.LoadTemplate(AName: String): TMemoryStream;
begin

end;

end.
