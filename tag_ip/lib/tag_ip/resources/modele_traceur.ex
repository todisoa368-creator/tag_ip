defmodule TagIp.Resources.ModeleTraceur do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("modeles_traceur")
    repo(TagIp.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :nom, :string do
      allow_nil?(false)
      constraints(max_length: 100)
      public?(true)
    end

    attribute :reference, :string do
      allow_nil?(false)
      constraints(max_length: 50)
      public?(true)
    end

    attribute :types_vehicule_compatibles, {:array, :string} do
      default([])
      public?(true)
    end

    attribute :alimentations_compatibles, {:array, :string} do
      default([])
      public?(true)
    end

    attribute :capteurs_supportes, {:array, :string} do
      default([])
      public?(true)
    end

    attribute :description, :string do
      constraints(max_length: 500)
      public?(true)
    end

    timestamps()
  end

  actions do
    create :create do
      accept([
        :nom,
        :reference,
        :types_vehicule_compatibles,
        :alimentations_compatibles,
        :capteurs_supportes,
        :description
      ])
    end

    defaults([:read, :update, :destroy])

    read :get_by_id do
      argument(:id, :uuid, allow_nil?: false)
      filter(expr(id == ^arg(:id)))
    end

    read :list do
      pagination(offset?: true, countable: :by_default)
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
    define(:get_by_id, action: :get_by_id, args: [:id])
    define(:list, action: :list)
  end
end
