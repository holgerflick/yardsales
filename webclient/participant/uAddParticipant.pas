unit uAddParticipant;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, Vcl.StdCtrls, Vcl.CheckLst,
  WEBLib.CheckLst,
  uBsWebCheckListBox,
  uDbController, Data.DB, WEBLib.DB, WEBLib.Lists, WEBLib.StdCtrls
  ;

type
  TFrmAddParticipant = class(TWebForm)

    procedure WebFormCreate(Sender: TObject);
  private
    { Private declarations }
    FController: TDbController;
    FCheckListBox: TBsWebCheckListBox;

    procedure InitForm;
    procedure OnUpdateItemCategories(Sender: TObject);
    procedure OnConnectionError(Sender: TObject);
  public
    { Public declarations }
    procedure HideAll;
  end;

var
  FrmAddParticipant: TFrmAddParticipant;

implementation

{$R *.dfm}

procedure TFrmAddParticipant.HideAll;
begin
  document.getHTMLElementById('container').hidden := true;
end;

procedure TFrmAddParticipant.InitForm;
begin
  FCheckListBox := TBsWebCheckListBox.Create('ListItemCategories');
  FCheckListBox.Selection := Multiple;

  FController := TDbController.Create(self);
  FController.OnUpdateItemCategories := OnUpdateItemCategories;
  FController.OnConnectionError := OnConnectionError;
  FController.Connect;
end;


procedure TFrmAddParticipant.OnConnectionError(Sender: TObject);
begin
  HideAll;
  ShowMessage('Cannot connect to web services.');
end;

procedure TFrmAddParticipant.OnUpdateItemCategories(Sender: TObject);
var
  LDataset: TDataset;
  LItem: TBsWebCheckListBoxItem;
begin
  FCheckListBox.Clear;

  LDataset := TDataSet( Sender );
  while not LDataset.Eof do
  begin
    LItem := FCheckListBox.Add;

    LItem.Text := LDataset.FieldByName('Name').AsString;
    LItem.Id := LDataset.FieldByName('Id').AsString;

    LDataset.Next;
  end;

  FCheckListBox.Update;
end;


procedure TFrmAddParticipant.WebFormCreate(Sender: TObject);
begin
  InitForm;
end;

end.
