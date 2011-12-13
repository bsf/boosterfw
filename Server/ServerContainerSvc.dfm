object ServerContainer2: TServerContainer2
  OldCreateOrder = False
  DisplayName = 'Booster Server'
  OnStart = ServiceStart
  Height = 271
  Width = 415
  object DSServer1: TDSServer
    AutoStart = True
    HideDSAdmin = False
    Left = 176
    Top = 11
  end
  object DSTCPServerTransport1: TDSTCPServerTransport
    PoolSize = 0
    Server = DSServer1
    BufferKBSize = 32
    Filters = <>
    Left = 48
    Top = 81
  end
  object DSHTTPService1: TDSHTTPService
    DSContext = 'datasnap/'
    RESTContext = 'rest/'
    CacheContext = 'cache/'
    Server = DSServer1
    DSHostname = 'localhost'
    DSPort = 211
    Filters = <>
    CredentialsPassThrough = False
    SessionTimeout = 1200000
    HttpPort = 8080
    Active = False
    Left = 48
    Top = 15
  end
  object DSServerClass1: TDSServerClass
    OnGetClass = DSServerClass1GetClass
    Server = DSServer1
    LifeCycle = 'Session'
    Left = 272
    Top = 11
  end
end
