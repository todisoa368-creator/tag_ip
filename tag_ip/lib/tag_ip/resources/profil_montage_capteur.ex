defmodule TagIp.Resources.ProfilMontageCapteur do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("profil_montage_capteurs")
    repo(TagIp.Repo)
  end

  identities do
    identity(:unique_profil_capteur, [:profil_montage_id, :capteur_id])
  end

  attributes do
    uuid_primary_key(:id)
    timestamps()
  end

  relationships do
    belongs_to :profil_montage, TagIp.Resources.ProfilMontage do
      allow_nil?(false)
      attribute_type(:uuid)
    end

    belongs_to :capteur, TagIp.Resources.Capteur do
      allow_nil?(false)
      attribute_type(:uuid)
    end
  end

  actions do
    defaults([:read, :destroy, :update, :create])
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
  end
end
