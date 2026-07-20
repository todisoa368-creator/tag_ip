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

    timestamps()
  end

  relationships do
    belongs_to :modele_traceur, TagIp.Resources.ModeleTraceur do
      allow_nil?(true)
      attribute_type(:uuid)
    end

    belongs_to :type_vehicule, TagIp.Resources.TypeVehicule do
      allow_nil?(true)
      attribute_type(:uuid)
    end

    belongs_to :organisation, TagIp.Resources.Organisation do
      allow_nil?(true)
      attribute_type(:uuid)
    end

    belongs_to :alimentation, TagIp.Resources.Alimentation do
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
    defaults([:read, :destroy])

    update :update do
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
        :organisation_id,
        :alimentation_id,
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
        :modele_traceur_id,
        :type_vehicule_id
      ])
    end

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
        :organisation_id,
        :alimentation_id,
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
        :modele_traceur_id,
        :type_vehicule_id
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

  def duplicate(id) do
    source =
      __MODULE__
      |> Ash.get!(id, load: [:capteurs, :peripherals])

    attrs = %{
      name: source.name,
      description: source.description,
      reporting_interval: source.reporting_interval,
      object_type: source.object_type,
      type_vehicule_id: source.type_vehicule_id,
      organisation_id: source.organisation_id,
      alimentation_id: source.alimentation_id,
      voltage_min: source.voltage_min,
      voltage_max: source.voltage_max,
      buzzer: source.buzzer,
      fuel_probe_type: source.fuel_probe_type,
      geofence_enabled: source.geofence_enabled,
      driver_id_type: source.driver_id_type,
      can_bus_requis: source.can_bus_requis,
      one_wire_requis: source.one_wire_requis,
      rs232_requis: source.rs232_requis,
      rs485_requis: source.rs485_requis,
      bluetooth_ble_requis: source.bluetooth_ble_requis,
      inputs_requis: source.inputs_requis,
      analog_inputs_requis: source.analog_inputs_requis,
      outputs_requis: source.outputs_requis,
      montage_exterieur: source.montage_exterieur,
      antenne_deportee: source.antenne_deportee,
      accelerometre_requis: source.accelerometre_requis,
      ultra_low_power_requis: source.ultra_low_power_requis
    }

    case __MODULE__.create(attrs) do
      {:ok, new_profil} ->
        source_capteur_ids = Enum.map(source.capteurs || [], & &1.id)
        sync_capteurs(new_profil.id, source_capteur_ids)

        source_peripheral_ids = Enum.map(source.peripherals || [], & &1.id)
        sync_peripherals(new_profil.id, source_peripheral_ids)

        {:ok, new_profil}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def sync_capteurs(profil_id, selected_ids) do
    existing =
      TagIp.Resources.ProfilMontageCapteur.read!()
      |> Enum.filter(&(&1.profil_montage_id == profil_id))

    Enum.each(existing, &TagIp.Resources.ProfilMontageCapteur.destroy(&1))

    Enum.each(selected_ids, fn id ->
      TagIp.Resources.ProfilMontageCapteur.create(%{
        profil_montage_id: profil_id,
        capteur_id: id
      })
    end)
  end

  def sync_peripherals(profil_id, selected_ids) do
    existing =
      TagIp.Resources.ProfilMontagePeripheral.read!()
      |> Enum.filter(&(&1.profil_montage_id == profil_id))

    Enum.each(existing, &TagIp.Resources.ProfilMontagePeripheral.destroy(&1))

    Enum.each(selected_ids, fn id ->
      TagIp.Resources.ProfilMontagePeripheral.create(%{
        profil_montage_id: profil_id,
        peripheral_id: id
      })
    end)
  end

  def compute_compatibilities(profil_id) do
    profil =
      __MODULE__
      |> Ash.get!(profil_id)
      |> Ash.load!([:capteurs, :peripherals])

    capteur_slugs = Enum.map(profil.capteurs || [], & &1.slug)
    peripheral_ids = Enum.map(profil.peripherals || [], & &1.id)

    profil_params = %{
      "object_type" => profil.object_type,
      "voltage_min" => profil.voltage_min,
      "voltage_max" => profil.voltage_max,
      "can_bus_requis" => profil.can_bus_requis,
      "one_wire_requis" => profil.one_wire_requis,
      "rs232_requis" => profil.rs232_requis,
      "rs485_requis" => profil.rs485_requis,
      "bluetooth_ble_requis" => profil.bluetooth_ble_requis,
      "inputs_requis" => profil.inputs_requis,
      "analog_inputs_requis" => profil.analog_inputs_requis,
      "outputs_requis" => profil.outputs_requis,
      "montage_exterieur" => profil.montage_exterieur,
      "antenne_deportee" => profil.antenne_deportee,
      "accelerometre_requis" => profil.accelerometre_requis,
      "ultra_low_power_requis" => profil.ultra_low_power_requis,
      "buzzer" => profil.buzzer,
      "geofence_enabled" => profil.geofence_enabled,
      "fuel_probe_type" => profil.fuel_probe_type
    }

    modeles =
      TagIp.Resources.ModeleTraceur
      |> Ash.read!(page: [limit: 50], load: [:types_vehicule, :alimentations, :capteurs])

    compatibilities =
      modeles.results
      |> Enum.map(fn modele ->
        result =
          TagIp.Resources.Compatibilite.calculer_depuis_params(
            profil_params,
            modele,
            capteur_slugs,
            peripheral_ids
          )

        %{modele: modele, compatible: result.compatible, score: result.score}
      end)
      |> Enum.sort_by(fn c -> -c.score end)

    for compat <- compatibilities, compat.compatible do
      TagIp.Resources.Compatibilite
      |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
        profil_id: profil_id,
        modele_id: compat.modele.id
      })
      |> Ash.run_action!()
    end

    length(compatibilities)
  end

  postgres do
    table("mounting_profiles")
    repo(TagIp.Repo)
  end
end
