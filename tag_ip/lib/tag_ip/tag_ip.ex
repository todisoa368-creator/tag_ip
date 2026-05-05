defmodule TagIp.TagIp do
  use Ash.Domain

  resources do
    resource(TagIp.Resources.ProfilMontage)
    resource(TagIp.Resources.ModeleTraceur)
    resource(TagIp.Resources.Compatibilite)
  end
end
