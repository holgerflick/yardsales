unit uFrmPreview;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ImgList,
  Vcl.VirtualImageList,
  Vcl.ImageCollection,
  Vcl.BaseImageCollection,

  VCL.FlexCel.Core,
  FlexCel.XlsAdapter,
  FlexCel.Render,
  FlexCel.Preview,

  AdvTypes,
  AdvGlowButton,
  AdvToolBar,

  uReportManager,
  uDbController
  ;

type
  TFrmPreview = class(TForm)
    Preview: TFlexCelPreviewer;
    VirtualImageList1: TVirtualImageList;
    AdvDockPanel1: TAdvDockPanel;
    AdvToolBar1: TAdvToolBar;
    btnPdf: TAdvGlowButton;
    btnHtml: TAdvGlowButton;
    btnXls: TAdvGlowButton;
    ImageCollection1: TImageCollection;
    DlgSave: TFileSaveDialog;
    procedure FormDestroy(Sender: TObject);
    procedure btnXlsClick(Sender: TObject);
    procedure btnHtmlClick(Sender: TObject);
    procedure btnPdfClick(Sender: TObject);
  private
    FImgExport: TFlexCelImgExport;
    FManager: TReportManager;
    FModel: TDbModel;
    FReport: TXlsFile;

    procedure ExportXls;
    procedure ExportPdf;
    procedure ExportHtml;

    procedure UpdateReport;
    procedure UpdateToolbar;


    { Private declarations }
  public
    { Public declarations }
    constructor Create( AModel: TDbModel ); reintroduce;

    procedure ShowParticipants(ASalesId: Integer);
  end;

var
  FrmPreview: TFrmPreview;

implementation

{$R *.dfm}

{ TFrmPreview }

procedure TFrmPreview.btnHtmlClick(Sender: TObject);
begin
  ExportHtml;
end;

procedure TFrmPreview.btnPdfClick(Sender: TObject);
begin
  ExportPdf;
end;

procedure TFrmPreview.btnXlsClick(Sender: TObject);
begin
  ExportXls;
end;

constructor TFrmPreview.Create(AModel: TDbModel);
begin
  inherited Create( nil );

  FModel := AModel;
  FManager := TReportManager.Create( nil, FModel.Connection );

  UpdateToolbar;

  FImgExport := nil;
end;

procedure TFrmPreview.ExportHtml;
var
  LFileType: TFileTypeItem;
  LExport: TFlexCelHtmlExport;

begin
  DlgSave.FileTypes.Clear;
  DlgSave.DefaultExtension := 'html';
  LFileType := DlgSave.FileTypes.Add;

  LFileType.DisplayName := 'Hypertext Markup Language Format (*.html)';
  LFileType.FileMask := '*.html';

  if DlgSave.Execute then
  begin
    LExport := TFlexCelHtmlExport.Create(FManager.LastReport);
    try
      LExport.Export(DlgSave.FileName, 'images' );
    finally
      LExport.Free;
    end;
  end;
end;

procedure TFrmPreview.ExportPdf;
var
  LFileType: TFileTypeItem;
  LExport: TFlexCelPdfExport;

begin
  DlgSave.FileTypes.Clear;
  DlgSave.DefaultExtension := 'pdf';
  LFileType := DlgSave.FileTypes.Add;

  LFileType.DisplayName := 'Adobe Portable Document Format  (*.pdf)';
  LFileType.FileMask := '*.pdf';

  LExport := nil;

  if DlgSave.Execute then
  begin
    LExport := TFlexCelPdfExport.Create( FManager.LastReport );
    try
      LExport.Export( DlgSave.FileName );
    finally
      LExport.Free;
    end;
  end;
end;

procedure TFrmPreview.ExportXls;
var
  LFileType: TFileTypeItem;
  LStream: TFileStream;

begin
  if Assigned( FManager.LastReport ) then
  begin
    DlgSave.FileTypes.Clear;
    DlgSave.DefaultExtension := 'xlsx';
    LFileType := DlgSave.FileTypes.Add;

    LFileType.DisplayName := 'Microsoft Excel (*.xlsx)';
    LFileType.FileMask := '*.xlsx';

    if DlgSave.Execute then
    begin
      FManager.LastReport.Save(DlgSave.FileName);
    end;
  end;
end;

procedure TFrmPreview.FormDestroy(Sender: TObject);
begin
  FManager.Free;
  FImgExport.Free;
end;

procedure TFrmPreview.UpdateReport;
begin
  if Assigned( FManager.LastReport ) then
  begin
    FImgExport.Free;

    // create an image export as import for preview
    FImgExport := TFlexCelImgExport.Create( FManager.LastReport );

    // assign the image export
    Preview.Document := FImgExport;

    // update the window
    Preview.InvalidatePreview;
  end;
end;

procedure TFrmPreview.UpdateToolbar;
var
  LEnabled: Boolean;

begin
  LEnabled := FManager.LastReport <> nil;

  btnHtml.Enabled := LEnabled;
  btnPdf.Enabled := LEnabled;
  btnXls.Enabled := LEnabled;
end;

procedure TFrmPreview.ShowParticipants(ASalesId: Integer);
begin
  FManager.ReportParticipants(ASalesId);
  UpdateReport;
  UpdateToolbar;

  self.ShowModal;
end;

end.
