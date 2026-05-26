defmodule TagIpWeb.ProfilMontageLive.IndexTest do
  use TagIpWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TagIp.Resources.{ProfilMontage, TrackableType}

  setup :register_and_log_in_user

  defp seed_trackable_types do
    TrackableType.create!(%{slug: "car", label: "Voiture", description: "Véhicule de tourisme"})
    :ok
  end

  describe "ProfilMontageLive.Index" do
    test "renders the list of profiles", %{conn: conn} do
      seed_trackable_types()
      ProfilMontage.create!(%{name: "Profil Test", object_type: "car"}, action: :create)

      {:ok, _lv, html} = live(conn, ~p"/profils")

      assert html =~ "Profils de Montage"
      assert html =~ "Profil Test"
    end

    test "renders empty state when no profiles", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/profils")

      assert html =~ "Aucun profil de montage trouvé"
    end

    test "redirects to new profile form when create button clicked", %{conn: conn} do
      seed_trackable_types()
      ProfilMontage.create!(%{name: "Existing", object_type: "car"}, action: :create)

      {:ok, lv, _html} = live(conn, ~p"/profils")

      {:ok, _new_lv, new_html} =
        lv
        |> element(~s{a[href="/profils/new"].bg-blue-600}, "Nouveau Profil")
        |> render_click()
        |> follow_redirect(conn, ~p"/profils/new")

      assert new_html =~ "Nouveau profil de montage"
    end
  end

  describe "duplicate profile" do
    test "duplicate creates a copy inline without redirecting", %{conn: conn} do
      seed_trackable_types()

      profil =
        ProfilMontage.create!(
          %{
            name: "Profil Original",
            object_type: "car",
            description: "Description originale",
            voltage_min: 10_800,
            voltage_max: 32_000
          },
          action: :create
        )

      {:ok, lv, _html} = live(conn, ~p"/profils")

      lv
      |> element("#profil-#{profil.id} button", "Dupliquer")
      |> render_click()

      html = render(lv)
      assert html =~ "Profil Original (copie)"
      assert html =~ "Profil dupliqué"
    end

    test "duplicate button is present for each profile", %{conn: conn} do
      seed_trackable_types()

      profil =
        ProfilMontage.create!(%{name: "Test Duplication", object_type: "car"},
          action: :create
        )

      {:ok, lv, _html} = live(conn, ~p"/profils")

      assert has_element?(lv, "#profil-#{profil.id} button", "Dupliquer")
    end

    test "shows search and action buttons on index", %{conn: conn} do
      seed_trackable_types()

      ProfilMontage.create!(%{name: "Profil Alpha", object_type: "car"}, action: :create)
      ProfilMontage.create!(%{name: "Profil Beta", object_type: "car"}, action: :create)

      {:ok, lv, html} = live(conn, ~p"/profils")

      assert html =~ "Profil Alpha"
      assert html =~ "Profil Beta"

      assert has_element?(lv, ~s{a[href="/profils/new"]}, "Nouveau Profil")
    end
  end
end
