unit uFrmProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls;

type
  TFrmProgress = class(TForm)
    Bar: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }

    procedure SetMax( AValue: Integer );
    procedure Increase;
  end;


implementation

{$R *.dfm}

{ TFrmProgress }

procedure TFrmProgress.Increase;
begin
  Bar.Position := Bar.Position + 1;

  if Bar.Position = Bar.Max then
  begin
    self.Close;
  end;

  Application.ProcessMessages;
end;

procedure TFrmProgress.SetMax(AValue: Integer);
begin
  Bar.Position := 0;
  Bar.Max := AValue;
  Bar.Min := 0;

  Application.ProcessMessages;
end;

end.
