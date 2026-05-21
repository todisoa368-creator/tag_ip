defmodule TagIpWeb.UserLive.LoginTest do
  use TagIpWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import TagIp.AccountsFixtures

  describe "login page" do
    test "renders login page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log-in")

      assert html =~ "Connexion TAG-Monitor"
      assert html =~ "inscrire"
      assert html =~ "Lien magique par email"
    end
  end

  describe "user login - magic link" do
    test "sends magic link email when user exists", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      result = lv |> element("#login_form_magic") |> render_submit(%{user: %{email: user.email}})

      assert {:error, {:live_redirect, _}} = result
    end

    test "does not disclose if user is registered", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      result =
        lv
        |> element("#login_form_magic")
        |> render_submit(%{user: %{email: "idonotexist@example.com"}})

      assert {:error, {:live_redirect, _}} = result
    end
  end

  describe "user login - password" do
    test "redirects if user logs in with valid credentials", %{conn: conn} do
      user = user_fixture() |> set_password()

      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      form =
        form(lv, "#login_form_password",
          user: %{email: user.email, password: valid_user_password(), remember_me: true}
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/dashboard"
    end

    test "redirects to login page with a flash error if credentials are invalid", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      form =
        form(lv, "#login_form_password", user: %{email: "test@email.com", password: "123456"})

      render_submit(form, %{user: %{remember_me: true}})

      conn = follow_trigger_action(form, conn)
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Email ou mot de passe invalide"
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Register button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s{a[href="/users/register"]})
        |> render_click()
        |> follow_redirect(conn, ~p"/users/register")

      assert login_html =~ "Créer un compte"
    end
  end

  describe "re-authentication (sudo mode)" do
    setup %{conn: conn} do
      user = user_fixture()
      %{user: user, conn: log_in_user(conn, user)}
    end

    test "redirects authenticated users away from login page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/dashboard"}}} = live(conn, ~p"/users/log-in")
    end
  end
end
