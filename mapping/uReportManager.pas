unit uReportManager;

interface

uses
  System.SysUtils,
  System.Classes
  ;

type
  TReportManager = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportManager: TReportManager;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
