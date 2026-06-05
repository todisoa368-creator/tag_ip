defmodule TagIp.Resources.Peripheral do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("peripherals")
    repo(TagIp.Repo)
  end

  identities do
    identity(:unique_name, [:name])
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :description, :string do
      public?(true)
    end

    timestamps()
  end

  relationships do
    belongs_to :port_type, TagIp.Resources.PortType do
      allow_nil?(false)
      attribute_type(:uuid)
    end
  end

  actions do
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)
      accept([:name, :description, :port_type_id])
      upsert?(true)
      upsert_identity(:unique_name)
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
  end
end
