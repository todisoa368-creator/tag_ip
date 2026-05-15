defmodule TagIp.Resources do
  use Ash.Domain

  resources do
    resource TagIp.Resources.ProfilMontage do
      # Vérifie que l'action :create est autorisée ici si nécessaire
      # Mais avec tes policies "authorize_all", ça devrait passer.
    end

    resource TagIp.Resources.TrackableType do
    end
  end
end
