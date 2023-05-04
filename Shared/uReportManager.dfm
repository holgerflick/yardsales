object ReportManager: TReportManager
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 228
  Width = 411
  object Sale: TFDQuery
    ActiveStoredUsage = []
    OnCalcFields = SaleCalcFields
    SQL.Strings = (
      'SELECT * FROM YardSales WHERE Id = :Id')
    Left = 40
    Top = 48
    ParamData = <
      item
        Name = 'ID'
        ParamType = ptInput
      end>
    object SaleEventDates: TStringField
      FieldKind = fkCalculated
      FieldName = 'EventDates'
      Size = 50
      Calculated = True
    end
    object SaleId: TFDAutoIncField
      FieldName = 'Id'
      Origin = 'Id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object SaleEventStart: TDateTimeField
      FieldName = 'EventStart'
      Origin = 'EventStart'
      Required = True
    end
    object SaleEventEnd: TDateTimeField
      FieldName = 'EventEnd'
      Origin = 'EventEnd'
      Required = True
    end
    object SaleTitle: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'Title'
      Origin = 'Title'
      Size = 340
    end
    object SaleLogo: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'Logo'
      Origin = 'Logo'
    end
    object SaleThumb: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'Thumb'
      Origin = 'Thumb'
    end
  end
  object Participants: TFDQuery
    ActiveStoredUsage = []
    OnCalcFields = ParticipantsCalcFields
    SQL.Strings = (
      'SELECT * FROM SalesParticipant P  '
      '  LEFT JOIN Locations L ON L.Id = P.Id'
      '  WHERE SalesId = :SalesId')
    Left = 120
    Top = 48
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
      ReadOnly = True
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
    SQL.Strings = (
      'SELECT Id, Name FROM ParticipantItemCategories'
      '  LEFT JOIN ItemCategories i ON i.Id = IdCategory'
      '  WHERE IdParticipant = :Id '
      '  ')
    Left = 240
    Top = 120
    ParamData = <
      item
        Name = 'ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 999
      end>
  end
  object sourceParticipants: TDataSource
    DataSet = Participants
    Left = 240
    Top = 48
  end
end
