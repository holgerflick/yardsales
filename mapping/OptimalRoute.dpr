program OptimalRoute;

{$R 'Icons.res' 'Icons.rc'}

uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uDbController in 'uDbController.pas' {DbModel: TDataModule},
  uMappingTypes in 'uMappingTypes.pas',
  uMainViewController in 'uMainViewController.pas',
  uFrmProgress in 'uFrmProgress.pas' {FrmProgress};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
