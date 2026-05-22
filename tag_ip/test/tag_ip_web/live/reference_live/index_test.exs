defmodule TagIpWeb.ReferenceLive.IndexTest do
  use TagIpWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TagIp.Resources.{Feature, Peripheral, PortType, TrackableType}

  setup :register_and_log_in_user

  defp seed_reference_data do
    port_type =
      PortType.create!(%{
        slug: "digital_input",
        label: "Digital Input (DIN)",
        description: "Entrée numérique"
      })

    Feature.create!(%{
      slug: "geofencing",
      label: "Geofencing",
      description: "Gestion de zones géographiques"
    })

    Peripheral.create!(%{
      name: "SOS Button",
      port_type_id: port_type.id,
      description: "Bouton d'urgence"
    })

    TrackableType.create!(%{
      slug: "car",
      label: "Voiture",
      description: "Véhicule de tourisme"
    })

    :ok
  end

  describe "ReferenceLive.Index" do
    test "renders the page with stats cards", %{conn: conn} do
      seed_reference_data()

      {:ok, _lv, html} = live(conn, ~p"/referentiels")

      assert html =~ "Référentiels"
      assert html =~ "Types de ports"
      assert html =~ "Fonctionnalités"
      assert html =~ "Périphériques"
      assert html =~ "Types traçables"
    end

    test "displays port types in the grid", %{conn: conn} do
      PortType.create!(%{
        slug: "analog_input",
        label: "Analog Input (AIN)",
        description: "Entrée analogique"
      })

      seed_reference_data()

      {:ok, _lv, html} = live(conn, ~p"/referentiels")

      assert html =~ "Analog Input (AIN)"
      assert html =~ "Entrée analogique"
    end

    test "displays features in the grid", %{conn: conn} do
      Feature.create!(%{
        slug: "eco_driving",
        label: "Eco-driving",
        description: "Analyse du comportement"
      })

      seed_reference_data()

      {:ok, _lv, html} = live(conn, ~p"/referentiels")

      assert html =~ "Eco-driving"
      assert html =~ "Analyse du comportement"
    end

    test "displays peripherals with port type badge", %{conn: conn} do
      port_type =
        PortType.create!(%{
          slug: "one_wire",
          label: "1-Wire",
          description: "Bus unifilaire"
        })

      Peripheral.create!(%{
        name: "Temperature Probe",
        port_type_id: port_type.id,
        description: "Sonde de température"
      })

      seed_reference_data()

      {:ok, _lv, html} = live(conn, ~p"/referentiels")

      assert html =~ "Temperature Probe"
      assert html =~ "1-Wire"
      assert html =~ "Sonde de température"
    end

    test "displays trackable types in the grid", %{conn: conn} do
      TrackableType.create!(%{
        slug: "truck",
        label: "Camion",
        description: "Véhicule poids lourd"
      })

      seed_reference_data()

      {:ok, _lv, html} = live(conn, ~p"/referentiels")

      assert html =~ "Camion"
      assert html =~ "Véhicule poids lourd"
    end

    test "has a link back to dashboard", %{conn: conn} do
      seed_reference_data()

      {:ok, lv, _html} = live(conn, ~p"/referentiels")

      assert has_element?(lv, ~s{a[href="/dashboard"]}, "Retour au dashboard")
    end

    test "shows sidebar with legend", %{conn: conn} do
      seed_reference_data()

      {:ok, _lv, html} = live(conn, ~p"/referentiels")

      assert html =~ "Vue globale"
      assert html =~ "Légende"
    end

    test "redirects unauthenticated users to login", %{} do
      conn = Phoenix.ConnTest.build_conn()

      assert {:error, {:redirect, _}} = live(conn, ~p"/referentiels")
    end

    test "displays zero counts when no reference data", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/referentiels")

      assert html =~ "Référentiels"
      assert html =~ "0"
    end
  end
end
