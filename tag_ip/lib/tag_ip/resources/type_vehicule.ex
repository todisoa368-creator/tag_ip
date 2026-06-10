defmodule TagIp.Resources.TypeVehicule do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("types_vehicule")
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

    attribute :voltage_min, :float do
      public?(true)
    end

    attribute :voltage_max, :float do
      public?(true)
    end

    attribute :inputs_requis, :integer do
      public?(true)
    end

    attribute :outputs_requis, :integer do
      public?(true)
    end

    timestamps()
  end

  relationships do
    many_to_many :modeles_traceur, TagIp.Resources.ModeleTraceur do
      through(TagIp.Resources.ModeleTraceurTypeVehicule)
      source_attribute_on_join_resource(:type_vehicule_id)
      destination_attribute_on_join_resource(:modele_traceur_id)
    end
  end

  actions do
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)

      accept([
        :slug,
        :label,
        :description,
        :voltage_min,
        :voltage_max,
        :inputs_requis,
        :outputs_requis
      ])

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
