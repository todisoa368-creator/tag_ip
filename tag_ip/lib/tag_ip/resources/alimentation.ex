defmodule TagIp.Resources.Alimentation do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("alimentations")
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
      default("voltage")
      public?(true)
    end

    timestamps()
  end

  relationships do
    many_to_many :modeles_traceur, TagIp.Resources.ModeleTraceur do
      through(TagIp.Resources.ModeleTraceurAlimentation)
      source_attribute_on_join_resource(:alimentation_id)
      destination_attribute_on_join_resource(:modele_traceur_id)
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
