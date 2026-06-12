defmodule TagIpWeb.ProfilMontageLive.FormTest do
  use TagIpWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TagIp.Resources.{ProfilMontage, TypeVehicule, TrackableType, Organisation}

  setup :register_and_log_in_user

  defp seed_data do
    TrackableType.create!(%{slug: "car", label: "Voiture"}, action: :create)

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

    Organisation.create!(%{slug: "test-org", name: "Test Org"}, action: :create)
    :ok
  end

  describe "ProfilMontageLive.Form new" do
    test "renders the new profile form", %{conn: conn} do
      seed_data()

      {:ok, _lv, html} = live(conn, ~p"/profils/new")

      assert html =~ "Nouveau profil de montage"
      assert html =~ "Étape 1"
    end

    test "shows step 1 fields", %{conn: conn} do
      seed_data()

      {:ok, _lv, html} = live(conn, ~p"/profils/new")

      assert html =~ "Identification du profil"
      assert html =~ "Nom du profil"
      assert html =~ "Type de véhicule"
    end

    test "shows error when submitting step 1 without name", %{conn: conn} do
      seed_data()

      {:ok, lv, _html} = live(conn, ~p"/profils/new")

      lv
      |> element("#step1-form")
      |> render_submit(%{"profile_name" => ""})

      assert lv |> render() =~ "Veuillez saisir un nom de profil"
    end

    test "renders edit form for existing profile", %{conn: conn} do
      seed_data()
      tv = TypeVehicule.read!() |> hd()

      profil =
        ProfilMontage.create!(
          %{
            name: "Profil à modifier",
            object_type: "car",
            type_vehicule_id: tv.id
          },
          action: :create
        )

      {:ok, _lv, html} = live(conn, ~p"/profils/#{profil.id}/edit")

      assert html =~ "Modifier le profil"
    end
  end
end
