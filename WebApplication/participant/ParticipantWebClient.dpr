program ParticipantWebClient;

uses
  Vcl.Forms,
  WEBLib.Forms,
  uAddParticipant in 'uAddParticipant.pas' {FrmAddParticipant: TWebForm} {*.html},
  uDbController in 'uDbController.pas' {DbController: TWebDataModule},
  uBsWebCheckListBox in 'uBsWebCheckListBox.pas',
  uYardSaleClientTypes in 'uYardSaleClientTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmAddParticipant, FrmAddParticipant);
  Application.Run;
end.
