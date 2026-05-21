defmodule TagIp.Resources.ModelFeature do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("model_features")
    repo(TagIp.Repo)
  end

  identities do
    identity(:unique_modele_feature, [:modele_traceur_id, :feature_id])
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

    belongs_to :feature, TagIp.Resources.Feature do
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
