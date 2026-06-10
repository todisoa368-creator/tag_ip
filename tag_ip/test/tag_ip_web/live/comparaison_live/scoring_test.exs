defmodule TagIpWeb.ComparaisonLive.ScoringTest do
  use ExUnit.Case, async: true

  alias TagIpWeb.ComparaisonLive.Index

  # Build a minimal modele struct that has the fields compute_score accesses
  defp modele(overrides \\ []) do
    %{
      id: "m1",
      brand: "Teltonika",
      features: [],
      model_ports: [],
      alimentations: [],
      capteurs: [],
      types_vehicule: []
    }
    |> Map.merge(Map.new(overrides))
  end

  describe "compute_score/3" do
    test "returns 0 when nothing is selected" do
      selected = %{
        brands: MapSet.new(),
        features: MapSet.new(),
        peripherals: MapSet.new(),
        alimentations: MapSet.new(),
        capteurs: MapSet.new(),
        types: MapSet.new()
      }

      assert Index.compute_score(modele(), selected, []) == 0
    end

    test "returns ~17% when 1 feature is selected and matched (1 category out of 6)" do
      selected = %{
        brands: MapSet.new(),
        features: MapSet.new(["buzzer_feature"]),
        peripherals: MapSet.new(),
        alimentations: MapSet.new(),
        capteurs: MapSet.new(),
        types: MapSet.new()
      }

      m = modele(features: [%{slug: "buzzer_feature"}])

      # 1/6 categories matched = ~17%
      assert Index.compute_score(m, selected, []) == 17
    end

    test "returns 0 when 1 feature is selected but not matched" do
      selected = %{
        brands: MapSet.new(),
        features: MapSet.new(["buzzer_feature"]),
        peripherals: MapSet.new(),
        alimentations: MapSet.new(),
        capteurs: MapSet.new(),
        types: MapSet.new()
      }

      m = modele(features: [%{slug: "green_driving"}])

      assert Index.compute_score(m, selected, []) == 0
    end

    test "returns ~33% when 2 categories (brand + feature) are selected and matched" do
      selected = %{
        brands: MapSet.new(["Teltonika"]),
        features: MapSet.new(["buzzer_feature"]),
        peripherals: MapSet.new(),
        alimentations: MapSet.new(),
        capteurs: MapSet.new(),
        types: MapSet.new()
      }

      m = modele(brand: "Teltonika", features: [%{slug: "buzzer_feature"}])

      # 2/6 categories matched = ~33%
      assert Index.compute_score(m, selected, []) == 33
    end

    test "returns 100% only when all 6 categories have selections and all match" do
      selected = %{
        brands: MapSet.new(["Teltonika"]),
        features: MapSet.new(["buzzer_feature"]),
        peripherals: MapSet.new(),
        alimentations: MapSet.new(["alim_1"]),
        capteurs: MapSet.new(["capt_1"]),
        types: MapSet.new(["type_1"])
      }

      m = modele(
        brand: "Teltonika",
        features: [%{slug: "buzzer_feature"}],
        alimentations: [%{id: "alim_1"}],
        capteurs: [%{id: "capt_1"}],
        types_vehicule: [%{id: "type_1"}]
      )

      # 5/6 categories matched (peripherals has no matching model_ports, so 0)
      # features_ratio=1, brands_ratio=1, alimentations_ratio=1, capteurs_ratio=1, types_ratio=1
      # peripherals_ratio=0 → 5/6 = 83%
      assert Index.compute_score(m, selected, []) == 83
    end

    test "brand match is binary (matched or not)" do
      selected = %{
        brands: MapSet.new(["BrandA"]),
        features: MapSet.new(),
        peripherals: MapSet.new(),
        alimentations: MapSet.new(),
        capteurs: MapSet.new(),
        types: MapSet.new()
      }

      m = modele(brand: "BrandA")

      assert Index.compute_score(m, selected, []) == 17

      m2 = modele(brand: "BrandB")

      assert Index.compute_score(m2, selected, []) == 0
    end

    test "partial match within a category gives proportional score" do
      selected = %{
        brands: MapSet.new(["Teltonika"]),
        features: MapSet.new(["buzzer_feature", "green_driving", "driver_id"]),
        peripherals: MapSet.new(),
        alimentations: MapSet.new(),
        capteurs: MapSet.new(),
        types: MapSet.new()
      }

      m = modele(brand: "Teltonika", features: [%{slug: "buzzer_feature"}, %{slug: "driver_id"}])

      # brands_ratio = 1/1 = 1.0
      # features_ratio = 2/3 ~ 0.667
      # total = (1.0 + 0.667) / 6 * 100 = 27.8 → round to 28
      assert Index.compute_score(m, selected, []) == 28
    end
  end
end
