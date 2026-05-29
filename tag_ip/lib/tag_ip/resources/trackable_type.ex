defmodule TagIp.Resources.TrackableType do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("trackable_types")
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

    timestamps()
  end

  actions do
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)

      accept([
        :slug,
        :label,
        :description
      ])

      upsert?(true)
      upsert_identity(:unique_slug)
    end

    read :get_by_id do
      argument(:id, :uuid, allow_nil?: false)
      filter(expr(id == ^arg(:id)))
      get?(true)
    end

    read :get_by_slug do
      argument(:slug, :string, allow_nil?: false)
      filter(expr(slug == ^arg(:slug)))
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
    define(:get_by_id, args: [:id])
    define(:get_by_slug, args: [:slug])
  end
end
