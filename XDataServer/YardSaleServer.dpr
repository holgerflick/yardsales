program YardSaleServer;

{$R 'Resources.res' 'Resources.rc'}

uses
  Vcl.Forms,
  uServerContainer in 'uServerContainer.pas' {ServerContainer: TDataModule},
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uYardSaleService in 'uYardSaleService.pas',
  uYardSaleServiceImpl in 'uYardSaleServiceImpl.pas',
  uYardSaleTypes in 'uYardSaleTypes.pas',
  uParticipantManager in 'uParticipantManager.pas',
  uLoginManager in 'uLoginManager.pas',
  uDbController in 'uDbController.pas' {DbController: TDataModule},
  uServerSettings in 'uServerSettings.pas',
  uFDCustomQueryHelper in 'uFDCustomQueryHelper.pas',
  uParticipantSqlManager in 'uParticipantSqlManager.pas',
  uAdminManager in 'uAdminManager.pas',
  uAdminSqlManager in 'uAdminSqlManager.pas',
  uBitmapTools in 'uBitmapTools.pas',
  uReportManager in '..\Shared\uReportManager.pas' {ReportManager: TDataModule};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServerContainer, ServerContainer);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
