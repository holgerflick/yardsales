object DbController: TDbController
  OnCreate = WebDataModuleCreate
  Height = 311
  Width = 372
  object Client: TXDataWebClient
    Connection = Connection
    Left = 104
    Top = 64
  end
  object Connection: TXDataWebConnection
    URL = 'https://yardsales.flixengineering.freemyip.com'
    OnConnect = ConnectionConnect
    OnError = ConnectionError
    Left = 104
    Top = 152
  end
  object ItemCategories: TWebClientDataSet
    Params = <>
    Left = 104
    Top = 232
    object ItemCategoriesId: TIntegerField
      FieldName = 'Id'
    end
    object ItemCategoriesName: TStringField
      FieldName = 'Name'
      Size = 200
    end
  end
end
