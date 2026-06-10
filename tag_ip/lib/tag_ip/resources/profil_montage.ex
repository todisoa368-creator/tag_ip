defmodule TagIp.Resources.ProfilMontage do
  use Ash.Resource,
    domain: TagIp.TagIp,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key(:id)

    attribute(:name, :string, allow_nil?: false, public?: true)
    attribute(:description, :string, public?: true)
    attribute(:reporting_interval, :string, default: "interval_30s", public?: true)
    attribute(:object_type, :string, public?: true)
    attribute(:voltage_min, :float, public?: true)
    attribute(:voltage_max, :float, public?: true)

    # Options matérielles
    attribute(:buzzer, :boolean, default: false, public?: true)
    attribute(:fuel_probe_type, :string, public?: true)
    attribute(:geofence_enabled, :boolean, default: false, public?: true)
    attribute(:driver_id_type, :string, public?: true)

    # Interfaces de communication
    attribute(:can_bus_requis, :boolean, default: false, public?: true)
    attribute(:one_wire_requis, :boolean, default: false, public?: true)
    attribute(:rs232_requis, :boolean, default: false, public?: true)
    attribute(:rs485_requis, :boolean, default: false, public?: true)
    attribute(:bluetooth_ble_requis, :boolean, default: false, public?: true)

    # Entrées/Sorties (I/O)
    attribute(:inputs_requis, :integer, public?: true)
    attribute(:analog_inputs_requis, :integer, public?: true)
    attribute(:outputs_requis, :integer, public?: true)

    # Environnement et Protection Physique
    attribute(:montage_exterieur, :boolean, default: false, public?: true)
    attribute(:antenne_deportee, :boolean, default: false, public?: true)

    # Intelligence Embarquée
    attribute(:accelerometre_requis, :boolean, default: false, public?: true)

    # Énergie
    attribute(:ultra_low_power_requis, :boolean, default: false, public?: true)

    attribute(:feature_slugs, {:array, :string}, default: [], public?: true)
    attribute(:organization_id, :uuid, public?: true)

    timestamps()
  end

  relationships do
    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur do
      allow_nil?(true)
      attribute_type(:uuid)
    end

    has_many :compatibilites, TagIp.Resources.Compatibilite

    many_to_many :capteurs, TagIp.Resources.Capteur do
      through(TagIp.Resources.ProfilMontageCapteur)
      source_attribute_on_join_resource(:profil_montage_id)
      destination_attribute_on_join_resource(:capteur_id)
    end

    many_to_many :peripherals, TagIp.Resources.Peripheral do
      through(TagIp.Resources.ProfilMontagePeripheral)
      source_attribute_on_join_resource(:profil_montage_id)
      destination_attribute_on_join_resource(:peripheral_id)
    end
  end

  actions do
    default_accept(:*)
    defaults([:read, :destroy, :update])

    create :create do
      primary?(true)

      accept([
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
        :organization_id,
        :inputs_requis,
        :analog_inputs_requis,
        :outputs_requis,
        :can_bus_requis,
        :one_wire_requis,
        :rs232_requis,
        :rs485_requis,
        :bluetooth_ble_requis,
        :accelerometre_requis,
        :montage_exterieur,
        :antenne_deportee,
        :ultra_low_power_requis,
        :feature_slugs,
        :modele_traceur_id
      ])
    end

    read :get_by_id do
      argument(:id, :uuid, allow_nil?: false)
      filter(expr(id == ^arg(:id)))
      get?(true)
    end
  end

  code_interface do
    define(:create)
    define(:read)
    define(:update)
    define(:destroy)
    define(:get_by_id, args: [:id])
  end

  postgres do
    table("mounting_profiles")
    repo(TagIp.Repo)
  end
end
