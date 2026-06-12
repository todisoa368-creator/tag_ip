defmodule TagIp.TagIp do
  use Ash.Domain

  resources do
    resource(TagIp.Resources.ProfilMontage)
    resource(TagIp.Resources.ModeleTraceur)
    resource(TagIp.Resources.Compatibilite)
    resource(TagIp.Resources.TypeVehicule)
    resource(TagIp.Resources.Alimentation)
    resource(TagIp.Resources.Capteur)
    resource(TagIp.Resources.ModeleTraceurTypeVehicule)
    resource(TagIp.Resources.ModeleTraceurAlimentation)
    resource(TagIp.Resources.ModeleTraceurCapteur)
    resource(TagIp.Resources.PortType)
    resource(TagIp.Resources.Feature)
    resource(TagIp.Resources.ModelFeature)
    resource(TagIp.Resources.ModelPort)
    resource(TagIp.Resources.Peripheral)
    resource(TagIp.Resources.ProfilMontageCapteur)
    resource(TagIp.Resources.ProfilMontagePeripheral)
    resource(TagIp.Resources.TrackableType)
    resource(TagIp.Resources.Organisation)
  end
end
