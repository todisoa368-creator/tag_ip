defmodule TagIp.Resources.ModeleTraceurTypeVehicule do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("modeles_traceur_types_vehicule")
    repo(TagIp.Repo)
  end

  identities do
    identity(:unique_modele_type, [:modele_traceur_id, :type_vehicule_id])
  end

  attributes do
    uuid_primary_key(:id)
    timestamps()
  end

  relationships do
    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur do
      allow_nil?(false)
      attribute_type(:uuid)
    end

    belongs_to :type_vehicule, TagIp.Resources.TypeVehicule do
      allow_nil?(false)
      attribute_type(:uuid)
    end
  end

  actions do
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)
      upsert?(true)
      upsert_identity(:unique_modele_type)

      accept([:modele_traceur_id, :type_vehicule_id])
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
  end
end
