object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'FrmMain'
  ClientHeight = 674
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
  DesignSize = (
    912
    674)
  TextHeight = 21
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
  object btnRoute: TButton
    Left = 384
    Top = 51
    Width = 182
    Height = 41
    Caption = 'Calculate optimal route'
    Enabled = False
    TabOrder = 1
    OnClick = btnRouteClick
  end
  object Map: TTMSFNCMaps
    Left = 8
    Top = 98
    Width = 896
    Height = 568
    ParentDoubleBuffered = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    DoubleBuffered = True
    TabOrder = 2
    APIKey = '***REMOVED***'
    Polylines = <>
    Polygons = <>
    Circles = <>
    Rectangles = <>
    Markers = <>
    ElementContainers = <>
    Labels = <>
    HeadLinks = <>
    Options.DefaultZoomLevel = 12.000000000000000000
    DesigntimeEnabled = False
  end
  object btnMarker: TButton
    Left = 196
    Top = 51
    Width = 182
    Height = 41
    Caption = 'Locate participants'
    Enabled = False
    TabOrder = 3
    OnClick = btnMarkerClick
  end
  object Geocoding: TTMSFNCGeocoding
    Left = 8
    Top = 19
    Width = 26
    Height = 26
    Visible = True
    APIKey = '***REMOVED***'
    GeocodingRequests = <>
  end
  object btnGeocode: TButton
    Left = 8
    Top = 51
    Width = 182
    Height = 41
    Caption = 'Geocode participants'
    Enabled = False
    TabOrder = 5
    OnClick = btnMarkerClick
  end
  object Routing: TTMSFNCRouteCalculator
    Left = 664
    Top = 64
    Width = 26
    Height = 26
    Visible = True
    APIKey = '***REMOVED***'
    Routes = <>
  end
end
