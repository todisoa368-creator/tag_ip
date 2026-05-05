defmodule TagIp.Resources.ProfilMontage do
  use Ash.Resource,
    domain: TagIp.Resources,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    attribute :reporting_interval, :string, public?: true
    attribute :object_type, :string, public?: true
    attribute :voltage_min, :float, public?: true
    attribute :voltage_max, :float, public?: true
    attribute :buzzer, :boolean, default: false, public?: true
    attribute :fuel_probe_type, :string, public?: true
    attribute :geofence_enabled, :boolean, default: false, public?: true
    attribute :driver_id_type, :string, public?: true
    attribute :organization_id, :uuid, public?: true

    timestamps()
  end

  actions do
    defaults [:read, :destroy, :update]

    create :create do
      primary? true
      accept [
        :name,
        :description,
        :reporting_interval,
        :object_type,
        :voltage_min,
        :voltage_max,
        :buzzer,
        :fuel_probe_type,
        :geofence_enabled,
        :driver_id_type,
        :organization_id
      ]
    end
  end

  policies do
    # Remplaçons l'importation par la condition la plus simple possible
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "mounting_profiles"
    repo TagIp.Repo
  end
end
