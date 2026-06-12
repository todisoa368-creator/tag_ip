defmodule TagIpWeb.CompatibiliteLive.IndexTest do
  use TagIpWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TagIp.Resources.{ProfilMontage, ModeleTraceur, Compatibilite, TrackableType}

  defp seed_admin_user(%{conn: conn}) do
    user = TagIp.AccountsFixtures.user_fixture()
    scope = TagIp.Accounts.Scope.for_user(user)

    user |> Ecto.Changeset.change(role: "admin") |> TagIp.Repo.update!()

    conn =
      conn
      |> TagIpWeb.ConnCase.log_in_user(user)

    {:ok, conn: conn, user: user, scope: scope}
  end

  describe "CompatibiliteLive.Index" do
    setup [:seed_admin_user, :seed_data]

    defp seed_data(%{conn: _conn}) do
      TrackableType.create!(%{slug: "car", label: "Voiture", description: "Véhicule"},
        action: :create
      )

      profil =
        ProfilMontage.create!(
          %{
            name: "Profil Test",
            object_type: "car",
            voltage_min: 12,
            voltage_max: 15
          },
          action: :create
        )

      modele =
        ModeleTraceur.create!(
          %{
            nom: "Test Tracker",
            brand: "TestBrand",
            reference: "TST-001",
            voltage_min: 10,
            voltage_max: 30
          },
          action: :create
        )

      %{profil: profil, modele: modele}
    end

    test "renders the compatibility list page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/compatibilites")

      assert html =~ "Compatibilités"
    end

    test "shows empty state when no compatibilities", %{
      conn: conn,
      profil: _profil,
      modele: _modele
    } do
      {:ok, lv, _html} = live(conn, ~p"/compatibilites")

      html = render(lv)
      assert html =~ "Aucune compatibilité"
    end

    test "displays compatibility after it is calculated", %{
      conn: conn,
      profil: profil,
      modele: modele
    } do
      {:ok, lv, _html} = live(conn, ~p"/compatibilites")

      Compatibilite
      |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
        profil_id: profil.id,
        modele_id: modele.id
      })
      |> Ash.run_action!()

      html = render(lv)
      assert html =~ "Test Tracker"
    end
  end
end
