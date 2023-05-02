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
    Connection = Connection
    SQL.Strings = (
      'SELECT * FROM YardSales ORDER BY EventStart DESC')
    Left = 176
    Top = 80
  end
  object Participants: TFDQuery
    ActiveStoredUsage = []
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
