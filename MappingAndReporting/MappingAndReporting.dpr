program MappingAndReporting;

{$R 'Resources.res' 'Resources.rc'}

uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uDbController in 'uDbController.pas' {DbModel: TDataModule},
  uMappingTypes in 'uMappingTypes.pas',
  uMainViewController in 'uMainViewController.pas',
  uFrmProgress in 'uFrmProgress.pas' {FrmProgress},
  uApiKeyLoader in 'uApiKeyLoader.pas',
  uReportManager in 'uReportManager.pas' {ReportManager: TDataModule};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
