defmodule TagIpWeb.ComparaisonLive.Admin do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ProfileComparaison
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Peripheral

  @impl true
  def mount(_params, _session, socket) do
    profiles = ProfileComparaison.read!()
    modeles = ModeleTraceur.read!()
    peripherals = Peripheral.read!()

    {:ok,
     socket
     |> assign(:page_title, "Comparaisons enregistrées · Administration")
     |> assign(:profiles, profiles)
     |> assign(:modeles, modeles)
     |> assign(:peripherals, peripherals)}
  end

  def tracker_name(profiles, tracker_id) do
    case Enum.find(profiles, &(&1.id == tracker_id)) do
      nil -> tracker_id
      m -> "#{m.nom} (#{m.reference})"
    end
  end

  def peripheral_name(peripherals, id) do
    case Enum.find(peripherals, &(&1.id == id)) do
      nil -> id
      p -> p.name
    end
  end

  def supplier_label(supplier) do
    case supplier do
      "Wondeproud" -> "WonderProud"
      other -> other
    end
  end

  def feature_label(slug) do
    case slug do
      "alert_button" -> "Alerte bouton (SOS)"
      "buzzer_feature" -> "Buzzer"
      "driver_id" -> "ID chauffeur"
      "green_driving" -> "Green Driving"
      "fuel_cap" -> "Bouchon réservoir"
      "fuel_analog" -> "Carburant (Analogique)"
      "fuel_rs232" -> "Carburant (RS232)"
      "fuel_ble" -> "Carburant (BLE)"
      "fuel_can" -> "Carburant (CAN)"
      "crash_detection" -> "Crash Detection"
      _ -> slug
    end
  end
end
