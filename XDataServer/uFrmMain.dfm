object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Yard Sales Server'
  ClientHeight = 386
  ClientWidth = 444
  Color = clBtnFace
  Constraints.MinWidth = 460
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  DesignSize = (
    444
    386)
  TextHeight = 18
  object mmInfo: TMemo
    Left = 8
    Top = 55
    Width = 428
    Height = 323
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    ExplicitWidth = 421
  end
  object btStart: TButton
    Left = 8
    Top = 8
    Width = 137
    Height = 41
    Caption = 'Start'
    TabOrder = 1
    OnClick = btStartClick
  end
  object btStop: TButton
    Left = 151
    Top = 8
    Width = 137
    Height = 41
    Caption = 'Stop'
    TabOrder = 2
    OnClick = btStopClick
  end
  object btSwagger: TButton
    Left = 299
    Top = 8
    Width = 137
    Height = 41
    Anchors = [akTop, akRight]
    Caption = 'Swagger UI'
    TabOrder = 3
    OnClick = btSwaggerClick
    ExplicitLeft = 390
  end
end
