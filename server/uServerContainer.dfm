object ServerContainer: TServerContainer
  OnCreate = DataModuleCreate
  Height = 267
  Width = 410
  object SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher
    Left = 112
    Top = 32
  end
  object XDataServer: TXDataServer
    BaseUrl = 'http://+:80/'
    Dispatcher = SparkleHttpSysDispatcher
    EntitySetPermissions = <>
    SwaggerOptions.Enabled = True
    SwaggerUIOptions.Enabled = True
    SwaggerUIOptions.ShowFilter = True
    Left = 112
    Top = 104
    object ServerJWT: TSparkleJwtMiddleware
      OnGetSecret = ServerJWTGetSecret
    end
  end
end
