defmodule TagIpWeb.Helpers.LabelHelper do
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
