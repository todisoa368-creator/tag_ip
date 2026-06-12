defmodule TagIpWeb.ProfilMontageLive.ShowTest do
  use TagIpWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TagIp.Resources.{ProfilMontage, TrackableType}

  setup :register_and_log_in_user

  defp seed_trackable_types do
    TrackableType.create!(%{slug: "car", label: "Voiture", description: "Véhicule de tourisme"})
    :ok
  end

  describe "ProfilMontageLive.Show" do
    test "renders profile details", %{conn: conn} do
      seed_trackable_types()
      profil = ProfilMontage.create!(%{name: "Mon Profil", object_type: "car"}, action: :create)

      {:ok, _lv, html} = live(conn, ~p"/profils/#{profil.id}")

      assert html =~ "Mon Profil"
      assert html =~ "Profil"
    end

    test "shows duplicate button", %{conn: conn} do
      seed_trackable_types()
      profil = ProfilMontage.create!(%{name: "À dupliquer", object_type: "car"}, action: :create)

      {:ok, lv, _html} = live(conn, ~p"/profils/#{profil.id}")

      assert has_element?(lv, "button", "Dupliquer")
    end

    test "shows calculate compatibility button", %{conn: conn} do
      seed_trackable_types()
      profil = ProfilMontage.create!(%{name: "Test", object_type: "car"}, action: :create)

      {:ok, lv, _html} = live(conn, ~p"/profils/#{profil.id}")

      assert has_element?(lv, "button", "Calculer")
    end

    test "redirects to list when profile not found", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/profils"}}} =
               live(conn, ~p"/profils/00000000-0000-0000-0000-000000000000")
    end

    test "displays compatibility list when calculated", %{conn: conn} do
      seed_trackable_types()

      profil =
        ProfilMontage.create!(%{name: "Profil Compat", object_type: "car"}, action: :create)

      ProfilMontage.compute_compatibilities(profil.id)

      {:ok, _lv, html} = live(conn, ~p"/profils/#{profil.id}")

      assert html =~ "Compatibilités calculées"
    end
  end
end
