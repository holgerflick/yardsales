object DbModel: TDbModel
  OnCreate = DataModuleCreate
  Height = 339
  Width = 495
  object Connection: TFDConnection
    Params.Strings = (
      'Database=yardsales'
      'User_Name=holger'
      'Password=masterkey'
      'Server=192.168.0.11'
      'DriverID=MySQL')
    Connected = True
    LoginPrompt = False
    Left = 56
    Top = 80
  end
  object Sales: TFDQuery
    ActiveStoredUsage = []
    OnCalcFields = SalesCalcFields
    Connection = Connection
    SQL.Strings = (
      'SELECT * FROM YardSales ORDER BY EventStart DESC')
    Left = 176
    Top = 80
    object SalesEventDates: TStringField
      FieldKind = fkCalculated
      FieldName = 'EventDates'
      Size = 50
      Calculated = True
    end
    object SalesId: TFDAutoIncField
      FieldName = 'Id'
      Origin = 'Id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object SalesEventStart: TDateTimeField
      FieldName = 'EventStart'
      Origin = 'EventStart'
      Required = True
    end
    object SalesEventEnd: TDateTimeField
      FieldName = 'EventEnd'
      Origin = 'EventEnd'
      Required = True
    end
    object SalesTitle: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'Title'
      Origin = 'Title'
      Size = 340
    end
    object SalesLogo: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'Logo'
      Origin = 'Logo'
    end
    object SalesThumb: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'Thumb'
      Origin = 'Thumb'
    end
  end
  object Participants: TFDQuery
    ActiveStoredUsage = []
    OnCalcFields = ParticipantsCalcFields
    Connection = Connection
    SQL.Strings = (
      'SELECT * FROM SalesParticipant P  '
      '  LEFT JOIN Locations L ON L.Id = P.Id'
      '  WHERE SalesId = :SalesId')
    Left = 264
    Top = 80
    ParamData = <
      item
        Name = 'SALESID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 2
      end>
    object ParticipantsCategories: TStringField
      FieldKind = fkCalculated
      FieldName = 'Categories'
      Size = 500
      Calculated = True
    end
    object ParticipantsId: TFDAutoIncField
      FieldName = 'Id'
      Origin = 'Id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object ParticipantsEmail: TWideStringField
      FieldName = 'Email'
      Origin = 'Email'
      Required = True
      Size = 133
    end
    object ParticipantsSalesId: TLongWordField
      FieldName = 'SalesId'
      Origin = 'SalesId'
      Required = True
    end
    object ParticipantsName: TWideStringField
      FieldName = 'Name'
      Origin = '`Name`'
      Required = True
      Size = 133
    end
    object ParticipantsStreet: TWideStringField
      FieldName = 'Street'
      Origin = 'Street'
      Required = True
      Size = 133
    end
    object ParticipantsZip: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'Zip'
      Origin = 'Zip'
      FixedChar = True
      Size = 6
    end
    object ParticipantsCity: TWideStringField
      FieldName = 'City'
      Origin = 'City'
      Required = True
      Size = 133
    end
    object ParticipantsState: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'State'
      Origin = 'State'
      FixedChar = True
      Size = 2
    end
    object ParticipantsMapUrl: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'MapUrl'
      Origin = 'MapUrl'
      Size = 1365
    end
    object ParticipantsLongitude: TFloatField
      AutoGenerateValue = arDefault
      FieldName = 'Longitude'
      Origin = 'Longitude'
      ProviderFlags = []
      ReadOnly = True
    end
    object ParticipantsLatitude: TFloatField
      AutoGenerateValue = arDefault
      FieldName = 'Latitude'
      Origin = 'Latitude'
      ProviderFlags = []
      ReadOnly = True
    end
    object ParticipantsCreated: TDateTimeField
      AutoGenerateValue = arDefault
      FieldName = 'Created'
      Origin = 'Created'
      ProviderFlags = []
      ReadOnly = True
    end
    object ParticipantsAddress: TStringField
      FieldKind = fkCalculated
      FieldName = 'Address'
      Size = 500
      Calculated = True
    end
  end
  object ParticipantCategories: TFDQuery
    ActiveStoredUsage = []
    MasterSource = sourceParticipants
    MasterFields = 'Id'
    Connection = Connection
    SQL.Strings = (
      'SELECT Id, Name FROM ParticipantItemCategories'
      '  LEFT JOIN ItemCategories i ON i.Id = IdCategory'
      '  WHERE IdParticipant = :Id '
      '  ')
    Left = 376
    Top = 152
    ParamData = <
      item
        Name = 'ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 11
      end>
  end
  object sourceParticipants: TDataSource
    DataSet = Participants
    Left = 376
    Top = 80
  end
  object ParticipantLocations: TFDQuery
    ActiveStoredUsage = []
    MasterSource = sourceParticipants
    MasterFields = 'Id'
    Connection = Connection
    SQL.Strings = (
      'SELECT Latitude, Longitude FROM Locations L'
      '  WHERE L.Id = :Id ')
    Left = 376
    Top = 224
    ParamData = <
      item
        Name = 'ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 11
      end>
  end
  object NeedLocation: TFDQuery
    ActiveStoredUsage = []
    Connection = Connection
    SQL.Strings = (
      
        'SELECT P.Id, CONCAT( Street, ",", City, ",", State, " ", Zip ) A' +
        'S Address, Latitude, Longitude FROM SalesParticipant P  '
      '  LEFT JOIN Locations L ON L.Id = P.Id'
      '  WHERE (SalesId = :SalesId) AND (Latitude IS NULL)')
    Left = 48
    Top = 176
    ParamData = <
      item
        Name = 'SALESID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 2
      end>
  end
  object UpdateLocation: TFDQuery
    ActiveStoredUsage = []
    Connection = Connection
    SQL.Strings = (
      'REPLACE INTO Locations'
      '  (Id, Latitude, Longitude, Created ) VALUES'
      '  (:Id, :Latitude, :Longitude, UTC_TIMESTAMP() )'
      '')
    Left = 48
    Top = 256
    ParamData = <
      item
        Name = 'ID'
        ParamType = ptInput
      end
      item
        Name = 'LATITUDE'
        ParamType = ptInput
      end
      item
        Name = 'LONGITUDE'
        ParamType = ptInput
      end>
  end
end
