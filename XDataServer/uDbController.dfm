object DbController: TDbController
  OnCreate = DataModuleCreate
  Height = 296
  Width = 518
  object Manager: TFDManager
    ConnectionDefFileAutoLoad = False
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 88
    Top = 40
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 88
    Top = 152
  end
end
