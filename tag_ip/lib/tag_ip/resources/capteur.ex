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

    timestamps()
  end

  actions do
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)
      accept([:slug, :label])
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
