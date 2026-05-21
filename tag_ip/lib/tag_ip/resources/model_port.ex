defmodule TagIp.Resources.ModelPort do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("model_ports")
    repo(TagIp.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :pin_label, :string do
      allow_nil?(false)
      public?(true)
    end

    timestamps()
  end

  relationships do
    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur do
      allow_nil?(false)
      attribute_type(:uuid)
    end

    belongs_to :port_type, TagIp.Resources.PortType do
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
