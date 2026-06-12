defmodule TagIp.Resources.CompatibiliteTest do
  use TagIp.DataCase, async: true

  alias TagIp.Resources.{
    Compatibilite,
    TypeVehicule,
    Alimentation,
    Capteur,
    ModeleTraceur,
    ModeleTraceurTypeVehicule,
    ModeleTraceurAlimentation,
    ModeleTraceurCapteur,
    ProfilMontage
  }

  defp seed_referential(_context) do
    TypeVehicule.create!(
      %{
        slug: "truck",
        label: "Camion",
        voltage_min: 12,
        voltage_max: 36,
        inputs_requis: 2,
        outputs_requis: 0
      },
      action: :create
    )

    TypeVehicule.create!(
      %{
        slug: "car",
        label: "Voiture",
        voltage_min: 12,
        voltage_max: 15,
        inputs_requis: 1,
        outputs_requis: 0
      },
      action: :create
    )

    Alimentation.create!(%{slug: "12V", label: "12V", category: "voltage"}, action: :create)
    Alimentation.create!(%{slug: "24V", label: "24V", category: "voltage"}, action: :create)
    Capteur.create!(%{slug: "buzzer", label: "Buzzer", category: "safety"}, action: :create)
    Capteur.create!(%{slug: "geofence", label: "Géofence", category: "safety"}, action: :create)
    Capteur.create!(%{slug: "ignition", label: "Contact", category: "energy"}, action: :create)
    :ok
  end

  defp create_modele(attrs \\ []) do
    defaults = %{
      nom: "Test Tracker",
      brand: "TestBrand",
      reference: "TST-001",
      nb_digital_inputs: 2,
      nb_analog_inputs: 1,
      nb_outputs: 2,
      can_bus: false,
      one_wire: false,
      rs232: false,
      rs485: false,
      bluetooth_ble: false,
      accelerometer: true,
      buffer_memory: 128,
      ip_rating: "IP54",
      voltage_min: 10,
      voltage_max: 30,
      antennes_externes: false,
      ultra_low_power: false
    }

    modele = ModeleTraceur.create!(Map.merge(defaults, Map.new(attrs)), action: :create)

    Ash.load!(modele, [:types_vehicule, :alimentations, :capteurs, :model_ports])
  end

  defp create_profil(attrs \\ []) do
    defaults = %{
      name: "Test Profil",
      object_type: "truck",
      voltage_min: 12,
      voltage_max: 36,
      can_bus_requis: false,
      one_wire_requis: false,
      rs232_requis: false,
      rs485_requis: false,
      bluetooth_ble_requis: false,
      accelerometre_requis: false,
      ultra_low_power_requis: false,
      montage_exterieur: false,
      antenne_deportee: false,
      buzzer: false,
      geofence_enabled: false,
      fuel_probe_type: nil,
      inputs_requis: nil,
      analog_inputs_requis: nil,
      outputs_requis: nil,
      reporting_interval: "interval_30s"
    }

    ProfilMontage.create!(Map.merge(defaults, Map.new(attrs)), action: :create)
  end

  describe "calculer/3" do
    setup [:seed_referential]

    test "returns compatible when all criteria match" do
      truck_tv = Ash.get!(TypeVehicule, slug: "truck")
      alim_12v = Ash.get!(Alimentation, slug: "12V")
      modele = create_modele()

      ModeleTraceurTypeVehicule.create!(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: truck_tv.id
      })

      ModeleTraceurAlimentation.create!(%{
        modele_traceur_id: modele.id,
        alimentation_id: alim_12v.id
      })

      modele = Ash.load!(modele, [:types_vehicule, :alimentations])

      profil = create_profil()

      {score, compatible, _reasons} = Compatibilite.calculer(profil, modele)

      assert compatible == true
      assert score >= 40
    end

    test "returns score 0 when no criteria are selected" do
      modele = create_modele()
      profil = create_profil(object_type: nil, voltage_min: nil, voltage_max: nil)

      {score, compatible, _reasons} = Compatibilite.calculer(profil, modele)

      assert score == 0
      refute compatible
    end

    test "marks incompatible when type_vehicule is not supported" do
      truck_tv = Ash.get!(TypeVehicule, slug: "truck")
      modele = create_modele()

      ModeleTraceurTypeVehicule.create!(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: truck_tv.id
      })

      modele = Ash.load!(modele, [:types_vehicule])

      profil = create_profil(object_type: "boat")

      {_score, compatible, reasons} = Compatibilite.calculer(profil, modele)

      assert compatible == false
      assert Enum.any?(reasons, &String.contains?(&1, "non supporté"))
    end

    test "detects CAN bus support" do
      truck_tv = Ash.get!(TypeVehicule, slug: "truck")
      modele = create_modele(can_bus: true)

      ModeleTraceurTypeVehicule.create!(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: truck_tv.id
      })

      modele = Ash.load!(modele, [:types_vehicule])

      profil = create_profil(can_bus_requis: true)

      {score, compatible, reasons} = Compatibilite.calculer(profil, modele)

      assert compatible == true
      assert Enum.any?(reasons, &String.contains?(&1, "CAN-Bus supportée"))
      assert score > 0
    end

    test "penalizes missing CAN bus when required" do
      modele = create_modele(can_bus: false)

      profil =
        create_profil(can_bus_requis: true, object_type: nil, voltage_min: nil, voltage_max: nil)

      {_score, _compatible, reasons} = Compatibilite.calculer(profil, modele)

      assert Enum.any?(reasons, &String.contains?(&1, "CAN-Bus non supportée"))
    end

    test "checks IP rating for outdoor mounting" do
      modele = create_modele(ip_rating: "IP54")

      profil =
        create_profil(
          montage_exterieur: true,
          object_type: nil,
          voltage_min: nil,
          voltage_max: nil
        )

      {_score, _compatible, reasons} = Compatibilite.calculer(profil, modele)

      assert Enum.any?(reasons, &String.contains?(&1, "IP67"))
    end

    test "validates voltage range compatibility" do
      truck_tv = Ash.get!(TypeVehicule, slug: "truck")
      alim_12v = Ash.get!(Alimentation, slug: "12V")
      modele = create_modele(voltage_min: 10, voltage_max: 30)

      ModeleTraceurTypeVehicule.create!(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: truck_tv.id
      })

      ModeleTraceurAlimentation.create!(%{
        modele_traceur_id: modele.id,
        alimentation_id: alim_12v.id
      })

      modele = Ash.load!(modele, [:types_vehicule, :alimentations])

      profil = create_profil(voltage_min: 12, voltage_max: 24)

      {_score, compatible, reasons} = Compatibilite.calculer(profil, modele)

      assert compatible == true
      assert Enum.any?(reasons, &String.contains?(&1, "Alimentation"))
    end

    test "validates buzzer support via capteurs" do
      buzzer_capt = Ash.get!(Capteur, slug: "buzzer")
      modele = create_modele()
      ModeleTraceurCapteur.create!(%{modele_traceur_id: modele.id, capteur_id: buzzer_capt.id})
      modele = Ash.load!(modele, [:capteurs])

      profil = create_profil(buzzer: true, object_type: nil, voltage_min: nil, voltage_max: nil)

      {_score, compatible, reasons} = Compatibilite.calculer(profil, modele)

      assert compatible == true
      assert Enum.any?(reasons, &String.contains?(&1, "Buzzer supporté"))
    end
  end

  describe "calculer_depuis_params/4" do
    setup [:seed_referential]

    test "computes score from params map" do
      truck_tv = Ash.get!(TypeVehicule, slug: "truck")
      alim_12v = Ash.get!(Alimentation, slug: "12V")
      modele = create_modele(can_bus: true, accelerometer: true)

      ModeleTraceurTypeVehicule.create!(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: truck_tv.id
      })

      ModeleTraceurAlimentation.create!(%{
        modele_traceur_id: modele.id,
        alimentation_id: alim_12v.id
      })

      modele = Ash.load!(modele, [:types_vehicule, :alimentations])

      params = %{
        "object_type" => "truck",
        "voltage_min" => 12,
        "voltage_max" => 36,
        "can_bus_requis" => true,
        "accelerometre_requis" => true,
        "montage_exterieur" => false,
        "antenne_deportee" => false,
        "ultra_low_power_requis" => false,
        "buzzer" => false,
        "geofence_enabled" => false,
        "fuel_probe_type" => nil,
        "inputs_requis" => nil,
        "analog_inputs_requis" => nil,
        "outputs_requis" => nil,
        "one_wire_requis" => false,
        "rs232_requis" => false,
        "rs485_requis" => false,
        "bluetooth_ble_requis" => false
      }

      result = Compatibilite.calculer_depuis_params(params, modele)

      assert result.compatible == true
      assert result.score > 0
      assert is_list(result.details)
    end
  end

  describe "action :calculer_compatibilite" do
    setup [:seed_referential]

    test "creates a compatibility record" do
      truck_tv = Ash.get!(TypeVehicule, slug: "truck")
      alim_12v = Ash.get!(Alimentation, slug: "12V")
      modele = create_modele()

      ModeleTraceurTypeVehicule.create!(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: truck_tv.id
      })

      ModeleTraceurAlimentation.create!(%{
        modele_traceur_id: modele.id,
        alimentation_id: alim_12v.id
      })

      profil = create_profil()

      result =
        Compatibilite
        |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
          profil_id: profil.id,
          modele_id: modele.id
        })
        |> Ash.run_action!()

      assert result.compatible == true
      assert is_integer(result.score)

      saved = Compatibilite |> Ash.Query.do_filter(profil_montage_id: profil.id) |> Ash.read!()
      assert length(saved) == 1
      assert hd(saved).score_compatibilite == result.score
    end
  end

  describe ":clear_all action" do
    setup [:seed_referential]

    test "deletes all compatibility records" do
      truck_tv = Ash.get!(TypeVehicule, slug: "truck")
      alim_12v = Ash.get!(Alimentation, slug: "12V")
      modele = create_modele()

      ModeleTraceurTypeVehicule.create!(%{
        modele_traceur_id: modele.id,
        type_vehicule_id: truck_tv.id
      })

      ModeleTraceurAlimentation.create!(%{
        modele_traceur_id: modele.id,
        alimentation_id: alim_12v.id
      })

      profil = create_profil()

      Compatibilite
      |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
        profil_id: profil.id,
        modele_id: modele.id
      })
      |> Ash.run_action!()

      assert Ash.read!(Compatibilite) |> length() == 1

      {:ok, count} =
        Compatibilite
        |> Ash.ActionInput.for_action(:clear_all, %{})
        |> Ash.run_action()

      assert count >= 1
      assert Ash.read!(Compatibilite) |> length() == 0
    end
  end
end
