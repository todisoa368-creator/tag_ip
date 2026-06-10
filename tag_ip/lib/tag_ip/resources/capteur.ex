defmodule TagIp.Resources.Capteur do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("capteurs")
    repo(TagIp.Repo)
  end

  identities do
    identity(:unique_slug, [:slug])
  end

  attributes do
    uuid_primary_key(:id)

    attribute :slug, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :label, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :description, :string do
      public?(true)
    end

    attribute :category, :string do
      public?(true)
    end

    timestamps()
  end

  relationships do
    many_to_many :modeles_traceur, TagIp.Resources.ModeleTraceur do
      through(TagIp.Resources.ModeleTraceurCapteur)
      source_attribute_on_join_resource(:capteur_id)
      destination_attribute_on_join_resource(:modele_traceur_id)
    end

    many_to_many :profils_montage, TagIp.Resources.ProfilMontage do
      through(TagIp.Resources.ProfilMontageCapteur)
      source_attribute_on_join_resource(:capteur_id)
      destination_attribute_on_join_resource(:profil_montage_id)
    end
  end

  actions do
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)
      accept([:slug, :label, :description, :category])
      upsert?(true)
      upsert_identity(:unique_slug)
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
  end
end
