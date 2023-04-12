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
    RoutingPrecedence = Service
    InstanceLoopHandling = Error
    EntitySetPermissions = <>
    SwaggerOptions.Enabled = True
    SwaggerOptions.AuthMode = Jwt
    SwaggerUIOptions.Enabled = True
    SwaggerUIOptions.ShowFilter = True
    SwaggerUIOptions.DocExpansion = None
    SwaggerUIOptions.DisplayOperationId = True
    Left = 112
    Top = 104
    object ServerJWT: TSparkleJwtMiddleware
      OnGetSecret = ServerJWTGetSecret
    end
    object XDataServerCORS: TSparkleCorsMiddleware
      Origin = 'https://webdev.flixengineering.freemyip.com'
    end
  end
end
