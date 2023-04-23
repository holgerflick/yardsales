unit uFrmMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  uServerContainer
  ;

type
  TFrmMain = class(TForm)
    mmInfo: TMemo;
    btStart: TButton;
    btStop: TButton;
    btSwagger: TButton;
    procedure btStartClick(ASender: TObject);
    procedure btStopClick(ASender: TObject);
    procedure btSwaggerClick(Sender: TObject);
    procedure FormCreate(ASender: TObject);
  strict private
    procedure UpdateGUI;
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  ShellAPI
  ;

{$R *.dfm}

resourcestring
  SServerStopped = 'Server stopped';
  SServerStartedAt = 'Server started at ';

{ TMainForm }

procedure TFrmMain.btStartClick(ASender: TObject);
begin
  ServerContainer.SparkleHttpSysDispatcher.Start;
  UpdateGUI;
end;

procedure TFrmMain.btStopClick(ASender: TObject);
begin
  ServerContainer.SparkleHttpSysDispatcher.Stop;
  UpdateGUI;
end;

procedure TFrmMain.btSwaggerClick(Sender: TObject);
begin
  ShellExecute( self.Handle, 'open',
    pChar( ServerContainer.XDataServer.BaseUrl.Replace('+', 'localhost') + 'swaggerui' )
    , '', '', SW_SHOWNORMAL );
end;

procedure TFrmMain.FormCreate(ASender: TObject);
begin
  UpdateGUI;
end;

procedure TFrmMain.UpdateGUI;
const
  cHttp = 'http://+';
  cHttpLocalhost = 'http://localhost';
begin
  btStart.Enabled := not ServerContainer.SparkleHttpSysDispatcher.Active;
  btStop.Enabled := not btStart.Enabled;
  btSwagger.Enabled := not btStart.Enabled;
  if ServerContainer.SparkleHttpSysDispatcher.Active then
    mmInfo.Lines.Add(SServerStartedAt + StringReplace(
      ServerContainer.XDataServer.BaseUrl,
      cHttp, cHttpLocalhost, [rfIgnoreCase]))
  else
    mmInfo.Lines.Add(SServerStopped);
end;

end.
