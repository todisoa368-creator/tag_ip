defmodule TagIp.Resources.CapabilityMatrix do
  @moduledoc """
  Validation de la matrice de capacités pour l'Assistant de création de profils.

  Vérifie que les fonctionnalités sélectionnées à l'étape 3 sont bien supportées
  par le modèle choisi à l'étape 2, conformément au référentiel de capacités.
  """

  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Feature

  @matrix_slugs ~w(alert_button buzzer_feature driver_id green_driving fuel_cap fuel_analog fuel_rs232 fuel_ble fuel_can crash_detection)

  @doc """
  Liste des slugs de fonctionnalités de la matrice de capacités.
  """
  def matrix_feature_slugs, do: @matrix_slugs

  @doc """
  Récupère toutes les fonctionnalités de la matrice de capacités (structs complets).
  """
  def matrix_features do
    Feature
    |> Ash.read!()
    |> Enum.filter(&(&1.slug in @matrix_slugs))
  end

  @doc """
  Récupère les slugs des fonctionnalités supportées par un modèle.
  """
  def supported_feature_slugs(modele_id) do
    modele =
      ModeleTraceur
      |> Ash.get!(modele_id)
      |> Ash.load!([:features])

    Enum.map(modele.features, & &1.slug)
  end

  @doc """
  Filtre les features de la matrice pour ne garder que celles supportées par le modèle.

  Retourne une liste de `%Feature{}`.
  """
  def filter_matrix_features_for_model(modele_id, all_matrix_features \\ nil) do
    supported = supported_feature_slugs(modele_id) |> MapSet.new()
    features = all_matrix_features || matrix_features()

    Enum.filter(features, &MapSet.member?(supported, &1.slug))
  end

  @doc """
  Vérifie que toutes les fonctionnalités sélectionnées sont supportées par le modèle.

  Retourne `:ok` ou `{:error, [unsupported_slug, ...]}`.
  """
  def validate_selection(modele_id, selected_feature_slugs) do
    supported = supported_feature_slugs(modele_id) |> MapSet.new()
    selected = MapSet.new(selected_feature_slugs)

    unsupported = MapSet.difference(selected, supported) |> MapSet.to_list()

    if unsupported == [] do
      :ok
    else
      {:error, unsupported}
    end
  end

  @doc """
  Vérification complète : features, capteurs requis, et options matérielles.

  Retourne `%{valid?: boolean(), errors: [String.t()], warnings: [String.t()]}`.
  """
  def check_full_compatibility(modele_id, selected_feature_slugs, _profil_params \\ %{}) do
    modele =
      ModeleTraceur
      |> Ash.get!(modele_id)
      |> Ash.load!([:features, :capteurs, :model_ports, :types_vehicule])

    supported_features = Enum.map(modele.features, & &1.slug) |> MapSet.new()
    selected_set = MapSet.new(selected_feature_slugs)

    errors = []

    unsupported_features =
      MapSet.difference(selected_set, supported_features) |> MapSet.to_list()

    errors =
      if unsupported_features != [] do
        labels = describe_feature_slugs(unsupported_features)
        ["Fonctionnalités non supportées par le modèle : #{Enum.join(labels, ", ")}" | errors]
      else
        errors
      end

    required_capteur_slugs = extract_required_capteurs(selected_feature_slugs)
    model_capteur_slugs = Enum.map(modele.capteurs || [], & &1.slug) |> MapSet.new()

    missing_capteurs =
      Enum.reject(required_capteur_slugs, &MapSet.member?(model_capteur_slugs, &1))

    errors =
      if missing_capteurs != [] do
        [
          "Capteurs requis manquants sur le modèle : #{Enum.join(missing_capteurs, ", ")}"
          | errors
        ]
      else
        errors
      end

    # Vérification des prérequis matériels dérivés des fonctionnalités
    hardware_errors = check_hardware_requirements(modele, selected_feature_slugs)
    errors = errors ++ hardware_errors

    %{valid?: errors == [], errors: errors, warnings: []}
  end

  defp check_hardware_requirements(modele, feature_slugs) do
    feature_set = MapSet.new(feature_slugs)
    errors = []

    errors =
      if MapSet.member?(feature_set, "fuel_can") and not modele.can_bus do
        ["Le modèle nécessite CAN-Bus pour la sonde carburant (fuel_can)" | errors]
      else
        errors
      end

    errors =
      if MapSet.member?(feature_set, "fuel_rs232") and not modele.rs232 do
        ["Le modèle nécessite RS232 pour la sonde carburant (fuel_rs232)" | errors]
      else
        errors
      end

    errors =
      if MapSet.member?(feature_set, "fuel_analog") and
           (is_nil(modele.nb_analog_inputs) or modele.nb_analog_inputs < 1) do
        [
          "Le modèle nécessite au moins 1 entrée analogique pour la sonde carburant (fuel_analog)"
          | errors
        ]
      else
        errors
      end

    errors =
      if MapSet.member?(feature_set, "fuel_ble") and not modele.bluetooth_ble do
        ["Le modèle nécessite Bluetooth BLE pour la sonde carburant (fuel_ble)" | errors]
      else
        errors
      end

    errors =
      if MapSet.member?(feature_set, "alert_button") and
           (is_nil(modele.nb_digital_inputs) or modele.nb_digital_inputs < 1) do
        [
          "Le modèle nécessite au moins 1 entrée numérique pour le bouton d'alerte (alert_button)"
          | errors
        ]
      else
        errors
      end

    errors =
      if (MapSet.member?(feature_set, "green_driving") or
            MapSet.member?(feature_set, "crash_detection")) and
           not modele.accelerometer do
        [
          "Le modèle nécessite un accéléromètre pour Green Driving et/ou Crash Detection"
          | errors
        ]
      else
        errors
      end

    errors
  end

  @doc """
  Détermine les slugs de capteurs requis par les fonctionnalités sélectionnées.
  """
  def extract_required_capteurs(feature_slugs) do
    Enum.flat_map(feature_slugs, fn slug ->
      case slug do
        "alert_button" -> ~w(alert_button_monitor)
        "buzzer_feature" -> ~w(buzzer)
        "driver_id" -> ~w(driver_identification_monitor)
        "green_driving" -> ~w()
        "fuel_cap" -> ~w(fuel_cap_monitor)
        "fuel_analog" -> ~w(fuel_probe_analog)
        "fuel_rs232" -> ~w(fuel_probe_digital)
        "fuel_ble" -> ~w(fuel_probe_digital)
        "fuel_can" -> ~w(fuel_probe_can_bus)
        "crash_detection" -> ~w()
        _ -> []
      end
    end)
  end

  defp describe_feature_slugs(slugs) do
    features = Feature.read!()
    slug_to_label = Enum.into(features, %{}, &{&1.slug, &1.label})
    Enum.map(slugs, &Map.get(slug_to_label, &1, &1))
  end
end
