defmodule TagIp.Resources.ProfileComparaison do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("profile_comparaisons")
    repo(TagIp.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :feature_slugs, {:array, :string} do
      allow_nil?(false)
      default([])
      public?(true)
    end

    attribute :peripheral_ids, {:array, :uuid} do
      allow_nil?(false)
      default([])
      public?(true)
    end

    attribute :compatible_tracker_ids, {:array, :uuid} do
      allow_nil?(false)
      default([])
      public?(true)
    end

    attribute :user_id, :integer do
      allow_nil?(true)
      public?(true)
    end

    timestamps()
  end

  actions do
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)
      accept([:feature_slugs, :peripheral_ids, :compatible_tracker_ids, :user_id])
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
  end
end
