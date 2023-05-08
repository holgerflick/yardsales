object DbController: TDbController
  OnCreate = WebDataModuleCreate
  Height = 147
  Width = 312
  object Client: TXDataWebClient
    Connection = Connection
    Left = 120
    Top = 48
  end
  object Connection: TXDataWebConnection
    URL = 'http://192.168.0.58:2011'
    OnConnect = ConnectionConnect
    OnError = ConnectionError
    Left = 32
    Top = 48
  end
  object ItemCategories: TWebClientDataSet
    Params = <>
    Left = 208
    Top = 48
    object ItemCategoriesId: TIntegerField
      FieldName = 'Id'
    end
    object ItemCategoriesName: TStringField
      FieldName = 'Name'
      Size = 200
    end
  end
end
