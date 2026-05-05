defmodule TagIp.Resources.Compatibilite do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "compatibilites"
    repo TagIp.Repo
  end

  actions do
  defaults [:create, :read, :update, :destroy]

  # Pour corriger le warning Compatibilite.get_by_id!
  read :get_by_id do
    argument :id, :uuid, allow_nil?: false
    get? true
    filter expr(id == ^arg(:id))
  end

  # Pour corriger le warning calculer_compatibilite/2
  action :calculer_compatibilite, :struct do
    argument :profil_id, :uuid, allow_nil?: false
    argument :modele_id, :uuid, allow_nil?: false
    run fn inputs, _ ->
      # Simulation pour ton test d'interface
      {:ok, %{score_compatibilite: 100, details: "Analyse réussie"}}
    end
  end
end

  attributes do
    uuid_primary_key :id

    attribute :score_compatibilite, :integer do
      allow_nil? false
    end

    attribute :details, :string

    timestamps()
  end

  relationships do
    belongs_to :profil_montage, TagIp.Resources.ProfilMontage do
      allow_nil? false
      attribute_type :uuid
    end

    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur do
      allow_nil? false
      attribute_type :uuid
    end
  end
end
