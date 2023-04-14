program OptimalRoute;

uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uDbController in 'uDbController.pas' {DbController: TDataModule},
  uMappingTypes in 'uMappingTypes.pas',
  uMainViewController in 'uMainViewController.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
