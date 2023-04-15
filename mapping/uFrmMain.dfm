object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'FrmMain'
  ClientHeight = 715
  ClientWidth = 912
  Color = clBtnFace
  Constraints.MinWidth = 850
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 21
  object AdvSplitter1: TAdvSplitter
    Left = 0
    Top = 523
    Width = 912
    Height = 5
    Cursor = crVSplit
    Align = alTop
    Appearance.BorderColor = clNone
    Appearance.BorderColorHot = clNone
    Appearance.Color = 12895944
    Appearance.ColorTo = 12895944
    Appearance.ColorHot = 15917525
    Appearance.ColorHotTo = 15917525
    GripStyle = sgDots
    ExplicitTop = 508
  end
  object Geocoding: TTMSFNCGeocoding
    Left = 8
    Top = 160
    Width = 26
    Height = 26
    Visible = True
    APIKey = '***REMOVED***'
    GeocodingRequests = <>
  end
  object Map: TTMSFNCGoogleMaps
    AlignWithMargins = True
    Left = 3
    Top = 148
    Width = 906
    Height = 373
    Margins.Bottom = 2
    Align = alTop
    ParentDoubleBuffered = False
    DoubleBuffered = True
    TabOrder = 1
    OnMapDblClick = MapMapDblClick
    APIKey = '***REMOVED***'
    Polylines = <>
    Polygons = <>
    Circles = <>
    Rectangles = <>
    Markers = <>
    Options.DefaultZoomLevel = 12.000000000000000000
    Options.BackgroundColor = clBlack
    Options.DisablePOI = False
    Options.Version = 'weekly'
    ElementContainers = <>
    HeadLinks = <>
    OnRetrievedDirectionsData = MapRetrievedDirectionsData
    KMLLayers = <>
    Directions = <>
    Clusters = <>
    OverlayViews = <>
    DesigntimeEnabled = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 912
    Height = 145
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      912
      145)
    object cbSales: TComboBox
      Left = 8
      Top = 16
      Width = 896
      Height = 29
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 0
      OnChange = cbSalesChange
    end
    object btnGeocode: TButton
      Left = 8
      Top = 51
      Width = 182
      Height = 41
      Caption = 'Geocode participants'
      Enabled = False
      TabOrder = 1
      OnClick = btnGeocodeClick
    end
    object btnMarker: TButton
      Left = 196
      Top = 51
      Width = 182
      Height = 41
      Caption = 'Locate participants'
      Enabled = False
      TabOrder = 2
      OnClick = btnMarkerClick
    end
    object btnRoute: TButton
      Left = 384
      Top = 51
      Width = 182
      Height = 41
      Caption = 'Calculate optimal route'
      Enabled = False
      TabOrder = 3
      OnClick = btnRouteClick
    end
    object txtHome: TEdit
      Left = 8
      Top = 98
      Width = 896
      Height = 29
      ReadOnly = True
      TabOrder = 4
      Text = '10611 Chevrolet Way, Estero, FL 33928, USA'
    end
    object ListView1: TListView
      Left = 368
      Top = 136
      Width = 250
      Height = 150
      Columns = <>
      TabOrder = 5
    end
  end
  object Routes: TListView
    Left = 0
    Top = 528
    Width = 912
    Height = 187
    Align = alClient
    Columns = <>
    HotTrack = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 3
    ExplicitLeft = 56
    ExplicitTop = 568
    ExplicitWidth = 250
    ExplicitHeight = 150
  end
end
