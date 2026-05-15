defmodule TagIpWeb.UserLive.Registration do
  use TagIpWeb, :live_view

  alias TagIp.Accounts
  alias TagIp.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            Créer un compte
            <:subtitle>
              Déjà inscrit ?
              <.link navigate={~p"/users/log-in"} class="font-semibold text-brand hover:underline">
                Se connecter
              </.link>
              maintenant.
            </:subtitle>
          </.header>
        </div>

        <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.input
            field={@form[:email]}
            type="email"
            label="Adresse Email"
            autocomplete="username"
            spellcheck="false"
            required
            phx-mounted={JS.focus()}
          />

          <%!-- AJOUT DU CHAMP MOT DE PASSE --%>
          <.input
            field={@form[:password]}
            type="password"
            label="Mot de passe"
            required
            autocomplete="new-password"
          />

          <.button phx-disable-with="Création du compte..." class="btn btn-primary w-full mt-4">
            Créer un compte
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: TagIpWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    # On initialise le changeset avec les champs vides
    changeset = Accounts.change_user_registration(%User{}, %{})

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        magic_link_min = TagIp.Accounts.UserToken.magic_link_validity_minutes()

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Un email a été envoyé à #{user.email}. Veuillez y accéder pour confirmer votre compte. Le lien magique expire dans #{magic_link_min} minutes."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
