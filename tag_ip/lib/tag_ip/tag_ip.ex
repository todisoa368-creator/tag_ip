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
  end
end
